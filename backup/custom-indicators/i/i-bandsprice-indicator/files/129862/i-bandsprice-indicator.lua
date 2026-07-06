-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69148

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
    indicator:name("I Bands Price");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("BandsPeriod", "Bands period", "", 20);
    indicator.parameters:addDouble("BandsDeviations", "Bands deviations", "", 2.0);
    indicator.parameters:addInteger("Slow", "Slow", "", 5);

    indicator.parameters:addColor("color", "Color", "", core.colors().Red);
end

local source;
local oldVal, BandsPeriod, BandsDeviations, BPBuffer, Buffer, ma;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    BandsPeriod = instance.parameters.BandsPeriod;
    BandsDeviations = instance.parameters.BandsDeviations;
    if nameOnly then
        return ;
    end

    oldVal = core.indicators:create("MVA", source, instance.parameters.BandsPeriod);
    BPBuffer = instance:addInternalStream(0, 0);
    ma = core.indicators:create("MVA", BPBuffer, instance.parameters.Slow);
    Buffer = instance:addStream("Buffer", core.Line, "Buffer", "Buffer", instance.parameters.color, 0, 0);
end

function Update(period, mode)
    oldVal:update(mode);
    if period < BandsPeriod or not oldVal.DATA:hasData(period - BandsPeriod - 1) then
        return;
    end
    local sum = 0.0;
    for i = 0, BandsPeriod - 1 do
        local newres = source.close[period - i] - oldVal.DATA[period];
        sum = sum + newres * newres;
    end
    local deviation = BandsDeviations * math.sqrt(sum / BandsPeriod);
    local upband = oldVal.DATA[period] + deviation;
    local dwband = oldVal.DATA[period] - deviation;
    if upband - dwband ~= 0 then
        BPBuffer[period] = (source.close[period] - dwband) / (upband - dwband);
    else
        BPBuffer[period] = 0;
    end
    ma:update(mode);
    Buffer[period] = ma.DATA[period];
end