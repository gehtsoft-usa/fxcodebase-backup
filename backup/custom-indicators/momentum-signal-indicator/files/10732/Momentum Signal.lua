-- Id: 3921
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4303

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Momentum Signal");
    indicator:description("Momentum Signal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("CciPeriod", "Cci Period", "Cci Period", 6);
    indicator.parameters:addInteger("AtrPeriod", "Atr Period", "Atr Period", 12);
    indicator.parameters:addInteger("MomentumPeriod", "Momentum Period", "Momentum Period", 7);
    indicator.parameters:addInteger("RsiPeriod", "Rsi Period", "Rsi Period", 7);
    indicator.parameters:addInteger("AdxPeriod", "Adx Period", "Adx Period", 7);
    indicator.parameters:addDouble("SubtractFromSignal", "Subtract From Signal", "Subtract From Signal", -5);
    indicator.parameters:addDouble("SubtractFromIndicator", "Subtract From Indicator", "SubtractFromIndicator", -1);
   
    indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("Momentum_color", "Color of Momentum", "Color of Momentum", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Momentum_width", "Momentum Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Momentum_style", "Momentum Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Momentum_style", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Signal_width", "Signal Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Signal_style", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Signal_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Overbought/Oversold Level");
    indicator.parameters:addDouble("OverBought", "Overbought Level", "", 1);  
	  indicator.parameters:addDouble("OverSold", "Oversold Level", "",-1);
    indicator.parameters:addInteger("overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("overboughtsold_style", "Style", "", core.LINE_SOLID);
		 indicator.parameters:setFlag("overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("overboughtsold_color", "Color", "", core.rgb(128, 128, 128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CciPeriod;
local AtrPeriod;
local MomentumPeriod;
local RsiPeriod;
local AdxPeriod;
local SubtractFromSignal;
local SubtractFromIndicator;
local OverBought;
local OverSold;

local indicator={};

local first;
local source = nil;

-- Streams block
local Momentum = nil;
local Signal = nil;

-- Routine
function Prepare(nameOnly)
    CciPeriod = instance.parameters.CciPeriod;
    AtrPeriod = instance.parameters.AtrPeriod;
    MomentumPeriod = instance.parameters.MomentumPeriod;
    RsiPeriod = instance.parameters.RsiPeriod;
    AdxPeriod = instance.parameters.AdxPeriod;
    SubtractFromSignal = instance.parameters.SubtractFromSignal;
    SubtractFromIndicator = instance.parameters.SubtractFromIndicator;
    OverBought = instance.parameters.OverBought;
    OverSold = instance.parameters.OverSold;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. CciPeriod .. ", " .. AtrPeriod .. ", " .. MomentumPeriod .. ", " .. RsiPeriod .. ", " .. AdxPeriod .. ", " .. SubtractFromSignal .. ", " .. SubtractFromIndicator.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
  
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install Momentum.lua indicator"); 
	
	indicator["CCI"] = core.indicators:create("CCI", source, CciPeriod);
	indicator["MOMENTUM"] = core.indicators:create("MOMENTUM", source.typical, MomentumPeriod);
	indicator["ATR"] = core.indicators:create("ATR", source, AtrPeriod);
	indicator["RSI"] = core.indicators:create("RSI", source.typical, AtrPeriod);
	indicator["ADX"] = core.indicators:create("ADX", source, AdxPeriod);	
	
	  first = math.max(indicator["CCI"].DATA:first(), indicator["MOMENTUM"].DATA:first(),indicator["ATR"].DATA:first(),indicator["RSI"].DATA:first(),indicator["ADX"].DATA:first());

	
    
    Momentum = instance:addStream("Momentum", core.Line, name .. ".Momentum", "Momentum", instance.parameters.Momentum_color, first);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, first);
	
	Momentum:addLevel(OverSold, instance.parameters.overboughtsold_style, instance.parameters.overboughtsold_width, instance.parameters.overboughtsold_color);
    Momentum:addLevel(OverBought, instance.parameters.overboughtsold_style, instance.parameters.overboughtsold_width, instance.parameters.overboughtsold_color);    
	
	Momentum:setWidth(instance.parameters.Momentum_width);
    Momentum:setStyle(instance.parameters.Momentum_style);
	
	Signal:setWidth(instance.parameters.Signal_width);
    Signal:setStyle(instance.parameters.Signal_style);
	
	Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	        indicator["CCI"]:update(mode);
			indicator["MOMENTUM"]:update(mode);
			indicator["ATR"]:update(mode);
			indicator["RSI"]:update(mode);
			indicator["ADX"]:update(mode);	     
	
        Signal[period] = (indicator["MOMENTUM"].DATA[period] / (indicator["ATR"].DATA[period] + indicator["ADX"].DATA[period])) - SubtractFromSignal;
        Momentum[period] = ((indicator["ATR"].DATA[period] + indicator["CCI"].DATA[period] + indicator["RSI"].DATA[period]) / indicator["ADX"].DATA[period]) - SubtractFromIndicator;
    end
end

