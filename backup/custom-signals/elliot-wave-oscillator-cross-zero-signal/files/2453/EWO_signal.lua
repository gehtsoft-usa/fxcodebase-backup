-- Id: 863
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
    strategy:name("Elliot wave oscillator signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addInteger("FastN", "Fast Moving Average", "", 5, 2, 1000);
    strategy.parameters:addInteger("SlowN", "Slow Moving Average", "", 35, 2, 1000);

    strategy.parameters:addString("Source", "Price", "", "M2");
    strategy.parameters:addStringAlternative("Source", "Typical", "", "M3");
    strategy.parameters:addStringAlternative("Source", "Median", "", "M2");
    strategy.parameters:addStringAlternative("Source", "Close", "", "C");

    strategy.parameters:addString("Method", "Moving average method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("Method", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("Method", "Wilders*", "", "WMA");

    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local gSource = nil;
local gEwo = nil;
local gEwoData = nil;
local b1, b2;
local first;

function Prepare()
    local ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");
    ExtSetupSignal("EWO signal:", ShowAlert);
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
    gEwo = core.indicators:create("EWO", gSource, instance.parameters.FastN, instance.parameters.SlowN, instance.parameters.Source, instance.parameters.Method, "No");
    gEwoData = gEwo.DATA;
    first = gEwoData:first() + 1;
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. "," .. instance.parameters.FastN .. "," .. instance.parameters.SlowN .. "," .. instance.parameters.Method .. ")";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    if id == 1 and period >= first then
        gEwo:update(core.UpdateLast);
        if core.crossesOver(gEwoData, 0, period) then
            ExtSignal(gSource, period, "Crosses over Zero", SoundFile);
        elseif core.crossesUnder(gEwoData, 0, period) then
            ExtSignal(gSource, period, "Crosses under Zero", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
