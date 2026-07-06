-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71472

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  |
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   |
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |
--+------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
--|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
--|Binance MEMO (BEP2 only)   : 107152697                                  |
--|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
--+------------------------------------------------------------------------+

function Init()
    indicator:name("Moving average VWAP");
    indicator:description("Moving average VWAP");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("cumulativePeriod", "Period", "", 5);
end

local source;
local params = {};
local plot1, plot2;
local vars = {};
local ma;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    params["cumulativePeriod"] = instance.parameters.cumulativePeriod;
    plot1 = instance:addStream("plot1", core.Line, "MA 1", "MA 1", core.colors().Red, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:addStream("plot2", core.Line, "MA 2", "MA 2", core.colors().Green, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    typicalPriceVolume = instance:addInternalStream(0, 0);
    ma = core.indicators:create("MVA", plot1, 21);
end

function Update(period, mode)
    if period < params["cumulativePeriod"] then
        return;
    end
    typicalPriceVolume[period] = source.typical[period] * source.volume[period];
    cumulativeTypicalPriceVolume = mathex.sum(typicalPriceVolume, core.rangeTo(period, params["cumulativePeriod"]))
    cumulativeVolume = mathex.sum(source.volume, core.rangeTo(period, params["cumulativePeriod"]))
    plot1[period] = cumulativeVolume == 0 and 0 or cumulativeTypicalPriceVolume / cumulativeVolume;
    ma:update(mode);
    plot2[period] = ma.DATA[period];
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
