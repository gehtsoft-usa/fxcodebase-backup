-- Id: 20986
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65937

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Candle Spread Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up,Down; 
local first;
local source = nil;
 
local Oscillator;  
local bid,ask;


-- Routine
 function Prepare(nameOnly)   
 
 
     source = instance.source;
	 first=source:first();
		
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 if source:isBid() then
     bid = source;
     ask = core.host:execute("getAskPrice");
     else
     ask = source;
     bid = core.host:execute("getBidPrice");
    end

    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
			

     
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Up, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
 
	
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	
    if period < first then
	return;
	end 
	
	 local Spread=math.abs(ask.close[period]-bid.close[period])/source:pipSize();
	
	if source.close[period]> source.open[period] then
	Oscillator[period]=(source.close[period]-source.low[period])/source:pipSize() +Spread;
	else
	Oscillator[period]=(source.high[period]-source.open[period])/source:pipSize() +Spread ;
	end
	
	
end

