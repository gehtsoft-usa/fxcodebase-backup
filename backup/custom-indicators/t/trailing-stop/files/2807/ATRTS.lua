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
    indicator:name("ATR Trailing Stop");
    indicator:description("ATR Trailing Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    --indicator.parameters:addDouble("P", "Percentage ", "Percentage ", 3);
	indicator.parameters:addInteger("AP", "ATR period ", "ATR Period ", 14);
	indicator.parameters:addDouble("AM", "ATR multiplicator ", "ATR multiplicator ", 3.5);
    indicator.parameters:addColor("PTS_color", "Color of PTS", "Color of PTS", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplicator=nil;
local Frame=nil;

local first;
local source = nil;

-- Streams block
local PTS = nil;
local STOP;
local ATR=nil;


-- Routine
function Prepare()
    Multiplicator = instance.parameters.AM;
	Frame = instance.parameters.AP;
	source = instance.source;
    first = source:first();
	
	ATR= core.indicators:create("ATR", source, Frame);
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. Multiplicator .. ")";
    instance:name(name);
    PTS = instance:addStream("PTS", core.Line, name, "PTS", instance.parameters.PTS_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    	     
		  if period >= Frame and source:hasData(period) then
			  
			  
			    ATR:update(mode);

				STOP=ATR.DATA[period]*Multiplicator;
			
				if source.close[period] < PTS[period-1] and  source.close[period-1] > PTS[period-1] then
				PTS[period] = source.close[period]+STOP;
				elseif source.close[period] < PTS[period-1] and  source.close[period-1] < PTS[period-1] then
				PTS[period]= math.min(PTS[period-1],source.close[period]+STOP);					
				end	
		
				
				if source.close[period] > PTS[period-1] and  source.close[period-1] < PTS[period-1] then
				PTS[period] = source.close[period]-STOP;
				elseif source.close[period]  > PTS[period-1] and   source.close[period-1] > PTS[period-1] then
				PTS[period]= math.max(PTS[period-1],source.close[period]-STOP);		
				end			
		
	
    end	
	
end
