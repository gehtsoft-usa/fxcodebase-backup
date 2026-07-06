-- Id: 13464

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61733

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
    indicator:name("High-Low Pip Range");
    indicator:description("High-Low Pip Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Type", "Type", "Type", "Chart Area");
	indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart Area");
	indicator.parameters:addStringAlternative("Type", "All Data", "All Data" , "All Data");
    indicator.parameters:addStringAlternative("Type", "Last N Period", "Period" , "Last N Period");
	
	indicator.parameters:addInteger("Period", "Period N", "Period", 100);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "Label Size", 15);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type;
local Color,Size; 
local source = nil;
local Period;
local X,Y;
-- Routine
function Prepare(nameOnly)
    Type = instance.parameters.Type;
    Color= instance.parameters.Color;
	Size= instance.parameters.Size;
	Period= instance.parameters.Period;
	X= instance.parameters.X;
	Y= instance.parameters.Y;
	
    source = instance.source; 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
         instance:ownerDrawn(true);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
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
		return context:top()+Shift* height + height*(x-1)+height ;
	else
	return context:bottom()-(Shift+2)* height + height*(x-1) ;
	end
end

 
local init = false;

function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	

	local first, last;
	
	if Type == "Chart Area" then
	first = context:firstBar ();
	last= context:lastBar ();
	elseif Type == "All Data" then
	first = source:first();
	last= source:size()-1;
	elseif Type == "Last N Period" then		
	first =  source:size()-1-Period+1;
	last= source:size()-1;
	end
	
	local min,max= mathex.minmax(source, first, last);
	local Value= Type ..  " High / Low Range : " .. string.format("%." .. 2 .. "f",  math.abs(max-min)/source:pipSize());
	
	
        if not init then
            context:createFont (1, "Arial", Size, Size, 0);
            init = true;
        end
		
		width, height = context:measureText (1, Value, 0);
		context:drawText (1, Value, Color, -1, iX(context,width,0,1) ,  iY(context,height,0,1) ,iX(context,width,0,2),iY(context,height,0,2), 0 )
end






