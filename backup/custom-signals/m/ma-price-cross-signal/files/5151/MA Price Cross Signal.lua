-- Id: 2171
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
    strategy:name("MA Price Cross Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("MA Price Cross Signal");


	strategy.parameters:addGroup("MA Parameters");
	strategy.parameters:addInteger("IN" , "Data Source", "", 4);
    strategy.parameters:addIntegerAlternative("IN" , "Open", "", 1);
    strategy.parameters:addIntegerAlternative("IN", "High", "", 2);
    strategy.parameters:addIntegerAlternative("IN" , "Low", "", 3);
	strategy.parameters:addIntegerAlternative("IN" , "Close", "", 4);
	strategy.parameters:addIntegerAlternative("IN", "Median", "", 5);
    strategy.parameters:addIntegerAlternative("IN" , "Typical", "", 6);
	strategy.parameters:addIntegerAlternative("IN" , "Weighted ", "", 7);		    			
	strategy.parameters:addString("M" , "Method for avegage", "", "EMA");
    strategy.parameters:addStringAlternative("M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("M", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("M", "Wilders*", "", "WMA");
	strategy.parameters:addStringAlternative("M" , "FRAMA", "", "FRAMA");
				
    strategy.parameters:addInteger("Frame", "MA Frame", "", 50, 2, 1000);  

 
    strategy.parameters:addGroup("Cross Type"); 
    strategy.parameters:addString("Type" , "Method of Cross", "", "Cross");
    strategy.parameters:addStringAlternative("Type" , "Cross", "", "Cross");
    strategy.parameters:addStringAlternative("Type", "Touch", "", "Touch");
	
	
	strategy.parameters:addGroup("Price Type"); 
	
	strategy.parameters:addInteger("PIN" , "Data Source", "", 4);
    strategy.parameters:addIntegerAlternative("PIN" , "Open", "", 1);
    strategy.parameters:addIntegerAlternative("PIN", "High", "", 2);
    strategy.parameters:addIntegerAlternative("PIN" , "Low", "", 3);
	strategy.parameters:addIntegerAlternative("PIN" , "Close", "", 4);
	strategy.parameters:addIntegerAlternative("PIN", "Median", "", 5);
    strategy.parameters:addIntegerAlternative("PIN" , "Typical", "", 6);
	strategy.parameters:addIntegerAlternative("PIN" , "Weighted ", "", 7);	
 
	
	
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
local Frame;
local M;
local Type;
local PIN;



function Prepare()
    IN = instance.parameters.IN;
    PIN = instance.parameters.PIN;
    Type = instance.parameters.Type;
    M = instance.parameters.M;
    Frame = instance.parameters.Frame;
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
    assert(core.indicators:findIndicator(M) ~= nil, "Please download and install ".. M .." Indicator!");

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
local PRICE;
local DATA;

function ExtUpdate(id, source, period)
    if id == 1 and first then
        first = false;
	
		tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
		
		
		if PIN == 1 then
		PRICE = tsource.open;		
		elseif PIN==2 then
		PRICE = tsource.high;	
		elseif PIN==3 then
		PRICE = tsource.low;	
		elseif PIN==4 then
		PRICE = tsource.close;	
		elseif PIN==5 then
		PRICE = tsource.median;	
		elseif PIN==6 then
		PRICE = tsource.typical;	
		elseif PIN==7 then
		PRICE = tsource.weighted;	
		end
		
		
		
		if IN == 1 then
		DATA = tsource.open;		
		elseif IN==2 then
		DATA = tsource.high;	
		elseif IN==3 then
		DATA = tsource.low;	
		elseif IN==4 then
		DATA = tsource.close;	
		elseif IN==5 then
		DATA = tsource.median;	
		elseif IN==6 then
		DATA = tsource.typical;	
		elseif IN==7 then
		DATA = tsource.weighted;
		end
		
        if M == "FRAMA" then
		indicator= core.indicators:create(M, tsource, Frame);	 
		else
	    indicator= core.indicators:create(M, DATA, Frame);	
        end  		

    elseif id == 2 and period > 1 then
        indicator:update(core.UpdateLast);
		
        -- check whether the signal appears
        if indicator.DATA:hasData(period - 1) and indicator.DATA:hasData(period) then
		
		
		    if Type == "Cross" then
		
					if  core.crossesUnder(PRICE, indicator.DATA,   period) then
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Cross Under", instance.bid:date(NOW));
							end

							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Cross Under", profile:id() .." : ".. instance.bid:instrument()  .." : "..  "MA Price Cross Under")
							end
							
					elseif  core.crossesOver( PRICE, indicator.DATA, period) then
						-- switch to long
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Cross Over", instance.bid:date(NOW));
							end
							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Cross Over", profile:id() .." : ".. instance.bid:instrument()  .." : ".. "MA Price Cross Over")
							end
							
					end
			else
			
			     
							
					       if  tsource.high[period] > indicator.DATA[period] and tsource.low[period] < indicator.DATA[period] then
						   
									-- switch to long
										if ShowAlert then
											terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Touch", instance.bid:date(NOW));
										end
										if SoundFile ~= nil then
											terminal:alertSound(SoundFile, RecurrentSound);
										end
										
										if Email ~= nil then
										terminal:alertEmail (Email, profile:id() .." : ".. instance.bid:instrument()  .." : "..  "MA Price Touch", "MA Price Touch")
										end
										
							end
							
					
			
            end			
		end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



