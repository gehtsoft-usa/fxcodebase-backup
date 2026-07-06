-- Id: 6009
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
    strategy:name("MA Price Cross Signal with RSI Filter");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");


	strategy.parameters:addGroup("MA Parameters");
	strategy.parameters:addString("IN" , "Data Source", "", "close");
    strategy.parameters:addStringAlternative("IN" , "Open", "", "open");
    strategy.parameters:addStringAlternative("IN", "High", "", "high");
    strategy.parameters:addStringAlternative("IN" , "Low", "", "low");
	strategy.parameters:addStringAlternative("IN" , "Close", "", "close");
	strategy.parameters:addStringAlternative("IN", "Median", "", "median");
    strategy.parameters:addStringAlternative("IN" , "Typical", "", "typical");
	strategy.parameters:addStringAlternative("IN" , "Weighted ", "", "weighted");		    			
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
	
	strategy.parameters:addString("PIN" , "Data Source", "", "close");
    strategy.parameters:addStringAlternative("PIN" , "Open", "", "open");
    strategy.parameters:addStringAlternative("PIN", "High", "", "high");
    strategy.parameters:addStringAlternative("PIN" , "Low", "", "low");
	strategy.parameters:addStringAlternative("PIN" , "Close", "", "close");
	strategy.parameters:addStringAlternative("PIN", "Median", "", "median");
    strategy.parameters:addStringAlternative("PIN" , "Typical", "", "typical");
	strategy.parameters:addStringAlternative("PIN" , "Weighted ", "", "weighted");	
	
		strategy.parameters:addGroup("RSI Parameters"); 
	 strategy.parameters:addInteger("RP", "RSI Period", "", 14, 2, 1000);  	
	 strategy.parameters:addDouble("RB", "RSI Buy Level", "", 50, 0, 100);  
 strategy.parameters:addDouble("RS", "RSI Sell Level", "", 50, 0, 100);  	 
	
	strategy.parameters:addString("RIN" , "Data Source", "", "close");
    strategy.parameters:addStringAlternative("RIN" , "Open", "", "open");
    strategy.parameters:addStringAlternative("RIN", "High", "", "high");
    strategy.parameters:addStringAlternative("RIN" , "Low", "", "low");
	strategy.parameters:addStringAlternative("RIN" , "Close", "", "close");
	strategy.parameters:addStringAlternative("RIN", "Median", "", "median");
    strategy.parameters:addStringAlternative("RIN" , "Typical", "", "typical");
	strategy.parameters:addStringAlternative("RIN" , "Weighted ", "", "weighted");	
 
	
	
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

local RP;
local RB, RS;
local ShowAlert;
local SoundFile;
local Email;
local RecurrentSound;
local Frame;
local M;
local Type;
local PIN;
local IN;

local RIN;
local RSI;
local Level;
local first = true;
local tsource = nil;
local indicator = nil;



function Prepare()
     RP = instance.parameters.RP;
     RB = instance.parameters.RB;
	 RS = instance.parameters.RS;
      RIN = instance.parameters.RIN;
	  Level = instance.parameters.Level;
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

     	tsource = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar");
		

		
		
        if M == "FRAMA" then
		indicator= core.indicators:create(M, tsource, Frame);	 
		else
	    indicator= core.indicators:create(M, tsource[IN], Frame);	
        end  	
   
       RSI= core.indicators:create("RSI", tsource[RIN], RP);	 
    first=math.max(RSI.DATA:first(),indicator.DATA:first()  );
end



function ExtUpdate(id, source, period)

		

    if id == 1 and period > first then
        indicator:update(core.UpdateLast);
		RSI:update(core.UpdateLast);
		
        -- check whether the signal appears
        if indicator.DATA:hasData(period - 1) and indicator.DATA:hasData(period) then
		
		
		    if Type == "Cross" then
		
					if  core.crossesUnder(tsource[PIN], indicator.DATA,   period) and RSI.DATA[period] < RS then
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Cross Under", instance.bid:date(NOW));
							end

							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Cross Under", profile:id() .." : ".. instance.bid:instrument()  .." : "..  "MA Price Cross Under")
							end
							
					elseif  core.crossesOver( tsource[PIN], indicator.DATA, period) and RSI.DATA[period] > RB then
						-- switch to long
							if ShowAlert then
								terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Cross Over", instance.bid:date(NOW));
							end
							if SoundFile ~= nil then
								terminal:alertSound(SoundFile, RecurrentSound);
							end
							
							if Email ~= nil then
							terminal:alertEmail (Email, "Cross Over", profile:id() .." : ".. instance.bid:instrument()  .." : "..  "MA Price Cross Over")
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



