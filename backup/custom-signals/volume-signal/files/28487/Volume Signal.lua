-- Id: 9661
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
    strategy:name("Volume Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameters");	 
    strategy.parameters:addInteger("Level", "Volume Threshold", "Threshold can not be zero", 0, 0, 1000000);	
	
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("TF", "Timeframe", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local first;
local ShowAlert;
local SoundFile;
local Source = nil;       
local Email;
local SendEmail;
local  Level;
local Last;
local Flag;
function Prepare()
    -- collect parameters	
   
	Level = instance.parameters.Level;	
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	 SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	assert(instance.parameters.TF ~= "t1", "timeframe must not be tick");
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

   
	
    Source = ExtSubscribe(1, nil, instance.parameters.TF , instance.parameters.Type == "Bid", "bar");
		
	first= Source.close:first()+1;
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", ".. Level  .. ")";
         instance:name(name);
		 
		 
    ExtSetupSignal("Volume Signal", ShowAlert); 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
    
		   
		if  period  <  first 
		or  id ~= 1
		or  Level == 0
		 then
		return;
		end
			
					if Source.volume[period] > Level
					and Last ~= source:serial(period) 
					then 	
                     Last = source:serial(period);  					
					 ExtSignal(Source, period, "Volume Threshold Reached" , SoundFile, Email);
					end 	
					
				
				
				 				 
					if Source.volume[period-1] < Level
					and Source.volume[period-2] >= Level
					and Flag ~= source:serial(period-1) 
					then 	
                     Flag = source:serial(period-1);  					
					 ExtSignal(Source, period, "Volume has fallen below Threshold" , SoundFile, Email);
					end 	
			  
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
