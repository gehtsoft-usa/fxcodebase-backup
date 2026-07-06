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
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
     indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("method", "Method", "ATR" , "ATR");
    indicator.parameters:addStringAlternative("method", "ATR", "ATR" , "ATR");
	indicator.parameters:addStringAlternative("method", "Percentage", "Percentage" , "Percentage");
	indicator.parameters:addStringAlternative("method", "In Pips", "" , "Pips");
	
	indicator.parameters:addDouble("P", "Percentage ", "Percentage ", 3, 0, 100);	
    indicator.parameters:addInteger("AP", "ATR period ", "ATR Period ", 14);
	indicator.parameters:addDouble("AM", "ATR multiplicator ", "ATR multiplicator ", 3.5);	
	 indicator.parameters:addInteger("STOP", "Initial Stop (In Pips) ", "", 100 , 0, 10000);
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("TS_color", "Color of TS", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Percentage=nil;
local Method=nil;

local first;
local source = nil;

-- Streams block
local TS = nil;
local STOP;

local Multiplicator=nil;
local Frame=nil;

local first;
local source = nil;

-- Streams block
local ATR=nil;

local name=nil;



-- Routine
function Prepare()
    Method = instance.parameters.method;
	STOP= instance.parameters.STOP;  
	
	Percentage = instance.parameters.P;
		
	Multiplicator = instance.parameters.AM;
	Frame = instance.parameters.AP;
	
    source = instance.source;
    first = source:first();
	
	if Method == "ATR" then	
	name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " ..  Multiplicator .. ", " .. Method.. ")";
	elseif Method ==  "Percentage" then
	name = profile:id() .. "(" .. source:name() .. ", " .. Percentage .. ", " .. Method.. ")";
	else
	name = profile:id() .. "(" .. source:name() .. ", " .. STOP..")";
	end
	
    instance:name(name);
	
	if Method == "ATR" then
	ATR= core.indicators:create("ATR", source, Frame);
	end
	if Method == "Pips" then
	STOP = STOP*source:pipSize();  
	end
	
	TS = instance:addStream("TS", core.Line, name, "TS", instance.parameters.TS_color, first);
	TS:setWidth(instance.parameters.width);
	TS:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

	if Method == "Percentage" then
	 
			 
					  if period >= first and source:hasData(period) then
						 

							STOP=(source.close[period]/100)*Percentage;
					
						   
						
							if source.close[period] < TS[period-1] and  source.close[period-1] > TS[period-1] then
							TS[period] = source.close[period]+STOP;
							elseif source.close[period] < TS[period-1] and  source.close[period-1] < TS[period-1] then
							TS[period]= math.min(TS[period-1],source.close[period]+STOP);					
							end	
					
							
							if source.close[period] > TS[period-1] and  source.close[period-1] < TS[period-1] then
							TS[period] = source.close[period]-STOP;
							elseif source.close[period]  > TS[period-1] and   source.close[period-1] > TS[period-1] then
							TS[period]= math.max(TS[period-1],source.close[period]-STOP);		
							end	

					
					end	
				
				
				
				
		elseif Method ==  "ATR" then
		
		       if period >= Frame and source:hasData(period) then
	     
			  
						ATR:update(mode);

						STOP=ATR.DATA[period]*Multiplicator;
				
					   
					
						if source.close[period] < TS[period-1] and  source.close[period-1] > TS[period-1] then
						TS[period] = source.close[period]+STOP;
						elseif source.close[period] < TS[period-1] and  source.close[period-1] < TS[period-1] then
						TS[period]= math.min(TS[period-1],source.close[period]+STOP);					
						end	
				
						
						if source.close[period] > TS[period-1] and  source.close[period-1] < TS[period-1] then
						TS[period] = source.close[period]-STOP;
						elseif source.close[period]  > TS[period-1] and   source.close[period-1] > TS[period-1] then
						TS[period]= math.max(TS[period-1],source.close[period]-STOP);		
						end	
				end
          else
		    
			     if period >= first and source:hasData(period) then
				   
						if source.close[period] < TS[period-1] and  source.close[period-1] > TS[period-1] then
						TS[period] = source.close[period]+STOP;
						elseif source.close[period] < TS[period-1] and  source.close[period-1] < TS[period-1] then
						TS[period]= math.min(TS[period-1],source.close[period]+STOP);					
						end	
				
						
						if source.close[period] > TS[period-1] and  source.close[period-1] < TS[period-1] then
						TS[period] = source.close[period]-STOP;
						elseif source.close[period]  > TS[period-1] and   source.close[period-1] > TS[period-1] then
						TS[period]= math.max(TS[period-1],source.close[period]-STOP);		
						end	
		
		       end
	
          	
		
	    end	
end

