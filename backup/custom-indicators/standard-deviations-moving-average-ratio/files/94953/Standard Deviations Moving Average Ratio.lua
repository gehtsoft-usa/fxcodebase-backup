-- Id: 12154
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60925

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Standard Deviations Moving Average Ratio");
    indicator:description(" ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","Period", 20, 1, 10000);
     
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color","Lines Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width","Lines Width","", 1, 1, 5);
    indicator.parameters:addInteger("style", "Lines Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);

   
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local Ratio;
local first;
local source = nil;
 

-- Routine
function Prepare(nameOnly)

    N = instance.parameters.N;
    source = instance.source;
 
    first  = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    Ratio = instance:addStream("Ratio", core.Line, name .. ".Ratio", "Ratio", instance.parameters.color, first )
    Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    Ratio:setWidth(instance.parameters.width );
    Ratio:setStyle(instance.parameters.style );
    
end

 
  

-- Indicator calculation routine
function Update(period)
  if period < first then
  return;
  end
        Ratio[period]= mathex.stdev(source, period - N + 1, period) /mathex.avg(source, period - N + 1, period);
        
      
    
end

