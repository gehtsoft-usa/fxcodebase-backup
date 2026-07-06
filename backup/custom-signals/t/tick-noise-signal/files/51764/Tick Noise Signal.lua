-- Id: 8330
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
    strategy:name("Tick Noise Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameters");
 
   -- strategy.parameters:addInteger("Frame", "Aroom Period", "", 25, 3, 1000);	
		 
    strategy.parameters:addString("Type", "Price Type", "", "Any");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	strategy.parameters:addStringAlternative("Type", "Any", "", "Any");
	 
    strategy.parameters:addString("TYPE", "Alert Type", "", "Any");
    strategy.parameters:addStringAlternative("TYPE", "Value Change", "", "Value");
    strategy.parameters:addStringAlternative("TYPE", "End of Period", "", "Period");
	strategy.parameters:addStringAlternative("TYPE", "Any", "", "Any");

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end
local Type,TYPE;
local first;
local ShowAlert;
local SoundFile;
local Bid = nil;  
local Ask = nil;   
local PlaySound;
local Email;
local SendEmail;
local RecurrentSound;
local LastBid, LastAsk;

function Prepare()
    -- collect parameters	
	Type = instance.parameters.Type;
	TYPE= instance.parameters.TYPE; 
	PlaySound = instance.parameters.PlaySound;   
    ShowAlert = instance.parameters.ShowAlert;
	
   if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
	
	   assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");
	 
   
	 SendEmail = instance.parameters.SendEmail;
	 
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
  
 
 
    if Type ~= "Ask" then
    Bid = ExtSubscribe(1, nil, "t1", true, "close");
	end
	
	if Type ~= "Bid" then
	Ask = ExtSubscribe(2, nil, "t1", false, "close");
	end	
 
    

	  
    local name = profile:id() .. "(" ..  instance.bid:instrument()  .. ")";
    instance:name(name);
 
    ExtSetupSignal("Tick Noise Signal", ShowAlert);
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
	ExtSetupSignalMail(name);	
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
   
		   
	if id == 1 and  Type  ~="Ask" then
		
	 if ((Bid[Bid:size()-1] ~= Bid[Bid:size()-2] )and TYPE~= "Period")
	 or  ( ((Bid:size()-1) ~= (Bid:size()-2))and TYPE~= "Value" and Type =="Bid") 
	 then
	 ExtSignal(Bid, period, "Bid Tick Alert", SoundFile, Email, RecurrentSound);
	 end
	end
	
	
	if id == 2 and  Type ~="Bid" then	
		if (( Ask[Ask:size()-1] ~= Ask[Ask:size()-2] ) and TYPE~= "Period")
		or (((Ask:size()-1) ~= (Ask:size()-2)) and TYPE~= "Value" and Type =="Ask") 
		then
		ExtSignal(Ask, period, "Ask Tick Alert", SoundFile, Email, RecurrentSound);
		end
	end
	
	
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
