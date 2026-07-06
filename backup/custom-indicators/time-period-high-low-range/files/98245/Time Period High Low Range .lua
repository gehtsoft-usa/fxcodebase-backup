-- Id: 13476
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61740

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
    indicator:name("Time Period High Low Range ");
    indicator:description("Time Period High Low Range ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    
	
	indicator.parameters:addDate ("From", "From", "From", 0)
	indicator.parameters:setFlag ("From", core.FLAG_DATETIME)
	
    indicator.parameters:addDate ("To", "To", "To", 0)
	indicator.parameters:setFlag ("To", core.FLAG_DATETIME)  
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("FromColor", "From Color", "From Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("ToColor", "To Color", "To Color", core.rgb(255, 0, 0));
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
local From,To;
local Color,Size; 
local source = nil;
local Period;
local X,Y;
local ToColor, FromColor;
-- Routine
function Prepare(nameOnly)
    From = instance.parameters.From;
	To = instance.parameters.To;
    Color= instance.parameters.Color;
	Size= instance.parameters.Size;
	ToColor= instance.parameters.ToColor;
	FromColor= instance.parameters.FromColor;
	X= instance.parameters.X;
	Y= instance.parameters.Y;
	
	if To< From and To ~= 0 then
	error("To should be greater than From");
	end
	
    source = instance.source; 

    local name = profile:id() .. "(" .. source:name()  .. ")";
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
    if stage ~= 0 then
	return;
	end
	
	if not init then
	context:createPen (1, context.SOLID, 5, FromColor);
	context:createPen (2, context.SOLID, 5, ToColor);	
	context:createFont (3, "Arial", Size, Size, 0);	 
	init = false;
	end
	

	local first, last;
	
	local p1= core.findDate (source, From, false);
	local p2= core.findDate (source, To, false);
	
    if p1~= -1 then
	first = math.max(source:first(),p1) ;
	else
	first =  context:firstBar ();
	end
	
	if p2~= -1 then
	last = math.min(source:size()-1, p2);
	else
	last = context:lastBar ();
	end
	
	x1, x , x = context:positionOfBar (p1);
	x2, x , x = context:positionOfBar (p2);
	
	context:drawLine (1, x1, context:top (), x1, context:bottom (), 0);
	context:drawLine (2, x2, context:top (), x2, context:bottom (), 0);
	 
	local min,max= mathex.minmax(source, first, last);
	Value=  " High/Low Range (Pips) : " .. string.format("%." .. 2 .. "f",  math.abs(max-min)/source:pipSize());
	
	visible, y1 = context:pointOfPrice (min);
	visible, y2 =  context:pointOfPrice (max);
	context:drawLine (1, context:left (), y1, context:right (), y1, 0);
	context:drawLine (2, context:left (), y2,  context:right (), y2, 0); 
		
		width, height = context:measureText (3, Value, 0);
		context:drawText (3, Value, Color, -1, iX(context,width,0,1) ,  iY(context,height,0,1) ,iX(context,width,0,2),iY(context,height,0,2), 0 )
		
		Value=  " High  : " .. string.format("%." .. source:getPrecision () .. "f",  max);
		width, height = context:measureText (3, Value, 0);
		context:drawText (3, Value, Color, -1, iX(context,width,0,1) ,  iY(context,height,1,1) ,iX(context,width,0,2),iY(context,height,1,2), 0 )
		
		Value=  " Low  : " .. string.format("%." .. source:getPrecision () .. "f",  min);
		width, height = context:measureText (3, Value, 0);
		context:drawText (3, Value, Color, -1, iX(context,width,0,1) ,  iY(context,height,2,1) ,iX(context,width,0,2),iY(context,height,2,2), 0 )
end






