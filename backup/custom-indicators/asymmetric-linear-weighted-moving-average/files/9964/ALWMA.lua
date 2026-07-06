-- Id: 3723
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4005

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
    indicator:name("Asymmetric Linear Weighted Moving Average");
    indicator:description("Asymmetric Linear Weighted Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	 indicator.parameters:addString("Mode", "Mode", "", "Regular");
	  indicator.parameters:addStringAlternative("Mode", "Regular", "", "Regular");
	 indicator.parameters:addStringAlternative("Mode", "Inverse", "", "Inverse");
	  indicator.parameters:addStringAlternative("Mode", "Asymmetric", "", "Asymmetric");
	  indicator.parameters:addStringAlternative("Mode", "Inverse Asymmetric", "", "Inverse_Asymmetric");
	
	
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
    indicator.parameters:addColor("AEMA_color", "Color of AEMA", "Color of AEMA", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Mode;
local STEP;

local first;
local source = nil;
-- Streams block
local AEMA = nil;

-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD;
    Mode = instance.parameters.Mode;
	
	STEP= PERIOD /( PERIOD/2);
    	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD).. ", " .. tostring( Mode) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        AEMA = instance:addStream("AEMA", core.Line, name, "AEMA", instance.parameters.AEMA_color, first);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period > first and source:hasData(period) then
	    local TOTAL=0;
		
	    local i;
		local COUNT= 0;
		local k=0;
		local TOTAL=0;
		
		for i= period - PERIOD, period , 1 do
		
		
					if Mode == "Regular" then
					COUNT=COUNT+1;
					elseif Mode == "Inverse" then
							if COUNT == 0 then
							COUNT =PERIOD;
							else
							COUNT =COUNT-1;
							end		
					elseif Mode == "Asymmetric" then	
					
					        if COUNT == 0 then							
							COUNT = STEP;							
							else     
                            						 
								if   period - i <    PERIOD /2 then
								COUNT=COUNT+ STEP;	
								else
								COUNT=COUNT- STEP;	
								end		
							end
                    else
                             
                             if COUNT == 0 then							
							COUNT = PERIOD;							
							else
					        
                            						 
								if   period - i <    PERIOD /2 then
								COUNT=COUNT- STEP;	
								else
								COUNT=COUNT+ STEP;	
							    end		
							end
					
					end
				
				k=k+COUNT;				
				TOTAL= TOTAL + source[i]*COUNT; 
				
		
		end	     
        
		AEMA[period]= TOTAL/k;
        		
    end
end

