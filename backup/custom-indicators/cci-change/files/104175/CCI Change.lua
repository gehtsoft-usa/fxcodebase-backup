
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63019

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("CCI Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "CCI Period","", 14);
	indicator.parameters:addDouble("Level", "Level","", 50);
	
	indicator.parameters:addInteger("Ahead", "Look Ahead Period","", 10);
	indicator.parameters:addBoolean("ShowProfit" , "Show Profit"  , "", true);
	indicator.parameters:addBoolean("Ignore" , "Ignore Neutral"  , "", true);
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpColor", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralColor", "Neutral Color","", core.rgb(128, 128, 128)); 
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
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

	
	Parameters (1, "Change ");	
   
   
end 

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
local Up={};
local Down={};
local Label={};
local ON={}; 
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
local Ignore;
local OnlyOnceFlag;
local ShowAlert;
local Ahead;
local ShowProfit;

local HSpace;
local UpColor, DownColor, NeutralColor;
local Indicator;
local Period;
local Level;
local first;
function Prepare(nameOnly)


    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Ignore= instance.parameters.Ignore;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	Ahead = instance.parameters.Ahead;
	ShowProfit = instance.parameters.ShowProfit;
	 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   Period=instance.parameters.Period;	
   UpColor=instance.parameters.UpColor;
   DownColor=instance.parameters.DownColor;   
   NeutralColor=instance.parameters.NeutralColor;
   Period=instance.parameters.Period;
   Level=instance.parameters.Level;
   
   
   local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize().. ", " .. Period;
	 instance:name(name );
	 
	 if   (nameOnly) then
        return;
    end
   
   instance:setLabelColor(NeutralColor);
   instance:ownerDrawn(true);
   

    
	
	 Indicator = core.indicators:create("CCI", source ,  Period);	 
	first= Indicator.DATA:first()+1;
	
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
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	



function Update(period, mode)

     Indicator:update(mode); 
	
	
	 if period < first then
	 return;
	 end
	
    Activate (1, period);
	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
   local mid= context:top() + (context:bottom()-context:top())/2
   
        if not init then
		     context:createPen (1, context.SOLID, 1, UpColor) ;      
			context:createSolidBrush(2, UpColor);
			
			 context:createPen (3, context.SOLID, 1, DownColor) ;      
			context:createSolidBrush(4, DownColor);
			
			context:createPen (5, context.SOLID, 1, NeutralColor);       
			context:createSolidBrush(6, NeutralColor);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if Indicator.DATA:hasData(period) and Indicator.DATA:hasData(period-1) then 
										
												 
									         	     if  (Indicator.DATA[period] -Indicator.DATA[period-1] )> Level then		 
																 
																C2=2;
																C1=1;
															 
														      
													 
														elseif (Indicator.DATA[period] -Indicator.DATA[period-1] )< -Level then	
																 
																C2=4;
																C1=3;
															  
															 	
														 else
					   
																 C1=5; C2=6;		
														
														end		 
														
																							
													 
												     
									   else		
									   C1=5; C2=6;										   
									   end 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
					if  ShowProfit then	
					
					        context:drawRectangle (C1, C2, X1, context:top(), X2, mid  );
							
							Flag = AheadCalculation(period);
							if Ignore and  C1== 5 then
							context:drawRectangle (5, 6, X1, mid, X2, context:bottom()  );
							elseif Flag then
							context:drawRectangle (1, 2, X1, mid, X2, context:bottom()  );
							else
							context:drawRectangle (3, 4, X1, mid, X2, context:bottom()  );							
							end
					     
					else   
					     context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
					end   
														
					
					
			end					
				 
				
	
end

function AheadCalculation(period)

local p= math.min(period+Ahead, source:size()-1);

 
   if source.close[p] > source.close[period] then
   return true;
   else
   return false;
   end
   
 

end
	

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
	
 
	  if id == 1  and ON[id]  then
	  
	       
					if (Indicator.DATA[period] -Indicator.DATA[period-1] )> Level
					then
						 	 
								   
					
					 D[id] = nil;
								   
									  if U[id]~=source:serial(period) 
									  and period == source:size()-1-Shift
									  and not FIRST 
									  then
									  OnlyOnceFlag=false;
									  U[id]=source:serial(period);
									  SoundAlert(Up[id]);
									  EmailAlert(  Label[id], " Up ", period);
									  SendAlert(" Up "); 
									  Pop(Label[id], " Up " );  
									  end
				 			  
					elseif (Indicator.DATA[period] -Indicator.DATA[period-1] )< -Level
					then	 

					U[id] = nil;
				   
									 if  D[id]~=source:serial(period)
									 and period == source:size()-1-Shift
									 and not FIRST 
									 then
									 OnlyOnceFlag=false;
									 D[id]=source:serial(period);
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] , " Down ", period);	
									 Pop(Label[id], " Down " );  	
									 SendAlert(" Down ");							 
									 end	
					 			 
					 end
			
	  
	 
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
	 



