--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
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
    indicator:name("Marker x2");
    indicator:description("Markers the x bars back");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("LookBacka", "LookBack Period", "", 8);
    indicator.parameters:addInteger("LookBackb", "LookBack Period", "", 25);
	
	indicator.parameters:addGroup("Mode");
	indicator.parameters:addString("Mode", "Market Type", "", "Trailing");
    indicator.parameters:addStringAlternative("Mode", "Trailing", "", "Trailing");
	indicator.parameters:addStringAlternative("Mode", "Locked", "", "Locked");

	 indicator.parameters:addGroup("Marker Style");
	  indicator.parameters:addColor("Color1", "Bar Colora", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width1", "Widtha", "The width of the marker, range is 5 to 20.", 10, 5, 20);
	


	  indicator.parameters:addColor("Color2", "Bar Colorb", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width2", "Widthb", "The width of the marker, range is 5 to 20.", 10, 5, 20);


	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Color1, Color2;
local Width1,Width2;
local LookBacka=0;
local LookBackb=0;

local first;
local source = nil;

-- Streams block
local open=nil;
local close=nil;
local high=nil;
local low=nil;

local MARKER1,MARKER2 ;
local Mode;
local LAST1=nil;
local LAST2=nil;
local FIRST= true;
local SECOND=true;
-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode;
    
    Color1 = instance.parameters.Color1;
    Width1 = instance.parameters.Width1;
	 Color2 = instance.parameters.Color2;
    Width2 = instance.parameters.Width2;

	 LookBacka = instance.parameters.LookBacka;
	 LookBackb = instance.parameters.LookBackb;
    source = instance.source;
    first = source:first();


    local name

    if LookBacka ~= 0 or LookBackb ~= 0 then
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LookBacka)  .. ", " .. tostring(LookBackb).. ", " .. tostring(Mode) .. ")";
	else
	name = profile:id() .. "(" .. source:name() .. ")";
	end
    instance:name(name);

    if (not (nameOnly)) then
			
				MARKER1 = instance:createTextOutput ("MARKER1", "1. MARKER", "Wingdings", Width1, core.H_Center, core.V_Bottom, instance.parameters.Color1, 0);			
				MARKER2 = instance:createTextOutput ("MARKER2", "2. MARKER", "Wingdings", Width2, core.H_Center, core.V_Bottom, instance.parameters.Color2, 0);
			
    end
	
	FIRST= true
	SECOND= true
    LAST1=nil;
	LAST2=nil;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then

	
			if Mode == "Trailing" then
			
						if source:serial(source:size()-1) ~= LAST1  and period == source:size()-1 then
						  
						  
						  
						   if LookBacka ~= 0  and LookBacka+1 < period  then
						  
						   LAST1  = source:serial(source:size()-1);

								
									MARKER1:set(period-LookBacka, source.low[period-LookBacka] , "\108");				
									MARKER1:setNoData (period-LookBacka-1);
								

							end
						  
						  
						end  
			
				 else
					
					
					 if  FIRST and  period == source:size()-1 then	
					     FIRST = false;
						  
							if LookBacka ~= 0  and LookBacka+1 < period  then							

								
									MARKER1:set(period-LookBacka, source.low[period-LookBacka] , "\108");				
									MARKER1:setNoData (period-LookBacka-1);
								

							end
						  
						  
					end	  
				 

				 end
				 
				 
			if Mode == "Trailing" then
			
						if source:serial(source:size()-1) ~= LAST2  and period == source:size()-1 then
						  
						  
						  
						   if LookBackb ~= 0  and LookBackb+1 < period  then
						  
						   LAST2  = source:serial(source:size()-1);

								
									MARKER2:set(period-LookBackb, source.low[period-LookBackb] , "\108");				
									MARKER2:setNoData (period-LookBackb-1);
								

							end
						  
						  
						end  
			
				 else
					
					
					 if  SECOND and  period == source:size()-1 then	
					     SECOND = false;
						  
							if LookBackb ~= 0  and LookBackb+1 < period  then							

								
									MARKER2:set(period-LookBackb, source.low[period-LookBackb] , "\108");				
									MARKER2:setNoData (period-LookBackb-1);
								

							end
						  
						  
					end	  
				 

				 end		 
      
    end
end

