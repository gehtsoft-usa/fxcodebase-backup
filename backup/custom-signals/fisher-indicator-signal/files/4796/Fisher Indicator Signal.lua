-- Id: 1875
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
    strategy:name("Fisher Indicator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Fisher Indicator Signal");

    strategy.parameters:addGroup("Fisher Indicator Parameters");
    strategy.parameters:addInteger("RangePeriods", "RangePeriods", "RangePeriods", 35);
    strategy.parameters:addDouble("PriceSmoothing", "PriceSmoothing", "PriceSmoothing", 0.3, 0, 0.9999);
    strategy.parameters:addDouble("IndexSmoothing", "IndexSmoothing", "IndexSmoothing", 0.3, 0, 0.9999);
    

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
    assert(core.indicators:findIndicator("FISHER_M11") ~= nil, "Please download and install Fisher Indicator!");

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

function ExtUpdate(id, source, period)
    if id == 1 and first then
        first = false;
        tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
        local iprofile = core.indicators:findIndicator("FISHER_M11");
        local iparams = iprofile:parameters();
        iparams:setInteger("RangePeriods", instance.parameters:getInteger("RangePeriods"));    
		iparams:setDouble("PriceSmoothing", instance.parameters:getDouble("PriceSmoothing"));        
		iparams:setDouble("IndexSmoothing", instance.parameters:getDouble("IndexSmoothing"));        		
        indicator = iprofile:createInstance(tsource, iparams);
    elseif id == 2 and period > 1 then
        indicator:update(core.UpdateLast);
        -- check whether the signal appears
        if not(indicator.DN:hasData(period - 1)) and indicator.DN:hasData(period) then
            -- switch to short
                if ShowAlert then
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
                end

                if SoundFile ~= nil then
                    terminal:alertSound(SoundFile, RecurrentSound);
                end
				
				if Email ~= nil then
				terminal:alertEmail (Email, "Enter Short", "Fisher Indicator have give Enter Short signal")
				end
				
        elseif not(indicator.UP:hasData(period - 1)) and indicator.UP:hasData(period) then
            -- switch to long
                if ShowAlert then
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
                end
                if SoundFile ~= nil then
                    terminal:alertSound(SoundFile, RecurrentSound);
                end
				
				if Email ~= nil then
				terminal:alertEmail (Email, "Enter Short", "Fisher Indicator have give Enter Long signal")
				end
				
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



