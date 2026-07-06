-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74457

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
    indicator:name("Order Blocks");
    indicator:description("Order Blocks");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Plot 2nd order pivots", "", true);
    indicator.parameters:addBoolean("param2", "Plot MSB lines", "", true);
    indicator.parameters:addBoolean("param3", "Plot Orderblocks", "", true);
    indicator.parameters:addBoolean("param4", "Plot Breakerblocks", "", true);
    indicator.parameters:addBoolean("param5", "Plot Range", "", true);
    indicator.parameters:addBoolean("param6", "Plot Range 0.5 Line", "", true);
    indicator.parameters:addBoolean("param7", "Plot Range 0.25 and 0.75 Lines", "", true);
    indicator.parameters:addBoolean("param8", "Use Log Scale", "", true);
    indicator.parameters:addBoolean("param9", "Alert MSB", "", true);
    indicator.parameters:addBoolean("param10", "Alert Orderblock test", "", true);
    indicator.parameters:addBoolean("param11", "Alert Breakerblock test", "", true);
    indicator.parameters:addBoolean("param12", "Alert New Range", "", true);
    indicator.parameters:addBoolean("param13", "Alert Range test", "", true);
    indicator.parameters:addColor("param14", "Untested Supply Color", "", Graphics:GetColor(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param15", "Tested Supply Color", "", Graphics:GetColor(core.rgb(255, 0, 0) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param16", "Untested Demand Color", "", Graphics:GetColor(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param17", "Tested Demand Color", "", Graphics:GetColor(core.rgb(0, 255, 0) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param18", "Untested Breaker Color", "", Graphics:GetColor(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param19", "Tested Breaker Color", "", Graphics:GetColor(core.colors().Blue + math.floor(80 / 100 * 255) * 16777216));
    signaler:Init(indicator.parameters);
end

local source;
local vars = {};
local htcmrll_price;
local htcmrll_time;
local ltcmrhh_price;
local ltcmrhh_time;
local temp_pv_0;
local temp_pv_1;
local temp_pv_2;
local temp_time;
local last_range_h;
local last_range_l;
local box_top;
local box_bottom;
local h_a_time;
local l_a_time;
local mh_a_time;
local ml_a_time;
local rh_a_time;
local rl_a_time;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["pv2_sv"] = instance.parameters.param1;
    vars["msb_sv"] = instance.parameters.param2;
    vars["box_sv"] = instance.parameters.param3;
    vars["m_sv"] = instance.parameters.param4;
    vars["range_sv"] = instance.parameters.param5;
    vars["range_eq_sv"] = instance.parameters.param6;
    vars["range_q_sv"] = instance.parameters.param7;
    vars["log_sv"] = instance.parameters.param8;
    vars["msb_a_sv"] = instance.parameters.param9;
    vars["ob_a_sv"] = instance.parameters.param10;
    vars["bb_a_sv"] = instance.parameters.param11;
    vars["r_a_sv"] = instance.parameters.param12;
    vars["rt_a_sv"] = instance.parameters.param13;
    vars["u_s"] = Graphics:AddTransparency(instance.parameters.param14, Graphics:GetTransparencyPercent(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    vars["t_s"] = Graphics:AddTransparency(instance.parameters.param15, Graphics:GetTransparencyPercent(core.rgb(255, 0, 0) + math.floor(80 / 100 * 255) * 16777216));
    vars["u_d"] = Graphics:AddTransparency(instance.parameters.param16, Graphics:GetTransparencyPercent(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    vars["t_d"] = Graphics:AddTransparency(instance.parameters.param17, Graphics:GetTransparencyPercent(core.rgb(0, 255, 0) + math.floor(80 / 100 * 255) * 16777216));
    vars["u_b"] = Graphics:AddTransparency(instance.parameters.param18, Graphics:GetTransparencyPercent(core.rgb(192, 192, 192) + math.floor(80 / 100 * 255) * 16777216));
    vars["t_b"] = Graphics:AddTransparency(instance.parameters.param19, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(80 / 100 * 255) * 16777216));
    htcmrll_price = instance:addInternalStream(0, 0);
    htcmrll_time = instance:addInternalStream(0, 0);
    ltcmrhh_price = instance:addInternalStream(0, 0);
    ltcmrhh_time = instance:addInternalStream(0, 0);
    temp_pv_0 = instance:addInternalStream(0, 0);
    temp_pv_1 = instance:addInternalStream(0, 0);
    temp_pv_2 = instance:addInternalStream(0, 0);
    temp_time = instance:addInternalStream(0, 0);
    last_range_h = instance:addInternalStream(0, 0);
    last_range_l = instance:addInternalStream(0, 0);
    box_top = instance:addInternalStream(0, 0);
    box_bottom = instance:addInternalStream(0, 0);
    h_a_time = instance:addInternalStream(0, 0);
    l_a_time = instance:addInternalStream(0, 0);
    mh_a_time = instance:addInternalStream(0, 0);
    ml_a_time = instance:addInternalStream(0, 0);
    rh_a_time = instance:addInternalStream(0, 0);
    rl_a_time = instance:addInternalStream(0, 0);
    Line:Prepare(50);
    Label:Prepare(50);
    signaler:Prepare(nameOnly);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Box:Clear();
        Label:Clear();
        vars["pvh1_price"] = Array:NewFloat(30, nil);
        vars["pvh1_time"] = Array:NewInt(30, nil);
        vars["pvl1_price"] = Array:NewFloat(30, nil);
        vars["pvl1_time"] = Array:NewInt(30, nil);
        vars["pvh2_price"] = Array:NewFloat(10, nil);
        vars["pvh2_time"] = Array:NewInt(10, nil);
        vars["pvl2_price"] = Array:NewFloat(10, nil);
        vars["pvl2_time"] = Array:NewInt(10, nil);
        SafeSetFloat(htcmrll_price, period, nil);
        SafeSetFloat(htcmrll_time, period, nil);
        SafeSetFloat(ltcmrhh_price, period, nil);
        SafeSetFloat(ltcmrhh_time, period, nil);
        vars["long_boxes"] = Array:NewBox(0, nil);
        vars["short_boxes"] = Array:NewBox(0, nil);
        vars["m_long_boxes"] = Array:NewBox(0, nil);
        vars["m_short_boxes"] = Array:NewBox(0, nil);
        vars["bull_bos_lines"] = Array:NewLine(0, nil);
        vars["bear_bos_lines"] = Array:NewLine(0, nil);
        vars["range_h_lines"] = Array:NewLine(0, nil);
        vars["range_25_lines"] = Array:NewLine(0, nil);
        vars["range_m_lines"] = Array:NewLine(0, nil);
        vars["range_75_lines"] = Array:NewLine(0, nil);
        vars["range_l_lines"] = Array:NewLine(0, nil);
        vars["la_ph2"] = Array:NewLabel(0, nil);
        vars["la_pl2"] = Array:NewLabel(0, nil);
        SafeSetFloat(temp_pv_0, period, nil);
        SafeSetFloat(temp_pv_1, period, nil);
        SafeSetFloat(temp_pv_2, period, nil);
        SafeSetFloat(temp_time, period, nil);
        SafeSetFloat(last_range_h, period, nil);
        SafeSetFloat(last_range_l, period, nil);
        vars["range_m"] = nil;
        vars["range_25"] = nil;
        vars["range_75"] = nil;
        SafeSetFloat(box_top, period, nil);
        SafeSetFloat(box_bottom, period, nil);
        SafeSetFloat(h_a_time, period, 0);
        SafeSetFloat(l_a_time, period, 0);
        SafeSetFloat(mh_a_time, period, 0);
        SafeSetFloat(ml_a_time, period, 0);
        SafeSetFloat(rh_a_time, period, 0);
        SafeSetFloat(rl_a_time, period, 0);
    else
        SafeSetFloat(htcmrll_price, period, SafeGetFloat(htcmrll_price, period - 1));
        SafeSetFloat(htcmrll_time, period, SafeGetFloat(htcmrll_time, period - 1));
        SafeSetFloat(ltcmrhh_price, period, SafeGetFloat(ltcmrhh_price, period - 1));
        SafeSetFloat(ltcmrhh_time, period, SafeGetFloat(ltcmrhh_time, period - 1));
        SafeSetFloat(temp_pv_0, period, SafeGetFloat(temp_pv_0, period - 1));
        SafeSetFloat(temp_pv_1, period, SafeGetFloat(temp_pv_1, period - 1));
        SafeSetFloat(temp_pv_2, period, SafeGetFloat(temp_pv_2, period - 1));
        SafeSetFloat(temp_time, period, SafeGetFloat(temp_time, period - 1));
        SafeSetFloat(last_range_h, period, SafeGetFloat(last_range_h, period - 1));
        SafeSetFloat(last_range_l, period, SafeGetFloat(last_range_l, period - 1));
        SafeSetFloat(box_top, period, SafeGetFloat(box_top, period - 1));
        SafeSetFloat(box_bottom, period, SafeGetFloat(box_bottom, period - 1));
        SafeSetFloat(h_a_time, period, SafeGetFloat(h_a_time, period - 1));
        SafeSetFloat(l_a_time, period, SafeGetFloat(l_a_time, period - 1));
        SafeSetFloat(mh_a_time, period, SafeGetFloat(mh_a_time, period - 1));
        SafeSetFloat(ml_a_time, period, SafeGetFloat(ml_a_time, period - 1));
        SafeSetFloat(rh_a_time, period, SafeGetFloat(rh_a_time, period - 1));
        SafeSetFloat(rl_a_time, period, SafeGetFloat(rl_a_time, period - 1));
    end
    pvh = (source.high:tick(period) < source.high:tick(period - 1)) and (source.high:tick(period - 1) > source.high:tick(period - 2));
    pvl = (source.low:tick(period) > source.low:tick(period - 1)) and (source.low:tick(period - 1) < source.low:tick(period - 2));
    pv1_time = period - 1;
    pv1_high = source.high:tick(period - 1);
    pv1_low = source.low:tick(period - 1);
    new_ph_2nd = false;
    new_pl_2nd = false;
    alert = nil;
    if (period ~= source:size() - 1 or mode == core.UpdateLast) then
        if pvh then
            Array:Pop(vars["pvh1_price"]);
            Array:Pop(vars["pvh1_time"]);
            vars["pvh1_price"]:Unshift(pv1_high);
            vars["pvh1_time"]:Unshift(pv1_time);
            if SafeGreater(vars["pvh1_price"]:Size(), 2) then
                SafeSetFloat(temp_pv_0, period, vars["pvh1_price"]:Get(0));
                SafeSetFloat(temp_pv_1, period, vars["pvh1_price"]:Get(1));
                SafeSetFloat(temp_pv_2, period, vars["pvh1_price"]:Get(2));
                if SafeLess(SafeGetFloat(temp_pv_0, period), SafeGetFloat(temp_pv_1, period)) and SafeGreater(SafeGetFloat(temp_pv_1, period), SafeGetFloat(temp_pv_2, period)) then
                    Array:Pop(vars["pvh2_price"]);
                    Array:Pop(vars["pvh2_time"]);
                    vars["pvh2_price"]:Unshift(SafeGetFloat(temp_pv_1, period));
                    vars["pvh2_time"]:Unshift(vars["pvh1_time"]:Get(1));
                    new_ph_2nd = true;
                    if SafeGreater(SafeGetFloat(temp_pv_1, period), vars["pvh2_price"]:Get(1)) then
                        local for1_from = 0;
                        local for1_to = SafeMinus(vars["pvl2_time"]:Size(), 1);
                        if not for1_from or not for1_to then return; end
                        for i = for1_from, for1_to, 1 do
                            temp_ltcmrhh_time = vars["pvl2_time"]:Get(i);
                            if SafeLess(temp_ltcmrhh_time, vars["pvh2_time"]:Get(0)) then
                                SafeSetFloat(ltcmrhh_price, period, vars["pvl2_price"]:Get(i));
                                SafeSetFloat(ltcmrhh_time, period, temp_ltcmrhh_time);
                                break;
                            end
                        end
                    end
                end
                if SafeLess(SafeGetFloat(temp_pv_0, period), SafeGetFloat(ltcmrhh_price, period)) then
                    if vars["msb_sv"] then
                        vars["bear_bos_lines"]:Push(Line:New(SafeGetFloat(ltcmrhh_time, period), SafeGetFloat(ltcmrhh_price, period), period, SafeGetFloat(ltcmrhh_price, period)):SetColor(core.colors().Green):SetWidth(2));
                    end
                    SafeSetFloat(box_top, period, vars["pvh2_price"]:Get(0));
                    SafeSetFloat(box_bottom, period, math.max(source.low:tick(period - SafeMinus(period, vars["pvh2_time"]:Get(0))), source.low:tick(period - SafePlus(SafeMinus(period, vars["pvh2_time"]:Get(0)), 1))));
                    vars["short_boxes"]:Push(Box:New(core.formatDate(source:date(vars["pvh2_time"]:Get(0))), "1", vars["pvh2_time"]:Get(0), SafeGetFloat(box_top, period), period, SafeGetFloat(box_bottom, period)):SetBgColor(((vars["box_sv"]) and (vars["u_s"]) or (nil))):SetBorderColor(nil));
                    if vars["msb_a_sv"] then
                        alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Bearish MSB @ "), Str:ToString(SafeGetFloat(ltcmrhh_price, period))), "\n"), "New Supply Zone : "), Str:ToString(SafeGetFloat(box_top, period))), " - "), Str:ToString(SafeGetFloat(box_bottom, period))), "\n");
                    end
                    SafeSetFloat(ltcmrhh_price, period, nil);
                end
            end
        end
        if pvl then
            Array:Pop(vars["pvl1_price"]);
            Array:Pop(vars["pvl1_time"]);
            vars["pvl1_price"]:Unshift(pv1_low);
            vars["pvl1_time"]:Unshift(pv1_time);
            if SafeGreater(vars["pvl1_price"]:Size(), 2) then
                SafeSetFloat(temp_pv_0, period, vars["pvl1_price"]:Get(0));
                SafeSetFloat(temp_pv_1, period, vars["pvl1_price"]:Get(1));
                SafeSetFloat(temp_pv_2, period, vars["pvl1_price"]:Get(2));
                if SafeGreater(SafeGetFloat(temp_pv_0, period), SafeGetFloat(temp_pv_1, period)) and SafeLess(SafeGetFloat(temp_pv_1, period), SafeGetFloat(temp_pv_2, period)) then
                    Array:Pop(vars["pvl2_price"]);
                    Array:Pop(vars["pvl2_time"]);
                    vars["pvl2_price"]:Unshift(SafeGetFloat(temp_pv_1, period));
                    vars["pvl2_time"]:Unshift(vars["pvl1_time"]:Get(1));
                    new_pl_2nd = true;
                    if SafeLess(SafeGetFloat(temp_pv_1, period), vars["pvl2_price"]:Get(1)) then
                        local for2_from = 0;
                        local for2_to = SafeMinus(vars["pvh2_time"]:Size(), 1);
                        if not for2_from or not for2_to then return; end
                        for i = for2_from, for2_to, 1 do
                            temp_htcmrll_time = vars["pvh2_time"]:Get(i);
                            if SafeLess(temp_htcmrll_time, vars["pvl2_time"]:Get(0)) then
                                SafeSetFloat(htcmrll_price, period, vars["pvh2_price"]:Get(i));
                                SafeSetFloat(htcmrll_time, period, temp_htcmrll_time);
                                break;
                            end
                        end
                    end
                end
                if SafeGreater(SafeGetFloat(temp_pv_0, period), SafeGetFloat(htcmrll_price, period)) then
                    if vars["msb_sv"] then
                        vars["bull_bos_lines"]:Push(Line:New(SafeGetFloat(htcmrll_time, period), SafeGetFloat(htcmrll_price, period), period, SafeGetFloat(htcmrll_price, period)):SetColor(core.colors().Red):SetWidth(2));
                    end
                    SafeSetFloat(box_top, period, math.min(source.high:tick(period - SafeMinus(period, vars["pvl2_time"]:Get(0))), source.high:tick(period - SafePlus(SafeMinus(period, vars["pvl2_time"]:Get(0)), 1))));
                    SafeSetFloat(box_bottom, period, vars["pvl2_price"]:Get(0));
                    vars["long_boxes"]:Push(Box:New(core.formatDate(source:date(vars["pvl2_time"]:Get(0))), "2", vars["pvl2_time"]:Get(0), SafeGetFloat(box_top, period), period, SafeGetFloat(box_bottom, period)):SetBgColor(((vars["box_sv"]) and (vars["u_d"]) or (nil))):SetBorderColor(nil));
                    if vars["msb_a_sv"] then
                        alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Bullish MSB @ "), Str:ToString(SafeGetFloat(htcmrll_price, period))), "\n"), "New Demand Zone : "), Str:ToString(SafeGetFloat(box_bottom, period))), " - "), Str:ToString(SafeGetFloat(box_top, period))), "\n");
                    end
                    SafeSetFloat(htcmrll_price, period, nil);
                end
            end
        end
        if SafeGreater(vars["short_boxes"]:Size(), 0) then
            local for3_from = SafeMinus(vars["short_boxes"]:Size(), 1);
            local for3_to = 0;
            if not for3_from or not for3_to then return; end
            for i = for3_from, for3_to, 1 do
                tbox = vars["short_boxes"]:Get(i);
                top = Box:GetTop(tbox);
                bottom = Box:GetBottom(tbox);
                ago = Box:GetLeft(tbox);
                if SafeGreater(vars["pvh1_price"]:Get(0), bottom) then
                    if vars["box_sv"] then
                        tbox:SetBgColor(vars["t_s"]);
                    end
                    if vars["ob_a_sv"] and SafeLess(source.close:tick(period), bottom) then
                        if (vars["pvh1_time"]:Get(0) ~= SafeGetFloat(h_a_time, period)) then
                            SafeSetFloat(h_a_time, period, vars["pvh1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Supply Zone Test @ "), Str:ToString(vars["pvh1_price"]:Get(0))), " (age = "), Str:ToString(SafeMinus(period, ago))), " bars) \n");
                        end
                    end
                end
                if SafeGreater(vars["pvl1_price"]:Get(0), top) then
                    if vars["m_sv"] then
                        tbox:SetBgColor(vars["u_b"]);
                        vars["m_long_boxes"]:Push(tbox);
                    else
                        Box:Delete(tbox);
                    end
                    if vars["msb_sv"] then
                        Line:Delete(vars["bear_bos_lines"]:Get(i));
                    end
                end
            end
        end
        if SafeGreater(vars["long_boxes"]:Size(), 0) then
            local for4_from = SafeMinus(vars["long_boxes"]:Size(), 1);
            local for4_to = 0;
            if not for4_from or not for4_to then return; end
            for i = for4_from, for4_to, 1 do
                lbox = vars["long_boxes"]:Get(i);
                top = Box:GetTop(lbox);
                bottom = Box:GetBottom(lbox);
                ago = Box:GetLeft(lbox);
                if SafeLess(vars["pvl1_price"]:Get(0), top) then
                    if vars["box_sv"] then
                        lbox:SetBgColor(vars["t_d"]);
                    end
                    if vars["ob_a_sv"] and SafeGreater(source.close:tick(period), top) then
                        if (vars["pvl1_time"]:Get(0) ~= SafeGetFloat(l_a_time, period)) then
                            SafeSetFloat(l_a_time, period, vars["pvl1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Demand Zone Test @ "), Str:ToString(vars["pvl1_price"]:Get(0))), " (age = "), Str:ToString(SafeMinus(period, ago))), " bars) \n");
                        end
                    end
                end
                if SafeLess(vars["pvh1_price"]:Get(0), bottom) then
                    if vars["m_sv"] then
                        lbox:SetBgColor(vars["u_b"]);
                        vars["m_short_boxes"]:Push(lbox);
                    else
                        Box:Delete(lbox);
                    end
                    if vars["msb_sv"] then
                        Line:Delete(vars["bull_bos_lines"]:Get(i));
                    end
                end
            end
        end
        if SafeGreater(vars["m_short_boxes"]:Size(), 0) then
            local for5_from = SafeMinus(vars["m_short_boxes"]:Size(), 1);
            local for5_to = 0;
            if not for5_from or not for5_to then return; end
            for i = for5_from, for5_to, 1 do
                tbox = vars["m_short_boxes"]:Get(i);
                top = Box:GetTop(tbox);
                bottom = Box:GetBottom(tbox);
                ago = Box:GetLeft(tbox);
                if SafeGreater(vars["pvh1_price"]:Get(0), bottom) then
                    tbox:SetBgColor(vars["t_b"]);
                    if vars["bb_a_sv"] and SafeLess(source.close:tick(period), bottom) then
                        if (vars["pvh1_time"]:Get(0) ~= SafeGetFloat(mh_a_time, period)) then
                            SafeSetFloat(mh_a_time, period, vars["pvh1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Breakerblock Test Up @ "), Str:ToString(vars["pvh1_price"]:Get(0))), " (age = "), Str:ToString(SafeMinus(period, ago))), " bars) \n");
                        end
                    end
                end
                if SafeGreater(vars["pvl1_price"]:Get(0), top) then
                    Box:Delete(tbox);
                end
            end
        end
        if SafeGreater(vars["m_long_boxes"]:Size(), 0) then
            local for6_from = SafeMinus(vars["m_long_boxes"]:Size(), 1);
            local for6_to = 0;
            if not for6_from or not for6_to then return; end
            for i = for6_from, for6_to, 1 do
                lbox = vars["m_long_boxes"]:Get(i);
                top = Box:GetTop(lbox);
                bottom = Box:GetBottom(lbox);
                ago = Box:GetLeft(lbox);
                if SafeLess(vars["pvl1_price"]:Get(0), top) then
                    lbox:SetBgColor(vars["t_b"]);
                    if vars["bb_a_sv"] and SafeGreater(source.close:tick(period), top) then
                        if (vars["pvl1_time"]:Get(0) ~= SafeGetFloat(ml_a_time, period)) then
                            SafeSetFloat(ml_a_time, period, vars["pvl1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "Breakerblock Test Down @ "), Str:ToString(vars["pvl1_price"]:Get(0))), " (age = "), Str:ToString(SafeMinus(period, ago))), " bars) \n");
                        end
                    end
                end
                if SafeLess(vars["pvh1_price"]:Get(0), bottom) then
                    Box:Delete(lbox);
                end
            end
        end
        if vars["range_sv"] and ((new_ph_2nd or new_pl_2nd)) and (SafeLess(vars["pvh2_price"]:Get(0), vars["pvh2_price"]:Get(1)) and SafeGreater(vars["pvl2_price"]:Get(0), vars["pvl2_price"]:Get(1)) and SafeGreater(vars["pvh2_price"]:Get(0), vars["pvl2_price"]:Get(1)) and SafeLess(vars["pvl2_price"]:Get(0), vars["pvh2_price"]:Get(1))) and ((((SafeGreater(vars["pvl2_price"]:Get(1), Nz(SafeGetFloat(last_range_h, period))) or SafeGetFloat(last_range_l, period) == nil)) and (true) or ((SafeLess(vars["pvh2_price"]:Get(1), SafeGetFloat(last_range_l, period)))))) then
            SafeSetFloat(temp_time, period, SafeMin(vars["pvh2_time"]:Get(1), vars["pvl2_time"]:Get(1)));
            SafeSetFloat(last_range_h, period, vars["pvh2_price"]:Get(1));
            SafeSetFloat(last_range_l, period, vars["pvl2_price"]:Get(1));
            SafeSetFloat(temp_pv_0, period, ((vars["log_sv"]) and (math.exp(SafeDivide((SafePlus(math.log(SafeGetFloat(last_range_h, period)), math.log(SafeGetFloat(last_range_l, period)))), 2))) or (SafeDivide((SafePlus(SafeGetFloat(last_range_h, period), SafeGetFloat(last_range_l, period))), 2))));
            SafeSetFloat(temp_pv_1, period, ((vars["log_sv"]) and (math.exp(SafeDivide((SafePlus(math.log(SafeGetFloat(last_range_h, period)), math.log(SafeGetFloat(temp_pv_0, period)))), 2))) or (SafeDivide((SafePlus(SafeGetFloat(last_range_h, period), SafeGetFloat(temp_pv_0, period))), 2))));
            SafeSetFloat(temp_pv_2, period, ((vars["log_sv"]) and (math.exp(SafeDivide((SafePlus(math.log(SafeGetFloat(last_range_l, period)), math.log(SafeGetFloat(temp_pv_0, period)))), 2))) or (SafeDivide((SafePlus(SafeGetFloat(last_range_l, period), SafeGetFloat(temp_pv_0, period))), 2))));
            vars["range_h_lines"]:Push(Line:New(SafeGetFloat(temp_time, period), SafeGetFloat(last_range_h, period), period, SafeGetFloat(last_range_h, period)):SetColor(core.colors().Gray):SetExtend("right"):SetWidth(1));
            vars["range_l_lines"]:Push(Line:New(SafeGetFloat(temp_time, period), SafeGetFloat(last_range_l, period), period, SafeGetFloat(last_range_l, period)):SetColor(core.colors().Gray):SetExtend("right"):SetWidth(1));
            if vars["range_eq_sv"] then
                vars["range_m_lines"]:Push(Line:New(SafeGetFloat(temp_time, period), SafeGetFloat(temp_pv_0, period), period, SafeGetFloat(temp_pv_0, period)):SetColor(core.colors().Gray):SetExtend("right"):SetWidth(1));
            end
            if vars["range_q_sv"] then
                vars["range_25_lines"]:Push(Line:New(SafeGetFloat(temp_time, period), SafeGetFloat(temp_pv_1, period), period, SafeGetFloat(temp_pv_1, period)):SetColor(core.colors().Gray):SetExtend("right"):SetStyle("dashed"):SetWidth(1));
                vars["range_75_lines"]:Push(Line:New(SafeGetFloat(temp_time, period), SafeGetFloat(temp_pv_2, period), period, SafeGetFloat(temp_pv_2, period)):SetColor(core.colors().Gray):SetExtend("right"):SetStyle("dashed"):SetWidth(1));
            end
            if vars["r_a_sv"] then
                alert = SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(SafeConcat(alert, "New Range : "), Str:ToString(SafeGetFloat(last_range_h, period))), " - "), Str:ToString(SafeGetFloat(last_range_l, period))), ". Mean = "), Str:ToString(SafeGetFloat(temp_pv_0, period))), "\n");
            end
        end
        if SafeGreater(vars["range_h_lines"]:Size(), 0) then
            local for7_from = SafeMinus(vars["range_h_lines"]:Size(), 1);
            local for7_to = 0;
            if not for7_from or not for7_to then return; end
            for i = for7_from, for7_to, 1 do
                range_h = vars["range_h_lines"]:Get(i);
                top = Line:GetY1(range_h);
                range_l = vars["range_l_lines"]:Get(i);
                bottom = Line:GetY1(range_l);
                SafeSetFloat(temp_time, period, Line:GetX1(range_h));
                if SafeGreater(vars["pvh1_price"]:Get(0), top) then
                    if vars["rt_a_sv"] and SafeLess(source.close:tick(period), top) then
                        if (vars["pvh1_time"]:Get(0) ~= SafeGetFloat(rh_a_time, period)) then
                            SafeSetFloat(rh_a_time, period, vars["pvh1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(alert, "Range High Test @ "), Str:ToString(vars["pvh1_price"]:Get(0))), " \n");
                        end
                    end
                end
                if SafeLess(vars["pvl1_price"]:Get(0), bottom) then
                    if vars["rt_a_sv"] and SafeGreater(source.close:tick(period), bottom) then
                        if (vars["pvl1_time"]:Get(0) ~= SafeGetFloat(rl_a_time, period)) then
                            SafeSetFloat(rl_a_time, period, vars["pvl1_time"]:Get(0));
                            alert = SafeConcat(SafeConcat(SafeConcat(alert, "Range Low Test @ "), Str:ToString(vars["pvl1_price"]:Get(0))), " \n");
                        end
                    end
                end
                if vars["range_eq_sv"] then
                    vars["range_m"] = vars["range_m_lines"]:Get(i);
                end
                if vars["range_q_sv"] then
                    vars["range_25"] = vars["range_25_lines"]:Get(i);
                    vars["range_75"] = vars["range_75_lines"]:Get(i);
                end
                if (SafeLess(vars["pvh1_price"]:Get(0), bottom) or SafeGreater(vars["pvl1_price"]:Get(0), top)) then
                    Line:Delete(range_h);
                    Line:Delete(range_l);
                    if vars["range_eq_sv"] then
                        Line:Delete(vars["range_m"]);
                    end
                    if vars["range_q_sv"] then
                        Line:Delete(vars["range_25"]);
                        Line:Delete(vars["range_75"]);
                    end
                    SafeSetFloat(last_range_h, period, nil);
                    SafeSetFloat(last_range_l, period, nil);
                end
            end
        end
        if vars["pv2_sv"] then
            if new_ph_2nd then
                label_1_x = vars["pvh2_time"]:Get(0);
                vars["la_ph2"]:Push(Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, vars["pvh2_price"]:Get(0)):SetColor(core.rgb(119, 0, 0)):SetStyle("down"):SetSize("tiny"));
            end
            if new_pl_2nd then
                label_2_x = vars["pvl2_time"]:Get(0);
                vars["la_pl2"]:Push(Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, vars["pvl2_price"]:Get(0)):SetColor(core.rgb(0, 119, 0)):SetStyle("up"):SetSize("tiny"));
            end
        end
    end
    alert = ((not (alert == nil)) and ((SafeConcat(SafeConcat(SafeConcat(alert, "Current price = "), Str:ToString(source.close:tick(period))), "\n"))) or (nil));
    exec = ((not (alert == nil)) and (true) or (false));
    if (exec == true) then
        if "once_per_bar_close" == "all" or vars["alert1_last_date"] ~= source:date(period) then
            vars["alert1_last_date"] = source:date(period);
            signaler:Signal(alert);
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Box:Draw(stage, context);
    Label:Draw(stage, context);
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
Str = {};
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
        local W, H;
        if self.Text == nil or self.Text == "" then
            W, H = self:GetDefaultSize()
        else
            W, H = context:measureText(Label.FontId, self.Text, context.LEFT);
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
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency)
            elseif self.Style == "up" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from + ySize / 2;
                y_to = y_to + ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_from - 1);
                points:add(x_to, y_from - 1);
                points:add((x_to + x_from) / 2, y_from - ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency)
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