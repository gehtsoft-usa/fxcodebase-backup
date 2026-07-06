-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76475
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.
local vars = {};
function Init()
    indicator:name("RSI adaptive zones [AdaptiveRSI]");
    indicator:description("RSI adaptive zones [AdaptiveRSI]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("param1", "Length", "", 14, 2);
    indicator.parameters:addString("param2", "Plot RSI As:", "", "candle");
    indicator.parameters:addStringAlternative("param2", "line", "", "line");
    indicator.parameters:addStringAlternative("param2", "bar", "", "bar");
    indicator.parameters:addStringAlternative("param2", "candle", "", "candle");
    indicator.parameters:addColor("param3", "", "", core.colors().Gray);
    indicator.parameters:addBoolean("param4", "Support / Resistance Zones", "", true);
    indicator.parameters:addColor("param5", "", "", Graphics:GetColor(core.colors().Gray + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addBoolean("param6", "Oversold / Overbought Zones", "", true);
    indicator.parameters:addColor("param7", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(217, 35, 35), 0)));
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(51, 166, 69), 0)));
    indicator.parameters:addBoolean("param9", "Oversold / Overbought Coloring", "", true);
    indicator.parameters:addColor("param10", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(51, 230, 67), 0)));
    indicator.parameters:addColor("param11", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(242, 39, 56), 0)));
end

local source;
local plot1;
local plot2_open;
local plot2_high;
local plot2_low;
local plot2_close;
local plot3_open;
local plot3_high;
local plot3_low;
local plot3_close;
local plot4_c;
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
function Create_TANH()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(x, period, mode)
            local_vars["ex"] = SafeExp(SafeMultiply(2.0, x));
            return SafeDivide((SafeMinus(local_vars["ex"], 1.0)), (SafePlus(local_vars["ex"], 1.0)));
        end
    };
end
function Create_RSI_distance_from50()
    local local_vars = {};
    local_vars["TANHFunc2"] = Create_TANH();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(z, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["TANHFunc2"].Clear();
            else
            end
            return SafeMultiply(vars["half_range"], local_vars["TANHFunc2"].GetValue(SafeMultiply(z, vars["inv_sqrt_lenm1"]), period, mode));
        end
    };
end
function Create_RSI_distance_from50_f(z)
    local local_vars = {};
    local_vars["TANHFunc4"] = Create_TANH();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["TANHFunc4"].Clear();
            else
            end
            return SafeMultiply(vars["half_range"], local_vars["TANHFunc4"].GetValue(SafeMultiply(z, vars["inv_sqrt_lenm1"]), period, mode));
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
    vars["Length"] = instance.parameters.param1;
    vars["RSIType"] = instance.parameters.param2;
    vars["color_RSI"] = instance.parameters.param3;
    vars["SupRes"] = instance.parameters.param4;
    vars["color_SR"] = Graphics:AddTransparency(instance.parameters.param5, Graphics:GetTransparencyPercent(core.colors().Gray + math.floor(50 / 100 * 255) * 16777216));
    vars["OO"] = instance.parameters.param6;
    vars["color_R"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(217, 35, 35), 0)));
    vars["color_G"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(51, 166, 69), 0)));
    vars["OO_coloring"] = instance.parameters.param9;
    vars["color_GI"] = Graphics:AddTransparency(instance.parameters.param10, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(51, 230, 67), 0)));
    vars["color_RI"] = Graphics:AddTransparency(instance.parameters.param11, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(242, 39, 56), 0)));
    vars["middle"] = instance:addInternalStream(0, 0);
    vars["SMMA1"] = core.indicators:create("SMMA", source.close, vars["Length"]);
    vars["CC_vol"] = instance:addInternalStream(0, 0);
    vars["SMMA2_source"] = instance:addInternalStream(0, 0);
    vars["SMMA2"] = core.indicators:create("SMMA", vars["SMMA2_source"], vars["Length"]);
    vars["RSI_distance_from50Func1"] = Create_RSI_distance_from50();
    vars["RSI_distance_from50Func3"] = Create_RSI_distance_from50_f(vars["breakout_threshold"]);
    vars["RSI_distance_from50Func5"] = Create_RSI_distance_from50();
    vars["RSI_distance_from50Func6"] = Create_RSI_distance_from50();
    plot1_color = vars["color_RSI"] + math.floor(25 / 100 * 255) * 16777216;
    plot1 = instance:addStream("plot1", core.Line, "RSI Line", "RSI Line", plot1_color or core.colors().Blue, 0, 0);
    plot1:setWidth(2);
    if (plot1_color == nil) then
        plot1:setStyle(core.LINE_NONE);
    else
        plot1:setStyle(core.LINE_SOLID);
    end
    plot2_open = instance:addStream("plot2_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot2_high = instance:addStream("plot2_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot2_low = instance:addStream("plot2_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot2_close = instance:addStream("plot2_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot2", "plot2", plot2_open, plot2_high, plot2_low, plot2_close);
    plot3_open = instance:addStream("plot3_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot3_high = instance:addStream("plot3_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot3_low = instance:addStream("plot3_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot3_close = instance:addStream("plot3_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot3", "plot3", plot3_open, plot3_high, plot3_low, plot3_close);
    plot4_c = instance:createTextOutput("plot4", "Dots", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    plot4 = instance:addInternalStream(0, 0);
    plot5_color = vars["color_RSI"] + math.floor(50 / 100 * 255) * 16777216;
    plot5 = instance:addStream("plot5", core.Line, "Middle", "Middle", plot5_color or core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    if (plot5_color == nil) then
        plot5:setStyle(core.LINE_NONE);
    else
    end
    vars["rsiMiddle"] = plot5;
    plot6_color = core.colors().Blue;
    plot6 = instance:addStream("plot6", core.Line, "Top of Overbought", "Top of Overbought", plot6_color or core.colors().Blue, 0, 0);
    plot6:setWidth(1);
    if (plot6_color == nil) then
        plot6:setStyle(core.LINE_NONE);
    else
        plot6:setStyle(core.LINE_SOLID);
    end
    vars["overbought"] = plot6;
    plot7_color = core.colors().Blue;
    plot7 = instance:addStream("plot7", core.Line, "Bottom of Overbought", "Bottom of Overbought", plot7_color or core.colors().Blue, 0, 0);
    plot7:setWidth(1);
    if (plot7_color == nil) then
        plot7:setStyle(core.LINE_NONE);
    else
        plot7:setStyle(core.LINE_SOLID);
    end
    vars["overbought1"] = plot7;
    vars["channel1_top"] = instance:addStream("channel1_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel1_bottom"] = instance:addInternalStream(0, 0);
    channel1_color = core.colors().Blue;
    instance:createChannelGroup("channel1", "channel1", vars["channel1_top"], vars["channel1_bottom"], channel1_color, channel1_color and 100 - Graphics:GetTransparencyPercent(channel1_color) or 100, true);
    plot8_color = core.colors().Blue;
    plot8 = instance:addStream("plot8", core.Line, "Bottom of Oversold", "Bottom of Oversold", plot8_color or core.colors().Blue, 0, 0);
    plot8:setWidth(1);
    if (plot8_color == nil) then
        plot8:setStyle(core.LINE_NONE);
    else
        plot8:setStyle(core.LINE_SOLID);
    end
    vars["oversold"] = plot8;
    plot9_color = core.colors().Blue;
    plot9 = instance:addStream("plot9", core.Line, "Top of Oversold", "Top of Oversold", plot9_color or core.colors().Blue, 0, 0);
    plot9:setWidth(1);
    if (plot9_color == nil) then
        plot9:setStyle(core.LINE_NONE);
    else
        plot9:setStyle(core.LINE_SOLID);
    end
    vars["oversold1"] = plot9;
    vars["channel2_top"] = instance:addStream("channel2_top", core.Line, "", "", core.colors().Blue, 0, 0);
    vars["channel2_bottom"] = instance:addInternalStream(0, 0);
    channel2_color = core.colors().Blue;
    instance:createChannelGroup("channel2", "channel2", vars["channel2_top"], vars["channel2_bottom"], channel2_color, channel2_color and 100 - Graphics:GetTransparencyPercent(channel2_color) or 100, true);
    plot10_color = core.colors().Blue;
    plot10 = instance:addStream("plot10", core.Line, "Top of Resistance", "Top of Resistance", plot10_color or core.colors().Blue, 0, 0);
    plot10:setWidth(1);
    if (plot10_color == nil) then
        plot10:setStyle(core.LINE_NONE);
    else
        plot10:setStyle(core.LINE_SOLID);
    end
    vars["R1"] = plot10;
    plot11_color = core.colors().Blue;
    plot11 = instance:addStream("plot11", core.Line, "Bottom of Resistance", "Bottom of Resistance", plot11_color or core.colors().Blue, 0, 0);
    plot11:setWidth(1);
    if (plot11_color == nil) then
        plot11:setStyle(core.LINE_NONE);
    else
        plot11:setStyle(core.LINE_SOLID);
    end
    vars["R2"] = plot11;
    vars["!channel3_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel3_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel3_1_c"] = vars["color_SR"];
    if (vars["!channel3_1_c"] ~= nil) then
        instance:createChannelGroup("channel3_1", "channel3_1", vars["!channel3_1_u"], vars["!channel3_1_d"], Graphics:GetColor(vars["!channel3_1_c"]), vars["!channel3_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel3_1_c"]) or 100);
    end
    vars["!channel3_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel3_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel3_2_c"] = vars["color_RSI"] + math.floor(100 / 100 * 255) * 16777216;
    if (vars["!channel3_2_c"] ~= nil) then
        instance:createChannelGroup("channel3_2", "channel3_2", vars["!channel3_2_u"], vars["!channel3_2_d"], Graphics:GetColor(vars["!channel3_2_c"]), vars["!channel3_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel3_2_c"]) or 100);
    end
    plot12_color = core.colors().Blue;
    plot12 = instance:addStream("plot12", core.Line, "Top of Support", "Top of Support", plot12_color or core.colors().Blue, 0, 0);
    plot12:setWidth(1);
    if (plot12_color == nil) then
        plot12:setStyle(core.LINE_NONE);
    else
        plot12:setStyle(core.LINE_SOLID);
    end
    vars["S1"] = plot12;
    plot13_color = core.colors().Blue;
    plot13 = instance:addStream("plot13", core.Line, "Bottom of Support", "Bottom of Support", plot13_color or core.colors().Blue, 0, 0);
    plot13:setWidth(1);
    if (plot13_color == nil) then
        plot13:setStyle(core.LINE_NONE);
    else
        plot13:setStyle(core.LINE_SOLID);
    end
    vars["S2"] = plot13;
    vars["!channel4_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel4_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel4_1_c"] = vars["color_SR"];
    if (vars["!channel4_1_c"] ~= nil) then
        instance:createChannelGroup("channel4_1", "channel4_1", vars["!channel4_1_u"], vars["!channel4_1_d"], Graphics:GetColor(vars["!channel4_1_c"]), vars["!channel4_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel4_1_c"]) or 100);
    end
    vars["!channel4_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel4_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel4_2_c"] = vars["color_RSI"] + math.floor(100 / 100 * 255) * 16777216;
    if (vars["!channel4_2_c"] ~= nil) then
        instance:createChannelGroup("channel4_2", "channel4_2", vars["!channel4_2_u"], vars["!channel4_2_d"], Graphics:GetColor(vars["!channel4_2_c"]), vars["!channel4_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel4_2_c"]) or 100);
    end
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        vars["RSI_distance_from50Func1"].Clear();
        vars["RSI_distance_from50Func3"].Clear();
        vars["RSI_distance_from50Func5"].Clear();
        vars["RSI_distance_from50Func6"].Clear();
    else
    end
    vars["SF"] = 1.0 / vars["Length"];
    vars["power_exponent"] = 0.5;
    vars["inv_sqrt_lenm1"] = SafeDivide(1.0, math.pow(vars["Length"] - 1.0, vars["power_exponent"]));
    vars["half_range"] = 50.0;
    vars["eps"] = 1e-10;
    vars["SMMA1"]:update(mode);
    SafeSetFloat(vars["middle"], period, vars["SMMA1"].DATA:tick(period));
    vars["middle_O"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["middle"], period - 1)), SafeMultiply(vars["SF"], source.open:tick(period)));
    vars["middle_H"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["middle"], period - 1)), SafeMultiply(vars["SF"], source.high:tick(period)));
    vars["middle_L"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["middle"], period - 1)), SafeMultiply(vars["SF"], source.low:tick(period)));
    SafeSetFloat(vars["SMMA2_source"], period, SafeAbs(SafeMinus(source.close:tick(period), source.close:tick(period - 1))));
    vars["SMMA2"]:update(mode);
    SafeSetFloat(vars["CC_vol"], period, vars["SMMA2"].DATA:tick(period));
    vars["CC_vol_O"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["CC_vol"], period - 1)), SafeMultiply(vars["SF"], SafeAbs(SafeMinus(source.open:tick(period), source.close:tick(period - 1)))));
    vars["CC_vol_H"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["CC_vol"], period - 1)), SafeMultiply(vars["SF"], SafeAbs(SafeMinus(source.high:tick(period), source.close:tick(period - 1)))));
    vars["CC_vol_L"] = SafePlus(SafeMultiply((SafeMinus(1, vars["SF"])), SafeGetFloat(vars["CC_vol"], period - 1)), SafeMultiply(vars["SF"], SafeAbs(SafeMinus(source.low:tick(period), source.close:tick(period - 1)))));
    vars["den_C"] = SafeMultiply(SafeMax(SafeGetFloat(vars["CC_vol"], period), vars["eps"]), (vars["Length"] - 1.0));
    vars["den_O"] = SafeMultiply(SafeMax(vars["CC_vol_O"], vars["eps"]), (vars["Length"] - 1.0));
    vars["den_H"] = SafeMultiply(SafeMax(vars["CC_vol_H"], vars["eps"]), (vars["Length"] - 1.0));
    vars["den_L"] = SafeMultiply(SafeMax(vars["CC_vol_L"], vars["eps"]), (vars["Length"] - 1.0));
    vars["myRSI"] = SafePlus(vars["half_range"], SafeMultiply(vars["half_range"], (SafeDivide((SafeMinus(source.close:tick(period), SafeGetFloat(vars["middle"], period))), vars["den_C"]))));
    vars["RSI_O"] = SafePlus(vars["half_range"], SafeMultiply(vars["half_range"], (SafeDivide((SafeMinus(source.open:tick(period), vars["middle_O"])), vars["den_O"]))));
    vars["RSI_H"] = SafePlus(vars["half_range"], SafeMultiply(vars["half_range"], (SafeDivide((SafeMinus(source.high:tick(period), vars["middle_H"])), vars["den_H"]))));
    vars["RSI_L"] = SafePlus(vars["half_range"], SafeMultiply(vars["half_range"], (SafeDivide((SafeMinus(source.low:tick(period), vars["middle_L"])), vars["den_L"]))));
    vars["body_threshold"] = SafeSqrt(SafeDivide((SafeMinus(5.0, math.sqrt(17.0))), 2.0));
    vars["tail_threshold"] = SafeSqrt(SafeDivide((SafePlus(5.0, math.sqrt(17.0))), 2.0));
    vars["breakout_threshold"] = 1.0;
    vars["reversal_threshold"] = math.sqrt(3.0);
    vars["Z_ins"] = vars["RSI_distance_from50Func1"].GetValue(vars["body_threshold"], period, mode);
    vars["Z_out"] = vars["RSI_distance_from50Func3"].GetValue(period, mode);
    vars["OO_ins"] = vars["RSI_distance_from50Func5"].GetValue(vars["reversal_threshold"], period, mode);
    vars["OO_out"] = vars["RSI_distance_from50Func6"].GetValue(vars["tail_threshold"], period, mode);
    vars["color_1"] = Triary(vars["SupRes"], vars["color_SR"], vars["color_RSI"] + math.floor(100 / 100 * 255) * 16777216);
    vars["color_RM"] = Triary(vars["OO"], vars["color_R"] + math.floor(15 / 100 * 255) * 16777216, core.colors().Red + math.floor(100 / 100 * 255) * 16777216);
    vars["color_GM"] = Triary(vars["OO"], vars["color_G"] + math.floor(15 / 100 * 255) * 16777216, core.colors().Green + math.floor(100 / 100 * 255) * 16777216);
    vars["opacity_OO"] = Triary(vars["OO"], 90, 100);
    vars["isCandleUp"] = SafeGreater(vars["myRSI"], vars["RSI_O"]);
    vars["opacity_candle"] = Triary(vars["isCandleUp"], 90, 10);
    vars["isOB_line"] = SafeGreater(vars["myRSI"], (SafePlus(50, vars["OO_ins"])));
    vars["isOS_line"] = SafeLess(vars["myRSI"], (SafeMinus(50, vars["OO_ins"])));
    vars["isOB_OHLC"] = (period >= vars["Length"]) and SafeGreater(vars["RSI_H"], SafePlus(50, vars["OO_ins"]));
    vars["isOS_OHLC"] = (period >= vars["Length"]) and SafeLess(vars["RSI_L"], SafeMinus(50, vars["OO_ins"]));
    vars["BC_color"] = Triary(not (vars["OO_coloring"]), vars["color_RSI"] + math.floor(vars["opacity_candle"] / 100 * 255) * 16777216, Triary(vars["isOB_OHLC"], vars["color_RI"] + math.floor(vars["opacity_candle"] / 100 * 255) * 16777216, Triary(vars["isOS_OHLC"], vars["color_GI"] + math.floor(vars["opacity_candle"] / 100 * 255) * 16777216, vars["color_RSI"] + math.floor(vars["opacity_candle"] / 100 * 255) * 16777216)));
    vars["border_color"] = Triary(not (vars["OO_coloring"]), vars["color_RSI"] + math.floor(0 / 100 * 255) * 16777216, Triary(vars["isOB_OHLC"], vars["color_RI"], Triary(vars["isOS_OHLC"], vars["color_GI"], vars["color_RSI"] + math.floor(0 / 100 * 255) * 16777216)));
    Plot:SetValue(plot1, period, Triary((vars["RSIType"] == "line"), vars["myRSI"], nil));
    plot2_open_value = Triary((vars["RSIType"] == "candle"), vars["RSI_O"], nil);
    plot2_close_value = Triary((vars["RSIType"] == "candle"), vars["myRSI"], nil);
    plot2_color = vars["BC_color"];
    if plot2_color then
        plot2_open[period] = plot2_open_value;
        plot2_high[period] = Triary((vars["RSIType"] == "candle"), vars["RSI_H"], nil);
        plot2_low[period] = Triary((vars["RSIType"] == "candle"), vars["RSI_L"], nil);
        plot2_close[period] = plot2_close_value;
        plot2_open:setColor(period, Graphics:GetColor(plot2_color));
    else
        plot2_open:setNoData(period);
        plot2_high:setNoData(period);
        plot2_low:setNoData(period);
        plot2_close:setNoData(period);
    end
    plot3_open_value = Triary((vars["RSIType"] == "bar"), vars["RSI_O"], nil);
    plot3_close_value = Triary((vars["RSIType"] == "bar"), vars["myRSI"], nil);
    plot3_color = vars["border_color"];
    if plot3_color then
        plot3_open[period] = plot3_open_value;
        plot3_high[period] = Triary((vars["RSIType"] == "bar"), vars["RSI_H"], nil);
        plot3_low[period] = Triary((vars["RSIType"] == "bar"), vars["RSI_L"], nil);
        plot3_close[period] = plot3_close_value;
        plot3_open:setColor(period, Graphics:GetColor(plot3_color));
    else
        plot3_open:setNoData(period);
        plot3_high:setNoData(period);
        plot3_low:setNoData(period);
        plot3_close:setNoData(period);
    end
    plot4_series = Triary(vars["OO_coloring"] and (vars["RSIType"] == "line") and ((vars["isOB_line"] or vars["isOS_line"])), vars["myRSI"], nil);
    plot4[period] = PlotShape:SetValue(plot4_c, period, source, plot4_series, "\161", "", nil, vars["border_color"]);
    Plot:SetValue(plot5, period, 50);
    Plot:SetValueWithColor(plot6, period, SafePlus(50, vars["OO_out"]), Graphics:GetColor(vars["color_GM"]));
    Plot:SetValueWithColor(plot7, period, SafePlus(50, vars["OO_ins"]), Graphics:GetColor(vars["color_G"] + math.floor(vars["opacity_OO"] / 100 * 255) * 16777216));
    vars["channel1_top"][period] = vars["overbought"][period];
    vars["channel1_bottom"][period] = vars["overbought1"][period];
    channel1_avg = (vars["channel1_top"][period] + vars["channel1_bottom"][period]) / 2;
    vars["channel1_top_value"] = SafePlus(50, vars["OO_out"]);
    vars["channel1_bottom_value"] = SafePlus(50, vars["OO_ins"]);
    if (channel1_avg <= vars["channel1_top_value"] and channel1_avg >= vars["channel1_bottom_value"]) then
        vars["channel1_top"]:setColor(period, Color:FromGradient(channel1_avg, vars["channel1_bottom_value"], vars["channel1_top_value"], vars["color_G"] + math.floor(vars["opacity_OO"] / 100 * 255) * 16777216, vars["color_GM"]));
    end
    Plot:SetValueWithColor(plot8, period, SafeMinus(50, vars["OO_out"]), Graphics:GetColor(vars["color_RM"]));
    Plot:SetValueWithColor(plot9, period, SafeMinus(50, vars["OO_ins"]), Graphics:GetColor(vars["color_R"] + math.floor(vars["opacity_OO"] / 100 * 255) * 16777216));
    vars["channel2_top"][period] = vars["oversold1"][period];
    vars["channel2_bottom"][period] = vars["oversold"][period];
    channel2_avg = (vars["channel2_top"][period] + vars["channel2_bottom"][period]) / 2;
    vars["channel2_top_value"] = SafeMinus(50, vars["OO_ins"]);
    vars["channel2_bottom_value"] = SafeMinus(50, vars["OO_out"]);
    if (channel2_avg <= vars["channel2_top_value"] and channel2_avg >= vars["channel2_bottom_value"]) then
        vars["channel2_top"]:setColor(period, Color:FromGradient(channel2_avg, vars["channel2_bottom_value"], vars["channel2_top_value"], vars["color_RM"], vars["color_R"] + math.floor(vars["opacity_OO"] / 100 * 255) * 16777216));
    end
    Plot:SetValueWithColor(plot10, period, SafePlus(50, vars["Z_out"]), Graphics:GetColor(vars["color_1"]));
    Plot:SetValueWithColor(plot11, period, SafePlus(50, vars["Z_ins"]), Graphics:GetColor(vars["color_1"]));
    channel3_from = vars["R1"][period];
    channel3_to = vars["R2"][period];
    channel3_c = vars["color_1"];
    Fill:SetValue(vars["!channel3_1_u"], vars["!channel3_1_d"], channel3_from, channel3_to, vars["!channel3_1_c"] == channel3_c, period);
    Fill:SetValue(vars["!channel3_2_u"], vars["!channel3_2_d"], channel3_from, channel3_to, vars["!channel3_2_c"] == channel3_c, period);
    Plot:SetValueWithColor(plot12, period, SafeMinus(50, vars["Z_ins"]), Graphics:GetColor(vars["color_1"]));
    Plot:SetValueWithColor(plot13, period, SafeMinus(50, vars["Z_out"]), Graphics:GetColor(vars["color_1"]));
    channel4_from = vars["S2"][period];
    channel4_to = vars["S1"][period];
    channel4_c = vars["color_1"];
    Fill:SetValue(vars["!channel4_1_u"], vars["!channel4_1_d"], channel4_from, channel4_to, vars["!channel4_1_c"] == channel4_c, period);
    Fill:SetValue(vars["!channel4_2_u"], vars["!channel4_2_d"], channel4_from, channel4_to, vars["!channel4_2_c"] == channel4_c, period);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function SafeSqrt(value)
    if value == nil then
        return nil;
    end
    return math.sqrt(value);
end
function SafeExp(value)
    if value == nil then
        return nil;
    end
    return math.exp(value);
end
Plot = {};
function Plot:SetValueWithColor(plot, period, value, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if Plot:SetValue(plot, period, value) then
        plot:setColor(period, clr)
    end
end
function Plot:SetValue(plot, period, value)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value then
        plot:setNoData(period);
        return false;
    end
    plot[period] = value;
    return true;
end
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value or transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label, clr);
        return source.high[period];
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label, clr);
        return source.low[period];
    end
    plot:set(period, value, text, label, clr);
    return value;
end
Color = {};
function Color:GetR(color)
    return color % 256;
end
function Color:GetG(color)
    local R = Color:GetR(color);
    return ((color - R) / 256) % 256;
end
function Color:GetB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:GetRGB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return R, G, ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:FromGradient(value, bottom_value, top_value, bottom_color, top_color)
    if bottom_color == nil then
        if top_color == nil then
            return nil;
        end
        bottom_color =  Graphics:AddTransparency(Graphics:GetColor(top_color), 0);
    end
    if top_color == nil then
        top_color =  Graphics:AddTransparency(Graphics:GetColor(bottom_color), 0);
    end
    if (value == nil or top_value == nil) then
        return bottom_color;
    end
    if (bottom_value == nil) then
        return top_color;
    end
    local range = top_value - bottom_value;
    local rate = (value - bottom_value) / range;
    if (rate > 1) then
        return bottom_color;
    end
    if (rate < 0) then
        return top_color;
    end
    
    local bottomR, bottomG, bottomB = Color:GetRGB(bottom_color);
    local topR, topG, topB = Color:GetRGB(top_color);
    return core.rgb(bottomR + math.floor(rate * (topR - bottomR)), 
        bottomG + math.floor(rate * (topG - bottomG)), 
        bottomB + math.floor(rate * (topB - bottomB)), 0);
end
Fill = {};
function Fill:SetValue(up_channel, dn_channel, value1, value2, mineColor, period)
    if value1 == nil or value2 == nil or mineColor ~= true then
        up_channel:setNoData(period);
        dn_channel:setNoData(period);
        return;
    end
    up_channel[period] = math.max(value1, value2);
    dn_channel[period] = math.min(value1, value2);
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76475
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.