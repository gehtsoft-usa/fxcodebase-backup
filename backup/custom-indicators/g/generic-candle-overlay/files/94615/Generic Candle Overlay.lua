-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60840
-- Id: 12044

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

function Init()
    indicator:name("Generic Candle  Overlay");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addInteger("Size", "Size", "", 100);
	indicator.parameters:addDouble("Scale", "Scale Down", "", 2, 1, 10)
	indicator.parameters:addColor("Up", "Up Candle Color","", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Candle Color","", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Color", "Label Color","", core.COLOR_LABEL);
    indicator.parameters:addColor("Range", "Range Color","", core.rgb(128, 128, 128));
		 
 end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	 
	local first;
	local source = nil;
	local TF;
	local host;
	local offset;
	local weekoffset; 
   local Scale;
    local o,h,l,c;
    local Size;
	local Up,Down;
	local Color;
	local Range;
-- Routine
function Prepare(nameOnly)
     
	Range = instance.parameters.Range;
	Color= instance.parameters.Color;
	Scale= instance.parameters.Scale;
	Size = instance.parameters.Size;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
    first = source:first();
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");  
	 
	first=source.close:first();
 
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(TF) .. ")";
    instance:name(name);
 
	instance:ownerDrawn(true);
      
end
local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	 s, e = core.getcandle(TF, source:date(source:size()-1),offset,weekoffset );	
	 local p1= core.findDate (source, s, false);	
	 local p2= core.findDate (source, e, false);
  
  
     if p1==-1
	 or p2== -1 
	 then
	 return;
	 end
	
	 
        if not init then
            context:createSolidBrush(1, Up );
            context:createPen (2, context.SOLID, Size/20, Up ) 			
			context:createSolidBrush(3, Down );
			 context:createPen (4, context.SOLID, Size/20, Down )			  
            context:createFont (5, "Arial", 10, 10, 0);

            context:createSolidBrush(7, Range );
            context:createPen (6, context.SOLID, 1, Range ) 	 			
            init = true;
        end
		


    local Open= source.open[p1] ;
    local Close= source.close[p2] ;
    local High=mathex.max(source.high, p1, p2);
    local Low=mathex.min(source.low, p1, p2);	
	local min,max=mathex.minmax(source, p1, p2);
    
	
	local pen,brush;
	local x2=context:right ()-Size;
	local x1=x2-Size;
	
	local Start = context:bottom ()+  ( (context:top ()-context:bottom ()) - ((context:top ()-context:bottom ()) /Scale ))/2;
	
	local y1 = Start + (((context:top ()-context:bottom ())/100)/Scale)* ((Open-Low)/((High-Low)/100));
	local y2 = Start + (((context:top ()-context:bottom ())/100)/Scale)* ((Close-Low)/((High-Low)/100));
	local y3 = Start + (((context:top ()-context:bottom ())/100)/Scale)* ((High-Low)/((High-Low)/100));
	local y4 = Start + (((context:top ()-context:bottom ())/100)/Scale)* ((Low-Low)/((High-Low)/100));
	
	local x3= x1+(x2-x1)/2;
	local x4= x1+(x2-x1)/2;
	
	if 	Close> Open then
	pen=2;
	brush=1;
	else
	pen=4;
	brush=3;
	end
	
	
	context:drawRectangle (pen, brush, x1, y1, x2, y2 );
	context:drawLine (pen, x3, y3, x4, y4 );
	
	px1, x , x  = context:positionOfBar (p1);
	px2, x , x  = context:positionOfBar (p2);
	
	visible, py1 = context:pointOfPrice (max)
	visible, py2 = context:pointOfPrice (min)
	context:drawRectangle (6, 7, px1, py1, px2, py2 ,128);
	
	
	
	x1= x1-200;
	
	
	Text= "Open : " ..  string.format("%." .. 2 .. "f",Open);	
	width, height =context:measureText (5, Text, 0);
	x2=x1+width;
	y1= y3+height;
	y2= y1+height;
	context:drawText (5, Text , Color, -1, x1, y1, x2, y2,context.LEFT);
	
	Text= "Close : " ..  string.format("%." .. 2 .. "f",Close);	
	width, height =context:measureText (5, Text, 0);
	x2=x1+width;
	y1= y1+height;
	y2= y1+height;
	context:drawText (5, Text , Color, -1, x1, y1, x2, y2,context.LEFT);
	
	Text= "High : " ..  string.format("%." .. 2 .. "f",math.max(High,Low));	
	width, height =context:measureText (5, Text, 0);
	x2=x1+width;
	y1= y1+height;
	y2= y1+height;
	context:drawText (5, Text , Color, -1, x1, y1, x2, y2,context.LEFT);
	
	Text= "Low : " ..  string.format("%." .. 2 .. "f",math.min(High,Low));	
	width, height = context:measureText (5, Text, 0);
	x2=x1+width;
	y1= y1+height;
	y2= y1+height;
	context:drawText (5, Text , Color, -1, x1, y1, x2, y2,context.LEFT);
	
	end


function Update(period )

	 
	   
end
