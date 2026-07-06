-- Id: 8226
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27956

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
    indicator:name("Linear Regression Trend Histogram");
    indicator:description("Linear Regression Trend Histogram");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 34);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of LRT Up", "Color of LRT", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of LRT Down", "Color of LRT", core.rgb(255, 0, 0));
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
local LRT = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        LRT = instance:addStream("LRT", core.Bar, name, "LRT", instance.parameters.Up, first);
    LRT:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
		
	local  a, b, c, sumy, sumx, sumxy, sumx2,i;
	 sumy=0.0; sumx=0.0; sumxy=0.0; sumx2=0.0;
	
	
	for i=1, Period, 1 do
   
      sumy=sumy+source[period-Period+i];
      sumxy=sumxy+source[period-Period+i]*i;
      sumx=sumx+i;
      sumx2=sumx2+i*i;
    end
	
	
	c=sumx2*Period-sumx*sumx;
    b=(sumxy*Period-sumx*sumy)/c;
    LRT[period]=b/source:pipSize(); 
	
	if LRT[period] >LRT[period-1] then 
	LRT:setColor(period, instance.parameters.Up);
    else
	LRT:setColor(period, instance.parameters.Down);
    end
 
end

