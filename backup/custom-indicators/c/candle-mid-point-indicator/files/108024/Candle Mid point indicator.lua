
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63850

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
    indicator:name("Candle Mid point indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Selector" );
	
	indicator.parameters:addString("Method", "Method", "Method" , "Candle");
    indicator.parameters:addStringAlternative("Method", "Candle", "Candle" , "Candle");
    indicator.parameters:addStringAlternative("Method", "Body", "Body" , "Body");
	
	
	indicator.parameters:addString("Type", "Type", "Type" , "OC");
    indicator.parameters:addStringAlternative("Type", "(Open+Close)/2", "(Open+Close)/2" , "OC");
    indicator.parameters:addStringAlternative("Type", "(High+Low+Close)/3", "(High+Low+Close)/3" , "HLC");
    indicator.parameters:addStringAlternative("Type", "(Open+High+Low+Close)/3", "(Open+High+Low+Close)/3" , "OHLC");

    
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.COLOR_LABEL );
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
   
   
end
 
local Method;
local source;
local Type;

function Prepare(nameOnly)  
 
    source = instance.source;		 
	Method=instance.parameters.Method;	
    Color=instance.parameters.Color; 
    Type=instance.parameters.Type;	
	
	local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name ..   " : "  ..  Method..   ", "  ..  Type);
	
	
	if   (nameOnly) then
        return;
    end
	
	
   instance:ownerDrawn(true);
   


		
end




function Update(period, mode)
        
end

local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 

   
    
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then			
			 context:createPen (1, context:convertPenStyle (instance.parameters.style) , instance.parameters.width, Color);    		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    		
	
       
			   for period= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (period);
			   
			   
			   
			      if Type == "OC" then			 
						 if Method == "Candle" then
						 price=  (source.high[period]+source.low[period]) /2 ;
						 else
						 price=   (math.max(source.open[period],source.close[period]) +math.min(source.open[period],source.close[period]) ) /2 ;
						 end				 
				 elseif Type == "HLC" then
				         
						 price=  (source.high[period]+source.low[period]+ source.close[period]) /3 ;
						 
				 elseif Type == "OHLC" then
				 
				        price=  (source.high[period]+source.low[period]+ source.close[period]+ source.open[period]) /4 ;
				 end
				  
				  visible, y = context:pointOfPrice (price);
			      
				  context:drawLine (1, x1, y, x2, y);
	         end
	   
	
end

