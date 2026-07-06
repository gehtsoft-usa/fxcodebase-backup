-- Id: 25078
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68498

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Stop Signs");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
    indicator.parameters:addGroup("Calculation"); 	
	indicator.parameters:addBoolean("Historical", "Historical", "", false);
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL);
	
	indicator.parameters:addColor("Up", "Up Candle Line Color", "", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Candle Line Color", "", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local Label; 
local Level1;
local Level2;
local Historical;
-- Routine
 function Prepare(nameOnly)   
 
 
 
	Historical= instance.parameters.Historical;
	Label= instance.parameters.Label;
	
	local Parameters="";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first();
	
	Level1= instance:addInternalStream(0, 0);
	Level2= instance:addInternalStream(0, 0);
   
 
 
	
	instance:setLabelColor(Label);
   instance:ownerDrawn(true);
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()  
	then
	return;
	end
	
	
	
	if source.close[period]> source.open[period] then
	Level1[period]=(source.high[period] - 0.0001) +((source.high[period]-source.low[period]-0.0001) / 3) ;
	Level2[period]= (source.close[period] - 0.0001) + ((source.close[period]-source.low[period]-0.0001) / 3); 
	else
	Level1[period]=(source.close[period]+0.0001) - ((source.high[period]-source.low[period]-0.0001) / 3) ;
	Level2[period]=(source.high[period]+0.0001) - ((source.high[period]-source.close[period]-0.0001) / 3); 
	end
	
	 
	 
   --[[
   rewrite: blue candles I have to find only two levels of blue / green stop calculation H - 0.0001 + [(H - L - 0.0001) / 3] then C - 0.0001 + [(C-- L - 0.0001) / 3]


red candles I have to find only two red levels
calculation L + 0.0001 - [(H - L - 0.0001) / 3] then C + 0.001 - [(H - C - 0.0001) / 3]

   
   
   ]]
	 
				  
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
 
			
			context:createPen (1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Up)			
			context:createPen (2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down)       
	 

		  
            init = true;
        end
     
    local first, last;
   
        if Historical then
        first = math.max(source:first(), context:firstBar ());
        last = math.min (context:lastBar (), source:size()-1);
		else
		first= source:size()-1;
		last= source:size()-1;
		end
		
    
	   
			   for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
				   visible, y =context:pointOfPrice (Level1[i]);
				   if visible then				    
				   context:drawLine (1, x1, y, x2+(x2-x1), y);				    
				   end
				   visible, y = context:pointOfPrice (Level2[i]);
				   if visible then
				   context:drawLine (2, x1, y, x2+(x2-x1), y);
				   end
			   end
			   
	
end

 