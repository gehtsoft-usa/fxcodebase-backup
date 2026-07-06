-- Id: 5365
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
    strategy:name("MA distance signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("MA distance signal");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addString("Price", "Price", "", "close");
    strategy.parameters:addStringAlternative("Price", "close", "", "close");
    strategy.parameters:addStringAlternative("Price", "open", "", "open");
    strategy.parameters:addStringAlternative("Price", "high", "", "high");
    strategy.parameters:addStringAlternative("Price", "low", "", "low");
    strategy.parameters:addStringAlternative("Price", "median", "", "median");
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical");
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    strategy.parameters:addString("Method", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    strategy.parameters:addInteger("Period", "Period", "", 20);

    strategy.parameters:addInteger("Distance", "Distance in pips", "", 10);

    strategy.parameters:addString("Type", "Type", "", "near");
    strategy.parameters:addStringAlternative("Type", "near", "", "near");
    strategy.parameters:addStringAlternative("Type", "far", "", "far");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addString("AlertText", "Alert text", "", "MA distance alert");
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);

    strategy.parameters:addGroup("Email Parameters");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Signal Parameters
local ShowAlert;
local SoundFile;
local RecurrentSound;
local SendEmail, Email;


-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend;

local MA;
local LastMA=nil;

--
--
--
function Prepare()
    ShowAlert = instance.parameters.ShowAlert;
    AllowDirection = instance.parameters.AllowDirection;
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
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. ")";
    instance:name(name);

    Source = ExtSubscribe(2, nil, "t1", true, "close");
    Source2 = ExtSubscribe(3, nil, instance.parameters.TF, true, instance.parameters.Price);
    
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "AVERAGES" .. " indicator must be installed");
    MA = core.indicators:create("AVERAGES", Source2, instance.parameters.Method, instance.parameters.Period, false);

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
    LastMA=nil;
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if id==3 then
     MA:update(core.UpdateLast);
     LastMA=MA.DATA[period];
    elseif id==2 and LastMA~=nil then
     local Dist=math.abs(LastMA-source[period]);
     if instance.parameters.Type=="near" then
      if Dist<instance.parameters.Distance*source:pipSize() then
       ExtSignal(source, period, instance.parameters.AlertText, SoundFile, Email, RecurrentSound);
       LastMA=nil;
      end
     else
      if Dist>instance.parameters.Distance*source:pipSize() then
       ExtSignal(source, period, instance.parameters.AlertText, SoundFile, Email, RecurrentSound);
       LastMA=nil;
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
