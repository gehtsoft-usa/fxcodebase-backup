-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5086
-- Id: 4256

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Kurtosis");
    indicator:description("Kurtosis");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("KP", "Kurtosis Period", "Kurtosis Period", 4);
    indicator.parameters:addInteger("FS", "First Smoothing Period", "First Smoothing Period", 66);
    indicator.parameters:addInteger("SS", "Second Smoothing Period", "Second Smoothing Period", 3);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
    indicator.parameters:addColor("Kurtosis_color", "Color of Kurtosis", "Color of Kurtosis", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local KP;
local FS;
local SS;

local first;
local source = nil;

local Indicator={};

-- Streams block
local Kurtosis = nil;
local Momentum;
local RAW;

-- Routine
function Prepare(nameOnly)
    KP = instance.parameters.KP;
    FS = instance.parameters.FS;
    SS = instance.parameters.SS;
    source = instance.source;
    first = source:first()+KP;

    local name = profile:id() .. "(" .. source:name() .. ", " .. KP .. ", " .. FS .. ", " .. SS .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Momentum =  instance:addInternalStream (first, 0);
	RAW =  instance:addInternalStream (first, 0);
	
	Indicator["EMA"] =   core.indicators:create("EMA", RAW, FS);
	Indicator["MVA"] =   core.indicators:create("MVA", Indicator["EMA"] .DATA, SS);
    Kurtosis = instance:addStream("Kurtosis", core.Line, name, "Kurtosis", instance.parameters.Kurtosis_color, first + FS +SS );
    Kurtosis:setPrecision(math.max(2, instance.source:getPrecision()));
	Kurtosis:setWidth(instance.parameters.width);
    Kurtosis:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	Momentum[period]= source[period] - source[period-KP];
	
	
	RAW[period] = Momentum[period] - Momentum[period-1];
	
	if period < first + FS +SS then
	return;
	end
	
	Indicator["EMA"]:update(mode);
	Indicator["MVA"]:update(mode);
	
    Kurtosis[period] = Indicator["MVA"].DATA[period];
    
end

