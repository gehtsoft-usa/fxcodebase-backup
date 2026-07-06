-- Id: 1651
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
    strategy:name("Know Sure Thing Oscillator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Know Sure Thing Oscillator Signal");

    
	AddParam(1, "First", 9, 6);
    AddParam(2, "Second", 12, 6);
    AddParam(3, "Third", 18, 6);
    AddParam(4, "Fourth", 24, 9);
    AddParam(5, "Signal", nil, 9);

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

function AddParam(id, name, defROC, defMA)
    if defROC ~= nil then
        strategy.parameters:addInteger("ROC" .. id, name .. " ROC Periods", "", defROC, 2, 300);
    end
    strategy.parameters:addInteger("MA" .. id, name .. " MA Periods", "The methods marked with (*) must be downloaded and installed", defMA, 1, 300);
    strategy.parameters:addString("MET" .. id, name .. " Method", "", "MVA");
    strategy.parameters:addStringAlternative("MET" .. id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MET" .. id, "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MET" .. id, "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MET" .. id, "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("MET" .. id, "SMMA(*)", "", "SMMA");
    strategy.parameters:addStringAlternative("MET" .. id, "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MET" .. id, "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MET" .. id, "Wilders*", "", "WMA");
end

local tsource = nil;
local KST=nil;
local RP={};
local MP={};
local MT={};
local first;
local Email;

function Prepare()
    local ShowAlert, PlaySound, SendEmail;
	local i;
	    for i = 1, 5, 1 do
			if i ~= 5 then
			RP[i] = instance.parameters:getInteger("ROC" .. i);
			end
        MP[i] = instance.parameters:getInteger("MA" .. i);
        MT[i] = instance.parameters:getString("MET" .. i);
        
	    end 
		
		assert(core.indicators:findIndicator("KST") ~= nil, "Please, download and install KST.LUA indicator");
		
		for i = 1 , 5 , 1 do
	    assert(core.indicators:findIndicator(MT[i]) ~= nil, "Please, download and install ".. MT[i]  .. " indicator");
		end

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

    local name;		
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]".. ")";
    instance:name(name);    

    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);

    ExtSubscribe(1, nil, "t1", true, "close");
end

function ExtUpdate(id, source, period)
    if id == 1 and tsource == nil then
        tsource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
        KST = core.indicators:create("KST", tsource.close,  RP[1],  MP[1],  MT[1],  RP[2],  MP[2],  MT[2],  RP[3],  MP[3],  MT[3],  RP[4],  MP[4],  MT[4], MP[5],  MT[5]  );
  
      first = KST.SIG:first() + 1;
     elseif id == 2 and period >= first then
     
        KST:update(core.UpdateLast);
		
		if core.crossesUnder(KST.KST, KST.SIG, period) then
        ExtSignal(instance.bid, instance.bid:size() - 1, "Strong Down Trend", SoundFile, Email);   
        end
		
		if core.crossesOver(KST.KST, KST.SIG, period) then
		ExtSignal(instance.bid, instance.bid:size() - 1, "Strong Up Trend", SoundFile, Email);
		end
		
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
