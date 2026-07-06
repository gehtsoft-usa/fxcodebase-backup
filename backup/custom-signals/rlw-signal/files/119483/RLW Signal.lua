-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=66177

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
    strategy:name("RLW signal");
    strategy:description("RLW signal");
    strategy:setTag("NonOptimizableParameters", "SendEmail,PlaySound,Email,SoundFile,RecurrentSound,ShowAlert");
    strategy:type(core.Signal);

    strategy.parameters:addGroup("Calculation parameters");
	strategy.parameters:addDouble("OB", "OB Level", "", -20);
	strategy.parameters:addDouble("OS", "OS Level", "", -80);
	
	 strategy.parameters:addBoolean("Inverse", "Inverse", "", false);

    strategy.parameters:addInteger("Period", "RLW Period", "", 14, 2, 200);

    strategy.parameters:addString("Type","Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
 

    strategy.parameters:addString("TF", "Period Type", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_BARPERIODS);

    strategy.parameters:addGroup("Signal parameters");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "SEND EMAIL", "", false);
    strategy.parameters:addString("Email", "EMAIL ADDRESS", "EMAIL ADDRESSDESCR", "anashassan76@gmail.com");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile;
local RecurrentSound;
local Indicator;
local BUY, SELL;
local gSource = nil;        -- the source stream
local SendEmail, Email;
local Period;
local OB,OS;
local Inverse;
function Prepare(onlyName)
       -- collect parameters
    Period = instance.parameters.Period;
    OB = instance.parameters.OB;
	OS = instance.parameters.OS;
	Inverse = instance.parameters.Inverse;
    
     -- set the name 
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")";
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
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file was not defined");
    
    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""),"Email file was not defined");
   
    assert(instance.parameters.TF ~= "t1", "t1 time is not allowed ");

    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");

    Indicator = core.indicators:create("RLW", gSource , Period);
    
    --localization
    BUY = ("BUY")
    SELL = ("SELL")
    ExtSetupSignal("RLW" .. ":", ShowAlert);
    ExtSetupSignalMail(name);   
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    Indicator:update(core.UpdateLast);

    if not(Indicator.DATA:hasData(period - 1)) then
        return ;
    end
  
  
   if Inverse  then
   
       if core.crossesOver(Indicator.DATA, OS ,period)then
			ExtSignal(gSource, period, BUY, SoundFile, Email, RecurrentSound);
			 
		elseif core.crossesUnder(Indicator.DATA, OB, period)then
	 
			ExtSignal(gSource, period, SELL, SoundFile, Email, RecurrentSound);
			
	   end
   
   
   else
     
	   if core.crossesOver(Indicator.DATA, OB, period)then
			ExtSignal(gSource, period, BUY, SoundFile, Email, RecurrentSound);
			 
		elseif core.crossesUnder(Indicator.DATA, OS, period)then
	 
			ExtSignal(gSource, period, SELL, SoundFile, Email, RecurrentSound);
			
	   end
   end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
