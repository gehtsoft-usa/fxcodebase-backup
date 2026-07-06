-- Id: 14369
--+------------------------------------------------------------------+
--|                                              ADX DMI Alert.lua   |
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
    strategy:name("ADX DMI Alert");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("ADX DMI Alert");

    strategy.parameters:addGroup("Parameters");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addInteger("ADX", "ADX Period", "ADX Period", 14, 2, 1000);
    strategy.parameters:addInteger("DMI", "DMI Period", "DMI Period", 14, 1, 1000);
	
	 strategy.parameters:addDouble("ADXL", "ADX Level", "ADX Level", 20, 0, 100);
	 strategy.parameters:addDouble("DMIL", " DMI Level", "DMI Level", 20, 0, 100);

   
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
	strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile;

local ADX;
local DMI;

local SHORT, LONG;
local Source = nil; 
local Email;
local SendEmail;

local ADXL;
local DMIL;
local ADXP;
local DMIP;

function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	ADXP = instance.parameters.ADX;
	DMIP = instance.parameters.DMI;
	
	ADXL= instance.parameters.ADXL
    DMIL= instance.parameters.DMIL

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");
	
	SendEmail = instance.parameters.SendEmail;
	 RecurrentSound = instance.parameters.RecurrentSound;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

    SHORT = "Strong Down Trend";	
    LONG = "Strong Up Trend";

    ExtSetupSignal("ADX DMI Alert ", ShowAlert);
	ExtSetupSignalMail(name);

    Source = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

		
	ADX  = core.indicators:create("ADX", Source, ADXP);
	DMI  = core.indicators:create("DMI", Source, DMIP);
    
    local name = profile:id() .. "ADX DMI Alert";
    instance:name(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
	
	
	ADX:update(core.UpdateLast);
	DMI:update(core.UpdateLast);	
	
	
	if period < math.max(ADX.DATA:first(), DMI.DATA:first()) then
	return;
	end
	
   

		 
	                
						if core.crossesOver(DMI.DIP, DMIL, period) and ADX.DATA[period] > ADXL and DMI.DIM[period] < DMI.DIP[period] then
							ExtSignal(Source, period, LONG, SoundFile, Email, RecurrentSound);
						end
						
											 
						if core.crossesOver(DMI.DIM, DMIL, period) and ADX.DATA[period] > ADXL and DMI.DIM[period] > DMI.DIP[period]  then
							ExtSignal(Source, period, SHORT, SoundFile, Email, RecurrentSound);
						end
					
   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
