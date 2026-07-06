-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74446

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



function Init()
    indicator:name("Machine Learning: LVQ-based Strategy");
    indicator:description("Machine Learning: LVQ-based Strategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("param1", "Dataset", "", "close");
    indicator.parameters:addStringAlternative("param1", "Open", "", "open");
    indicator.parameters:addStringAlternative("param1", "High", "", "high");
    indicator.parameters:addStringAlternative("param1", "Low", "", "low");
    indicator.parameters:addStringAlternative("param1", "Close", "", "close");
    indicator.parameters:addStringAlternative("param1", "Median", "", "median");
    indicator.parameters:addStringAlternative("param1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param1", "Weighted", "", "weighted");
    indicator.parameters:addInteger("param2", "Lookback Window |1..2160|", "", 14);
    indicator.parameters:addDouble("param3", "Learning Rate |0.0001..0.1|", "", 0.1, 0.0001, 0.1);
    indicator.parameters:addInteger("param4", "Epochs", "", 5);
    indicator.parameters:addString("param5", "Filter Signals by", "", "Volatility");
    indicator.parameters:addStringAlternative("param5", "Volatility", "", "Volatility");
    indicator.parameters:addStringAlternative("param5", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("param5", "Both", "", "Both");
    indicator.parameters:addStringAlternative("param5", "None", "", "None");
    indicator.parameters:addBoolean("param6", "Reverse Signals?", "", false);
    indicator.parameters:addInteger("param7", "Training Start Year", "", 2020);
    indicator.parameters:addInteger("param8", "Training Start Month", "", 1);
    indicator.parameters:addInteger("param9", "Training Start Day", "", 1);
    indicator.parameters:addInteger("param10", "Training Stop Year", "", 2021);
    indicator.parameters:addInteger("param11", "Training Stop Month", "", 1);
    indicator.parameters:addInteger("param12", "Training Stop Day", "", 1);
    signaler:Init(indicator.parameters);
    indicator.parameters:addDouble("param13", "Lot Size", "", 0.01);
    indicator.parameters:addBoolean("param14", "Show Information?", "", true);
end

local source;
local vars = {};
local BUY;
local wnr;
local signal;
local x;
local time;
local plot1;
local plot2;
local plot3;
local plot4;
local start_long_trade;
local long_trades;
local start_short_trade;
local short_trades;
local wins;
local trade_count;
local time_close;
function Create_volatilityBreak(volmin, volmax)
    local local_vars = {};
    local_vars["ATR1"] = core.indicators:create("ATR", source, volmin);
    local_vars["ATR2"] = core.indicators:create("ATR", source, volmax);
    return {
        GetValue = function(period, mode)
            local_vars["ATR1"]:update(mode);
            local_vars["ATR2"]:update(mode);
            return SafeGreater(local_vars["ATR1"].DATA:tick(period), local_vars["ATR2"].DATA:tick(period));
        end
    };
end
function Create_volumeBreak(thres)
    local local_vars = {};
    local_vars["RSI1"] = core.indicators:create("RSI", source.volume, 14);
    rsivol = instance:addInternalStream(0, 0);
            assert(core.indicators:findIndicator("PINESCRIPT HMA") ~= nil, "Please, download and install PINESCRIPT HMA.lua indicator");
    local_vars["PINESCRIPT HMA1"] = core.indicators:create("PINESCRIPT HMA", rsivol, 10);
    return {
        GetValue = function(period, mode)
            local_vars["RSI1"]:update(mode);
            rsivol_value = local_vars["RSI1"].DATA:tick(period);
            if rsivol_value then
                rsivol[period] = rsivol_value;
            else
                rsivol:setNoData(period);
            end
            local_vars["PINESCRIPT HMA1"]:update(mode);
            osc = local_vars["PINESCRIPT HMA1"].DATA:tick(period);
            return SafeGreater(osc, thres);
        end
    };
end
function Create_getwinner(features, weights0, weights1)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            d0 = 0.;
            d1 = 0.;
            size = features.Value:Size();
            for i = 0, SafeMinus(size, 1), 1 do
                d0 = SafePlus(d0, math.pow(SafeMinus(features.Value:Get(i), weights0.Value:Get(i)), 2));
                d1 = SafePlus(d1, math.pow(SafeMinus(features.Value:Get(i), weights1.Value:Get(i)), 2));
            end
            return (((d0 > d1)) and ((vars["SELL"]:hasData(period) and vars["SELL"]:tick(period) or nil)) or ((((d0 < d1)) and ((BUY:hasData(period) and BUY:tick(period) or nil)) or ((vars["HOLD"]:hasData(period) and vars["HOLD"]:tick(period) or nil)))));
        end
    };
end
function Create_update(features, weights0, weights1, w, lr)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            size = features.Value:Size();
            for i = 0, SafeMinus(size, 1), 1 do
                if ((w:hasData(period) and w:tick(period) or nil) == sell) then
                    Array:Set(weights0.Value, i, SafePlus(weights0.Value:Get(i), SafeMultiply(vars["lrate"], (SafeMinus(features.Value:Get(i), weights0.Value:Get(i))))));
                end
                if ((w:hasData(period) and w:tick(period) or nil) == buy) then
                    Array:Set(weights1.Value, i, SafePlus(weights1.Value:Get(i), SafeMultiply(vars["lrate"], (SafeMinus(features.Value:Get(i), weights1.Value:Get(i))))));
                end
            end
        end
    };
end
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["ds"] = source[instance.parameters.param1];
    vars["p"] = instance.parameters.param2;
    vars["lrate"] = instance.parameters.param3;
    vars["epochs"] = instance.parameters.param4;
    vars["ftype"] = instance.parameters.param5;
    vars["reverse"] = instance.parameters.param6;
    vars["startYear"] = instance.parameters.param7;
    vars["startMonth"] = instance.parameters.param8;
    vars["startDay"] = instance.parameters.param9;
    vars["stopYear"] = instance.parameters.param10;
    vars["stopMonth"] = instance.parameters.param11;
    vars["stopDay"] = instance.parameters.param12;
    BUY = instance:addInternalStream(0, 0);
    vars["SELL"] = instance:addInternalStream(0, 0);
    vars["HOLD"] = instance:addInternalStream(0, 0);
    wnr = instance:addInternalStream(0, 0);
    signal = instance:addInternalStream(0, 0);
    vars["volatilityBreakFunc1"] = Create_volatilityBreak(1, 10);
    vars["volumeBreakFunc2"] = Create_volumeBreak(49);
    vars["volatilityBreakFunc3"] = Create_volatilityBreak(1, 10);
    vars["volumeBreakFunc4"] = Create_volumeBreak(49);
    x = instance:addInternalStream(0, 0);
    vars["RSI2"] = core.indicators:create("RSI", x, vars["p"]);
    vars["PINESCRIPT CCI1"] = core.indicators:create("PINESCRIPT CCI", x, vars["p"]);
    vars["ROC1"] = core.indicators:create("ROC", x, vars["p"]);
    time = instance:addInternalStream(0, 0);
    vars["getwinnerFunc5_param1"] = {};
    vars["getwinnerFunc5_param2"] = {};
    vars["getwinnerFunc5_param3"] = {};
    vars["getwinnerFunc5"] = Create_getwinner(vars["getwinnerFunc5_param1"], vars["getwinnerFunc5_param2"], vars["getwinnerFunc5_param3"]);
    vars["updateFunc6_param1"] = {};
    vars["updateFunc6_param2"] = {};
    vars["updateFunc6_param3"] = {};
    vars["updateFunc6_param4"] = instance:addInternalStream(0, 0);
    vars["updateFunc6"] = Create_update(vars["updateFunc6_param1"], vars["updateFunc6_param2"], vars["updateFunc6_param3"], vars["updateFunc6_param4"], vars["lrate"]);
    vars["getwinnerFunc7_param1"] = {};
    vars["getwinnerFunc7_param2"] = {};
    vars["getwinnerFunc7_param3"] = {};
    vars["getwinnerFunc7"] = Create_getwinner(vars["getwinnerFunc7_param1"], vars["getwinnerFunc7_param2"], vars["getwinnerFunc7_param3"]);
    plot1 = instance:createTextOutput("plot1", "Buy", "Wingdings", 12, core.H_Center, core.V_Bottom, core.colors().Blue);
    plot2 = instance:createTextOutput("plot2", "Sell", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot3 = instance:createTextOutput("plot3", "StopBuy", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    plot4 = instance:createTextOutput("plot4", "StopSell", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Red);
    signaler:Prepare(nameOnly);
    vars["lot_size"] = instance.parameters.param13;
    start_long_trade = instance:addInternalStream(0, 0);
    long_trades = instance:addInternalStream(0, 0);
    start_short_trade = instance:addInternalStream(0, 0);
    short_trades = instance:addInternalStream(0, 0);
    wins = instance:addInternalStream(0, 0);
    trade_count = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator("PINESCRIPT CUM") ~= nil, "Please, download and install PINESCRIPT CUM.lua indicator");
    vars["PINESCRIPT CUM1"] = core.indicators:create("PINESCRIPT CUM", long_trades);
    vars["PINESCRIPT CUM2"] = core.indicators:create("PINESCRIPT CUM", short_trades);
    vars["PINESCRIPT CUM3"] = core.indicators:create("PINESCRIPT CUM", trade_count);
    vars["PINESCRIPT CUM4"] = core.indicators:create("PINESCRIPT CUM", wins);
    time_close = instance:addInternalStream(0, 0);
    Label:Prepare(200);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Label:Clear();
        BUY_value = (-1);
        if BUY_value then
            BUY[period] = BUY_value;
        else
            BUY:setNoData(period);
        end
        SELL_value = 1;
        if SELL_value then
            vars["SELL"][period] = SELL_value;
        else
            vars["SELL"]:setNoData(period);
        end
        HOLD_value = 0;
        if HOLD_value then
            vars["HOLD"][period] = HOLD_value;
        else
            vars["HOLD"]:setNoData(period);
        end
        wnr_value = 0;
        if wnr_value then
            wnr[period] = wnr_value;
        else
            wnr:setNoData(period);
        end
        signal_value = (vars["HOLD"]:hasData(period) and vars["HOLD"]:tick(period) or nil);
        if signal_value then
            signal[period] = signal_value;
        else
            signal:setNoData(period);
        end
        vars["features"] = Array:NewFloat(0, nil);
        vars["weights0"] = Array:NewFloat(3, 1.);
        vars["weights1"] = Array:NewFloat(3, 100.);
        time[period] = source:date(period) * 86400000;
        start_long_trade_value = 0.;
        if start_long_trade_value then
            start_long_trade[period] = start_long_trade_value;
        else
            start_long_trade:setNoData(period);
        end
        long_trades_value = 0.;
        if long_trades_value then
            long_trades[period] = long_trades_value;
        else
            long_trades:setNoData(period);
        end
        start_short_trade_value = 0.;
        if start_short_trade_value then
            start_short_trade[period] = start_short_trade_value;
        else
            start_short_trade:setNoData(period);
        end
        short_trades_value = 0.;
        if short_trades_value then
            short_trades[period] = short_trades_value;
        else
            short_trades:setNoData(period);
        end
        wins_value = 0;
        if wins_value then
            wins[period] = wins_value;
        else
            wins:setNoData(period);
        end
        trade_count_value = 0;
        if trade_count_value then
            trade_count[period] = trade_count_value;
        else
            trade_count:setNoData(period);
        end
        vars["lbl"] = nil;
        time_close[period] = source:date(period) * 86400000 + BarSizeInMS(source:barSize());
    else
        BUY_value = (BUY:hasData(period - 1) and BUY:tick(period - 1) or nil);
        if BUY_value then
            BUY[period] = BUY_value;
        else
            BUY:setNoData(period);
        end
        SELL_value = (vars["SELL"]:hasData(period - 1) and vars["SELL"]:tick(period - 1) or nil);
        if SELL_value then
            vars["SELL"][period] = SELL_value;
        else
            vars["SELL"]:setNoData(period);
        end
        HOLD_value = (vars["HOLD"]:hasData(period - 1) and vars["HOLD"]:tick(period - 1) or nil);
        if HOLD_value then
            vars["HOLD"][period] = HOLD_value;
        else
            vars["HOLD"]:setNoData(period);
        end
        wnr_value = (wnr:hasData(period - 1) and wnr:tick(period - 1) or nil);
        if wnr_value then
            wnr[period] = wnr_value;
        else
            wnr:setNoData(period);
        end
        signal_value = (signal:hasData(period - 1) and signal:tick(period - 1) or nil);
        if signal_value then
            signal[period] = signal_value;
        else
            signal:setNoData(period);
        end
        time[period] = source:date(period) * 86400000;
        start_long_trade_value = (start_long_trade:hasData(period - 1) and start_long_trade:tick(period - 1) or nil);
        if start_long_trade_value then
            start_long_trade[period] = start_long_trade_value;
        else
            start_long_trade:setNoData(period);
        end
        long_trades_value = (long_trades:hasData(period - 1) and long_trades:tick(period - 1) or nil);
        if long_trades_value then
            long_trades[period] = long_trades_value;
        else
            long_trades:setNoData(period);
        end
        start_short_trade_value = (start_short_trade:hasData(period - 1) and start_short_trade:tick(period - 1) or nil);
        if start_short_trade_value then
            start_short_trade[period] = start_short_trade_value;
        else
            start_short_trade:setNoData(period);
        end
        short_trades_value = (short_trades:hasData(period - 1) and short_trades:tick(period - 1) or nil);
        if short_trades_value then
            short_trades[period] = short_trades_value;
        else
            short_trades:setNoData(period);
        end
        wins_value = (wins:hasData(period - 1) and wins:tick(period - 1) or nil);
        if wins_value then
            wins[period] = wins_value;
        else
            wins:setNoData(period);
        end
        trade_count_value = (trade_count:hasData(period - 1) and trade_count:tick(period - 1) or nil);
        if trade_count_value then
            trade_count[period] = trade_count_value;
        else
            trade_count:setNoData(period);
        end
        time_close[period] = source:date(period) * 86400000 + BarSizeInMS(source:barSize());
    end
    buy = ((vars["reverse"]) and (1) or ((-1)));
    sell = ((vars["reverse"]) and ((-1)) or (1));
    x_value = vars["ds"]:tick(period - ((period ~= source:size() - 1) and (0) or (1)));
    if x_value then
        x[period] = x_value;
    else
        x:setNoData(period);
    end
    periodStart = Timestamp(vars["startYear"], vars["startMonth"], vars["startDay"], 0, 0, 0);
    periodStop = Timestamp(vars["stopYear"], vars["stopMonth"], vars["stopDay"], 0, 0, 0);
    filter = (((vars["ftype"] == "Volatility")) and (vars["volatilityBreakFunc1"].GetValue(period, mode)) or ((((vars["ftype"] == "Volume")) and (vars["volumeBreakFunc2"].GetValue(period, mode)) or ((((vars["ftype"] == "Both")) and (vars["volatilityBreakFunc3"].GetValue(period, mode) and vars["volumeBreakFunc4"].GetValue(period, mode)) or (true))))));
    vars["RSI2"]:update(mode);
    f1 = vars["RSI2"].DATA:tick(period);
    vars["PINESCRIPT CCI1"]:update(mode);
    f2 = vars["PINESCRIPT CCI1"].DATA:tick(period);
    vars["ROC1"]:update(mode);
    f3 = vars["ROC1"].DATA:tick(period);
    if SafeGE(time:tick(period), periodStart) and SafeLE(time:tick(period), periodStop) then
        Array:Clear(vars["features"]);
        vars["features"]:Push(f1);
        vars["features"]:Push(f2);
        vars["features"]:Push(f3);
        for i = 1, vars["epochs"], 1 do
            vars["getwinnerFunc5_param1"].Value = vars["features"];
            vars["getwinnerFunc5_param2"].Value = vars["weights0"];
            vars["getwinnerFunc5_param3"].Value = vars["weights1"];
            w = vars["getwinnerFunc5"].GetValue(period, mode);
            vars["updateFunc6_param1"].Value = vars["features"];
            vars["updateFunc6_param2"].Value = vars["weights0"];
            vars["updateFunc6_param3"].Value = vars["weights1"];
            updateFunc6_param4_value = w;
            if updateFunc6_param4_value then
                vars["updateFunc6_param4"][period] = updateFunc6_param4_value;
            else
                vars["updateFunc6_param4"]:setNoData(period);
            end
            vars["updateFunc6"].GetValue(period, mode);
        end
    end
    if SafeGreater(time:tick(period), periodStop) then
        Array:Clear(vars["features"]);
        vars["features"]:Push(f1);
        vars["features"]:Push(f2);
        vars["features"]:Push(f3);
        vars["getwinnerFunc7_param1"].Value = vars["features"];
        vars["getwinnerFunc7_param2"].Value = vars["weights0"];
        vars["getwinnerFunc7_param3"].Value = vars["weights1"];
        wnr_value = vars["getwinnerFunc7"].GetValue(period, mode);
        if wnr_value then
            wnr[period] = wnr_value;
        else
            wnr:setNoData(period);
        end
    end
    if signal:first() > period - 1 then return; end
    signal_value = ((((wnr:hasData(period) and wnr:tick(period) or nil) == (vars["SELL"]:hasData(period) and vars["SELL"]:tick(period) or nil)) and filter) and (sell) or (((((wnr:hasData(period) and wnr:tick(period) or nil) == (BUY:hasData(period) and BUY:tick(period) or nil)) and filter) and (buy) or (Nz((signal:hasData(period - 1) and signal:tick(period - 1) or nil))))));
    if signal_value then
        signal[period] = signal_value;
    else
        signal:setNoData(period);
    end
    changed = Change(signal, period, 1);
    startLongTrade = NumberToBool(changed) and ((signal:hasData(period) and signal:tick(period) or nil) == (BUY:hasData(period) and BUY:tick(period) or nil));
    startShortTrade = NumberToBool(changed) and ((signal:hasData(period) and signal:tick(period) or nil) == (vars["SELL"]:hasData(period) and vars["SELL"]:tick(period) or nil));
    endLongTrade = NumberToBool(changed) and ((signal:hasData(period) and signal:tick(period) or nil) == (vars["SELL"]:hasData(period) and vars["SELL"]:tick(period) or nil));
    endShortTrade = NumberToBool(changed) and ((signal:hasData(period) and signal:tick(period) or nil) == (BUY:hasData(period) and BUY:tick(period) or nil));
    plot1_series = ((startLongTrade) and (source.low:tick(period)) or (nil));
    if plot1_series then
        plot1:set(period, source.low:tick(period), "\241", "");
    else
        plot1:setNoData(period);
    end
    plot2_series = ((startShortTrade) and (source.high:tick(period)) or (nil));
    if plot2_series then
        plot2:set(period, source.high:tick(period), "\242", "");
    else
        plot2:setNoData(period);
    end
    plot3_series = ((endLongTrade) and (source.high:tick(period)) or (nil));
    if plot3_series then
        plot3:set(period, plot3_series, "\253", "");
    else
        plot3:setNoData(period);
    end
    plot4_series = ((endShortTrade) and (source.low:tick(period)) or (nil));
    if plot4_series then
        plot4:set(period, plot4_series, "\253", "");
    else
        plot4:setNoData(period);
    end
    if startLongTrade and period == source:size() - 1 then
        signaler:Signal("Go long!");
    end
    if startShortTrade and period == source:size() - 1 then
        signaler:Signal("Go short!");
    end
    if (startLongTrade or startShortTrade) and period == source:size() - 1 then
        signaler:Signal("Deal Time!");
    end
    ohl3 = (source.open:tick(period) + source.high:tick(period) + source.low:tick(period)) / 3;
    if startLongTrade then
        start_long_trade_value = ohl3;
        if start_long_trade_value then
            start_long_trade[period] = start_long_trade_value;
        else
            start_long_trade:setNoData(period);
        end
    end
    if endLongTrade then
        trade_count_value = 1;
        if trade_count_value then
            trade_count[period] = trade_count_value;
        else
            trade_count:setNoData(period);
        end
        ldiff = (ohl3 - (start_long_trade:hasData(period) and start_long_trade:tick(period) or nil));
        wins_value = (((ldiff > 0)) and (1) or (0));
        if wins_value then
            wins[period] = wins_value;
        else
            wins:setNoData(period);
        end
        long_trades_value = ldiff * vars["lot_size"];
        if long_trades_value then
            long_trades[period] = long_trades_value;
        else
            long_trades:setNoData(period);
        end
    end
    if startShortTrade then
        start_short_trade_value = ohl3;
        if start_short_trade_value then
            start_short_trade[period] = start_short_trade_value;
        else
            start_short_trade:setNoData(period);
        end
    end
    if endShortTrade then
        trade_count_value = 1;
        if trade_count_value then
            trade_count[period] = trade_count_value;
        else
            trade_count:setNoData(period);
        end
        sdiff = ((start_short_trade:hasData(period) and start_short_trade:tick(period) or nil) - ohl3);
        wins_value = (((sdiff > 0)) and (1) or (0));
        if wins_value then
            wins[period] = wins_value;
        else
            wins:setNoData(period);
        end
        short_trades_value = sdiff * vars["lot_size"];
        if short_trades_value then
            short_trades[period] = short_trades_value;
        else
            short_trades:setNoData(period);
        end
    end
    vars["PINESCRIPT CUM1"]:update(mode);
    vars["PINESCRIPT CUM2"]:update(mode);
    cumreturn = SafePlus(vars["PINESCRIPT CUM1"].DATA:tick(period), vars["PINESCRIPT CUM2"].DATA:tick(period));
    vars["PINESCRIPT CUM3"]:update(mode);
    totaltrades = vars["PINESCRIPT CUM3"].DATA:tick(period);
    vars["PINESCRIPT CUM4"]:update(mode);
    totalwins = vars["PINESCRIPT CUM4"].DATA:tick(period);
    totallosses = (((SafeMinus(totaltrades, totalwins) == 0)) and (1) or (SafeMinus(totaltrades, totalwins)));
    if time:first() > period - 1 then return; end
    tbase = (time:tick(period) - time:tick(period - 1)) / 1000;
    if time_close:first() > period - 1 then return; end
    tcurr = (core.host:execute("getServerTime") * 86400000 - time_close:tick(period - 1)) / 1000;
    info = "CR=" .. Str:ToString(cumreturn, "#.#") .. "\nTrades: " .. Str:ToString(totaltrades, "#") .. "\nWin/Loss: " .. Str:ToString(SafeDivide(totalwins, totallosses), "#.##") .. "\nWinrate: " .. Str:ToString(SafeDivide(totalwins, totaltrades), "#.#%") .. "\nBar Time: " .. Str:ToString(tcurr / tbase, "#.#%");
    if instance.parameters.param14 and period == source:size() - 1 then
        label_1_x = period;
        vars["lbl"] = Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, source.close:tick(period)):SetText(info):SetColor(core.colors().Blue + math.floor(100 / 100 * 255) * 16777216):SetTextColor(core.colors().Black):SetStyle("left");
        Label:Delete(Label:Get(vars["lbl"], 1));
    end
end
function Draw(stage, context)
    Label:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
end
Array = {};
function Array:Clear(array)
    if array == nil then
        return;
    end
    array:Clear();
end
function Array:Max(array)
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or maxVal < val then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or minVal > val then
            minVal = val;
        end
    end
    return minVal;
end
function Array:Set(array, index, value)
    if array == nil then
        return;
    end
    array:Set(index, value);
end
function Array:Fill(array, value, from, to)
    if array == nil then
        return;
    end
    array:Fill(value, from, to);
end
function Array:IndexOf(array, value)
    if array == nil then
        return -1;
    end
    return array:IndexOf(value);
end
function Array:NewArray(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    for i = 1, size, 1 do
        newArray.arr[i] = initialValue;
    end
    function newArray:Push(item) self.arr[#self.arr + 1] = item; end
    function newArray:Get(index) return self.arr[index + 1]; end
    function newArray:Set(index, value) self.arr[index + 1] = value; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return #self.arr; end
    function newArray:Clear()
        self.arr = {};
    end
    function newArray:Fill(value, from, to)
        if to == nil then
            to = #self.arr - 1;
        end
        for i = from, to, 1 do
            self.arr[i + 1] = value;
        end
    end
    function newArray:IndexOf(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return i;
            end
        end
        return -1;
    end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Unshift(value)
        local nextValue = value;
        for i = 1, #self.arr, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[#self.arr + 1] = nextValue;
    end
    function newArray:Shift(value)
        table.remove(self.arr, 1);
        self.arr[#self.arr + 1] = nextValue;
    end
    function newArray:Slice(from, to)
        local slice = {};
        slice.Parent = self;
        slice.From = from;
        slice.To = to;
        function slice:Get(index)
            return self.Parent:Get(index + self.From);
        end
        function slice:Size()
            return self.To - self.From;
        end
        function slice:Max()
            return Array:Max(self);
        end
        function slice:Min()
            return Array:Min(self);
        end
        return slice;
    end
    return newArray;
end
function Array:NewLine(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Timestamp(year, month, day, hour, minute, second, tz)
    local date = {};
    date.month = month;
    date.day = day;
    date.year = year;
    date.hour = hour;
    date.min = minute;
    date.sec = second;
    return core.tableToDate(date);
end

function BarSizeInMS(barSize)
    local s, e = core.getcandle(barSize, core.now(), 0, 0)
    return (e - s) * 86400000;
end

function NumberToBool(n)
    return n ~= nil and n ~= 0;
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaulValue == nil then
        defaulValue = 0;
    end
    return value and value or defaultValue;
end
function Change(source, period, length)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
end
signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

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
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
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

function signaler:Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
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
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
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
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
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
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);
Str = {};
function Str:ToString(value, pattern)
    local luaPattern = "";
    local waitNumber = false;
    local digits = 0;
    for i = 1, #pattern do
        local char = string.sub(pattern, i, i);
        if not waitNumber then
            if char == "#" then
                waitNumber = true;
                luaPattern = luaPattern .. "%";
            else
                luaPattern = luaPattern .. char;
            end
        else
            if char == "." then
                luaPattern = luaPattern .. ".";
            elseif char == "#" then
                digits = digits + 1;
            else
                luaPattern = luaPattern .. digits .. "f";
                waitNumber = false;
                digits = 0;
            end
        end
    end
    if waitNumber then
        luaPattern = luaPattern .. digits .. "f";
        waitNumber = false;
        digits = 0;
    end
    
    return string.format(luaPattern, value);
end
Graphics = {};
Graphics.NextId = 2;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;
    
    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    if Graphics.Fonts[1] ~= nil then
        return Graphics.Fonts[1].Id;
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    context:createFont(newFont.Id, "Arial", 0, context:pointsToPixels(10), context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    core.host:trace(math.floor(transparency * 100.0 / 255.0 + 0.5));
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
Label = {};
Label.AllLabels = {};
Label.AllLabelsInOrder = {};
Label.AllSeries = {};
function Label:Clear()
    Label.AllLabels = {};
    Label.AllSeries = {};
    Label.AllLabelsInOrder = {};
end
function Label:Prepare(max_labels_count)
    Label.max_labels_count = max_labels_count;
end
function Label:Get(label, index)
    if label == nil then
        return;
    end
    return label:Get(index);
end
function Label:SetText(label, text)
    if label == nil then
        return;
    end
    label:SetText(text);
end
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
end
function Label:SetY(label, y)
    if label == nil then
        return;
    end
    label:SetY(y);
end
function Label:GetX(label)
    if label == nil then
        return;
    end
    return label:GetX();
end
function Label:GetY(label)
    if label == nil then
        return;
    end
    return label:GetY();
end
function Label:SetStyle(label, style)
    if label == nil then
        return;
    end
    return label:SetStyle(style);
end
function Label:New(id, seriesId, period, price)
    local newLabel = {};
    newLabel.SeriesId = seriesId;
    newLabel.X = period;
    function newLabel:SetX(x)
        self.X = x;
        return self;
    end
    function newLabel:GetX()
        return self.X;
    end
    newLabel.Y = price;
    function newLabel:SetY(y)
        self.Y = y;
        return self;
    end
    function newLabel:GetY()
        return self.Y;
    end
    newLabel.Text = "";
    function newLabel:SetText(text)
        self.Text = text;
        return self;
    end
    newLabel.BGColor = nil;
    function newLabel:SetColor(clr)
        if clr ~= nil then
            self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
            self.BGColor = clr - self.BgColorTransparency * 16777216;
        else
            self.BgColorTransparency = nil;
            self.BGColor = nil;
        end
        self.BGPenId = nil;
        self.BGBrushId = nil;
        return self;
    end
    newLabel.TextColor = core.colors().Black;
    function newLabel:SetTextColor(clr)
        self.TextColor = clr;
        return self;
    end
    newLabel.Style = "down";
    function newLabel:SetStyle(style)
        self.Style = style;
        return self;
    end
    function newLabel:getCoordinates(context, W, H)
        local visible, y = context:pointOfPrice(self.Y);
        local x1, x = context:positionOfBar(self.X)
        if self.Style == "left" then
            return x, y - H / 2, x + W, y + H / 2;
        end
        if self.Style == "down" then
            return x - W / 2, y - H, x + W / 2, y;
        end
        if self.Style == "up" then
            return x - W / 2, y, x + W / 2, y + H;
        end
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        local W, H = context:measureText(Label.FontId, self.Text, context.LEFT);
        local x_from, y_from, x_to, y_to = self:getCoordinates(context, W, H);
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency)
        end
        context:drawText(Label.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    function newLabel:Get(index)
        return Label.AllSeries[self.SeriesId][index + 1];
    end
    self.AllLabels[id .. "_" .. seriesId] = newLabel;
    self.AllLabelsInOrder[#self.AllLabelsInOrder + 1] = newLabel
    if #self.AllLabelsInOrder > self.max_labels_count then
        table.remove(self.AllLines, 1);
    end
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newLabel);
    return newLabel;
end
function Label:Delete(label)
    if label == nil then
        return;
    end
    self:removeFromAllLabels(label);
    self:removeFromAllLabelsByOrder(label);
    self:removeFromSeries(label);
end
function Label:removeFromSeries(label)
    for i = 1, #self.AllSeries[label.SeriesId] do
        if self.AllSeries[label.SeriesId][i] == label then
            table.remove(self.AllSeries[label.SeriesId], i);
            return;
        end
    end
end
function Label:removeFromAllLabels(label)
    for k, v in pairs(self.AllLabels) do
        if v == label then
            self.AllLabels[k] = nil;
            return;
        end
    end
end
function Label:removeFromAllLabelsByOrder(label)
    for i = 1, #self.AllLabelsInOrder do
        if self.AllLabelsInOrder[i] == label then
            table.remove(self.AllLabelsInOrder, i);
            return;
        end
    end
end
function Label:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Label.FontId == nil then
        Label.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, label in pairs(self.AllLabels) do
        label:Draw(stage, context);
    end
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+