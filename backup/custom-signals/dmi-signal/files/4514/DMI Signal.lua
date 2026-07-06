-- Id: 1649
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
    strategy:name("DMI Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("DMI Signal");

    
	strategy.parameters:addGroup("DMI");
    strategy.parameters:addInteger("dmip", "DMI Period", "DMI Period", 14, 1, 1000);	 
    strategy.parameters:addGroup("Levels");
    strategy.parameters:addInteger("up", "Up Level", "No description", 20, 1, 100);
    strategy.parameters:addInteger("down", "Down Level", "No description", 15, 1, 100);

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local tsource = nil;
local DMI;
local up, down, dmip;
local first;
local UpFlag,DownFlag;
local Flag;

function Prepare()
    local ShowAlert, PlaySound, SendEmail;

    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
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
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

	up = instance.parameters.up;
    down = instance.parameters.down;
	dmip = instance.parameters.dmip;
	 
    local name;
		
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. dmip  .. "," .. up .. "," .. down  .. ")";
    instance:name(name);    

    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);

    ExtSubscribe(1, nil, "t1", true, "close");
end

function ExtUpdate(id, source, period)
    if id == 1 and tsource == nil then
        tsource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
        DMI = core.indicators:create("DMI", tsource, dmip);
        first = DMI.DATA:first() + 1;
    elseif id == 2 and period >= first then
        DMI:update(core.UpdateLast);
		
		if core.crossesUnder(DMI.DIM, up, period) then
        DownFlag= "Neutral";    
        end
		
		if core.crossesOver(DMI.DIM, down, period) then
		DownFlag= "Neutral";
		end
		
		if core.crossesUnder(DMI.DIP, up, period) then
        UpFlag= "Neutral";    
        end
		
		if core.crossesOver(DMI.DIP, down, period) then
		UpFlag= "Neutral";
		end
		
        
		if core.crossesOver(DMI.DIP, up, period) then
		UpFlag= "Buy";
		end
            
        if core.crossesUnder(DMI.DIP, down, period) then
        UpFlag= "Sell";    
        end
		
			
		if core.crossesOver(DMI.DIM, up, period) then
		DownFlag="Sell";
		end
            
        if core.crossesUnder(DMI.DIM, down, period) then
        DownFlag="Buy";    
        end
		

		if  DownFlag == "Buy" and UpFlag == "Buy"  and Flag ~= "Buy" then
		Flag="Buy";
		ExtSignal(instance.bid, instance.bid:size() - 1, "Strong Up Trend", SoundFile, Email);
		elseif  DownFlag == "Sell" and UpFlag == "Sell"  and Flag ~= "Sell" then
		Flag="Sell";
		ExtSignal(instance.bid, instance.bid:size() - 1, "Strong Down Trend", SoundFile, Email);
		end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
