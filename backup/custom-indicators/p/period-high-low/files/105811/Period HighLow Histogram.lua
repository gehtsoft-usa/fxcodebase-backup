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
 
    indicator.parameters:addBoolean("On1" , "Show 1. Period", "", true);	
    indicator.parameters:addInteger("Period1", "1.Period", "", 5);
	indicator.parameters:addBoolean("On2" , "Show 2. Period", "", true);	
    indicator.parameters:addInteger("Period2", "2. Period", "", 15);
	indicator.parameters:addBoolean("On3" , "Show 3. Period", "", true);	
	indicator.parameters:addInteger("Period3", "3. Period", "", 45);
	indicator.parameters:addInteger("Cut_Off", "Cut Off Value", "Minimum value to be shown", 10);

    indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("Color1", "1. Extreme color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Color2", "2. Extreme color", "Color", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Color3", "2. Extreme color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Size", "Font Size", "Size", 10);
end

local first;
local Color1, Color2, Color3; 
local name;
local Period1,Period2,Period3;
local Size;
local Up,Down;
local On={};
local Cut_Off;
function Prepare(onlyName)
    source = instance.source;
    Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Cut_Off=instance.parameters.Cut_Off;
	On[1]=instance.parameters.On1;
	On[2]=instance.parameters.On2;
	On[3]=instance.parameters.On3;
    Size=instance.parameters.Size;
	
	first=source:first()+math.max(Period1, Period2, Period3);
    name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Period3 .. ")";
    instance:name(name);
	
	
    if onlyName then
        return ;
    end 
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	
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
            context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
			 context:createFont (2, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
 

 
      local First=math.max(first,context:firstBar ());
	  local Last=math.min(source:size()-1, context:lastBar ());
	  
	   for period = First, Last, 1 do
	   Up[period]=0;
	   Down[period]=0;
	   end
	   
       for period = First, Last, 1 do
		   if On[1]then
		   min1,max1, min1p, max1p = mathex.minmax(source, period-Period1+1, period);
		   Up[max1p]= Up[max1p] +1;
		   Down[min1p]= Down[min1p] +1;
		   end
		
		   if On[2]then
		   min2,max2, min2p, max2p = mathex.minmax(source, period-Period2+1, period);
		   Up[max2p]= Up[max2p] +1;
		   Down[min2p]= Down[min2p] +1;
		   end

		   if On[3]then	   
		   min3,max3, min3p, max3p = mathex.minmax(source, period-Period3+1, period);
		   Up[max3p]= Up[max3p] +1;
		   Down[min3p]= Down[min3p] +1;
		   end	   		
		end 
		
		for period = First, Last, 1 do
		
		if Down[period]> Cut_Off then
		x, x1, x2 = context:positionOfBar (period);
		visible, y = context:pointOfPrice (source.low[period]);
	    width, height = context:measureText (1,  Down[period] , context.CENTER  );  
		context:drawText (1,   Down[period], Color1, -1, x-width/2 , y , x+width/2  , y+height, context.CENTER   );
		end
		
		if Up[period]> Cut_Off then
		x, x1, x2 = context:positionOfBar (period);
		visible, y= context:pointOfPrice (source.high[period]);
		width, height = context:measureText (1, Up[period] , context.CENTER  );  
		context:drawText (1,  Up[period], Color1, -1, x-width/2 , y-height, x+width/2  , y, context.CENTER   );	
		end
		
		end
		
	   Last=source:size()-1;
	   local min1,max1, min1p, max1p = mathex.minmax(source, Last-Period1+1, Last);
	   local min2,max2, min2p, max2p = mathex.minmax(source, Last-Period2+1, Last);
	   local min3,max3, min3p, max3p = mathex.minmax(source, Last-Period3+1, Last);
	   
	   
	    x, x1, x2 = context:positionOfBar (min1p);
		visible, y = context:pointOfPrice (min1)
	    width, height = context:measureText (2, "\233" , context.CENTER  );  
		context:drawText (2,  "\233", Color1, -1, x-width/2 , y+height , x+width/2  , y+height*2, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max1p);
		visible, y= context:pointOfPrice (max1)
		context:drawText (2,  "\234", Color1, -1, x-width/2 , y-height*2, x+width/2  , y-height, context.CENTER   );	
	   
	  
	  
	     x, x1, x2 = context:positionOfBar (min2p);
		visible, y = context:pointOfPrice (min2)
	    width, height = context:measureText (2, "\233" , context.CENTER  );  
		context:drawText (2,  "\233", Color2, -1, x-width/2 , y+height*3 , x+width/2  , y+height*3, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max2p);
		visible, y= context:pointOfPrice (max2)
		context:drawText (2,  "\234", Color2, -1, x-width/2 , y-height*3, x+width/2  , y-height*2, context.CENTER   );	
		
		
		
		 x, x1, x2 = context:positionOfBar (min3p);
		visible, y = context:pointOfPrice (min3)
	    width, height = context:measureText (2, "\233" , context.CENTER  );  
		context:drawText (2,  "\233", Color3, -1, x-width/2 , y+height*3 , x+width/2  , y+height*4, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max3p);
		visible, y= context:pointOfPrice (max3)
		context:drawText (2,  "\234", Color3, -1, x-width/2 , y-height*4, x+width/2  , y-height*3, context.CENTER   );	
end

		

function Update(period, mode)
 
end

