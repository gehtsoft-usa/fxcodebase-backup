-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60444
-- Id: 11361

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

function Init()
    indicator:name("Trend Component");
    indicator:description("Trend Component");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 11);
    indicator.parameters:addDouble("Delta", "Delta", "Delta", 0.05);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Trend_color", "Color of Trend", "Color of Trend", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Delta;

local first;
local source = nil;

-- Streams block
local Trend = nil;
local beta, gamma, alpha,bp;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Delta = instance.parameters.Delta;
    source = instance.source;
    first = source:first()+2;
	
	beta = math.cos(math.rad(360/Period));
    gamma = (1 / math.cos(math.rad(720*Delta)/Period));
    alpha = gamma * math.sqrt((gamma*gamma)-1);   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Delta) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        bp= instance:addInternalStream(0, 0);	
        Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.Trend_color, first+Period*2);
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
		Trend:setWidth(instance.parameters.width);
        Trend:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	       
		 
            bp[period] = 0.5*(1-alpha)*(source.median[period]-source.median[period-2]) + 
            beta*(1+alpha)*bp[period-1]-alpha*bp[period-2];			
			
      
			if period < first+Period*2 then
			return;
			end

         
	
        Trend[period] = mathex.avg(bp, period-Period*2+1, period);
  
end

