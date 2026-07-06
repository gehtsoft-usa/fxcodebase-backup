-- Id: 18872
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62783


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
    indicator:name("Close within HighLow Range Histogram");
    indicator:description("Close within HighLow Range Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
     
	indicator.parameters:addDouble("TL", "Up Limit", "", 60);
	indicator.parameters:addDouble("BL", "Down Limit", "", 40);
	indicator.parameters:addBoolean("ShowReversePattern", "Show reverse pattern", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Direct pattern color", "Bar Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Reverse pattern color", "Bar Color", core.rgb(255, 0, 0));
     indicator.parameters:addColor("color3", "Neutral color", "Bar Color", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Range;
local TL,BL;
local ShowReversePattern;
function Prepare(nameOnly)
    source = instance.source; 
   
	TL=instance.parameters.TL;
	BL=instance.parameters.BL; 
	ShowReversePattern=instance.parameters.ShowReversePattern;
	
    first = source:first();
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Range = instance:addStream("Range", core.Bar, name, "Range", instance.parameters.color3, first);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
	Range:addLevel(TL);  
	Range:addLevel(BL);  
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
   
	local HighLowRange= (source.high[period]-source.low[period])/100;
   
     Range[period]= ( source.close[period]-source.low[period])/(HighLowRange);
	 
     if source.close[period]> (source.low[period]+ HighLowRange*TL) then
	 
	 if ShowReversePattern then
	 Range:setColor(period,  instance.parameters.color2);
	 else
	 Range:setColor(period,  instance.parameters.color1);
	 end
	
     elseif source.close[period]< (source.low[period]+ HighLowRange*BL) then
	 
	  if ShowReversePattern then
	  Range:setColor(period,  instance.parameters.color1);
	  else
	  Range:setColor(period,  instance.parameters.color2);
	  end
	  
	 else 
	 Range:setColor(period,  instance.parameters.color3);  
	 end
end

