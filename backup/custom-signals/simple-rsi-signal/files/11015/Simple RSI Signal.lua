-- Id: 3999
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
    strategy:name("RSI Signals");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");
    

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("RSIN", "RSI periods", "", 14, 2, 200);
    strategy.parameters:addInteger("OS", "Oversold level", "", 30, 1, 100);
    strategy.parameters:addInteger("OB", "Overbought level", "", 70, 1, 100);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Period size", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Notification");

    strategy.parameters:addBoolean("ShowAlert", "Show alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurrentSound",  "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	strategy.parameters:addBoolean("SendEmail", "Send e-mail", "", false);
    strategy.parameters:addString("Email", "E-mail address", "Note that to recieve e-mails, SMTP settings must be defined (see Signals Options).", "");
	strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile;
local RecurrentSound;
local RSI;
local OS, OB;
local BUY, SELL;
local gSource = nil;        -- the source stream
local SendEmail, Email;

function Prepare(onlyName)
    local RSIN;

    -- collect parameters
    RSIN = instance.parameters.RSIN;
    OS = instance.parameters.OS;
    OB = instance.parameters.OB;
	
	local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. "," .. RSIN  .. "," .. OS .. "," .. OB .. ")";
    instance:name(name);
	if onlyName then
        return;
    end	

    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
	
	SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");

    RSI = core.indicators:create("RSI", gSource, RSIN);
    
	--localization
	
	ExtSetupSignal("RSI Signals" .. ":", ShowAlert);
	ExtSetupSignalMail(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    RSI:update(core.UpdateLast);

    if not(RSI.DATA:hasData(period - 1)) then
        return ;
    end

    if core.crossesOver(RSI.DATA, OS, period) then
        ExtSignal(gSource, period, "Oversold level CrossOver", SoundFile, Email, RecurrentSound);
    elseif core.crossesUnder(RSI.DATA, OS, period) then
        ExtSignal(gSource, period, "Oversold level CrossUnder", SoundFile, Email, RecurrentSound);		
    elseif core.crossesOver(RSI.DATA, OB, period) then
        ExtSignal(gSource, period, "Overbought level CrossOver", SoundFile, Email, RecurrentSound);
	elseif core.crossesUnder(RSI.DATA, OB, period) then
        ExtSignal(gSource, period, "Overbought level CrossUnder", SoundFile, Email, RecurrentSound);
	 elseif core.crossesOver(RSI.DATA, 50, period) then
        ExtSignal(gSource, period, "Central Line CrossOver", SoundFile, Email, RecurrentSound);
	elseif core.crossesUnder(RSI.DATA, 50, period) then
        ExtSignal(gSource, period, "Central Line CrossUnder", SoundFile, Email, RecurrentSound);	
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
