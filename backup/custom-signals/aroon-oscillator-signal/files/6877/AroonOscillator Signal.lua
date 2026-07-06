-- Id: 2676
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
    strategy:name("AroonOscillator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signal in generated when Aroon Oscillator Cross adjustable Level");

    strategy.parameters:addGroup("Parameters");
 
    strategy.parameters:addInteger("Frame", "Aroom Period", "", 25, 3, 1000);
	 
    strategy.parameters:addInteger("Level", "Alarm Level", "", 50, 0, 100);	
	
		 
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

local Frame, Level;
local AO=nil;

function Prepare()
    -- collect parameters	
	Frame = instance.parameters.Frame;
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

     

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
    assert(core.indicators:findIndicator("AROON OSCILLATOR") ~= nil, "AROON OSCILLATOR" .. " indicator must be installed");
	AO  = core.indicators:create("AROON OSCILLATOR", BarSource, Frame);
	first= AO.DATA:first();
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. Frame .. ", ".. Level  .. ")";
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     AO:update(core.UpdateLast);
		   
		if  period  <  first + 2 or not AO.DATA:hasData(period) then
		return;
		end
			
					if core.crossesOver(AO.DATA, Level,period) then 					
					 ExtSignal(BarSource.close, period, "Top Line CrossOver", SoundFile, Email);
					end 	
					
				
				    if core.crossesUnder(AO.DATA, Level,period) then 					
					 ExtSignal(BarSource.close, period, "Top Line CrossUnder", SoundFile, Email);
					end 	
					
				   
				   
				   if core.crossesOver(AO.DATA, -Level,period) then 					
					 ExtSignal(BarSource.close, period, "Bottom line CrossOver", SoundFile, Email);
					end 	
					
				
				    if core.crossesUnder(AO.DATA, -Level,period) then 					
					 ExtSignal(BarSource.close, period, "Bottom line CrossUnder", SoundFile, Email);
					end 	
			
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
