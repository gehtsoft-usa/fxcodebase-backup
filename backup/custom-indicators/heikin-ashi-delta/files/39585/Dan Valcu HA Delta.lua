-- Id: 11021
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22967

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
    indicator:name("Dan Valcu Heikin-Ashi Delta");
    indicator:description("Dan Valcu  Heikin-Ashi Delta");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Smoothing Period", "", 3);	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Delta", "Delta Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Dwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Average", "Average Line Color" , "", core.rgb(255,0, 0));
	indicator.parameters:addInteger("Awidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Astyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Astyle", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta;
local Average;
local HA, MA;
local first;
local source = nil;
local Period;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
   Period=instance.parameters.Period;
   

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);	
	

    if (not (nameOnly)) then
	    HA= core.indicators:create("HA", source);
        Delta = instance:addStream("Delta", core.Line, name .. ".Delta", "Delta",instance.parameters.Delta, source:first());
		Delta:setWidth(instance.parameters.Dwidth);
        Delta:setStyle(instance.parameters.Dstyle);
		
		
		MA= core.indicators:create("MVA", Delta, Period);
		
		first= MA.DATA:first();
		
		Average = instance:addStream("Average", core.Line, name .. ".Average", "Average",instance.parameters.Average, MA.DATA:first());
		Average:setWidth(instance.parameters.Awidth);
        Average:setStyle(instance.parameters.Astyle);
		
		Delta:setPrecision(math.max(2, instance.source:getPrecision()));
	    Average:setPrecision(math.max(2, instance.source:getPrecision()));
	    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	 
	
	     HA:update(mode); 
		 if period >= source:first() then  
	     Delta[period]= HA.close[period]- HA.open[period];	 
		 end
		 
		 
		  MA:update(mode); 	 
		  if period<MA.DATA:first() then 
		  Average[period]= MA.DATA[period];
		  end
end

