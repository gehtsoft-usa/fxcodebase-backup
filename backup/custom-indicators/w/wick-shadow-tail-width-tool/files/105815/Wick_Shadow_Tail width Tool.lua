
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63384

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
    indicator:name("Wick_Shadow_Tail width Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 
    indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("Up", "Up Candle Color", "Color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Down", "Down Candle Color", "Color", core.COLOR_DOWNCANDLE );
 
    indicator.parameters:addInteger("Width", "Wick Width as % of Candle", "Width", 25);
end

 
local Up,Down; 
local name; 
local Width;
function Prepare(onlyName)
    source = instance.source;
    Width=instance.parameters.Width; 
	 
    name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
    if onlyName then
        return ;
    end 
	
    Up = instance.parameters.Up;
    Down = instance.parameters.Down;
   
    instance:ownerDrawn(true);

end


function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
       
            			
     
 
       local Last=source:size()-1;
	   
      
	   
	  local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
 
	        X0, X1, X2 = context:positionOfBar (source:size()-1); 
			LineWidth= ((X2-X1)/100)*Width;
	        context:createPen (1, context.SOLID, LineWidth, Up);
            context:createPen (2, context.SOLID, LineWidth, Down);  
       
			    for period= first, last, 1 do	 
				
				  X0, X1, X2 = context:positionOfBar (period); 
				  visible1, High = context:pointOfPrice (source.high[period]);
				  visible2, Low = context:pointOfPrice (source.low[period]);
				  visible3, Close = context:pointOfPrice (source.close[period]);
				  visible4, Open = context:pointOfPrice (source.open[period]);
				  
				  if source.close[period]> source.open[period] then
				  context:drawLine (1, X0, High, X0, math.min(Open,Close));
				  context:drawLine (1, X0, math.max(Open,Close), X0, Low);
				  else
				  context:drawLine (2, X0, High, X0, math.min(Open,Close));
				  context:drawLine (2, X0, math.max(Open,Close), X0, Low);
				  end
				  
				end
		
	 
		
	    
end

		

function Update(period, mode)
    
end

