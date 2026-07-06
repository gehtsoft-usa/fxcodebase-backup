--Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=74487
 

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
local vars = {};
function Init()
    indicator:name("Imbalance Detector [LuxAlgo]");
    indicator:description("Imbalance Detector [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Fair Value Gaps (FVG)", "", true);
    indicator.parameters:addColor("param2", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    indicator.parameters:addColor("param3", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    indicator.parameters:addBoolean("param4", "Min Width", "", false);
    indicator.parameters:addDouble("param5", "", "", 0);
    indicator.parameters:addString("param6", "", "", "Points");
    indicator.parameters:addStringAlternative("param6", "Points", "", "Points");
    indicator.parameters:addStringAlternative("param6", "%", "", "%");
    indicator.parameters:addStringAlternative("param6", "ATR", "", "ATR");
    indicator.parameters:addInteger("param7", "Extend FVG", "", 0);
    indicator.parameters:addBoolean("param8", "Show Opening Gaps (OG)", "", true);
    indicator.parameters:addColor("param9", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    indicator.parameters:addColor("param10", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    indicator.parameters:addBoolean("param11", "Min Width", "", false);
    indicator.parameters:addDouble("param12", "", "", 0);
    indicator.parameters:addString("param13", "", "", "Points");
    indicator.parameters:addStringAlternative("param13", "Points", "", "Points");
    indicator.parameters:addStringAlternative("param13", "%", "", "%");
    indicator.parameters:addStringAlternative("param13", "ATR", "", "ATR");
    indicator.parameters:addInteger("param14", "Extend OG", "", 0);
    indicator.parameters:addBoolean("param15", "Show Volume Imbalances (VI)", "", true);
    indicator.parameters:addColor("param16", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    indicator.parameters:addColor("param17", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    indicator.parameters:addBoolean("param18", "Min Width", "", false);
    indicator.parameters:addDouble("param19", "", "", 0);
    indicator.parameters:addString("param20", "", "", "Points");
    indicator.parameters:addStringAlternative("param20", "Points", "", "Points");
    indicator.parameters:addStringAlternative("param20", "%", "", "%");
    indicator.parameters:addStringAlternative("param20", "ATR", "", "ATR");
    indicator.parameters:addInteger("param21", "Extend VI", "", 5);
    indicator.parameters:addBoolean("param22", "Show Dashboard", "", true);
    indicator.parameters:addString("param23", "Dashboard Location", "", "Bottom Right");
    indicator.parameters:addStringAlternative("param23", "Top Right", "", "Top Right");
    indicator.parameters:addStringAlternative("param23", "Bottom Right", "", "Bottom Right");
    indicator.parameters:addStringAlternative("param23", "Bottom Left", "", "Bottom Left");
    indicator.parameters:addString("param24", "Dashboard Size", "", "Tiny");
    indicator.parameters:addStringAlternative("param24", "Tiny", "", "Tiny");
    indicator.parameters:addStringAlternative("param24", "Small", "", "Small");
    indicator.parameters:addStringAlternative("param24", "Normal", "", "Normal");
    signaler:Init(indicator.parameters);
end

local source;
local bull_vi;
local bull_gap_btm;
local bear_vi;
local bear_gap_top;
local bull_og;
local bear_og;
function Create_imbalance_detection(show, usewidth, method, width, top, btm, condition)
    local local_vars = {};
    is_width = instance:addInternalStream(0, 0);
    count = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                SafeSetBool(is_width, period, true);
                SafeSetFloat(count, period, 0);
            else
                SafeSetBool(is_width, period, SafeGetBool(is_width, period - 1));
                SafeSetFloat(count, period, SafeGetFloat(count, period - 1));
            end
            if usewidth then
                dist = SafeMinus(SafeGetFloat(top, period), SafeGetFloat(btm, period));
                SafeSetBool(is_width, period, (((method.Value == "Points")) and (SafeGreater(dist, width)) or ((((method.Value == "%")) and (SafeGreater(SafeMultiply(SafeDivide(dist, SafeGetFloat(btm, period)), 100), width)) or ((((method.Value == "ATR")) and (SafeGreater(dist, SafeMultiply(atr, width))) or (nil)))))));
            end
            is_true = show and SafeGetBool(condition, period) and SafeGetBool(is_width, period);
            SafeSetFloat(count, period, SafeGetFloat(count, period) + ((is_true) and (1) or (0)));
            return is_true, SafeGetFloat(count, period);
        end
    };
end
function Create_bull_filled(condition, btm)
    local local_vars = {};
    count = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["btms"] = Array:NewFloat(0, nil);
                SafeSetFloat(count, period, 0);
            else
                SafeSetFloat(count, period, SafeGetFloat(count, period - 1));
            end
            if SafeGetBool(condition, period) then
                local_vars["btms"]:Unshift(SafeGetFloat(btm, period));
            end
            size = local_vars["btms"]:Size();
            local for1_from = (((SafeGreater(size, 0)) and (SafeMinus(size, 1)) or (nil)));
            local for1_to = 0;
            if not for1_from or not for1_to then return; end
            for i = for1_from, for1_to, 1 do
                value = local_vars["btms"]:Get(i);
                if SafeLess(source.low:tick(period), value) then
                    Array:Remove(local_vars["btms"], i);
                    SafeSetFloat(count, period, SafeGetFloat(count, period) + 1);
                end
            end
            return SafeGetFloat(count, period);
        end
    };
end
function Create_bear_filled(condition, top)
    local local_vars = {};
    count = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["tops"] = Array:NewFloat(0, nil);
                SafeSetFloat(count, period, 0);
            else
                SafeSetFloat(count, period, SafeGetFloat(count, period - 1));
            end
            if SafeGetBool(condition, period) then
                local_vars["tops"]:Unshift(SafeGetFloat(top, period));
            end
            size = local_vars["tops"]:Size();
            local for2_from = (((SafeGreater(size, 0)) and (SafeMinus(size, 1)) or (nil)));
            local for2_to = 0;
            if not for2_from or not for2_to then return; end
            for i = for2_from, for2_to, 1 do
                value = local_vars["tops"]:Get(i);
                if SafeGreater(source.high:tick(period), value) then
                    Array:Remove(local_vars["tops"], i);
                    SafeSetFloat(count, period, SafeGetFloat(count, period) + 1);
                end
            end
            return SafeGetFloat(count, period);
        end
    };
end
function Create_set_cells(tb, column, bull_filled, bull_count, bear_filled, bear_count, bull_css, bear_css, __table_size)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            Table:CellText(tb.Value, column, 1, Str:ToString(SafeGetFloat(bull_count, period)));
            Table:CellTextColor(tb.Value, column, 1, bull_css);
            Table:CellTextSize(tb.Value, column, 1, __table_size.Value);
            Table:CellTextHAlign(tb.Value, column, 1, "left");
            Table:CellText(tb.Value, column, 2, Str:Format("{0,number,percent}", SafeDivide(SafeGetFloat(bull_filled, period), SafeGetFloat(bull_count, period))));
            Table:CellTextColor(tb.Value, column, 2, bull_css);
            Table:CellTextSize(tb.Value, column, 2, __table_size.Value);
            Table:CellTextHAlign(tb.Value, column, 2, "left");
            Table:CellText(tb.Value, column, 3, Str:ToString(SafeGetFloat(bear_count, period)));
            Table:CellTextColor(tb.Value, column, 3, bear_css);
            Table:CellTextSize(tb.Value, column, 3, __table_size.Value);
            Table:CellTextHAlign(tb.Value, column, 3, "left");
            Table:CellText(tb.Value, column, 4, Str:Format("{0,number,percent}", SafeDivide(SafeGetFloat(bear_filled, period), SafeGetFloat(bear_count, period))));
            Table:CellTextColor(tb.Value, column, 4, bear_css);
            Table:CellTextSize(tb.Value, column, 4, __table_size.Value);
            return Table:CellTextHAlign(tb.Value, column, 4, "left");
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
    vars["show_fvg"] = instance.parameters.param1;
    vars["bull_fvg_css"] = Graphics:AddTransparency(instance.parameters.param2, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    vars["bear_fvg_css"] = Graphics:AddTransparency(instance.parameters.param3, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    vars["fvg_usewidth"] = instance.parameters.param4;
    vars["fvg_gapwidth"] = instance.parameters.param5;
    vars["fvg_method"] = instance.parameters.param6;
    vars["fvg_extend"] = instance.parameters.param7;
    vars["show_og"] = instance.parameters.param8;
    vars["bull_og_css"] = Graphics:AddTransparency(instance.parameters.param9, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    vars["bear_og_css"] = Graphics:AddTransparency(instance.parameters.param10, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    vars["og_usewidth"] = instance.parameters.param11;
    vars["og_gapwidth"] = instance.parameters.param12;
    vars["og_method"] = instance.parameters.param13;
    vars["og_extend"] = instance.parameters.param14;
    vars["show_vi"] = instance.parameters.param15;
    vars["bull_vi_css"] = Graphics:AddTransparency(instance.parameters.param16, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(33, 87, 243), 0)));
    vars["bear_vi_css"] = Graphics:AddTransparency(instance.parameters.param17, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 17, 0), 0)));
    vars["vi_usewidth"] = instance.parameters.param18;
    vars["vi_gapwidth"] = instance.parameters.param19;
    vars["vi_method"] = instance.parameters.param20;
    vars["vi_extend"] = instance.parameters.param21;
    vars["show_dash"] = instance.parameters.param22;
    vars["dash_loc"] = instance.parameters.param23;
    vars["text_size"] = instance.parameters.param24;
    vars["ATR1"] = core.indicators:create("ATR", source, 200);
    vars["imbalance_detectionFunc1_param3"] = {};
    vars["imbalance_detectionFunc1_param5"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc1_param6"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc1_param7"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc1"] = Create_imbalance_detection(vars["show_vi"], vars["vi_usewidth"], vars["imbalance_detectionFunc1_param3"], vars["vi_gapwidth"], vars["imbalance_detectionFunc1_param5"], vars["imbalance_detectionFunc1_param6"], vars["imbalance_detectionFunc1_param7"]);
    vars["bull_filledFunc2_param1"] = instance:addInternalStream(0, 0);
    bull_vi = instance:addInternalStream(0, 0);
    vars["bull_filledFunc2_param2"] = instance:addInternalStream(0, 0);
    bull_gap_btm = instance:addInternalStream(0, 0);
    vars["bull_filledFunc2"] = Create_bull_filled(vars["bull_filledFunc2_param1"], vars["bull_filledFunc2_param2"]);
    vars["imbalance_detectionFunc3_param3"] = {};
    vars["imbalance_detectionFunc3_param5"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc3_param6"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc3_param7"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc3"] = Create_imbalance_detection(vars["show_vi"], vars["vi_usewidth"], vars["imbalance_detectionFunc3_param3"], vars["vi_gapwidth"], vars["imbalance_detectionFunc3_param5"], vars["imbalance_detectionFunc3_param6"], vars["imbalance_detectionFunc3_param7"]);
    vars["bear_filledFunc4_param1"] = instance:addInternalStream(0, 0);
    bear_vi = instance:addInternalStream(0, 0);
    vars["bear_filledFunc4_param2"] = instance:addInternalStream(0, 0);
    bear_gap_top = instance:addInternalStream(0, 0);
    vars["bear_filledFunc4"] = Create_bear_filled(vars["bear_filledFunc4_param1"], vars["bear_filledFunc4_param2"]);
    vars["imbalance_detectionFunc5_param3"] = {};
    vars["imbalance_detectionFunc5_param5"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc5_param6"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc5_param7"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc5"] = Create_imbalance_detection(vars["show_og"], vars["og_usewidth"], vars["imbalance_detectionFunc5_param3"], vars["og_gapwidth"], vars["imbalance_detectionFunc5_param5"], vars["imbalance_detectionFunc5_param6"], vars["imbalance_detectionFunc5_param7"]);
    vars["bull_filledFunc6_param1"] = instance:addInternalStream(0, 0);
    vars["bull_filledFunc6_param2"] = instance:addInternalStream(0, 0);
    vars["bull_filledFunc6"] = Create_bull_filled(vars["bull_filledFunc6_param1"], vars["bull_filledFunc6_param2"]);
    vars["imbalance_detectionFunc7_param3"] = {};
    vars["imbalance_detectionFunc7_param5"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc7_param6"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc7_param7"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc7"] = Create_imbalance_detection(vars["show_og"], vars["og_usewidth"], vars["imbalance_detectionFunc7_param3"], vars["og_gapwidth"], vars["imbalance_detectionFunc7_param5"], vars["imbalance_detectionFunc7_param6"], vars["imbalance_detectionFunc7_param7"]);
    vars["bear_filledFunc8_param1"] = instance:addInternalStream(0, 0);
    vars["bear_filledFunc8_param2"] = instance:addInternalStream(0, 0);
    vars["bear_filledFunc8"] = Create_bear_filled(vars["bear_filledFunc8_param1"], vars["bear_filledFunc8_param2"]);
    vars["imbalance_detectionFunc9_param3"] = {};
    vars["imbalance_detectionFunc9_param6"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc9_param7"] = instance:addInternalStream(0, 0);
    bull_og = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc9"] = Create_imbalance_detection(vars["show_fvg"], vars["fvg_usewidth"], vars["imbalance_detectionFunc9_param3"], vars["fvg_gapwidth"], source.low, vars["imbalance_detectionFunc9_param6"], vars["imbalance_detectionFunc9_param7"]);
    vars["bull_filledFunc10_param1"] = instance:addInternalStream(0, 0);
    vars["bull_filledFunc10_param2"] = instance:addInternalStream(0, 0);
    vars["bull_filledFunc10"] = Create_bull_filled(vars["bull_filledFunc10_param1"], vars["bull_filledFunc10_param2"]);
    vars["imbalance_detectionFunc11_param3"] = {};
    vars["imbalance_detectionFunc11_param5"] = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc11_param7"] = instance:addInternalStream(0, 0);
    bear_og = instance:addInternalStream(0, 0);
    vars["imbalance_detectionFunc11"] = Create_imbalance_detection(vars["show_fvg"], vars["fvg_usewidth"], vars["imbalance_detectionFunc11_param3"], vars["fvg_gapwidth"], vars["imbalance_detectionFunc11_param5"], source.high, vars["imbalance_detectionFunc11_param7"]);
    vars["bear_filledFunc12_param1"] = instance:addInternalStream(0, 0);
    vars["bear_filledFunc12_param2"] = instance:addInternalStream(0, 0);
    vars["bear_filledFunc12"] = Create_bear_filled(vars["bear_filledFunc12_param1"], vars["bear_filledFunc12_param2"]);
    Line:Prepare(500);
    vars["__IsFirst1"] = CreateIsFirst();
    vars["set_cellsFunc13_param1"] = {};
    vars["set_cellsFunc13_param3"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc13_param4"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc13_param5"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc13_param6"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc13_param9"] = {};
    vars["set_cellsFunc13"] = Create_set_cells(vars["set_cellsFunc13_param1"], 2, vars["set_cellsFunc13_param3"], vars["set_cellsFunc13_param4"], vars["set_cellsFunc13_param5"], vars["set_cellsFunc13_param6"], vars["bull_fvg_css"], vars["bear_fvg_css"], vars["set_cellsFunc13_param9"]);
    vars["set_cellsFunc14_param1"] = {};
    vars["set_cellsFunc14_param3"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc14_param4"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc14_param5"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc14_param6"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc14_param9"] = {};
    vars["set_cellsFunc14"] = Create_set_cells(vars["set_cellsFunc14_param1"], 3, vars["set_cellsFunc14_param3"], vars["set_cellsFunc14_param4"], vars["set_cellsFunc14_param5"], vars["set_cellsFunc14_param6"], vars["bull_og_css"], vars["bear_og_css"], vars["set_cellsFunc14_param9"]);
    vars["set_cellsFunc15_param1"] = {};
    vars["set_cellsFunc15_param3"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc15_param4"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc15_param5"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc15_param6"] = instance:addInternalStream(0, 0);
    vars["set_cellsFunc15_param9"] = {};
    vars["set_cellsFunc15"] = Create_set_cells(vars["set_cellsFunc15_param1"], 4, vars["set_cellsFunc15_param3"], vars["set_cellsFunc15_param4"], vars["set_cellsFunc15_param5"], vars["set_cellsFunc15_param6"], vars["bull_vi_css"], vars["bear_vi_css"], vars["set_cellsFunc15_param9"]);
    signaler:Prepare(nameOnly);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Box:Clear();
        Line:Clear();
        Table:Clear();
        vars["imbalance_detectionFunc1"].Clear();
        vars["bull_filledFunc2"].Clear();
        vars["imbalance_detectionFunc3"].Clear();
        vars["bear_filledFunc4"].Clear();
        vars["imbalance_detectionFunc5"].Clear();
        vars["bull_filledFunc6"].Clear();
        vars["imbalance_detectionFunc7"].Clear();
        vars["bear_filledFunc8"].Clear();
        vars["imbalance_detectionFunc9"].Clear();
        vars["bull_filledFunc10"].Clear();
        vars["imbalance_detectionFunc11"].Clear();
        vars["bear_filledFunc12"].Clear();
        Str:Clear();
        vars["table_position"] = Str:NewVar((((vars["dash_loc"] == "Bottom Left")) and ("bottom_left") or ((((vars["dash_loc"] == "Top Right")) and ("top_right") or ("bottom_right")))));
        vars["table_size"] = Str:NewVar((((vars["text_size"] == "Tiny")) and ("tiny") or ((((vars["text_size"] == "Small")) and ("small") or ("normal")))));
        vars["tb"] = nil;
        vars["set_cellsFunc13"].Clear();
        vars["set_cellsFunc14"].Clear();
        vars["set_cellsFunc15"].Clear();
    else
        SafeSetString(vars["table_position"], period, SafeGetString(vars["table_position"], period - 1));
        SafeSetString(vars["table_size"], period, SafeGetString(vars["table_size"], period - 1));
        vars["__IsFirst1"]:Clear();
    end
    n = period;
    vars["ATR1"]:update(mode);
    atr = vars["ATR1"].DATA:tick(period);
    bull_gap_top = math.min(source.close:tick(period), source.open:tick(period));
    SafeSetFloat(bull_gap_btm, period, math.max(source.close:tick(period - 1), source.open:tick(period - 1)));
    vars["imbalance_detectionFunc1_param3"].Value = vars["vi_method"];
    SafeSetFloat(vars["imbalance_detectionFunc1_param5"], period, bull_gap_top);
    SafeSetFloat(vars["imbalance_detectionFunc1_param6"], period, SafeGetFloat(bull_gap_btm, period));
    SafeSetBool(vars["imbalance_detectionFunc1_param7"], period, (source.open:tick(period) > source.close:tick(period - 1)) and (source.high:tick(period - 1) > source.low:tick(period)) and (source.close:tick(period) > source.close:tick(period - 1)) and (source.open:tick(period) > source.open:tick(period - 1)) and SafeLess(source.high:tick(period - 1), bull_gap_top));
    bull_vi_ret_val, bull_vi_count_ret_val = vars["imbalance_detectionFunc1"].GetValue(period, mode);
    SafeSetBool(bull_vi, period, bull_vi_ret_val);
    bull_vi_count = bull_vi_count_ret_val;
    if bull_vi:first() > period - 1 then return; end
    if bull_gap_btm:first() > period - 1 then return; end
    SafeSetBool(vars["bull_filledFunc2_param1"], period, SafeGetBool(bull_vi, period - 1));
    SafeSetFloat(vars["bull_filledFunc2_param2"], period, SafeGetFloat(bull_gap_btm, period - 1));
    bull_vi_filled = vars["bull_filledFunc2"].GetValue(period, mode);
    SafeSetFloat(bear_gap_top, period, math.min(source.close:tick(period - 1), source.open:tick(period - 1)));
    bear_gap_btm = math.max(source.close:tick(period), source.open:tick(period));
    vars["imbalance_detectionFunc3_param3"].Value = vars["vi_method"];
    SafeSetFloat(vars["imbalance_detectionFunc3_param5"], period, SafeGetFloat(bear_gap_top, period));
    SafeSetFloat(vars["imbalance_detectionFunc3_param6"], period, bear_gap_btm);
    SafeSetBool(vars["imbalance_detectionFunc3_param7"], period, (source.open:tick(period) < source.close:tick(period - 1)) and (source.low:tick(period - 1) < source.high:tick(period)) and (source.close:tick(period) < source.close:tick(period - 1)) and (source.open:tick(period) < source.open:tick(period - 1)) and SafeGreater(source.low:tick(period - 1), bear_gap_btm));
    bear_vi_ret_val, bear_vi_count_ret_val = vars["imbalance_detectionFunc3"].GetValue(period, mode);
    SafeSetBool(bear_vi, period, bear_vi_ret_val);
    bear_vi_count = bear_vi_count_ret_val;
    if bear_vi:first() > period - 1 then return; end
    if bear_gap_top:first() > period - 1 then return; end
    SafeSetBool(vars["bear_filledFunc4_param1"], period, SafeGetBool(bear_vi, period - 1));
    SafeSetFloat(vars["bear_filledFunc4_param2"], period, SafeGetFloat(bear_gap_top, period - 1));
    bear_vi_filled = vars["bear_filledFunc4"].GetValue(period, mode);
    if SafeGetBool(bull_vi, period) then
        Box:New(core.formatDate(source:date(n - 1)), "1", n - 1, bull_gap_top, n + vars["vi_extend"], SafeGetFloat(bull_gap_btm, period)):SetBgColor(nil):SetBorderColor(vars["bull_vi_css"]):SetBorderStyle("dotted");
    end
    if SafeGetBool(bear_vi, period) then
        Box:New(core.formatDate(source:date(n - 1)), "2", n - 1, SafeGetFloat(bear_gap_top, period), n + vars["vi_extend"], bear_gap_btm):SetBgColor(nil):SetBorderColor(vars["bear_vi_css"]):SetBorderStyle("dotted");
    end
    vars["imbalance_detectionFunc5_param3"].Value = vars["og_method"];
    SafeSetFloat(vars["imbalance_detectionFunc5_param5"], period, bull_gap_top);
    SafeSetFloat(vars["imbalance_detectionFunc5_param6"], period, SafeGetFloat(bull_gap_btm, period));
    SafeSetBool(vars["imbalance_detectionFunc5_param7"], period, (source.low:tick(period) > source.high:tick(period - 1)));
    bull_og_ret_val, bull_og_count_ret_val = vars["imbalance_detectionFunc5"].GetValue(period, mode);
    SafeSetBool(bull_og, period, bull_og_ret_val);
    bull_og_count = bull_og_count_ret_val;
    SafeSetBool(vars["bull_filledFunc6_param1"], period, SafeGetBool(bull_og, period));
    SafeSetFloat(vars["bull_filledFunc6_param2"], period, SafeGetFloat(bull_gap_btm, period));
    bull_og_filled = vars["bull_filledFunc6"].GetValue(period, mode);
    vars["imbalance_detectionFunc7_param3"].Value = vars["og_method"];
    SafeSetFloat(vars["imbalance_detectionFunc7_param5"], period, SafeGetFloat(bear_gap_top, period));
    SafeSetFloat(vars["imbalance_detectionFunc7_param6"], period, bear_gap_btm);
    SafeSetBool(vars["imbalance_detectionFunc7_param7"], period, (source.high:tick(period) < source.low:tick(period - 1)));
    bear_og_ret_val, bear_og_count_ret_val = vars["imbalance_detectionFunc7"].GetValue(period, mode);
    SafeSetBool(bear_og, period, bear_og_ret_val);
    bear_og_count = bear_og_count_ret_val;
    SafeSetBool(vars["bear_filledFunc8_param1"], period, SafeGetBool(bear_og, period));
    SafeSetFloat(vars["bear_filledFunc8_param2"], period, SafeGetFloat(bear_gap_top, period));
    bear_og_filled = vars["bear_filledFunc8"].GetValue(period, mode);
    if SafeGetBool(bull_og, period) then
        Box:New(core.formatDate(source:date(n - 1)), "3", n - 1, bull_gap_top, n + vars["og_extend"], SafeGetFloat(bull_gap_btm, period)):SetBgColor(vars["bull_og_css"] + math.floor(50 / 100 * 255) * 16777216):SetBorderColor(nil):SetText("OG"):SetTextColor(core.COLOR_LABEL);
    end
    if SafeGetBool(bear_og, period) then
        Box:New(core.formatDate(source:date(n - 1)), "4", n - 1, SafeGetFloat(bear_gap_top, period), n + vars["og_extend"], bear_gap_btm):SetBgColor(vars["bear_og_css"] + math.floor(50 / 100 * 255) * 16777216):SetBorderColor(nil):SetText("OG"):SetTextColor(core.COLOR_LABEL);
    end
    vars["imbalance_detectionFunc9_param3"].Value = vars["fvg_method"];
    if bull_og:first() > period - 1 then return; end
    SafeSetFloat(vars["imbalance_detectionFunc9_param6"], period, source.high:tick(period - 2));
    SafeSetBool(vars["imbalance_detectionFunc9_param7"], period, (source.low:tick(period) > source.high:tick(period - 2)) and (source.close:tick(period - 1) > source.high:tick(period - 2)) and not (((SafeGetBool(bull_og, period) or SafeGetBool(bull_og, period - 1)))));
    bull_fvg_ret_val, bull_fvg_count_ret_val = vars["imbalance_detectionFunc9"].GetValue(period, mode);
    bull_fvg = bull_fvg_ret_val;
    bull_fvg_count = bull_fvg_count_ret_val;
    SafeSetBool(vars["bull_filledFunc10_param1"], period, bull_fvg);
    SafeSetFloat(vars["bull_filledFunc10_param2"], period, source.high:tick(period - 2));
    bull_fvg_filled = vars["bull_filledFunc10"].GetValue(period, mode);
    vars["imbalance_detectionFunc11_param3"].Value = vars["fvg_method"];
    if bear_og:first() > period - 1 then return; end
    SafeSetFloat(vars["imbalance_detectionFunc11_param5"], period, source.low:tick(period - 2));
    SafeSetBool(vars["imbalance_detectionFunc11_param7"], period, (source.high:tick(period) < source.low:tick(period - 2)) and (source.close:tick(period - 1) < source.low:tick(period - 2)) and not (((SafeGetBool(bear_og, period) or SafeGetBool(bear_og, period - 1)))));
    bear_fvg_ret_val, bear_fvg_count_ret_val = vars["imbalance_detectionFunc11"].GetValue(period, mode);
    bear_fvg = bear_fvg_ret_val;
    bear_fvg_count = bear_fvg_count_ret_val;
    SafeSetBool(vars["bear_filledFunc12_param1"], period, bear_fvg);
    SafeSetFloat(vars["bear_filledFunc12_param2"], period, source.low:tick(period - 2));
    bear_fvg_filled = vars["bear_filledFunc12"].GetValue(period, mode);
    if bull_fvg then
        avg = (source.low:tick(period) + source.high:tick(period - 2)) / 2;
        Box:New(core.formatDate(source:date(n - 2)), "5", n - 2, source.low:tick(period), n + vars["fvg_extend"], source.high:tick(period - 2)):SetBgColor(vars["bull_fvg_css"] + math.floor(80 / 100 * 255) * 16777216):SetBorderColor(nil);
        Line:New(n - 2, avg, n + vars["fvg_extend"], avg):SetColor(vars["bull_fvg_css"]);
    end
    if bear_fvg then
        avg = (source.low:tick(period - 2) + source.high:tick(period)) / 2;
        Box:New(core.formatDate(source:date(n - 2)), "6", n - 2, source.low:tick(period - 2), n + vars["fvg_extend"], source.high:tick(period)):SetBgColor(vars["bear_fvg_css"] + math.floor(80 / 100 * 255) * 16777216):SetBorderColor(nil);
        Line:New(n - 2, avg, n + vars["fvg_extend"], avg):SetColor(vars["bear_fvg_css"]);
    end
    if vars["__IsFirst1"]:IsFirst() and vars["show_dash"] then
        vars["tb"] = Table:New("1", SafeGetString(vars["table_position"], period), 5, 7):SetBorderWidth(1):SetBgColor(Graphics:AddTransparency(core.rgb(30, 34, 45), 0)):SetBorderColor(Graphics:AddTransparency(core.rgb(55, 58, 70), 0)):SetFrameColor(Graphics:AddTransparency(core.rgb(55, 58, 70), 0)):SetFrameWidth(1);
        if vars["show_fvg"] then
            Table:CellText(vars["tb"], 2, 0, "? FVG");
            Table:CellTextColor(vars["tb"], 2, 0, core.colors().White);
            Table:CellTextSize(vars["tb"], 2, 0, SafeGetString(vars["table_size"], period));
        end
        if vars["show_og"] then
            Table:CellText(vars["tb"], 3, 0, "? OG");
            Table:CellTextColor(vars["tb"], 3, 0, core.colors().White);
            Table:CellTextSize(vars["tb"], 3, 0, SafeGetString(vars["table_size"], period));
        end
        if vars["show_vi"] then
            Table:CellText(vars["tb"], 4, 0, "? VI");
            Table:CellTextColor(vars["tb"], 4, 0, core.colors().White);
            Table:CellTextSize(vars["tb"], 4, 0, SafeGetString(vars["table_size"], period));
        end
        Table:MergeCells(vars["tb"], 0, 0, 1, 0);
        Table:CellText(vars["tb"], 0, 1, "Bullish");
        Table:CellTextColor(vars["tb"], 0, 1, Graphics:AddTransparency(core.rgb(8, 153, 129), 0));
        Table:CellTextSize(vars["tb"], 0, 1, SafeGetString(vars["table_size"], period));
        Table:CellText(vars["tb"], 1, 1, "Frequency");
        Table:CellTextColor(vars["tb"], 1, 1, Graphics:AddTransparency(core.rgb(8, 153, 129), 0));
        Table:CellTextSize(vars["tb"], 1, 1, SafeGetString(vars["table_size"], period));
        Table:CellTextHAlign(vars["tb"], 1, 1, "left");
        Table:CellText(vars["tb"], 1, 2, "Filled");
        Table:CellTextColor(vars["tb"], 1, 2, Graphics:AddTransparency(core.rgb(8, 153, 129), 0));
        Table:CellTextSize(vars["tb"], 1, 2, SafeGetString(vars["table_size"], period));
        Table:CellTextHAlign(vars["tb"], 1, 2, "left");
        Table:MergeCells(vars["tb"], 0, 1, 0, 2);
        Table:CellText(vars["tb"], 0, 3, "Bearish");
        Table:CellTextColor(vars["tb"], 0, 3, Graphics:AddTransparency(core.rgb(242, 54, 69), 0));
        Table:CellTextSize(vars["tb"], 0, 3, SafeGetString(vars["table_size"], period));
        Table:CellText(vars["tb"], 1, 3, "Frequency");
        Table:CellTextColor(vars["tb"], 1, 3, Graphics:AddTransparency(core.rgb(242, 54, 69), 0));
        Table:CellTextSize(vars["tb"], 1, 3, SafeGetString(vars["table_size"], period));
        Table:CellTextHAlign(vars["tb"], 1, 3, "left");
        Table:CellText(vars["tb"], 1, 4, "Filled");
        Table:CellTextColor(vars["tb"], 1, 4, Graphics:AddTransparency(core.rgb(242, 54, 69), 0));
        Table:CellTextSize(vars["tb"], 1, 4, SafeGetString(vars["table_size"], period));
        Table:CellTextHAlign(vars["tb"], 1, 4, "left");
        Table:MergeCells(vars["tb"], 0, 3, 0, 4);
    end
    if period == source:size() - 1 and vars["show_dash"] then
        if vars["show_fvg"] then
            vars["set_cellsFunc13_param1"].Value = vars["tb"];
            vars["set_cellsFunc13_param9"].Value = SafeGetString(vars["table_size"], period);
            SafeSetFloat(vars["set_cellsFunc13_param3"], period, bull_fvg_filled);
            SafeSetFloat(vars["set_cellsFunc13_param4"], period, bull_fvg_count);
            SafeSetFloat(vars["set_cellsFunc13_param5"], period, bear_fvg_filled);
            SafeSetFloat(vars["set_cellsFunc13_param6"], period, bear_fvg_count);
            vars["set_cellsFunc13"].GetValue(period, mode);
        end
        if vars["show_og"] then
            vars["set_cellsFunc14_param1"].Value = vars["tb"];
            vars["set_cellsFunc14_param9"].Value = SafeGetString(vars["table_size"], period);
            SafeSetFloat(vars["set_cellsFunc14_param3"], period, bull_og_filled);
            SafeSetFloat(vars["set_cellsFunc14_param4"], period, bull_og_count);
            SafeSetFloat(vars["set_cellsFunc14_param5"], period, bear_og_filled);
            SafeSetFloat(vars["set_cellsFunc14_param6"], period, bear_og_count);
            vars["set_cellsFunc14"].GetValue(period, mode);
        end
        if vars["show_vi"] then
            vars["set_cellsFunc15_param1"].Value = vars["tb"];
            vars["set_cellsFunc15_param9"].Value = SafeGetString(vars["table_size"], period);
            SafeSetFloat(vars["set_cellsFunc15_param3"], period, bull_vi_filled);
            SafeSetFloat(vars["set_cellsFunc15_param4"], period, bull_vi_count);
            SafeSetFloat(vars["set_cellsFunc15_param5"], period, bear_vi_filled);
            SafeSetFloat(vars["set_cellsFunc15_param6"], period, bear_vi_count);
            vars["set_cellsFunc15"].GetValue(period, mode);
        end
    end
    if bull_fvg and period == source:size() - 1 then
        signaler:SignalEx("Bullish FVG detected", period, source);
    end
    if bear_fvg and period == source:size() - 1 then
        signaler:SignalEx("Bearish FVG detected", period, source);
    end
    if SafeGetBool(bull_og, period) and period == source:size() - 1 then
        signaler:SignalEx("Bullish OG detected", period, source);
    end
    if SafeGetBool(bear_og, period) and period == source:size() - 1 then
        signaler:SignalEx("Bearish OG detected", period, source);
    end
    if SafeGetBool(bull_vi, period) and period == source:size() - 1 then
        signaler:SignalEx("Bullish VI detected", period, source);
    end
    if SafeGetBool(bear_vi, period) and period == source:size() - 1 then
        signaler:SignalEx("Bearish VI detected", period, source);
    end
end
function Draw(stage, context)
    Box:Draw(stage, context);
    Line:Draw(stage, context);
    Table:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
end
Graphics = {};
Graphics.NextId = 2;
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

Array = {};
function Array:Enum(array)
    if array == nil then
        return {};
    end
    return array.arr;
end
function Array:Clear(array)
    if array == nil then
        return;
    end
    array:Clear();
end
function Array:Remove(array, index)
    if array == nil then
        return;
    end
    return array:Remove(index);
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
function Array:Pop(array)
    if array == nil then
        return nil;
    end
    return array:Pop();
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
    newArray.size = size;
    for i = 1, size, 1 do
        newArray.arr[i] = initialValue;
    end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; end
    function newArray:Get(index) return self.arr[index + 1]; end
    function newArray:Set(index, value) self.arr[index + 1] = value; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return self.size; end
    function newArray:Clear()
        self.arr = {};
        self.size = 0;
    end
    function newArray:Pop()
        local lastVal = self.arr[self.size];
        table.remove(self.arr, self.size);
        self.size = self.size - 1;
        return lastVal;
    end
    function newArray:Fill(value, from, to)
        if to == nil then
            to = self.size - 1;
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
        for i = 1, self.size, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[self.size + 1] = nextValue;
        self.size = self.size + 1;
    end
    function newArray:Shift()
        local value = self.arr[1];
        table.remove(self.arr, 1);
        self.size = self.size - 1;
        return value;
    end
    function newArray:Remove(index)
        local value = self.arr[index];
        table.remove(self.arr, index);
        self.size = self.size - 1;
        return value;
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
function Array:NewBox(size, initialValue)
    return Array:NewArray(size, initialValue);
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function Box:SetRight(box, right)
    if box == nil then
        return;
    end
    box:SetRight(right);
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
    if pattern == nil then
        return tostring(value);
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
Table = {};
Table.AllTables = {};
function Table:Clear()
    Table.AllTables = {};
end
function Table:MergeCells(table, start_column, start_row, end_column, end_row)
    if table == nil then
        return;
    end
    table:MergeCells(start_column, start_row, end_column, end_row);
end
function Table:CellText(table, column, row, text)
    if table == nil then
        return;
    end
    table:CellText(column, row, text)
end
function Table:CellTextColor(table, column, row, color)
    if table == nil then
        return;
    end
    table:CellTextColor(column, row, color)
end
function Table:CellTextSize(table, column, row, size)
    if table == nil then
        return;
    end
    table:CellTextSize(column, row, size)
end
function Table:CellTextHAlign(table, column, row, halign)
    if table == nil then
        return;
    end
    table:CellTextHAlign(column, row, halign)
end
function Table:New(id, position, columns, rows)
    local newTable = {};
    newTable.position = position;
    newTable.border_width = 1;
    function newTable:SetBorderWidth(width)
        self.border_width = width;
        return self;
    end
    newTable.bgcolor = nil;
    function newTable:SetBgColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.bgcolor = clr;
        self.bgcolor_transparency = transp;
        return self;
    end
    newTable.border_color = core.colors().Gray;
    newTable.border_style = core.LINE_SOLID;
    function newTable:SetBorderColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.border_color = clr;
        self.border_color_transparency = transp;
        return self;
    end
    newTable.frame_color = core.colors().Gray;
    function newTable:SetFrameColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.frame_color = clr;
        self.frame_color_transparency = transp;
        return self;
    end
    newTable.frame_width = 1;
    function newTable:SetFrameWidth(width)
        self.frame_width = width;
        return self;
    end
    newTable.rows = {};
    for i = 1, rows, 1 do
        newTable.rows[i] = {};
        for ii = 1, columns, 1 do
            local cell = {};
            cell.text = "";
            cell.text_color = core.COLOR_LABEL;
            cell.text_halign = "middle";
            cell.text_size = "normal";
            cell.cache = {};
            newTable.rows[i][ii] = cell;
        end
    end
    function newTable:CellText(column, row, text)
        if self.rows[row + 1][column + 1].text ~= text then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text = text;
        return self;
    end
    function newTable:CellTextColor(column, row, color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.rows[row + 1][column + 1].text_color = clr;
        return self;
    end
    function newTable:CellTextSize(column, row, size)
        if self.rows[row + 1][column + 1].text_size ~= size then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_size = size;
        return self;
    end
    function newTable:CellTextHAlign(column, row, halign)
        if self.rows[row + 1][column + 1].text_halign ~= halign then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_halign = halign;
        return self;
    end
    function newTable:MergeCells(start_column, start_row, end_column, end_row)
        for columnIndex = start_column + 1, end_column + 1 do
            for rowIndex = start_row + 1, end_row + 1 do
                if columnIndex ~= start_column + 1 or rowIndex ~= start_row + 1 then
                    self.rows[rowIndex][columnIndex].skip = true;
                else
                    self.rows[rowIndex][columnIndex].skip = nil;
                    self.rows[rowIndex][columnIndex].till_row = end_row + 1;
                    self.rows[rowIndex][columnIndex].till_column = end_column + 1;
                end
            end
        end
        return self;
    end
    function newTable:getRowDirection()
        if self.position == "top_left" or self.position == "top_right" or self.position == "top_middle" then
            return 1;
        end
        if self.position == "bottom_left" or self.position == "bottom_right" or self.position == "bottom_middle" then
            return -1;
        end
        return 0;
    end
    function newTable:getColumnDirection()
        if self.position == "top_left" or self.position == "bottom_left" or self.position == "middle_left" then
            return 1;
        end
        if self.position == "top_right" or self.position == "bottom_right" or self.position == "middle_right" then
            return -1;
        end
        return 0;
    end
    function newTable:measureCells(context)
        local columnWidths = {};
        local rowHeights = {};
        local total_height = 0;
        local total_width = 0;
        for row = 1, #self.rows do
            for column = 1, #self.rows[row] do
                local W, H;
                if self.rows[row][column].cache.W ~= nil then
                    W = self.rows[row][column].cache.W;
                    H = self.rows[row][column].cache.H;
                else
                    if self.rows[row][column].text ~= nil then
                        W, H = context:measureText(Table.FontId, self.rows[row][column].text, context.LEFT);
                    else
                        W, H = 0, 0;
                    end
                    self.rows[row][column].cache.W = W;
                    self.rows[row][column].cache.H = H;
                end
                if columnWidths[column] == nil or columnWidths[column] < W then
                    columnWidths[column] = W;
                end
                if rowHeights[row] == nil or rowHeights[row] < H then
                    rowHeights[row] = H;
                end
            end
            total_height = total_height + rowHeights[row];
        end
        for i = 1, #columnWidths do
            total_width = total_width + columnWidths[i];
        end
        return rowHeights, columnWidths, total_height, total_width;
    end
    function newTable:getCellWidth(row, column, columnWidths)
        local w = columnWidths[column];
        local shift = 0;
        if self.rows[row][column].till_column ~= nil and self.rows[row][column].till_column ~= column then
            for i = column + 1, self.rows[row][column].till_column do
                w = w + columnWidths[i];
                shift = shift + columnWidths[i];
            end
        end
        return w, shift;
    end
    function newTable:getCellHeight(row, column, rowHeights)
        local h = rowHeights[row];
        local shift = 0;
        if self.rows[row][column].till_row ~= nil and self.rows[row][column].till_row ~= row then
            for i = row + 1, self.rows[row][column].till_row do
                h = h + rowHeights[i];
                shift = shift + rowHeights[i];
            end
        end
        return h, shift;
    end
    function newTable:getLabelXCoordinates(rectangle_x1, rectangle_x2, width, align)
        local x = (rectangle_x1 + rectangle_x2) / 2;
        if align == "left" then
            local text_x1 = rectangle_x1;
            local text_x2 = text_x1 + width;
            return text_x1, text_x2;
        elseif align == "right" then
            local text_x2 = rectangle_x2;
            local text_x1 = text_x2 - width;
            return text_x1, text_x2;
        end
        local text_x1 = x - width / 2;
        local text_x2 = text_x1 + width;
        return text_x1, text_x2;
    end
    function newTable:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart)
        local rectangle_x1;
        local rectangle_x2;
        local rectangle_y1;
        local rectangle_y2;
        local width, w_shift = self:getCellWidth(row, column, columnWidths);
        local height, h_shift = self:getCellHeight(row, column, rowHeights);
        rectangle_y1 = yStart;
        rectangle_y2 = yStart + height;
        rectangle_x1 = xStart;
        rectangle_x2 = xStart + width;
        local text_x1, text_x2 = self:getLabelXCoordinates(rectangle_x1, rectangle_x2, self.rows[row][column].cache.W,
            self.rows[row][column].text_halign);
        local y = (rectangle_y1 + rectangle_y2) / 2;
        local text_y1 = y - self.rows[row][column].cache.H / 2;
        local text_y2 = y + self.rows[row][column].cache.H;
        if self.BgBrushId ~= nil then
            context:drawRectangle(self.FramePenId, self.BgBrushId, rectangle_x1, rectangle_y1, rectangle_x2, rectangle_y2, self.bgcolor_transparency)
        end
        context:drawText(Table.FontId, self.rows[row][column].text, self.rows[row][column].text_color, -1, 
            text_x1, text_y1, text_x2, text_y2, 0);
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil then
            self.FramePenId = Graphics:FindPen(self.border_width, self.border_color, self.border_style, context);
        end
        local rowHeights, columnWidths, total_height, total_width = self:measureCells(context);
        
        local rowDirection = self:getRowDirection();
        local columnDirection = self:getColumnDirection();
        local yStart = rowDirection == 1 and context:top() or context:bottom() - total_height;
        local totalRows = #self.rows;
        for rowIt = 1, totalRows do
            local row = rowIt;
            local xStart = columnDirection == 1 and context:left() or (context:right() - total_width); 
            local totalCoumns = #self.rows[rowIt];
            for columnIt = 1, totalCoumns do
                local column = columnIt;
                if not self.rows[row][column].skip then
                    self:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart);
                end
                xStart = xStart + columnWidths[column];
            end
            yStart = yStart + rowHeights[row];
        end
    end
    self.AllTables[id] = newTable;
    return newTable;
end
function Table:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Table.FontId == nil then
        Table.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, table in pairs(self.AllTables) do
        table:Draw(stage, context);
    end
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
function signaler:SignalEx(message, period, source)
    source = self:getSource(getSource);
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
    source = self:getSource(getSource);
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