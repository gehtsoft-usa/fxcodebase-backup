-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64678
-- Id: 18185

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Inverse prices");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");
	
	
	indicator.parameters:addGroup("Selector");
 
   -- indicator.parameters:addBoolean("Historic", "Historic", "", true);
    --indicator.parameters:addBoolean("Inverse", "Inverse", "", true);
	indicator.parameters:addInteger("Additional", " Additional decimal places","" , 0);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
   indicator.parameters:addInteger("HistoricSize", "Historic Font Size", "", 7);
   indicator.parameters:addColor("Up", "Up Candle", "", core.COLOR_UPCANDLE  );
   indicator.parameters:addColor("Down", "Down Candle", "", core.COLOR_DOWNCANDLE  );
   
   indicator.parameters:addColor("iUp", "Inverse Up Candle", "", core.rgb(0, 255, 0) );
   indicator.parameters:addColor("iDown", "Inverse Down Candle", "", core.rgb(128, 128, 128)  );
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Additional;
 
local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local Price;
 
local HistoricSize;
local Down, Up;
local iDown, iUp;
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
	 
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;  
    HistoricSize=instance.parameters.HistoricSize;	
	Additional=instance.parameters.Additional;
	Down=instance.parameters.Down;
	Up=instance.parameters.Up;
	iDown=instance.parameters.iDown;
	iUp=instance.parameters.iUp;
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   	
    instance:ownerDrawn(true);
     
	Price = instance:createTextOutput ("Price", "Price", "Verdana", HistoricSize, core.H_Right, core.V_Top, Label, 1);
	 
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first,1)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first,1)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first,1)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first,1)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   


   	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	if source.close[period] > source.open[period] then
	open:setColor(period, Up);
	else
	open:setColor(period, Down);
	end
	
	
	 if period <source:size()-1 then
	 return;
	 end
	 
	
	iOpen=1/source.open[period];
	iClose=1/source.close[period];
    iHigh=1/source.high[period];
	iLow=1/source.low[period];
	
	

	Delta=source.open[period]-iOpen;
	
	if iClose > iClose then
	open:setColor(period+1, iUp); 
	else
	open:setColor(period+1, iDown); 
	end
	
   	high[period+1]= iHigh+Delta;
	low[period+1]= iLow+Delta;	   
	close[period+1] = iClose+Delta;
	open[period+1]  = iOpen+Delta;
	
	Text1=  win32.formatNumber(1/source.close[source.close:size()-1], false, source:getPrecision()+Additional);
	Price:set(period+1, math.max(high[period+1],low[period+1]),  Text1 ); 
	Price:setNoData(period );
   
	
	
 
    
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
	
			
	local Text1;
	
	 
	Text1=  "Inverse Price : "..win32.formatNumber(1/source.close[source.close:size()-1], false, source:getPrecision()+Additional);
 
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   

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
 