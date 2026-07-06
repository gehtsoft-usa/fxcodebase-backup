
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74488

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
    indicator:name("ICT Sessions");
    indicator:description("ICT Sessions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addBoolean("param1", "Override defaul offset", "", false);
    indicator.parameters:addInteger("param2", "Offset of UTC time", "", (-6));
    indicator.parameters:addInteger("param3", "Forward plotting hours", "", 2);
    indicator.parameters:addBoolean("param4", "Filter Timewindows by asset type", "", true);
    indicator.parameters:addBoolean("param5", "Show vertical weekly separator line", "", true);
end

local source;
local time;
local plot1;
local plot2;
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
local plot17;
local plot18;
local plot19;
local plot20;
local plot21;
local plot22;
local plot23;
local plot24;
local plot25;
local plot26;
function Create_number_to_4char_string(int_number)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            normalized_int_number = SafeGetFloat(int_number, period);
            if (SafeGetFloat(int_number, period) <= 0) then
                normalized_int_number = 2400 + SafeGetFloat(int_number, period);
            end
            initial_convert = Str:Format("{0, number,###}", normalized_int_number);
            if SafeLE(Str:Length(initial_convert), 3) then
                initial_convert = SafeConcat("0", initial_convert);
            end
            if SafeLE(Str:Length(initial_convert), 3) then
                initial_convert = SafeConcat("0", initial_convert);
            end
            if SafeLE(Str:Length(initial_convert), 3) then
                initial_convert = SafeConcat("0", initial_convert);
            end
            return initial_convert;
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
    vars["override_offset"] = instance.parameters.param1;
    vars["utc_offset_input"] = instance.parameters.param2;
    vars["plotting_offset_hours"] = instance.parameters.param3;
    vars["use_assettype_filter_inverted"] = instance.parameters.param4;
    vars["show_weekly_separator"] = instance.parameters.param5;
    vars["number_to_4char_stringFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc1"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc1_param1"]);
    vars["number_to_4char_stringFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc2"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc2_param1"]);
    vars["number_to_4char_stringFunc3_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc3"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc3_param1"]);
    vars["number_to_4char_stringFunc4_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc4"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc4_param1"]);
    vars["number_to_4char_stringFunc5_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc5"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc5_param1"]);
    vars["number_to_4char_stringFunc6_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc6"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc6_param1"]);
    vars["number_to_4char_stringFunc7_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc7"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc7_param1"]);
    vars["number_to_4char_stringFunc8_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc8"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc8_param1"]);
    vars["number_to_4char_stringFunc9_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc9"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc9_param1"]);
    vars["number_to_4char_stringFunc10_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc10"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc10_param1"]);
    vars["number_to_4char_stringFunc11_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc11"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc11_param1"]);
    vars["number_to_4char_stringFunc12_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc12"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc12_param1"]);
    vars["number_to_4char_stringFunc13_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc13"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc13_param1"]);
    vars["number_to_4char_stringFunc14_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc14"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc14_param1"]);
    vars["number_to_4char_stringFunc15_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc15"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc15_param1"]);
    vars["number_to_4char_stringFunc16_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc16"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc16_param1"]);
    vars["number_to_4char_stringFunc17_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc17"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc17_param1"]);
    vars["number_to_4char_stringFunc18_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc18"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc18_param1"]);
    vars["number_to_4char_stringFunc19_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc19"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc19_param1"]);
    vars["number_to_4char_stringFunc20_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc20"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc20_param1"]);
    vars["number_to_4char_stringFunc21_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc21"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc21_param1"]);
    vars["number_to_4char_stringFunc22_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc22"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc22_param1"]);
    vars["number_to_4char_stringFunc23_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc23"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc23_param1"]);
    vars["number_to_4char_stringFunc24_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc24"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc24_param1"]);
    vars["number_to_4char_stringFunc25_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc25"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc25_param1"]);
    vars["number_to_4char_stringFunc26_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc26"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc26_param1"]);
    vars["number_to_4char_stringFunc27_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc27"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc27_param1"]);
    vars["number_to_4char_stringFunc28_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc28"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc28_param1"]);
    vars["number_to_4char_stringFunc29_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc29"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc29_param1"]);
    vars["number_to_4char_stringFunc30_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc30"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc30_param1"]);
    vars["number_to_4char_stringFunc31_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc31"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc31_param1"]);
    vars["number_to_4char_stringFunc32_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc32"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc32_param1"]);
    vars["number_to_4char_stringFunc33_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc33"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc33_param1"]);
    vars["number_to_4char_stringFunc34_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc34"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc34_param1"]);
    vars["number_to_4char_stringFunc35_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc35"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc35_param1"]);
    vars["number_to_4char_stringFunc36_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc36"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc36_param1"]);
    vars["number_to_4char_stringFunc37_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc37"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc37_param1"]);
    vars["number_to_4char_stringFunc38_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc38"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc38_param1"]);
    vars["number_to_4char_stringFunc39_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc39"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc39_param1"]);
    vars["number_to_4char_stringFunc40_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc40"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc40_param1"]);
    vars["number_to_4char_stringFunc41_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc41"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc41_param1"]);
    vars["number_to_4char_stringFunc42_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc42"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc42_param1"]);
    vars["number_to_4char_stringFunc43_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc43"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc43_param1"]);
    vars["number_to_4char_stringFunc44_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc44"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc44_param1"]);
    vars["number_to_4char_stringFunc45_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc45"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc45_param1"]);
    vars["number_to_4char_stringFunc46_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc46"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc46_param1"]);
    vars["number_to_4char_stringFunc47_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc47"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc47_param1"]);
    vars["number_to_4char_stringFunc48_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc48"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc48_param1"]);
    vars["number_to_4char_stringFunc49_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc49"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc49_param1"]);
    vars["number_to_4char_stringFunc50_param1"] = instance:addInternalStream(0, 0);
    vars["number_to_4char_stringFunc50"] = Create_number_to_4char_string(vars["number_to_4char_stringFunc50_param1"]);
    time = instance:addInternalStream(0, 0);
    Line:Prepare(50);
    plot1 = instance:addStream("plot1", core.Line, "London Session", "London Session", core.colors().Blue, 0, SafeNegative(n_bars_to_shift));
    plot1:setWidth(3);
    plot2 = instance:addStream("plot2", core.Line, "New York Session", "New York Session", Graphics:AddTransparency(core.rgb(85, 117, 136), 0), 0, SafeNegative(n_bars_to_shift));
    plot2:setWidth(3);
    plot3 = instance:addStream("plot3", core.Line, "Asia Session", "Asia Session", core.colors().Orange, 0, SafeNegative(n_bars_to_shift));
    plot3:setWidth(3);
    plot4 = instance:addStream("plot4", core.Line, "London killzone", "London killzone", core.colors().Aqua, 0, SafeNegative(n_bars_to_shift));
    plot4:setWidth(4);
    plot5 = instance:addStream("plot5", core.Line, "London killzone ext", "London killzone ext", core.colors().Aqua, 0, SafeNegative(n_bars_to_shift));
    plot5:setWidth(2);
    plot6 = instance:addStream("plot6", core.Line, "London Exitzone", "London Exitzone", core.colors().Maroon, 0, SafeNegative(n_bars_to_shift));
    plot6:setWidth(4);
    plot7 = instance:addStream("plot7", core.Line, "New York killzone", "New York killzone", core.colors().Teal, 0, SafeNegative(n_bars_to_shift));
    plot7:setWidth(4);
    plot8 = instance:addStream("plot8", core.Line, "New York killzone ext", "New York killzone ext", core.colors().Teal, 0, SafeNegative(n_bars_to_shift));
    plot8:setWidth(2);
    plot9 = instance:createTextOutput("plot9", "London midnight", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Black);
    plot10 = instance:createTextOutput("plot10", "New York midnight", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Black);
    plot11 = instance:addStream("plot11", core.Line, "London Lunch", "London Lunch", core.colors().Red, 0, SafeNegative(n_bars_to_shift));
    plot11:setWidth(6);
    plot12 = instance:addStream("plot12", core.Line, "New York Lunch", "New York Lunch", Graphics:AddTransparency(core.rgb(212, 38, 38), 0), 0, SafeNegative(n_bars_to_shift));
    plot12:setWidth(6);
    plot13 = instance:addStream("plot13", core.Line, "New York Lunch 13", "New York Lunch 13", core.colors().Red, 0, SafeNegative(n_bars_to_shift));
    plot13:setWidth(6);
    plot14 = instance:addStream("plot14", core.Line, "First 30min of trading", "First 30min of trading", Graphics:AddTransparency(core.rgb(255, 148, 0), 0), 0, SafeNegative(n_bars_to_shift));
    plot14:setWidth(4);
    plot15 = instance:addStream("plot15", core.Line, "Silberbullet AM", "Silberbullet AM", Graphics:AddTransparency(core.rgb(76, 106, 119), 0), 0, SafeNegative(n_bars_to_shift));
    plot15:setWidth(4);
    plot16 = instance:addStream("plot16", core.Line, "Silberbullet PM", "Silberbullet PM", Graphics:AddTransparency(core.rgb(76, 106, 119), 0), 0, SafeNegative(n_bars_to_shift));
    plot16:setWidth(4);
    plot17 = instance:addStream("plot17", core.Line, "8:50 makro", "8:50 makro", Graphics:AddTransparency(core.rgb(27, 94, 32), 0), 0, SafeNegative(n_bars_to_shift));
    plot17:setWidth(4);
    plot18 = instance:addStream("plot18", core.Line, "9:50 makro", "9:50 makro", Graphics:AddTransparency(core.rgb(27, 94, 32), 0), 0, SafeNegative(n_bars_to_shift));
    plot18:setWidth(4);
    plot19 = instance:addStream("plot19", core.Line, "Pre NY Lunch makro", "Pre NY Lunch makro", Graphics:AddTransparency(core.rgb(27, 94, 32), 0), 0, SafeNegative(n_bars_to_shift));
    plot19:setWidth(4);
    plot20 = instance:addStream("plot20", core.Line, "NY Lunch makro", "NY Lunch makro", Graphics:AddTransparency(core.rgb(73, 0, 0), 0), 0, SafeNegative(n_bars_to_shift));
    plot20:setWidth(4);
    plot21 = instance:addStream("plot21", core.Line, "Last NY hour of trading", "Last NY hour of trading", Graphics:AddTransparency(core.rgb(22, 211, 35), 0), 0, SafeNegative(n_bars_to_shift));
    plot21:setWidth(4);
    plot22 = instance:addStream("plot22", core.Line, "Last NY hour of trading makro", "Last NY hour of trading makro", Graphics:AddTransparency(core.rgb(27, 94, 32), 0), 0, SafeNegative(n_bars_to_shift));
    plot22:setWidth(4);
    plot23 = instance:createTextOutput("plot23", "New York 8:30", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Black);
    plot24 = instance:createTextOutput("plot24", "New York 9:30", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Black);
    plot25 = instance:addStream("plot25", core.Line, "Upper line", "Upper line", core.colors().Silver, 0, SafeNegative(n_bars_to_shift));
    plot25:setWidth(1);
    plot25:setStyle(core.LINE_SOLID);
    plot26 = instance:addStream("plot26", core.Line, "Lower line", "Lower line", core.colors().Silver, 0, SafeNegative(n_bars_to_shift));
    plot26:setWidth(1);
    plot26:setStyle(core.LINE_SOLID);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        vars["number_to_4char_stringFunc1"].Clear();
        vars["number_to_4char_stringFunc2"].Clear();
        vars["number_to_4char_stringFunc3"].Clear();
        vars["number_to_4char_stringFunc4"].Clear();
        vars["number_to_4char_stringFunc5"].Clear();
        vars["number_to_4char_stringFunc6"].Clear();
        vars["number_to_4char_stringFunc7"].Clear();
        vars["number_to_4char_stringFunc8"].Clear();
        vars["number_to_4char_stringFunc9"].Clear();
        vars["number_to_4char_stringFunc10"].Clear();
        vars["number_to_4char_stringFunc11"].Clear();
        vars["number_to_4char_stringFunc12"].Clear();
        vars["number_to_4char_stringFunc13"].Clear();
        vars["number_to_4char_stringFunc14"].Clear();
        vars["number_to_4char_stringFunc15"].Clear();
        vars["number_to_4char_stringFunc16"].Clear();
        vars["number_to_4char_stringFunc17"].Clear();
        vars["number_to_4char_stringFunc18"].Clear();
        vars["number_to_4char_stringFunc19"].Clear();
        vars["number_to_4char_stringFunc20"].Clear();
        vars["number_to_4char_stringFunc21"].Clear();
        vars["number_to_4char_stringFunc22"].Clear();
        vars["number_to_4char_stringFunc23"].Clear();
        vars["number_to_4char_stringFunc24"].Clear();
        vars["number_to_4char_stringFunc25"].Clear();
        vars["number_to_4char_stringFunc26"].Clear();
        vars["number_to_4char_stringFunc27"].Clear();
        vars["number_to_4char_stringFunc28"].Clear();
        vars["number_to_4char_stringFunc29"].Clear();
        vars["number_to_4char_stringFunc30"].Clear();
        vars["number_to_4char_stringFunc31"].Clear();
        vars["number_to_4char_stringFunc32"].Clear();
        vars["number_to_4char_stringFunc33"].Clear();
        vars["number_to_4char_stringFunc34"].Clear();
        vars["number_to_4char_stringFunc35"].Clear();
        vars["number_to_4char_stringFunc36"].Clear();
        vars["number_to_4char_stringFunc37"].Clear();
        vars["number_to_4char_stringFunc38"].Clear();
        vars["number_to_4char_stringFunc39"].Clear();
        vars["number_to_4char_stringFunc40"].Clear();
        vars["number_to_4char_stringFunc41"].Clear();
        vars["number_to_4char_stringFunc42"].Clear();
        vars["number_to_4char_stringFunc43"].Clear();
        vars["number_to_4char_stringFunc44"].Clear();
        vars["number_to_4char_stringFunc45"].Clear();
        vars["number_to_4char_stringFunc46"].Clear();
        vars["number_to_4char_stringFunc47"].Clear();
        vars["number_to_4char_stringFunc48"].Clear();
        vars["number_to_4char_stringFunc49"].Clear();
        vars["number_to_4char_stringFunc50"].Clear();
        time[period] = source:date(period) * 86400000;
    else
        time[period] = source:date(period) * 86400000;
    end
    if not (vars["override_offset"]) then
        if ((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) then
            vars["utc_offset_input"] = (-7);
        end
        if ((SymInfo:GetType() == "forex") or (SymInfo:GetTicker() == "DXY")) then
            vars["utc_offset_input"] = (-6);
        end
    end
    use_assettype_filter = not (vars["use_assettype_filter_inverted"]);
    n_bars_to_shift = Round(SafeDivide((vars["plotting_offset_hours"] * 60), tonumber(Timeframe:Period())));
    utc_offset = (vars["utc_offset_input"] - vars["plotting_offset_hours"]) * 100;
    SafeSetFloat(vars["number_to_4char_stringFunc1_param1"], period, 0900 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc2_param1"], period, 1701 + utc_offset);
    london_timewindow = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc1"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc2"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc3_param1"], period, 1430 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc4_param1"], period, 2201 + utc_offset);
    newyork_timewindow = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc3"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc4"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc5_param1"], period, 0000 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc6_param1"], period, 1001 + utc_offset);
    asian_timewindow = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc5"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc6"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc7_param1"], period, 0800 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc8_param1"], period, 1101 + utc_offset);
    london_entry_kill_zone = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc7"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc8"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc9_param1"], period, 0700 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc10_param1"], period, 1101 + utc_offset);
    london_entry_kill_zone_extended = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc9"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc10"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc11_param1"], period, 1600 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc12_param1"], period, 1701 + utc_offset);
    london_exit_kill_zone = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc11"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc12"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc13_param1"], period, 1300 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc14_param1"], period, 1601 + utc_offset);
    newyork_kill_zone = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc13"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc14"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc15_param1"], period, 1200 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc16_param1"], period, 1601 + utc_offset);
    newyork_kill_zone_extended = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc15"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc16"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc17_param1"], period, 0000 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc18_param1"], period, 0001 + utc_offset);
    sydney_open = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc17"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc18"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc19_param1"], period, 0100 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc20_param1"], period, 0101 + utc_offset);
    london_midnight = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc19"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc20"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc21_param1"], period, 0600 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc22_param1"], period, 0601 + utc_offset);
    newyork_midnight = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc21"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc22"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc23_param1"], period, 1430 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc24_param1"], period, 1431 + utc_offset);
    newyork_830 = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc23"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc24"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc25_param1"], period, 1530 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc26_param1"], period, 1531 + utc_offset);
    newyork_930 = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc25"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc26"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc27_param1"], period, 1300 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc28_param1"], period, 1431 + utc_offset);
    london_lunch_timewindow = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc27"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc28"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc29_param1"], period, 1800 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc30_param1"], period, 1901 + utc_offset);
    newyork_lunch_timewindow = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc29"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc30"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc31_param1"], period, 1900 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc32_param1"], period, 1931 + utc_offset);
    newyork_lunch_until_1330 = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc31"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc32"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc33_param1"], period, 1530 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc34_param1"], period, 1601 + utc_offset);
    first_30min_of_trading_window = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc33"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc34"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc35_param1"], period, 1600 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc36_param1"], period, 1701 + utc_offset);
    silverbullet_am_window = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc35"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc36"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc37_param1"], period, 2000 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc38_param1"], period, 2101 + utc_offset);
    silverbullet_pm_window = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc37"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc38"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc39_param1"], period, 1450 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc40_param1"], period, 1511 + utc_offset);
    am850_makro = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc39"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc40"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc41_param1"], period, 1550 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc42_param1"], period, 1611 + utc_offset);
    am950_makro = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc41"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc42"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc43_param1"], period, 1650 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc44_param1"], period, 1711 + utc_offset);
    pre_lunch_makro = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc43"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc44"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc45_param1"], period, 1750 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc46_param1"], period, 1811 + utc_offset);
    lunch_makro = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc45"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc46"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc47_param1"], period, 2100 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc48_param1"], period, 2201 + utc_offset);
    last_hour = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc47"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc48"].GetValue(period, mode));
    SafeSetFloat(vars["number_to_4char_stringFunc49_param1"], period, 2115 + utc_offset);
    SafeSetFloat(vars["number_to_4char_stringFunc50_param1"], period, 2146 + utc_offset);
    last_hour_makro = SafeConcat(SafeConcat(vars["number_to_4char_stringFunc49"].GetValue(period, mode), "-"), vars["number_to_4char_stringFunc50"].GetValue(period, mode));
    plot_london = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_timewindow, "America/New_York") == nil, nil, 1);
    plot_newyork = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_timewindow, "America/New_York") == nil, nil, 2);
    plot_asia = Triary(PineScriptUtils:Time(period, Timeframe:Period(), asian_timewindow, "America/New_York") == nil, nil, 0);
    plot_london_entry_kill_zone = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_entry_kill_zone, "America/New_York") == nil, nil, 1.3);
    plot_london_entry_kill_zone_extended = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_entry_kill_zone_extended, "America/New_York") == nil, nil, 1.27);
    plot_london_exit_kill_zone = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_exit_kill_zone, "America/New_York") == nil, nil, 1.3);
    plot_newyork_kill_zone = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_kill_zone, "America/New_York") == nil, nil, 2.3);
    plot_newyork_kill_zone_extended = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_kill_zone_extended, "America/New_York") == nil, nil, 2.27);
    scatter_sydney = Triary(PineScriptUtils:Time(period, Timeframe:Period(), sydney_open, "America/New_York") == nil, nil, 0);
    scatter_london_midnight = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_midnight, "America/New_York") == nil, nil, 1);
    scatter_newyork_midnight = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_midnight, "America/New_York") == nil, nil, 2);
    scattter_newyork_830 = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_830, "America/New_York") == nil, nil, 2.3);
    scattter_newyork_930 = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_930, "America/New_York") == nil, nil, 2.3);
    plot_london_lunch = Triary(PineScriptUtils:Time(period, Timeframe:Period(), london_lunch_timewindow, "America/New_York") == nil, nil, 1.15);
    plot_newyork_lunch_until_1330 = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_lunch_until_1330, "America/New_York") == nil, nil, 2.15);
    plot_newyork_lunch = Triary(PineScriptUtils:Time(period, Timeframe:Period(), newyork_lunch_timewindow, "America/New_York") == nil, nil, 2.15);
    plot_first_30min_of_trading_window = Triary(PineScriptUtils:Time(period, Timeframe:Period(), first_30min_of_trading_window, "America/New_York") == nil, nil, 2.15);
    plot_silverbullet_am_window = Triary(PineScriptUtils:Time(period, Timeframe:Period(), silverbullet_am_window, "America/New_York") == nil, nil, 2.15);
    plot_silverbullet_pm_window = Triary(PineScriptUtils:Time(period, Timeframe:Period(), silverbullet_pm_window, "America/New_York") == nil, nil, 2.15);
    plot_am850_makro = Triary(PineScriptUtils:Time(period, Timeframe:Period(), am850_makro, "America/New_York") == nil, nil, 2.6);
    plot_am950_makro = Triary(PineScriptUtils:Time(period, Timeframe:Period(), am950_makro, "America/New_York") == nil, nil, 2.6);
    plot_pre_lunch_makro = Triary(PineScriptUtils:Time(period, Timeframe:Period(), pre_lunch_makro, "America/New_York") == nil, nil, 2.6);
    plot_lunch_makro = Triary(PineScriptUtils:Time(period, Timeframe:Period(), lunch_makro, "America/New_York") == nil, nil, 2.6);
    plot_last_hour = Triary(PineScriptUtils:Time(period, Timeframe:Period(), last_hour, "America/New_York") == nil, nil, 2.6);
    plot_last_hour_makro = Triary(PineScriptUtils:Time(period, Timeframe:Period(), last_hour_makro, "America/New_York") == nil, nil, 2.6);
    offset_in_ms = vars["utc_offset_input"] * 60 * 60 * 1000;
    if vars["show_weekly_separator"] and (PineScriptUtils:WeekOfYear(time:tick(period) - offset_in_ms, "America/New_York") ~= PineScriptUtils:WeekOfYear(time:tick(period) - 1 - offset_in_ms, "America/New_York")) then
        Line:New(period, 3, period, (-1)):SetColor(core.colors().Black):SetStyle("dashed"):SetWidth(2);
    end
    plot1[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_london, nil);
    plot2[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_newyork, nil);
    plot3[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_asia, nil);
    plot4[period] = plot_london_entry_kill_zone;
    plot5[period] = plot_london_entry_kill_zone_extended;
    plot6[period] = Triary((((SymInfo:GetType() == "forex") or use_assettype_filter)), plot_london_exit_kill_zone, nil);
    plot7[period] = Triary((((SymInfo:GetType() == "forex") or use_assettype_filter)), plot_newyork_kill_zone, nil);
    plot8[period] = Triary((((SymInfo:GetType() == "forex") or use_assettype_filter)), plot_newyork_kill_zone_extended, nil);
    plot9_series = scatter_london_midnight;
    if plot9_series then
        plot9:set(period, plot9_series, "\253", "");
    else
        plot9:setNoData(period);
    end
    plot10_series = scatter_newyork_midnight;
    if plot10_series then
        plot10:set(period, plot10_series, "\253", "");
    else
        plot10:setNoData(period);
    end
    plot11[period] = plot_london_lunch;
    plot12[period] = plot_newyork_lunch;
    plot13[period] = plot_newyork_lunch_until_1330;
    plot14[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_first_30min_of_trading_window, nil);
    plot15[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_silverbullet_am_window, nil);
    plot16[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_silverbullet_pm_window, nil);
    plot17[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_am850_makro, nil);
    plot18[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_am950_makro, nil);
    plot19[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_pre_lunch_makro, nil);
    plot20[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_lunch_makro, nil);
    plot21[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_last_hour, nil);
    plot22[period] = Triary(((((SymInfo:GetType() == "index") or (SymInfo:GetType() == "futures")) or use_assettype_filter)), plot_last_hour_makro, nil);
    plot23_series = scattter_newyork_830;
    if plot23_series then
        plot23:set(period, plot23_series, "\253", "");
    else
        plot23:setNoData(period);
    end
    plot24_series = scattter_newyork_930;
    if plot24_series then
        plot24:set(period, plot24_series, "\161", "");
    else
        plot24:setNoData(period);
    end
    plot25[period] = 3;
    plot26[period] = (-1);
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
SymInfo = {};
function SymInfo:GetType()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    if offer.InstrumentType == 1 then
        return "forex";
    elseif offer.InstrumentType == 2 then
        return "index";
    elseif offer.InstrumentType == 3 then
        return "commodity";
    elseif offer.InstrumentType == 4 then
        return "";
    elseif offer.InstrumentType == 5 then
        return "";
    elseif offer.InstrumentType == 6 then
        return "";
    elseif offer.InstrumentType == 7 then
        return "";
    elseif offer.InstrumentType == 8 then
        return "";
    elseif offer.InstrumentType == 9 then
        return "crypto";
    end
    return "";
end
function SymInfo:GetBaseCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.ContractCurrency;
end
function SymInfo:GetCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.Instrument;
end
function SymInfo:GetTicker()
    return instance.source:instrument();
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
function Str:Length(str)
    if str == nil then
        return 0;
    end
    return string.len(str);
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