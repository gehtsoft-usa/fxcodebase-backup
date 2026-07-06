-- Id: 4459
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
    strategy:name("Acceleration Bands Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signal in generated when  Price cross AB Band");

    strategy.parameters:addGroup("Parameters");
 
   strategy.parameters:addInteger("TF", "Period", "Period", 20,2,2000); 
    strategy.parameters:addDouble("CF", "Factor", "Factor", 0.001);
	
	 
  
	
	strategy.parameters:addGroup("Price");	 
	 strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
	
	  strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
		
	   
    strategy.parameters:addGroup("Signals");
	
	 strategy.parameters:addString("Mode", "Signal Mode", "Cross", "Cross");
	  strategy.parameters:addStringAlternative("Mode", "Cross", "", "Cross");
    strategy.parameters:addStringAlternative("Mode", "Touch", "", "Touch");
    strategy.parameters:addStringAlternative("Mode", "Both", "", "Both");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	 strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end
local Mode;
local first;
local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local Email;
local SendEmail;

local Factor=nil;
local Frame=nil;
local AB;
local RecurrentSound;

function Prepare()
    -- collect parameters	
	Mode = instance.parameters.Mode;
	Frame = instance.parameters.TF;
    Factor = instance.parameters.CF;
	RecurrentSound = instance.parameters.RecurrentSound;
   
	   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	 SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
   
	   
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

   assert(core.indicators:findIndicator("AB") ~= nil, "Please, download and install AB indicator");
    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	AB  = core.indicators:create("AB", BarSource, Frame, Factor);
	first= AB.DATA:first()+1;
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. Factor .. ", " .. Frame .. ")";
         instance:name(name);
 
   
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     AB:update(core.UpdateLast);
		   
		if  period  <  first then
		return;
		end
			 
		if Mode ~= "Touch" then	
					if core.crossesOver(source.close, AB.Top,period) then 					
					 Signal ("Top Line CrossOver");
					end 	
					
				
				    if core.crossesUnder(source.close, AB.Top,period) then 			
                      Signal ("Top Line CrossUnder");		
					end 	
					
				   
				   
				   if core.crossesOver(source.close, AB.Bottom,period) then 	
                    Signal ( "Bottom line CrossOver");
					end 	
					
				
				    if core.crossesUnder(source.close, AB.Bottom,period) then 	
                        Signal ("Bottom line CrossUnder");		
					end 	
		end
		
		if Mode ~= "Cross" then
		           
				    if source.high[period]  > AB.Top[period] and  source.low[period]  < AB.Top[period]  then 					
					 Signal ("Top Line Touch");
					end 		

                   			
				
				    if source.high[period]  > AB.Bottom[period] and  source.low[period]  < AB.Bottom[period]    then 	
                        Signal ("Bottom line Touch");		
					end 

                					
           end		
				
						  
							   
end

function Signal (Label)

								  if ShowAlert then
									terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
								end
								if SoundFile ~= nil then
									terminal:alertSound(SoundFile, RecurrentSound);
								end
								
								if Email ~= nil then
								 terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
								end
end								


dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
