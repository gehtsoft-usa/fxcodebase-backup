-- Id: 658
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
    strategy:name("Elder Impulse System Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameter");

    strategy.parameters:addInteger("EMA", "EMA periods for study", "", 13, 1, 100);
    strategy.parameters:addInteger("MACDF", "MACD periods fast", "", 12, 1, 100);
    strategy.parameters:addInteger("MACDS", "MACD periods slow", "", 26, 1, 100);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signal");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local E, U, D, N;
local gSource = nil;        -- the source stream

function Prepare()
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "The sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "close");

    assert(core.indicators:findIndicator("ELDER_IMPULSE_SYSTEM") ~= nil, "ELDER_IMPULSE_SYSTEM" .. " indicator must be installed");
    E = core.indicators:create("ELDER_IMPULSE_SYSTEM", gSource, instance.parameters.EMA, instance.parameters.MACDF, instance.parameters.MACDS);

    U = E:getStream(0);
    D = E:getStream(1);
    N = E:getStream(2);

    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. "," .. instance.parameters.EMA  .. "," .. instance.parameters.MACDF .. "," .. instance.parameters.MACDS .. ")";
    instance:name(name);
end

function getElder(period)
    if U:hasData(period) and U[period] == 100 then
        return 1;
    elseif D:hasData(period) and D[period] == 100 then
        return 2;
    elseif N:hasData(period) and N[period] == 100 then
        return 3;
    else
        return 0;
    end
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    E:update(core.UpdateLast);

    local prev, curr;
    prev = getElder(period - 1);
    curr = getElder(period);

    if prev ~= curr then
        if curr == 1 then
            ExtSignal(gSource, period, "UP", SoundFile);
        elseif curr == 2 then
            ExtSignal(gSource, period, "DOWN", SoundFile);
        elseif curr == 3 then
            ExtSignal(gSource, period, "NEUTRAL", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
