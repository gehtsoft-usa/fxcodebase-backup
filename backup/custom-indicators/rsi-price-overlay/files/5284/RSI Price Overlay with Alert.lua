-- Id: 15347
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2438

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI Price Overlay");
    indicator:description("RSI Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 2, 1000);
	
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Buy1", "1. Buy Level", "", 50);
	indicator.parameters:addDouble("Buy2", "2. Buy Level", "", 70);
	indicator.parameters:addDouble("Buy3", "3. Buy Level", "", 90);
	
	indicator.parameters:addDouble("Sell1", "1. Sell Level", "", 50);
	indicator.parameters:addDouble("Sell2", "2. Sell Level", "", 30);
	indicator.parameters:addDouble("Sell3", "3. Sell Level", "", 10);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up1", "Color of 1. Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down1", "Color of 1. Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Up2", "Color of 2. Up", "Color of Up", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Down2", "Color of 2. Down", "Color of Down", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Up3", "Color of 3. Up", "Color of Up", core.rgb(0, 150, 0));
	indicator.parameters:addColor("Down3", "Color of 3. Down", "Color of Down", core.rgb(150, 0, 0));
	
	
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "1. Buy Level");	
	Parameters (2, "2. Buy Level");	
	Parameters (3, "3. Buy Level");	
	
	Parameters (4, "1. Sell Level");	
	Parameters (5, "2. Sell Level");	
	Parameters (6, "3. Sell Level");	
   
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("SoundUp"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("SoundUp"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("SoundDown"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("SoundDown"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local 	Number = 6;
local SoundUp={};
local SoundDown={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local OnlyOnceFlag;
local font;
local ShowAlert;




local first;
local source = nil;
local Price;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Up={}
local Down={};
local Neutral={};

local Period; 
local RSI = nil;
local Buy={};
local Sell={};

function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    Period = instance.parameters.Period;
	Price= instance.parameters.Price;
	source = instance.source;
	Up[1]= instance.parameters.Up1;
	Down[1]= instance.parameters.Down1;
	Up[2]= instance.parameters.Up2;
	Down[2]= instance.parameters.Down2;
	Up[3]= instance.parameters.Up3;
	Down[3]= instance.parameters.Down3;
	Neutral= instance.parameters.Neutral; 
	Buy[1]= instance.parameters.Buy1;
	Sell[1]= instance.parameters.Sell1;
	Buy[2]= instance.parameters.Buy2;
	Sell[2]= instance.parameters.Sell2;
	Buy[3]= instance.parameters.Buy3;
	Sell[3]= instance.parameters.Sell3;
	
	
	 if (Buy[3] < Buy[2]) then
       error("Buy Level 3. should be higher than Buy Level 2.");
    end
	
	if (Buy[2] < Buy[1]) then
       error("Buy Level 2. should be higher than Buy Level 1.");
    end
	
	
	 if (Sell[3] > Sell[2]) then
       error("Sell Level 3. should be lower than Sell Level 2.");
    end
	
	if (Sell[2] > Sell[1]) then
        error("Sell Level 2. should be lower than Sell Level 1.");
    end
	
      
    local name = profile:id() .. "(" .. source:name() ..", ".. Price..", ".. Period.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	RSI=core.indicators:create("RSI",  source[Price], Period);
	
	first= RSI.DATA:first();
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("MACD", "MACD", open, high, low, close);
	 
	Initialization();	
end


function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  SoundUp[i]=instance.parameters:getString("SoundUp" .. i);
	  SoundDown[i]=instance.parameters:getString("SoundDown" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       SoundUp[i]=nil;
	  SoundDown[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and SoundUp[i] ~= "") or (PlaySound and SoundUp[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and SoundDown[i] ~= "") or (PlaySound and SoundDown[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


-- Indicator calculation routine
function Update(period, mode)
    
 
		
		 RSI:update(mode);
		   
		open[period]=source.open[period]
		close[period]=source.close[period];
		high[period]=source.high[period];
		low[period]=source.low[period];	                   
		   
		   if period < RSI.DATA:first() or not RSI.DATA:hasData(period)then
		   open:setColor(period, Neutral);
		   return;
		   end
		   
					
						 
							if RSI.DATA[period] > Buy[3] then 	
							open:setColor(period, Up[3]); 
							elseif RSI.DATA[period] < Sell[3] then 
                            open:setColor(period, Down[3]); 
                            elseif RSI.DATA[period] > Buy[2] then 	
							open:setColor(period, Up[2]); 
							elseif RSI.DATA[period] < Sell[2] then 
                            open:setColor(period, Down[2]); 
                            elseif RSI.DATA[period] > Buy[1] then 	
							open:setColor(period, Up[1]); 
							elseif RSI.DATA[period] < Sell[1] then 
                            open:setColor(period, Down[1]); 								
							else
							open:setColor(period, Neutral); 
							end
							
							Activate (1, period);
							Activate (2, period);
							Activate (3, period);
							Activate (4, period);
							Activate (5, period);
							Activate (6, period);			 
	 
end				


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Buy[1] 
			and   RSI.DATA[period-1] <= Buy[1] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Buy[1] 
			and   RSI.DATA[period-1] >= Buy[1] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	   if id == 2  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Buy[2] 
			and   RSI.DATA[period-1] <= Buy[2] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Buy[2] 
			and   RSI.DATA[period-1] >= Buy[2] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 3  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Buy[3] 
			and   RSI.DATA[period-1] <= Buy[3] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Buy[3] 
			and   RSI.DATA[period-1] >= Buy[3] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	--***************************************

    if id == 4  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Sell[1] 
			and   RSI.DATA[period-1] <= Sell[1] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Sell[1] 
			and   RSI.DATA[period-1] >= Sell[1] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	   if id == 5  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Sell[2] 
			and   RSI.DATA[period-1] <= Sell[2] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Sell[2] 
			and   RSI.DATA[period-1] >= Sell[2] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 6  and ON[id]  then
	  
	       
			if   RSI.DATA[period] > Sell[3] 
			and   RSI.DATA[period-1] <= Sell[3] 
			then
			           
						    
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(SoundUp[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  RSI.DATA[period] < Sell[3] 
			and   RSI.DATA[period-1] >= Sell[3] 
            then			
			
			      		   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(SoundDown[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  --Up
	  --Down
	 
	  end

	
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end

   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
  
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;

	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 

