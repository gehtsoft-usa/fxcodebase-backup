-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64025&p=108779#p108779

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Reversal Zone");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", " Period","" , 50);
	
	indicator.parameters:addBoolean("Historical", "Show Historical", "Historical", true);
	indicator.parameters:addBoolean("Show", "Show Value", "Value", true);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
   
	
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
     indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
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
local Period;
local Historical;
local Show;
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;  
    Historical=instance.parameters.Historical;	
	Show=instance.parameters.Show;
    source = instance.source;
    first=source:first();
	
	Period=instance.parameters.Period;
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	
   	
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  if source.close[period] >  source.high[period-1]
  and source.close[period-1] <  source.open[period-1]
  then
  Up[period]= source.close[period] -  source.high[period-1];
  Down[period]=0;
  end
  
  
  if source.close[period] <  source.low[period-1]
   and source.close[period-1] >  source.open[period-1]	
  then
  Up[period]= 0;
  Down[period]=source.close[period] - source.low[period-1];
  end
end
 
local init = false;
 
function Draw(stage, context)
 
	
	if stage~= 2 then
	return;
	end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		   context:createPen (11, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Up);
		   context:createPen (12, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down);
		  
            init = true;
        end
	

   local AverageUp, AverageDown;
   local  First,Last;
   
  
   First= math.max(context:firstBar (),source:first());
   Last=math.min( context:lastBar (), source:size()-1);
  
   
     if Historical then

     	 
   
   	for period= First, Last, 1 do
		
		 x, x1, x2= context:positionOfBar (period);
		 
		AverageUp, AverageDown=Calculate(period);
		
		if source.close[period]>source.open[period] then
		visible, y = context:pointOfPrice (source.low[period-1]+AverageDown);
		Color=12;
		else
		visible, y = context:pointOfPrice (source.high[period-1]+AverageUp);
		Color=11;
		end
		  
          context:drawLine (Color, x1, y, x2, y);
		  
		
		    
		 
		
		end
		
      else
	           period=source:size()-1;
	           x, x1, x2= context:positionOfBar (period);
		 
				AverageUp, AverageDown=Calculate(period);
				
				if source.close[period]>source.open[period] then
				visible, y = context:pointOfPrice (source.low[period-1]+AverageDown);
				Color=12;
				else
				visible, y = context:pointOfPrice (source.high[period-1]+AverageUp);
				Color=11;
				end
				  
				  
				  context:drawLine (Color, x1, y, x2, y);
				  
		  
		  
	  
	  end
	  
	  
if Show then

period=source:size()-1;

AverageUp, AverageDown=Calculate(period);
	
if source.close[period]>source.open[period] then	
Text1=(win32.formatNumber(((source.low[period-1]+AverageDown - source.close[period])/source:pipSize()), false, source:getPrecision ())) .. " pips from  " .. (  win32.formatNumber(source.low[period-1]+AverageDown, false, source:getPrecision ()));
else
Text1=(win32.formatNumber(((source.high[period-1]+AverageUp - source.close[period])/source:pipSize()), false, source:getPrecision ())) .. " pips from  ".. ( win32.formatNumber(source.high[period-1]+AverageUp, false, source:getPrecision ())) 
end 

	 
local i=1;	 
width, height = context:measureText (1, Text1, 0);
context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
end	  
	  

end		
 
 
function Calculate(period)
 local AverageUp=0;
 local UpCount=0;
 
 local AverageDown=0;
  local DownCount=0;
  
  
 for period= period, source:first()+1, -1 do
 
		  if source.close[period] >  source.high[period-1]
		  and   source.close[period-1] <  source.open[period-1]
		  then
		  UpCount=UpCount+1;
		  AverageUp= AverageUp + (source.close[period] -  source.high[period-1]);
		  end
		  
		  
		  if source.close[period] <  source.low[period-1]
		   and source.close[period-1] >  source.open[period-1]
		  then
		  DownCount=DownCount+1;
		  AverageDown= AverageDown + (source.close[period] - source.low[period-1]);
		  end
		 
 end
 
 AverageUp=AverageUp/UpCount;
 AverageDown=AverageDown/DownCount;
 
  return AverageUp, AverageDown;
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
 