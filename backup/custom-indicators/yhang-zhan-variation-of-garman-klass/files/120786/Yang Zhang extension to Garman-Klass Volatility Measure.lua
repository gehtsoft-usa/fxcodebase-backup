-- Id: 22171
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66600

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Yang Zhang extension to Garman-Klass Volatility Measure")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 254)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local Period
local first
local source = nil
local Volatility;
local Data; 

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    source = instance.source;
    Period = instance.parameters.Period
    first = source:first();

    
	Data = instance:addInternalStream(0, 0);
 
    Volatility = instance:addStream("Volatility", core.Line, "Volatility", "Volatility", instance.parameters.color, first+Period);
    Volatility:setPrecision(math.max(2, instance.source:getPrecision()));
    Volatility:setWidth(instance.parameters.width);
    Volatility:setStyle(instance.parameters.style);
end

 
-- Indicator calculation routine
function Update(period, mode)


    if period < first then
        return;
    end
	
	
	Data[period]=math.log(source.open[period]*source.close[period-1])^2
	+ (1/2)* math.log(source.high[period]*source.low[period])^2
	- (2*math.log(2)-1)* math.log(source.close[period]*source.open[period])^2;
	
	if period < first+Period then
        return;
    end
	 
	
    Volatility[period] =((1/Period)*mathex.sum(Data, period-Period+1, period))^(1/2);
   
end
