-- Id: 4034
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
    strategy:name("Moving Average Envelope Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("N", "Number of periods for Moving Average", "", 14);
    strategy.parameters:addString("MET", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MET", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MET", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MET", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MET", "Wilders*", "", "WMA");

    strategy.parameters:addInteger("B", "Band Width", "", 25);
    strategy.parameters:addString("BWU", "Band Width Units", "", "%");
    strategy.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%");
    strategy.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");
	
		 
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


local N;
local B;
local BWU;
local MET;
local SM;

local IND;

-- Streams block
local MVA = nil;



function Prepare()
    -- collect parameters	
	N = instance.parameters.N;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    MET = instance.parameters.MET;
    SM = instance.parameters.SM;
   
	   
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

    ExtSetupSignal("Moving Average Envelope", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");
	
    assert(core.indicators:findIndicator(MET) ~= nil, MET .. " indicator must be installed");
	IND = core.indicators:create(MET, BarSource, N);
	first=IND.DATA:first();
	
        local name = profile:id() .. "(" ..  instance.bid:instrument()  .. "," .. MET .. "(" .. N .. ")," .. B .. BWU .. ")";
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
	
	if BWU == "%" then
        BWU = 1;
    else
        BWU = 2;
        B = B * source:pipSize();
    end
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     IND:update(core.UpdateLast);
		   
		if  period  <  first + 1  then
		return;
		end
		
		
		
		 local s;

        if BWU == 1 then
            s = IND.DATA[period] * B / 10000;
        else
            s = B;
        end
		
			
					if core.crossesOver(BarSource, IND.DATA[period] + s,  period) then 					
					 ExtSignal(BarSource, period, "Top Line CrossOver", SoundFile, Email);
					end 	
					
				
				    if core.crossesUnder(BarSource, IND.DATA[period] + s, period) then 					
					 ExtSignal(BarSource, period, "Top Line CrossUnder", SoundFile, Email);
					end 	
					
				   
				   
				   if core.crossesOver(BarSource, IND.DATA[period]-s, period) then 					
					 ExtSignal(BarSource, period, "Bottom line CrossOver", SoundFile, Email);
					end 	
					
				
				    if core.crossesUnder(BarSource, IND.DATA[period]-s, period) then 					
					 ExtSignal(BarSource, period, "Bottom line CrossUnder", SoundFile, Email);
					end 	
			
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
