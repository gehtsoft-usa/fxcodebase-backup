
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63136#p104725

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
    indicator:name("Fractal Based Support/Resistance Count");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 100);
	
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("LabelSize", "Font Size", "Font Size", 10);
    indicator.parameters:addColor("clrUP", "Color of Up Fractal", "Color of Up Fractal", core.rgb(255, 192, 0));
    indicator.parameters:addColor("clrDN", "Color of Down Fractal", "Color of Down Fractal", core.rgb(0, 192, 255));
	
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
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local LabelSize, LookBack;
local R = nil;
local S = nil;
 local U,D;
local Top=nil;
local Bottom=nil;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
 
	LookBack= instance.parameters.LookBack; 
	LabelSize= instance.parameters.LabelSize;
	 

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	R = instance:createTextOutput ("Up", "Up", "Wingdings", LabelSize, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    S = instance:createTextOutput ("Dn", "Dn", "Wingdings",  LabelSize, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
    U = instance:addInternalStream(0, 0);
	D = instance:addInternalStream(0, 0);
	
	Top=nil;
	Bottom=nil;
	
	 Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   

	
	 instance:ownerDrawn(true);
end

-- Indicator calculation routine
function Update(period)

    if period < source:first()+6 or not  source:hasData(period) then
	return;
	end
	
  
	    if (period > 6) then
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            R:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            U[period]=1;
        else
            R:setNoData(period - 2);
            U[period]=0;
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
            S:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            D[period]=1; 
        else
            S:setNoData(period - 2);
            D[period]=0; 
        end
    end
    
	
	if period < source:size()-1 then
	return;
	end
	
    Top=mathex.sum(U, math.max(source:first(), period-LookBack+1), period);
	Bottom=mathex.sum(D, math.max(source:first(), period-LookBack+1), period);
end



local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 
	  or Top== nil
	  or Bottom== nil
	  then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
	local Text1;
	
   Text1=  "Top : " ..  Top
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
   
   Text1=  "Bottom : " ..  Bottom
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,1,1) ,  iY(context,height,i,0) ,iX(context,width,1,2),iY(context,height,i,1), 0 );	

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
 
 