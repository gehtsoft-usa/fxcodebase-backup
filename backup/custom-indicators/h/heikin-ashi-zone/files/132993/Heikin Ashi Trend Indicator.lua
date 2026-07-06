-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69639
 
--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

 
function Init()
    indicator:name("Heikin Ashi Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("Continuation", "Continuation", "Continuation", true);
	
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local Continuation; 
local first;
local source = nil;

-- Streams block
 
local Up, Down, Neutral;
-- Routine
function Prepare(nameOnly)
 
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
	Continuation = instance.parameters.Continuation;
	 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 
    HA = core.indicators:create("HA", source);
    first = HA.DATA:first();	
	 
	
	
	Trend = instance:addStream("Trend", core.Bar, name, "Trend", core.rgb(0, 0, 0), first)
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
   
   
    HA:update(mode);
	 
   
	

     
	if period < first  or not source:hasData(period) then 
    return;
    end 
 
	            if HA.close[period] > HA.open[period] and source.close[period] > source.open[period]  then 
				Trend[period]=1; 				
				elseif HA.close[period] < HA.open[period] and source.close[period] < source.open[period] then 
				Trend[period]=-1; 					
				else
				
				 if Continuation then
				 Trend[period]=Trend[period-1]; 
				 else
				 Trend[period]=0; 				
				 end
				 
				end
	
	if Trend[period]==1 then
	Trend:setColor(period, Up);
	elseif Trend[period]==-1 then
	Trend:setColor(period, Down);
	else
	Trend:setColor(period, Neutral);
	end
				

end

