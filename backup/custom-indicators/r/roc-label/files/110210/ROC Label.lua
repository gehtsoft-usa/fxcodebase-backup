-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64240

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
    indicator:name("ROC Label");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

   	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", " Period","" , 14);
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("LabelUp", "Up Label Color", "",core.rgb(0, 255, 0));
   indicator.parameters:addColor("LabelDown", "Down Label Color", "", core.rgb(255, 0, 0));
   indicator.parameters:addInteger("Size", "Font Size", "", 20);

 
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

-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    LabelUp=instance.parameters.LabelUp;
	LabelDown=instance.parameters.LabelDown;
	Size=instance.parameters.Size;   
	Period=instance.parameters.Period;
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   	
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
	local period=source:size()-1;
	local ROC = (source[period] / source[period - Period] - 1) * 100;		
	local Text1=  "ROC : " ..  win32.formatNumber(ROC, false, source:getPrecision());
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   
   if ROC> 0 then
   context:drawText (1,  Text1, LabelUp, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   else
   context:drawText (1,  Text1, LabelDown, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end

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
 