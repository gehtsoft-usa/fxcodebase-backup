-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74456

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
    indicator:name("[PX] ADX Box");
    indicator:description("[PX] ADX Box");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "ADX Threshold", "", 20);
    indicator.parameters:addInteger("param2", "ADX Smoothing", "", 14);
    indicator.parameters:addInteger("param3", "DI Length", "", 14);
    indicator.parameters:addString("param4", "Box Mode", "", "Extremes");
    indicator.parameters:addStringAlternative("param4", "Extremes", "", "Extremes");
    indicator.parameters:addStringAlternative("param4", "Avg. High/Low", "", "Avg. High/Low");
    indicator.parameters:addBoolean("param5", "Show Box?", "", true);
    indicator.parameters:addBoolean("param6", "Show Mid Line?", "", true);
    indicator.parameters:addBoolean("param7", "Extend Mid Line?", "", false);
    indicator.parameters:addString("param8", "Box Color", "", "yellow");
    indicator.parameters:addStringAlternative("param8", "aqua", "", "aqua");
    indicator.parameters:addStringAlternative("param8", "black", "", "black");
    indicator.parameters:addStringAlternative("param8", "blue", "", "blue");
    indicator.parameters:addStringAlternative("param8", "fuchsia", "", "fuchsia");
    indicator.parameters:addStringAlternative("param8", "gray", "", "gray");
    indicator.parameters:addStringAlternative("param8", "green", "", "green");
    indicator.parameters:addStringAlternative("param8", "lime", "", "lime");
    indicator.parameters:addStringAlternative("param8", "maroon", "", "maroon");
    indicator.parameters:addStringAlternative("param8", "navy", "", "navy");
    indicator.parameters:addStringAlternative("param8", "olive", "", "olive");
    indicator.parameters:addStringAlternative("param8", "orange", "", "orange");
    indicator.parameters:addStringAlternative("param8", "purple", "", "purple");
    indicator.parameters:addStringAlternative("param8", "red", "", "red");
    indicator.parameters:addStringAlternative("param8", "silver", "", "silver");
    indicator.parameters:addStringAlternative("param8", "teal", "", "teal");
    indicator.parameters:addStringAlternative("param8", "white", "", "white");
    indicator.parameters:addStringAlternative("param8", "yellow", "", "yellow");
    indicator.parameters:addString("param9", "Box Style", "", "solid");
    indicator.parameters:addStringAlternative("param9", "solid", "", "solid");
    indicator.parameters:addStringAlternative("param9", "dotted", "", "dotted");
    indicator.parameters:addStringAlternative("param9", "dashed", "", "dashed");
    indicator.parameters:addInteger("param10", "Box Width", "", 2);
    indicator.parameters:addString("param11", "Mid Line Color", "", "fuchsia");
    indicator.parameters:addStringAlternative("param11", "aqua", "", "aqua");
    indicator.parameters:addStringAlternative("param11", "black", "", "black");
    indicator.parameters:addStringAlternative("param11", "blue", "", "blue");
    indicator.parameters:addStringAlternative("param11", "fuchsia", "", "fuchsia");
    indicator.parameters:addStringAlternative("param11", "gray", "", "gray");
    indicator.parameters:addStringAlternative("param11", "green", "", "green");
    indicator.parameters:addStringAlternative("param11", "lime", "", "lime");
    indicator.parameters:addStringAlternative("param11", "maroon", "", "maroon");
    indicator.parameters:addStringAlternative("param11", "navy", "", "navy");
    indicator.parameters:addStringAlternative("param11", "olive", "", "olive");
    indicator.parameters:addStringAlternative("param11", "orange", "", "orange");
    indicator.parameters:addStringAlternative("param11", "purple", "", "purple");
    indicator.parameters:addStringAlternative("param11", "red", "", "red");
    indicator.parameters:addStringAlternative("param11", "silver", "", "silver");
    indicator.parameters:addStringAlternative("param11", "teal", "", "teal");
    indicator.parameters:addStringAlternative("param11", "white", "", "white");
    indicator.parameters:addStringAlternative("param11", "yellow", "", "yellow");
    indicator.parameters:addString("param12", "Mid Line Style", "", "solid");
    indicator.parameters:addStringAlternative("param12", "solid", "", "solid");
    indicator.parameters:addStringAlternative("param12", "dotted", "", "dotted");
    indicator.parameters:addStringAlternative("param12", "dashed", "", "dashed");
    indicator.parameters:addInteger("param13", "Mid Line Width", "", 2);
    indicator.parameters:addString("param14", "Box Color (in Progress)", "", "lime");
    indicator.parameters:addStringAlternative("param14", "aqua", "", "aqua");
    indicator.parameters:addStringAlternative("param14", "black", "", "black");
    indicator.parameters:addStringAlternative("param14", "blue", "", "blue");
    indicator.parameters:addStringAlternative("param14", "fuchsia", "", "fuchsia");
    indicator.parameters:addStringAlternative("param14", "gray", "", "gray");
    indicator.parameters:addStringAlternative("param14", "green", "", "green");
    indicator.parameters:addStringAlternative("param14", "lime", "", "lime");
    indicator.parameters:addStringAlternative("param14", "maroon", "", "maroon");
    indicator.parameters:addStringAlternative("param14", "navy", "", "navy");
    indicator.parameters:addStringAlternative("param14", "olive", "", "olive");
    indicator.parameters:addStringAlternative("param14", "orange", "", "orange");
    indicator.parameters:addStringAlternative("param14", "purple", "", "purple");
    indicator.parameters:addStringAlternative("param14", "red", "", "red");
    indicator.parameters:addStringAlternative("param14", "silver", "", "silver");
    indicator.parameters:addStringAlternative("param14", "teal", "", "teal");
    indicator.parameters:addStringAlternative("param14", "white", "", "white");
    indicator.parameters:addStringAlternative("param14", "yellow", "", "yellow");
    indicator.parameters:addString("param15", "Box Style (in Progress)", "", "dashed");
    indicator.parameters:addStringAlternative("param15", "solid", "", "solid");
    indicator.parameters:addStringAlternative("param15", "dotted", "", "dotted");
    indicator.parameters:addStringAlternative("param15", "dashed", "", "dashed");
    indicator.parameters:addInteger("param16", "Box Width (in Progress)", "", 1);
    indicator.parameters:addString("param17", "Mid Line Color (in Progress)", "", "orange");
    indicator.parameters:addStringAlternative("param17", "aqua", "", "aqua");
    indicator.parameters:addStringAlternative("param17", "black", "", "black");
    indicator.parameters:addStringAlternative("param17", "blue", "", "blue");
    indicator.parameters:addStringAlternative("param17", "fuchsia", "", "fuchsia");
    indicator.parameters:addStringAlternative("param17", "gray", "", "gray");
    indicator.parameters:addStringAlternative("param17", "green", "", "green");
    indicator.parameters:addStringAlternative("param17", "lime", "", "lime");
    indicator.parameters:addStringAlternative("param17", "maroon", "", "maroon");
    indicator.parameters:addStringAlternative("param17", "navy", "", "navy");
    indicator.parameters:addStringAlternative("param17", "olive", "", "olive");
    indicator.parameters:addStringAlternative("param17", "orange", "", "orange");
    indicator.parameters:addStringAlternative("param17", "purple", "", "purple");
    indicator.parameters:addStringAlternative("param17", "red", "", "red");
    indicator.parameters:addStringAlternative("param17", "silver", "", "silver");
    indicator.parameters:addStringAlternative("param17", "teal", "", "teal");
    indicator.parameters:addStringAlternative("param17", "white", "", "white");
    indicator.parameters:addStringAlternative("param17", "yellow", "", "yellow");
    indicator.parameters:addString("param18", "Mid Line Style (in Progress)", "", "dashed");
    indicator.parameters:addStringAlternative("param18", "solid", "", "solid");
    indicator.parameters:addStringAlternative("param18", "dotted", "", "dotted");
    indicator.parameters:addStringAlternative("param18", "dashed", "", "dashed");
    indicator.parameters:addInteger("param19", "Mid Line Width (in Progress)", "", 1);
end

local source;
local vars = {};
local time;
local lowestInRange;
local highestInRange;
local vol;
local setupActive;
local begin;
local beginIndex;
local sig;
function Create_dirmov(len)
    local local_vars = {};
    SMMA1_source = instance:addInternalStream(0, 0);
    local_vars["SMMA1"] = core.indicators:create("SMMA", SMMA1_source, len);
            local_vars["__fixnan1"] = CreateFixnan();
    plusDM = instance:addInternalStream(0, 0);
    local_vars["SMMA2"] = core.indicators:create("SMMA", plusDM, len);
            local_vars["__fixnan2"] = CreateFixnan();
    minusDM = instance:addInternalStream(0, 0);
    local_vars["SMMA3"] = core.indicators:create("SMMA", minusDM, len);
    return {
        GetValue = function(period, mode)
            up = Change(source.high, period, 1);
            down = SafeNegative(Change(source.low, period, 1));
            SafeSetFloat(plusDM, period, ((up == nil) and (nil) or ((((SafeGreater(up, down) and SafeGreater(up, 0)) and (up) or (0))))));
            SafeSetFloat(minusDM, period, ((down == nil) and (nil) or ((((SafeGreater(down, up) and (down > 0)) and (down) or (0))))));
            SafeSetFloat(SMMA1_source, period, GetTrueRange(source, period));
            local_vars["SMMA1"]:update(mode);
            truerange = local_vars["SMMA1"].DATA:tick(period);
            local_vars["SMMA2"]:update(mode);
            plus = local_vars["__fixnan1"]:set(period, SafeDivide(SafeMultiply(100, local_vars["SMMA2"].DATA:tick(period)), truerange));
            local_vars["SMMA3"]:update(mode);
            minus = local_vars["__fixnan2"]:set(period, SafeDivide(SafeMultiply(100, local_vars["SMMA3"].DATA:tick(period)), truerange));
            return plus, minus;
        end
    };
end
function Create_adx(dilen, adxlen)
    local local_vars = {};
    local_vars["dirmovFunc2"] = Create_dirmov(dilen);
    SMMA4_source = instance:addInternalStream(0, 0);
    local_vars["SMMA4"] = core.indicators:create("SMMA", SMMA4_source, adxlen);
    return {
        GetValue = function(period, mode)
            plus_ret_val, minus_ret_val = local_vars["dirmovFunc2"].GetValue(period, mode);
            plus = plus_ret_val;
            minus = minus_ret_val;
            sum = SafePlus(plus, minus);
            SafeSetFloat(SMMA4_source, period, SafeDivide(SafeAbs(SafeMinus(plus, minus)), ((((sum == 0)) and (1) or (sum)))));
            local_vars["SMMA4"]:update(mode);
            adx = SafeMultiply(100, local_vars["SMMA4"].DATA:tick(period));
            return adx;
        end
    };
end
function Create_f_set_color(selection)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            ret = core.colors().Black;
            if (selection == "gray") then
                ret = core.colors().Gray;
            end
            if (selection == "green") then
                ret = core.colors().Green;
            end
            if (selection == "aqua") then
                ret = core.colors().Aqua;
            end
            if (selection == "blue") then
                ret = core.colors().Blue;
            end
            if (selection == "fuchsia") then
                ret = core.colors().Fuchsia;
            end
            if (selection == "lime") then
                ret = core.colors().Lime;
            end
            if (selection == "maroon") then
                ret = core.colors().Maroon;
            end
            if (selection == "navy") then
                ret = core.colors().Navy;
            end
            if (selection == "white") then
                ret = core.colors().White;
            end
            if (selection == "yellow") then
                ret = core.colors().Yellow;
            end
            if (selection == "olive") then
                ret = core.colors().Olive;
            end
            if (selection == "orange") then
                ret = core.colors().Orange;
            end
            if (selection == "purple") then
                ret = core.colors().Purple;
            end
            if (selection == "red") then
                ret = core.colors().Red;
            end
            if (selection == "silver") then
                ret = core.colors().Silver;
            end
            if (selection == "teal") then
                ret = core.colors().Teal;
            end
            return ret;
        end
    };
end
function Create_f_set_style(selection)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            ret = "solid";
            if (selection == "dotted") then
                ret = "dotted";
            end
            if (selection == "dashed") then
                ret = "dashed";
            end
            return ret;
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
    vars["threshold"] = instance.parameters.param1;
    vars["adxlen"] = instance.parameters.param2;
    vars["dilen"] = instance.parameters.param3;
    vars["mode"] = instance.parameters.param4;
    vars["showBox"] = instance.parameters.param5;
    vars["showMidLine"] = instance.parameters.param6;
    vars["extendMidLine"] = instance.parameters.param7;
    vars["lineColor"] = instance.parameters.param8;
    vars["lineStyle"] = instance.parameters.param9;
    vars["lineWidth"] = instance.parameters.param10;
    vars["midLineColor"] = instance.parameters.param11;
    vars["midLineStyle"] = instance.parameters.param12;
    vars["midLineWidth"] = instance.parameters.param13;
    vars["proLineColor"] = instance.parameters.param14;
    vars["proLineStyle"] = instance.parameters.param15;
    vars["proLineWidth"] = instance.parameters.param16;
    vars["proMidLineColor"] = instance.parameters.param17;
    vars["proMidLineStyle"] = instance.parameters.param18;
    vars["proMidLineWidth"] = instance.parameters.param19;
    time = instance:addInternalStream(0, 0);
    lowestInRange = instance:addInternalStream(0, 0);
    highestInRange = instance:addInternalStream(0, 0);
    vol = instance:addInternalStream(0, 0);
    setupActive = instance:addInternalStream(0, 0);
    begin = instance:addInternalStream(0, 0);
    beginIndex = instance:addInternalStream(0, 0);
    vars["adxFunc1"] = Create_adx(vars["dilen"], vars["adxlen"]);
    sig = instance:addInternalStream(0, 0);
    vars["threshold_stream"] = instance:addInternalStream(0, 0);
    Line:Prepare(50);
    vars["f_set_colorFunc3"] = Create_f_set_color(vars["proLineColor"]);
    vars["f_set_styleFunc4"] = Create_f_set_style(vars["proLineStyle"]);
    vars["f_set_colorFunc5"] = Create_f_set_color(vars["proLineColor"]);
    vars["f_set_styleFunc6"] = Create_f_set_style(vars["proLineStyle"]);
    vars["f_set_colorFunc7"] = Create_f_set_color(vars["proLineColor"]);
    vars["f_set_styleFunc8"] = Create_f_set_style(vars["proLineStyle"]);
    vars["f_set_colorFunc9"] = Create_f_set_color(vars["proMidLineColor"]);
    vars["f_set_styleFunc10"] = Create_f_set_style(vars["proMidLineStyle"]);
    vars["threshold_stream"] = instance:addInternalStream(0, 0);
    vars["f_set_colorFunc11"] = Create_f_set_color(vars["lineColor"]);
    vars["f_set_styleFunc12"] = Create_f_set_style(vars["lineStyle"]);
    vars["f_set_colorFunc13"] = Create_f_set_color(vars["lineColor"]);
    vars["f_set_styleFunc14"] = Create_f_set_style(vars["lineStyle"]);
    vars["f_set_colorFunc15"] = Create_f_set_color(vars["lineColor"]);
    vars["f_set_styleFunc16"] = Create_f_set_style(vars["lineStyle"]);
    vars["f_set_colorFunc17"] = Create_f_set_color(vars["lineColor"]);
    vars["f_set_styleFunc18"] = Create_f_set_style(vars["lineStyle"]);
    vars["f_set_colorFunc19"] = Create_f_set_color(vars["midLineColor"]);
    vars["f_set_styleFunc20"] = Create_f_set_style(vars["midLineStyle"]);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        time[period] = source:date(period) * 86400000;
        SafeSetFloat(lowestInRange, period, nil);
        SafeSetFloat(highestInRange, period, nil);
        SafeSetFloat(vol, period, nil);
        SafeSetBool(setupActive, period, nil);
        SafeSetFloat(begin, period, nil);
        SafeSetFloat(beginIndex, period, nil);
        vars["upper00"] = ToLine(nil);
        vars["lower00"] = ToLine(nil);
        vars["left00"] = ToLine(nil);
        vars["right00"] = ToLine(nil);
        vars["middle00"] = ToLine(nil);
        vars["upper01"] = ToLine(nil);
        vars["lower01"] = ToLine(nil);
        vars["left01"] = ToLine(nil);
        vars["right01"] = ToLine(nil);
        vars["middle01"] = ToLine(nil);
        vars["upper02"] = ToLine(nil);
        vars["lower02"] = ToLine(nil);
        vars["left02"] = ToLine(nil);
        vars["right02"] = ToLine(nil);
        vars["middle02"] = ToLine(nil);
        vars["upper03"] = ToLine(nil);
        vars["lower03"] = ToLine(nil);
        vars["left03"] = ToLine(nil);
        vars["right03"] = ToLine(nil);
        vars["middle03"] = ToLine(nil);
        vars["upper04"] = ToLine(nil);
        vars["lower04"] = ToLine(nil);
        vars["left04"] = ToLine(nil);
        vars["right04"] = ToLine(nil);
        vars["middle04"] = ToLine(nil);
        vars["upper05"] = ToLine(nil);
        vars["lower05"] = ToLine(nil);
        vars["left05"] = ToLine(nil);
        vars["right05"] = ToLine(nil);
        vars["middle05"] = ToLine(nil);
        vars["upper06"] = ToLine(nil);
        vars["lower06"] = ToLine(nil);
        vars["left06"] = ToLine(nil);
        vars["right06"] = ToLine(nil);
        vars["middle06"] = ToLine(nil);
        vars["upper07"] = ToLine(nil);
        vars["lower07"] = ToLine(nil);
        vars["left07"] = ToLine(nil);
        vars["right07"] = ToLine(nil);
        vars["middle07"] = ToLine(nil);
        vars["upper08"] = ToLine(nil);
        vars["lower08"] = ToLine(nil);
        vars["left08"] = ToLine(nil);
        vars["right08"] = ToLine(nil);
        vars["middle08"] = ToLine(nil);
        vars["upper09"] = ToLine(nil);
        vars["lower09"] = ToLine(nil);
        vars["left09"] = ToLine(nil);
        vars["right09"] = ToLine(nil);
        vars["middle09"] = ToLine(nil);
        vars["upper10"] = ToLine(nil);
        vars["lower10"] = ToLine(nil);
        vars["left10"] = ToLine(nil);
        vars["right10"] = ToLine(nil);
        vars["middle10"] = ToLine(nil);
    else
        time[period] = source:date(period) * 86400000;
        SafeSetFloat(lowestInRange, period, SafeGetFloat(lowestInRange, period - 1));
        SafeSetFloat(highestInRange, period, SafeGetFloat(highestInRange, period - 1));
        SafeSetFloat(vol, period, SafeGetFloat(vol, period - 1));
        SafeSetBool(setupActive, period, SafeGetBool(setupActive, period - 1));
        SafeSetFloat(begin, period, SafeGetFloat(begin, period - 1));
        SafeSetFloat(beginIndex, period, SafeGetFloat(beginIndex, period - 1));
    end
    if time:first() > period - 1 then return; end
    barsize = time:tick(period) - time:tick(period - 1);
    col = core.colors().Yellow;
    SafeSetFloat(sig, period, vars["adxFunc1"].GetValue(period, mode));
    SafeSetFloat(vars["threshold_stream"], period, vars["threshold"]);
    if sig:first() > period - 1 then return; end
    if vars["threshold_stream"]:first() > period - 1 then return; end
    if core.crossesUnder(sig, vars["threshold_stream"], period) then
        SafeSetBool(setupActive, period, true);
        SafeSetFloat(begin, period, time:tick(period));
        SafeSetFloat(lowestInRange, period, source.low:tick(period));
        SafeSetFloat(highestInRange, period, source.high:tick(period));
        SafeSetFloat(vol, period, source.volume:tick(period));
        SafeSetFloat(beginIndex, period, period);
        if vars["showBox"] then
            vars["upper00"] = Line:New(SafeGetFloat(begin, period), SafeGetFloat(highestInRange, period), time:tick(period), SafeGetFloat(highestInRange, period)):SetColor(vars["f_set_colorFunc3"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc4"].GetValue(period, mode)):SetWidth(vars["proLineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
            vars["lower00"] = Line:New(SafeGetFloat(begin, period), SafeGetFloat(lowestInRange, period), time:tick(period), SafeGetFloat(lowestInRange, period)):SetColor(vars["f_set_colorFunc5"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc6"].GetValue(period, mode)):SetWidth(vars["proLineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
            vars["left00"] = Line:New(SafeGetFloat(begin, period), SafeGetFloat(highestInRange, period), SafeGetFloat(begin, period), SafeGetFloat(lowestInRange, period)):SetColor(vars["f_set_colorFunc7"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc8"].GetValue(period, mode)):SetWidth(vars["proLineWidth"]):SetXLoc(SafeGetFloat(begin, period), SafeGetFloat(begin, period), "bar_time");
        end
        if vars["showMidLine"] then
            avg = SafeDivide((SafePlus(SafeGetFloat(highestInRange, period), SafeGetFloat(lowestInRange, period))), 2);
            vars["middle00"] = Line:New(SafeGetFloat(begin, period), avg, time:tick(period), avg):SetColor(vars["f_set_colorFunc9"].GetValue(period, mode)):SetExtend(((vars["extendMidLine"]) and ("right") or ("none"))):SetStyle(vars["f_set_styleFunc10"].GetValue(period, mode)):SetWidth(vars["proMidLineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
        end
    end
    if setupActive:first() > period - 1 then return; end
    if SafeGetBool(setupActive, period - 1) then
        if (vars["mode"] == "Extremes") then
            if SafeGreater(source.high:tick(period - 1), SafeGetFloat(highestInRange, period)) then
                SafeSetFloat(highestInRange, period, source.high:tick(period - 1));
            end
            if SafeLess(source.low:tick(period - 1), SafeGetFloat(lowestInRange, period)) then
                SafeSetFloat(lowestInRange, period, source.low:tick(period - 1));
            end
            Line:SetX2(vars["upper00"], time:tick(period));
            Line:SetX2(vars["lower00"], time:tick(period));
            Line:SetX2(vars["middle00"], time:tick(period));
            Line:SetY1(vars["upper00"], SafeGetFloat(highestInRange, period));
            Line:SetY1(vars["lower00"], SafeGetFloat(lowestInRange, period));
            Line:SetY1(vars["left00"], SafeGetFloat(lowestInRange, period));
            Line:SetY1(vars["middle00"], SafeDivide((SafePlus(SafeGetFloat(highestInRange, period), SafeGetFloat(lowestInRange, period))), 2));
            Line:SetY2(vars["upper00"], SafeGetFloat(highestInRange, period));
            Line:SetY2(vars["lower00"], SafeGetFloat(lowestInRange, period));
            Line:SetY2(vars["left00"], SafeGetFloat(highestInRange, period));
            Line:SetY2(vars["middle00"], SafeDivide((SafePlus(SafeGetFloat(highestInRange, period), SafeGetFloat(lowestInRange, period))), 2));
        end
    end
    SafeSetFloat(vars["threshold_stream"], period, vars["threshold"]);
    if sig:first() > period - 1 then return; end
    if vars["threshold_stream"]:first() > period - 1 then return; end
    if core.crossesOver(sig, vars["threshold_stream"], period) then
        sum = nil;
        top = nil;
        bot = nil;
        highSum = nil;
        lowSum = nil;
        range = (SafeMinus(period, SafeGetFloat(beginIndex, period)));
        local for1_from = 1;
        local for1_to = range;
        if not for1_from or not for1_to then return; end
        for i = for1_from, for1_to, 1 do
            sum = SafePlus(Nz(sum), (source.high:tick(period) + source.low:tick(period) + source.close:tick(period)) / 3);
            highSum = SafePlus(Nz(highSum), source.high:tick(period - i));
            lowSum = SafePlus(Nz(lowSum), source.low:tick(period - i));
        end
        avg = SafeDivide(sum, range);
        highAvg = SafeDivide(highSum, range);
        lowAvg = SafeDivide(lowSum, range);
        SafeSetBool(setupActive, period, false);
        Line:Delete(vars["upper00"]);
        Line:Delete(vars["lower00"]);
        Line:Delete(vars["left00"]);
        Line:Delete(vars["middle00"]);
        if vars["showBox"] then
            Line:Delete(vars["upper10"]);
            Line:Delete(vars["lower10"]);
            Line:Delete(vars["left10"]);
            Line:Delete(vars["right10"]);
            Line:Delete(vars["middle10"]);
        end
        if (vars["mode"] == "Extremes") then
            top = SafeGetFloat(highestInRange, period);
            bot = SafeGetFloat(lowestInRange, period);
        else
            top = highAvg;
            bot = lowAvg;
        end
        if vars["showBox"] then
            vars["upper10"] = vars["upper09"];
            vars["upper09"] = vars["upper08"];
            vars["upper08"] = vars["upper07"];
            vars["upper07"] = vars["upper06"];
            vars["upper06"] = vars["upper05"];
            vars["upper05"] = vars["upper04"];
            vars["upper04"] = vars["upper03"];
            vars["upper03"] = vars["upper02"];
            vars["upper02"] = vars["upper01"];
            vars["upper01"] = Line:New(SafeGetFloat(begin, period), top, time:tick(period), top):SetColor(vars["f_set_colorFunc11"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc12"].GetValue(period, mode)):SetWidth(vars["lineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
            vars["lower10"] = vars["lower09"];
            vars["lower09"] = vars["lower08"];
            vars["lower08"] = vars["lower07"];
            vars["lower07"] = vars["lower06"];
            vars["lower06"] = vars["lower05"];
            vars["lower05"] = vars["lower04"];
            vars["lower04"] = vars["lower03"];
            vars["lower03"] = vars["lower02"];
            vars["lower02"] = vars["lower01"];
            vars["lower01"] = Line:New(SafeGetFloat(begin, period), bot, time:tick(period), bot):SetColor(vars["f_set_colorFunc13"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc14"].GetValue(period, mode)):SetWidth(vars["lineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
            vars["left10"] = vars["left09"];
            vars["left09"] = vars["left08"];
            vars["left08"] = vars["left07"];
            vars["left07"] = vars["left06"];
            vars["left06"] = vars["left05"];
            vars["left05"] = vars["left04"];
            vars["left04"] = vars["left03"];
            vars["left03"] = vars["left02"];
            vars["left02"] = vars["left01"];
            vars["left01"] = Line:New(SafeGetFloat(begin, period), top, SafeGetFloat(begin, period), bot):SetColor(vars["f_set_colorFunc15"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc16"].GetValue(period, mode)):SetWidth(vars["lineWidth"]):SetXLoc(SafeGetFloat(begin, period), SafeGetFloat(begin, period), "bar_time");
            vars["right10"] = vars["right09"];
            vars["right09"] = vars["right08"];
            vars["right08"] = vars["right07"];
            vars["right07"] = vars["right06"];
            vars["right06"] = vars["right05"];
            vars["right05"] = vars["right04"];
            vars["right04"] = vars["right03"];
            vars["right03"] = vars["right02"];
            vars["right02"] = vars["right01"];
            vars["right01"] = Line:New(time:tick(period), top, time:tick(period), bot):SetColor(vars["f_set_colorFunc17"].GetValue(period, mode)):SetStyle(vars["f_set_styleFunc18"].GetValue(period, mode)):SetWidth(vars["lineWidth"]):SetXLoc(time:tick(period), time:tick(period), "bar_time");
        end
        if vars["showMidLine"] then
            vars["middle10"] = vars["middle09"];
            vars["middle09"] = vars["middle08"];
            vars["middle08"] = vars["middle07"];
            vars["middle07"] = vars["middle06"];
            vars["middle06"] = vars["middle05"];
            vars["middle05"] = vars["middle04"];
            vars["middle04"] = vars["middle03"];
            vars["middle03"] = vars["middle02"];
            vars["middle02"] = vars["middle01"];
            vars["middle01"] = Line:New(SafeGetFloat(begin, period), avg, time:tick(period), avg):SetColor(vars["f_set_colorFunc19"].GetValue(period, mode)):SetExtend(((vars["extendMidLine"]) and ("right") or ("none"))):SetStyle(vars["f_set_styleFunc20"].GetValue(period, mode)):SetWidth(vars["midLineWidth"]):SetXLoc(SafeGetFloat(begin, period), time:tick(period), "bar_time");
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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

function Change(source, period, length)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
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
function CreateFixnan()
    local fixnan = {};
    fixnan._stream = instance:addInternalStream(0, 0); 
    function fixnan:set(period, value)
        if value == nil then
            if period == 0 or not self._stream:hasData(period - 1) then
                return nil;
            end
            self._stream[period] = self._stream[period - 1];
        else
            self._stream[period] = value;
        end
        return self._stream[period];
    end
    return fixnan;
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
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
