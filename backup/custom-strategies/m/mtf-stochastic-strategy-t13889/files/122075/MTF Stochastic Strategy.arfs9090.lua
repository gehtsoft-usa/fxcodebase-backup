-- Id: 22710
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=13889

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

local BAR = true
local FRAMES = {"m5", "m15", "m30"}
local TfNumber = 3

function Init() --The strategy profile initialization
    strategy:name("MTF Stochastic Strategy")
    strategy:description("v2 2018-11-12")
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    local i

    for i = 1, TfNumber, 1 do
        TIMEFRAME(i, FRAMES[i])
    end

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addBoolean("confirm_trend", "Confirm using trend MA", "", false);
    AddAverages("trend_method", "Trend MA Method", "MVA");
    strategy.parameters:addInteger("trend_period", "Trend MA Period", "", 7);
    strategy.parameters:addString("trend_timeframe", "Trend MA time frame", "", "W1");
    strategy.parameters:setFlag("trend_timeframe", core.FLAG_PERIODS);
    strategy.parameters:addString("Direction", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct")
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse")

    CreateTradingParameters()

    strategy.parameters:addGroup("Time Parameters")

    strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false)
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00")
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60)
end

function AddAverages(id, name, default)
    strategy.parameters:addString(id, name, "", default);
    strategy.parameters:addStringAlternative(id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative(id, "EMA", "", "EMA");
    strategy.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative(id, "HMA", "", "HMA");
    strategy.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative(id, "T3", "", "T3");
    strategy.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative(id, "Median", "", "Median");
    strategy.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative(id, "REMA", "", "REMA");
    strategy.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    strategy.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    strategy.parameters:addStringAlternative(id, "HPF", "", "HPF");
    strategy.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function TIMEFRAME(id, FRAME)
    strategy.parameters:addGroup(id .. ". Time Frame")

    if id > 1 then
        strategy.parameters:addBoolean(tostring(id * 100 + 10), "Use This Time Frame", "", true)
    end

    strategy.parameters:addString(tostring(id * 100 + 1), "Fast MA time frame", "", FRAME)
    strategy.parameters:setFlag(tostring(id * 100 + 1), core.FLAG_PERIODS)

    strategy.parameters:addInteger(tostring(id * 100 + 2), "%K Period", "", 5, 2, 1000)
    strategy.parameters:addInteger(tostring(id * 100 + 3), "%D Periof", "", 3, 1, 1000)
    strategy.parameters:addInteger(tostring(id * 100 + 4), "%D slowing periods", "", 3, 1, 1000)

    strategy.parameters:addString(tostring(id * 100 + 5), "Smoothing method for %K", "", "MVA")
    strategy.parameters:addStringAlternative(tostring(id * 100 + 5), "MVA", "", "MVA")
    strategy.parameters:addStringAlternative(tostring(id * 100 + 5), "EMA", "", "EMA")
    strategy.parameters:addStringAlternative(tostring(id * 100 + 5), "MetaTrader", "", "MT")

    strategy.parameters:addString(tostring(id * 100 + 6), "Smoothing method for %D", "", "MVA")
    strategy.parameters:addStringAlternative(tostring(id * 100 + 6), "MVA", "", "MVA")
    strategy.parameters:addStringAlternative(tostring(id * 100 + 6), "EMA", "", "EMA")

    strategy.parameters:addInteger(tostring(id * 100 + 7), "Oversold level", "", 20, 1, 100)
    strategy.parameters:addInteger(tostring(id * 100 + 8), "Overbought level", "", 80, 1, 100)

    strategy.parameters:addBoolean("confirm" .. id, "Confirm using MA", "", false);
    strategy.parameters:addBoolean("confirm_reversal" .. id, "Confirm using Sign of Reversal", "", false);
    AddAverages("confirm_method" .. id, "Method", "MVA");
    strategy.parameters:addInteger("confirm_period" .. id, "Period", "", 7);
    strategy.parameters:addBoolean("confirm_cross" .. id, "Confirm using MA Cross", "", false);
    AddAverages("confirm_cross_slow_method" .. id, "Slow Method", "MVA");
    strategy.parameters:addInteger("confirm_cross_slow_period" .. id, "Slow Period", "", 14);
    AddAverages("confirm_cross_fast_method" .. id, "Fast Method", "MVA");
    strategy.parameters:addInteger("confirm_cross_fast_period" .. id, "Fast Period", "", 7);
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString(
        "ALLOWEDSIDE",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    
    strategy.parameters:addString("stop_type", "Stop Order", "", "no");
    strategy.parameters:addStringAlternative("stop_type", "No stop", "", "no");
    strategy.parameters:addStringAlternative("stop_type", "In Pips", "", "pips");
    strategy.parameters:addStringAlternative("stop_type", "ATR", "", "atr");
    strategy.parameters:addInteger("stop", "Stop Value", "In pips or ATR period", 30);
    strategy.parameters:addDouble("atr_stop_mult", "ATR Stop Multiplicator", "", 2.0);
    strategy.parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
    strategy.parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);

    strategy.parameters:addString("limit_type", "Limit Order", "", "no");
    strategy.parameters:addStringAlternative("limit_type", "No stop", "", "no");
    strategy.parameters:addStringAlternative("limit_type", "In Pips", "", "pips");
    strategy.parameters:addStringAlternative("limit_type", "ATR", "", "atr");
    strategy.parameters:addInteger("limit", "Limit Value", "In pips or ATR period", 30);
    strategy.parameters:addDouble("atr_limit_mult", "ATR Limit Multiplicator", "", 2.0);
    strategy.parameters:addDouble("limit_dist", "Distance to limit for exit confirmation", "", 50);

    strategy.parameters:addString("StopLimitTimeframe", "Timeframe for ATR stop/limit", "", "m1");
    strategy.parameters:setFlag("StopLimitTimeframe", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Alerts")
    signaler:Init(strategy.parameters);
end

local ALLOWEDSIDE
local AllowMultiple
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local BaseSize

local Direction
local Price
local Parameters = {}

local OpenTime, CloseTime, ExitTime, ValidInterval, UseMandatoryClosing
local ToTime
local data = {};
local custom_id;
local StopLimitSource;
local limit_dist;
local trend_ma;
--
function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    custom_id = profile:id() .. "_" .. instance.bid:name();
    Direction = instance.parameters.Direction == "direct"

    local i
    local name = profile:id() .. "( " .. instance.bid:name()

    if instance.parameters.confirm_trend then
        trend_source = ExtSubscribe(2345, nil, instance.parameters.trend_timeframe, instance.parameters.Type == "Bid", "bar");
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "AVERAGES" .. " indicator must be installed");
        trend_ma = core.indicators:create("AVERAGES", trend_source, instance.parameters.trend_method, instance.parameters.trend_period);
    end

    for i = 1, TfNumber, 1 do
        Parameters[tostring(i * 100 + 1)] = instance.parameters:getString(tostring(i * 100 + 1))
        Parameters[tostring(i * 100 + 2)] = instance.parameters:getInteger(tostring(i * 100 + 2))
        Parameters[tostring(i * 100 + 3)] = instance.parameters:getInteger(tostring(i * 100 + 3))
        Parameters[tostring(i * 100 + 4)] = instance.parameters:getInteger(tostring(i * 100 + 4))

        Parameters[tostring(i * 100 + 5)] = instance.parameters:getString(tostring(i * 100 + 5))
        Parameters[tostring(i * 100 + 6)] = instance.parameters:getString(tostring(i * 100 + 6))

        assert(Parameters[tostring(i * 100 + 1)] ~= "t1", "The time frame must not be tick")

        name = name .. "(" .. Parameters[tostring(i * 100 + 1)] .. ", " .. Parameters[tostring(i * 100 + 2)] ..
            ", " .. Parameters[tostring(i * 100 + 3)] .. ", " .. Parameters[tostring(i * 100 + 4)] ..
            ", " .. Parameters[tostring(i * 100 + 5)] .. ", " .. Parameters[tostring(i * 100 + 6)] .. ") ";

        if not nameOnly then
            local item = {};
            if i > 1 then
                item.ON = instance.parameters:getBoolean(tostring(i * 100 + 10))
            end
            item.Source = ExtSubscribe(i, nil, Parameters[tostring(i * 100 + 1)], instance.parameters.Type == "Bid", "bar")

            item.Indicator = core.indicators:create("STOCHASTIC", item.Source, Parameters[tostring(i * 100 + 2)],
                Parameters[tostring(i * 100 + 3)], Parameters[tostring(i * 100 + 4)],
                Parameters[tostring(i * 100 + 5)], Parameters[tostring(i * 100 + 6)])
            item.K = item.Indicator:getStream(0)
            item.D = item.Indicator:getStream(1)
            item.OB = instance.parameters:getInteger(tostring(i * 100 + 7));
            item.OS = instance.parameters:getInteger(tostring(i * 100 + 8));
            item.Confirm = instance.parameters:getBoolean("confirm" .. i);
            item.ConfirmReversal = instance.parameters:getBoolean("confirm_reversal" .. i);
            item.ConfirmCross = instance.parameters:getBoolean("confirm_cross" .. i);
            if item.ConfirmCross then
                item.ConfirmSlowIndi = core.indicators:create("AVERAGES", item.Source
                    , instance.parameters:getString("confirm_cross_slow_method" .. i)
                    , instance.parameters:getInteger("confirm_cross_slow_period" .. i)
                );
                item.ConfirmFastIndi = core.indicators:create("AVERAGES", item.Source
                    , instance.parameters:getString("confirm_cross_fast_method" .. i)
                    , instance.parameters:getInteger("confirm_cross_fast_period" .. i)
                );
            end
            if item.Confirm or item.ConfirmReversal then
                item.ConfirmIndi = core.indicators:create("AVERAGES", item.Source
                    , instance.parameters:getString("confirm_method" .. i)
                    , instance.parameters:getInteger("confirm_period" .. i)
                );
            end
            data[#data + 1] = item;
        end
    end

    name = name .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end
    StopLimitSource = ExtSubscribe(99, nil, instance.parameters.StopLimitTimeframe, instance.parameters.Type == "Bid", "bar")
    ToTime = instance.parameters.ToTime
    ValidInterval = instance.parameters.ValidInterval
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing
    limit_dist = instance.parameters.limit_dist;

    if ToTime == 1 then
        ToTime = core.TZ_EST
    elseif ToTime == 2 then
        ToTime = core.TZ_UTC
    elseif ToTime == 3 then
        ToTime = core.TZ_LOCAL
    elseif ToTime == 4 then
        ToTime = core.TZ_SERVER
    elseif ToTime == 5 then
        ToTime = core.TZ_FINANCIAL
    elseif ToTime == 6 then
        ToTime = core.TZ_TS
    end

    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    CloseTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")
    ExitTime, valid = ParseTime(instance.parameters.ExitTime)
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid")

    if UseMandatoryClosing then
        core.host:execute("setTimer", 42, math.max(ValidInterval / 2, 1))
    end
end

function PrepareTrading()
    AllowMultiple = instance.parameters.AllowMultiple
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE
    AllowTrade = instance.parameters.AllowTrade
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    end
end

function ReleaseInstance()
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end
    core.host:execute("killTimer", 42)
end

function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function ConfirmLong(source, indi, period)
    if not indi.Confirm then
        return true;
    end
    return source.close[period] > indi.ConfirmIndi.DATA[period];
end

function ConfirmShort(source, indi, period)
    if not indi.Confirm then
        return true;
    end
    return source.close[period] < indi.ConfirmIndi.DATA[period];
end

function ConfirmLongTrend(source, period)
    if trend_ma == nil then
        return true;
    end
    return trend_ma.DATA[period] < source.close[period];
end

function ConfirmShortTrend(source, period)
    if trend_ma == nil then
        return true;
    end
    return trend_ma.DATA[period] > source.close[period];
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    -- get only time
    now = now - math.floor(now)
    if not InRange(now, OpenTime, CloseTime) then
        return ;
    end

    if id ~= 1 then
        return
    end

    if trend_ma ~= nil then
        trend_ma:update(core.UpdateLast);
    end
    local i
    for i = 1, TfNumber, 1 do
        data[i].Indicator:update(core.UpdateLast);
        if data[i].ConfirmIndi ~= nil then
            data[i].ConfirmIndi:update(core.UpdateLast);
        end
        if data[i].ConfirmSlowIndi ~= nil then
            data[i].ConfirmSlowIndi:update(core.UpdateLast);
        end
        if data[i].ConfirmFastIndi ~= nil then
            data[i].ConfirmFastIndi:update(core.UpdateLast);
        end
    end

    local FLAG = true
    for i = 1, TfNumber, 1 do
        if data[i].D:size() <= data[i].D:first() + 2 then
            FLAG = false
        end
    end
    if not FLAG then
        return
    end
    if
        core.crossesOver(data[1].K, data[1].D, data[1].K:size() - 2, data[1].D:size() - 2) and
            (data[2].K[data[2].K:size() - 2] > data[2].D[data[2].D:size() - 2] or not data[2].ON) and
            (data[3].K[data[3].K:size() - 2] > data[3].D[data[3].D:size() - 2] or not data[3].ON) and
            data[1].K[data[1].K:size() - 2] < data[1].OS and
            (data[2].K[data[2].K:size() - 2] < data[2].OS or not data[2].ON) and
            (data[3].K[data[3].K:size() - 2] < data[3].OS or not data[3].ON)
            and ConfirmLong(source, data[1], NOW)
            and ConfirmLong(source, data[2], NOW)
            and ConfirmLong(source, data[3], NOW)
            and not SignOfLongFalling(data[1], NOW)
            and not SignOfLongFalling(data[2], NOW)
            and not SignOfLongFalling(data[3], NOW)
            and ConfirmLongCross(data[1], NOW)
            and ConfirmLongCross(data[2], NOW)
            and ConfirmLongCross(data[3], NOW)
            and ConfirmLongTrend(source, NOW)
    then
        if Direction then
            BUY()
        else
            SELL()
        end
    elseif
        core.crossesUnder(data[1].K, data[1].D, data[1].K:size() - 2, data[1].D:size() - 2) and
            (data[2].K[data[2].K:size() - 2] < data[2].D[data[2].D:size() - 2] or not data[2].ON) and
            (data[3].K[data[3].K:size() - 2] < data[3].D[data[3].D:size() - 2] or not data[3].ON) and
            data[1].K[data[1].K:size() - 2] > data[1].OB and
            (data[2].K[data[2].K:size() - 2] > data[2].OB or not data[2].ON) and
            (data[3].K[data[3].K:size() - 2] > data[3].OB or not data[3].ON)
            and ConfirmShort(source, data[1], NOW)
            and ConfirmShort(source, data[2], NOW)
            and ConfirmShort(source, data[3], NOW)
            and not SignOfShortFalling(data[1], NOW)
            and not SignOfShortFalling(data[2], NOW)
            and not SignOfShortFalling(data[3], NOW)
            and ConfirmShortCross(data[1], NOW)
            and ConfirmShortCross(data[2], NOW)
            and ConfirmShortCross(data[3], NOW)
            and ConfirmShortTrend(source, NOW)
     then
        if Direction then
            SELL()
        else
            BUY()
        end
    end
    --in a current open position long and and 50 pts away from TP and price closes 
    --through MVA in a reverse would alert possible trend reversal and pop up box alert would say Exit confirmed
end

function ConfirmLongCross(indi, period)
    if not indi.ConfirmCross then
        return true;
    end
    return indi.ConfirmSlowIndi.DATA[period] < indi.ConfirmFastIndi.DATA[period];
end

function ConfirmShortCross(indi, period)
    if not indi.ConfirmCross then
        return true;
    end
    return indi.ConfirmSlowIndi.DATA[period] > indi.ConfirmFastIndi.DATA[period];
end

function SignOfLongFalling(indi, period)
    if not indi.ConfirmReversal then
        return false;
    end
    if indi.K[period] < indi.OB then
        return false;
    end
    if trading.LimitATR ~= nil then
        local distanceToLimit = (trading.LimitATR.DATA[period] * instance.parameters.atr_limit_mult) / instance.bid:pipSize();
        if distanceToLimit < limit_dist then
            return false;
        end
    end
    local result = core.crossesUnder(indi.Source.close, indi.ConfirmIndi.DATA, period);
    if result then
        core.host:trace("Signs of long falling");
    end
    return result;
end

function SignOfShortFalling(indi, period)
    if not indi.ConfirmReversal then
        return false;
    end
    if indi.K[period] > indi.OS then
        return false;
    end
    if trading.LimitATR then
        local distanceToLimit = (trading.LimitATR.DATA[period] * instance.parameters.atr_limit_mult) / instance.bid:pipSize();
        if distanceToLimit < limit_dist then
            return false;
        end
    end
    local result = core.crossesOver(indi.Source.close, indi.ConfirmIndi.DATA, period);
    if result then
        core.host:trace("Signs of short falling");
    end
    return result;
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == 42 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime")
            now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
            -- get only time
            now = now - math.floor(now)

            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + (ValidInterval / 86400.0) then
                if not checkReady("trades") then
                    return
                end

                if haveTrades("B") then
                    exit("B")
                    signaler:Signal("Close Long")
                end

                if haveTrades("S") then
                    exit("S")
                    signaler:Signal("Close Short")
                end
            end
        end
    end
    if cookie == 201 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            if haveTrades("S") then
                exit("S")
                signaler:Signal("Close Short")
            end
            return
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S") then
                exit("S")
                signaler:Signal("Close Short")
            end
            return
        end

        if haveTrades("S") then
            exit("S")
            signaler:Signal("Close Short")
        end

        enter("B")
    else
        signaler:Signal("Up Trend")
    end
end

function SELL()
    if AllowTrade then
        if haveTrades("S") and not AllowMultiple then
            if haveTrades("B") then
                exit("B")
                signaler:Signal("Close Long")
            end
            return
        end

        if ALLOWEDSIDE == "Buy" then
            if haveTrades("B") then
                exit("B")
                signaler:Signal("Close Long")
            end
            return
        end

        if haveTrades("B") then
            exit("B")
            signaler:Signal("Close Long")
        end

        enter("S")
    else
        signaler:Signal("Down Trend")
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

function tradesCount(BuySell)
    local count = 0
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    -- NG: to get the true count we must NOT stop when count is not a zero or
    -- the function will return 1 or 0 only and will work as "haveTrades"
    -- while count == 0 and row ~= nil do
    while row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            count = count + 1
        end
        row = enum:next()
    end
    return count
end

function haveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            found = true
        end
        row = enum:next()
    end
    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not AllowMultiple then
        return true
    end

    local command = trading:MarketOrder(StopLimitSource:instrument())
        :SetSide(BuySell)
        :SetAccountID(Account)
        :SetAmount(Amount)
        :SetCustomID(custom_id);
    if instance.parameters.stop_type == "pips" then
        command = command:SetPipStop(nil, instance.parameters.stop, instance.parameters.use_trailing and instance.parameters.trailing);
        stop = instance.parameters.stop;
    end
    if instance.parameters.limit_type == "pips" then
        command = command:SetPipLimit(nil, instance.parameters.limit);
        limit = instance.parameters.limit;
    end
    local result = command:Execute();
    if instance.parameters.stop_type == "atr" then
        breakeven:CreateIndicatorTrailingController()
            :SetRequestID(result.RequestID)
            :SetTrailingTarget(breakeven.STOP_ID)
            :SetIndicatorStream(trading.StopATR.DATA, instance.parameters.atr_stop_mult, true)
        ;
    end
    if instance.parameters.limit_type == "atr" then
        breakeven:CreateIndicatorTrailingController()
            :SetRequestID(result.RequestID)
            :SetTrailingTarget(breakeven.LIMIT_ID)
            :SetIndicatorStream(trading.LimitATR.DATA, instance.parameters.atr_limit_mult, true)
        ;
    end
    if BuySell == "B" then
        local stop = "";
        local limit = "";
        if instance.parameters.stop_type == "pips" then
            stop = instance.ask:tick(NOW) - instance.parameters.stop * instance.bid:pipSize();
        end
        if instance.parameters.limit_type == "pips" then
            limit = instance.ask:tick(NOW) + instance.parameters.limit * instance.bid:pipSize();
        end
        if instance.parameters.stop_type == "atr" then
            stop = instance.ask:tick(NOW) - trading.StopATR.DATA[NOW] * instance.parameters.atr_stop_mult;
        end
        if instance.parameters.limit_type == "atr" then
            limit = instance.ask:tick(NOW) + trading.LimitATR.DATA[NOW] * instance.parameters.atr_stop_mult;
        end
        signaler:Signal("Long " .. instance.ask:tick(NOW) .. " SL " .. stop .. " TP " .. limit);
    else
        local stop = "";
        local limit = "";
        if instance.parameters.stop_type == "pips" then
            stop = instance.bid:tick(NOW) + instance.parameters.stop * instance.bid:pipSize();
        end
        if instance.parameters.limit_type == "pips" then
            limit = instance.bid:tick(NOW) - instance.parameters.limit * instance.bid:pipSize();
        end
        if instance.parameters.stop_type == "atr" then
            stop = instance.bid:tick(NOW) + trading.StopATR.DATA[NOW] * instance.parameters.atr_stop_mult;
        end
        if instance.parameters.limit_type == "atr" then
            limit = instance.bid:tick(NOW) - trading.LimitATR.DATA[NOW] * instance.parameters.atr_stop_mult;
        end
        signaler:Signal("Short " .. instance.bid:tick(NOW) .. " SL " .. stop .. " TP " .. limit);
    end
    return true
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")

trading = {};
trading.Name = "Trading";
trading.Version = "4.10";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading._ids_start = nil;
trading._signaler = nil;
trading._account = nil;
trading._amount = 1;
trading._all_modules = {};
trading._limit = nil;
trading._stop = nil;
trading._trailing_stop = nil;
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:Init(parameters)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    if self.AddAmountParameter then
        parameters:addInteger("amount", "Trade Amount in Lots", "", 1);
    end
    if self.AddStopParameter then
        parameters:addBoolean("set_stop", "Set Stop Orders", "", false);
        parameters:addInteger("stop", "Stop Order in pips", "", 30);
        parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
        parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    end
    if self.AddLimitParameter then
        parameters:addBoolean("set_limit", "Set Limit Orders", "", false);
        parameters:addInteger("limit", "Limit Order in pips", "", 30);
    end
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", true);
    parameters:addBoolean("position_cap", "Position Cap", "", false);
    parameters:addInteger("no_of_positions", "No of open positions", "", 1);
    parameters:addInteger("no_of_buy_position", "Max # of buy positions", "", 1);
    parameters:addInteger("no_of_sell_position", "Max # of sell positions", "", 1);
end

function trading:Prepare(name_only)
    --do what you usually do in prepare
    assert(instance.parameters.stop_type ~= "atr" or not instance.parameters.use_trailing, 
        "ATR stop with trailing is not supported");
        if name_only then return; end
    end

function trading:ExtUpdate(id, source, period)
    if instance.parameters.stop_type == "atr" then
        if self.StopATR == nil then
            self.StopATR = core.indicators:create("ATR", StopLimitSource, instance.parameters.stop);
        end
        self.StopATR:update(core.UpdateLast);
    end
    if instance.parameters.limit_type == "atr" then
        if self.LimitATR == nil then
            self.LimitATR = core.indicators:create("ATR", StopLimitSource, instance.parameters.limit);
        end
        self.LimitATR:update(core.UpdateLast);
    end
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        res.Error = not success and message or nil;
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal(res.Error);
            else
                self:trace(res.Error);
            end
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:calculateAmount()
    return self._amount;
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(trade, stop_rate, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(trade, limit_rate)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(order, rate, trailing)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = trailing;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and IsLimitOrderType(row.Type) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and self:IsStopOrderType(row.Type) and self._used_stop_orders[row.OrderID] ~= true then
                self._used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:MoveStop(trade, stop_rate, trailing)
    local order = self:FindStopOrder(trade);
    if order == nil then
        if trailing == 0 then
            trailing = nil;
        end
        return self:CreateStopOrder(trade, stop_rate, trailing);
    else
        if trailing == 0 then
            if order.TrlMinMove ~= 0 then
                trailing = order.TrlMinMove
            else
                trailing = nil;
            end
        end
        return self:ChangeOrder(order, stop_rate, trailing);
    end
end

function trading:MoveLimit(trade, limit_rate)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(trade, limit_rate);
    else
        return self:ChangeOrder(order, limit_rate);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:DeleteOrder(order)
    self:trace(string.format("Deleting order %s", order.OrderID));
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Delete order failed: " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    return res;
end

function trading:GetCustomID(qtxt)
    if qtxt == nil then
        return nil;
    end
    local metadata = self:GetMetadata(qtxt);
    if metadata == nil then
        return qtxt;
    end
    return metadata.CustomID;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:Do(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then action(row); end
            row = enum:next();
        end
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Rate == self.Rate or not self.Rate)
            and (row.Type == self.OrderType or not self.OrderType);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then orders[#orders + 1] = row; end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpen(open) self.Open = open; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:Do(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then action(row); end
            row = enum:next();
        end
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Open == self.Open or not self.Open)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then 
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:Count()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0;
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindClosedTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:ParialClose(trade, amount)
    -- not finished
    local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
    local id = self:getId();
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(id, valuemap);
        if success then
            local res = trading:ClosePartialSuccessResult(msg);
            self._waiting_requests[id] = res;
            return res;
        end
        return trading:ClosePartialFailResult(msg);
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(id, valuemap);
    if success then
        local res = trading:ClosePartialSuccessResult(msg);
        self._waiting_requests[id] = res;
        return res;
    end
    return trading:ClosePartialFailResult(msg);
end

function trading:ClosePartialSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:ClosePartialFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    return res;
end

function trading:Close(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(self._ids_start + 3, valuemap);
    if not(success) then
        if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
        return false;
    end

    return true;
end

function trading:ObjectToJson(obj)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    
    local first = true;
    for idx,t in pairs(obj) do
        local stype = type(t)
        if stype == "number" then json:AddNumber(idx, t);
        elseif stype == "string" then json:AddStr(idx, t);
        elseif stype == "boolean" then json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then --do nothing
        else core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function trading:CreateEntryOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:IsOrderExecuted()
        return self.FixStatus ~= nil and self.FixStatus == "F";
    end
    function res:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then return nil; end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:CreateEntryOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetOrder() return nil; end
    function res:GetClosedTrade() return nil; end
    function res:IsOrderExecuted() return false; end
    return res;
end

function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end

    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetDefaultAmount() self.valuemap.Quantity = self.Parent:calculateAmount() * self:_GetBaseUnitSize(); return self; end
    function builder:SetAmount(amount) self.valuemap.Quantity = amount * self:_GetBaseUnitSize(); return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetRate(rate) if self.valuemap.BuySell == "B" then self.valuemap.OrderType = self.Offer.Ask > rate and "LE" or "SE"; else self.valuemap.OrderType = self.Offer.Bid > rate and "SE" or "LE"; end self.valuemap.Rate = rate; return self; end
    function builder:SetPipLimit(limit_type, limit) self.valuemap.PegTypeLimit = limit_type or "M"; self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit; return self; end
    function builder:set_limit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop) self.valuemap.PegTypeStop = stop_type or "O"; self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:set_stop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:UseDefaultCustomId() self.valuemap.CustomID = self.Parent.CustomID; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        local desc = string.format("Creating %s %s for %s at %f", self.valuemap.BuySell, self.valuemap.OrderType, self.Instrument, self.valuemap.Rate);
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self.valuemap.RateStop ~= nil then
            desc = desc .. " stop " .. self.valuemap.RateStop;
        end
        if self.valuemap.RateLimit ~= nil then
            desc = desc .. " limit " .. self.valuemap.RateLimit;
        end
        self.Parent:trace(desc);
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._PercentOfEquityAmount / 100.0;
            local stop = math.abs(self.valuemap.RateStop - self.valuemap.Rate) / self.Offer.PointSize;
            local possible_loss = self.Offer.PipCost * stop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * self:_GetBaseUnitSize();
        end

        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateEntryOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then module:OnOrder(self.valuemap); end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderFailResult(message);
        end
        local res = trading:CreateEntryOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:StoreMarketOrderResults(res)
    local str = "[";
    for i, t in ipairs(res) do
        local json = t:ToJSON();
        if str == "[" then str = str .. json; else str = str .. "," .. json; end
    end
    return str .. "]";
end
function trading:RestoreMarketOrderResults(str)
    local results = {};
    local position = 2;
    local result;
    while (position < str:len()) do
        local ch = string.sub(str, position, position);
        if ch == "{" then
            result = trading:CreateMarketOrderSuccessResult();
            position = position + 1;
        elseif ch == "}" then
            results[#results + 1] = result;
            result = nil;
            position = position + 1;
        elseif ch == "," then
            position = position + 1;
        else
            local name, value = string.match(str, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return results;
end
function trading:CreateMarketOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        local json = {};
        function json:AddStr(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
        end
        function json:AddNumber(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
        end
        function json:AddBool(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
        end
        function json:ToString() return "{" .. (self.str or "") .. "}"; end
        
        local first = true;
        for idx,t in pairs(self) do
            local stype = type(t)
            if stype == "number" then json:AddNumber(idx, t);
            elseif stype == "string" then json:AddStr(idx, t);
            elseif stype == "boolean" then json:AddBool(idx, t);
            elseif stype == "function" or stype == "table" then --do nothing
            else core.host:trace(tostring(idx) .. " " .. tostring(stype));
            end
        end
        return json:ToString();
    end
    return res;
end
function trading:CreateMarketOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetTrade() return nil; end
    return res;
end

function trading:MarketOrder(instrument)
    local builder = {};
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OrderType = "OM";
    builder.valuemap.OfferID = offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount)
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID);
        self.valuemap.Quantity = amount * base_size;
        return self;
    end
    function builder:SetDefaultAmount()
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.Parent._account);
        self.valuemap.Quantity = self.Parent:calculateAmount() * base_size;
        return self;
    end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:set_limit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:set_stop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateMarketOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then
                module:OnOrder(self.valuemap);
            end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderFailResult(message);
        end
        local res = trading:CreateMarketOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:JsonToObject(json)
    local position = 1;
    local result;
    local results;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            if results ~= nil then
                position = position + 1;
                results[#results + 1] = result;
            else
                return result;
            end
        elseif ch == "," then
            position = position + 1;
        elseif ch == "[" then
            position = position + 1;
            results = {};
        elseif ch == "]" then
            return results;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(json, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetMetadata(qtxt)
    if qtxt == "" then
        return nil;
    end
    local position = 1;
    local result;
    while (position < qtxt:len() + 1) do
        local ch = string.sub(qtxt, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(qtxt, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetTradeMetadata(trade)
    return self:GetMetadata(trade.QTXT);
end
trading:RegisterModule(Modules);

breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "1.8";
breakeven.Debug = false;
breakeven.Default_breakeven_when = 10;
breakeven.Default_use_breakeven = false;
breakeven.Default_breaeven_to = 1;
--private fields
breakeven._breakeven_when = 10;
breakeven._use_breakeven = false;
breakeven._breaeven_to = 1;
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = nil;
breakeven._source_id = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
    parameters:addBoolean("use_breakeven", "Use Breakeven", "", self.Default_use_breakeven);
    parameters:addDouble("breakeven_when", "Breakeven Activation Value, in pips", "", self.Default_breakeven_when);
    parameters:addDouble("breakeven_to", "Breakeven To, in pips", "", self.Default_breaeven_to);
    parameters:addString("TRAILING_LIMIT_TYPE", "Trailing Limit", "", "Off");
    parameters:addStringAlternative("TRAILING_LIMIT_TYPE", "Off", "", "Off");
    parameters:addStringAlternative("TRAILING_LIMIT_TYPE", "Favorable", "moves limit up for long/buy positions, vice versa for short/sell", "Favorable");
    parameters:addStringAlternative("TRAILING_LIMIT_TYPE", "Unfavorable", "moves limit down for long/buy positions, vice versa for short/sell", "Unfavorable");
    parameters:addDouble("TRAILING_LIMIT_TRIGGER", "Trailing Limit Trigger in Pips", "", 0);
    parameters:addDouble("TRAILING_LIMIT_STEP", "Trailing Limit Step in Pips", "", 10);
end

function breakeven:Prepare(nameOnly)
    self._breakeven_when = instance.parameters.breakeven_when;
    self._use_breakeven = instance.parameters.use_breakeven;
    self._breaeven_to = instance.parameters.breakeven_to;
    if self._use_breakeven == nil or self._use_breakeven == true then
        self._source_id = self._ids_start + 1;
        ExtSubscribe(self._source_id, nil, "t1", true, "tick");
    end
    self:trace(string.format("Use breakeven: %s. Profit for trigger breakeven: %s. Breakeven target: %s",
        tostring(self._use_breakeven), tostring(self._breakeven_when), tostring(self._breaeven_to)));
end

function breakeven:ExtUpdate(id, source, period)
    if id ~= self._source_id then
        return;
    end
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function breakeven:CreateBaseController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    function controller:SetTrade(trade)
        self._trade = trade;
        return self;
    end
    function controller:GetOffer()
        if self._offer == nil then
            self._offer = core.host:findTable("offers"):find("Instrument", self._trade.Instrument);
        end
        return self._offer;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
            self._initial_limit = self._trade.Limit;
            self._initial_stop = self._trade.Stop;
        end
        return self._trade;
    end
    return controller;
end

breakeven.STOP_ID = 1;
breakeven.LIMIT_ID = 2;

function breakeven:CreateIndicatorTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:SetIndicatorStream(stream, distance)
        self._stream = stream;
        self._stream_in_distance = distance;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if not self._stream:hasData(NOW) then
            return true;
        end
        if self._target_id == breakeven.STOP_ID then
            local new_level;
            if self._stream_in_distance then
                if trade.BS == "B" then
                    new_level = breakeven:round(trade.Open - self._stream:tick(NOW), self:GetOffer().Digits);
                else
                    new_level = breakeven:round(trade.Open + self._stream:tick(NOW), self:GetOffer().Digits);
                end
            else
                new_level = breakeven:round(self._stream:tick(NOW), self:GetOffer().Digits);
            end
            if self._move_command ~= nil and self._move_command.Finished and not self._move_command.Success then
                core.host:trace(self._move_command.Error)
            end
            if trade.Stop ~= new_level then
                self._move_command = self._parent._trading:MoveStop(trade, new_level);
            end
        else
            local new_level;
            if self._stream_in_distance then
                if trade.BS == "B" then
                    new_level = breakeven:round(trade.Open + self._stream:tick(NOW), self:GetOffer().Digits);
                else
                    new_level = breakeven:round(trade.Open - self._stream:tick(NOW), self:GetOffer().Digits);
                end
            else
                new_level = breakeven:round(self._stream:tick(NOW), self:GetOffer().Digits);
            end
            if trade.Limit ~= new_level then
                self._move_command = self._parent._trading:MoveLimit(trade, new_level);
            end
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateTrailingLimitController()
    local controller = self:CreateBaseController();
    function controller:SetDirection(direction)
        self._direction = direction;
        return self;
    end
    function controller:SetTrigger(trigger)
        self._trigger = trigger;
        return self;
    end
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._direction == 1 then
            if trade.PL >= self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        elseif self._direction == -1 then
            if trade.PL <= -self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        else
            core.host:trace("No direction is set for the trailing limit");
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetDynamicTo(dynamicTo)
        self._dynamicTo = dynamicTo;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetTrailing(trailing)
        self._trailing = trailing
        return self;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        if self._dynamicTo ~= nil then
            return self._dynamicTo(trade);
        end
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            self._parent._trading:MoveStop(trade, self:getTo(), self._trailing);
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:RestoreTrailingOnProfitController(controller)
    controller._parent = self;
    function controller:SetProfitPercentage(profit_pr, min_profit)
        self._profit_pr = profit_pr;
        self._min_profit = min_profit;
        return self;
    end
    function controller:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self._request_id);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function controller:getStopPips(trade)
        local stop = trading:FindStopOrder(trade);
        if stop == nil then
            return nil;
        end
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return (stop.Rate - trade.Open) / offer.PointSize;
        else
            return (trade.Open - stop.Rate) / offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        if self._move_command ~= nil and not self._move_command.Finished then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            if self:GetClosedTrade() ~= nil then
                self._executed = true;
            end
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL < self._min_profit then
            return true;
        end
        local new_stop = trade.PL * (self._profit_pr / 100);
        local current_stop = self:getStopPips(trade);
        if current_stop == nil or current_stop < new_stop then
            local offer = self:GetOffer();
            if trade.BS == "B" then
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open + new_stop * offer.PointSize);
                core.host:trace("Moving stop for " .. trade.TradeID .. " to " .. trade.Open + new_stop * offer.PointSize);
            else
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open - new_stop * offer.PointSize);
                core.host:trace("Moving stop for " .. trade.TradeID .. " to " .. trade.Open - new_stop * offer.PointSize);
            end
            return true;
        end
        return true;
    end
end

function breakeven:CreateTrailingOnProfitController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    self:RestoreTrailingOnProfitController(controller);
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end
breakeven:RegisterModule(Modules);

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.4";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(label);
    end

    if self._show_popup == true then
        local subject, text = self:FormatEmail(source, NOW, label);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print into log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end
signaler:RegisterModule(Modules);