-- Id: 3967
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
    strategy:name("QQE Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Alarm when the QQE and the signal cross at the close of the bar.");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("QQE Parameters");
    strategy.parameters:addInteger("RF", "RSI Period", "RSI Period", 14);
    strategy.parameters:addInteger("RSP", "RSI  Smoothing Period", "RSI  Smoothing Period", 5);
    strategy.parameters:addInteger("AP", " ATR Period", " ATR Period", 14);
    strategy.parameters:addDouble("F", "Fast ATR Multipliers", "Fast ATR Multipliers", 2.618 );
	strategy.parameters:addDouble("S", "Slow ATR Multipliers", "Slow ATR Multipliers", 4.236);
 
    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true);
    strategy.parameters:addString("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local ShowAlert;
local SoundFile;
local PlaySound;
local RecurrentSound;
local SendEmail;
local Email;
local BarSource = nil;         -- the source stream

local QQE

function Prepare()
    ShowAlert = instance.parameters.ShowAlert;
    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        RecurrentSound = instance.parameters.RecurSound;
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
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    assert(core.indicators:findIndicator("QQE") ~= nil, "QQE" .. " indicator must be installed");
    QQE = core.indicators:create("QQE", BarSource.close, instance.parameters.RF, instance.parameters.RSP, instance.parameters.AP, instance.parameters.F, instance.parameters.S, false)
    
    
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);

    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);
    
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
    QQE:update(core.UpdateLast)
    
    if period >= QQE.QQE:first() + 1 and period >= QQE.TS1:first() + 1 then
        if core.crosses(QQE.QQE, QQE.TS1, period)  then	 
            ExtSignal(BarSource.close, period, "QQE Signal", SoundFile);
        end 				
    end
					   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
