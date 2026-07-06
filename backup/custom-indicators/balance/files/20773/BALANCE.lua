-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?p=20773#p20773

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Balance");
    indicator:description("Shows account historical balance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("account", "Account", "", "");
    indicator.parameters:setFlag("account", core.FLAG_ACCOUNT);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Line color", "Color of Line", core.rgb(255, 255, 255));
end

local timerId;
local account
local source
local day_offset
local week_offset

function Prepare(onlyName)
    source = instance.source;
    host = core.host;

    account = instance.parameters.account

    local name = profile:id() .. "(" .. account .. ")"
    instance:name(name);
    if onlyName then
        return ;
    end

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    require("LuaLib/commons");
    require("LuaLib/reportapi");
    require("LuaLib/reportcache")

    reportcache.initialize(account)
    last_index = 1

    timerId = core.host:execute("setTimer", 1, 1);

    BALANCE = instance:addStream ("BALANCE", core.Line, "BALANCE", "BALANCE", instance.parameters.Color, 0, 0)
end


local last_index = 1

function Update(period, mode)
    -- Check if there are closed trades in source:date(period) and draw arrow
    if mode == core.UpdateAll then
        last_index = 1
    end
    local activities = reportcache.get_activities();

    local start, finish = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);        

    if period == BALANCE:first() then
        BALANCE[period] = 0
        if #activities > 0 then
            BALANCE[period] = activities[1].balance;
        end
    else 
        BALANCE[period] = BALANCE[period - 1]
    end

    for i = last_index, #activities do
        -- Open
        if activities[i].date < finish then --activities[i].date >= start
            BALANCE[period] = activities[i].balance
        end

        if activities[i].date > finish then
            last_index = i
            break
        end
    end

    local showCurrent = false

    if #activities == 0 then
        showCurrent = true
    elseif activities[#activities].date < start then
        showCurrent = true
    end

    if showCurrent then
        BALANCE[period] = host:findTable("accounts"):find("AccountID", account).Balance
    end
end


function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then 
        reportapi.onTimer();

        if reportcache.onTimer() then 
            last_index = 1
            instance:updateFrom(0)
        end
    end
end

function ReleaseInstance()
    reportapi.cancelAll();
end



