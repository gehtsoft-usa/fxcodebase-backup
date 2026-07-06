-- Id: 14055
 
--+------------------------------------------------------------------+
--|                                        ADX Consensus Signal.lua  |
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
    strategy:name("ADX Consensus Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("ADX Consensus Signal");

    strategy.parameters:addGroup("1. ADX Calculation"); 
    strategy.parameters:addInteger("Period1", "ADX Period", "", 14, 3, 1000);
    strategy.parameters:addDouble("Level1", "ADX Level", "", 20, 0, 100);	
	strategy.parameters:addString("TF1", "Timeframe", "", "m5");
    strategy.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
	strategy.parameters:addGroup("2. ADX Calculation"); 
    strategy.parameters:addInteger("Period2", "ADX Period", "", 14, 3, 1000);
    strategy.parameters:addDouble("Level2", "ADX Level", "", 20, 0, 100);	
	strategy.parameters:addString("TF2", "Timeframe", "", "H1");
    strategy.parameters:setFlag("TF2", core.FLAG_PERIODS);
		 
 

  

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

local first;
local ShowAlert;
local SoundFile;
local Source1 ,Source2;
local Email;
local SendEmail;
local RecurrentSound;
local Period1,Period2;
local TF1,TF2; 
local ADX1,ADX2;
local Level1,Level2;
function Prepare()
    -- collect parameters	
	 
	Level1 = instance.parameters.Level1;
    Level2 = instance.parameters.Level2;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	TF1 = instance.parameters.TF1;
	TF2 = instance.parameters.TF2;
	   
    ShowAlert = instance.parameters.ShowAlert;
	
   if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
	
	 SendEmail = instance.parameters.SendEmail;
	 RecurrentSound = instance.parameters.RecurrentSound;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    

    Source1 = ExtSubscribe(1, nil, TF1, true, "bar");
	Source2 = ExtSubscribe(2, nil, TF2, true,  "bar");
	
	ADX1  = core.indicators:create("ADX", Source1, Period2);
    ADX2  = core.indicators:create("ADX", Source2, Period2);
	
        local name = profile:id() .. ", " ..  instance.bid:instrument();
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
    ADX1:update(core.UpdateLast);
	ADX2:update(core.UpdateLast);
		   
		
	if id ~= 2 then
    return;
    end
	
			
					if ADX1.DATA[ADX1.DATA:size()-1]  > Level1 
					and ADX2.DATA[ADX2.DATA:size()-1]  > Level2 
					and
					(
					ADX1.DATA[ADX1.DATA:size()-2]  <= Level1 
					or 
					ADX2.DATA[ADX2.DATA:size()-2]  <= Level2 
					)
					then 					
					 ExtSignal(Source2.close, period, "ADX Consensus", SoundFile, Email, RecurrentSound);
					end 	
					 
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
