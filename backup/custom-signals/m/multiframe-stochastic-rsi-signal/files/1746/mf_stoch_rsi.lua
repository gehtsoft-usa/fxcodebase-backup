-- Id: 613
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
    strategy:name("Multiframe Stoch RSI signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when two Stoch RSI moves in the same zone");

    strategy.parameters:addInteger("OS", "Oversold level", "", 20, 1, 50);
    strategy.parameters:addInteger("OB", "Overbought level", "", 80, 50, 99);
    strategy.parameters:addString("TF1", "Fast Stochastic time frame", "", "m5");
    strategy.parameters:setFlag("TF1", core.FLAG_PERIODS);
    strategy.parameters:addInteger("N1", "Fast Stochastic Number of periods for RSI", "", 14, 1, 200);
    strategy.parameters:addInteger("K1", "Fast Stochastic %K Stochastic Periods", "", 14, 1, 200);
    strategy.parameters:addInteger("KS1", "Fast Stochastic %K Slowing Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("D1", "Fast Stochastic %D Slowing Stochastic Periods", "", 3, 1, 200);

    strategy.parameters:addString("TF2", "Fast Stochastic time frame", "", "m30");
    strategy.parameters:setFlag("TF2", core.FLAG_PERIODS);
    strategy.parameters:addInteger("N2", "Fast Stochastic Number of periods for RSI", "", 14, 1, 200);
    strategy.parameters:addInteger("K2", "Fast Stochastic %K Stochastic Periods", "", 14, 1, 200);
    strategy.parameters:addInteger("KS2", "Fast Stochastic %K Slowing Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("D2", "Fast Stochastic %D Slowing Stochastic Periods", "", 3, 1, 200);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
	strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
end

local OS, OB;
local SoundFile;
local gSource1 = nil;
local gSource2 = nil;
local RSI1 = nil;
local RSI2 = nil;
local RSI1D = nil;
local RSI2D = nil;

function Prepare()
    local ShowAlert = instance.parameters.ShowAlert;
    OS = instance.parameters.OS;
    OB = instance.parameters.OB;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    local s, e;
    local l1, l2;
    s, e = core.getcandle(instance.parameters.TF1, 0, 0);
    l1 = e - s;
    s, e = core.getcandle(instance.parameters.TF2, 0, 0);
    l2 = e - s;
    assert(l1 < l2, "The first time frame must be shorter than the second timeframe");

    gSource1 = ExtSubscribe(1, nil, instance.parameters.TF1, true, "close");
    gSource2 = ExtSubscribe(2, nil, instance.parameters.TF2, true, "close");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "," ..
                 "STOCHRSI(" .. instance.parameters.TF1 .. ", " .. instance.parameters.N1 .. ", " .. instance.parameters.K1  .. ", " .. instance.parameters.KS1   .. ", " .. instance.parameters.D1 .. "), " ..
                 "STOCHRSI(" .. instance.parameters.TF2 .. ", " .. instance.parameters.N2 .. ", " .. instance.parameters.K2  .. ", " .. instance.parameters.KS2   .. ", " .. instance.parameters.D2 .. "))";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    local stream;

    if RSI1 == nil then
    assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "STOCHRSI" .. " indicator must be installed");
        RSI1 = core.indicators:create("STOCHRSI", gSource1, instance.parameters.N1, instance.parameters.K1, instance.parameters.KS1, instance.parameters.D1);
        RSI1D = RSI1:getStream(1);
    end
    if RSI2 == nil then
        RSI2 = core.indicators:create("STOCHRSI", gSource2, instance.parameters.N2, instance.parameters.K2, instance.parameters.KS2, instance.parameters.D2);
        RSI2D = RSI2:getStream(1);
    end
    RSI1:update(core.UpdateLast);
    RSI2:update(core.UpdateLast);

    if id ~= 1 then
        return ;
    end

    if gSource1:size() > RSI1D:first() + 1 and
       gSource2:size() > RSI2D:first() + 1 then
        if RSI2D[NOW] > OB and core.crossesOver(RSI1D, OB, NOW) then
           ExtSignal(instance.bid, instance.bid:size() - 1, instance.parameters.TF2 .. " bearish, " .. instance.parameters.TF1 .. " turns bearish", SoundFile);
        end
        if RSI2D[NOW] < OS and core.crossesUnder(RSI1D, OS, NOW) then
           ExtSignal(instance.bid, instance.bid:size() - 1, instance.parameters.TF2 .. " bullish, " .. instance.parameters.TF1 .. " turns bullish", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
