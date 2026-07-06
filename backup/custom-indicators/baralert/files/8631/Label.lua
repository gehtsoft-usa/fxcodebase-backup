
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3596

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
    indicator:name("Label");
    indicator:description("Label");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
    indicator.parameters:addColor("color", "Label Color", "Label Color", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LABEL;
local NOTE;
local first;
local source = nil;
local H,L,C,O;

-- Routine
function Prepare(nameOnly)   
  
    source = instance.source;
    first = source:first();
	O=source.open;
	C=source.close;
	H=source.high;
	L=source.low;

    local name = profile:id() .. "(" .. source:name() ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     LABEL = instance:createTextOutput ("LABEL", "LABEL", "Wingdings", 8, core.H_Center, core.V_Top, instance.parameters.color, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
     if period < first or not source:hasData(period) then
	return;
	end
	
	LABEL:setNoData (period);
	
	  core.host:execute ("removeLabel",source:serial(period) );		
	
	local HW = (H[period] -math.max(C[period],O[period]))/source:pipSize();
	local LW = (math.min(C[period],O[period])-L[period])/source:pipSize();
	
	   NOTE = string.format("HL: %i\nOC: %i\nHW: %i\nLW: %i\n",(H[period] -L[period])/source:pipSize(),(C[period] -O[period])/source:pipSize(),HW,LW);
	
       LABEL:set(period, source.high[period], "\164", NOTE);
     
end

