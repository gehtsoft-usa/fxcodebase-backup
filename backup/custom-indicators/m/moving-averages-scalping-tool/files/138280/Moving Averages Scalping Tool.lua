-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Moving Averages Scalping Tool")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Period1", "1. MA Period", "", 50, 1, 1000)
	indicator.parameters:addInteger("Period2", "2. MA Period", "", 100, 1, 1000)
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 200, 1, 1000)
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("Lines", "Show Lines", "", true);
	indicator.parameters:addBoolean("Off", "Exclude 1. MA filtering", "", true);
	indicator.parameters:addDouble("Ratio", "Risk/Reward Ratio", "", 4, 0, 1000)
 

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down  Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40);
	
	indicator.parameters:addGroup("1. MA Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("2. MA Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("3. MA Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source;
local Period1, Period2, Period3,Method;
local Off;
local open = nil;
local close = nil;
local high = nil;
local low = nil;

--local MA = nil;
local MA1,MA2,MA3;
local ma1, ma2, ma3;
local Up, Down;
local Ratio;
local Lines;
local Transparency;
local Trend;
local LastCross;
function Prepare(nameOnly)
	 
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Method = instance.parameters.Method;
	Lines = instance.parameters.Lines;
	Ratio = instance.parameters.Ratio;
	Off= instance.parameters.Off;
	source = instance.source;

	Up = instance.parameters.Up;
	Down = instance.parameters.Down;

	local name = profile:id() .. "(" .. source:name() .. ", " .. Period1, Period2, Period3 .. ", " .. Method .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1 = core.indicators:create(Method, source , Period1);
	MA2 = core.indicators:create(Method, source , Period2);
    MA3 = core.indicators:create(Method, source , Period3);
	first = math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first());
     
	if Lines then
	ma1 = instance:addStream("ma1" , core.Line, "1. MA","1. MA",instance.parameters.color1, first );
	ma1:setWidth(instance.parameters.width1);
    ma1:setStyle(instance.parameters.style1);
    ma1:setPrecision(math.max(2, source:getPrecision()));
	
	ma2 = instance:addStream("ma2" , core.Line, "2. MA","2. MA",instance.parameters.color2, first );
	ma2:setWidth(instance.parameters.width2);
    ma2:setStyle(instance.parameters.style2);
    ma2:setPrecision(math.max(2, source:getPrecision()));
	
	
	ma3 = instance:addStream("ma3" , core.Line, "3. MA","3. MA",instance.parameters.color3, first );
	ma3:setWidth(instance.parameters.width3);
    ma3:setStyle(instance.parameters.style3);
    ma3:setPrecision(math.max(2, source:getPrecision())); 
	
	else
	ma1 = instance:addInternalStream(0, 0);
	ma2 = instance:addInternalStream(0, 0);
	ma3 = instance:addInternalStream(0, 0);
	end
	
	Trend = instance:addInternalStream(0, 0);
	
	instance:ownerDrawn(true);

end

-- Indicator calculation routine
function Update(period, mode)
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	if period < first then
		return
	end
	
	
	ma1[period]=MA1.DATA[period];
	ma2[period]=MA2.DATA[period];
	ma3[period]=MA3.DATA[period];

	
	 Trend[period]=0;
	
	if source[period]> MA1.DATA[period]
	and (MA1.DATA[period]> MA1.DATA[period-1] or Off )
	and MA2.DATA[period]> MA2.DATA[period-1]
	and MA3.DATA[period]> MA3.DATA[period-1]
	and (MA1.DATA[period]> MA2.DATA[period] or Off )
	and MA2.DATA[period]> MA3.DATA[period]
	then
	Trend[period]=1;
	elseif  source[period]< MA1.DATA[period]
 	and (MA1.DATA[period]< MA1.DATA[period-1]  or Off )
	and MA2.DATA[period]< MA2.DATA[period-1]
	and MA3.DATA[period]< MA3.DATA[period-1]
	and (MA1.DATA[period]< MA2.DATA[period] or Off )
	and MA2.DATA[period]< MA3.DATA[period]
	then
	Trend[period]=-1;
	end
	
	if period <source:size()-1 then
	return;
	end
	
	LastCross= FindLastCross(period);
 
end
function FindLastCross(period) 

local Return=0;

    for i= period, first, -1 do
	
	
		 if Off then
		          if core.crosses (source , MA1.DATA, i) then
				 Return=i;
				 break;
		         end
		 else
		 
				 if core.crosses (MA1.DATA, MA2.DATA, i) then
				 Return=i;
				 break;
		         end
	    end
	 
	end
	

	return Return;

end

local init = false;
 
function Draw(stage, context)
    if stage ~= 0
	then
	return;
	end 
	
	   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
	
        if not init then
            context:createSolidBrush(1, Up);
			 context:createSolidBrush(2, Down);
			 	Transparency = context:convertTransparency (instance.parameters.Transparency);	  
            init = true;
        end
 
		
		local Last=source:size()-1;
		x, x , x1 =  context:positionOfBar (LastCross);
		x, x , x2 =  context:positionOfBar (Last);
		
		visible1, y1 =context:pointOfPrice (MA1.DATA[LastCross]);
		visible2, y2  = context:pointOfPrice (MA2.DATA[LastCross]);
		visible3, y3  = context:pointOfPrice (MA3.DATA[LastCross]);
		
		
		if Off then
		
		    if Trend[Last]== Trend[LastCross] and Trend[Last]==1 then		
			C1=1;
			C2=2;
			context:drawRectangle(-1, C1, x1, y1-math.abs(y2-y3)*Ratio, x2, y1, Transparency);
			context:drawRectangle(-1, C2, x1, y3, x2, y1, Transparency);
			elseif Trend[Last]==Trend[LastCross] and Trend[Last]==-1  then
			C1=1;
			C2=2;
			context:drawRectangle(-1, C1, x1, y1+math.abs(y2-y3)*Ratio, x2, y1, Transparency);
			context:drawRectangle(-1, C2, x1, y3, x2, y1, Transparency);
			end
		 
		else
		
		
			if Trend[Last]== Trend[LastCross]  and Trend[Last]==1  then		
			C1=1;
			C2=2;
			context:drawRectangle(-1, C1, x1, y2-math.abs(y1-y3)*Ratio, x2, y2, Transparency);
			context:drawRectangle(-1, C2, x1, y3, x2, y2, Transparency);
			elseif Trend[Last]==Trend[LastCross]  and Trend[Last]==-1  then
			C1=1;
			C2=2;
			context:drawRectangle(-1, C1, x1, y2+math.abs(y1-y3)*Ratio, x2, y2, Transparency);
			context:drawRectangle(-1, C2, x1, y3, x2, y2, Transparency);
			end
		
		end
		
   
	
end

