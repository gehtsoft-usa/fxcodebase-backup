-- Id: 495
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=850

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Signals on the base of FXFish indicator");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addInteger("N", "Periods for finding highest high and lowest low", "", 10);
    strategy.parameters:addString("PT", "Price Type", "", "M");
    strategy.parameters:addStringAlternative("PT", "Open", "", "O");
    strategy.parameters:addStringAlternative("PT", "High", "", "H");
    strategy.parameters:addStringAlternative("PT", "Low", "", "L");
    strategy.parameters:addStringAlternative("PT", "Close", "", "C");
    strategy.parameters:addStringAlternative("PT", "Median", "", "M");
    strategy.parameters:addStringAlternative("PT", "Typical", "", "T");
    strategy.parameters:addStringAlternative("PT", "Weighted", "", "W");
    strategy.parameters:addString("MA1M", "First smoothing method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MA1M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA1M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA1M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA1M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA1M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA1M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA1M", "Wilders*", "", "WMA");
    strategy.parameters:addInteger("MA1N", "First smoothing number of periods", "", 9);
    strategy.parameters:addString("MA2M", "Smoothign 2 method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "LWMA");
    strategy.parameters:addStringAlternative("MA2M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA2M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA2M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA2M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA2M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA2M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA2M", "Wilders*", "", "WMA");
    strategy.parameters:addInteger("MA2N", "Smoothing 2 number of periods", "", 45);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
end

local N;
local SoundFile;
local gSource = nil;        -- the source stream
local T = 1.2;              -- threshold

function Prepare(nameOnly)
    N = instance.parameters.N;
    PT = instance.parameters.PT;
    MA1M = instance.parameters.MA1M;
    MA1N = instance.parameters.MA1N;
    MA2M = instance.parameters.MA2M;
    MA2N = instance.parameters.MA2N;

    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
	
	assert(core.indicators:findIndicator("FXFISH") ~= nil, "Please, download and install FXFISH.LUA indicator");  

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
end

local FISH = nil;
local U, D;
local first;
local pos = 0;

-- when tick source is updated
function ExtUpdate(id, source, period)
    if FISH == nil then
        local iprofile = core.indicators:findIndicator("FXFISH");
        local params = iprofile:parameters();
        params:setInteger("N", N);
        params:setString("PT", PT);
        params:setString("MA1M", MA1M);
        params:setInteger("MA1N", MA1N);
        params:setString("MA2M", MA2M);
        params:setInteger("MA2N", MA2N);
        FISH = iprofile:createInstance(gSource, params);
        U = FISH:getStream(0);
        D = FISH:getStream(1);
        first = U:first() + 2;
    end

    FISH:update(core.UpdateLast);


    if period <= first then
        return ;
    end

    local v = 0;
    local v1 = 0;
    local v2 = 0;

    if U[period] > 0 then
        v = U[period];
    else
        v = D[period];
    end
    if U[period - 1] > 0 then
        v1 = U[period - 1];
    else
        v1 = D[period - 1];
    end
    if U[period - 2] > 0 then
        v2 = U[period - 2];
    else
        v2 = D[period - 2];
    end

    if v < 0 and v1 > 0 and pos > 0 then
        ExtSignal(gSource, period, "Exit Buy", SoundFile);
        pos = 0;
    end
    if v > 0 and v1 < 0 and pos < 0 then
        ExtSignal(gSource, period, "Exit Sell", SoundFile);
        pos = 0;
    end
    if v < -T and v > v1 and v1 <= v2 and pos == 0 then
        ExtSignal(gSource, period, "Enter Sell", SoundFile);
        pos = -1;
    end
    if v > T and v < v1 and v1 >= v2 and pos == 0 then
        ExtSignal(gSource, period, "Enter Buy", SoundFile);
        pos = 1;
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
