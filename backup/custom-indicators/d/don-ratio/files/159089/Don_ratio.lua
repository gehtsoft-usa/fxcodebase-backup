-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75879

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
local vars = {};
function Init()
    indicator:name("Don ratio");
    indicator:description("Don ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "", "", 450);
    indicator.parameters:addBoolean("param2", "HIGH", "", false);
    indicator.parameters:addBoolean("param3", "LOW", "", false);
    indicator.parameters:addBoolean("param4", "Show Bullish/Bearish Zones", "", true);
    indicator.parameters:addBoolean("param5", "Take Profit Long", "", true);
    indicator.parameters:addBoolean("param6", "Take Profit Short", "", true);
    indicator.parameters:addInteger("param7", "Take Profit %", "", 2);
    indicator.parameters:addBoolean("param8", "Stop Loss Long", "", false);
    indicator.parameters:addBoolean("param9", "Stop Loss Short", "", false);
    indicator.parameters:addInteger("param10", "Stop Loss %", "", 3);
    signaler:Init(indicator.parameters);
    indicator.parameters:addBoolean("param11", "Take Profit Long1", "", true);
    indicator.parameters:addBoolean("param12", "Take Profit Short1", "", true);
    indicator.parameters:addInteger("param13", "Take Profit %", "", 2);
    indicator.parameters:addBoolean("param14", "buy again", "", false);
    indicator.parameters:addBoolean("param15", "sell again", "", false);
end

local source;
local plot1;
local plot2;
local time;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
local plot8;
local plot9;
local plot10;
local plot11;
local plot12;
local plot13;
local plot14;
local plot15;
local plot16;
function Create_bton_b(b)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return Triary(SafeGetBool(b, period), 1, 0);
        end
    };
end
function Create_bton1_b(b1)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return Triary(SafeGetBool(b1, period), 1, 0);
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
    vars["tf"] = instance.parameters.param1;
    vars["High"] = instance:addInternalStream(0, 0);
    vars["Low"] = instance:addInternalStream(0, 0);
    vars["HIGH"] = instance.parameters.param2;
    vars["LOW"] = instance.parameters.param3;
    plot1 = instance:createTextOutput("plot1", "high channel", "Arial", 12, core.H_Center, core.V_Top, core.colors().Black);
    plot2 = instance:createTextOutput("plot2", "low channel", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Black);
    vars["showZones"] = instance.parameters.param4;
    vars["ruleState"] = 0;
    vars["bgcolor_1"] = BGColor:Create();
    vars["longCond"] = nil;
    vars["shortCond"] = nil;
    vars["cross_1_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_2_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_2_y_src"] = instance:addInternalStream(0, 0);
    vars["sectionLongs"] = 0;
    vars["sectionShorts"] = 0;
    vars["pyrl"] = 1;
    vars["last_open_longCondition"] = nil;
    vars["last_open_shortCondition"] = nil;
    vars["last_longCondition"] = nil;
    vars["last_shortCondition"] = nil;
    time = instance:addInternalStream(0, 0);
    vars["isTPl"] = instance.parameters.param5;
    vars["isTPs"] = instance.parameters.param6;
    vars["tp"] = instance.parameters.param7;
    vars["cross_3_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_4_y_src"] = instance:addInternalStream(0, 0);
    vars["isSLl"] = instance.parameters.param8;
    vars["isSLs"] = instance.parameters.param9;
    vars["sl"] = 0.0;
    vars["sl"] = instance.parameters.param10;
    vars["cross_5_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_6_y_src"] = instance:addInternalStream(0, 0);
    vars["last_long_close"] = nil;
    vars["last_short_close"] = nil;
    plot3 = instance:createTextOutput("plot3", "buy alert", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Green);
    plot4 = instance:createTextOutput("plot4", "sell alert", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot5 = instance:createTextOutput("plot5", "Take Profit Long", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot6 = instance:createTextOutput("plot6", "Take Profit Short", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Lime);
    plot7 = instance:createTextOutput("plot7", "", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().White);
    plot8 = instance:createTextOutput("plot8", "", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().White);
    plot9 = instance:createTextOutput("plot9", "Stop Loss Long", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot10 = instance:createTextOutput("plot10", "Stop Loss Short", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Lime);
    plot11 = instance:createTextOutput("plot11", "", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().White);
    plot12 = instance:createTextOutput("plot12", "", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().White);
    signaler:Prepare(nameOnly);
    vars["btonFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["btonFunc1"] = Create_bton_b(vars["btonFunc1_param1"]);
    vars["btonFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["btonFunc2"] = Create_bton_b(vars["btonFunc2_param1"]);
    vars["btonFunc3"] = Create_bton_b(long_tp and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])));
    vars["btonFunc4"] = Create_bton_b(short_tp and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])));
    vars["btonFunc5"] = Create_bton_b(long_sl and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])));
    vars["btonFunc6"] = Create_bton_b(short_sl and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])));
    vars["longCond1"] = nil;
    vars["shortCond1"] = nil;
    vars["cross_7_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_8_y_src"] = instance:addInternalStream(0, 0);
    vars["sectionLongs1"] = 0;
    vars["sectionShorts1"] = 0;
    vars["pyrl1"] = 1;
    vars["last_open_longCondition1"] = nil;
    vars["last_open_shortCondition1"] = nil;
    vars["last_longCondition1"] = nil;
    vars["last_shortCondition1"] = nil;
    vars["isTPl1"] = instance.parameters.param11;
    vars["isTPs1"] = instance.parameters.param12;
    vars["tp1"] = instance.parameters.param13;
    vars["cross_9_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_10_y_src"] = instance:addInternalStream(0, 0);
    vars["last_long_close1"] = nil;
    vars["last_short_close1"] = nil;
    vars["buy1"] = instance.parameters.param14;
    vars["sell1"] = instance.parameters.param15;
    plot13 = instance:createTextOutput("plot13", "Buy again", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Blue);
    plot14 = instance:createTextOutput("plot14", "Sell again", "Arial", 12, core.H_Center, core.V_Top, core.colors().Black);
    plot15 = instance:createTextOutput("plot15", "Take Profit Long1", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot16 = instance:createTextOutput("plot16", "Take Profit Short1", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Lime);
    vars["bton1Func7_param1"] = instance:addInternalStream(0, 0);
    vars["bton1Func7"] = Create_bton1_b(vars["bton1Func7_param1"]);
    vars["bton1Func8_param1"] = instance:addInternalStream(0, 0);
    vars["bton1Func8"] = Create_bton1_b(vars["bton1Func8_param1"]);
    vars["bton1Func9"] = Create_bton1_b(long_tp1 and SafeGreater(vars["last_longCondition1"], Nz(vars["last_long_close1"])));
    vars["bton1Func10"] = Create_bton1_b(short_tp1 and SafeGreater(vars["last_shortCondition1"], Nz(vars["last_short_close1"])));
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        BGColor:Clear();
        time[period] = source:date(period) * 86400000;
        vars["btonFunc1"].Clear();
        vars["btonFunc2"].Clear();
        vars["btonFunc3"].Clear();
        vars["btonFunc4"].Clear();
        vars["btonFunc5"].Clear();
        vars["btonFunc6"].Clear();
        vars["bton1Func7"].Clear();
        vars["bton1Func8"].Clear();
        vars["bton1Func9"].Clear();
        vars["bton1Func10"].Clear();
    else
        time[period] = source:date(period) * 86400000;
    end
    lookBack = Triary(Timeframe:IsIntraday() and (Timeframe:Interval() >= 1), vars["tf"] / Timeframe:Interval() * 7, Triary(Timeframe:IsIntraday() and (Timeframe:Interval() < 60), 60 / Timeframe:Interval() * 24 * 7, 7));
    if source.high:first() > period - (lookBack) then return; end
    SafeSetFloat(vars["High"], period, mathex.max(source.high, core.rangeTo(period, lookBack)));
    if source.low:first() > period - (lookBack) then return; end
    SafeSetFloat(vars["Low"], period, mathex.min(source.low, core.rangeTo(period, lookBack)));
    highRatio = SafeMultiply((SafeDivide((SafeMinus(source.close:tick(period), SafeGetFloat(vars["Low"], period))), (SafeMinus(SafeGetFloat(vars["High"], period), SafeGetFloat(vars["Low"], period))))), 500);
    lowRatio = SafeNegative((SafeDivide((SafeMinus(SafeGetFloat(vars["High"], period), source.close:tick(period))), (SafeMinus(SafeGetFloat(vars["High"], period), SafeGetFloat(vars["Low"], period)))))) * 500;
    if vars["High"]:first() > period - (1) then return; end
    highColor = Triary(SafeGreater(SafeGetFloat(vars["High"], period), SafeGetFloat(vars["High"], period - 1)), Graphics:AddTransparency(core.rgb(0, 100, 0), 0), Graphics:AddTransparency(core.rgb(144, 238, 144), 0));
    if vars["Low"]:first() > period - (1) then return; end
    lowRatio1 = Triary(SafeLess(SafeGetFloat(vars["Low"], period), SafeGetFloat(vars["Low"], period - 1)), Graphics:AddTransparency(core.rgb(139, 0, 0), 0), Graphics:AddTransparency(core.rgb(237, 175, 175), 0));
    h = SafeGreater(SafeGetFloat(vars["High"], period), SafeGetFloat(vars["High"], period - 1));
    l = SafeLess(SafeGetFloat(vars["Low"], period), SafeGetFloat(vars["Low"], period - 1));
    PlotShape:SetValue(plot1, period, source, vars["HIGH"] and h, "M", "M", "abovebar");
    PlotShape:SetValue(plot2, period, source, vars["LOW"] and l, "L", "L", "belowbar");
    z = SafePlus(highRatio, lowRatio);
    bullishRule = SafeGE(z, 100);
    bearishRule = SafeLE(z, (-100));
    vars["ruleState"] = Triary(bullishRule, 1, Triary(bearishRule, (-1), Nz(vars["ruleState"])));
    vars["bgcolor_1"]:Set(period, Graphics:AddTransparency(Triary(vars["showZones"], (Triary((vars["ruleState"] == 1), core.colors().Green, Triary((vars["ruleState"] == (-1)), core.colors().Red, core.colors().Yellow))), nil), 90));
    SafeSetFloat(vars["cross_1_x_src"], period, z);
    vars["longCond"] = SafeCrossesOver(vars["cross_1_x_src"], 100, period);
    SafeSetFloat(vars["cross_2_x_src"], period, z);
    SafeSetFloat(vars["cross_2_y_src"], period, (-100));
    vars["shortCond"] = SafeCrossesUnder(vars["cross_2_x_src"], vars["cross_2_y_src"], period);
    vars["sectionLongs"] = Nz(vars["sectionLongs"]);
    vars["sectionShorts"] = Nz(vars["sectionShorts"]);
    if vars["longCond"] then
        vars["sectionLongs"] = vars["sectionLongs"] + 1;
        vars["sectionShorts"] = 0;
    end
    if vars["shortCond"] then
        vars["sectionLongs"] = 0;
        vars["sectionShorts"] = vars["sectionShorts"] + 1;
    end
    longCondition = vars["longCond"] and (vars["sectionLongs"] <= vars["pyrl"]);
    shortCondition = vars["shortCond"] and (vars["sectionShorts"] <= vars["pyrl"]);
    vars["last_open_longCondition"] = Triary(longCondition, source.open:tick(period), Nz(vars["last_open_longCondition"]));
    vars["last_open_shortCondition"] = Triary(shortCondition, source.open:tick(period), Nz(vars["last_open_shortCondition"]));
    vars["last_longCondition"] = Triary(longCondition, time:tick(period), Nz(vars["last_longCondition"]));
    vars["last_shortCondition"] = Triary(shortCondition, time:tick(period), Nz(vars["last_shortCondition"]));
    in_longCondition = SafeGreater(vars["last_longCondition"], vars["last_shortCondition"]);
    in_shortCondition = SafeGreater(vars["last_shortCondition"], vars["last_longCondition"]);
    SafeSetFloat(vars["cross_3_y_src"], period, SafeMultiply((1 + (vars["tp"] / 100)), vars["last_open_longCondition"]));
    long_tp = vars["isTPl"] and SafeCrossesOver(source.high, vars["cross_3_y_src"], period) and (longCondition == 0) and (in_longCondition == 1);
    SafeSetFloat(vars["cross_4_y_src"], period, SafeMultiply((1 - (vars["tp"] / 100)), vars["last_open_shortCondition"]));
    short_tp = vars["isTPs"] and SafeCrossesUnder(source.low, vars["cross_4_y_src"], period) and (shortCondition == 0) and (in_shortCondition == 1);
    SafeSetFloat(vars["cross_5_y_src"], period, SafeMultiply((1 - (vars["sl"] / 100)), vars["last_open_longCondition"]));
    long_sl = vars["isSLl"] and SafeCrossesUnder(source.low, vars["cross_5_y_src"], period) and (longCondition == 0) and (in_longCondition == 1);
    SafeSetFloat(vars["cross_6_y_src"], period, SafeMultiply((1 + (vars["sl"] / 100)), vars["last_open_shortCondition"]));
    short_sl = vars["isSLs"] and SafeCrossesOver(source.high, vars["cross_6_y_src"], period) and (shortCondition == 0) and (in_shortCondition == 1);
    long_close = Triary((long_tp or long_sl), 1, 0);
    short_close = Triary((short_tp or short_sl), 1, 0);
    vars["last_long_close"] = Triary(NumberToBool(long_close), time:tick(period), Nz(vars["last_long_close"]));
    vars["last_short_close"] = Triary(NumberToBool(short_close), time:tick(period), Nz(vars["last_short_close"]));
    PlotShape:SetValue(plot3, period, source, longCondition, "LONG", "LONG", "belowbar");
    PlotShape:SetValue(plot4, period, source, shortCondition, "SHORT", "SHORT", "abovebar");
    PlotShape:SetValue(plot5, period, source, long_tp and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])), "TP", "TP", "abovebar");
    PlotShape:SetValue(plot6, period, source, short_tp and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])), "TP", "TP", "belowbar");
    ltp = Triary(long_tp and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])), SafeMultiply((1 + (vars["tp"] / 100)), vars["last_open_longCondition"]), nil);
    PlotShape:SetValue(plot7, period, source, ltp, "\253", "", plot7_series);
    stp = Triary(short_tp and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])), SafeMultiply((1 - (vars["tp"] / 100)), vars["last_open_shortCondition"]), nil);
    PlotShape:SetValue(plot8, period, source, stp, "\253", "", plot8_series);
    PlotShape:SetValue(plot9, period, source, long_sl and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])), "SL", "SL", "abovebar");
    PlotShape:SetValue(plot10, period, source, short_sl and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])), "SL", "SL", "belowbar");
    lsl = Triary(long_sl and SafeGreater(vars["last_longCondition"], Nz(vars["last_long_close"])), SafeMultiply((1 - (vars["sl"] / 100)), vars["last_open_longCondition"]), nil);
    PlotShape:SetValue(plot11, period, source, lsl, "\253", "", plot11_series);
    ssl = Triary(short_sl and SafeGreater(vars["last_shortCondition"], Nz(vars["last_short_close"])), SafeMultiply((1 + (vars["sl"] / 100)), vars["last_open_shortCondition"]), nil);
    PlotShape:SetValue(plot12, period, source, ssl, "\253", "", plot12_series);
    SafeSetBool(vars["btonFunc1_param1"], period, longCondition);
    if vars["btonFunc1"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(1, "Buy Alert", period, source);
    end
    SafeSetBool(vars["btonFunc2_param1"], period, shortCondition);
    if vars["btonFunc2"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(2, "Sell Alert", period, source);
    end
    if vars["btonFunc3"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(3, "Take Profit Long", period, source);
    end
    if vars["btonFunc4"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(4, "Take Profit Short", period, source);
    end
    if vars["btonFunc5"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(5, "Stop Loss Long", period, source);
    end
    if vars["btonFunc6"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(6, "Stop Loss Short", period, source);
    end
    SafeSetFloat(vars["cross_7_y_src"], period, SafeMultiply((1 + (vars["tp"] / 100)), vars["last_open_longCondition"]));
    vars["longCond1"] = vars["isTPl"] and SafeCrossesOver(source.high, vars["cross_7_y_src"], period) and (longCondition == 0) and (in_longCondition == 1);
    SafeSetFloat(vars["cross_8_y_src"], period, SafeMultiply((1 - (vars["tp"] / 100)), vars["last_open_shortCondition"]));
    vars["shortCond1"] = vars["isTPs"] and SafeCrossesUnder(source.low, vars["cross_8_y_src"], period) and (shortCondition == 0) and (in_shortCondition == 1);
    vars["sectionLongs1"] = Nz(vars["sectionLongs1"]);
    vars["sectionShorts1"] = Nz(vars["sectionShorts1"]);
    if vars["longCond1"] then
        vars["sectionLongs1"] = vars["sectionLongs1"] + 1;
        vars["sectionShorts1"] = 0;
    end
    if vars["shortCond1"] then
        vars["sectionLongs1"] = 0;
        vars["sectionShorts1"] = vars["sectionShorts1"] + 1;
    end
    longCondition1 = vars["longCond1"] and (vars["sectionLongs1"] <= vars["pyrl1"]);
    shortCondition1 = vars["shortCond1"] and (vars["sectionShorts1"] <= vars["pyrl1"]);
    vars["last_open_longCondition1"] = Triary(longCondition1, source.open:tick(period), Nz(vars["last_open_longCondition1"]));
    vars["last_open_shortCondition1"] = Triary(shortCondition1, source.open:tick(period), Nz(vars["last_open_shortCondition1"]));
    vars["last_longCondition1"] = Triary(longCondition1, time:tick(period), Nz(vars["last_longCondition1"]));
    vars["last_shortCondition1"] = Triary(shortCondition1, time:tick(period), Nz(vars["last_shortCondition1"]));
    in_longCondition1 = SafeGreater(vars["last_longCondition1"], vars["last_shortCondition1"]);
    in_shortCondition1 = SafeGreater(vars["last_shortCondition1"], vars["last_longCondition1"]);
    SafeSetFloat(vars["cross_9_y_src"], period, SafeMultiply((1 + (vars["tp"] / 100)), vars["last_open_longCondition1"]));
    long_tp1 = vars["isTPl1"] and SafeCrossesOver(source.high, vars["cross_9_y_src"], period) and (longCondition1 == 0) and (in_longCondition1 == 1);
    SafeSetFloat(vars["cross_10_y_src"], period, SafeMultiply((1 - (vars["tp"] / 100)), vars["last_open_shortCondition1"]));
    short_tp1 = vars["isTPs1"] and SafeCrossesUnder(source.low, vars["cross_10_y_src"], period) and (shortCondition1 == 0) and (in_shortCondition1 == 1);
    long_close1 = Triary(long_tp1, 1, 0);
    short_close1 = Triary(short_tp1, 1, 0);
    vars["last_long_close1"] = Triary(NumberToBool(long_close1), time:tick(period), Nz(vars["last_long_close1"]));
    vars["last_short_close1"] = Triary(NumberToBool(short_close1), time:tick(period), Nz(vars["last_short_close1"]));
    PlotShape:SetValue(plot13, period, source, vars["buy1"] and longCondition1, "b", "b", "belowbar");
    PlotShape:SetValue(plot14, period, source, vars["sell1"] and shortCondition1, "s", "s", "abovebar");
    PlotShape:SetValue(plot15, period, source, long_tp1 and SafeGreater(vars["last_longCondition1"], Nz(vars["last_long_close1"])), "TP1", "TP1", "abovebar");
    PlotShape:SetValue(plot16, period, source, short_tp1 and SafeGreater(vars["last_shortCondition1"], Nz(vars["last_short_close1"])), "TP1", "TP1", "belowbar");
    SafeSetBool(vars["bton1Func7_param1"], period, longCondition1);
    if vars["bton1Func7"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(7, "Buy Again", period, source);
    end
    SafeSetBool(vars["bton1Func8_param1"], period, shortCondition1);
    if vars["bton1Func8"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(8, "Sell Aagin", period, source);
    end
    if vars["bton1Func9"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(9, "Take Profit Long1", period, source);
    end
    if vars["bton1Func10"].GetValue(period, mode) and period == source:size() - 1 then
        signaler:SignalEx(10, "Take Profit Short1", period, source);
    end
end
function Draw(stage, context)
    BGColor:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
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
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
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
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
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
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
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
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local seconds = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local seconds = 60 * 60 * tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "M";
    end
    return "0";
end
function Timeframe:IsIntraday()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "m" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "H" then
        return true;
    end
    return false;
end
function Timeframe:Interval()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "0";
    elseif string.sub(bar_size, 1, 1) == "m" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "H" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "1";
    end
    return "0";
end
function Timeframe:InSeconds(period, source)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
    else
        local minutes = tonumber(timeframe);
        if minutes == nil then
            return nil;
        end
        return minutes * 60;
    end
    return nil;
end
function Timeframe:GetBarSize(timeframe)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
    else
        local minutes = tonumber(timeframe);
        if minutes == 1 then
            return "m1";
        elseif minutes == 5 then
            return "m5";
        elseif minutes == 15 then
            return "m15";
        elseif minutes == 30 then
            return "m30";
        elseif minutes == 60 then
            return "h1";
        elseif minutes == 120 then
            return "h2";
        elseif minutes == 180 then
            return "h3";
        elseif minutes == 240 then
            return "h4";
        elseif minutes == 360 then
            return "h6";
        elseif minutes == 480 then
            return "h8";
        end
    end
    return nil;
end
function Timeframe:Change(timeframe, source, period)
    if period <= 0 then
        return false;
    end
    local barSize = Timeframe:GetBarSize(timeframe);
    if barSize == nil then
        return false;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    local currentDate = core.getcandle(barSize, source:date(period), tradingDayOffset, tradingWeekOffset);
    local prevDate = core.getcandle(barSize, source:date(period - 1), tradingDayOffset, tradingWeekOffset);
    return currentDate ~= prevDate;
end
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
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
    if color == nil then
        return -1;
    end
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
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
end
BGColor = {};
BGColor.AllBGColors = {};
function BGColor:Clear()
end
function BGColor:Create()
    local newBGColor = {};
    newBGColor.Items = {};
    function newBGColor:Draw(stage, context)
        for date, bar in pairs(self.Items) do
            local index = core.findDate(instance.source, date, false);
            if index ~= -1 and index >= context:firstBar() and index <= context:lastBar() then
                if bar.PenId == nil then
                    bar.PenId = Graphics:FindPen(1, bar.Color, core.LINE_SOLID, context);
                end
                if bar.BrushId == nil then
                    bar.BrushId = Graphics:FindBrush(bar.Color, context);
                end
                x, xs, xe = context:positionOfBar(index);
                context:drawRectangle(bar.PenId, bar.BrushId, xs, context:top(), xe, context:bottom(), bar.Transparency);
            end
        end
    end
    function newBGColor:Set(period, clr)
        local date = instance.source:date(period);
        if clr == nil then
            newBGColor.Items[date] = nil;
            return;
        end
        if newBGColor.Items[date] == nil then
            newBGColor.Items[date] = {};
        end
        color, transp = Graphics:SplitColorAndTransparency(clr);
        newBGColor.Items[date].Color = color;
        newBGColor.Items[date].Transparency = transp;
        newBGColor.Items[date].PenId = nil;
        newBGColor.Items[date].BrushId = nil;
    end
    self.AllBGColors[#self.AllBGColors + 1] = newBGColor
    return newBGColor;
end
function BGColor:Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    for i, bgcolor in ipairs(self.AllBGColors) do
        bgcolor:Draw(stage, context);
    end
end
PineScriptUtils = {};
PineScriptUtils.Sources = {};
function PineScriptUtils:CreateSource(source, sourceType)
    if sourceType ~= "ohlc4" then
        return source[sourceType];
    end
    local newSource = {};
    newSource.Stream = instance:addInternalStream(0, 0);
    function newSource:Update(period, mode)
        self.Stream[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
    end
    self.Sources[#self.Sources + 1] = newSource;
    return newSource.Stream;
end
function PineScriptUtils:UpdateSources(period, mode)
    for i, src in ipairs(self.Sources) do
        src:Update(period, mode);
    end
end
function PineScriptUtils:TimeframeFromLength(length)
    if length == "t" then
        return "t1"
    elseif length == "D" then
        return "D1";
    elseif length == "W" then
        return "W1";
    elseif length == "M" then
        return "M1";
    end
    local length_number = tonumber(length);
    if length_number < 3600 then
        return "m" .. tostring(length_number / 60);
    end
    return "H" .. tostring(length_number / 3600)
end
function PineScriptUtils:ParseSession(session)
    local session_info = {};
    local _, _, from_hour, from_minute, to_hour, to_minute = string.find(session, "(%d%d)(%d%d)-(%d%d)(%d%d)");
    session_info.from_hour = from_hour and tonumber(from_hour) or 0;
    session_info.from_minute = from_minute and tonumber(from_minute) or 0;
    session_info.from = (session_info.from_hour * 60.0 + session_info.from_minute) * 60.0;
    session_info.to_hour = to_hour and tonumber(to_hour) or 23;
    session_info.to_minute = to_minute and tonumber(to_minute) or 59;
    session_info.to = (session_info.to_hour * 60.0 + session_info.to_minute) * 60.0;
    function session_info:IsInRange(time)
        time = math.floor(time * 86400 + 0.5);
        if self.from < self.to then
            return time >= self.from and time <= self.to;
        end
        if self.from > self.to then
            return time > self.from or time < self.to;
        end
    
        return time == self.from;
    end
    return session_info;
end
function PineScriptUtils:Time(period, timeframe_length, session, timezone)
    local timeframe = PineScriptUtils:TimeframeFromLength(timeframe_length);
    if PineScriptUtils.tradingWeekOffset == nil then
        PineScriptUtils.tradingWeekOffset = core.host:execute("getTradingWeekOffset");
        PineScriptUtils.tradingDayOffset = core.host:execute("getTradingDayOffset");
    end
    local s, e = core.getcandle(timeframe, instance.source:date(period), PineScriptUtils.tradingDayOffset, PineScriptUtils.tradingWeekOffset);
    local session_info = PineScriptUtils:ParseSession(session);
    if not session_info:IsInRange(s % 1) then
        return nil;
    end
    
    return s * 86400000;
end
function PineScriptUtils:WeekOfYear(time, timezone)
    local time_ole = time / 86400000;
    local date_table = core.dateToTable(time_ole)
    date_table.month = 1;
    date_table.day = 1;
    date_table.hour = 0;
    date_table.min = 0;
    date_table.sec = 0;
    local first_day_ole = core.tableToDate(date_table);
    date_table = core.dateToTable(first_day_ole);
    first_day_ole = first_day_ole - date_table.wday + 1;
    return math.floor(time_ole - first_day_ole / 7);
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

function GetTrueRange(source, period)
    if period == 0 then
        return nil;
    end
    local num1 = math.abs(source.high[period] - source.low[period]);
    local num2 = math.abs(source.high[period] - source.close[period - 1]);
    local num3 = math.abs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
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
signaler.lastIndexSerial = {};

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
function signaler:getSource(source)
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
    return source;
end
function signaler:SignalEx(index, message, period, source)
    source = self:getSource(source);
    if index ~= nil then
        if (self.lastIndexSerial[index] == source:serial(period)) then
            return;
        end
        self.lastIndexSerial[index] = source:serial(period);
    end
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(source);
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75879

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 