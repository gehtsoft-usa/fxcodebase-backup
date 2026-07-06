
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63690


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Candle lenght predictor");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("S1", "Show Open ", "", true);
	indicator.parameters:addBoolean("S2", "Show Average ", "", true);
	indicator.parameters:addBoolean("S3", "Show Top", "", true);
	indicator.parameters:addBoolean("S4", "Show Bottom", "", true);
	indicator.parameters:addBoolean("S5", "Show Distance from Top", "", true);
	indicator.parameters:addBoolean("S6", "Show Distance from Bottom", "", true);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period","" , 14);
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Label Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 14);
  
	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
	indicator.parameters:addGroup("Zone Style");
    indicator.parameters:addInteger("transparency", "Transparency","", 50);
	indicator.parameters:addColor("top_color", "Top Zone Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("bottom_color", "Bottom Zone Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("wick_color_up", "Up Candle Wick Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("wick_color_down", "Down Wick Color", "", core.rgb(255, 255, 128))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local Range;
local Period;
local S1,S2,S3,S4,S5,S6;
local transparency;
local Up,Down;
-- Routine
function Prepare(nameOnly) 
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;
    Period=instance.parameters.Period;
	S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
	S4=instance.parameters.S4;
	S5=instance.parameters.S5;
	S6=instance.parameters.S6;
	
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
   	
    instance:ownerDrawn(true);
   
   
    Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	Range = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

    Range[period]= source.high[period]- source.low[period];
	
	Up[period]= source.high[period]-math.max(source.open[period],source.close[period]);
	Down[period]=  math.min(source.open[period],source.close[period])-source.low[period];
end
 
local init = false;
 
function Draw(stage, context)
 
	
	if stage ~= 0 then
	return;
	end
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		   context:createPen (3, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.top_color);
		   context:createPen (5, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.bottom_color);
		   transparency=context:convertTransparency (instance.parameters.transparency);
		   
		   context:createPen (11, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.wick_color_up);
		   context:createPen (12, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.wick_color_down);
		   context:createSolidBrush (4, instance.parameters.top_color);
		 
		   context:createSolidBrush (6, instance.parameters.bottom_color);
            init = true;
        end
	
	local Open= source.open[source.open:size()-1];		
	local Text1=  "Open Price : " ..  win32.formatNumber(Open, false, source:getPrecision());

   local i=0;
   
   if S1 then
   i=i+1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   local Average= mathex.avg(Range,source.open:size()-1-Period+1,source.open:size()-1 )/source:pipSize();
   
   if S2 then
   i=i+1; 
   Text1=  "Average Range : " .. win32.formatNumber(Average, false, source:getPrecision())
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
    local Top=Open  + Average *source:pipSize();
	
   if S3 then
   i=i+1;	   
   Text1=  "Top Range Limit : " .. win32.formatNumber(Top, false, source:getPrecision())
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
     local Bottom=Open  - Average *source:pipSize();
   
   if S4 then
    i=i+1;	  
   Text1=  "Bottom Range Limit : " .. win32.formatNumber(Bottom, false, source:getPrecision())
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
   if S5 then
   i=i+1; 
   Text1=  "Distance from Top : " .. win32.formatNumber((Top-source.close[source:size()-1])/source:pipSize(), false, source:getPrecision())
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
   if S6 then
   i=i+1;	 
   Text1=  "Distance from Bottom  : " .. win32.formatNumber(( source.close[source:size()-1]-Bottom)/source:pipSize(), false, source:getPrecision())
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
   visible, y1 =context:pointOfPrice (Top);
   visible, y2 = context:pointOfPrice (Bottom);
   context:drawLine (3, context:left (), y1, context:right (), y1 );
   context:drawLine (5, context:left (), y2, context:right (), y2 );
   
   visible, y3 = context:pointOfPrice (Open);
   context:drawRectangle (3, 4, context:left (), y1, context:right (), y3, transparency );
   context:drawRectangle (5, 6, context:left (), y3, context:right (), y2, transparency );
   
    AT= mathex.avg(Up,source.open:size()-1-Period+1,source.open:size()-1 );
	AB= mathex.avg(Down,source.open:size()-1-Period+1,source.open:size()-1 )
   
    visible, TU =context:pointOfPrice (Top+AT);
	visible, TD =context:pointOfPrice (Open-AB)
	 
	visible, BU =context:pointOfPrice (Open+AT);
	visible, BD =context:pointOfPrice (Bottom-AB);
	
	context:drawLine (11, context:left (), TU, context:right (), TU );
	context:drawLine (11, context:left (), TD, context:right (), TD );
	context:drawLine (12, context:left (), BU, context:right (), BU );
	context:drawLine (12, context:left (), BD, context:right (), BD );
end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 