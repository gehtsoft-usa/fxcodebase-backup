-- Id: 17264
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64244

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
    indicator:name("Moving Average Shadow");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Caclulation");

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 
	indicator.parameters:addInteger("Period", "Period","", 34);
	
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transparency", "Transparency","", 25);
 

 
   
   
end 


local Up, Down;
local High, Low, Close,Open;
local Method, Period;
local first;
local transparency;
local MA;
function Prepare(nameOnly)
 
    source = instance.source;	
	
	
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
   Method=instance.parameters.Method;
   Period=instance.parameters.Period;
   transparency=instance.parameters.transparency;
   
   
   local name = profile:id() .. " " .. source:name()  .. " : " .. Method .. " : " .. Period;
   instance:name(name );
    if nameOnly then
        return;
    end
   
   instance:setLabelColor(core.COLOR_LABEL );
   instance:ownerDrawn(true);
   

	
 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	High = core.indicators:create(Method, source.high ,  Period);
	Low = core.indicators:create(Method, source.low ,  Period);
	Open = core.indicators:create(Method, source.open ,  Period);
	Close = core.indicators:create(Method, source.close ,  Period);
	first=Close.DATA:first();
	
	MA = instance:addStream("MA", core.Line, name, "MA", 0, first);
    MA:setVisible(false);
 
 

		
end



function Update(period, mode)

    High:update(mode);
	Low:update(mode);
	Close:update(mode);
	Open:update(mode);
	MA[period]=Close.DATA[period];
	
end
 

function Draw (stage, context)

    if stage  ~= 1 then
	return;
	end
	  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
      
			transparency=context:convertTransparency (instance.parameters.transparency);
	 
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
       
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			          visible, high= context:pointOfPrice (High.DATA[period]);
					  visible, low= context:pointOfPrice (Low.DATA[period]);
			          visible, open= context:pointOfPrice (Open.DATA[period]);
					   visible, close= context:pointOfPrice (Close.DATA[period]);
					  
				 
						context:drawGradientTriangle (x0, open, Up, x2, high, Up, x2, close, Up, transparency);
						context:drawGradientTriangle (x0, open, Down, x2, close, Down, x2, low, Down, transparency);
						
 
				 
			end					
				 
				
	
end

