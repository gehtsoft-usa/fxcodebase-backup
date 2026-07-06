-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64544
-- Id: 17862

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Intraday Intensity Open Form");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local Period;
local IntradayIntensity;
 
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;
 
    name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
     
   IntradayIntensity = instance:addStream("IntradayIntensity", core.Line, name, "IntradayIntensity", instance.parameters.color,  source:first());   
    IntradayIntensity:setPrecision(math.max(2, instance.source:getPrecision()));
   IntradayIntensity:setWidth(instance.parameters.width);
   IntradayIntensity:setStyle(instance.parameters.style);
	
 
end

function Update(period, mode)
 
   if (source.high[period]-source.low[period])~= 0 then
    Add=(2*source.close[period]-source.high[period]-source.low[period])/(source.high[period]-source.low[period])*source.volume[period];
    IntradayIntensity[period] =IntradayIntensity[period-1]+ Add;
   end
 
end
 
