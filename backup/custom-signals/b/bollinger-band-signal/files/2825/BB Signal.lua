-- Id: 1005
--+------------------------------------------------------------------+
--|                                                   BB Signal.lua  |
--|                               Copyright © 2015, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                                  Donate/Support  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--|                    BitCoin : 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Bollinger Band Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Bollinger Band Signal");

    strategy.parameters:addGroup("Parameters");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	 strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
	
	strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn");
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn");
	strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live");
	

	
	strategy.parameters:addGroup("Calculation");
	strategy.parameters:addInteger("NOP", "Number of periods", "Number of periods", 20, 2, 1000);
    strategy.parameters:addDouble("NOSD", "Number of standard deviations", "Number of standard deviations", 2, 0, 100);

	
   
  
	
	strategy.parameters:addGroup("Selector");
		strategy.parameters:addString("CROSS", "Cross Type", "", "CROSS");
    strategy.parameters:addStringAlternative("CROSS", "Cross", "", "CROSS");
    strategy.parameters:addStringAlternative("CROSS", "Touch", "", "TOUCH");
	strategy.parameters:addStringAlternative("CROSS", "Both", "", "BOTH");
	
		strategy.parameters:addBoolean("IN", "Show Bollinger Band Break In", "Show Bollinger Band Break In", true);
	strategy.parameters:addBoolean("OUT", "Show Bollinger Band Break Out", "Show Bollinger Band Break Out", true);
	strategy.parameters:addBoolean("CENTRAL", "Show Cental Line Cross Over", "Show Cental Line Cross Over", true);

    strategy.parameters:addGroup("Signals");

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

local Email;
local RecurrentSound;
local SoundFile;
local CROSS;
local first;
local Frame;
local Deviations;
local IN;
local OUT;
local CENTRAL
local ONE;
local BB;
local SMA;
local ExecutionType;
local CrossesOver, CrossesIn, CrossesOut;
local TickSource,Source; 


function Prepare()
    RecurrentSound= instance.parameters.Recurrent;
	ExecutionType= instance.parameters.ExecutionType;
	
	local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
    CROSS = instance.parameters.CROSS;
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	Frame = instance.parameters.NOP;
	Deviations = instance.parameters.NOSD;
	IN = instance.parameters.IN;
	OUT = instance.parameters.OUT;
	CENTRAL =  instance.parameters.CENTRAL;
   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

  
    Source = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	if ExecutionType== "Live" then
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
	end

	
	BB  = core.indicators:create("BB",Source.close, Frame, Deviations );
	SMA  = core.indicators:create("MVA", Source.close, Frame);
	
	first=math.max(BB.DATA:first(), SMA.DATA:first())+1;
	    
    local name = profile:id() .. "Bollinger Band";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)
  
	if  ExecutionType ==  "Live" and  id == 1 then
			
			period= core.findDate (Source.close, TickSource:date(period), false );		
					
	end

	if  ExecutionType ==  "Live"  then
	
	        if ONE == Source:serial(period) then
			return;
			end
	
			if id == 2 then
			return;
			end		
			
			
		
	else	
			if id ~= 2 then       
			return;
			end
	end

	
	BB:update(core.UpdateLast);
	SMA:update(core.UpdateLast);
	
	if period < first then
	return;
	end
	
  
	
	                
			if  CROSS == "CROSS" then 						
					if IN then 
					
														
							if core.crossesOver(Source.close, BB.TL , period) then
							 ALERT ("Bollinger Band Signal", " Top Line Cross Over", period);
							end
							
							
							if core.crossesUnder( Source.close, BB.BL, period) then
							ALERT ("Bollinger Band Signal", " Bottom  Line Cross Under", period);
							end
							
							
					
					end 
					
					if OUT then 
					
					        if core.crossesOver(Source.close, BB.BL , period) then
							 ALERT ("Bollinger Band Signal", "  Bottom Line Cross Over", period);
							end
					
							
							if core.crossesUnder( Source.close, BB.TL, period) then
							 ALERT ("Bollinger Band Signal", " Top Line Cross Under", period);
							end
							
					end
					
					if CENTRAL then
					
					        if core.crossesOver( Source.close, SMA.DATA, period) then
							ALERT ("Bollinger Band Signal", " Central Line Cross Over", period);
							end
					
							
							if core.crossesUnder(Source.close, SMA.DATA, period) then
							ALERT ("Bollinger Band Signal", "  Central Line Cross Under", period);
							end
											
					end
					
            elseif CROSS == "TOUCH" then
			 
			        if IN then 
					
														
							 if Source.high[period] > BB.TL[period] and Source.low[period] < BB.TL[period]then
							 ALERT ("Bollinger Band Signal", " Top Line Touch", period);
							end
							
							
							 if Source.high[period] > BB.BL[period] and Source.low[period] < BB.BL[period]then
							 ALERT ("Bollinger Band Signal", " Bottom Line Touch", period);	
							end
					
					end 
					
			
					
					if CENTRAL then
					
					       
					     if Source.high[period] > SMA.DATA[period] and Source.low[period] < SMA.DATA[period]then
							 ALERT ("Bollinger Band Signal", "  Central Line Touch", period);
						end
							
							
											
					end       
			 else		
			 
			     	if IN then 
					
														
							if core.crossesOver( Source.close, BB.TL, period) then
							ALERT ("Bollinger Band Signal", "Top Line Cross Over", period);
							end
							
							
							if core.crossesUnder(Source.close, BB.BL,  period) then
							 ALERT ("Bollinger Band Signal", " Bottom Line Cross Under", period);
							end
					
					end 
					
					if OUT then 
					
					        if core.crossesOver(Source.close,  BB.BL, period) then
							ALERT ("Bollinger Band Signal", " Bottom Line Cross Over", period);
							end
					
							
							if core.crossesUnder(Source.close, BB.TL,  period) then
							 ALERT ("Bollinger Band Signal", "Top Line Cross Under", period);
							end
							
					end
					
					if CENTRAL then
					
					        if core.crossesOver( Source.close, SMA.DATA, period) then
							ALERT ("Bollinger Band Signal", "Central Line Cross Over", period);
							end
					
							
							if core.crossesUnder( Source.close,  SMA.DATA, period) then
							ALERT ("Bollinger Band Signal", "Central Line Cross Under", period);
							end
											
					end
			 
			 
			 
			     if IN then 
					
														
							 if Source.high[period] > BB.TL[period] and Source.low[period] < BB.TL[period]then
							 ALERT ("Bollinger Band Signal", " Top Line Touch", period);
							end
							
							
							 if Source.high[period] > BB.BL[period] and Source.low[period] < BB.BL[period]then
							 ALERT ("Bollinger Band Signal", "Bottom Line Touch", period);							 
							 end
					
					end 
					
					
					if CENTRAL then				
					       
					        if Source.high[period] > SMA.DATA[period] and Source.low[period] < SMA.DATA[period]then
							ALERT ("Bollinger Band Signal", "Central Line Touch", period);
							end				
					end       
			 		
             end			
                  
     
end



function ALERT(Label,Subject, period)

    ONE= Source:serial(period);
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label .. " : " .. Subject , instance.bid:date(NOW));
    end
	
	
    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
     		
	   local date = instance.bid:date(NOW)
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..Label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. instance.bid:instrument()
   local TF= "Time Frame : " .. Source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	 terminal:alertEmail(Email, Label, text);
    end
end


dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
