--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Percentage Trailing Stop");
    indicator:description("Percentage Trailing Stop");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addDouble("P", "Percentage ", "Percentage ", 3, 0, 100);
	indicator.parameters:addColor("PTS_color", "Color of PTS", "Color of PTS", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Percentage=nil;

local first;
local source = nil;

-- Streams block
local PTS = nil;
local STOP;


-- Routine
function Prepare()
    Percentage = instance.parameters.P;
	HIGH = instance.parameters.HL;
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Percentage .. ")";
    instance:name(name);
    PTS = instance:addStream("PTS", core.Line, name, "PTS", instance.parameters.PTS_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  	     
		  if period >= first and source:hasData(period) then
			 

				STOP=(source[period]/100)*Percentage;
		
			   
			
				if source[period] < PTS[period-1] and  source[period-1] > PTS[period-1] then
				PTS[period] = source[period]+STOP;
				elseif source[period] < PTS[period-1] and  source[period-1] < PTS[period-1] then
				PTS[period]= math.min(PTS[period-1],source[period]+STOP);					
				end	
		
				
				if source[period] > PTS[period-1] and  source[period-1] < PTS[period-1] then
				PTS[period] = source[period]-STOP;
				elseif source[period]  > PTS[period-1] and   source[period-1] > PTS[period-1] then
				PTS[period]= math.max(PTS[period-1],source[period]-STOP);		
				end	

		
		end	
	
    	
end

