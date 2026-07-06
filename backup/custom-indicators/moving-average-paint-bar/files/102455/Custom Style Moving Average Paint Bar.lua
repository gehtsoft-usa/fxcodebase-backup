-- Id: 19006
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62685&p=102455#p102455


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
    indicator:name("Custom Style Moving Average Paint Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");
	
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price1", "Fast MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("Fast", "Fast Average Period", "", 34);
	indicator.parameters:addString("Method1", "Fast MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addString("Price2", "Slow MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Slow", "Slow Average Period", "", 200);
	indicator.parameters:addString("Method2", "Slow MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

   indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE );
   indicator.parameters:addColor("Down", "Down Color", "",core.COLOR_DOWNCANDLE );
   indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(0,0,0));
   indicator.parameters:addColor("background", "Background Color", "", core.COLOR_BACKGROUND );
   indicator.parameters:addDouble("transparency", "Transparency", "",0 , 0, 100);
  
   indicator.parameters:addInteger("Size", "Candle Size", "", 70, 0, 100);
   indicator.parameters:addInteger("LineWidth", "Line Width", "", 3, 1, 5);
   
   indicator.parameters:addBoolean("HollowUp", "Hollow Up Candle","", false);
   indicator.parameters:addBoolean("HollowDown", "Hollow Down Candle","", false);
 
end
 
local open, high, low, close, volume;
local source,first;
local transparency;
local Up, Down,Neutral;
local Size;
local LineWidth;
local HollowUp, HollowDown ;
local background;

local Fast,Slow, fast,slow, Method1,Method2,Price1,Price2;
-- initializes the instance of the indicator
function Prepare(nameOnly)   
   
    source = instance.source;
    first=source:first();   
	
	  Fast = instance.parameters.Fast;
    Slow= instance.parameters.Slow;
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;
	
	HollowUp= instance.parameters.HollowUp;
	HollowDown= instance.parameters.HollowDown;
	 
	
	 Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	Size = instance.parameters.Size;
	LineWidth = instance.parameters.LineWidth;
	background = instance.parameters.background;
	
	local name = profile:id() .. "(" .. source:name() .. ", "  .. Fast .. ", " .. Slow .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
     fast = core.indicators:create(Method1, source[Price1], Fast);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    slow = core.indicators:create(Method2, source[Price2], Slow);
    first = math.max( fast.DATA:first(), slow.DATA:first());	

    

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


          fast:update(mode);
	slow:update(mode);

	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
  
	
	local Price=source.close[period];
	local FastAvg=fast.DATA[period];
	local SlowAvg=slow.DATA[period];
				
	if Price > FastAvg and Price < SlowAvg then
	open:setColor(period, Neutral); 
	elseif Price < FastAvg and Price > SlowAvg then
	open:setColor(period, Neutral); 
	elseif FastAvg > SlowAvg and Price > FastAvg then 
	open:setColor(period, Up); 
	elseif FastAvg > SlowAvg and Price < SlowAvg then 
	open:setColor(period, Down); 
	elseif FastAvg < SlowAvg and Price < FastAvg then
	open:setColor(period, Down); 
	elseif FastAvg < SlowAvg and Price > FastAvg then
	open:setColor(period, Up); 
	end	
		
				
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
			if HollowUp then
			context:drawRectangle(11, 5, x3, y1+1, x4,  y2-1 , transparency);
			else
			context:drawRectangle(11, 2, x3, y1+1, x4,  y2-1 , transparency);
			end
		
		context:drawLine (1, x, y1, x, y3);
		context:drawLine (1, x, y4, x, y2);
		else
			if HollowDown then
			context:drawRectangle(13,5, x3, y1-1, x4,  y2+1 , transparency);
			else
			context:drawRectangle(13, 4, x3, y1-1, x4,  y2+1 , transparency);
			end
		context:drawLine (3, x, y4, x, y1);
		context:drawLine (3, x, y2, x, y3);
		end
	
	end
	
	
 end