-- Id: 6816
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("MA Price Cross Touch Signal");
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

   
   
	strategy.parameters:addString("M1" , "Method for First Aegage", "", "EMA");
    strategy.parameters:addStringAlternative("M1", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("M1", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("M1", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("M1", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("M1", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("M1", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("M1", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("M1", "Wilders*", "", "WMA");
	strategy.parameters:addStringAlternative("M1" , "FRAMA", "", "FRAMA");
	
	
	
	strategy.parameters:addString("M2" , "Method for Second Avegage", "", "EMA");
    strategy.parameters:addStringAlternative("M2", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("M2", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("M2", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("M2", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("M2", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("M2", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("M2", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("M2", "Wilders*", "", "WMA");
	strategy.parameters:addStringAlternative("M2" , "FRAMA", "", "FRAMA");
	
				
    strategy.parameters:addInteger("Frame1", "MA Frame", "", 100, 2, 1000);  
	 strategy.parameters:addInteger("Frame2", "MA Frame", "", 200, 2, 1000);  
	 
	 strategy.parameters:addString("Confirmation" , "Confirmation Type", "", "Both");
    strategy.parameters:addStringAlternative("Confirmation" , "Any", "", "Both");
    strategy.parameters:addStringAlternative("Confirmation", "First MA", "", "One");
    strategy.parameters:addStringAlternative("Confirmation" , "Second MA", "", "Two");
	 --strategy.parameters:addStringAlternative("Confirmation" , "Don't use Confirmation", "", "No");

 
    strategy.parameters:addGroup("Cross Type"); 
    strategy.parameters:addString("CrossType" , "Method of Cross", "", "Cross");
    strategy.parameters:addStringAlternative("CrossType" , "Cross", "", "Cross");
    strategy.parameters:addStringAlternative("CrossType", "Touch", "", "Touch");
	
	
	strategy.parameters:addGroup("Price Type"); 

	
	strategy.parameters:addString("PIN" , "Data Source", "", "close");
    strategy.parameters:addStringAlternative("PIN" , "Open", "", "open");
    strategy.parameters:addStringAlternative("PIN", "High", "", "high");
    strategy.parameters:addStringAlternative("PIN" , "Low", "", "low");
	strategy.parameters:addStringAlternative("PIN" , "Close", "", "close");
	strategy.parameters:addStringAlternative("PIN", "Median", "", "median");
    strategy.parameters:addStringAlternative("PIN" , "Typical", "", "typical");
	strategy.parameters:addStringAlternative("PIN" , "Weighted ", "", "weighted");	
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
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
local CrossType;
local Frame1, Frame2;
local M1, M2;
local Type;
local PIN;
local indicator={};
local Confirmation;
local RecurrentSound;
function Prepare()
    -- collect parameters		
	IN = instance.parameters.IN;
    PIN = instance.parameters.PIN;
    Type = instance.parameters.Type;
    M1 = instance.parameters.M1;
	M2 = instance.parameters.M2;
    Frame1 = instance.parameters.Frame1;
	Frame2 = instance.parameters.Frame2;
   Confirmation = instance.parameters.Confirmation;
   RecurrentSound = instance.parameters.RecurrentSound;
   CrossType = instance.parameters.CrossType;
	   
    ShowAlert = instance.parameters.ShowAlert;
	
	 SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
   
	   
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
	assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");   
    assert(core.indicators:findIndicator(M1) ~= nil, "Please download and install ".. M1 .." Indicator!");
	assert(core.indicators:findIndicator(M2) ~= nil, "Please download and install ".. M2 .." Indicator!");
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

 

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
    	 if M1 == "FRAMA" then
		indicator[1]= core.indicators:create(M1, BarSource, Frame1);	 
		else
	    indicator[1]= core.indicators:create(M1, BarSource[IN], Frame1);	
        end  		
		
		 if M2 == "FRAMA" then
		indicator[2]= core.indicators:create(M2, BarSource, Frame2);	 
		else
	    indicator[2]= core.indicators:create(M2, BarSource[IN], Frame2);	
        end  		
		
		
	first= math.max(indicator[1].DATA:first(), indicator[2].DATA:first())+1;
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. Frame1 .. ", ".. M1.. ", " .. Frame2 .. ", ".. M2  .. ")";
         instance:name(name);
  
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     
	 if period < first  or id ~= 1 then
	 return;
	 end
	 
	 indicator[1]:update(core.UpdateLast);
	 indicator[2]:update(core.UpdateLast);  
		
		
		    if CrossType == "Cross" then		
				
					if  (core.crossesUnder(BarSource[PIN], indicator[1].DATA,  period) and Confirmation~="Two")
					or (core.crossesUnder(BarSource[PIN], indicator[2].DATA,  period) and Confirmation~="One")
					
					then
							Signal ("MA Price Cross Touch Signal",  "CrossUnder");
							
					elseif  (core.crossesOver(BarSource[PIN], indicator[1].DATA,  period) and Confirmation~="Two")
					or (core.crossesOver(BarSource[PIN], indicator[2].DATA,  period) and Confirmation~="One")
				
					then						
							Signal ("MA Price Cross Touch Signal",  "CrossOver");
							
					end
			elseif CrossType =="Touch" then						     				 
					       if     (BarSource.high[period] > indicator[1].DATA[period] and BarSource.low[period] < indicator[1].DATA[period]	and Confirmation~="Two")
                           or  (BarSource.high[period] > indicator[2].DATA[period] and BarSource.low[period] < indicator[2].DATA[period]	and Confirmation~="One")						   
						   then						   									
										 
										Signal ("MA Price Touch", "MA Price Touch");
										
							end
							
						
							
							
					
			
            end			
						  
							   
end

 function Signal (Name, Label)
 
   
    local period =BarSource.close:size()-1;
    local date = BarSource:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  "  Alert : " .. Label ;  
   local Symbol= "  Instrument : " .. BarSource:instrument() ;
   local Time =  "  Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
    local TF= "  Time Frame : " .. BarSource:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
  
	   
   
   
    if ShowAlert then
        terminal:alertMessage( BarSource:instrument(), BarSource.close[period],  text, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, Name,text);
    end
end		 

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");