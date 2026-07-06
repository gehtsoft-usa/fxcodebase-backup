--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Volty Channel Stop Trade Strategy");
    strategy:description("The strategy trades using Volty Channel Stop indicator");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Volty Channel Stop Parameters");
    strategy.parameters:addInteger("MA_N", "Moving Average Period", "", 1);
    strategy.parameters:addString("MA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate strategys to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_M", "Wilders*", "", "WMA");
    strategy.parameters:addInteger("ATR_N", "ATR period", "", 10);
    strategy.parameters:addDouble("VF", "Volatility's Factor or Multiplier", "", 4);
    strategy.parameters:addInteger("OF", "Offset factor", "", 0);
    strategy.parameters:addString("P", "Price", "The price to the strategy apply to", "C");
    strategy.parameters:addStringAlternative("P", "Open", "", "O");
    strategy.parameters:addStringAlternative("P", "High", "", "H");
    strategy.parameters:addStringAlternative("P", "Low", "", "L");
    strategy.parameters:addStringAlternative("P", "Close", "", "C");
    strategy.parameters:addStringAlternative("P", "Median", "", "M");
    strategy.parameters:addStringAlternative("P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("P", "Weighted", "", "W");
    strategy.parameters:addBoolean("HiLoE", "Use High/Low envelope", "", false);
    strategy.parameters:addBoolean("HiLoB", "Hi/Lo Break", "", true);
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Confirmation Parameters");
    strategy.parameters:addBoolean("ConfirmSignal", "Use MVA to confirm signal", "", false);
    strategy.parameters:addInteger("CMA_N", "Moving Average Period", "", 100);
    strategy.parameters:addInteger("CMA_L", "Moving Average Look back periods", "", 1);
    strategy.parameters:addString("CMA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate strategys to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("CMA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("CMA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("CMA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("CMA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("CMA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("CMA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("CMA_M", "Wilders*", "", "WMA");
    strategy.parameters:addString("CTF", "Time Frame", "", "H1");
    strategy.parameters:setFlag("CTF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Method and Schedule");
    strategy.parameters:addString("CheckStyle", "Check method", "", "Bar");
    strategy.parameters:addStringAlternative("CheckStyle", "On Recently Closed Bar", "", "Bar");
    strategy.parameters:addStringAlternative("CheckStyle", "On Alive Bar", "", "Tick");
    strategy.parameters:addBoolean("UseSchedule", "Trade in the specified period only", "", false);
    strategy.parameters:addInteger("StartHour", "Period Hour (24H, EST/EDT)", "", 3, 0, 24);
    strategy.parameters:addInteger("EndHour", "End Hour (24H, EST/EDT)", "", 14, 0, 24);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addBoolean("IndicatorAsStop", "Use Indicator Value as additional stop", "", false);
    strategy.parameters:addBoolean("ExitNonConf", "Exit from position on non-confirmed signals", "", false);

    strategy.parameters:addGroup("Alert Parameters");
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

local Email;

local ShowAlert;
local SoundFile;
local RecurrentSound;

local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local IndicatorAsStop;
local ExitNonConf;
local CheckBar;

local ConfirmSignal;
local CMA_L;
local CMA;

local ticksource = nil;
local barsource = nil;
local confirmsource = nil;
local indicator = nil;

local UseSchedule;
local StartHour;
local EndHour;

function Prepare(onlyName)
    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    assert(not(instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""), "Sound file must be chosen");
    assert(core.indicators:findIndicator("VOLTYCHANNEL_STOP") ~= nil, "Please download and install VoltyChannel_Stop indicator!");
    assert(core.indicators:findIndicator(instance.parameters.MA_M) ~= nil, "Please download and install " .. instance.parameters.MA_M .. " moving average indicator!");

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end

    local name;
    name = profile:id() .. "(" .. "VOLTY(" .. instance.bid:name() .. "." .. instance.parameters.TF .. "," ..
                                  instance.parameters.MA_N .. "," .. instance.parameters.MA_M .. "," ..
                                  instance.parameters.ATR_N .. "," ..
                                  instance.parameters.VF .. "," ..
                                  instance.parameters.OF .. "," .. instance.parameters.P .. ")"

    ConfirmSignal = instance.parameters.ConfirmSignal;
    if ConfirmSignal then
        assert(core.indicators:findIndicator(instance.parameters.CMA_M) ~= nil, "Please download and install " .. instance.parameters.CMA_M .. " moving average indicator!");
        CMA_L = instance.parameters.CMA_L;
        name = name .. ",CONFIRM BY " .. instance.parameters.CMA_M .. "(" ..
               instance.bid:name() .. "." .. instance.parameters.CTF .. "," ..
               instance.parameters.CMA_N .. ") " .. CMA_L ..  " bars ago";
    end

    AllowTrade = instance.parameters.AllowTrade;


    if AllowTrade then
        Account = instance.parameters.Account;
        Amount = instance.parameters.Amount * core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit * instance.bid:pipSize();
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop * instance.bid:pipSize();
        TrailingStop = instance.parameters.TrailingStop;
        IndicatorAsStop = instance.parameters.IndicatorAsStop;
        ExitNonConf = instance.parameters.ExitNonConf;
        if (SetLimit or SetStop) and not(CanClose) then
            assert(false, "Stop and limit orders cannot be used by FIFO account");
        end
        name = name .. ",trade)";
    else
        name = name .. ",signal)";
    end

    UseSchedule = instance.parameters.UseSchedule;
    if UseSchedule then
        StartHour = instance.parameters.StartHour;
        EndHour = instance.parameters.EndHour;
        assert(StartHour < EndHour, "Start hour must be less than the end hour");
    end

    instance:name(name);

    if onlyName then
        return ;
    end

    if instance.parameters.CheckStyle == "Tick" then
        CheckBar = false;
    else
        CheckBar = true;
    end

    if not(CheckBar) then
        ticksource = ExtSubscribe(1, nil, "t1", true, "tick");
    end

    barsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
    local iprofile = core.indicators:findIndicator("VOLTYCHANNEL_STOP");
    local iparams = iprofile:parameters();
    iparams:setInteger("MA_N", instance.parameters:getInteger("MA_N"));
    iparams:setString("MA_M", instance.parameters:getString("MA_M"));
    iparams:setInteger("ATR_N", instance.parameters:getInteger("ATR_N"));
    iparams:setDouble("VF", instance.parameters:getDouble("VF"));
    iparams:setInteger("OF", instance.parameters:getInteger("OF"));
    iparams:setString("P", instance.parameters:getString("P"));
    iparams:setBoolean("HiLoE", instance.parameters:getBoolean("HiLoE"));
    iparams:setBoolean("HiLoB", instance.parameters:getBoolean("HiLoB"));
    indicator = iprofile:createInstance(barsource, iparams);

    if ConfirmSignal then
        if instance.parameters.TF == instance.parameters.CTF then
            confirmsource = barsource.close;
        else
            confirmsource = ExtSubscribe(3, nil, instance.parameters.CTF, true, "close");
        end
        CMA = core.indicators:create(instance.parameters.CMA_M, confirmsource, instance.parameters.CMA_N);
        CMA_L = instance.parameters.CMA_L;
    end
end

local loaded = false;
local lastsignal = -1;
local lastsignal_serial = -1;

function ExtUpdate(id, source, period)
    if id == 1 and not(CheckBar) and loaded then
        CheckBar = true;
        ExtUpdate(2, barsource, barsource:size() - 1);
        CheckBar = false;
    elseif not(loaded) and id == 2 then
        core.host:trace("loaded");
        loaded = true;
    elseif id == 2 and period > 1 and CheckBar then
        if UseSchedule then
            local currhour = math.floor(instance.bid:date(NOW) * 24 + 0.005) % 24;
            if currhour < StartHour or currhour >= EndHour then
                return ;
            end
        end


        indicator:update(core.UpdateLast);
        -- check whether the signal appears
        if not(indicator.DnBuffer:hasData(period - 1)) and indicator.DnBuffer:hasData(period) then
            if ConfirmSignal then
                local period1 = confirmsource:size() - 1;
                CMA:update(core.UpdateLast);
                if (CMA.DATA:first() >= (period1 - CMA_L)) or
                   (CMA.DATA[period1 - CMA_L] < CMA.DATA[period1]) then
                    if lastsignal == 1 and lastsignal_serial == source:serial(period) then
                        return;
                    end
                    lastsignal = 1;
                    lastsignal_serial = source:serial(period);
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short is not confimed", instance.bid:date(NOW));
                    if SoundFile ~= nil then
                        terminal:alertSound(SoundFile, false);
                    end
                    if ExitNonConf then
                        exit("B");
                    end
                    return ;
                end
            end

            if lastsignal == 2 and lastsignal_serial == source:serial(period) then
                return;
            end

            lastsignal = 2;
            lastsignal_serial = source:serial(period);

            -- switch to short
            if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
            end

            if SoundFile ~= nil then
                terminal:alertSound(SoundFile, RecurrentSound);
            end

            if Email ~= nil then
                terminal:alertEmail(Email, "Open Short Position", "Volty Channel Stop Open Short Position")
            end


            exit("B");
            enter("S");
        elseif not(indicator.UpBuffer:hasData(period - 1)) and indicator.UpBuffer:hasData(period) then
            if ConfirmSignal then
                local period1 = confirmsource:size() - 1;
                CMA:update(core.UpdateLast);
                if (CMA.DATA:first() >= (period1 - CMA_L)) or
                   (CMA.DATA[period1 - CMA_L] > CMA.DATA[period1]) then
                    if lastsignal == 3 and lastsignal_serial == source:serial(period) then
                        return;
                    end
                    lastsignal = 3;
                    lastsignal_serial = source:serial(period);
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long is not confimed", instance.bid:date(NOW));
                    if SoundFile ~= nil then
                        terminal:alertSound(SoundFile, false);
                    end
                    if ExitNonConf then
                        exit("S");
                    end
                    return ;
                end
            end

            if lastsignal == 4 and lastsignal_serial == source:serial(period) then
                return;
            end
            lastsignal = 4;
            lastsignal_serial = source:serial(period);

            -- switch to long
            if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
            end
            if SoundFile ~= nil then
                terminal:alertSound(SoundFile, RecurrentSound);
            end

            if Email ~= nil then
                terminal:alertEmail (Email, "Open Long Position ", "Volty Channel Stop Open Long Position")
            end

            exit("S");
            enter("B");
        elseif indicator.DnBuffer:hasData(period) and source.close[period] > indicator.DnBuffer[period] and IndicatorAsStop then
            if lastsignal == 5 and lastsignal_serial == source:serial(period) then
                return;
            end
            lastsignal = 5;
            lastsignal_serial = source:serial(period);

            exit("S");
        elseif indicator.UpBuffer:hasData(period) and source.close[period] < indicator.DnBuffer[period] and IndicatorAsStop then
            if lastsignal == 6 and lastsignal_serial == source:serial(period) then
                return;
            end
            lastsignal = 6;
            lastsignal_serial = source:serial(period);

            exit("B");
        end
    end
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return ;
    end

    local enum, row, valuemap, success, msg;

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    -- do not enter if position in the
    -- specified direction already exists
    if count > 0 then
        return ;
    end


    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount;
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit;
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit;
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop;
        else
            valuemap.RateStop = instance.bid[NOW] + Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
    end

    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
    end
end

-- exit from the specified direction
function exit(BuySell)
    if not(AllowTrade) then
        return ;
    end

    local enum, row, valuemap, success, msg;

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    if count > 0 then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end


dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



