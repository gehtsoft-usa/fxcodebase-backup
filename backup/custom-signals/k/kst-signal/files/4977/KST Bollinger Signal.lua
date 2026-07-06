-- Id: 3410
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
    strategy:name("KST Bollinger Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");


    strategy.parameters:addGroup("KST Parameters");
    AddParam(1, "First", 9, 6);
    AddParam(2, "Second", 12, 6);
    AddParam(3, "Third", 18, 6);
    AddParam(4, "Fourth", 24, 9);
    AddParam("S", "Signal", nil, 9);

	strategy.parameters:addGroup("BB Parameters");
    strategy.parameters:addInteger("N", "Number of periods", "", 20, 1, 10000);
    strategy.parameters:addDouble("Dev", "Number of standard deviations", "", 2.0, 0.0001, 1000.0);
	
    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);
	
	strategy.parameters:addGroup("Email Parameters");
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

local ShowAlert;
local SoundFile;
local Email;
local RecurrentSound;

function Prepare()
    RecurrentSound= instance.parameters.Recurrent;
    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");


    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    assert(not(instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""), "Sound file must be chosen");
    assert(core.indicators:findIndicator("KST") ~= nil, "Please download and install KST Indicator!");

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF ..  ")";
    instance:name(name);

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    ExtSubscribe(1, nil, "t1", true, "close");
end

local first = true;
local tsource = nil;
local indicator = nil;
local indicator2 = nil;

function ExtUpdate(id, source, period)
    if id == 1 and first then
        first = false;
        tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
        local iprofile = core.indicators:findIndicator("KST");
        local iparams = iprofile:parameters();
		local i;
				 for i = 1, 4, 1 do		
							if i~= 4 then
							iparams:setInteger("ROC"..i, instance.parameters:getInteger("ROC"..i));   
							end				
				iparams:setInteger("MA"..i, instance.parameters:getInteger("MA"..i));        
				iparams:setString("MET"..i, instance.parameters:getString("MET"..i));
				end 		
        indicator = iprofile:createInstance(tsource.close, iparams);	
		
		
		local iprofile2 = core.indicators:findIndicator("BB");
        local iparams2 = iprofile2:parameters();		
		iparams2:setInteger("N", instance.parameters:getInteger("N"));        
		iparams2:setDouble("Dev", instance.parameters:getDouble("Dev"));		 		
        indicator2 = iprofile2:createInstance(indicator.KST, iparams2);
		
    elseif id == 2 and period > 1 then
        indicator:update(core.UpdateLast);
		indicator2:update(core.UpdateLast);
        -- check whether the signal appears
        if indicator.KST:hasData(period - 1) and indicator2.TL:hasData(period - 1) then
		
					if  core.crossesUnder(indicator.KST, indicator2.BL, period) then
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
							end

							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Enter Short", "KST have give Enter Short signal")
							end
							
					elseif  core.crossesOver(indicator.KST, indicator2.TL, period) then
						-- switch to long
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
							end
							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Enter Long", "KST have give Enter Long signal")
							end
							
					end
		end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



