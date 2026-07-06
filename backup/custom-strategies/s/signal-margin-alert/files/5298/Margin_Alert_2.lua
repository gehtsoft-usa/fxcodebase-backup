-- Id: 17208
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local NUM_LEVELS = 5;

-- strategy profile initialization routine
-- Defines strategy profile properties and strategy parameters
function Init()
    strategy:name("Margin Alert Signal");
    strategy:description("Alerts with a sound/email whether margin is below one of the levels");
    strategy:setTag("Version", "2");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addBoolean("ACCTALL", "Watch margin on all accounts", "If Yes - margin is watched on all accounts, otherwise one of the accounts should be selected", true);

    strategy.parameters:addString("ACCT", "Account to watch", "Alert will work for a specified account", "");
    strategy.parameters:setFlag("ACCT", core.FLAG_ACCOUNT);

    strategy.parameters:addInteger("UPDATEINTERVAL", "How often check margin", "Margin check time, in seconds.", 3);

    createLevelsParams(NUM_LEVELS);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    strategy.parameters:addGroup("Email Parameters");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end
local ACCT;
local ACCTALL;

local Email;

local ShowAlert;
local SoundFile;
local RecurrentSound;

local host;


local timerId;
local TIMERCOOKIE = 123;
local timerInterval;

local usedMargin = {};

local levels = {};

-- preparation
function Prepare(onlyName)
    ACCT = instance.parameters.ACCT;
    ACCTALL = instance.parameters.ACCTALL;
    timerInterval = instance.parameters.UPDATEINTERVAL;

    fillLevels(NUM_LEVELS);

    local sAccountString;
    if ACCTALL == true then
        sAccountString = "All accounts";
    else
        sAccountString = "" .. ACCT;
    end

    host = core.host;

    local name = profile:id() .. "(" .. sAccountString .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    if ACCTALL == true then
        local acctEnum = host:findTable("accounts"):enumerator();
        local acctRow;
        local idx = 1;
        acctRow = acctEnum:next();
        while acctRow ~= nil do
            usedMargin[acctRow:cell("AccountName")] = getMargin(acctRow);
            idx = idx + 1;
            acctRow = acctEnum:next();
        end;
    else
        local acctRow = host:findTable("accounts"):find("AccountID", ACCT);
        usedMargin[acctRow:cell("AccountName")] = getMargin(acctRow);
    end


    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
    assert(not(instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""), "Sound file must be chosen");
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end

    timerId = host:execute ("setTimer", TIMERCOOKIE, timerInterval);
end

function ReleaseInstance()
    host:execute("killTimer", timerId);
end


--------------------------------------------
-- Recalculate margin level and recheck all levels on timer
--------------------------------------------
function AsyncOperationFinished(cookie, successful, message)
    if ACCTALL == true then
        local acctEnum = host:findTable("accounts"):enumerator();
        local acctRow;
        acctRow = acctEnum:next();
        while acctRow ~= nil do
            checkAcct(acctRow);
            acctRow = acctEnum:next();
        end;
    else
        local acctRow = host:findTable("accounts"):find("AccountID", ACCT);
        checkAcct(acctRow);
    end
end

--------------------------------------------
-- Creates level settings for signal parameters
-- @param numLevels number of possible levels
--------------------------------------------
function createLevelsParams(numLevels)
    for idx = 1, numLevels do
        strategy.parameters:addGroup("Level "..idx);
        strategy.parameters:addBoolean("LEVEL"..idx.."USE", "Use current level?", "If Yes, margin alert is calculated for this level", (idx == 1));
        strategy.parameters:addDouble("LEVEL"..idx, "Margin Level", "Level of margin in percentage or in absolute values", 10*idx);
        strategy.parameters:addString("LEVEL"..idx.."PRCT", "Check Type", "Choose whether check must be done in % of account equity or in exact amount", "P");
        strategy.parameters:addStringAlternative("LEVEL"..idx.."PRCT", "Percents", "", "P");
        strategy.parameters:addStringAlternative("LEVEL"..idx.."PRCT", "Exact Amount", "", "A");
    end
end


--------------------------------------------
-- Read level settings from signal parameters
-- @param numLevels number of possible levels
--------------------------------------------
function fillLevels(numLevels)
    local level;
    for idx = 1, numLevels do
        level = {};
        level.Check = instance.parameters:getBoolean("LEVEL"..idx.."USE");
        level.Level = instance.parameters:getDouble("LEVEL"..idx);
        level.Percentage = instance.parameters:getString("LEVEL"..idx.."PRCT") == "P";
        levels[idx] = level;
    end
end

-- strategy calculation routine
function Update()
end


--------------------------------------------
-- Checks margin on account and send alert if one of levels is broken
-- @param acctRow row from accounts table
--------------------------------------------
function checkAcct(acctRow)
    local currentMargin = getMargin(acctRow);
    local acctName = acctRow:cell("AccountName");
    local previousMargin = usedMargin[acctName];

    for idx = 1, #levels do
        if checkMargin(currentMargin, previousMargin, levels[idx]) then
            doAlert(acctName, currentMargin, levels[idx]);
        end
    end

    usedMargin[acctName] = currentMargin;
end

--------------------------------------------
-- Gets margin level for specified account
-- @param acctRow row from accounts table
-- @return table with usable margin and eqity
--------------------------------------------
function getMargin(acctRow)
    local acct = {};
    acct.UsableMargin = acctRow:cell("UsableMargin");
    acct.Equity = acctRow:cell("Equity");
    return acct;
end

--------------------------------------------
-- Checks whether margin level is broken by current margin.
-- @param currentMargin current margin level
-- @param previousMargin previous margin level
-- @param condition margin level condition
-- @return true if level is broken, false otherwise
--------------------------------------------
function checkMargin(currentMargin, previousMargin, condition)
    if condition.Check then
        local curr, prev;

        if condition.Percentage then
            curr = 100 * currentMargin.UsableMargin/currentMargin.Equity;
            prev = 100 * previousMargin.UsableMargin/previousMargin.Equity;
        else
            curr = currentMargin.UsableMargin;
            prev = previousMargin.UsableMargin;
        end

        if (curr < condition.Level) and (prev > condition.Level) then
            return true;
        end
    end
    return false;
end


--------------------------------------------
-- This function alerts trader about the achieved margin level.
-- @param acctName name of account
-- @param currentMargin achieved level of marign
-- @param level crossed margin level
--------------------------------------------
function doAlert(acctName, currentMargin, level)
    local bid = instance.bid;
    local sLevelString, sMarginString;
    local curr;

    if level.Percentage then
        curr = 100 * currentMargin.UsableMargin/currentMargin.Equity;
        sLevelString = string.format("%.2f%%", level.Level);
        sMarginString = string.format("%.2f%%", curr);
    else
        curr = currentMargin.UsableMargin;
        sLevelString = string.format("%.2f", level.Level);
        sMarginString = string.format("%.2f", curr);
    end

    local message = "Acct #" .. acctName .. " margin(" .. sMarginString  .. ") is below " .. sLevelString;

    if ShowAlert then
        terminal:alertMessage(bid:instrument(), bid:tick(NOW), message, bid:date(NOW));
    end
    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end
    if Email ~= nil then
        local subject, text = FormatEmail(source, message);
        terminal:alertEmail(Email, subject, text);
    end
end


--------------------------------------------
-- Use this function to format alert email
-- @param source Source stream
-- @param message Signal defined message
--------------------------------------------
function FormatEmail(source, message)
    --format email subject
    local subject = "Margin Alert: " .. message;
    --format email text
    local delim = "\013\010";
    local messageDescr = message;
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, math.max(instance.bid:date(instance.bid:size() - 1), instance.ask:date(instance.ask:size() - 1))));
    local dateDescr = "Time: " .. string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local text = messageDescr .. delim .. dateDescr;
    return subject, text;
end

