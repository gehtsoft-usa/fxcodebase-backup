-- Id: 20410
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65658

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Average Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");

	
	indicator.parameters:addString("Mode", "Method", "Method" , "Open/Close");
    indicator.parameters:addStringAlternative("Mode", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "Open/Close", "Open/Close" , "Open/Close");
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period", "Period", "Period" , 14);
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up  Color","Up Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Color","Down Color", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
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
   indicator.parameters:addInteger("Size", "Font Size", "", 8);
 
	

end

local X,Y;
local Label;
local Size;
local ShiftY;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Method;
local Mode;
-- Streams block
local Range = nil;
local Period;
local Signal;
local MA;
local Up,Down;
local Text={};
local Last=0;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
	
	
	Method=instance.parameters.Method;
	Mode=instance.parameters.Mode;
	Period=instance.parameters.Period;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	
	
 
    
  
	 
	
	 if source:barSize()~= "m1" then
	 error("Please select m1 as Chart Time ");
	 end
 
	
    local name = profile:id() .. "(" .. source:name() .. "," .. Mode.. ", " .. Method.. ", " .. Period.. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Range = instance:addStream("Range", core.Bar, name, "Range",Up, first);
		MA = core.indicators:create(Method, Range, Period);
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color, MA.DATA:first());
		Signal:setWidth(instance.parameters.width);
        Signal:setStyle(instance.parameters.style);
		
		Range:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		
		instance:ownerDrawn(true);
		core.host:execute ("setTimer", 1, 1);
    end
	
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
  local Count=0;
  local Table;
  local iX=0;
  local iY=0;
  
 if cookie== 1 then
 
         for i= source:size()-1 , first, -1 do
		         Table= core.dateToTable (source:date(i));
				 
				 if  Last~=Table.hour then
				 Last=Table.hour;
				 Count=Count+1;
				 iX=0;
				 iY=0;
				 end
				 
				 if Count== 11 then
				 break;
				 end
				  
				 
				 if Text[Count]==nil then
				 Text[Count]=0;				 
				 end
				 
				 iX=iX+1;
				 iY=iY+Range[i];
				 Text[Count]=iY/iX;
				 
				 
		 end
		 
		 
 
 end
 
 
 
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first
	or not source:hasData(period) then
	return;
	end
	
       local Min,Max=source.low[period], source.high[period];

	    if Mode == "High/Low" then
        Range[period] =( Max-Min)/source:pipSize();
		else
		Range[period] =math.abs( source.open[period]-source.close[period])/source:pipSize();
		end
		
		
	if source.close[period]> source.open[period] then
	Range:setColor(period, Up);
	else
	Range:setColor(period,  Down);
	end
		
	
	MA:update(mode);
	
	if period< 	MA.DATA:first() then
	return;
	end
    Signal[period]= MA.DATA[period];
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
	local Max=0; 
	local Min=0;
    for i= 1, 10, 1 do
		if Text[i]~= nil then
		Text1=  tostring(string.format("%." .. 2 .. "f", Text[i]) );
		width, height = context:measureText (1, Text1, context.RIGHT);
		context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), context.LEFT );	
		
		
		
		if X~= "Left" then
		Value=iX(context,width,0,1);
			if i== 1 then
			Min=Value;
			end
		Min=math.min(Value ,Min );		
		else
		Value=iX(context,width,0,2);
		Max=math.max(Value ,Max );
		end
		
		end
		
		
    end
	
	  for i= 1, 10, 1 do
	    Text1= i.. ". "
		
		
	    width, height = context:measureText (1, Text1, context.RIGHT);
		if X~= "Left" then		
		context:drawText (1,  Text1, Label, -1, Min-Size-width ,  iY(context,height,i,0) ,Min-Size,iY(context,height,i,1), context.LEFT );	
		else
		context:drawText (1,  Text1, Label, -1, Max+Size ,  iY(context,height,i,0) ,Max+Size+width,iY(context,height,i,1), context.LEFT );	
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

