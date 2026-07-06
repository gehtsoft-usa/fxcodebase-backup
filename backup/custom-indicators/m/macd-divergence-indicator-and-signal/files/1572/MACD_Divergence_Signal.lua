-- Id: 518
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=869

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    strategy:name("MACD Divergence");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when the MACD Divergence detected");

    strategy.parameters:addInteger("MACD_Short", "Period of short EMA for MACD", "", 12);
    strategy.parameters:addInteger("MACD_Long", "Period of long EMA for MACD", "", 26);
    strategy.parameters:addInteger("MACD_Signal", "Signal period of MACD", "", 9);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
end

local SoundFile;
local gSource = nil;        -- the source stream

function Prepare(nameOnly)

    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. instance.parameters.MACD_Short .. "," .. instance.parameters.MACD_Long .. "," .. instance.parameters.MACD_Signal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
	
	assert(core.indicators:findIndicator("MACD_DIVERGENCE") ~= nil, "Please, download and install MACD_DIVERGENCE.LUA indicator");    
end

local MACD = nil;

-- when tick source is updated
function ExtUpdate(id, source, period)
    if MACD == nil then
        MACD = core.indicators:create("MACD_DIVERGENCE", gSource, instance.parameters.MACD_Short,instance.parameters.MACD_Long,instance.parameters.MACD_Signal, false);
    end

    MACD:update(core.UpdateLast);


    if period <= instance.parameters.MACD_Long + 10 then
        return ;
    end

    local v;

    if MACD:getStream(1):hasData(period - 2) then
        v = MACD:getStream(1)[period - 2];
        if v > 0 then
            ExtSignal(gSource, period, "Classic Bearish", SoundFile);
        elseif v < 0 then
            ExtSignal(gSource, period, "Reversal Bearish", SoundFile);
        end
    end
    if MACD:getStream(2):hasData(period - 2) then
        v = MACD:getStream(2)[period - 2];
        if v > 0 then
            ExtSignal(gSource, period, "Classic Bullish", SoundFile);
        elseif v < 0 then
            ExtSignal(gSource, period, "Reversal Bullish", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
