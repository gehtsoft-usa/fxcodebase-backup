-- Id: 25408
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68608

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Average Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("adr_period", "Period", "", 10);
    indicator.parameters:addColor("color", "Color", "", core.rgb(255, 0, 0));
end

local dr;
local loaded = false;
local adr;
local out;
local loopback;

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
    dr = instance:addInternalStream(0, 0);
    adr = core.indicators:create("MVA", dr, instance.parameters.adr_period);
    out = instance:addStream("DATA", core.Line, "AR", "AR", instance.parameters.color, 0, 0);
    out:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    dr[period] = source.high[period] - source.low[period];
    adr:update(mode);
    out[period] = adr.DATA[period];
end
