-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1970
-- Id: 1386

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Ichimoku Advanced Siganl");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when span lines crosses and when close crosses span channel");

    strategy.parameters:addGroup("Ichimoku Parameter");
    strategy.parameters:addInteger("Tenkan", "Tenkan", "", 9, 1, 300);
    strategy.parameters:addInteger("Kijun", "Kijun", "", 26, 1, 300);
    strategy.parameters:addInteger("Senkou", "Senkou", "", 52, 1, 300);
    strategy.parameters:addInteger("SpanShift", "Span Shift", "", 0, -200, 200);
    strategy.parameters:addInteger("ChinkouShift", "Chinkou Shift", "", 0, -200, 200);
    strategy.parameters:addBoolean("Signal1", "Span Cross Signal", "", true);
    strategy.parameters:addBoolean("Signal2", "Close Cross Signal", "", true);

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local gSource = nil;
local ICH = nil;
local S1;
local S2;
local Signal1;
local Signal2;

function Prepare(nameOnly)
    ShowAlert = instance.parameters.ShowAlert;
    Signal1 = instance.parameters.Signal1;
    Signal2 = instance.parameters.Signal2;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    ExtSetupSignal("Ichimoku Advanced", ShowAlert);

    assert(instance.parameters.Period ~= "t1", "The time frame must not be a tick!");

    local ichprofile = core.indicators:findIndicator("ICH1");
    assert(ichprofile ~= nil, "The ICH1 (Ichimoku Advanced) indicator must also be installed");


    local name;
    name = profile:id() .. "(" .. instance.source:instrument() .. "[" .. instance.parameters.Period .. "]" .. "," .. instance.parameters.Tenkan .. "," .. instance.parameters.Kijun .. "," .. instance.parameters.Senkou .. "," .. instance.parameters.SpanShift .. "," .. instance.parameters.ChinkouShift ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    local ichparams = ichprofile:parameters();
    ichparams:setInteger("Tenkan", instance.parameters.Tenkan);
    ichparams:setInteger("Kijun", instance.parameters.Kijun);
    ichparams:setInteger("Senkou", instance.parameters.Senkou);
    ichparams:setInteger("SpanShift", instance.parameters.SpanShift);
    ichparams:setInteger("ChinkouShift", instance.parameters.ChinkouShift);
    ichparams:setBoolean("Signal1", true);
    ichparams:setBoolean("Signal2", true);
    ichparams:setBoolean("SignalMode", false);
    ichparams:setBoolean("TenkanShow", false);
    ichparams:setBoolean("KijunShow", false);
    ichparams:setBoolean("ChinkouShow", false);
    ICH = ichprofile:createInstance(gSource, ichparams);
    S1 = ICH:getStream(3);
    S2 = ICH:getStream(2);
end

function ExtUpdate(id, source, period)
    if id == 1 then
        ICH:update(core.UpdateLast);

        local signal = "";
        local c = 0;

        if Signal2 then
            if S1[period] == 1 then
                signal = "Close Cross Span A";
                c = c + 1;
            elseif S1[period] == 2 then
                signal = "Close Cross Span B";
                c = c + 1;
            elseif S1[period] == 3 then
                signal = "Close Cross Both Spans";
                c = c + 1;
            end
        end

        if Signal1 then
            if period >= S2:first() then
                if S2[period] == 1 then
                    signal = signal .. " Span crossed";
                    c = c + 1;
                end
            end
        end
        if c > 0 then
            ExtSignal(gSource.close, period, signal, SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
