-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75325 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

local vars = {};
function Init()
    indicator:name("Three Bar Reversal Pattern [LuxAlgo]");
    indicator:description("Three Bar Reversal Pattern [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("param1", "Pattern Type", "", "All");
    indicator.parameters:addStringAlternative("param1", "Normal", "", "Normal");
    indicator.parameters:addStringAlternative("param1", "Enhanced", "", "Enhanced");
    indicator.parameters:addStringAlternative("param1", "All", "", "All");
    indicator.parameters:addString("param2", "Derived Support and Resistance", "", "Level");
    indicator.parameters:addStringAlternative("param2", "Level", "", "Level");
    indicator.parameters:addStringAlternative("param2", "Zone", "", "Zone");
    indicator.parameters:addStringAlternative("param2", "None", "", "None");
    indicator.parameters:addColor("param3", "Bullish Reversal Patterns", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(41, 98, 255), 0)));
    indicator.parameters:addColor("param4", "Bearish Reversal Patterns", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 152, 0), 0)));
    indicator.parameters:addString("param5", "Filtering", "", "None");
    indicator.parameters:addStringAlternative("param5", "Moving Average Cloud", "", "Moving Average Cloud");
    indicator.parameters:addStringAlternative("param5", "Supertrend", "", "Supertrend");
    indicator.parameters:addStringAlternative("param5", "Donchian Channels", "", "Donchian Channels");
    indicator.parameters:addStringAlternative("param5", "None", "", "None");
    indicator.parameters:addString("param6", "", "", "Aligned");
    indicator.parameters:addStringAlternative("param6", "Aligned", "", "Aligned");
    indicator.parameters:addStringAlternative("param6", "Opposite", "", "Opposite");
    indicator.parameters:addColor("param7", "Bullish Trend", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(8, 153, 129), 0)));
    indicator.parameters:addColor("param8", "?Bearish Trend", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(242, 54, 69), 0)));
    indicator.parameters:addString("param9", "Type", "", "HMA");
    indicator.parameters:addStringAlternative("param9", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param9", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("param9", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("param9", "RMA", "", "RMA");
    indicator.parameters:addStringAlternative("param9", "WMA", "", "WMA");
    indicator.parameters:addStringAlternative("param9", "VWMA", "", "VWMA");
    indicator.parameters:addInteger("param10", "Fast Length", "", 50, 1, 100);
    indicator.parameters:addInteger("param11", "Slow Length", "", 200, 100);
    indicator.parameters:addInteger("param12", "ATR Length", "", 10, 1);
    indicator.parameters:addDouble("param13", "Factor", "", 3, 2);
    indicator.parameters:addInteger("param14", "Length", "", 13, 1);
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
function Create_movingAverage_sf_i_s(__source, length, maType)
    local local_vars = {};
    local_vars["MVA1"] = core.indicators:create("MVA", source, length);
    local_vars["EMA1"] = core.indicators:create("EMA", source, length);
            assert(core.indicators:findIndicator("PINESCRIPT HMA") ~= nil, "Please, download and install PINESCRIPT HMA.lua indicator");
    local_vars["PINESCRIPT HMA1"] = core.indicators:create("PINESCRIPT HMA", source, length);
    local_vars["SMMA1"] = core.indicators:create("SMMA", source, length);
    local_vars["WMA1"] = core.indicators:create("WMA", source, length);
           assert(core.indicators:findIndicator("VOLUME-WEIGHTED MOVING AVERAGE") ~= nil, "Please, download and install VOLUME-WEIGHTED MOVING AVERAGE.lua indicator");	
    local_vars["VOLUME WEIGHTED MOVING AVERAGE1"] = core.indicators:create("VOLUME-WEIGHTED MOVING AVERAGE", source, length);
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["MVA1"]:update(mode);
            local_vars["EMA1"]:update(mode);
            local_vars["PINESCRIPT HMA1"]:update(mode);
            local_vars["SMMA1"]:update(mode);
            local_vars["WMA1"]:update(mode);
            local_vars["VOLUME WEIGHTED MOVING AVERAGE1"]:update(mode);
            return Triary((maType.Value == "SMA"), local_vars["MVA1"].DATA:tick(period), Triary((maType.Value == "EMA"), local_vars["EMA1"].DATA:tick(period), Triary((maType.Value == "HMA"), local_vars["PINESCRIPT HMA1"].DATA:tick(period), Triary((maType.Value == "RMA"), local_vars["SMMA1"].DATA:tick(period), Triary((maType.Value == "WMA"), local_vars["WMA1"].DATA:tick(period), Triary((maType.Value == "VWMA"), local_vars["VOLUME WEIGHTED MOVING AVERAGE1"].DATA:tick(period), nil))))));
        end
    };
end
function Create_isBullishReversal()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return (SafeLess(source.close:tick(period - 2), source.open:tick(period - 2))) and (SafeLess(source.low:tick(period - 1), source.low:tick(period - 2))) and (SafeLess(source.high:tick(period - 1), source.high:tick(period - 2))) and (SafeLess(source.close:tick(period - 1), source.open:tick(period - 1))) and ((source.close:tick(period) > source.open:tick(period))) and (SafeGreater(source.high:tick(period), source.high:tick(period - 2)));
        end
    };
end
function Create_isBearishReversal()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return (SafeGreater(source.close:tick(period - 2), source.open:tick(period - 2))) and (SafeGreater(source.high:tick(period - 1), source.high:tick(period - 2))) and (SafeGreater(source.low:tick(period - 1), source.low:tick(period - 2))) and (SafeGreater(source.close:tick(period - 1), source.open:tick(period - 1))) and ((source.close:tick(period) < source.open:tick(period))) and (SafeLess(source.low:tick(period), source.low:tick(period - 2)));
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
    vars["display"] = Display.All - Display.StatusLine;
    vars["brpType"] = instance.parameters.param1;
    vars["brpSR"] = instance.parameters.param2;
    vars["brpAC"] = Graphics:AddTransparency(instance.parameters.param3, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(41, 98, 255), 0)));
    vars["brpSC"] = Graphics:AddTransparency(instance.parameters.param4, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 152, 0), 0)));
    vars["trendIndiGroup"] = "Trend Filtering";
    vars["trendType"] = instance.parameters.param5;
    vars["trendFilt"] = instance.parameters.param6;
    vars["trendAC"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(8, 153, 129), 0)));
    vars["trendSC"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(242, 54, 69), 0)));
    vars["ma_Group"] = "Moving Average Settings";
    vars["maType"] = instance.parameters.param9;
    vars["maFLength"] = instance.parameters.param10;
    vars["maSLength"] = instance.parameters.param11;
    vars["st_Group"] = "Supertrend Settings";
    vars["atrPeriod"] = instance.parameters.param12;
    vars["factor"] = instance.parameters.param13;
    vars["dc_Group"] = "Donchian Channel Settings";
    vars["length"] = instance.parameters.param14;
    vars["movingAverageFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["movingAverageFunc1_param3"] = {};
    vars["movingAverageFunc1"] = Create_movingAverage_sf_i_s(vars["movingAverageFunc1_param1"], vars["maFLength"], vars["movingAverageFunc1_param3"]);
    vars["movingAverageFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["movingAverageFunc2_param3"] = {};
    vars["movingAverageFunc2"] = Create_movingAverage_sf_i_s(vars["movingAverageFunc2_param1"], vars["maSLength"], vars["movingAverageFunc2_param3"]);
    plot1 = instance:addStream("plot1", core.Line, "ma fast", "ma fast", vars["trendAC"] + math.floor(81 / 100 * 255) * 16777216, 0, 0);
    plot1:setWidth(1);
    vars["ma1"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "ma slow", "ma slow", vars["trendAC"] + math.floor(73 / 100 * 255) * 16777216, 0, 0);
    plot2:setWidth(1);
    vars["ma2"] = plot2;
    channel1_color = core.colors().Blue;
    instance:createChannelGroup("channel1", "channel1", vars["ma1"], vars["ma2"], Graphics:GetColor(channel1_color), 100 - Graphics:GetTransparencyPercent(channel1_color), true);
    assert(core.indicators:findIndicator("PINESCRIPT SUPERTREND") ~= nil, "Please, download and install PINESCRIPT SUPERTREND.lua indicator");
    vars["PINESCRIPT SUPERTREND1"] = core.indicators:create("PINESCRIPT SUPERTREND", source, vars["factor"], vars["atrPeriod"]);
    vars["__IsFirst1"] = CreateIsFirst();
    plot3 = instance:addStream("plot3", core.Line, "Up Trend", "Up Trend", vars["trendAC"] + math.floor(73 / 100 * 255) * 16777216, 0, 0);
    plot3:setWidth(1);
    vars["upTrend"] = plot3;
    plot4 = instance:addStream("plot4", core.Line, "Down Trend", "Down Trend", vars["trendSC"] + math.floor(73 / 100 * 255) * 16777216, 0, 0);
    plot4:setWidth(1);
    vars["downTrend"] = plot4;
    vars["__IsFirst2"] = CreateIsFirst();
    plot5 = instance:addStream("plot5", core.Line, "Body Middle", "Body Middle", core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_NONE);
    vars["bodyMiddle"] = plot5;
    channel2_color = core.colors().Blue;
    instance:createChannelGroup("channel2", "channel2", vars["bodyMiddle"], vars["upTrend"], Graphics:GetColor(channel2_color), 100 - Graphics:GetTransparencyPercent(channel2_color), true);
    channel3_color = core.colors().Blue;
    instance:createChannelGroup("channel3", "channel3", vars["bodyMiddle"], vars["downTrend"], Graphics:GetColor(channel3_color), 100 - Graphics:GetTransparencyPercent(channel3_color), true);
    vars["os"] = instance:addInternalStream(0, 0);
    vars["upper"] = instance:addInternalStream(0, 0);
    vars["lower"] = instance:addInternalStream(0, 0);
    plot6 = instance:addStream("plot6", core.Line, "", "", vars["trendAC"] + math.floor(99 / 100 * 255) * 16777216, 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_SOLID);
    vars["dcUpper"] = plot6;
    plot7 = instance:addStream("plot7", core.Line, "", "", vars["trendAC"] + math.floor(73 / 100 * 255) * 16777216, 0, 0);
    plot7:setWidth(1);
    plot7:setStyle(core.LINE_SOLID);
    vars["dcLower"] = plot7;
    channel4_color = core.colors().Blue;
    instance:createChannelGroup("channel4", "channel4", vars["dcUpper"], vars["dcLower"], Graphics:GetColor(channel4_color), 100 - Graphics:GetTransparencyPercent(channel4_color), true);
    vars["C_DownTrend"] = true;
    vars["C_UpTrend"] = true;
    vars["isBullishReversalFunc3"] = Create_isBullishReversal();
    vars["isBearishReversalFunc4"] = Create_isBearishReversal();
    vars["bullProcess"] = instance:addInternalStream(0, 0);
    vars["bullProcess2"] = instance:addInternalStream(0, 0);
    vars["bullHigh"] = instance:addInternalStream(0, 0);
    Label:Prepare(500);
    Line:Prepare(500);
    vars["bearProcess"] = instance:addInternalStream(0, 0);
    vars["bearProcess2"] = instance:addInternalStream(0, 0);
    vars["bearLow"] = instance:addInternalStream(0, 0);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Label:Clear();
        Line:Clear();
        Linefill:Clear();
        Box:Clear();
        vars["movingAverageFunc1"].Clear();
        vars["movingAverageFunc2"].Clear();
        vars["__IsFirst1"]:Clear();
        vars["__IsFirst2"]:Clear();
        SafeSetFloat(vars["os"], period, 0);
        vars["isBullishReversalFunc3"].Clear();
        vars["isBearishReversalFunc4"].Clear();
        vars["lnAT"] = nil;
        vars["lnAB"] = nil;
        vars["lnAT2"] = nil;
        vars["lnAB2"] = nil;
        vars["lbAT"] = nil;
        vars["bxA"] = nil;
        SafeSetBool(vars["bullProcess"], period, false);
        SafeSetBool(vars["bullProcess2"], period, false);
        SafeSetFloat(vars["bullHigh"], period, nil);
        vars["lnST"] = nil;
        vars["lnSB"] = nil;
        vars["lnST2"] = nil;
        vars["lnSB2"] = nil;
        vars["lbST"] = nil;
        vars["bxS"] = nil;
        SafeSetBool(vars["bearProcess"], period, false);
        SafeSetBool(vars["bearProcess2"], period, false);
        SafeSetFloat(vars["bearLow"], period, nil);
    else
        SafeSetFloat(vars["os"], period, SafeGetFloat(vars["os"], period - 1));
        SafeSetBool(vars["bullProcess"], period, SafeGetBool(vars["bullProcess"], period - 1));
        SafeSetBool(vars["bullProcess2"], period, SafeGetBool(vars["bullProcess2"], period - 1));
        SafeSetFloat(vars["bullHigh"], period, SafeGetFloat(vars["bullHigh"], period - 1));
        SafeSetBool(vars["bearProcess"], period, SafeGetBool(vars["bearProcess"], period - 1));
        SafeSetBool(vars["bearProcess2"], period, SafeGetBool(vars["bearProcess2"], period - 1));
        SafeSetFloat(vars["bearLow"], period, SafeGetFloat(vars["bearLow"], period - 1));
    end
    vars["movingAverageFunc1_param3"].Value = vars["maType"];
    SafeSetFloat(vars["movingAverageFunc1_param1"], period, source.close:tick(period));
    maFast = vars["movingAverageFunc1"].GetValue(period, mode);
    vars["movingAverageFunc2_param3"].Value = vars["maType"];
    SafeSetFloat(vars["movingAverageFunc2_param1"], period, source.close:tick(period));
    maSlow = vars["movingAverageFunc2"].GetValue(period, mode);
    maColor = Triary(SafeGreater(maFast, maSlow), vars["trendAC"], vars["trendSC"]);
    plot1[period] = Triary((vars["trendType"] == "Moving Average Cloud"), maFast, nil);
    plot1:setColor(period, vars["trendAC"] + math.floor(81 / 100 * 255) * 16777216);
    plot2[period] = Triary((vars["trendType"] == "Moving Average Cloud"), maSlow, nil);
    plot2:setColor(period, vars["trendAC"] + math.floor(73 / 100 * 255) * 16777216);
    vars["PINESCRIPT SUPERTREND1"]:update(mode);
    supertrend_ret_val, direction_ret_val = vars["PINESCRIPT SUPERTREND1"].SUPERTREND:tick(period), vars["PINESCRIPT SUPERTREND1"].DIRECTION:tick(period);
    supertrend = supertrend_ret_val;
    direction = direction_ret_val;
    supertrend = Triary(vars["__IsFirst1"]:IsFirst(), nil, supertrend);
    plot3[period] = Triary(SafeLess(direction, 0), Triary((vars["trendType"] == "Supertrend"), supertrend, nil), nil);
    plot4[period] = Triary(SafeLess(direction, 0), nil, Triary((vars["trendType"] == "Supertrend"), supertrend, nil));
    plot5[period] = Triary(vars["__IsFirst2"]:IsFirst(), nil, Triary((vars["trendType"] == "Supertrend"), (source.open:tick(period) + source.close:tick(period)) / 2, nil));
    if source.close:first() > period - (vars["length"]) then return; end
    SafeSetFloat(vars["upper"], period, mathex.max(source.close, core.rangeTo(period, vars["length"])));
    if source.close:first() > period - (vars["length"]) then return; end
    SafeSetFloat(vars["lower"], period, mathex.min(source.close, core.rangeTo(period, vars["length"])));
    if vars["upper"]:first() > period - (1) then return; end
    if vars["lower"]:first() > period - (1) then return; end
    SafeSetFloat(vars["os"], period, Triary(SafeGreater(SafeGetFloat(vars["upper"], period), SafeGetFloat(vars["upper"], period - 1)), 1, Triary(SafeLess(SafeGetFloat(vars["lower"], period), SafeGetFloat(vars["lower"], period - 1)), 0, SafeGetFloat(vars["os"], period))));
    plot6[period] = Triary((vars["trendType"] == "Donchian Channels"), SafeGetFloat(vars["upper"], period), nil);
    plot6:setColor(period, vars["trendAC"] + math.floor(99 / 100 * 255) * 16777216);
    plot7[period] = Triary((vars["trendType"] == "Donchian Channels"), SafeGetFloat(vars["lower"], period), nil);
    plot7:setColor(period, vars["trendAC"] + math.floor(73 / 100 * 255) * 16777216);
    if (vars["trendType"] == "Moving Average Cloud") then
        if (vars["trendFilt"] == "Aligned") then
            vars["C_DownTrend"] = SafeLess(source.close:tick(period), maFast) and SafeLess(maFast, maSlow);
            vars["C_UpTrend"] = SafeGreater(source.close:tick(period), maFast) and SafeGreater(maFast, maSlow);
        elseif (vars["trendFilt"] == "Opposite") then
            vars["C_DownTrend"] = SafeGreater(source.close:tick(period), maFast) and SafeGreater(maFast, maSlow);
            vars["C_UpTrend"] = SafeLess(source.close:tick(period), maFast) and SafeLess(maFast, maSlow);
        else
            vars["C_DownTrend"] = true;
            vars["C_UpTrend"] = true;
        end
    end
    if (vars["trendType"] == "Supertrend") then
        if (vars["trendFilt"] == "Aligned") then
            vars["C_DownTrend"] = SafeGreater(direction, 0);
            vars["C_UpTrend"] = SafeLess(direction, 0);
        elseif (vars["trendFilt"] == "Opposite") then
            vars["C_DownTrend"] = SafeLess(direction, 0);
            vars["C_UpTrend"] = SafeGreater(direction, 0);
        else
            vars["C_DownTrend"] = true;
            vars["C_UpTrend"] = true;
        end
    end
    if (vars["trendType"] == "Donchian Channels") then
        if (vars["trendFilt"] == "Aligned") then
            vars["C_DownTrend"] = (SafeGetFloat(vars["os"], period) == 0);
            vars["C_UpTrend"] = (SafeGetFloat(vars["os"], period) == 1);
        elseif (vars["trendFilt"] == "Opposite") then
            vars["C_DownTrend"] = (SafeGetFloat(vars["os"], period) == 1);
            vars["C_UpTrend"] = (SafeGetFloat(vars["os"], period) == 0);
        else
            vars["C_DownTrend"] = true;
            vars["C_UpTrend"] = true;
        end
    end
    bullishReversal = vars["isBullishReversalFunc3"].GetValue(period, mode) and vars["C_UpTrend"];
    bearishReversal = vars["isBearishReversalFunc4"].GetValue(period, mode) and vars["C_DownTrend"];
    if bullishReversal and (Triary((vars["brpType"] == "All"), true, Triary((vars["brpType"] == "Enhanced"), Triary(SafeGreater(source.close:tick(period), source.high:tick(period - 2)), true, false), Triary((vars["brpType"] == "Normal"), Triary(SafeLess(source.close:tick(period), source.high:tick(period - 2)), true, false), false)))) then
        SafeSetBool(vars["bullProcess"], period, true);
        label_1_x = period;
        vars["lbAT"] = Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, source.low:tick(period)):SetText("?"):SetColor(Color(nil)):SetTextColor(vars["brpAC"] + math.floor(07 / 100 * 255) * 16777216):SetStyle("up"):SetSize("small"):SetTooltip("new bullish pattern detected" .. (Triary(SafeGreater(source.close:tick(period), source.high:tick(period - 2)), " (enchanced)", " (normal)")));
        vars["lnAT"] = Line:New(period - 2, source.high:tick(period - 2), period, source.high:tick(period - 2)):SetColor(vars["brpAC"] + math.floor(53 / 100 * 255) * 16777216);
        vars["lnAB"] = Line:New(period - 1, SafeMin(source.low:tick(period - 1), source.low:tick(period)), period - 0, SafeMin(source.low:tick(period - 1), source.low:tick(period))):SetColor(vars["brpAC"] + math.floor(53 / 100 * 255) * 16777216);
        Linefill:New(vars["lnAT"], vars["lnAB"]):SetColor(vars["brpAC"] + math.floor(73 / 100 * 255) * 16777216);
        vars["lnAT2"] = Line:New(period - 2, source.high:tick(period - 2), period, source.high:tick(period - 2)):SetColor(vars["brpAC"] + math.floor(53 / 100 * 255) * 16777216);
        vars["lnAB2"] = Line:New(period - 1, SafeMin(source.low:tick(period - 1), source.low:tick(period)), period - 0, SafeMin(source.low:tick(period - 1), source.low:tick(period))):SetColor(vars["brpAC"] + math.floor(53 / 100 * 255) * 16777216);
        SafeSetFloat(vars["bullHigh"], period, Triary((vars["brpSR"] == "Zone"), SafeMax(source.low:tick(period - 1), source.low:tick(period)), SafeMin(source.low:tick(period - 1), source.low:tick(period))));
    end
    if SafeGetBool(vars["bullProcess"], period) then
        if SafeGreater(source.close:tick(period - 1), Line:GetPrice(vars["lnAT"], period)) then
            if vars["bullProcess"]:first() > period - (1) then return; end
            if vars["bullProcess"]:first() > period - (1) then return; end
            if vars["bullProcess"]:first() > period - (2) then return; end
            if SafeGetBool(vars["bullProcess"], period - 1) and (SafeGetBool(vars["bullProcess"], period - 1) ~= SafeGetBool(vars["bullProcess"], period - 2)) then
                Label:SetTooltip(vars["lbAT"], "enchanced pattern (confirmed at detection)\nprice activity above the pattern high");
            else
                Label:SetTooltip(vars["lbAT"], SafeConcat(SafeConcat("pattern confirmed ", Str:ToString(SafeMinus(period - 1, Label:GetX(vars["lbAT"])))), " bars later"));
                label_2_x = period - 1;
                Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, source.low:tick(period - 1)):SetText("?"):SetColor(Color(nil)):SetTextColor(vars["brpAC"] + math.floor(07 / 100 * 255) * 16777216):SetStyle("up"):SetSize("small"):SetTooltip("confirmation bar\nprice activity above the pattern high");
            end
            SafeSetBool(vars["bullProcess"], period, false);
            vars["bxA"] = Box:New(core.formatDate(source:date(period)), "1", period, SafeGetFloat(vars["bullHigh"], period), period, Line:GetPrice(vars["lnAB"], period)):SetBgColor(vars["brpAC"] + math.floor(73 / 100 * 255) * 16777216):SetBorderColor(vars["brpAC"] + math.floor(Triary((vars["brpSR"] == "Zone"), 73, 53) / 100 * 255) * 16777216);
            SafeSetBool(vars["bullProcess2"], period, true);
        end
        if (SafeLess(source.close:tick(period - 1), Line:GetPrice(vars["lnAB"], period)) or bearishReversal) then
            Label:SetTooltip(vars["lbAT"], "pattern failed\nthe low of the pattern breached");
            SafeSetBool(vars["bullProcess"], period, false);
        end
        if not (SafeGetBool(vars["bullProcess"], period)) then
            Line:SetX2(vars["lnAT2"], period - 1);
            Line:SetX2(vars["lnAB2"], period - 1);
        else
            Line:SetX2(vars["lnAT2"], period);
            Line:SetX2(vars["lnAB2"], period);
        end
    end
    if SafeGetBool(vars["bullProcess2"], period) and (vars["brpSR"] ~= "None") then
        if SafeGreater(source.close:tick(period), Box:GetBottom(vars["bxA"])) then
            Box:SetRight(vars["bxA"], period);
        else
            Box:SetRight(vars["bxA"], period);
            SafeSetBool(vars["bullProcess2"], period, false);
        end
    end
    if bearishReversal and (Triary((vars["brpType"] == "All"), true, Triary((vars["brpType"] == "Enhanced"), Triary(SafeLess(source.close:tick(period), source.low:tick(period - 2)), true, false), Triary((vars["brpType"] == "Normal"), Triary(SafeGreater(source.close:tick(period), source.low:tick(period - 2)), true, false), false)))) then
        SafeSetBool(vars["bearProcess"], period, true);
        label_3_x = period;
        vars["lbST"] = Label:New(core.formatDate(label_3_x and source:date(label_3_x) or 0) .. "_3", "3", label_3_x, source.high:tick(period)):SetText("?"):SetColor(Color(nil)):SetTextColor(vars["brpSC"] + math.floor(07 / 100 * 255) * 16777216):SetStyle("down"):SetSize("small"):SetTooltip("new bearish pattern detected" .. (Triary(SafeLess(source.close:tick(period), source.low:tick(period - 2)), " (enchanced)", " (normal)")));
        vars["lnSB"] = Line:New(period - 2, source.low:tick(period - 2), period, source.low:tick(period - 2)):SetColor(vars["brpSC"] + math.floor(53 / 100 * 255) * 16777216);
        vars["lnST"] = Line:New(period - 1, SafeMax(source.high:tick(period - 1), source.high:tick(period)), period - 0, SafeMax(source.high:tick(period - 1), source.high:tick(period))):SetColor(vars["brpSC"] + math.floor(53 / 100 * 255) * 16777216);
        Linefill:New(vars["lnST"], vars["lnSB"]):SetColor(vars["brpSC"] + math.floor(73 / 100 * 255) * 16777216);
        vars["lnSB2"] = Line:New(period - 2, source.low:tick(period - 2), period, source.low:tick(period - 2)):SetColor(vars["brpSC"] + math.floor(53 / 100 * 255) * 16777216);
        vars["lnST2"] = Line:New(period - 1, SafeMax(source.high:tick(period - 1), source.high:tick(period)), period - 0, SafeMax(source.high:tick(period - 1), source.high:tick(period))):SetColor(vars["brpSC"] + math.floor(53 / 100 * 255) * 16777216);
        SafeSetFloat(vars["bearLow"], period, Triary((vars["brpSR"] == "Zone"), SafeMin(source.high:tick(period - 1), source.high:tick(period)), SafeMax(source.high:tick(period - 1), source.high:tick(period))));
    end
    if SafeGetBool(vars["bearProcess"], period) then
        if (SafeGreater(source.close:tick(period - 1), Line:GetPrice(vars["lnST"], period)) or bullishReversal) then
            Label:SetTooltip(vars["lbST"], "pattern failed\nthe high of the pattern breached");
            SafeSetBool(vars["bearProcess"], period, false);
        end
        if SafeLess(source.close:tick(period - 1), Line:GetPrice(vars["lnSB"], period)) then
            if vars["bearProcess"]:first() > period - (1) then return; end
            if vars["bearProcess"]:first() > period - (1) then return; end
            if vars["bearProcess"]:first() > period - (2) then return; end
            if SafeGetBool(vars["bearProcess"], period - 1) and (SafeGetBool(vars["bearProcess"], period - 1) ~= SafeGetBool(vars["bearProcess"], period - 2)) then
                Label:SetTooltip(vars["lbST"], "enchanced pattern (confirmed at detection)\nprice activity below the pattern low");
            else
                Label:SetTooltip(vars["lbST"], SafeConcat(SafeConcat("pattern confirmed ", Str:ToString(SafeMinus(period - 1, Label:GetX(vars["lbST"])))), " bars later"));
                label_4_x = period - 1;
                Label:New(core.formatDate(label_4_x and source:date(label_4_x) or 0) .. "_4", "4", label_4_x, source.high:tick(period - 1)):SetText("?"):SetColor(Color(nil)):SetTextColor(vars["brpSC"] + math.floor(07 / 100 * 255) * 16777216):SetStyle("down"):SetSize("small"):SetTooltip("confirmation bar\nprice activity blow the pattern low");
            end
            SafeSetBool(vars["bearProcess"], period, false);
            vars["bxS"] = Box:New(core.formatDate(source:date(period)), "2", period, Line:GetPrice(vars["lnST"], period), period, SafeGetFloat(vars["bearLow"], period)):SetBgColor(vars["brpSC"] + math.floor(73 / 100 * 255) * 16777216):SetBorderColor(vars["brpSC"] + math.floor(Triary((vars["brpSR"] == "Zone"), 73, 53) / 100 * 255) * 16777216);
            SafeSetBool(vars["bearProcess2"], period, true);
        end
        if not (SafeGetBool(vars["bearProcess"], period)) then
            Line:SetX2(vars["lnST2"], period - 1);
            Line:SetX2(vars["lnSB2"], period - 1);
        else
            Line:SetX2(vars["lnST2"], period);
            Line:SetX2(vars["lnSB2"], period);
        end
    end
    if SafeGetBool(vars["bearProcess2"], period) and (vars["brpSR"] ~= "None") then
        if SafeLess(source.close:tick(period), Box:GetTop(vars["bxS"])) then
            Box:SetRight(vars["bxS"], period);
        else
            Box:SetRight(vars["bxS"], period);
            SafeSetBool(vars["bearProcess2"], period, false);
        end
    end
end
function Draw(stage, context)
    Label:Draw(stage, context);
    Line:Draw(stage, context);
    Linefill:Draw(stage, context);
    Box:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Display = {};
Display.All = 15;
Display.None = 0;
Display.DataWindow = 1;
Display.Pane = 2;
Display.PriceScale = 4;
Display.StatusLine = 8;
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
    if not stream:hasData(period) then
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

function CreateIsFirst()
    local is_first = {};
    is_first.first = true;
    function is_first:IsFirst()
        local val = self.first;
        self.first = false;
        return val;
    end
    function is_first:Clear()
        self.first = true;
    end
    return is_first;
end
Label = {};
Label.AllLabelsInOrder = {};
Label.AllSeries = {};
function Label:Clear()
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
function Label:SetTooltip(label, text)
    if label == nil then
        return;
    end
    label:SetTooltip(text);
end
function Label:SetSize(label, size)
    if label == nil then
        return;
    end
    label:SetSize(size);
end
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
end
function Label:SetXY(label, x, y)
    if label == nil then
        return;
    end
    label:SetX(x);
    label:SetY(y);
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
    function newLabel:SetTooltip(tooltip)
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
            return x1, y - H / 2, x1 + W, y + H / 2;
        end
        if self.Style == "down" then
            return x1 - W / 2, y - H, x1 + W / 2, y;
        end
        if self.Style == "up" then
            return x1 - W / 2, y, x1 + W / 2, y + H;
        end
        return x1 - W / 2, y - H / 2, x1 + W / 2, y + H / 2;
    end
    newLabel.Size = "auto";
    function newLabel:SetSize(size)
        self.Size = size;
        return self;
    end
    function newLabel:GetDefaultSize()
        if self.Size == "tiny" then
            return 7, 7;
        end
        if self.Size == "auto" or self.Size == "small" then
            return 10, 10;
        end
        if self.Size == "normal" then
            return 12, 12;
        end
        if self.Size == "large" then
            return 14, 14;
        end
        return 16, 16;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        if self.FontId == nil then
            local defFontSize = self:GetDefaultSize();
            self.FontId = Graphics:FindFont("Arial", 0, defFontSize, context.LEFT, context);
        end
        local W, H;
        if self.Text == nil or self.Text == "" then
            W, H = self:GetDefaultSize()
        else
            W, H = context:measureText(self.FontId, self.Text, context.LEFT);
        end
        local x_from, y_from, x_to, y_to = self:getCoordinates(context, W, H);
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            if self.Style == "down" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from - ySize / 2;
                y_to = y_to - ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_to);
                points:add(x_to, y_to);
                points:add((x_to + x_from) / 2, y_to + ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "up" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from + ySize / 2;
                y_to = y_to + ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_from - 1);
                points:add(x_to, y_from - 1);
                points:add((x_to + x_from) / 2, y_from - ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "none" then
            else
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            end
        end
        context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    function newLabel:Get(index)
        return Label.AllSeries[self.SeriesId][index + 1];
    end
    self.AllLabelsInOrder[#self.AllLabelsInOrder + 1] = newLabel
    if #self.AllLabelsInOrder > self.max_labels_count then
        Label:Delete(self.AllLabelsInOrder[1]);
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
    for i = 1, #self.AllLabelsInOrder do
        self.AllLabelsInOrder[i]:Draw(stage, context);
    end
end
Line = {};
Line.AllLines = {};
function Line:GetAll()
    local array = {};
    array.arr = Line.AllLines;
    return array;
end
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
end
function Line:GetPrice(line, x)
    if line == nil then
        return nil;
    end
    return line:GetPrice(x);
end
function Line:SetXY1(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY1(x, y);
end
function Line:SetXY2(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY2(x, y);
end
function Line:SetX1(line, x)
    if line == nil then
        return;
    end
    line:SetX1(x);
end
function Line:SetX2(line, x)
    if line == nil then
        return;
    end
    line:SetX2(x);
end
function Line:SetY1(line, y)
    if line == nil then
        return;
    end
    line:SetY1(y);
end
function Line:SetY2(line, y)
    if line == nil then
        return;
    end
    line:SetY2(y);
end
function Line:GetX1(line)
    if line == nil then
        return;
    end
    return line:GetX1();
end
function Line:GetX2(line)
    if line == nil then
        return;
    end
    return line:GetX2();
end
function Line:GetY1(line)
    if line == nil then
        return;
    end
    return line:GetY1();
end
function Line:GetY2(line)
    if line == nil then
        return;
    end
    return line:GetY2();
end
function Line:SetColor(line, clr)
    if line == nil then
        return;
    end
    line:SetColor(clr);
end
function Line:SetWidth(line, width)
    if line == nil then
        return;
    end
    line:SetWidth(width);
end
function Line:SetStyle(line, style)
    if line == nil then
        return;
    end
    line:SetStyle(style);
end
function Line:SetExtend(line, extend)
    if line == nil then
        return;
    end
    line:SetExtend(extend);
end
function Line:SetXLoc(line, x1, x2, xloc)
    if line == nil then
        return;
    end
    line:SetXLoc(x1, x2, xloc);
end
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
        return self;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
        return self;
    end
    function newLine:SetX1(x)
        self.X1 = x;
        return self;
    end
    function newLine:SetX2(x)
        self.X2 = x;
        return self;
    end
    newLine.XLoc = "bar_index";
    function newLine:SetXLoc(x1, x2, xloc)
        newLine.X1 = x1;
        newLine.X2 = x2;
        newLine.XLoc = xloc;
        return self;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
        return self;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
        return self;
    end
    function newLine:GetX1()
        return self.X1;
    end
    function newLine:GetX2()
        return self.X2;
    end
    function newLine:GetY1()
        return self.Y1;
    end
    function newLine:GetY2()
        return self.Y2;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.ColorTransparency = (math.floor(clr / 16777216) % 255);
        self.Color = clr - self.ColorTransparency * 16777216;
        self.PenId = nil;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenId = nil;
        return self;
    end
    newLine.Extend = "none";
    function newLine:SetExtend(extend)
        self.Extend = extend;
        return self;
    end
    newLine.Style = "solid";
    function newLine:SetStyle(style)
        self.Style = style;
        self.PenId = nil;
        return self;
    end
    function newLine:GetPrice(x)
        local a, c = math2d.lineEquation(self.X1, self.Y1, self.X2, self.Y2);
        return a * x + c;
    end
    function newLine:getStyleForContext()
        if self.Style == "solid" or self.Style == "arrow_left" or self.Style == "arrow_both" or self.Style == "arrow_right" then
            return core.LINE_SOLID;
        elseif self.Style == "dotted" then
            return core.LINE_DOT;
        elseif self.Style == "dashed" then
            return core.LINE_DASH;
        end
        return core.LINE_SOLID;
    end
    function newLine:converXToPoints(context, x)
        if self.XLoc == "bar_time" then
            return context:positionOfDate(x / 86400000);
        end
        local _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        local x1 = self:converXToPoints(context, self.X1);
        local x2 = self:converXToPoints(context, self.X2);
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
        end
    end
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
    return newLine;
end
function Line:Delete(line)
    for i = 1, #self.AllLines do
        if self.AllLines[i] == line then
            table.remove(self.AllLines, i);
            return;
        end
    end
end
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
end
Linefill = {};
Linefill.AllLinefills = {};
function Linefill:Clear()
    Linefill.AllLinefills = {};
end
function Linefill:SetColor(Linefill, clr)
    if Linefill == nil then
        return;
    end
    Linefill:SetColor(clr);
end
function Linefill:New(line1, line2)
    for i, fill in ipairs(Linefill.AllLinefills) do
        if fill.Line1 == line1 and fill.Line2 == line2 then
            return fill;
        end
    end
    local newLinefill = {};
    newLinefill.Line1 = line1;
    newLinefill.Line2 = line2;
    newLinefill.Color = core.colors().Blue;
    function newLinefill:SetColor(clr, transparency)
        self.Color = clr;
        if clr ~= nil then
            self.ColorTransparency = transparency and transparency or (math.floor(clr / 16777216) % 255);
        else
            self.ColorTransparency = nil;
        end
        self.PenId = nil;
        self.BrushId = nil;
    end
    function newLinefill:Draw(stage, context)
        if self.Line1 == nil or self.Line2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(1, self.Color, core.LINE_SOLID, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.Color, context);
        end
        
        local points = context:createPoints();
        _, y1 = context:pointOfPrice(self.Line1:GetY1());
        _, x1 = context:positionOfBar(self.Line1:GetX1());
        _, y2 = context:pointOfPrice(self.Line1:GetY2());
        _, x2 = context:positionOfBar(self.Line1:GetX2());
        points:add(x1, y1);
        points:add(x2, y2);
        _, y1 = context:pointOfPrice(self.Line2:GetY1());
        _, x1 = context:positionOfBar(self.Line2:GetX1());
        _, y2 = context:pointOfPrice(self.Line2:GetY2());
        _, x2 = context:positionOfBar(self.Line2:GetX2());
        points:add(x2, y2);
        points:add(x1, y1);
        context:drawPolygon(self.PenId, self.BrushId, points, self.ColorTransparency);
    end
    self.AllLinefills[#self.AllLinefills + 1] = newLinefill;
    return newLinefill;
end
function Linefill:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLinefills) do
        value:Draw(stage, context);
    end
end
Str = {};
function Str:NewVar(value)
    local var = {};
    var.items = {};
    var.items[0] = value;
    function var:Get(period)
        if period < 0 then
            return nil;
        end
        return self.items[period];
    end
    function var:Set(period, value)
        self.items[period] = value;
    end
    return var;
end
function Str:Clear()
end
function Str:doFormat(pattern, values)
    local tokens = core.parseCsv(pattern, ",");
    local value = values[tonumber(tokens[0])];
    if value == nil then
        return "";
    end
    if tokens[1] == "number" then
        if tokens[2] == "percent" then
            return tostring(math.floor(value + 0.5)) .. "%";
        end
    end
    return tostring(value);
end
function Str:Format(pattern, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
    local values = {};
    values[0] = value0;
    values[1] = value1;
    values[2] = value2;
    values[3] = value3;
    values[4] = value4;
    values[5] = value5;
    values[6] = value6;
    values[7] = value7;
    values[8] = value8;
    values[9] = value9;

    local tokens = core.parseCsv(pattern, "{");
    local result = "";
    for i, token in ipairs(tokens) do
        local subtokens, c = core.parseCsv(token, "}");
        if c == 1 then
            result = result .. token;
        else
            result = result .. Str:doFormat(subtokens[0], values) .. subtokens[1];
        end
    end
    return result;
end
function Str:ToString(value, pattern)
    if value == nil then
        return "";
    end
    if pattern == nil then
        return tostring(value);
    end
    if pattern == "percent" then
        return win32.formatNumber(value, false, 2);
    end
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
function Str:Length(str)
    if str == nil then
        return 0;
    end
    return string.len(str);
end
function Str:ReplaceAll(str, from, to)
    if str == nil then
        return nil;
    end
    return string.gsub(str, from, to);
end
function Str:Upper(str)
    if str == nil then
        return nil;
    end
    return string.upper(str);
end
function Str:StartsWith(str, item)
    if str == nil then
        return nil;
    end
    return string.find(str, item) == 1;
end
function Str:Split(str, separator)
    if str == nil then
        return nil;
    end
    local items, c = core.parseCsv(str, separator);
    local arr = Array:NewString(0);
    for i = 0, c - 1 do
        arr:Push(items[i]);
    end
    return arr;
end
function SafeSetString(str, period, value)
    if str == nil then
        return;
    end
    str:Set(period, value);
end
function SafeGetString(str, period)
    if str == nil then
        return;
    end
    return str:Get(period);
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function Box:SetLeftTop(box, left, top)
    if box == nil then
        return;
    end
    box:SetLeft(left);
    box:SetTop(top);
end
function Box:SetRightBottom(box, right, bottom)
    if box == nil then
        return;
    end
    box:SetRight(right);
    box:SetBottom(bottom);
end
function Box:SetRight(box, right)
    if box == nil then
        return;
    end
    box:SetRight(right);
end
function Box:SetTop(box, top)
    if box == nil then
        return;
    end
    box:SetTop(top);
end
function Box:SetBottom(box, bottom)
    if box == nil then
        return;
    end
    box:SetBottom(bottom);
end
function Box:SetLeft(box, left)
    if box == nil then
        return;
    end
    box:SetLeft(left);
end
function Box:GetBottom(box)
    if box == nil then
        return nil;
    end
    return box:GetBottom();
end
function Box:GetTop(box)
    if box == nil then
        return nil;
    end
    return box:GetTop();
end
function Box:GetLeft(box)
    if box == nil then
        return nil;
    end
    return box:GetLeft();
end
function Box:GetRight(box)
    if box == nil then
        return nil;
    end
    return box:GetRight();
end
function Box:SetText(box, text)
    if box == nil then
        return;
    end
    box:SetText(text);
end
function Box:SetTextColor(box, text_color)
    if box == nil then
        return;
    end
    box:SetTextColor(text_color);
end
function Box:SetTextHAlign(box, text_halign)
    if box == nil then
        return;
    end
    box:SetTextHAlign(text_halign);
end
function Box:SetTextSize(box, text_size)
    if box == nil then
        return;
    end
    box:SetTextSize(text_size);
end
function Box:SetBorderStyle(box, style)
    if box == nil then
        return;
    end
    box:SetBorderStyle(style);
end
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    function newBox:SetLeft(left)
        self.Left = left;
        return self;
    end
    function newBox:GetLeft()
        return self.Left;
    end
    newBox.Top = top;
    function newBox:SetTop(top)
        self.Top = top;
        return self;
    end
    function newBox:GetTop()
        return self.Top;
    end
    newBox.Right = right;
    function newBox:SetRight(right)
        self.Right = right;
        return self;
    end
    function newBox:GetRight()
        return self.Right;
    end
    newBox.Bottom = bottom;
    function newBox:SetBottom(bottom)
        self.Bottom = bottom;
        return self;
    end
    function newBox:GetBottom()
        return self.Bottom;
    end
    newBox.BorderWidth = 1;
    newBox.BgColor = core.colors().Blue;
    function newBox:SetBgColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BgColorTransparency = transparency;
        self.BgColor = color;
        self.BrushId = nil;
        return self;
    end
    newBox.BorderColor = core.colors().Blue;
    function newBox:SetBorderColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BorderColor_transparency = transparency;
        self.BorderColor = color;
        self.PenId = nil;
        return self;
    end
    newBox.BorderStyle = "solid";
    newBox.BorderStyleIndicore = core.LINE_SOLID;
    function newBox:SetBorderStyle(style)
        self.BorderStyle = style;
        if style == "solid" or style == "arrow_right" or style == "arrow_left" or style == "arrow_both" then
            newBox.BorderStyleIndicore = core.LINE_SOLID;
        elseif style == "dotted" then
            newBox.BorderStyleIndicore = core.LINE_DOT;
        elseif style == "dashed" then
            newBox.BorderStyleIndicore = core.LINE_DASH;
        end
        self.PenId = nil;
        return self;
    end
    newBox.Text = nil;
    function newBox:SetText(text)
        self.Text = text;
        return self;
    end
    newBox.TextColor = nil;
    function newBox:SetTextColor(text_color)
        self.TextColor = text_color;
        return self;
    end
    newBox.TextHAlign = nil;
    function newBox:SetTextHAlign(text_halign)
        self.TextHAlign = text_halign;
        return self;
    end
    newBox.TextSize = nil;
    function newBox:SetTextSize(text_size)
        self.TextSize = text_size;
        return self;
    end
    function newBox:getCoordinates(context, x, y, W, H)
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyleIndicore, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, x1 = context:positionOfBar(self.Left);
        _, y2 = context:pointOfPrice(self.Bottom);
        _, x2 = context:positionOfBar(self.Right);
        if (x1 == x2) then
            x2 = x1 + 1;
        end
        if (y1 == y2) then
            y2 = y1 + 1
        end
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
        if self.Text ~= nil and self.Text ~= "" then
            if self.FontId == nil then
                self.FontId = Graphics:FindFont("Arial", 10, 0, context.LEFT, context);
            end
            local W, H = context:measureText(self.FontId, self.Text, context.LEFT);
            local x_from, y_from, x_to, y_to = self:getCoordinates(context, (x1 + x2) / 2, (y1 + y2) / 2, W, H);
            context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
        end
    end
    function newBox:Get(index)
        return Box.AllSeries[self.SeriesId][index + 1];
    end
    self.AllBoxs[id .. "_" .. seriesId] = newBox;
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newBox);
    return newBox;
end
function Box:Delete(box)
    if box == nil then
        return;
    end
    self:removeFromAllBoxes(box);
    self:removeFromSeries(box);
end
function Box:removeFromSeries(box)
    for i = 1, #self.AllSeries[box.SeriesId] do
        if self.AllSeries[box.SeriesId][i] == box then
            table.remove(self.AllSeries[box.SeriesId], i);
            return;
        end
    end
end
function Box:removeFromAllBoxes(box)
    for key, value in pairs(self.AllBoxs) do
        if value == box then
            self.AllBoxs[key] = nil;
            return;
        end
    end
end
function Box:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for id, Box in pairs(self.AllBoxs) do
        Box:Draw(stage, context);
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
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