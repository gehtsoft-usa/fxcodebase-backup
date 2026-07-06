-- Id: 464
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=257

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    strategy:name("Vector 2 Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when Vector crosses +/- 0 ");

    strategy.parameters:addGroup("Parameters");
  
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

local SoundFile;
local Vector;
local VC;
local SHORT, LONG;
local gSource = nil;        -- the source stream

function Prepare(nameOnly)
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    SHORT = "Short";
    LONG = "Long";
    local name = profile:id() .. "Vector";
    instance:name(name);
    if nameOnly then
        return;
    end

    ExtSetupSignal("Vector", ShowAlert);

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    assert(core.indicators:findIndicator("VEKTOR2") ~= nil, "Please, download and install VEKTOR2.LUA indicator");
    Vector = core.indicators:create("VEKTOR2", gSource);
    VC = Vector:getStream(0);
    
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    Vector:update(core.UpdateLast);
   if period >= VC:first() + 1 then
        if core.crossesOver(VC, 0, period) then
                    ExtSignal(gSource, period, LONG, SoundFile);
                   
        end
          
        if core.crossesUnder(VC, 0, period) then
                   
                    ExtSignal(gSource, period, SHORT, SoundFile);
                 
          end
           
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
