-- Id: 800
--+------------------------------------------------------------------+
--|                                     Donchian Channel Signal.lua  |
--|                               Copyright © 2015, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--|                    BitCoin : 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Donchian Channel Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("If a security trades above its highest/lowest 20 day high/low then go Long/Short");
    strategy:type (core.Signal);     
    strategy.parameters:addGroup("Parameters");

 
    strategy.parameters:addInteger("Period", "Period", "", 20,2,2000); 
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("TF", "Timeframe", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	strategy.parameters:addBoolean("RecurrentSound", "RecurrentSound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Email;
local SendEmail;
local RecurrentSound;
local ShowAlert;
local SoundFile; 
local Source = nil;         -- the source stream
local Period; 
local TF;

function Prepare()
    -- collect parameters
	
	Period=instance.parameters.Period;
	TF=instance.parameters.TF;
    ShowAlert = instance.parameters.ShowAlert;
	
   if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
	
	 SendEmail = instance.parameters.SendEmail;
	 
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");
 

    Source = ExtSubscribe(1, nil, TF, instance.parameters.Type == "Bid", "bar");

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ", " .. TF .. ")" 
    instance:name(name);
	
	ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
end


local MAX,MAX;


-- when tick source is updated
function ExtUpdate(id, source, period)	


		if period < Period+1 then
		return;
		end
		 
		
		MIN, MAX = mathex.minmax(Source,period-1-Period+1, period-1);
	 
		
		
				if core.crossesOver(Source.close, MAX, period)  then	 
				 ExtSignal(Source.close, period, "Top Line Cross Over", SoundFile, Email, RecurrentSound);
                end 				
				
				if core.crossesUnder(Source.close, MIN, period)  then	 
				ExtSignal(Source.close, period, "Bottom Line Cross Under", SoundFile, Email, RecurrentSound);
				end  
		  
		 
					   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
