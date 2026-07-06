-- Available @ http://fxcodebase.com/ 

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
    indicator:name("Relative Strength Index");
    indicator:description("Relative Strength Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "RSI Length", "", 14);
    indicator.parameters:addString("param2", "Source", "", "close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
    indicator.parameters:addString("param3", "MA Type", "", "SMA");
    indicator.parameters:addStringAlternative("param3", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("param3", "Bollinger Bands", "", "Bollinger Bands");
    indicator.parameters:addStringAlternative("param3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("param3", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("param3", "WMA", "", "WMA");
    indicator.parameters:addStringAlternative("param3", "VWMA", "", "VWMA");
    indicator.parameters:addInteger("param4", "MA Length", "", 14);
    indicator.parameters:addDouble("param5", "BB StdDev", "", 2.0, 0.001, 50);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "Upper Bollinger Band Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Lower Bollinger Band Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Channel Color", "", core.rgb(0, 0, 255)); 	
	
	
	indicator.parameters:addColor("color4", "RSI Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color5", "RSI Upper Band Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color6", "RSI Lower Band Color", "", core.rgb(0, 0, 255)); 		
	indicator.parameters:addColor("color7", "Channel Color", "", core.rgb(128, 128, 128)); 		
end

local source;
local params = {};
local RMA1_source;
local RMA2_source;
local maFunc1_param1;
function Create_ma(source, length, type)
    local local_vars = {};
    local_vars["MVA1"] = core.indicators:create("MVA", source, length);
    local_vars["MVA2"] = core.indicators:create("MVA", source, length);
    local_vars["EMA1"] = core.indicators:create("EMA", source, length);
    local_vars["RMA3"] = core.indicators:create("SMMA", source, length);
    local_vars["WMA1"] = core.indicators:create("WMA", source, length);
    local_vars["VOLUME WEIGHTED MOVING AVERAGE1"] = core.indicators:create("WMA", source, length);
    return {
        GetValue = function(period, mode)
            local_vars["MVA1"]:update(mode);
            local_vars["MVA2"]:update(mode);
            local_vars["EMA1"]:update(mode);
            local_vars["RMA3"]:update(mode);
            local_vars["WMA1"]:update(mode);
            local_vars["VOLUME WEIGHTED MOVING AVERAGE1"]:update(mode);
            return (((type == "SMA")) and (local_vars["MVA1"].DATA:tick(period)) or ((((type == "Bollinger Bands")) and (local_vars["MVA2"].DATA:tick(period)) or ((((type == "EMA")) and (local_vars["EMA1"].DATA:tick(period)) or ((((type == "SMMA (RMA)")) and (local_vars["RMA3"].DATA:tick(period)) or ((((type == "WMA")) and (local_vars["WMA1"].DATA:tick(period)) or ((((type == "VWMA")) and (local_vars["VOLUME WEIGHTED MOVING AVERAGE1"].DATA:tick(period)) or (nil))))))))))));
        end
    };
end
local plot1;
local plot2;
local plot3;
local rsi;
local plot4;
local rsi;
local plot5;
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
	
    vars["rsiLengthInput"] = instance.parameters.param1;
    vars["rsiSourceInput"] = source[instance.parameters.param2];
    vars["maTypeInput"] = instance.parameters.param3;
    vars["maLengthInput"] = instance.parameters.param4;
    vars["bbMultInput"] = instance.parameters.param5;
	
	
	
    RMA1_source = instance:addInternalStream(0, 0);
    vars["RMA1"] = core.indicators:create("SMMA", RMA1_source, vars["rsiLengthInput"]);
    RMA2_source = instance:addInternalStream(0, 0);
    vars["RMA2"] = core.indicators:create("SMMA", RMA2_source, vars["rsiLengthInput"]);
    maFunc1_param1 = instance:addInternalStream(0, 0);
    vars["maFunc1"] = Create_ma(maFunc1_param1, vars["maLengthInput"], vars["maTypeInput"]);
	
	
    plot1 = instance:addStream("plot1", core.Line, "RSI", "RSI", instance.parameters.color4, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:addStream("plot2", core.Line, "RSI Upper Band", "RSI Upper Band", instance.parameters.color5, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    vars["rsiUpperBand"] = plot2;
    plot3 = instance:addStream("plot3", core.Line, "RSI Lower Band", "RSI Lower Band", instance.parameters.color6, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    vars["rsiLowerBand"] = plot3;
    instance:createChannelGroup("channel1", "channel1", vars["rsiUpperBand"], vars["rsiLowerBand"], instance.parameters.color7, 100 - 90, true);
    rsi = instance:addInternalStream(0, 0);
    plot4 = instance:addStream("plot4", core.Line, "Upper Bollinger Band", "Upper Bollinger Band", instance.parameters.color1, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    vars["bbUpperBand"] = plot4;
    rsi = instance:addInternalStream(0, 0);
    plot5 = instance:addStream("plot5", core.Line, "Lower Bollinger Band", "Lower Bollinger Band", instance.parameters.color2, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    vars["bbLowerBand"] = plot5;
    instance:createChannelGroup("channel2", "channel2", vars["bbUpperBand"], vars["bbLowerBand"], instance.parameters.color3, 100 - 90, true);
end

function Update(period, mode)
    RMA1_source[period] = SafeMax(Change(vars["rsiSourceInput"], period, 1), 0);
    vars["RMA1"]:update(mode);
    up = vars["RMA1"].DATA:tick(period);
    RMA2_source[period] = SafeNegative(SafeMin(Change(vars["rsiSourceInput"], period, 1), 0));
    vars["RMA2"]:update(mode);
    down = vars["RMA2"].DATA:tick(period);
    rsi[period] = (((down == 0)) and (100) or ((((up == 0)) and (0) or (100 - (100 / (SafePlus(1, SafeDivide(up, down))))))));
    maFunc1_param1[period] = rsi:tick(period) * source.close[period] / 48;
    rsiMA = vars["maFunc1"].GetValue(period, mode);
    isBB = (vars["maTypeInput"] == "Bollinger Bands");
    plot1[period] = rsi:tick(period) * source.close[period] / 48;
    plot2[period] = 70 * source.close[period] / 48;
    plot3[period] = 30 * source.close[period] / 48;
    vars["rsiUpperBand"]:setColor(period, core.rgb(126, 87, 194) + math.floor(90 / 100 * 256) * 16777216);
    if rsi:first() > period - vars["maLengthInput"] then return; end
    plot4[period] = ((isBB) and (SafePlus(rsiMA, SafeMultiply(mathex.stdev(rsi, core.rangeTo(period, vars["maLengthInput"])), vars["bbMultInput"]))) or (nil));
    if rsi:first() > period - vars["maLengthInput"] then return; end
    plot5[period] = ((isBB) and (SafeMinus(rsiMA, SafeMultiply(mathex.stdev(rsi, core.rangeTo(period, vars["maLengthInput"])), vars["bbMultInput"]))) or (nil));
    vars["bbUpperBand"]:setColor(period, ((isBB) and (core.colors().Green) or (nil)));
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
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function Change(source, period, length)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
	
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