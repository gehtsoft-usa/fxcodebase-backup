-- Id: 4011
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4482

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("FX Trend");
    indicator:description("FX Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Short_Period", "Short Period", "", 7);
	indicator.parameters:addInteger("Mid_Period", "Mid Period", "", 14);
	indicator.parameters:addInteger("Long_Period", "Long Period", "", 28);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Color of FX_Trend", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short_Period;
local Mid_Period;
local Long_Period;
local Constant;

local first;
local source = nil;

-- Streams block
local FX_Trend = nil;

-- Routine
function Prepare(nameOnly)
    Short_Period = instance.parameters.Short_Period;
	Mid_Period = instance.parameters.Mid_Period;
	Long_Period = instance.parameters.Long_Period;
	
    source = instance.source;
    first = math.max(Short_Period, Mid_Period, Long_Period );
	
	 Constant = 100 / (1.0 / Short_Period + 1.0 / Mid_Period + 1.0 / Long_Period);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Short_Period.. ", " .. Mid_Period.. ", " .. Long_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    FX_Trend = instance:addStream("FX_Trend", core.Line, name, "FX_Trend", instance.parameters.color, first);
    FX_Trend:setPrecision(math.max(2, instance.source:getPrecision()));
	FX_Trend:setWidth(instance.parameters.width);
    FX_Trend:setStyle(instance.parameters.style);
	
	FX_Trend:addLevel(50);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	
	local ll1, hh1;
	local ll2, hh2;
	local ll3, hh3;
	
	ll1, hh1 = mathex.minmax(source, period -Short_Period,  period);
    ll2, hh2 = mathex.minmax(source, period -Mid_Period, period);
    ll3, hh3 = mathex.minmax(source, period -Long_Period,  period);
	 
    local  dif1 = hh1 - ll1;
    local dif2 = hh2 - ll2;
    local dif3 = hh3 - ll3;
	
	FX_Trend[period] = Constant * ((source.close[period] - ll1) / dif1 / Short_Period +
                       (source.close[period] - ll2) / dif2 / Mid_Period +
                       (source.close[period] - ll3) / dif3 / Long_Period);
	
	
        
    end
end

