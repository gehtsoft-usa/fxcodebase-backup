-- Id: 1571
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
    strategy:name("%R Larry Williams Cross Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when the oscillator crosses oversold or overbought level");

    strategy.parameters:addGroup("RLW Parameter");
    strategy.parameters:addInteger("rlw_n", "Indicator periods", "No description", 14, 1, 100);

    strategy.parameters:addGroup("Levels");
    strategy.parameters:addInteger("up", "Up Level", "No description", -20, 1, 100);
    strategy.parameters:addInteger("down", "Down Level", "No description", -80, 1, 100);

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
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local tsource = nil;
local rlw;
local up, down;

function Prepare()
    local ShowAlert, PlaySound, SendEmail;

    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

    local name;
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. instance.parameters.rlw_n  .. "," ..
                           instance.parameters.up .. "," .. instance.parameters.down  .. ")";
    instance:name(name);

    up = instance.parameters.up;
    down = instance.parameters.down;

    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);

    ExtSubscribe(1, nil, "t1", true, "close");
end

function ExtUpdate(id, source, period)
    if id == 1 and tsource == nil then
        tsource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
        rlw = core.indicators:create("RLW", tsource, instance.parameters.rlw_n);
        first = rlw.DATA:first() + 1;
    elseif id == 2 and period >= first then
        rlw:update(core.UpdateLast);
        if core.crossesOver(rlw.DATA, up, period) then
            ExtSignal(instance.bid, instance.bid:size() - 1, "Crossed Over Up", SoundFile, Email);
        elseif core.crossesUnder(rlw.DATA, down, period) then
            ExtSignal(instance.bid, instance.bid:size() - 1, "Crossed Under Down", SoundFile, Email);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
