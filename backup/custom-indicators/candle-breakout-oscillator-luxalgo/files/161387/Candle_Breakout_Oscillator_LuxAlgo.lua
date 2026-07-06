-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76476
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
    indicator:name("Candle Breakout Oscillator [LuxAlgo]");
    indicator:description("Candle Breakout Oscillator [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("param1", "Window", "", 100);
    vars["RMA"] = "RMA";
    indicator.parameters:addString("param2", "Smoothing Method", "", vars["RMA"]);
    vars["NONE"] = "None";
    indicator.parameters:addStringAlternative("param2", vars["NONE"], "", vars["NONE"]);
    indicator.parameters:addStringAlternative("param2", vars["RMA"], "", vars["RMA"]);
    vars["SMA"] = "SMA";
    indicator.parameters:addStringAlternative("param2", vars["SMA"], "", vars["SMA"]);
    vars["TMA"] = "TMA";
    indicator.parameters:addStringAlternative("param2", vars["TMA"], "", vars["TMA"]);
    vars["EMA"] = "EMA";
    indicator.parameters:addStringAlternative("param2", vars["EMA"], "", vars["EMA"]);
    vars["DEMA"] = "DEMA";
    indicator.parameters:addStringAlternative("param2", vars["DEMA"], "", vars["DEMA"]);
    vars["TEMA"] = "TEMA";
    indicator.parameters:addStringAlternative("param2", vars["TEMA"], "", vars["TEMA"]);
    vars["HMA"] = "HMA";
    indicator.parameters:addStringAlternative("param2", vars["HMA"], "", vars["HMA"]);
    vars["WMA"] = "WMA";
    indicator.parameters:addStringAlternative("param2", vars["WMA"], "", vars["WMA"]);
    vars["SWMA"] = "SWMA";
    indicator.parameters:addStringAlternative("param2", vars["SWMA"], "", vars["SWMA"]);
    vars["VWMA"] = "VWMA";
    indicator.parameters:addStringAlternative("param2", vars["VWMA"], "", vars["VWMA"]);
    indicator.parameters:addInteger("param3", "Smoothing Length", "", 2, 1, 100);
    indicator.parameters:addString("param4", "Weighting Method", "", vars["NONE"]);
    indicator.parameters:addStringAlternative("param4", vars["NONE"], "", vars["NONE"]);
    vars["VOLUME"] = "Volume";
    indicator.parameters:addStringAlternative("param4", vars["VOLUME"], "", vars["VOLUME"]);
    vars["PRICE"] = "Price";
    indicator.parameters:addStringAlternative("param4", vars["PRICE"], "", vars["PRICE"]);
    indicator.parameters:addInteger("param5", "Top", "", 80, 50, 100);
    indicator.parameters:addInteger("param6", "Bottom", "", 20, 0, 50);
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
local plot8;
function Create_parseWeight()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(weight, period, mode)
            return Triary((vars["weightTypeInput"] ~= vars["NONE"]), (Triary((vars["weightTypeInput"] == vars["VOLUME"]), source.volume:tick(period), weight)), 1);
        end
    };
end
function Create_addData_i(size)
    local local_vars = {};
    local_vars["parseWeightFunc2"] = Create_parseWeight();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(a_rray, value, weight, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["parseWeightFunc2"].Clear();
            else
            end
            a_rray:Push(SafeMultiply(value, local_vars["parseWeightFunc2"].GetValue(weight, period, mode)));
            if SafeGreater(a_rray:Size(), size) then
                a_rray:Shift();
                return a_rray:Shift();
            end
        end
    };
end
function Create_parseWeight_i(weight)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return Triary((vars["weightTypeInput"] ~= vars["NONE"]), (Triary((vars["weightTypeInput"] == vars["VOLUME"]), source.volume:tick(period), weight)), 1);
        end
    };
end
function Create_addData_i_i(size, weight)
    local local_vars = {};
    local_vars["parseWeightFunc5"] = Create_parseWeight_i(weight);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(a_rray, value, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["parseWeightFunc5"].Clear();
            else
            end
            a_rray:Push(SafeMultiply(value, local_vars["parseWeightFunc5"].GetValue(period, mode)));
            if SafeGreater(a_rray:Size(), size) then
                a_rray:Shift();
                return a_rray:Shift();
            end
        end
    };
end
function Create_addWeight_i(size)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(a_rray, value, period, mode)
            a_rray:Push(value);
            if SafeGreater(a_rray:Size(), size) then
                a_rray:Shift();
                return a_rray:Shift();
            end
        end
    };
end
function Create_addWeight_i_i(value, size)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(a_rray, period, mode)
            a_rray:Push(value);
            if SafeGreater(a_rray:Size(), size) then
                a_rray:Shift();
                return a_rray:Shift();
            end
        end
    };
end
function Create_smooth()
    local local_vars = {};
    local_vars["SMMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["SMMA1"] = core.indicators:create("SMMA", local_vars["SMMA1_source"], vars["smoothingLengthInput"]);
    local_vars["MVA1_source"] = instance:addInternalStream(0, 0);
    local_vars["MVA1"] = core.indicators:create("MVA", local_vars["MVA1_source"], vars["smoothingLengthInput"]);
    local_vars["MVA3_source"] = instance:addInternalStream(0, 0);
    local_vars["MVA3"] = core.indicators:create("MVA", local_vars["MVA3_source"], vars["smoothingLengthInput"]);
    local_vars["MVA2_source"] = instance:addInternalStream(0, 0);
    local_vars["MVA2"] = core.indicators:create("MVA", local_vars["MVA2_source"], vars["smoothingLengthInput"]);
    local_vars["EMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA1"] = core.indicators:create("EMA", local_vars["EMA1_source"], vars["smoothingLengthInput"]);
    local_vars["EMA2_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA2"] = core.indicators:create("EMA", local_vars["EMA2_source"], vars["smoothingLengthInput"]);
    local_vars["EMA4_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA4"] = core.indicators:create("EMA", local_vars["EMA4_source"], vars["smoothingLengthInput"]);
    local_vars["EMA3_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA3"] = core.indicators:create("EMA", local_vars["EMA3_source"], vars["smoothingLengthInput"]);
    local_vars["EMA5_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA5"] = core.indicators:create("EMA", local_vars["EMA5_source"], vars["smoothingLengthInput"]);
    local_vars["EMA7_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA7"] = core.indicators:create("EMA", local_vars["EMA7_source"], vars["smoothingLengthInput"]);
    local_vars["EMA6_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA6"] = core.indicators:create("EMA", local_vars["EMA6_source"], vars["smoothingLengthInput"]);
    local_vars["EMA8_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA8"] = core.indicators:create("EMA", local_vars["EMA8_source"], vars["smoothingLengthInput"]);
    local_vars["EMA10_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA10"] = core.indicators:create("EMA", local_vars["EMA10_source"], vars["smoothingLengthInput"]);
    local_vars["EMA9_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA9"] = core.indicators:create("EMA", local_vars["EMA9_source"], vars["smoothingLengthInput"]);
    local_vars["EMA13_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA13"] = core.indicators:create("EMA", local_vars["EMA13_source"], vars["smoothingLengthInput"]);
    local_vars["EMA12_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA12"] = core.indicators:create("EMA", local_vars["EMA12_source"], vars["smoothingLengthInput"]);
    local_vars["EMA11_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA11"] = core.indicators:create("EMA", local_vars["EMA11_source"], vars["smoothingLengthInput"]);
    local_vars["EMA14_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA14"] = core.indicators:create("EMA", local_vars["EMA14_source"], vars["smoothingLengthInput"]);
    local_vars["EMA16_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA16"] = core.indicators:create("EMA", local_vars["EMA16_source"], vars["smoothingLengthInput"]);
    local_vars["EMA15_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA15"] = core.indicators:create("EMA", local_vars["EMA15_source"], vars["smoothingLengthInput"]);
    local_vars["EMA19_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA19"] = core.indicators:create("EMA", local_vars["EMA19_source"], vars["smoothingLengthInput"]);
    local_vars["EMA18_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA18"] = core.indicators:create("EMA", local_vars["EMA18_source"], vars["smoothingLengthInput"]);
    local_vars["EMA17_source"] = instance:addInternalStream(0, 0);
    local_vars["EMA17"] = core.indicators:create("EMA", local_vars["EMA17_source"], vars["smoothingLengthInput"]);
                assert(core.indicators:findIndicator("PINESCRIPT HMA") ~= nil, "Please, download and install PINESCRIPT HMA.lua indicator");
    local_vars["PINESCRIPT HMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["PINESCRIPT HMA1"] = core.indicators:create("PINESCRIPT HMA", local_vars["PINESCRIPT HMA1_source"], vars["smoothingLengthInput"]);
    local_vars["WMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["WMA1"] = core.indicators:create("WMA", local_vars["WMA1_source"], vars["smoothingLengthInput"]);
    local_vars["PINESCRIPT SWMA1"] = core.indicators:create("PINESCRIPT SWMA", source);
    local_vars["VOLUME WEIGHTED MOVING AVERAGE1_source"] = instance:addInternalStream(0, 0);
    local_vars["VOLUME WEIGHTED MOVING AVERAGE1"] = core.indicators:create("VOLUME WEIGHTED MOVING AVERAGE", local_vars["VOLUME WEIGHTED MOVING AVERAGE1_source"], vars["smoothingLengthInput"]);
    return {
        Clear = function()
        end,
        GetValue = function(data, period, mode)
            if vars["RMA"] then
                SafeSetFloat(local_vars["SMMA1_source"], period, data);
                local_vars["SMMA1"]:update(mode);
                return local_vars["SMMA1"].DATA:tick(period);
            elseif vars["SMA"] then
                SafeSetFloat(local_vars["MVA1_source"], period, data);
                local_vars["MVA1"]:update(mode);
                return local_vars["MVA1"].DATA:tick(period);
            elseif vars["TMA"] then
                SafeSetFloat(local_vars["MVA3_source"], period, data);
                local_vars["MVA3"]:update(mode);
                SafeSetFloat(local_vars["MVA2_source"], period, local_vars["MVA3"].DATA:tick(period));
                local_vars["MVA2"]:update(mode);
                return local_vars["MVA2"].DATA:tick(period);
            elseif vars["EMA"] then
                SafeSetFloat(local_vars["EMA1_source"], period, data);
                local_vars["EMA1"]:update(mode);
                return local_vars["EMA1"].DATA:tick(period);
            elseif vars["DEMA"] then
                SafeSetFloat(local_vars["EMA2_source"], period, data);
                local_vars["EMA2"]:update(mode);
                SafeSetFloat(local_vars["EMA4_source"], period, data);
                local_vars["EMA4"]:update(mode);
                SafeSetFloat(local_vars["EMA3_source"], period, local_vars["EMA4"].DATA:tick(period));
                local_vars["EMA3"]:update(mode);
                SafeMinus(SafeMultiply(2, local_vars["EMA2"].DATA:tick(period)), local_vars["EMA3"].DATA:tick(period));
                SafeSetFloat(local_vars["EMA5_source"], period, data);
                local_vars["EMA5"]:update(mode);
                SafeSetFloat(local_vars["EMA7_source"], period, data);
                local_vars["EMA7"]:update(mode);
                SafeSetFloat(local_vars["EMA6_source"], period, local_vars["EMA7"].DATA:tick(period));
                local_vars["EMA6"]:update(mode);
                return SafeMinus(SafeMultiply(2, local_vars["EMA5"].DATA:tick(period)), local_vars["EMA6"].DATA:tick(period));
            elseif vars["TEMA"] then
                SafeSetFloat(local_vars["EMA8_source"], period, data);
                local_vars["EMA8"]:update(mode);
                SafeSetFloat(local_vars["EMA10_source"], period, data);
                local_vars["EMA10"]:update(mode);
                SafeSetFloat(local_vars["EMA9_source"], period, local_vars["EMA10"].DATA:tick(period));
                local_vars["EMA9"]:update(mode);
                SafeSetFloat(local_vars["EMA13_source"], period, data);
                local_vars["EMA13"]:update(mode);
                SafeSetFloat(local_vars["EMA12_source"], period, local_vars["EMA13"].DATA:tick(period));
                local_vars["EMA12"]:update(mode);
                SafeSetFloat(local_vars["EMA11_source"], period, local_vars["EMA12"].DATA:tick(period));
                local_vars["EMA11"]:update(mode);
                SafePlus(SafeMinus(SafeMultiply(3, local_vars["EMA8"].DATA:tick(period)), SafeMultiply(3, local_vars["EMA9"].DATA:tick(period))), local_vars["EMA11"].DATA:tick(period));
                SafeSetFloat(local_vars["EMA14_source"], period, data);
                local_vars["EMA14"]:update(mode);
                SafeSetFloat(local_vars["EMA16_source"], period, data);
                local_vars["EMA16"]:update(mode);
                SafeSetFloat(local_vars["EMA15_source"], period, local_vars["EMA16"].DATA:tick(period));
                local_vars["EMA15"]:update(mode);
                SafeSetFloat(local_vars["EMA19_source"], period, data);
                local_vars["EMA19"]:update(mode);
                SafeSetFloat(local_vars["EMA18_source"], period, local_vars["EMA19"].DATA:tick(period));
                local_vars["EMA18"]:update(mode);
                SafeSetFloat(local_vars["EMA17_source"], period, local_vars["EMA18"].DATA:tick(period));
                local_vars["EMA17"]:update(mode);
                return SafePlus(SafeMinus(SafeMultiply(3, local_vars["EMA14"].DATA:tick(period)), SafeMultiply(3, local_vars["EMA15"].DATA:tick(period))), local_vars["EMA17"].DATA:tick(period));
            elseif vars["HMA"] then
                SafeSetFloat(local_vars["PINESCRIPT HMA1_source"], period, data);
                local_vars["PINESCRIPT HMA1"]:update(mode);
                return local_vars["PINESCRIPT HMA1"].DATA:tick(period);
            elseif vars["WMA"] then
                SafeSetFloat(local_vars["WMA1_source"], period, data);
                local_vars["WMA1"]:update(mode);
                return local_vars["WMA1"].DATA:tick(period);
            elseif vars["SWMA"] then
                local_vars["PINESCRIPT SWMA1"]:update(mode);
                return local_vars["PINESCRIPT SWMA1"].DATA:tick(period);
            elseif vars["VWMA"] then
                SafeSetFloat(local_vars["VOLUME WEIGHTED MOVING AVERAGE1_source"], period, data);
                local_vars["VOLUME WEIGHTED MOVING AVERAGE1"]:update(mode);
                return local_vars["VOLUME WEIGHTED MOVING AVERAGE1"].DATA:tick(period);
            else
                return data;
            end
        end
    };
end
function Create_normalize_i(window)
    local local_vars = {};
    local_vars["min_1"] = instance:addInternalStream(0, 0);
    local_vars["max_1"] = instance:addInternalStream(0, 0);
    local_vars["min_2"] = instance:addInternalStream(0, 0);
    return {
        Clear = function()
        end,
        GetValue = function(a_rray, weights, period, mode)
            local_vars["value"] = Triary((vars["weightTypeInput"] ~= vars["NONE"]), SafeDivide(Array:Sum(a_rray), (Triary((vars["weightTypeInput"] == vars["VOLUME"]), Array:Sum(vars["volumes"]:Get()), Array:Sum(weights)))), Array:Sum(a_rray));
            SafeSetFloat(local_vars["min_1"], period, local_vars["value"]);
            SafeSetFloat(local_vars["max_1"], period, local_vars["value"]);
            SafeSetFloat(local_vars["min_2"], period, local_vars["value"]);
            return SafeDivide(SafeMultiply(100, (SafeMinus(local_vars["value"], SafeMathExMin(local_vars["min_1"], period, window)))), (SafeMinus(SafeMathExMax(local_vars["max_1"], period, window), SafeMathExMin(local_vars["min_2"], period, window))));
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
    vars["windowInput"] = instance.parameters.param1;
    vars["smoothingInput"] = instance.parameters.param2;
    vars["smoothingLengthInput"] = instance.parameters.param3;
    vars["weightTypeInput"] = instance.parameters.param4;
    vars["topThresholdInput"] = instance.parameters.param5;
    vars["bottomThresholdInput"] = instance.parameters.param6;
    vars["bulls"] = Variable:Create();
    vars["bears"] = Variable:Create();
    vars["sideways"] = Variable:Create();
    vars["volumes"] = Variable:Create();
    vars["bullWeights"] = Variable:Create();
    vars["bearWeights"] = Variable:Create();
    vars["sidewayWeights"] = Variable:Create();
    vars["addDataFunc1"] = Create_addData_i(vars["windowInput"]);
    vars["addDataFunc3"] = Create_addData_i(vars["windowInput"]);
    vars["addDataFunc4"] = Create_addData_i_i(vars["windowInput"], vars["sidewayWeight"]);
    vars["addWeightFunc6"] = Create_addWeight_i(vars["windowInput"]);
    vars["addWeightFunc7"] = Create_addWeight_i(vars["windowInput"]);
    vars["addWeightFunc8"] = Create_addWeight_i(vars["windowInput"]);
    vars["addWeightFunc9"] = Create_addWeight_i_i(vars["sidewayWeight"], vars["windowInput"]);
    vars["bullsNormalized"] = instance:addInternalStream(0, 0);
    vars["smoothFunc10"] = Create_smooth();
    vars["normalizeFunc11"] = Create_normalize_i(vars["windowInput"]);
    vars["bearsNormalized"] = instance:addInternalStream(0, 0);
    vars["smoothFunc12"] = Create_smooth();
    vars["normalizeFunc13"] = Create_normalize_i(vars["windowInput"]);
    vars["smoothFunc14"] = Create_smooth();
    vars["normalizeFunc15"] = Create_normalize_i(vars["windowInput"]);
    vars["GREEN"] = Graphics:AddTransparency(core.rgb(8, 153, 129), 0);
    vars["bullColor"] = vars["GREEN"] + math.floor(50 / 100 * 255) * 16777216;
    plot1_color = vars["bullColor"];
    plot1 = instance:addStream("plot1", core.Line, "Bullish", "Bullish", plot1_color or core.colors().Blue, 0, 0);
    plot1:setWidth(1);
    if (plot1_color == nil) then
        plot1:setStyle(core.LINE_NONE);
    else
        plot1:setStyle(core.LINE_SOLID);
    end
    vars["bullPlot"] = plot1;
    vars["RED"] = Graphics:AddTransparency(core.rgb(242, 54, 69), 0);
    vars["bearColor"] = vars["RED"] + math.floor(50 / 100 * 255) * 16777216;
    plot2_color = vars["bearColor"];
    plot2 = instance:addStream("plot2", core.Line, "Bearish", "Bearish", plot2_color or core.colors().Blue, 0, 0);
    plot2:setWidth(1);
    if (plot2_color == nil) then
        plot2:setStyle(core.LINE_NONE);
    else
        plot2:setStyle(core.LINE_SOLID);
    end
    vars["bearPlot"] = plot2;
    vars["sidewaysColor"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    plot3_color = vars["sidewaysColor"];
    plot3 = instance:addStream("plot3", core.Line, "Sideways", "Sideways", plot3_color or core.colors().Blue, 0, 0);
    plot3:setWidth(1);
    if (plot3_color == nil) then
        plot3:setStyle(core.LINE_NONE);
    else
        plot3:setStyle(core.LINE_SOLID);
    end
    vars["sidewaysPlot"] = plot3;
    plot4_color = Color(nil);
    plot4 = instance:addStream("plot4", core.Line, "Top", "Top", plot4_color or core.colors().Blue, 0, 0);
    plot4:setWidth(1);
    if (plot4_color == nil) then
        plot4:setStyle(core.LINE_NONE);
    else
        plot4:setStyle(core.LINE_SOLID);
    end
    vars["topPlot"] = plot4;
    plot5_color = Color(nil);
    plot5 = instance:addStream("plot5", core.Line, "Bottom", "Bottom", plot5_color or core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    if (plot5_color == nil) then
        plot5:setStyle(core.LINE_NONE);
    else
        plot5:setStyle(core.LINE_SOLID);
    end
    vars["bottomPlot"] = plot5;
    vars["bulls"] = Variable:Create();
    vars["bullWeights"] = Variable:Create();
    vars["smoothFunc16"] = Create_smooth();
    vars["normalizeFunc17"] = Create_normalize_i(vars["windowInput"]);
    vars["bears"] = Variable:Create();
    vars["bearWeights"] = Variable:Create();
    vars["smoothFunc18"] = Create_smooth();
    vars["normalizeFunc19"] = Create_normalize_i(vars["windowInput"]);
    SafeSetFloat(vars["bullsNormalized"], period, vars["smoothFunc16"].GetValue(vars["normalizeFunc17"].GetValue(vars["bulls"]:Get(), vars["bullWeights"]:Get(), period, mode), period, mode));
    SafeSetFloat(vars["bearsNormalized"], period, vars["smoothFunc18"].GetValue(vars["normalizeFunc19"].GetValue(vars["bears"]:Get(), vars["bearWeights"]:Get(), period, mode), period, mode));
    vars["bullishCross"] = SafeGreater(SafeGetFloat(vars["bullsNormalized"], period), SafeGetFloat(vars["bearsNormalized"], period)) and SafeLE(SafeGetFloat(vars["bullsNormalized"], period - 1), SafeGetFloat(vars["bearsNormalized"], period - 1));
    plot6 = instance:createTextOutput("plot6", "Bullish Cross", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    vars["bearishCross"] = SafeGreater(SafeGetFloat(vars["bearsNormalized"], period), SafeGetFloat(vars["bullsNormalized"], period)) and SafeLE(SafeGetFloat(vars["bearsNormalized"], period - 1), SafeGetFloat(vars["bullsNormalized"], period - 1));
    plot7 = instance:createTextOutput("plot7", "Bearish Cross", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    vars["!channel1_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel1_1_c"] = core.rgb(8, 153, 129) + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel1_1_c"] ~= nil) then
        instance:createChannelGroup("channel1_1", "channel1_1", vars["!channel1_1_u"], vars["!channel1_1_d"], Graphics:GetColor(vars["!channel1_1_c"]), vars["!channel1_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel1_1_c"]) or 100);
    end
    vars["!channel1_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel1_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel1_2_c"] = Color(nil);
    if (vars["!channel1_2_c"] ~= nil) then
        instance:createChannelGroup("channel1_2", "channel1_2", vars["!channel1_2_u"], vars["!channel1_2_d"], Graphics:GetColor(vars["!channel1_2_c"]), vars["!channel1_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel1_2_c"]) or 100);
    end
    vars["!channel2_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel2_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel2_1_c"] = core.rgb(8, 153, 129) + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel2_1_c"] ~= nil) then
        instance:createChannelGroup("channel2_1", "channel2_1", vars["!channel2_1_u"], vars["!channel2_1_d"], Graphics:GetColor(vars["!channel2_1_c"]), vars["!channel2_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel2_1_c"]) or 100);
    end
    vars["!channel2_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel2_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel2_2_c"] = Color(nil);
    if (vars["!channel2_2_c"] ~= nil) then
        instance:createChannelGroup("channel2_2", "channel2_2", vars["!channel2_2_u"], vars["!channel2_2_d"], Graphics:GetColor(vars["!channel2_2_c"]), vars["!channel2_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel2_2_c"]) or 100);
    end
    vars["!channel3_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel3_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel3_1_c"] = core.rgb(242, 54, 69) + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel3_1_c"] ~= nil) then
        instance:createChannelGroup("channel3_1", "channel3_1", vars["!channel3_1_u"], vars["!channel3_1_d"], Graphics:GetColor(vars["!channel3_1_c"]), vars["!channel3_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel3_1_c"]) or 100);
    end
    vars["!channel3_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel3_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel3_2_c"] = Color(nil);
    if (vars["!channel3_2_c"] ~= nil) then
        instance:createChannelGroup("channel3_2", "channel3_2", vars["!channel3_2_u"], vars["!channel3_2_d"], Graphics:GetColor(vars["!channel3_2_c"]), vars["!channel3_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel3_2_c"]) or 100);
    end
    vars["!channel4_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel4_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel4_1_c"] = core.rgb(242, 54, 69) + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel4_1_c"] ~= nil) then
        instance:createChannelGroup("channel4_1", "channel4_1", vars["!channel4_1_u"], vars["!channel4_1_d"], Graphics:GetColor(vars["!channel4_1_c"]), vars["!channel4_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel4_1_c"]) or 100);
    end
    vars["!channel4_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel4_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel4_2_c"] = Color(nil);
    if (vars["!channel4_2_c"] ~= nil) then
        instance:createChannelGroup("channel4_2", "channel4_2", vars["!channel4_2_u"], vars["!channel4_2_d"], Graphics:GetColor(vars["!channel4_2_c"]), vars["!channel4_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel4_2_c"]) or 100);
    end
    vars["!channel5_1_u"] = instance:addInternalStream(0, 0);
    vars["!channel5_1_d"] = instance:addInternalStream(0, 0);
    vars["!channel5_1_c"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    if (vars["!channel5_1_c"] ~= nil) then
        instance:createChannelGroup("channel5_1", "channel5_1", vars["!channel5_1_u"], vars["!channel5_1_d"], Graphics:GetColor(vars["!channel5_1_c"]), vars["!channel5_1_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel5_1_c"]) or 100);
    end
    vars["!channel5_2_u"] = instance:addInternalStream(0, 0);
    vars["!channel5_2_d"] = instance:addInternalStream(0, 0);
    vars["!channel5_2_c"] = Color(nil);
    if (vars["!channel5_2_c"] ~= nil) then
        instance:createChannelGroup("channel5_2", "channel5_2", vars["!channel5_2_u"], vars["!channel5_2_d"], Graphics:GetColor(vars["!channel5_2_c"]), vars["!channel5_2_c"] and 100 - Graphics:GetTransparencyPercent(vars["!channel5_2_c"]) or 100);
    end
    plot8 = instance:addStream("plot8", core.Line, "", "", core.colors().Blue, 0, 0);
    plot8:setStyle(core.LINE_NONE);
    plot8:addLevel(vars["topThresholdInput"], core.LINE_SOLID, 1, core.colors().Blue);
    plot8:addLevel(vars["bottomThresholdInput"], core.LINE_SOLID, 1, core.colors().Blue);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        vars["bulls"]:Clear();
        vars["bears"]:Clear();
        vars["sideways"]:Clear();
        vars["volumes"]:Clear();
        vars["bullWeights"]:Clear();
        vars["bearWeights"]:Clear();
        vars["sidewayWeights"]:Clear();
        vars["addDataFunc1"].Clear();
        vars["addDataFunc3"].Clear();
        vars["addDataFunc4"].Clear();
        vars["addWeightFunc6"].Clear();
        vars["addWeightFunc7"].Clear();
        vars["addWeightFunc8"].Clear();
        vars["addWeightFunc9"].Clear();
        vars["normalizeFunc11"].Clear();
        vars["smoothFunc10"].Clear();
        vars["normalizeFunc13"].Clear();
        vars["smoothFunc12"].Clear();
        vars["normalizeFunc15"].Clear();
        vars["smoothFunc14"].Clear();
        vars["bulls"]:Clear();
        vars["bullWeights"]:Clear();
        vars["normalizeFunc17"].Clear();
        vars["smoothFunc16"].Clear();
        vars["bears"]:Clear();
        vars["bearWeights"]:Clear();
        vars["normalizeFunc19"].Clear();
        vars["smoothFunc18"].Clear();
    else
    end
    vars["GREEN"] = Graphics:AddTransparency(core.rgb(8, 153, 129), 0);
    vars["RED"] = Graphics:AddTransparency(core.rgb(242, 54, 69), 0);
    vars["bullColor"] = vars["GREEN"] + math.floor(50 / 100 * 255) * 16777216;
    vars["bearColor"] = vars["RED"] + math.floor(50 / 100 * 255) * 16777216;
    vars["sidewaysColor"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    vars["NONE"] = "None";
    vars["VOLUME"] = "Volume";
    vars["PRICE"] = "Price";
    vars["RMA"] = "RMA";
    vars["SMA"] = "SMA";
    vars["TMA"] = "TMA";
    vars["EMA"] = "EMA";
    vars["DEMA"] = "DEMA";
    vars["TEMA"] = "TEMA";
    vars["HMA"] = "HMA";
    vars["WMA"] = "WMA";
    vars["SWMA"] = "SWMA";
    vars["VWMA"] = "VWMA";
    vars["DATA_GROUP"] = "DATA";
    vars["THRESHOLDS_GROUP"] = "THRESHOLDS";
    if not vars["bulls"]:IsInitialized() then
        vars["bulls"]:Set(Array:New(0, nil));
    end
    if not vars["bears"]:IsInitialized() then
        vars["bears"]:Set(Array:New(0, nil));
    end
    if not vars["sideways"]:IsInitialized() then
        vars["sideways"]:Set(Array:New(0, nil));
    end
    if not vars["volumes"]:IsInitialized() then
        vars["volumes"]:Set(Array:New(0, nil));
    end
    if not vars["bullWeights"]:IsInitialized() then
        vars["bullWeights"]:Set(Array:New(0, nil));
    end
    if not vars["bearWeights"]:IsInitialized() then
        vars["bearWeights"]:Set(Array:New(0, nil));
    end
    if not vars["sidewayWeights"]:IsInitialized() then
        vars["sidewayWeights"]:Set(Array:New(0, nil));
    end
    vars["bull"] = SafeGreater(source.close:tick(period), source.high:tick(period - 1));
    vars["bear"] = SafeLess(source.close:tick(period), source.low:tick(period - 1));
    vars["sideway"] = not (vars["bull"]) and not (vars["bear"]);
    vars["bullWeight"] = SafeAbs(SafeMinus(source.close:tick(period), source.high:tick(period - 1)));
    vars["bearWeight"] = SafeAbs(SafeMinus(source.close:tick(period), source.low:tick(period - 1)));
    vars["sidewayWeight"] = 1;
    vars["addDataFunc1"].GetValue(vars["bulls"]:Get(), Triary(vars["bull"], 1, (-1)), vars["bullWeight"], period, mode);
    vars["addDataFunc3"].GetValue(vars["bears"]:Get(), Triary(vars["bear"], 1, (-1)), vars["bearWeight"], period, mode);
    vars["addDataFunc4"].GetValue(vars["sideways"]:Get(), Triary(vars["sideway"], 1, (-1)), period, mode);
    vars["addWeightFunc6"].GetValue(vars["volumes"]:Get(), source.volume:tick(period), period, mode);
    vars["addWeightFunc7"].GetValue(vars["bullWeights"]:Get(), vars["bullWeight"], period, mode);
    vars["addWeightFunc8"].GetValue(vars["bearWeights"]:Get(), vars["bearWeight"], period, mode);
    vars["addWeightFunc9"].GetValue(vars["sidewayWeights"]:Get(), period, mode);
    SafeSetFloat(vars["bullsNormalized"], period, vars["smoothFunc10"].GetValue(vars["normalizeFunc11"].GetValue(vars["bulls"]:Get(), vars["bullWeights"]:Get(), period, mode), period, mode));
    SafeSetFloat(vars["bearsNormalized"], period, vars["smoothFunc12"].GetValue(vars["normalizeFunc13"].GetValue(vars["bears"]:Get(), vars["bearWeights"]:Get(), period, mode), period, mode));
    vars["sidewaysNormalized"] = vars["smoothFunc14"].GetValue(vars["normalizeFunc15"].GetValue(vars["sideways"]:Get(), vars["sidewayWeights"]:Get(), period, mode), period, mode);
    Plot:SetValue(plot1, period, SafeGetFloat(vars["bullsNormalized"], period));
    Plot:SetValue(plot2, period, SafeGetFloat(vars["bearsNormalized"], period));
    Plot:SetValue(plot3, period, vars["sidewaysNormalized"]);
    Plot:SetValue(plot4, period, vars["topThresholdInput"]);
    Plot:SetValue(plot5, period, vars["bottomThresholdInput"]);
    vars["bullishCross"] = SafeGreater(SafeGetFloat(vars["bullsNormalized"], period), SafeGetFloat(vars["bearsNormalized"], period)) and SafeLE(SafeGetFloat(vars["bullsNormalized"], period - 1), SafeGetFloat(vars["bearsNormalized"], period - 1));
    vars["bearishCross"] = SafeGreater(SafeGetFloat(vars["bearsNormalized"], period), SafeGetFloat(vars["bullsNormalized"], period)) and SafeLE(SafeGetFloat(vars["bearsNormalized"], period - 1), SafeGetFloat(vars["bullsNormalized"], period - 1));
    PlotShape:SetValue(plot6, period, source, SafeGetFloat(vars["bullsNormalized"], period), "\161", "", "absolute", Triary(vars["bullishCross"], vars["bullColor"] + math.floor(0 / 100 * 255) * 16777216, Color(nil)));
    if not vars["bulls"]:IsInitialized() then
        vars["bulls"]:Set(Array:New(0, nil));
    end
    if not vars["bullWeights"]:IsInitialized() then
        vars["bullWeights"]:Set(Array:New(0, nil));
    end
    if not vars["bears"]:IsInitialized() then
        vars["bears"]:Set(Array:New(0, nil));
    end
    if not vars["bearWeights"]:IsInitialized() then
        vars["bearWeights"]:Set(Array:New(0, nil));
    end
    PlotShape:SetValue(plot7, period, source, SafeGetFloat(vars["bearsNormalized"], period), "\161", "", "absolute", Triary(vars["bearishCross"], vars["bearColor"] + math.floor(0 / 100 * 255) * 16777216, Color(nil)));
    channel1_from = vars["bullPlot"][period];
    channel1_to = vars["topPlot"][period];
    channel1_c = Triary(SafeGreater(SafeGetFloat(vars["bullsNormalized"], period), vars["topThresholdInput"]), vars["bullColor"], Color(nil));
    Fill:SetValue(vars["!channel1_1_u"], vars["!channel1_1_d"], channel1_from, channel1_to, vars["!channel1_1_c"] == channel1_c, period);
    Fill:SetValue(vars["!channel1_2_u"], vars["!channel1_2_d"], channel1_from, channel1_to, vars["!channel1_2_c"] == channel1_c, period);
    channel2_from = vars["bullPlot"][period];
    channel2_to = vars["bottomPlot"][period];
    channel2_c = Triary(SafeLess(SafeGetFloat(vars["bullsNormalized"], period), vars["bottomThresholdInput"]), vars["bullColor"], Color(nil));
    Fill:SetValue(vars["!channel2_1_u"], vars["!channel2_1_d"], channel2_from, channel2_to, vars["!channel2_1_c"] == channel2_c, period);
    Fill:SetValue(vars["!channel2_2_u"], vars["!channel2_2_d"], channel2_from, channel2_to, vars["!channel2_2_c"] == channel2_c, period);
    channel3_from = vars["bearPlot"][period];
    channel3_to = vars["topPlot"][period];
    channel3_c = Triary(SafeGreater(SafeGetFloat(vars["bearsNormalized"], period), vars["topThresholdInput"]), vars["bearColor"], Color(nil));
    Fill:SetValue(vars["!channel3_1_u"], vars["!channel3_1_d"], channel3_from, channel3_to, vars["!channel3_1_c"] == channel3_c, period);
    Fill:SetValue(vars["!channel3_2_u"], vars["!channel3_2_d"], channel3_from, channel3_to, vars["!channel3_2_c"] == channel3_c, period);
    channel4_from = vars["bearPlot"][period];
    channel4_to = vars["bottomPlot"][period];
    channel4_c = Triary(SafeLess(SafeGetFloat(vars["bearsNormalized"], period), vars["bottomThresholdInput"]), vars["bearColor"], Color(nil));
    Fill:SetValue(vars["!channel4_1_u"], vars["!channel4_1_d"], channel4_from, channel4_to, vars["!channel4_1_c"] == channel4_c, period);
    Fill:SetValue(vars["!channel4_2_u"], vars["!channel4_2_d"], channel4_from, channel4_to, vars["!channel4_2_c"] == channel4_c, period);
    channel5_from = vars["sidewaysPlot"][period];
    channel5_to = vars["bottomPlot"][period];
    channel5_c = Triary(SafeLess(vars["sidewaysNormalized"], vars["bottomThresholdInput"]), vars["sidewaysColor"], Color(nil));
    Fill:SetValue(vars["!channel5_1_u"], vars["!channel5_1_d"], channel5_from, channel5_to, vars["!channel5_1_c"] == channel5_c, period);
    Fill:SetValue(vars["!channel5_2_u"], vars["!channel5_2_d"], channel5_from, channel5_to, vars["!channel5_2_c"] == channel5_c, period);
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
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    function var:Clear()
        self._init = false;
        self._value = nil;
    end
    function var:Get()
        return self._value;
    end
    function var:Set(value)
        self._value = value;
        self._init = true;
    end
    function var:IsInitialized()
        return self._value;
    end
    return var;
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
function Array:Copy(array)
    if array == nil then
        return;
    end
    return array:Copy();
end
function Array:Get(array, index)
    if array == nil then
        return;
    end
    return array:Get(index);
end
function Array:Join(array, separator)
    if array == nil then
        return;
    end
    return array:Join(separator);
end
function Array:Reverse(array)
    if array == nil then
        return;
    end
    return array:Reverse();
end
function Array:Remove(array, index)
    if array == nil then
        return;
    end
    return array:Remove(index);
end
function Array:Sum(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local sum = array:Get(0);
    for i = 1, array:Size() - 1 do
        local v = array:Get(i);
        if (sum == nil) then
            sum = v;
        elseif (v ~= nil or sum == nil) then
            sum = sum + v;
        end
    end
    return sum;
end
function Array:Max(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or (val ~= nil and maxVal < val) then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or (val ~= nil and minVal > val) then
            minVal = val;
        end
    end
    return minVal;
end
function Array:Pop(array)
    if array == nil or array:Size() == 0 then
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
function Array:Includes(array, value)
    if array == nil then
        return nil;
    end
    return array:Includes(value);
end
function Array:Median(array)
    if array == nil then
        return nil;
    end
    return array:Median();
end
function Array:First(array, value)
    if array == nil then
        return nil;
    end
    return array:First(value);
end
function Array:Last(array, value)
    if array == nil then
        return nil;
    end
    return array:Last(value);
end
function Array:New(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    if size ~= nil then
        newArray.size = size;
        for i = 1, size, 1 do
            newArray.arr[i] = initialValue;
        end
    else
        newArray.size = 0;
    end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; return self; end
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
    function newArray:Includes(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return true;
            end
        end
        return false;
    end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Median()
        local items = {};
        for i, v in ipairs(self.arr) do
            items[i] = v;
        end
        table.sort(items);
        local center = self.size / 2;
        if self.size % 2 == 1 then
            return items[center];
        else
            return (items[center] + items[center + 1]) / 2;
        end
    end
    function newArray:First()
        if self.size == 0 then
            return;
        end
        return self.arr[1];
    end
    function newArray:Last()
        if self.size == 0 then
            return;
        end
        return self.arr[self.size];
    end
    function newArray:Copy()
        local arrayCopy = Array:New(self.size, nil);
        for i = 1, self.size, 1 do
            arrayCopy.arr[i] = self.arr[i];
        end
        return arrayCopy;
    end
    function newArray:Reverse()
        local half = math.floor(self.size / 2);
        for i = 1, half, 1 do
            local swapped = self.arr[self.size - i + 1];
            self.arr[self.size - i + 1] = self.arr[i];
            self.arr[i] = swapped;
        end
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
    function newArray:Join(separator)
        if self.size == 0 then
            return "";
        end
        local str = tostring(self.arr[1]);
        for i = 2, self.size, 1 do
            if self.arr[i] ~= nil then
                str = str .. separator .. tostring(self.arr[i]);
            end
        end
        return str;
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
    return Array:New(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBox(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBool(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewColor(size, initialValue)
    return Array:New(size, initialValue);
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76476
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