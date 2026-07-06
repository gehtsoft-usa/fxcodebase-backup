-- Id: 3550
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Alert New Candle");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("The signal show alerts when a first tick of new candle appears");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addString("TF", "Time frame of candle", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowMessage", "Show message when new candle appears?", "", false);
    strategy.parameters:addBoolean("PlaySound", "Play Sound when new candle appears?", "", true);
    strategy.parameters:addFile("Sound", "Sound file", "", "");
    strategy.parameters:setFlag("Sound", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent sound?", "", false);
end

local name;
local TF;
local tradingDayOffset, tradingWeekOffset;

function Prepare(onlyName)
    assert(instance.parameters.TF ~= "t1", "Please choose non-tick time frame");

    name = profile:id() .. "(" .. instance.bid:instrument() .. "," .. instance.parameters.TF .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    tradingDayOffset = core.host:execute("getTradingDayOffset");
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
end

local endOfCandle = nil;

function Update()
    local s, e;

    if endOfCandle == nil then
        s, e = core.getcandle(TF, instance.bid:date(NOW), tradingDayOffset, tradingWeekOffset);
        endOfCandle = e;
    elseif instance.bid:date(NOW) >= endOfCandle then
        s, e = core.getcandle(TF, instance.bid:date(NOW), tradingDayOffset, tradingWeekOffset);
        endOfCandle = e;
        if instance.parameters.ShowMessage then
            local message;
            message = string.format("Candle of %s/%s (%s) is started", instance.bid:instrument(), TF, core.formatDate(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, s)));
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], message, instance.bid:date(NOW));
        end

        if instance.parameters.PlaySound then
            terminal:alertSound(instance.parameters.Sound, instance.parameters.RecurrentSound);
        end
    end
end
