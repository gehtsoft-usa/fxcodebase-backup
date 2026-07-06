-- Id: 19639

-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Delta");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Bar Color", "", core.rgb(0, 255, 0));
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

	local first;
	local source = nil; 
	local loading = false;   
    local Delta;
-- Streams block
 

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
  
    if   (nameOnly) then
        return;
    end
     
        Delta = instance:addStream("Delta", core.Bar, name, "Delta", instance.parameters.color1, source:first());		
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
		Delta:addLevel(0);
   
end

 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )
 
    Delta[period]=source.close[period]-source.open[period];
end
 
