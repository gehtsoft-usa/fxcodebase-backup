local vars = {};
function Init()
    indicator:name("MACD Short/Long Strategy for TradingView Input Optimizer");
    indicator:description("MACD Short/Long Strategy for TradingView Input Optimizer");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addBoolean("param1", "Allow Long", "", true);
    indicator.parameters:addInteger("param2", "Fast Length Long", "", 13);
    indicator.parameters:addInteger("param3", "Slow Length Long", "", 19);
    indicator.parameters:addString("param4", "Source Long", "", "close");
    indicator.parameters:addStringAlternative("param4", "Open", "", "open");
    indicator.parameters:addStringAlternative("param4", "High", "", "high");
    indicator.parameters:addStringAlternative("param4", "Low", "", "low");
    indicator.parameters:addStringAlternative("param4", "Close", "", "close");
    indicator.parameters:addStringAlternative("param4", "Median", "", "median");
    indicator.parameters:addStringAlternative("param4", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param4", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param4", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param4", "HLCC4", "", "hlcc4");
    indicator.parameters:addInteger("param5", "Signal Smoothing Long", "", 9, 1, 50);
    indicator.parameters:addString("param6", "Oscillator MA Type Long", "", "EMA");
    indicator.parameters:addStringAlternative("param6", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param6", "EMA", "", "EMA");
    indicator.parameters:addString("param7", "Signal Line MA Type Long", "", "EMA");
    indicator.parameters:addStringAlternative("param7", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param7", "EMA", "", "EMA");
    indicator.parameters:addInteger("param8", "Cross Point Long", "", 0);
    indicator.parameters:addInteger("param9", "MacD Cross Delay Long", "", 0);
    indicator.parameters:addBoolean("param10", "Signal Must Also Cross Long", "", false);
    indicator.parameters:addInteger("param11", "Signal Cross Delay Long", "", 0);
    indicator.parameters:addBoolean("param12", "Allow Short", "", true);
    indicator.parameters:addInteger("param13", "Fast Length Short", "", 11);
    indicator.parameters:addInteger("param14", "Slow Length Short", "", 20);
    indicator.parameters:addString("param15", "Source Short", "", "close");
    indicator.parameters:addStringAlternative("param15", "Open", "", "open");
    indicator.parameters:addStringAlternative("param15", "High", "", "high");
    indicator.parameters:addStringAlternative("param15", "Low", "", "low");
    indicator.parameters:addStringAlternative("param15", "Close", "", "close");
    indicator.parameters:addStringAlternative("param15", "Median", "", "median");
    indicator.parameters:addStringAlternative("param15", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param15", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param15", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param15", "HLCC4", "", "hlcc4");
    indicator.parameters:addInteger("param16", "Signal Smoothing Short", "", 9, 1, 50);
    indicator.parameters:addString("param17", "Oscillator MA Type Short", "", "EMA");
    indicator.parameters:addStringAlternative("param17", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param17", "EMA", "", "EMA");
    indicator.parameters:addString("param18", "Signal Line MA Type Short", "", "EMA");
    indicator.parameters:addStringAlternative("param18", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param18", "EMA", "", "EMA");
    indicator.parameters:addInteger("param19", "Cross Point Short", "", 0);
    indicator.parameters:addDouble("param20", "MacD Cross Delay Short", "", 1);
    indicator.parameters:addBoolean("param21", "Signal Must Also Cross Short", "", false);
    indicator.parameters:addInteger("param22", "Signal Cross Delay Short", "", 0);
    indicator.parameters:addBoolean("param23", "Use Stop Loss Long", "", false);
    indicator.parameters:addDouble("param24", "Stop Loss % Long", "", 1, 0.0);
    indicator.parameters:addBoolean("param25", "Use Take Profit Long", "", false);
    indicator.parameters:addDouble("param26", "Take Profit % Long", "", 1, 0.0);
    indicator.parameters:addBoolean("param27", "Use Stop Loss Short", "", true);
    indicator.parameters:addDouble("param28", "Stop Loss % Short", "", 21, 0.0);
    indicator.parameters:addBoolean("param29", "Use Take Profit Short", "", true);
    indicator.parameters:addDouble("param30", "Take Profit % Short", "", 20, 0.0);
    indicator.parameters:addColor("param31", "MACD Line Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(41, 98, 255), 0)));
    indicator.parameters:addColor("param32", "Signal Line Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 109, 0), 0)));
    indicator.parameters:addColor("param33", "Grow Above Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(38, 166, 154), 0)));
    indicator.parameters:addColor("param34", "Fall Above Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(178, 223, 219), 0)));
    indicator.parameters:addColor("param35", "Grow Below Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 205, 210), 0)));
    indicator.parameters:addColor("param36", "Fall Below Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 82, 82), 0)));
    indicator.parameters:addColor("param37", "MACD Line Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(176, 61, 255), 0)));
    indicator.parameters:addColor("param38", "Signal Line Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 255, 232), 0)));
    indicator.parameters:addColor("param39", "Grow Above Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(217, 89, 101), 0)));
    indicator.parameters:addColor("param40", "Fall Above Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(77, 32, 36), 0)));
    indicator.parameters:addColor("param41", "Grow Below Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 50, 45), 0)));
    indicator.parameters:addColor("param42", "Fall Below Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 173, 173), 0)));
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local signal1;
local signal2;
local signal3;
local signal4;
local signal5;
local signal6;
local signal7;
local signal8;
local signal9;
local signal10;
--level
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["allow_long"] = instance.parameters.param1;
    vars["fast_length_long"] = instance.parameters.param2;
    vars["slow_length_long"] = instance.parameters.param3;
    vars["src_long"] = PineScriptUtils:CreateSource(source, instance.parameters.param4);
    vars["signal_length_long"] = instance.parameters.param5;
    vars["sma_source_long"] = instance.parameters.param6;
    vars["sma_signal_long"] = instance.parameters.param7;
    vars["cross_point_long"] = instance.parameters.param8;
    vars["cross_delay_macd_long"] = instance.parameters.param9;
    vars["signal_must_cross_long"] = instance.parameters.param10;
    vars["cross_delay_signal_long"] = instance.parameters.param11;
    vars["allow_short"] = instance.parameters.param12;
    vars["fast_length_short"] = instance.parameters.param13;
    vars["slow_length_short"] = instance.parameters.param14;
    vars["src_short"] = PineScriptUtils:CreateSource(source, instance.parameters.param15);
    vars["signal_length_short"] = instance.parameters.param16;
    vars["sma_source_short"] = instance.parameters.param17;
    vars["sma_signal_short"] = instance.parameters.param18;
    vars["cross_point_short"] = instance.parameters.param19;
    vars["cross_delay_macd_short"] = instance.parameters.param20;
    vars["signal_must_cross_short"] = instance.parameters.param21;
    vars["cross_delay_signal_short"] = instance.parameters.param22;
    vars["use_stop_loss_long"] = instance.parameters.param23;
    vars["use_take_profit_long"] = instance.parameters.param25;
    vars["use_stop_loss_short"] = instance.parameters.param27;
    vars["use_take_profit_short"] = instance.parameters.param29;
    vars["col_macd_long"] = Graphics:AddTransparency(instance.parameters.param31, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(41, 98, 255), 0)));
    vars["col_signal_long"] = Graphics:AddTransparency(instance.parameters.param32, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 109, 0), 0)));
    vars["col_grow_above_long"] = Graphics:AddTransparency(instance.parameters.param33, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(38, 166, 154), 0)));
    vars["col_fall_above_long"] = Graphics:AddTransparency(instance.parameters.param34, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(178, 223, 219), 0)));
    vars["col_grow_below_long"] = Graphics:AddTransparency(instance.parameters.param35, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 205, 210), 0)));
    vars["col_fall_below_long"] = Graphics:AddTransparency(instance.parameters.param36, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 82, 82), 0)));
    vars["col_macd_short"] = Graphics:AddTransparency(instance.parameters.param37, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(176, 61, 255), 0)));
    vars["col_signal_short"] = Graphics:AddTransparency(instance.parameters.param38, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 255, 232), 0)));
    vars["col_grow_above_short"] = Graphics:AddTransparency(instance.parameters.param39, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(217, 89, 101), 0)));
    vars["col_fall_above_short"] = Graphics:AddTransparency(instance.parameters.param40, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(77, 32, 36), 0)));
    vars["col_grow_below_short"] = Graphics:AddTransparency(instance.parameters.param41, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 50, 45), 0)));
    vars["col_fall_below_short"] = Graphics:AddTransparency(instance.parameters.param42, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 173, 173), 0)));
    vars["MVA1"] = core.indicators:create("MVA", vars["src_long"], vars["fast_length_long"]);
    vars["EMA1"] = core.indicators:create("EMA", vars["src_long"], vars["fast_length_long"]);
    vars["MVA2"] = core.indicators:create("MVA", vars["src_long"], vars["slow_length_long"]);
    vars["EMA2"] = core.indicators:create("EMA", vars["src_long"], vars["slow_length_long"]);
    vars["MVA3_source"] = instance:addInternalStream(0, 0);
    vars["MVA3"] = core.indicators:create("MVA", vars["MVA3_source"], vars["signal_length_long"]);
    vars["EMA3_source"] = instance:addInternalStream(0, 0);
    vars["EMA3"] = core.indicators:create("EMA", vars["EMA3_source"], vars["signal_length_long"]);
    vars["MVA4"] = core.indicators:create("MVA", vars["src_short"], vars["fast_length_short"]);
    vars["EMA4"] = core.indicators:create("EMA", vars["src_short"], vars["fast_length_short"]);
    vars["MVA5"] = core.indicators:create("MVA", vars["src_short"], vars["slow_length_short"]);
    vars["EMA5"] = core.indicators:create("EMA", vars["src_short"], vars["slow_length_short"]);
    vars["MVA6_source"] = instance:addInternalStream(0, 0);
    vars["MVA6"] = core.indicators:create("MVA", vars["MVA6_source"], vars["signal_length_short"]);
    vars["EMA6_source"] = instance:addInternalStream(0, 0);
    vars["EMA6"] = core.indicators:create("EMA", vars["EMA6_source"], vars["signal_length_short"]);
    vars["!hist_long_stream"] = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Bar, "Histogram Long", "Histogram Long", core.colors().Blue, 0, 0);
    plot1:setWidth(1);
    plot2 = instance:addStream("plot2", core.Line, "MACD Long", "MACD Long", vars["col_macd_long"], 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    plot3 = instance:addStream("plot3", core.Line, "Signal Long", "Signal Long", vars["col_signal_long"], 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    vars["!hist_short_stream"] = instance:addInternalStream(0, 0);
    plot4 = instance:addStream("plot4", core.Bar, "Histogram Short", "Histogram Short", core.colors().Blue, 0, 0);
    plot4:setWidth(1);
    plot5 = instance:addStream("plot5", core.Line, "MACD Short", "MACD Short", vars["col_macd_short"], 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    plot6 = instance:addStream("plot6", core.Line, "Signal Short", "Signal Short", vars["col_signal_short"], 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_SOLID);
    vars["detectedLongCrossOver"] = instance:addInternalStream(0, 0);
    vars["detectedShortCrossUnder"] = instance:addInternalStream(0, 0);
    vars["cross_1_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_1_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_2_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_2_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_3_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_3_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_4_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_4_y_src"] = instance:addInternalStream(0, 0);
    vars["crossover_signal_long"] = instance:addInternalStream(0, 0);
    vars["cross_5_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_5_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_6_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_6_y_src"] = instance:addInternalStream(0, 0);
    vars["crossunder_signal_short"] = instance:addInternalStream(0, 0);
    vars["cross_7_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_7_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_8_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_8_y_src"] = instance:addInternalStream(0, 0);
    vars["crossover_macd_long"] = instance:addInternalStream(0, 0);
    vars["cross_9_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_9_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_10_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_10_y_src"] = instance:addInternalStream(0, 0);
    vars["crossunder_macd_short"] = instance:addInternalStream(0, 0);
    vars["cross_11_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_11_y_src"] = instance:addInternalStream(0, 0);
    vars["cross_12_x_src"] = instance:addInternalStream(0, 0);
    vars["cross_12_y_src"] = instance:addInternalStream(0, 0);
    signal1 = PineStrategy:CreateEntrySignalV5("long");
    signal2 = PineStrategy:CreateEntrySignalV5("long");
    signal3 = PineStrategy:CreateEntrySignalV5("short");
    signal4 = PineStrategy:CreateEntrySignalV5("short");
    signal5 = PineStrategy:CreateCloseSignalV4("long");
    signal6 = PineStrategy:CreateCloseSignalV4("long");
    signal7 = PineStrategy:CreateCloseSignalV4("short");
    signal8 = PineStrategy:CreateCloseSignalV4("short");
    signal9 = PineStrategy:CreateExitSignalV4("TP/SL Long");
    signal10 = PineStrategy:CreateExitSignalV4("TP/SL Short");
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetBool(vars["detectedLongCrossOver"], period, false);
        SafeSetBool(vars["detectedShortCrossUnder"], period, false);
    else
        SafeSetBool(vars["detectedLongCrossOver"], period, SafeGetBool(vars["detectedLongCrossOver"], period - 1));
        SafeSetBool(vars["detectedShortCrossUnder"], period, SafeGetBool(vars["detectedShortCrossUnder"], period - 1));
    end
    PineScriptUtils:UpdateSources(period, mode);
    vars["stop_loss_long_percentage"] = instance.parameters.param24 * .01;
    vars["take_profit_long_percentage"] = instance.parameters.param26 * .01;
    vars["stop_loss_short_percentage"] = instance.parameters.param28 * .01;
    vars["take_profit_short_percentage"] = instance.parameters.param30 * .01;
    vars["MVA1"]:update(mode);
    vars["EMA1"]:update(mode);
    vars["fast_ma_long"] = Triary((vars["sma_source_long"] == "SMA"), vars["MVA1"].DATA:tick(period), vars["EMA1"].DATA:tick(period));
    vars["MVA2"]:update(mode);
    vars["EMA2"]:update(mode);
    vars["slow_ma_long"] = Triary((vars["sma_source_long"] == "SMA"), vars["MVA2"].DATA:tick(period), vars["EMA2"].DATA:tick(period));
    vars["macd_long"] = SafeMinus(vars["fast_ma_long"], vars["slow_ma_long"]);
    SafeSetFloat(vars["MVA3_source"], period, vars["macd_long"]);
    vars["MVA3"]:update(mode);
    SafeSetFloat(vars["EMA3_source"], period, vars["macd_long"]);
    vars["EMA3"]:update(mode);
    vars["signal_long"] = Triary((vars["sma_signal_long"] == "SMA"), vars["MVA3"].DATA:tick(period), vars["EMA3"].DATA:tick(period));
    vars["hist_long"] = SafeMinus(vars["macd_long"], vars["signal_long"]);
    vars["MVA4"]:update(mode);
    vars["EMA4"]:update(mode);
    vars["fast_ma_short"] = Triary((vars["sma_source_short"] == "SMA"), vars["MVA4"].DATA:tick(period), vars["EMA4"].DATA:tick(period));
    vars["MVA5"]:update(mode);
    vars["EMA5"]:update(mode);
    vars["slow_ma_short"] = Triary((vars["sma_source_short"] == "SMA"), vars["MVA5"].DATA:tick(period), vars["EMA5"].DATA:tick(period));
    vars["macd_short"] = SafeMinus(vars["fast_ma_short"], vars["slow_ma_short"]);
    SafeSetFloat(vars["MVA6_source"], period, vars["macd_short"]);
    vars["MVA6"]:update(mode);
    SafeSetFloat(vars["EMA6_source"], period, vars["macd_short"]);
    vars["EMA6"]:update(mode);
    vars["signal_short"] = Triary((vars["sma_signal_short"] == "SMA"), vars["MVA6"].DATA:tick(period), vars["EMA6"].DATA:tick(period));
    vars["hist_short"] = SafeMinus(vars["macd_short"], vars["signal_short"]);
    SafeSetFloat(vars["!hist_long_stream"], period, vars["hist_long"]);
    vars["!hist_long_stream_index"] = 1;
    vars["!hist_long_stream_index"] = 1;
    plot1[period] = vars["hist_long"];
    plot1:setColor(period, Graphics:GetColor((Triary(SafeGE(vars["hist_long"], 0), (Triary(SafeLess(SafeGetFloat(vars["!hist_long_stream"], vars["!hist_long_stream_index"]), vars["hist_long"]), vars["col_grow_above_long"], vars["col_fall_above_long"])), (Triary(SafeLess(SafeGetFloat(vars["!hist_long_stream"], vars["!hist_long_stream_index"]), vars["hist_long"]), vars["col_grow_below_long"], vars["col_fall_below_long"]))))));
    plot2[period] = vars["macd_long"];
    plot3[period] = vars["signal_long"];
    SafeSetFloat(vars["!hist_short_stream"], period, vars["hist_short"]);
    vars["!hist_short_stream_index"] = 1;
    vars["!hist_short_stream_index"] = 1;
    plot4[period] = vars["hist_short"];
    plot4:setColor(period, Graphics:GetColor((Triary(SafeGE(vars["hist_short"], 0), (Triary(SafeLess(SafeGetFloat(vars["!hist_short_stream"], vars["!hist_short_stream_index"]), vars["hist_short"]), vars["col_grow_above_short"], vars["col_fall_above_short"])), (Triary(SafeLess(SafeGetFloat(vars["!hist_short_stream"], vars["!hist_short_stream_index"]), vars["hist_short"]), vars["col_grow_below_short"], vars["col_fall_below_short"]))))));
    plot5[period] = vars["macd_short"];
    plot6[period] = vars["signal_short"];
    SafeSetFloat(vars["cross_1_x_src"], period, vars["macd_short"]);
    SafeSetFloat(vars["cross_1_y_src"], period, vars["cross_point_short"]);
    if (SafeCrossesUnder(vars["cross_1_x_src"], vars["cross_1_y_src"], period)) then
        SafeSetBool(vars["detectedShortCrossUnder"], period, true);
    end
    SafeSetFloat(vars["cross_2_x_src"], period, vars["macd_short"]);
    SafeSetFloat(vars["cross_2_y_src"], period, vars["cross_point_short"]);
    if (SafeCrossesOver(vars["cross_2_x_src"], vars["cross_2_y_src"], period)) then
        SafeSetBool(vars["detectedShortCrossUnder"], period, false);
    end
    SafeSetFloat(vars["cross_3_x_src"], period, vars["macd_long"]);
    SafeSetFloat(vars["cross_3_y_src"], period, vars["cross_point_long"]);
    if (SafeCrossesOver(vars["cross_3_x_src"], vars["cross_3_y_src"], period)) then
        SafeSetBool(vars["detectedLongCrossOver"], period, true);
    end
    SafeSetFloat(vars["cross_4_x_src"], period, vars["macd_long"]);
    SafeSetFloat(vars["cross_4_y_src"], period, vars["cross_point_long"]);
    if (SafeCrossesUnder(vars["cross_4_x_src"], vars["cross_4_y_src"], period)) then
        SafeSetBool(vars["detectedLongCrossOver"], period, false);
    end
    SafeSetFloat(vars["cross_5_x_src"], period, vars["signal_long"]);
    SafeSetFloat(vars["cross_5_y_src"], period, vars["cross_point_long"]);
    SafeSetBool(vars["crossover_signal_long"], period, SafeCrossesOver(vars["cross_5_x_src"], vars["cross_5_y_src"], period));
    SafeSetFloat(vars["cross_6_x_src"], period, vars["signal_long"]);
    SafeSetFloat(vars["cross_6_y_src"], period, vars["cross_point_long"]);
    vars["crossunder_signal_long"] = SafeCrossesUnder(vars["cross_6_x_src"], vars["cross_6_y_src"], period);
    SafeSetFloat(vars["cross_7_x_src"], period, vars["signal_short"]);
    SafeSetFloat(vars["cross_7_y_src"], period, vars["cross_point_short"]);
    SafeSetBool(vars["crossunder_signal_short"], period, SafeCrossesUnder(vars["cross_7_x_src"], vars["cross_7_y_src"], period));
    SafeSetFloat(vars["cross_8_x_src"], period, vars["signal_short"]);
    SafeSetFloat(vars["cross_8_y_src"], period, vars["cross_point_short"]);
    vars["crossover_signal_short"] = SafeCrossesOver(vars["cross_8_x_src"], vars["cross_8_y_src"], period);
    SafeSetFloat(vars["cross_9_x_src"], period, vars["macd_long"]);
    SafeSetFloat(vars["cross_9_y_src"], period, vars["cross_point_long"]);
    SafeSetBool(vars["crossover_macd_long"], period, SafeCrossesOver(vars["cross_9_x_src"], vars["cross_9_y_src"], period));
    SafeSetFloat(vars["cross_10_x_src"], period, vars["macd_long"]);
    SafeSetFloat(vars["cross_10_y_src"], period, vars["cross_point_long"]);
    vars["crossunder_macd_long"] = SafeCrossesUnder(vars["cross_10_x_src"], vars["cross_10_y_src"], period);
    SafeSetFloat(vars["cross_11_x_src"], period, vars["macd_short"]);
    SafeSetFloat(vars["cross_11_y_src"], period, vars["cross_point_short"]);
    SafeSetBool(vars["crossunder_macd_short"], period, SafeCrossesUnder(vars["cross_11_x_src"], vars["cross_11_y_src"], period));
    SafeSetFloat(vars["cross_12_x_src"], period, vars["macd_short"]);
    SafeSetFloat(vars["cross_12_y_src"], period, vars["cross_point_short"]);
    vars["crossover_macd_short"] = SafeCrossesOver(vars["cross_12_x_src"], vars["cross_12_y_src"], period);
    vars["inEntry"] = false;
    if ((PineStrategy:Equity() > 0)) then
        if ((PineStrategy:PositionSize(source:instrument()) <= 0) and (vars["allow_long"] == true) and (vars["inEntry"] == false)) then
            if ((vars["signal_must_cross_long"] == true)) then
                vars["longSignalCondition"] = (SafeGetBool(vars["detectedLongCrossOver"], period) == true) and SafeGetBool(vars["crossover_signal_long"], period - vars["cross_delay_signal_long"]);
                signal1:Execute(period, "long", true, nil, nil, nil, "", "oca.none", nil, vars["longSignalCondition"], nil);
                if (vars["longSignalCondition"]) then
                    vars["inEntry"] = true;
                end
            else
                vars["longMacDCondition"] = SafeGetBool(vars["crossover_macd_long"], period - vars["cross_delay_macd_long"]);
                signal2:Execute(period, "long", true, nil, nil, nil, "", "oca.none", nil, vars["longMacDCondition"], nil);
                if (vars["longMacDCondition"]) then
                    vars["inEntry"] = true;
                end
            end
        end
        if ((PineStrategy:PositionSize(source:instrument()) >= 0) and (vars["allow_short"] == true) and (vars["inEntry"] == false)) then
            if ((vars["signal_must_cross_short"] == true)) then
                vars["shortSignalCondition"] = SafeGetBool(vars["detectedShortCrossUnder"], period) and SafeGetBool(vars["crossunder_signal_short"], period - vars["cross_delay_signal_short"]);
                signal3:Execute(period, "short", false, nil, nil, nil, "", "oca.none", nil, vars["shortSignalCondition"], nil);
                if (vars["shortSignalCondition"]) then
                    vars["inEntry"] = true;
                end
            else
                vars["shortMacDCondition"] = SafeGetBool(vars["crossunder_macd_short"], period - vars["cross_delay_macd_short"]);
                signal4:Execute(period, "short", false, nil, nil, nil, "", "oca.none", nil, vars["shortMacDCondition"], nil);
                if (vars["shortMacDCondition"]) then
                    vars["inEntry"] = true;
                end
            end
        end
        if ((PineStrategy:PositionSize(source:instrument()) > 0) and (vars["allow_long"] == true) and (vars["allow_short"] == false)) then
            if ((vars["signal_must_cross_long"] == true)) then
                signal5:Execute(period, "long", (SafeGetBool(vars["detectedLongCrossOver"], period) == false) and vars["crossunder_signal_long"], nil, 100.0, nil, nil);
            else
                signal6:Execute(period, "long", vars["crossunder_macd_long"], nil, 100.0, nil, nil);
            end
        end
        if ((PineStrategy:PositionSize(source:instrument()) < 0) and (vars["allow_short"] == true) and (vars["allow_long"] == false)) then
            if ((vars["signal_must_cross_short"] == true)) then
                signal7:Execute(period, "short", (SafeGetBool(vars["detectedShortCrossUnder"], period) == false) and vars["crossover_signal_short"], nil, 100.0, nil, nil);
            else
                signal8:Execute(period, "short", vars["crossover_macd_short"], nil, 100.0, nil, nil);
            end
        end
    end
    vars["stop_loss_value_long"] = PineStrategy:PositionAvgPrice(source:instrument()) * (1 - vars["stop_loss_long_percentage"]);
    vars["take_profit_value_long"] = PineStrategy:PositionAvgPrice(source:instrument()) * (1 + vars["take_profit_long_percentage"]);
    vars["stop_loss_value_short"] = PineStrategy:PositionAvgPrice(source:instrument()) * (1 + vars["stop_loss_short_percentage"]);
    vars["take_profit_value_short"] = PineStrategy:PositionAvgPrice(source:instrument()) * (1 - vars["take_profit_short_percentage"]);
    if ((PineStrategy:PositionSize(source:instrument()) > 0)) then
        signal9:Execute(period, "TP/SL Long", "long", nil, 100.0, nil, Triary(vars["use_take_profit_long"], vars["take_profit_value_long"], nil), nil, Triary(vars["use_stop_loss_long"], vars["stop_loss_value_long"], nil), nil, nil, nil, nil, nil, true, nil);
    end
    if ((PineStrategy:PositionSize(source:instrument()) < 0)) then
        signal10:Execute(period, "TP/SL Short", "short", nil, 100.0, nil, Triary(vars["use_take_profit_short"], vars["take_profit_value_short"], nil), nil, Triary(vars["use_stop_loss_short"], vars["stop_loss_value_short"], nil), nil, nil, nil, nil, nil, true, nil);
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
    if transparency == nil then
        return nil;
    end
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil or transp == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
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
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or period == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil or period == nil then
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
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
function SafeMathExMax(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.max(source, core.rangeTo(period, length));
end
function SafeMathExMin(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.min(source, core.rangeTo(period, length));
end
function SafeMathExStdev(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.stdev(source, core.rangeTo(period, length));
end
PineStrategy = {};
PineStrategy.streams = {};
function PineStrategy:CreateEntrySignalV4(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateEntrySignalV5(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV4(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, when, qty, qty_percent, comment, alert_message)
        if when then
            self.stream[period] = 1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV5(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
        if immediately then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV4(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, when, alert_message)
        if when then
            self.stream_sl[period] = limit;
            self.stream_tp[period] = stop;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV5(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, 
            comment_profit, comment_loss, comment_trailing, alert_message, alert_profit, alert_loss, alert_trailing, disable_alert)
        self.stream_sl[period] = limit;
        self.stream_tp[period] = stop;
    end
    return signal;
end
function PineStrategy:EntryV4(id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:EntryV5(id, direction, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV4(id, when, qty, qty_percent, comment, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV5(id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
    if disable_alert == true then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:Equity(account)
    local accounts = core.host:findTable("accounts");
    if account == nil then
        local enum = accounts:enumerator();
        local row = enum:next();
        while row ~= nil do
            return row.Equity;
        end
        return 0;
    end
    return accounts:find("AccountID", account).Equity;
end
function PineStrategy:PositionSize(symbol)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    local total = 0;
    while row ~= nil do
        if row.Instrument == symbol then
            if row.BS == "B" then
                total = total + row.Lot;
            else
                total = total - row.Lot;
            end
        end
        row = enum:next();
    end
    return total;
end
function PineStrategy:PositionAvgPrice(symbol)
    return 0;
end
