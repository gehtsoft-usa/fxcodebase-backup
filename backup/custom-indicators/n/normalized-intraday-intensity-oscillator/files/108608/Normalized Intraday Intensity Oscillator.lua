-- Id: 16807
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63978&p=108608#p108608

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
    indicator:name("Normalized Intraday Intensity Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Periods", "", 21, 1, 1000);
 
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local Period;
local MA1, MA2;
local Normalized;
local Temp;
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;
 
	Temp = instance:addInternalStream(0, 0);
	 
    name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end

	MA1 = core.indicators:create("MVA", Temp, Period);
	MA2 = core.indicators:create("MVA", source.volume, Period);
 
     
   Normalized = instance:addStream("Normalized", core.Line, name, "Normalized", instance.parameters.color,  MA1.DATA:first());   
    Normalized:setPrecision(math.max(2, instance.source:getPrecision()));
   Normalized:setWidth(instance.parameters.width);
   Normalized:setStyle(instance.parameters.style);
	
 
end

function Update(period, mode)

   --temp = (2*lastArray - highArray - lowArray) / (highArray - lowArray)*volArray
   if (source.high[period]-source.low[period])~= 0 then
   Temp[period]=(2*source.close[period]-source.high[period]-source.low[period])/(source.high[period]-source.low[period])*source.volume[period];
   end
   MA1:update(mode);
   MA2:update(mode);  
   
   if period < MA1.DATA:first() then
   return;
   end   
   
  -- sma(temp,period)/sma(volArray,period)*100
   Normalized[period] =MA1.DATA[period] / MA2.DATA[period]*100;
    
end
 
