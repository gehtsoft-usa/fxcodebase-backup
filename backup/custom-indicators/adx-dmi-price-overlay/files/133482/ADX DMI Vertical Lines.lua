-- More information about this indicator can be found at:
--  http://fxcodebase.com/code/viewtopic.php?f=17&t=69794

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
    indicator:name("ADX & DMI Vertical Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 1000);
    indicator.parameters:addInteger("ADX_Level", "ADX_Level", "", 20, 0, 1000);
 
	
	indicator.parameters:addGroup("Vertical Line Style");
	
	
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	

 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
		indicator.parameters:addGroup("Style");
	
	indicator.parameters:addColor("color1", "ADX Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "DIP Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "DIM Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Up,Down, Neutral;
 
local ADX_Level;
local  adx=nil;
local  dip=nil;
local  dim=nil;

local Period, ADX, DMI;
local signal;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
	width= instance.parameters.width;
	style= instance.parameters.style;
	color= instance.parameters.color;


 
   Period = instance.parameters.Period;
   ADX_Level = instance.parameters.ADX_Level;
	
 

	source = instance.source;
	
	signal = instance:addInternalStream(0, 0);
	
	ADX=core.indicators:create("ADX",  source, Period);
	DMI=core.indicators:create("DMI",  source, Period);	
	first=ADX.DATA:first();

    	
	adx = instance:addStream("ADX", core.Line, name, "ADX",  instance.parameters.color1, first);
	adx:setWidth(instance.parameters.width1);
    adx:setStyle(instance.parameters.style1);
		
    dip = instance:addStream("DIP", core.Line, name, "DIP",  instance.parameters.color2, first);
	dip:setWidth(instance.parameters.width2);
    dip:setStyle(instance.parameters.style2);
		
	dim = instance:addStream("ADX", core.Line, name, "ADX",  instance.parameters.color3, first);
	dim:setWidth(instance.parameters.width3);
    dim:setStyle(instance.parameters.style3);
	
	adx:addLevel(ADX_Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
            ADX:update(mode);
			DMI:update(mode);
			   
	
			if period < first then 	
			return;
			end
	
 
	
			 
			   
			   
			   adx[period]=ADX.DATA[period];
			   dip[period]=DMI.DIP[period];
			   dim[period]=DMI.DIM[period];
		
	    signal[period]=signal[period-1];
		
		
		if ADX.DATA[period]> ADX_Level  and DMI.DIP[period]>DMI.DIM[period]  then	 
		signal[period]=1;
        elseif ADX.DATA[period]> ADX_Level  and DMI.DIP[period]<DMI.DIM[period] then 
		signal[period]=-1;
		else
		signal[period]=0; 	
		end
		
		
			instance:ownerDrawn(true); 	

		
 end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
    	return;
	end
	
	
    if not init then
        context:createPen (1, context:convertPenStyle (style), context:pixelsToPoints (width), Up);
		context:createPen (2, context:convertPenStyle (style), context:pixelsToPoints (width), Down);
		context:createPen (3, context:convertPenStyle (style), context:pixelsToPoints (width), Neutral);
        init = true;
    end

    local left, top, right, bottom=context:left(), context:top(), context:right(), context:bottom();
 
    context:setClipRectangle(left, top, right, bottom);


    local first = math.max(source:first(), context:firstBar ());
    local last = math.min (context:lastBar (), source:size()-1);
		
    local x, x1, x2;
	local period;
    for period= first, last, 1 do	

        x, x1, x2 = context:positionOfBar (period);	
	
	    if signal[period] == 1 and signal[period-1]~= 1	then        
        context:drawLine (1, x, top, x, bottom);
		elseif signal[period] == -1 and signal[period-1]~= -1 then		      
        context:drawLine (2, x, top, x, bottom);
		elseif signal[period] == 0 and signal[period-1]~= 0	then	    
        context:drawLine (3, x, top, x, bottom);
		end
		
    end

    context:resetClipRectangle();
end
