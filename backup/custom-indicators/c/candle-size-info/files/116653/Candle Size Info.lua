-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65488

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Candle Size Info");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
  indicator.parameters:addGroup("Selector");
  
  local Select={ "Last candle body", "Last upper wick", "Last lower wick", "Last candle",
              "Bull body candle average", "Bull upper wick candle average",  "Bull lower wick candle average", "Bull candles average",
               "Bear body candle average","Bear upper wick candle average","Bear lower wick candle average", "Bear candles average",
			    "Body Average size", "Upper wick Average size", "Lower wick Average size", "Candle Average size"}

	for i= 1, 16, 1 do
	indicator.parameters:addBoolean("On".. i , "Show ".. Select[i], "",true);	
	end
	
	 indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "Period", "", 14);
	 indicator.parameters:addBoolean("Shift", "Exclude current candle", "",true);
	
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
   indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
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
local On={};
local Value;
local Count=0;
local Period;
local Shift;

local OldLabelText={ "Last candle body", "Last upper wick", "Last lower wick", "Last candle",
              "Bull body candle average", "Bull upper wick candle average",  "Bull lower wick candle average", "Bull candles average",
               "Bear body candle average","Bear upper wick candle average","Bear lower wick candle average", "Bear candles average",
			    "Body Average size", "Upper wick Average size", "Lower wick Average size", "Candle Average size"}
local Body, Upper, Lower, Candle;
local LabelText;
local ValueText;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
	Period=instance.parameters.Period;
	Shift=instance.parameters.Shift;
    source = instance.source;
    first=source:first()+Period;
	
	for i= 1, 16, 1 do
	On[i]= instance.parameters:getBoolean("On" .. i);
	end
	
	Body = instance:addInternalStream(0, 0);
	Upper = instance:addInternalStream(0, 0);
	Lower = instance:addInternalStream(0, 0);
	Candle = instance:addInternalStream(0, 0);
	 
   	
    instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);
	
	Count=0;
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Average(period, Data, Side)

local iSum=0;
local iCount=0;

for i= period, period-Period+1, -1 do

	if Side==0 then
	iSum=iSum+Data[i];	
	iCount=iCount+1;
	end
	
	if Side==1 and  source.close[i]>   source.open[i] then
	iSum=iSum+Data[i];	
	iCount=iCount+1;
	end
	
	if Side==-1 and  source.close[i]<   source.open[i] then
	iSum=iSum+Data[i];	
	iCount=iCount+1;
	end

end
local Return=iSum / iCount;

return Return;

end

function AsyncOperationFinished(cookie)


if cookie~=1 then
 return core.ASYNC_REDRAW ;
end


Count=0;
LabelText={};
ValueText={};
local Last= source:size()-1;

if Shift then
Last=Last-1;
end
 

				--"Last candle body"
				if On[1] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[1];
				ValueText[Count]=Body[Last];
				end

				-- "Last upper wick"
				if On[2] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[2];
				ValueText[Count]=Upper[Last];
				end

				-- "Last lower wick"
				if On[3] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[3];
				ValueText[Count]=Lower[Last];
				end
				-- "Last candle",

				if On[4] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[4];
				ValueText[Count]=Candle[Last];
				end

				----------------------------------
				-- Average(period, Data, Side)
				 ----------------------------------
				
				
				--"Bull body candle average"
				if On[5] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[5];
				ValueText[Count]= Average(Last, Body, 1);
				end

				-- "Bull upper wick candle average"
				if On[6] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[6]; 
				ValueText[Count]= Average(Last, Upper, 1);
				end
				--  "Bull lower wick candle average"
				if On[7] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[7];
				ValueText[Count]= Average(Last, Lower, 1);
				end
				-- "Bull candles average",
				if On[8] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[8];
				ValueText[Count]= Average(Last, Candle, 1);
				end
				-- "Bear body candle average"
				if On[9] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[9];
				ValueText[Count]= Average(Last, Body, -1);
				end
				--"Bear upper wick candle average"
				if On[10] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[10];
				ValueText[Count]= Average(Last, Upper, -1);
				end
				--"Bear lower wick candle average"
				if On[11] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[11];
				ValueText[Count]= Average(Last, Lower, -1);
				end
				-- "Bear candles average",
				if On[12] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[12];
				ValueText[Count]= Average(Last, Candle, -1);
				end
				--"Body Average size"
				if On[13] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[13];
				ValueText[Count]= Average(Last, Body, 0);
				end
				--"Upper wick Average size"
				if On[14] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[14];
				ValueText[Count]= Average(Last, Upper, 0);
				end
				-- "Lower wick Average size"
				if On[15] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[15];
				ValueText[Count]= Average(Last, Lower, 0);
				end
				-- "Candle Average size"
				if On[16] then
				Count=Count+1;
				LabelText[Count]=OldLabelText[16];
				ValueText[Count]= Average(Last, Candle, 0);
				end
								
 

 return core.ASYNC_REDRAW ;
 
 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

 
function Update(period)   

    Body[period]= math.abs(source.open[period]-source.close[period])/source:pipSize();
	Upper[period]= math.abs(source.high[period]-math.max( source.open[period],source.close[period]))/source:pipSize();
	Lower[period]= math.abs(math.min(source.open[period],source.close[period])-source.low[period])/source:pipSize();
	Candle[period]= (source.high[period]-source.low[period])/source:pipSize();

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2
	  or Count==0 
	  then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
			
	
	 
   for i= 1, Count, 1 do
   
   if  ValueText[i]~= "" and  ValueText[i]~= nil then
   
   local Text1= LabelText[i] .. " : " .. win32.formatNumber( ValueText[i], false, 1);   
   
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end
   
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
 