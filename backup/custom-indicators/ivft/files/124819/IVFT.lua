-- Id: 24232
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67756

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("IVFT");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     
    indicator.parameters:addInteger("Period", "Period", "", 10);
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
end

local first;
local source = nil;
local Value;
local tmpSeries;
local Period;
 
function Prepare(nameOnly)   
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
    Period = instance.parameters.Period;
    source = instance.source;
    tmpSeries = instance:addInternalStream(0, 0);
	Value = instance:addStream("IVFT" , core.Line, "IVFT", "IVFT", instance.parameters.color1, 0);
    Value:setPrecision(math.max(2, instance.source:getPrecision()));
	Value:setWidth(instance.parameters.width1);
    Value:setStyle(instance.parameters.style1);
end

function Update(period, mode)
    if period < Period then
        return;
    end
    local minLo	= mathex.min(source, period - Period + 1, period);
    local num1 = math.max(mathex.max(source, period - Period + 1, period) - minLo, source:pipSize() / 10);
    local tmpValue = ((source[period] - minLo) / num1 - 0.5) + 0.999 * tmpSeries[period - 1];

    if (tmpValue > 0.99) then
        tmpValue = 0.999;
    elseif (tmpValue < -0.99) then 
        tmpValue = -0.999;
    end
    
    tmpSeries[period] = tmpValue;
    Value[period] = (math.exp(2 * tmpValue) - 1) / (math.exp(2 * tmpValue) + 1);
end
