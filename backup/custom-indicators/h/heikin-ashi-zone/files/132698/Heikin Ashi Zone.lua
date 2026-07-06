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
    indicator:name("Heikin Ashi Zone");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation");
    
	indicator.parameters:addString("Method1", "Candle Method", "Method" , "HA");
    indicator.parameters:addStringAlternative("Method1", "HA", "HA" , "HA");
    indicator.parameters:addStringAlternative("Method1", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Method1", "Both", "Both" , "Both");
	
	indicator.parameters:addString("Method2", "Color Method", "Method" , "HA");
    indicator.parameters:addStringAlternative("Method2", "HA", "HA" , "HA");
    indicator.parameters:addStringAlternative("Method2", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Method2", "Both", "Both" , "Both");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local Method1, Method2;

local first;
local source = nil;

-- Streams block
--local HZU = nil;
--local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
-- Routine
function Prepare(nameOnly)
 
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	if Method1~= "Price" or Method2~= "Price" then
    HA = core.indicators:create("HA", source);
    first = HA.DATA:first();	
	else
	first = source:first();
	end
	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
   
    if Method1~= "Price" or Method2~= "Price" then
    HA:update(mode);
	end
   
	

     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
	
	if Method1 ~= "Price" then
	high[period]= HA.high[period];
	low[period]= HA.low[period];		   
	close[period] = HA.close[period];
	open[period]  = HA.open[period];	
	else
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	end
  
				   
   
    if Method2 == "Price" then
	
	            if source.close[period] > source.open[period] then 
				open:setColor(period, Up);
				elseif source.close[period] < source.open[period] then 
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end
	
	
 
	elseif Method2 == "HA" then
	
	           if HA.close[period] > HA.open[period] then 
				open:setColor(period, Up);
				elseif HA.close[period] < HA.open[period] then 
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end
	else

	            if HA.close[period] > HA.open[period] and source.close[period] > source.open[period]  then 
				open:setColor(period, Up);
				elseif HA.close[period] < HA.open[period] and source.close[period] < source.open[period] then 
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end
				 
	end
	
	
				

end

