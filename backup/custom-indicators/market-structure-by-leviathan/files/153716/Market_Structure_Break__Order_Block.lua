-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74418

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
    indicator:name("Market Structure Break & Order Block");
    indicator:description("Market Structure Break & Order Block");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "ZigZag Length", "", 9);
    indicator.parameters:addBoolean("param2", "Show Zigzag", "", true);
    indicator.parameters:addDouble("param3", "Fib Factor for breakout confirmation", "", 0.33, 0, 1);
    indicator.parameters:addString("param4", "Text Size", "", "tiny");
    indicator.parameters:addStringAlternative("param4", "tiny", "", "tiny");
    indicator.parameters:addStringAlternative("param4", "small", "", "small");
    indicator.parameters:addStringAlternative("param4", "normal", "", "normal");
    indicator.parameters:addStringAlternative("param4", "large", "", "large");
    indicator.parameters:addStringAlternative("param4", "huge", "", "huge");
    indicator.parameters:addBoolean("param5", "Delete Old/Broken Boxes", "", true);
    indicator.parameters:addColor("param6", "Color", "", Graphics:GetColor(core.colors().Green + math.floor(70 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param7", "Border Color", "", core.colors().Green);
    indicator.parameters:addColor("param8", "Text Color", "", core.colors().Green);
    indicator.parameters:addColor("param9", "Color", "", Graphics:GetColor(core.colors().Red + math.floor(70 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param10", "Border Color", "", core.colors().Red);
    indicator.parameters:addColor("param11", "Text Color", "", core.colors().Red);
    indicator.parameters:addColor("param12", "Color", "", Graphics:GetColor(core.colors().Green + math.floor(70 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param13", "Border Color", "", core.colors().Green);
    indicator.parameters:addColor("param14", "Text Color", "", core.colors().Green);
    indicator.parameters:addColor("param15", "Color", "", Graphics:GetColor(core.colors().Red + math.floor(70 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param16", "Border Color", "", core.colors().Red);
    indicator.parameters:addColor("param17", "Text Color", "", core.colors().Red);
    signaler:Init(indicator.parameters);
end

local source;
local vars = {};
local trend;
local to_up;
local to_down;
local market;
local bu_ob_index;
local l0i;
local be_ob_index;
local h0i;
local be_bb_index;
local bu_bb_index;
function Create_f_get_high(ind)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            return vars["high_points_arr"]:Get(SafeMinus(SafeMinus(vars["high_points_arr"]:Size(), 1), ind)), vars["high_index_arr"]:Get(SafeMinus(SafeMinus(vars["high_index_arr"]:Size(), 1), ind));
        end
    };
end
function Create_f_get_low(ind)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            return vars["low_points_arr"]:Get(SafeMinus(SafeMinus(vars["low_points_arr"]:Size(), 1), ind)), vars["low_index_arr"]:Get(SafeMinus(SafeMinus(vars["low_index_arr"]:Size(), 1), ind));
        end
    };
end
function Create_f_delete_box(box_arr)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            if vars["delete_boxes"] then
                Box:Delete(box_arr.Value:Shift());
            else
                box_arr.Value:Shift();
            end
            return 0;
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
    vars["settings"] = "Settings";
    vars["bu_ob_inline_color"] = "Bu-OB Colors";
    vars["be_ob_inline_color"] = "Be-OB Colors";
    vars["bu_bb_inline_color"] = "Bu-BB Colors";
    vars["be_bb_inline_color"] = "Be-BB Colors";
    vars["bu_ob_display_settings"] = "Bu-OB Display Settings";
    vars["be_ob_display_settings"] = "Be-OB Display Settings";
    vars["bu_bb_display_settings"] = "Bu-BB & Bu-MB Display Settings";
    vars["be_bb_display_settings"] = "Be-BB & Be-MB Display Settings";
    vars["zigzag_len"] = instance.parameters.param1;
    vars["show_zigzag"] = instance.parameters.param2;
    vars["fib_factor"] = instance.parameters.param3;
    vars["text_size"] = instance.parameters.param4;
    vars["delete_boxes"] = instance.parameters.param5;
    vars["bu_ob_color"] = Graphics:AddTransparency(instance.parameters.param6, Graphics:GetTransparencyPercent(core.colors().Green + math.floor(70 / 100 * 255) * 16777216));
    vars["bu_ob_border_color"] = instance.parameters.param7;
    vars["bu_ob_text_color"] = instance.parameters.param8;
    vars["be_ob_color"] = Graphics:AddTransparency(instance.parameters.param9, Graphics:GetTransparencyPercent(core.colors().Red + math.floor(70 / 100 * 255) * 16777216));
    vars["be_ob_border_color"] = instance.parameters.param10;
    vars["be_ob_text_color"] = instance.parameters.param11;
    vars["bu_bb_color"] = Graphics:AddTransparency(instance.parameters.param12, Graphics:GetTransparencyPercent(core.colors().Green + math.floor(70 / 100 * 255) * 16777216));
    vars["bu_bb_border_color"] = instance.parameters.param13;
    vars["bu_bb_text_color"] = instance.parameters.param14;
    vars["be_bb_color"] = Graphics:AddTransparency(instance.parameters.param15, Graphics:GetTransparencyPercent(core.colors().Red + math.floor(70 / 100 * 255) * 16777216));
    vars["be_bb_border_color"] = instance.parameters.param16;
    vars["be_bb_text_color"] = instance.parameters.param17;
    trend = instance:addInternalStream(0, 0);
    vars["__barssince1"] = CreateBarsSince();
    to_up = instance:addInternalStream(0, 0);
    vars["__barssince2"] = CreateBarsSince();
    vars["__barssince3"] = CreateBarsSince();
    to_down = instance:addInternalStream(0, 0);
    vars["__barssince4"] = CreateBarsSince();
    vars["f_get_highFunc1"] = Create_f_get_high(0);
    vars["f_get_highFunc2"] = Create_f_get_high(1);
    vars["f_get_lowFunc3"] = Create_f_get_low(0);
    vars["f_get_lowFunc4"] = Create_f_get_low(1);
    Line:Prepare(500);
    market = instance:addInternalStream(0, 0);
    vars["__valuewhen1"] = CreateValueWhen();
    vars["__valuewhen2"] = CreateValueWhen();
    bu_ob_index = instance:addInternalStream(0, 0);
    l0i = instance:addInternalStream(0, 0);
    be_ob_index = instance:addInternalStream(0, 0);
    h0i = instance:addInternalStream(0, 0);
    be_bb_index = instance:addInternalStream(0, 0);
    bu_bb_index = instance:addInternalStream(0, 0);
    Label:Prepare(50);
    vars["f_delete_boxFunc5_param1"] = {};
    vars["f_delete_boxFunc5"] = Create_f_delete_box(vars["f_delete_boxFunc5_param1"]);
    signaler:Prepare(nameOnly);
    vars["f_delete_boxFunc6_param1"] = {};
    vars["f_delete_boxFunc6"] = Create_f_delete_box(vars["f_delete_boxFunc6_param1"]);
    vars["f_delete_boxFunc7_param1"] = {};
    vars["f_delete_boxFunc7"] = Create_f_delete_box(vars["f_delete_boxFunc7_param1"]);
    vars["f_delete_boxFunc8_param1"] = {};
    vars["f_delete_boxFunc8"] = Create_f_delete_box(vars["f_delete_boxFunc8_param1"]);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Box:Clear();
        vars["high_points_arr"] = Array:NewFloat(5, nil);
        vars["high_index_arr"] = Array:NewInt(5, nil);
        vars["low_points_arr"] = Array:NewFloat(5, nil);
        vars["low_index_arr"] = Array:NewInt(5, nil);
        vars["bu_ob_boxes"] = Array:NewBox(5, nil);
        vars["be_ob_boxes"] = Array:NewBox(5, nil);
        vars["bu_bb_boxes"] = Array:NewBox(5, nil);
        vars["be_bb_boxes"] = Array:NewBox(5, nil);
    else
    end
    if source.high:first() > period - vars["zigzag_len"] then return; end
    SafeSetBool(to_up, period, SafeGE(source.high:tick(period), mathex.max(source.high, core.rangeTo(period, vars["zigzag_len"]))));
    if source.low:first() > period - vars["zigzag_len"] then return; end
    SafeSetBool(to_down, period, SafeLE(source.low:tick(period), mathex.min(source.low, core.rangeTo(period, vars["zigzag_len"]))));
    SafeSetFloat(trend, period, 1);
    if trend:first() > period - 1 then return; end
    SafeSetFloat(trend, period, Nz(SafeGetFloat(trend, period - 1), 1));
    SafeSetFloat(trend, period, (((SafeGetFloat(trend, period) == 1) and SafeGetBool(to_down, period)) and ((-1)) or ((((SafeGetFloat(trend, period) == (-1)) and SafeGetBool(to_up, period)) and (1) or (SafeGetFloat(trend, period))))));
    if to_up:first() > period - 1 then return; end
    last_trend_up_since = vars["__barssince1"]:set(period, SafeGetBool(to_up, period - 1));
    if source.low:first() > period - Nz(((SafeGreater(last_trend_up_since, 0)) and (last_trend_up_since) or (1)), 1) then return; end
    low_val = mathex.min(source.low, core.rangeTo(period, Nz(((SafeGreater(last_trend_up_since, 0)) and (last_trend_up_since) or (1)), 1)));
    low_index = SafeMinus(period, vars["__barssince2"]:set(period, (low_val == source.low:tick(period))));
    if to_down:first() > period - 1 then return; end
    last_trend_down_since = vars["__barssince3"]:set(period, SafeGetBool(to_down, period - 1));
    if source.high:first() > period - Nz(((SafeGreater(last_trend_down_since, 0)) and (last_trend_down_since) or (1)), 1) then return; end
    high_val = mathex.max(source.high, core.rangeTo(period, Nz(((SafeGreater(last_trend_down_since, 0)) and (last_trend_down_since) or (1)), 1)));
    high_index = SafeMinus(period, vars["__barssince4"]:set(period, (high_val == source.high:tick(period))));
    if (Change(trend, period, 1) ~= 0) then
        if (SafeGetFloat(trend, period) == 1) then
            vars["low_points_arr"]:Push(low_val);
            vars["low_index_arr"]:Push(low_index);
        end
        if (SafeGetFloat(trend, period) == (-1)) then
            vars["high_points_arr"]:Push(high_val);
            vars["high_index_arr"]:Push(high_index);
        end
    end
    h0_ret_val, h0i_ret_val = vars["f_get_highFunc1"].GetValue(period, mode);
    h0 = h0_ret_val;
    SafeSetFloat(h0i, period, h0i_ret_val);
    h1_ret_val, h1i_ret_val = vars["f_get_highFunc2"].GetValue(period, mode);
    h1 = h1_ret_val;
    h1i = h1i_ret_val;
    l0_ret_val, l0i_ret_val = vars["f_get_lowFunc3"].GetValue(period, mode);
    l0 = l0_ret_val;
    SafeSetFloat(l0i, period, l0i_ret_val);
    l1_ret_val, l1i_ret_val = vars["f_get_lowFunc4"].GetValue(period, mode);
    l1 = l1_ret_val;
    l1i = l1i_ret_val;
    if (Change(trend, period, 1) ~= 0) and vars["show_zigzag"] then
        if (SafeGetFloat(trend, period) == 1) then
            Line:New(SafeGetFloat(h0i, period), h0, SafeGetFloat(l0i, period), l0);
        end
        if (SafeGetFloat(trend, period) == (-1)) then
            Line:New(SafeGetFloat(l0i, period), l0, SafeGetFloat(h0i, period), h0);
        end
    end
    SafeSetFloat(market, period, 1);
    if market:first() > period - 1 then return; end
    SafeSetFloat(market, period, Nz(SafeGetFloat(market, period - 1), 1));
    last_l0 = vars["__valuewhen1"]:set(period, (Change(market, period, 1) ~= 0), l0, 0);
    last_h0 = vars["__valuewhen2"]:set(period, (Change(market, period, 1) ~= 0), h0, 0);
    SafeSetFloat(market, period, ((((last_l0 == l0) or (last_h0 == h0))) and (SafeGetFloat(market, period)) or ((((SafeGetFloat(market, period) == 1) and SafeLess(l0, l1) and SafeLess(l0, SafeMinus(l1, SafeMultiply(math.abs(SafeMinus(h0, l1)), vars["fib_factor"])))) and ((-1)) or ((((SafeGetFloat(market, period) == (-1)) and SafeGreater(h0, h1) and SafeGreater(h0, SafePlus(h1, SafeMultiply(math.abs(SafeMinus(h1, l0)), vars["fib_factor"])))) and (1) or (SafeGetFloat(market, period))))))));
    SafeSetFloat(bu_ob_index, period, period);
    if bu_ob_index:first() > period - 1 then return; end
    SafeSetFloat(bu_ob_index, period, Nz(SafeGetFloat(bu_ob_index, period - 1), period));
    if l0i:first() > period - vars["zigzag_len"] then return; end
    local for1_from = h1i;
    local for1_to = SafeGetFloat(l0i, period - vars["zigzag_len"]);
    if not for1_from or not for1_to then return; end
    for i = for1_from, for1_to, 1 do
        index = period - i;
        if (source.open:tick(period - index) > source.close:tick(period - index)) then
            SafeSetFloat(bu_ob_index, period, period - index);
        end
    end
    bu_ob_since = period - SafeGetFloat(bu_ob_index, period);
    SafeSetFloat(be_ob_index, period, period);
    if be_ob_index:first() > period - 1 then return; end
    SafeSetFloat(be_ob_index, period, Nz(SafeGetFloat(be_ob_index, period - 1), period));
    if h0i:first() > period - vars["zigzag_len"] then return; end
    local for2_from = l1i;
    local for2_to = SafeGetFloat(h0i, period - vars["zigzag_len"]);
    if not for2_from or not for2_to then return; end
    for i = for2_from, for2_to, 1 do
        index = period - i;
        if (source.open:tick(period - index) < source.close:tick(period - index)) then
            SafeSetFloat(be_ob_index, period, period - index);
        end
    end
    be_ob_since = period - SafeGetFloat(be_ob_index, period);
    SafeSetFloat(be_bb_index, period, period);
    if be_bb_index:first() > period - 1 then return; end
    SafeSetFloat(be_bb_index, period, Nz(SafeGetFloat(be_bb_index, period - 1), period));
    local for3_from = SafeMinus(h1i, vars["zigzag_len"]);
    local for3_to = l1i;
    if not for3_from or not for3_to then return; end
    for i = for3_from, for3_to, 1 do
        index = period - i;
        if (source.open:tick(period - index) > source.close:tick(period - index)) then
            SafeSetFloat(be_bb_index, period, period - index);
        end
    end
    be_bb_since = period - SafeGetFloat(be_bb_index, period);
    SafeSetFloat(bu_bb_index, period, period);
    if bu_bb_index:first() > period - 1 then return; end
    SafeSetFloat(bu_bb_index, period, Nz(SafeGetFloat(bu_bb_index, period - 1), period));
    local for4_from = SafeMinus(l1i, vars["zigzag_len"]);
    local for4_to = h1i;
    if not for4_from or not for4_to then return; end
    for i = for4_from, for4_to, 1 do
        index = period - i;
        if (source.open:tick(period - index) < source.close:tick(period - index)) then
            SafeSetFloat(bu_bb_index, period, period - index);
        end
    end
    bu_bb_since = period - SafeGetFloat(bu_bb_index, period);
    if (Change(market, period, 1) ~= 0) then
        if (SafeGetFloat(market, period) == 1) then
            Line:New(h1i, h1, SafeGetFloat(h0i, period), h1):SetColor(core.colors().Green):SetWidth(2);
            label_1_x = Int(SafeDivide((SafePlus(h1i, SafeGetFloat(l0i, period))), 2));
            Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, h1):SetText("MSB"):SetColor(core.colors().Black + math.floor(100 / 100 * 255) * 16777216):SetTextColor(core.colors().Green):SetStyle("down");
            bu_ob = Box:New(core.formatDate(source:date(SafeGetFloat(bu_ob_index, period))), "1", SafeGetFloat(bu_ob_index, period), source.high:tick(period - bu_ob_since), period + 10, source.low:tick(period - bu_ob_since)):SetBgColor(vars["bu_ob_color"]):SetBorderColor(vars["bu_ob_border_color"]):SetText("Bu-OB"):SetTextColor(vars["bu_ob_text_color"]):SetTextHAlign("right"):SetTextSize(vars["text_size"]);
            bu_bb = Box:New(core.formatDate(source:date(SafeGetFloat(bu_bb_index, period))), "2", SafeGetFloat(bu_bb_index, period), source.high:tick(period - bu_bb_since), period + 10, source.low:tick(period - bu_bb_since)):SetBgColor(vars["bu_bb_color"]):SetBorderColor(vars["bu_bb_border_color"]):SetText(((SafeLess(l0, l1)) and ("Bu-BB") or ("Bu-MB"))):SetTextColor(vars["bu_bb_text_color"]):SetTextHAlign("right"):SetTextSize(vars["text_size"]);
            vars["bu_ob_boxes"]:Push(bu_ob);
            vars["bu_bb_boxes"]:Push(bu_bb);
        end
        if (SafeGetFloat(market, period) == (-1)) then
            Line:New(l1i, l1, SafeGetFloat(l0i, period), l1):SetColor(core.colors().Red):SetWidth(2);
            label_2_x = Int(SafeDivide((SafePlus(l1i, SafeGetFloat(h0i, period))), 2));
            Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, l1):SetText("MSB"):SetColor(core.colors().Black + math.floor(100 / 100 * 255) * 16777216):SetTextColor(core.colors().Red):SetStyle("up");
            be_ob = Box:New(core.formatDate(source:date(SafeGetFloat(be_ob_index, period))), "3", SafeGetFloat(be_ob_index, period), source.high:tick(period - be_ob_since), period + 10, source.low:tick(period - be_ob_since)):SetBgColor(vars["be_ob_color"]):SetBorderColor(vars["be_ob_border_color"]):SetText("Be-OB"):SetTextColor(vars["be_ob_text_color"]):SetTextHAlign("right"):SetTextSize(vars["text_size"]);
            be_bb = Box:New(core.formatDate(source:date(SafeGetFloat(be_bb_index, period))), "4", SafeGetFloat(be_bb_index, period), source.high:tick(period - be_bb_since), period + 10, source.low:tick(period - be_bb_since)):SetBgColor(vars["be_bb_color"]):SetBorderColor(vars["be_bb_border_color"]):SetText(((SafeGreater(h0, h1)) and ("Be-BB") or ("Be-MB"))):SetTextColor(vars["be_bb_text_color"]):SetTextHAlign("right"):SetTextSize(vars["text_size"]);
            vars["be_ob_boxes"]:Push(be_ob);
            vars["be_bb_boxes"]:Push(be_bb);
        end
    end
    for _, bull_ob in ipairs(Array:Enum(vars["bu_ob_boxes"])) do
        bottom = Box:GetBottom(bull_ob);
        top = Box:GetTop(bull_ob);
        if SafeLess(source.close:tick(period), bottom) then
            vars["f_delete_boxFunc5_param1"].Value = vars["bu_ob_boxes"];
            vars["f_delete_boxFunc5"].GetValue(period, mode);
        elseif SafeLess(source.close:tick(period), top) then
            if "once_per_bar" == "all" or vars["alert1_last_date"] ~= source:date(period) then
                vars["alert1_last_date"] = source:date(period);
                signaler:Signal("Price in the BU-OB zone");
            end
        else
            bull_ob:SetRight(period + 10);
        end
    end
    for _, bear_ob in ipairs(Array:Enum(vars["be_ob_boxes"])) do
        top = Box:GetTop(bear_ob);
        bottom = Box:GetBottom((bear_ob));
        if SafeGreater(source.close:tick(period), top) then
            vars["f_delete_boxFunc6_param1"].Value = vars["be_ob_boxes"];
            vars["f_delete_boxFunc6"].GetValue(period, mode);
        end
        if SafeGreater(source.close:tick(period), bottom) then
            if "once_per_bar" == "all" or vars["alert2_last_date"] ~= source:date(period) then
                vars["alert2_last_date"] = source:date(period);
                signaler:Signal("Price in the BE-OB zone");
            end
        else
            bear_ob:SetRight(period + 10);
        end
    end
    for _, bear_bb in ipairs(Array:Enum(vars["be_bb_boxes"])) do
        top = Box:GetTop(bear_bb);
        bottom = Box:GetBottom(bear_bb);
        if SafeGreater(source.close:tick(period), top) then
            vars["f_delete_boxFunc7_param1"].Value = vars["be_bb_boxes"];
            vars["f_delete_boxFunc7"].GetValue(period, mode);
        elseif SafeGreater(source.close:tick(period), bottom) then
            if "once_per_bar" == "all" or vars["alert3_last_date"] ~= source:date(period) then
                vars["alert3_last_date"] = source:date(period);
                signaler:Signal("Price in the BE-BB zone");
            end
        else
            bear_bb:SetRight(period + 10);
        end
    end
    for _, bull_bb in ipairs(Array:Enum(vars["bu_bb_boxes"])) do
        bottom = Box:GetBottom(bull_bb);
        top = Box:GetTop(bull_bb);
        if SafeLess(source.close:tick(period), bottom) then
            vars["f_delete_boxFunc8_param1"].Value = vars["bu_bb_boxes"];
            vars["f_delete_boxFunc8"].GetValue(period, mode);
        elseif SafeLess(source.close:tick(period), top) then
            if "once_per_bar" == "all" or vars["alert4_last_date"] ~= source:date(period) then
                vars["alert4_last_date"] = source:date(period);
                signaler:Signal("Price in the BU-BB zone");
            end
        else
            bull_bb:SetRight(period + 10);
        end
    end
    if (Change(market, period, 1) ~= 0) and period == source:size() - 1 then
        signaler:Signal("MSB");
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Box:Draw(stage, context);
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
    function newArray:Shift()
        local value = self.arr[1];
        table.remove(self.arr, 1);
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
function CreateBarsSince()
    local bs = {};
    bs.last_period = nil;
    function bs:set(period, condition)
        if condition then
            self.last_period = period;
        end
        if self.last_period == nil then
            return nil;
        end
        return period - self.last_period;
    end
    return bs;
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
function CreateValueWhen()
    local vw = {};
    vw._stream = instance:addInternalStream(0, 0); 
    vw._count = 0;
    function vw:set(period, condition, value, occurrence)
        if self._count > 0 and self._stream:getBookmark(self._count) == period then
            self._stream:setBookmark(self._count, -1);
        end
        if condition then
            if self._count == 0 or self._stream:getBookmark(self._count) ~= -1 then
                self._count = self._count + 1;
            end
            self._stream:setBookmark(self._count, period);
            if value == nil then
                self._stream:setNoData(period);
            else
                self._stream[period] = value;
            end
        end
        if self._count <= occurrence then
            return nil;
        end
        return self._stream[self._stream:getBookmark(self._count - occurrence)];
    end
    return vw;
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
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    newBox.Top = top;
    function newBox:GetTop()
        return self.Top;
    end
    newBox.Right = right;
    function newBox:SetRight(right)
        self.Right = right;
        return self;
    end
    newBox.Bottom = bottom;
    function newBox:GetBottom()
        return self.Bottom;
    end
    newBox.BorderWidth = 1;
    newBox.BorderStyle = core.LINE_SOLID;
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
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyle, context);
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