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
    indicator:name("Trailing Stop");
    indicator:description("Trailing Stop");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("STOP", "Initial Stop (In Pips) ", "", 100 , 0, 10000);
	
    indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("PTS_color", "Color of TS", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local PTS = nil;
local STOP;


-- Routine
function Prepare()
    STOP= instance.parameters.STOP;   
	
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. STOP..")";
	
	STOP = STOP*source:pipSize();
	
    instance:name(name);
    PTS = instance:addStream("PTS", core.Line, name, "TS", instance.parameters.PTS_color, first);
	PTS:setWidth(instance.parameters.width);
	PTS:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  	     
		  if period >= first and source:hasData(period) then  
			   
			
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

