-- Id: 19250


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=2344

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Smothed Heikin-Ashi Top/Bottom");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Smothed Heikin-Ashi Top/Bottom");

    
	strategy.parameters:addGroup("Heikin-Ashi Smoothed");
    strategy.parameters:addString("Method1", "The smoothing method for prices", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    strategy.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method1", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("Method1", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("Method1", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("Method1", "Wilders*", "", "WMA");
	
	strategy.parameters:addInteger("N1", "Periods to smooth prices", "", 6, 1, 1000);

    strategy.parameters:addString("Method2", "The smoothing method for candles", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    strategy.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method2", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("Method2", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("Method2", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("Method2", "Wilders*", "", "WMA");

    strategy.parameters:addInteger("N2", "Periods to smooth candles", "", 6, 1, 1000);

	
    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
   -- strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

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
    assert(core.indicators:findIndicator("HASM") ~= nil, "Please download and install HASM Indicator!");

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

function FRACTAL (p)

    if (p > 6) then
        local curr = indicator.high[p - 2];
        if (curr > indicator.high[p - 4] and curr > indicator.high[p - 3] and
            curr > indicator.high[p - 1] and curr > indicator.high[p]) then
			SHORT(); 
        end
        curr = indicator.low[p - 2];
        if (curr < indicator.low[p - 4] and curr < indicator.low[p - 3] and
            curr < indicator.low[p - 1] and curr < indicator.low[p]) then           
		   LONG(); 
        end
    end

end

function ExtUpdate(id, source, period)
    if id == 1 and first then
        first = false;
        tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
        local iprofile = core.indicators:findIndicator("HASM");
        local iparams = iprofile:parameters();
				
		iparams:setString("Method1", instance.parameters:getString("Method1"));  
        iparams:setInteger("N1", instance.parameters:getInteger("N1"));		
		iparams:setString("Method2", instance.parameters:getString("Method2"));
		iparams:setInteger("N2", instance.parameters:getInteger("N2"));				
        indicator = iprofile:createInstance(tsource, iparams);	
		
    elseif id == 2 and period > 1 then
        indicator:update(core.UpdateLast);
					
		FRACTAL (period);					
		
    end
end

function SHORT() 

		if ShowAlert then
		terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Top", instance.bid:date(NOW));
		end

		if SoundFile ~= nil then
		terminal:alertSound(SoundFile, RecurrentSound);
		end
									
		if Email ~= nil then
		terminal:alertEmail (Email, "Enter Short", "Smothed Heikin-Ashi have give Top signal , "   .. source:instrument() ..  ", "   .. source:barSize() )
		end
	
end

function LONG()

		if ShowAlert then
		terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Bottom", instance.bid:date(NOW));
		end
		if SoundFile ~= nil then
		terminal:alertSound(SoundFile, RecurrentSound);
		end
									
		if Email ~= nil then
		terminal:alertEmail (Email, "Enter Long", "Smothed Heikin-Ashi have give Bottom signal , "   .. source:instrument() ..  ", "   .. source:barSize() )
		end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



