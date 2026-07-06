
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9374

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


function Init()
    indicator:name("Average Daily Range Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

   indicator.parameters:addGroup("Calculation");
   indicator.parameters:addInteger("P1", 1 .. ". Period", "", 1);
   indicator.parameters:addInteger("P2", 2 .. ". Period", "", 5);
	indicator.parameters:addInteger("P3", 3 .. ". Period", "", 10);
	indicator.parameters:addInteger("P4", 4 .. ". Period", "", 20);
	indicator.parameters:addBoolean("Shift", "Exclude Active Candle", "", false);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 

	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local Label;
local Size;
local Average={};
local Range; 
local Period={};
local FIRST;
local Shift;
-- Routine
function Prepare(nameOnly)
    Placement=instance.parameters.Positioning; 
    X=instance.parameters.X; 
    Y=instance.parameters.Y;	
	Shift=instance.parameters.Shift;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
   first=source:first();
	

	 
	 Period[1] = instance.parameters.P1;
	 Period[2] = instance.parameters.P2;
	 Period[3] = instance.parameters.P3;
	 Period[4] = instance.parameters.P4;
	 
	 Range=instance:addInternalStream (0, 0);
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   	
    FIRST= first + math.max( Period[1],  Period[2],  Period[3],  Period[4])+1;
	
	instance:ownerDrawn(true);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)   


if period < first then 
return;
end

if Shift then
Range[period] =source.high[period-1] -source.low[period-1];
else
Range[period] =source.high[period] -source.low[period];
end

if period < FIRST and period <  source:size()-1 -  (FIRST - first) then
return;
end

Average[1] = mathex.avg (Range, period-  Period[1]+1 , period) / source:pipSize();
Average[2] = mathex.avg (Range, period-  Period[2]+1 , period) / source:pipSize();
Average[3] = mathex.avg (Range, period-  Period[3]+1 , period) / source:pipSize();
Average[4] = mathex.avg (Range, period-  Period[4]+1 , period) / source:pipSize();
Average[5] = (Average[1] +Average[2] + Average[3] + Average[4])/4 ;


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
	return context:bottom()-Shift* height - height*(x-1) ;
	end
end



local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		local Text;
		
		for i= 1, 5, 1 do
		
		    if Average[i]~=nil then
				if i~= 5 then
				Text=  "Period (" .. Period[i]..") : " .. string.format("%." .. 2 .. "f",  Average[i]);
				else
				Text=  "Average : " .. string.format("%." .. 2 .. "f",  Average[i]);
				end
				
				   width, height = context:measureText (1, Text, 0);
				   if Y== "Top" then
				   context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1,i) ,iX(context,width,0,2),iY(context,height,1,i+1), 0 );
				   else
				   context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1,i+1) ,iX(context,width,0,2),iY(context,height,1,i), 0 );
				   end		
			end 			   
   
		end 

 end


