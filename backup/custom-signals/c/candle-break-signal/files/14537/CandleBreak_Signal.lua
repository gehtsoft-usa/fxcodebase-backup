-- Id: 4519
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
function Init() --The strategy profile initialization
    strategy:name("RSI strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("RSI strategy");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);

    strategy.parameters:addGroup("Email Parameters");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local ShowAlert;
local SoundFile;
local RecurrentSound;
local SendEmail, Email;


local LastH,LastL;

function Prepare()
    LastH=nil;
    LastL=nil;
    ShowAlert = instance.parameters.ShowAlert;
    local PlaySound = instance.parameters.PlaySound
    if  PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or SoundFile ~= "", "Sound file must be chosen");
    RecurrentSound = instance.parameters.Recurrent;

    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or Email ~= "", "Email address must be specified");

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. ".";
    instance:name(name);

    Source = ExtSubscribe(2, nil, "t1", true, "close");
    Source2 = ExtSubscribe(3, nil, instance.parameters.TF, true, "bar");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    if id==3 then
     LastH=source.high[period];
     LastL=source.low[period];
    end
    if id==2 then
     if LastH~=nil then
      if source[period]>LastH then
       ExtSignal(source, period, "High break", SoundFile, Email, RecurrentSound);
       LastH=nil;
      end
     end 
     if LastL~=nil then
      if source[period]<LastL then
       ExtSignal(source, period, "Low break", SoundFile, Email, RecurrentSound);
       LastL=nil;
      end
     end 
    end
   
end

-- The strategy instance finalization.
function ReleaseInstance()
end

function AsyncOperationFinished(cookie, successful, message)
  if not successful then
    core.host:trace('Error: ' .. message)
  end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
