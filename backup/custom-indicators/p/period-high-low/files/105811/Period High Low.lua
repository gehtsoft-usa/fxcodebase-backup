-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63382

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
    indicator:name("Period High & Low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
 

    indicator.parameters:addInteger("Period1", "1.Period", "", 5);
    indicator.parameters:addInteger("Period2", "2. Period", "", 15);
	indicator.parameters:addInteger("Period3", "3. Period", "", 45);

    indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("Color1", "1. Extreme color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Color2", "2. Extreme color", "Color", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Color3", "2. Extreme color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Size", "Font Size", "Size", 15);
end

local first;
local Color1, Color2, Color3; 
local name;
local Period1,Period2,Period3;
local Size;
function Prepare(onlyName)
    source = instance.source;
    Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
    Size=instance.parameters.Size;
	
	first=source:first()+math.max(Period1, Period2, Period3);
    name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Period3 .. ")";
    instance:name(name);
	
    if onlyName then
        return ;
    end 
	
    Color1 = instance.parameters.Color1;
    Color2 = instance.parameters.Color2;
	Color3 = instance.parameters.Color3;
   
    instance:ownerDrawn(true);

end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
 
       local Last=source:size()-1;
	   
       local min1,max1, min1p, max1p = mathex.minmax(source, Last-Period1+1, Last);
	   local min2,max2, min2p, max2p = mathex.minmax(source, Last-Period2+1, Last);
	   local min3,max3, min3p, max3p = mathex.minmax(source, Last-Period3+1, Last);
	   
	   
	    x, x1, x2 = context:positionOfBar (min1p);
		visible, y = context:pointOfPrice (min1)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color1, -1, x-width/2 , y , x+width/2  , y+height, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max1p);
		visible, y= context:pointOfPrice (max1)
		context:drawText (1,  "\234", Color1, -1, x-width/2 , y-height, x+width/2  , y, context.CENTER   );	
	   
	  
	  
	     x, x1, x2 = context:positionOfBar (min2p);
		visible, y = context:pointOfPrice (min2)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color2, -1, x-width/2 , y+height , x+width/2  , y+height*2, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max2p);
		visible, y= context:pointOfPrice (max2)
		context:drawText (1,  "\234", Color2, -1, x-width/2 , y-height*2, x+width/2  , y-height, context.CENTER   );	
		
		
		
		 x, x1, x2 = context:positionOfBar (min3p);
		visible, y = context:pointOfPrice (min3)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color3, -1, x-width/2 , y+height*2 , x+width/2  , y+height*3, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max3p);
		visible, y= context:pointOfPrice (max3)
		context:drawText (1,  "\234", Color3, -1, x-width/2 , y-height*3, x+width/2  , y-height*2, context.CENTER   );	
end

		

function Update(period, mode)
    
end

