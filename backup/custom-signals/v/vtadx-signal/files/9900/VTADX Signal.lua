-- Id: 3703
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
    strategy:name("VTADX Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signal in generated when VTADX  Cross adjustable Level");

    strategy.parameters:addGroup("Parameters");
 
    strategy.parameters:addInteger("FirstPeriod", "First Smoothing periods", "", 14, 1, 100);
    strategy.parameters:addInteger("SecondPeriod", "Second Smoothing periods", "", 14, 1, 100);
	strategy.parameters:addInteger("Level", "Level", "Level", 20, 1, 100);
	
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
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

local first;
local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local Email;
local SendEmail;

local FirstPeriod, SecondPeriod, Level;
local indicator=nil;

function Prepare()
    -- collect parameters	
	FirstPeriod = instance.parameters.FirstPeriod;
	SecondPeriod = instance.parameters.SecondPeriod;
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
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    ExtSetupSignal("VTADX Signal", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	assert(core.indicators:findIndicator("VTADX") ~= nil, "Please, download and install VTADX.LUA indicator");
	
	indicator  = core.indicators:create("VTADX", BarSource, FirstPeriod, SecondPeriod);
	first= indicator.DATA:first();
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. FirstPeriod .. ", " .. SecondPeriod.. ", ".. Level  .. ")";
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	       
     
		   
		if  period  <  first + 1 or id~=1  then
		return;
		end
			
		indicator:update(core.UpdateLast);	
		
		
		
					if core.crossesOver(indicator.DATA, Level,period) then 					
					 ExtSignal(BarSource.close, period, " VTADX have cross over " .. Level .. " Level ", SoundFile, Email);
					end 	
					
				
				    if core.crossesUnder(indicator.DATA, Level,period) then 					
					 ExtSignal(BarSource.close, period, " VTADX have cross under " .. Level .. " Level ", SoundFile, Email);
					end 				
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
