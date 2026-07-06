
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59954

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
    indicator:name("Heikin-Ashi");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	    indicator.parameters:addGroup("Calculation");

	indicator.parameters:addInteger("Transparency", "Transparency", "", 90);
	    indicator.parameters:addGroup("Style");

   indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("OC", "Open Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("CC", "Close Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("HC", "High Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("LC", "Low Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("Mode", "Mode", "" , 1);
    indicator.parameters:addIntegerAlternative("Mode", "Line", "" , 0);
    indicator.parameters:addIntegerAlternative("Mode", "Bar", "" , 1);
	
		indicator.parameters:addInteger("Method", "Layer", "" , 1);
    indicator.parameters:addIntegerAlternative("Method", "1", "1" , 0);
    indicator.parameters:addIntegerAlternative("Method", "2", "2" , 1);
 indicator.parameters:addIntegerAlternative("Method", "3", "3" , 2);
  
end

local source = nil;
 local open = nil;
local high = nil;
local low = nil;
local close=nil;
local Up, Down;
local first = 0;
local Transparency;
local Method;
local Mode;
local HC, LC, OC, CC;
-- Routine
function Prepare(nameOnly) 
    HC=instance.parameters.HC;
	LC=instance.parameters.LC;
	OC=instance.parameters.OC;
	CC=instance.parameters.CC;
    source = instance.source;
	Transparency=instance.parameters.Transparency;
	Mode=instance.parameters.Mode;
	Method=instance.parameters.Method;
	
	Up = instance.parameters.Up;    
	Down = instance.parameters.Down;
	
	
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    
    open = instance:addStream("open", core.Line, name .. ".open", "open", OC, first)	
    high = instance:addStream("high", core.Line, name .. ".high", "high", HC , first)	
    low = instance:addStream("low", core.Line, name .. ".low", "low", LC, first)	
    close = instance:addStream("close", core.Line, name .. ".close", "close", CC, first)
	
	
	if  Mode== 1	 then
	   open:setStyle (core.LINE_NONE);
	   high:setStyle (core.LINE_NONE);
	   low:setStyle (core.LINE_NONE);
	   close:setStyle (core.LINE_NONE);
	end
	
	
	 instance:ownerDrawn(true);
    
    
    instance:setLabelColor(Up);
end

-- Indicator calculation routine
function Update(period, mode)
    if period < first then
	return;
	end
        if (period == first) then
            open[period] = (source.open[period - 1] + source.close[period - 1]) / 2;
        else
            open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        close[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
        high[period] = math.max(open[period], close[period], source.high[period]);
        low[period] = math.min(open[period], close[period], source.low[period]);
		
		
	 
    
end

local init = false;

function Draw(stage, context)

    if stage ~= Method or Mode== 0 then
	return;
	end
	
        if not init then             
            context:createPen(1, context.SOLID, 2, Up);   
             context:createPen(2, context.SOLID, 2, Down);     			
             context:createSolidBrush(3, Up);
			 context:createSolidBrush(4, Down);
            init = true;
        end
		

		local O,H,L,C;		 
		local i;
		local First = math.max(context:firstBar (), source:first());
		local Last = math.min(context:lastBar (),  source:size()-1);
		
		local x1,x2,x3;
		
		for i=First, Last , 1 do
		
		x1, x2, x3  =context:positionOfBar (i);
		Size=((x3-x2)/2)*0.8;
		   
		     visible,O = context:pointOfPrice (open[i]);
			 visible,C = context:pointOfPrice (close[i]);
			 visible,H = context:pointOfPrice (high[i]);
			 visible,L = context:pointOfPrice (low[i]);
			 
			 
				if open[i]< close[i] then 
			 
			context:drawRectangle(1, 3, x1-Size, O, x1+Size, C, Transparency); 			 
			context:drawLine(1, x1,H, x1, math.min(O,C)); 
			context:drawLine(1, x1,math.max(O,C), x1, L);
			else
			context:drawRectangle(2, 4, x1-Size, O, x1+Size, C, Transparency); 				
			context:drawLine(2, x1,H, x1, math.min(O,C)); 
			context:drawLine(2, x1,math.max(O,C), x1, L);
			end
			
 end
		
        
  end         
 









