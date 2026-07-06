-- Id: 14883
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62746

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
    indicator:name("ZeroLagEMA");
    indicator:description("ZeroLagEMA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation" );
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style" );
    indicator.parameters:addColor("EMA_color", "Color of EMA", "Color of EMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local EMA = nil;
local Alpha;
local Lag;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
 
	
	 Alpha=2./(Period+1.); 
     Lag=math.ceil((Period-1.)/2.);
	 
	    first = source:first()+Lag;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        EMA = instance:addStream("EMA", core.Line, name, "EMA", instance.parameters.EMA_color, first);
		EMA:setWidth(instance.parameters.width);
        EMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
 
    if period <first or not  source:hasData(period) then
	return;
	end
	   
	 
        EMA[period] =  Alpha*(2*source[period]-source[period-Lag])+(1-Alpha)*EMA[period-1];
    
end

