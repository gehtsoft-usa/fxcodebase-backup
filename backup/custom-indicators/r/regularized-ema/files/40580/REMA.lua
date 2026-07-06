-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23582
-- Id: 7439

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
    indicator:name("Regularized EMA");
    indicator:description("Designed to be smoother  then EMA but not introduce too much extra lag");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addDouble("Lambda", "Lambda", "factor controlling the amount of �regularization�", 0.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("REMA_color", "Color of REMA", "Color of REMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;
local Lambda;
local Period
local first;
local source = nil;

-- Streams block
local REMA = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Lambda = instance.parameters.Lambda;
    source = instance.source;
    first = source:first()+2;
	
	Alpha=2/(Period+1)

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Lambda) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        REMA = instance:addStream("REMA", core.Line, name, "REMA", instance.parameters.REMA_color, first);
		REMA:setWidth(instance.parameters.width);
        REMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     REMA[period]=0;
    if period < first or not  source:hasData(period) then
	return;
	end
   
    REMA[period] =(REMA[period-1]*(1+2*Lambda)+Alpha*(source[period]-REMA[period-1])-Lambda*REMA[period-2])/(1+Lambda);
	
end

