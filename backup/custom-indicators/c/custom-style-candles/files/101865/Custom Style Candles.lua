-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62551


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
    indicator:name("Custom Style Candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");

   
   indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE );
   indicator.parameters:addColor("Down", "Down Color", "",core.COLOR_DOWNCANDLE );
   indicator.parameters:addColor("background", "Background Color", "", core.COLOR_BACKGROUND );
   indicator.parameters:addDouble("transparency", "Transparency", "",0 , 0, 100);
  
   indicator.parameters:addInteger("Size", "Candle Size", "", 90, 0, 100);
   indicator.parameters:addInteger("LineWidth", "Line Width", "", 3, 1, 5);
   
   indicator.parameters:addBoolean("Hollow", "Hollow Candle","", false);
end
 
local open, high, low, close, volume;
local source,first;
local transparency;
local Up, Down;
local Size;
local LineWidth;
local Hollow;
local background;
-- initializes the instance of the indicator
function Prepare(nameOnly) 
   
    source = instance.source;
    first=source:first();   
	
	Hollow = instance.parameters.Hollow;
	
	 Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Size = instance.parameters.Size;
	LineWidth = instance.parameters.LineWidth;
	background = instance.parameters.background;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end	

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open",0,  source:first());
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0,source:first());
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low",0, source:first());
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close",0, source:first());
	
	open:setStyle (core.LINE_NONE);
    high:setStyle (core.LINE_NONE);
    low:setStyle (core.LINE_NONE);
    close:setStyle (core.LINE_NONE);	
	instance:ownerDrawn(true);
   
end

function Update(period)


        open[period] = source.open[period];  
		low[period] = source.low[period]; 
		close[period]=source.close[period]; 
		high[period] = source.high[period]; 
				
end


local Initialized= false;

function Draw (stage, context)

 
   
 if stage ~= 2 then
 return;
 end
 
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    local First, Last = context:firstBar(), context:lastBar();
 
           if not Initialized then
		   
            context:createPen(1, context.SOLID, context:pointsToPixels (LineWidth), Up);
			context:createPen(11, context.SOLID, context:pointsToPixels (LineWidth), Up);
			context:createSolidBrush(2, Up );
			
			
			context:createSolidBrush(5, background );
			
			
			context:createPen(3, context.SOLID, context:pointsToPixels (LineWidth), Down );
			context:createPen(13, context.SOLID, context:pointsToPixels (LineWidth), Down );
			context:createSolidBrush(4, Down );
			transparency = context:convertTransparency(instance.parameters.transparency);
			 
            Initialized = true;           
           end
    
	local width;
	for i=  math.max(First, source:first()), math.min(Last, source:size()-1), 1 do
	visible, y1=  context:pointOfPrice (open[i]);
    visible, y2=  context:pointOfPrice (close[i]);
	visible, y3=  context:pointOfPrice (low[i]);
    visible, y4=  context:pointOfPrice (high[i]);
	
	x , x1, x2 = context:positionOfBar (i);
	
	width = (((x2-x1)/100)/2)*Size;
	x3=x-width;
	x4=x+width;
	
    	if y1 > y2 then
			if Hollow then
			context:drawRectangle(11, 5, x3, y1+1, x4,  y2-1 , transparency);
			else
			context:drawRectangle(11, 2, x3, y1+1, x4,  y2-1 , transparency);
			end
		
		context:drawLine (1, x, y1, x, y3);
		context:drawLine (1, x, y4, x, y2);
		else
			if Hollow then
			context:drawRectangle(13,5, x3, y1-1, x4,  y2+1 , transparency);
			else
			context:drawRectangle(13, 4, x3, y1-1, x4,  y2+1 , transparency);
			end
		context:drawLine (3, x, y4, x, y1);
		context:drawLine (3, x, y2, x, y3);
		end
	
	end
	
	
 end