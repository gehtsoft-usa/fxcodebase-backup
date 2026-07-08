-- Id: 489
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=846

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    strategy:name("RSI Divergence");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when the RSI Divergence detected");

    strategy.parameters:addInteger("N", "Periods for RSI Divergence", "", 7, 2, 200);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    --strategy.parameters:addFile("SoundFile", "Sound file", "", "");
	
	strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
end

local N;
local SoundFile;
local gSource = nil;        -- the source stream

function Prepare(nameOnly)
    N = instance.parameters.N;

    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("RSI_DIVERGENCE") ~= nil, "Please, download and install RSI_DIVERGENCE.LUA indicator");  

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
end

local RSI = nil;

-- when tick source is updated
function ExtUpdate(id, source, period)
    if RSI == nil then
        RSI = core.indicators:create("RSI_DIVERGENCE", gSource, N, false);
    end

    RSI:update(core.UpdateLast);


    if period <= N + 10 then
        return ;
    end

    local v;

    if RSI:getStream(1):hasData(period - 2) then
        v = RSI:getStream(1)[period - 2];
        if v > 0 then
            ExtSignal(gSource, period, "Classic Bearish", SoundFile);
        elseif v < 0 then
            ExtSignal(gSource, period, "Reversal Bearish", SoundFile);
        end
    end
    if RSI:getStream(2):hasData(period - 2) then
        v = RSI:getStream(2)[period - 2];
        if v > 0 then
            ExtSignal(gSource, period, "Classic Bullish", SoundFile);
        elseif v < 0 then
            ExtSignal(gSource, period, "Reversal Bullish", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
