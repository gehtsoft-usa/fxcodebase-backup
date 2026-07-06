-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69988

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Persistence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addBoolean("Wicks", "Wicks", "", true);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0));
     indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "", 10);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Overshot;
local Wicks; 
local first;
local source = nil;
 
local Up, Down, up, down;  
 
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Wicks= instance.parameters.Wicks;
	Size= instance.parameters.Size;
	
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first();
	
 
   
 
	Up =  instance:addInternalStream(0, 0);
    Down =  instance:addInternalStream(0, 0);
	
	
	 up = instance:createTextOutput ("Up", "Up", "Arial", Size, core.H_Center, core.V_Top, instance.parameters.UpColor, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Arial", Size, core.H_Center, core.V_Bottom, instance.parameters.DownColor, 0);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()
	then
	return;
	end
	
	local min1=math.min(source.close[period-1],source.open[period-1]);
	local max1=math.max(source.close[period-1],source.open[period-1]);
	
	local min0=math.min(source.close[period],source.open[period]);
	local max0=math.max(source.close[period],source.open[period]);

       Up[period]=Up[period-1]+1;
	 Down[period]=Down[period-1]+1;
	 
	 if  max0 > source.high[period-1]  
	 or max1 > source.high[period]
	 then
     Up[period]=0;
	 elseif  min0 < source.low[period-1]
	 or min1 < source.low[period]
     then
	 Down[period]=0;
	 end
	 
	 
	  down:setNoData(period);
	  up:setNoData(period);
	  
	  if Up[period]~=0 then
	  up:set(period , source.high[period ], tostring(Up[period]));
	  end
	  if Down[period]~=0 then
	  down:set(period , source.low[period ], tostring(Down[period] ));
	  end
	 
				  
end
 
