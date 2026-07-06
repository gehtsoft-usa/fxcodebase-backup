
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63706

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
    indicator:name("Candle Completion");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", " Type","" , "Percentage");
    indicator.parameters:addStringAlternative("Type", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addStringAlternative("Type", "Fraction", "Fraction" , "Fraction"); 
     indicator.parameters:addInteger("Number", "Fraction Number","" , 6);
  
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
local Number, Type;
-- Routine
function Prepare(nameOnly) 
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size; 
	Number=instance.parameters.Number;
	Type=instance.parameters.Type;
	
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
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
 
	
	if stage ~= 0 then
	return;
	end
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0); 
        end
	
	local Last=source:size()-1;
	local Value= math.abs(source.open[Last]-source.close[Last])/((source.high[Last]-source.low[Last])/100);		
	local Text1;
	
	if Type == "Percentage" then
	Text1=  "Body / Candle : " ..  win32.formatNumber(Value, false, 0)  .. "/100"   ;
	else	
	Value= Decode(Value);
	Text1=  "Body / Candle : "   .. (Value) .. "/" .. Number;
	end

   local i=0; 
   i=i+1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	

   
   
end		
 
function Decode(Value)
  local Delta =100/Number;
  for i=1, Number,1 do
  if Value>=(i-1)*Delta and  Value<=(i)*Delta then
  Return=tostring(i);
  break;
  end
  end
  return Return;
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
 