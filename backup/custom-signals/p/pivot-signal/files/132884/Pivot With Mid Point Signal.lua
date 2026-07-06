-- Id: 2593
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
    strategy:name("Pivot Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Pivot Signal");


	strategy.parameters:addGroup("Pivot Parameters");
	
	strategy.parameters:addString("BS", "The Time Frame For Pivots", "", "D1");
    strategy.parameters:setFlag("BS", core.FLAG_PERIODS);

    strategy.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot");
    strategy.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    strategy.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    strategy.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    strategy.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    strategy.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR");
   
   
    strategy.parameters:addBoolean("showR1", "Show R1", "", true);
    strategy.parameters:addBoolean("showR2", "Show R2", "", true);
    strategy.parameters:addBoolean("showR3", "Show R3", "", true);
	strategy.parameters:addBoolean("showR4", "Show R4", "", true);
	
    strategy.parameters:addBoolean("showS1", "Show S1", "", true);
    strategy.parameters:addBoolean("showS2", "Show S2", "", true);
    strategy.parameters:addBoolean("showS3", "Show S3", "", true);
    strategy.parameters:addBoolean("showS4", "Show S4", "", true);
 
	
	strategy.parameters:addBoolean("showM1", "Show 1. Mid", "", true);
    strategy.parameters:addBoolean("showM2", "Show 2. Mid", "", true);
	strategy.parameters:addBoolean("showM3", "Show 3. Mid", "", true);
	strategy.parameters:addBoolean("showM4", "Show 4. Mid", "", true);
	strategy.parameters:addBoolean("showM5", "Show 5. Mid", "", true);
	strategy.parameters:addBoolean("showM6", "Show 6. Mid", "", true);
	
	
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

local tsource = nil;
local indicator = nil;

function Prepare(nameOnly)      
   
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
   

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF ..  ")";
    instance:name(name);

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	  if nameOnly then
        return ;
    end
	
    tsource = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar"); 
	
	
    assert(core.indicators:findIndicator("PIVOT WITH MID POINT") ~= nil, "Please, download and install PIVOT WITH MID POINT.LUA indicator");
	
	local iprofile = core.indicators:findIndicator("PIVOT WITH MID POINT");
    local iparams = iprofile:parameters();
		
	iparams:setString("BS", instance.parameters:getString("BS"));
	iparams:setString("CalcMode", instance.parameters:getString("CalcMode"));
	iparams:setString("ShowMode", "HIST");
	
	
	iparams:setBoolean("ShowMP", true);
	
	iparams:setBoolean("showR1", true); 
    iparams:setBoolean("showR2", true);  
    iparams:setBoolean("showR3", true);  
    iparams:setBoolean("showR4", true);   
	
	iparams:setBoolean("showS1", true); 
    iparams:setBoolean("showS2", true);  
    iparams:setBoolean("showS3", true);  
    iparams:setBoolean("showS4", true);
	
	indicator = iprofile:createInstance(tsource, iparams);
end





function ExtUpdate(id, source, period)
    if id ~= 1 and  period < 1  then  
    return;
    end	

    
        indicator:update(core.UpdateLast);
		
		if not indicator.P:hasData(period) then
		return;
		end
		
		if  indicator.P:hasData(period) then
        Alert ("P", indicator.P[period], period);
		end
		if instance.parameters:getBoolean("showR1")   then
	    Alert ("R1", indicator.R1[period], period);
		end
		if   instance.parameters:getBoolean("showR2")  then
		Alert ("R2", indicator.R2[period], period);	
		end
		if  instance.parameters:getBoolean("showR3")   then
 		Alert ("R3", indicator.R3[period], period);
		end
		
		if   instance.parameters:getBoolean("showR4")  then
 		Alert ("R4", indicator.R4[period], period);
		end
		
		if   instance.parameters:getBoolean("showS1")  then
		Alert ("S1", indicator.S1[period], period);
		end
		if    instance.parameters:getBoolean("showS2")   then
		Alert ("S2", indicator.S2[period], period);
		end
		
		if    instance.parameters:getBoolean("showS3")   then
		Alert ("S3", indicator.S3[period], period);
		end
		
		if   instance.parameters:getBoolean("showS4")  then
		Alert ("S4", indicator.S4[period], period);
		end
		
		
		--//////////////////////////////////////////////////////////////////
		
		if   instance.parameters:getBoolean("showM1")  then
		Alert ("M0", indicator.MID1[period], period);
		end
		
		
		if   instance.parameters:getBoolean("showM2")  then
		Alert ("M1", indicator.MID2[period], period);
		end
		
		
		if   instance.parameters:getBoolean("showM3")  then
		Alert ("M2", indicator.MID3[period], period);
		end
		
		
		if   instance.parameters:getBoolean("showM4")  then
		Alert ("M3", indicator.MID4[period], period);
		end
		
		if   instance.parameters:getBoolean("showM5")  then
		Alert ("M4", indicator.MID5[period], period);
		end
		
		
		if   instance.parameters:getBoolean("showM6")  then
		Alert ("M5", indicator.MID6[period], period);
		end
		
		
end



function Alert (name, data, period)


		if data == nil then
        return;
        end 
							
					       if  tsource.high[period] >data and tsource.low[period] < data then
						   
						   
						            if  core.crossesOver( tsource.close, data , period) then 
									
								     	if ShowAlert then
										terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], name .. " Cross Over", instance.bid:date(NOW));
										end
										if SoundFile ~= nil then
											terminal:alertSound(SoundFile, RecurrentSound);
										end
										
										if Email ~= nil then
										terminal:alertEmail (Email, name .." Cross Over", instance.bid:instrument(), instance.bid[NOW],  name .. " Cross Over", instance.bid:date(NOW))
										end
									
						            elseif  core.crossesUnder( tsource.close, data , period) then 
									
									    if ShowAlert then
										terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], name .." Cross Under", instance.bid:date(NOW));
										end
										if SoundFile ~= nil then
											terminal:alertSound(SoundFile, RecurrentSound);
										end
										
										if Email ~= nil then
										terminal:alertEmail (Email, name .." Cross Under", instance.bid:instrument(), instance.bid[NOW],  name .." Cross Under", instance.bid:date(NOW))
										end
						   
						            else
									-- switch to long
										if ShowAlert then
											terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], name .." Touch", instance.bid:date(NOW));
										end
										if SoundFile ~= nil then
											terminal:alertSound(SoundFile, RecurrentSound);
										end
										
										if Email ~= nil then
										terminal:alertEmail (Email, name .." Touch", instance.bid:instrument(), instance.bid[NOW], name .. " Touch", instance.bid:date(NOW))
										end
									end
							end

end
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



