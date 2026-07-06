-- Id: 7416
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23491

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
    indicator:name("Balance of Power Indicator");
    indicator:description("Balance of Power Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
      indicator.parameters:addInteger("Period1", "Price Action", "", 14);
	  indicator.parameters:addInteger("Period2", "Range Period", "", 28);
	  
	  indicator.parameters:addBoolean("LAST", "Use Last Period", " ", true);
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("UP", "Up Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("DN", "Down Color", "", core.rgb(255, 0, 0));	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local first;
local source = nil;
local LAST;
-- Streams block
local BOP = nil;

-- Routine
function Prepare(nameOnly)
   Period1 = instance.parameters.Period1;
   Period2 = instance.parameters.Period2;
   LAST = instance.parameters.LAST;
    source = instance.source;
    first = source:first()+math.max(Period1, Period2)+1;

    local name = profile:id() .. "(" .. source:name() .. ", ".. Period1.. ", ".. Period2 .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        BOP = instance:addStream("BOP", core.Bar, name, "BOP", instance.parameters.UP, first);
    BOP:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

  

    if period >= first and source:hasData(period) then      
	
	local min, max;
 	
       
	    if LAST then
        min, max = mathex.minmax (source, period-Period2+1, period);  
        else
		 min, max = mathex.minmax (source, period-Period2+1-1, period-1); 
        end
	   
        BOP[period] = (source.close[period]- source.open[period-Period1+1])/ (max-min);	 
			
		if  source.close[period] >   min +(max-min)/2  then
		 BOP:setColor(period, instance.parameters.UP);
		else
		 BOP:setColor(period, instance.parameters.DN);
        end   		
		
    end
end

