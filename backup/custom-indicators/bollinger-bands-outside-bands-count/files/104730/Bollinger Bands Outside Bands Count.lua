
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63137

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
function Init()
    indicator:name("Bollinger Bands Outside Bands Count");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Bollinger Bands Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	indicator.parameters:addDouble("Deviations", "Number of standard deviations", "", 2);
	 
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 100);
	
  
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
	
	indicator.parameters:addGroup("Label Style");
   indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("LabelSize", "Font Size", "", 10);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local LabelColor,LabelSize,X,Y, ShiftY;
local Over = nil;
local Under = nil;
local LookBack;
local min,max;
local Deviations, Period;
local BB;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	LookBack= instance.parameters.LookBack;
	LabelColor= instance.parameters.LabelColor;
	LabelSize= instance.parameters.LabelSize;
	X= instance.parameters.X;
	Y= instance.parameters.Y;
	ShiftY= instance.parameters.ShiftY;
	Deviations= instance.parameters.Deviations;
	Period= instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	
	BB=core.indicators:create("BB",  source , Period, Deviations);
    first = BB.DATA:first() ; 
 
	
	Over = instance:addInternalStream(first, 0);
	Under = instance:addInternalStream(first, 0);
 
	min=nil;
	
	instance:ownerDrawn(true);
end

-- Indicator calculation routine
function Update(period)

    BB:update(mode);
	
	Over[period]=0;
    Under[period]=0;     
 
		  
    if period < first or not  source:hasData(period) then
	return;
	end
	
	if source[period]> BB.TL[period]then
	Over[period]=1;
	elseif source[period]< BB.BL[period]then
	Under[period]=1;
	end
	
   if period < source:size()-1 then
   return;
   end   
	
 
		
	   max=mathex.sum(Over, math.max(first, period-LookBack+1), period);
       min=mathex.sum(Under, math.max(first, period-LookBack+1), period);
 
end

local init = false;
 
function Draw(stage, context)


   if stage~= 2 then
   return;
   end
 
	if min == nil then
	return;
	end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (LabelSize), context:pointsToPixels (LabelSize), 0);
            init = true;
        end
	
			
	local Text1=  " Outside Bands : " ..  (min+max);
	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, LabelColor, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY,3) ,iX(context,width,0,2),iY(context,height,1+ShiftY,4), 0 );	
   
 
end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end


