-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6596

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
    indicator:name("New Trend With Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Caclulation");
	indicator.parameters:addInteger("ATRP", "ATR Period", "ATR Period", 12);
    indicator.parameters:addInteger("MVAP", "MVA Period", "MVA Period", 14);
 
	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownDown", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
   indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " Alert ");	
 
   
end 


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Trend Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
local Up={};
local Down={};
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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 

--//////////////////////////////////////////

local HSpace;
local UpUp,DownDown,Neutral;

local ATRP;
local MVAP;

local ATR;
local MVA;
local Signal ;
function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   UpUp=instance.parameters.UpUp;
   DownDown=instance.parameters.DownDown; 
   Neutral=instance.parameters.Neutral;
   
   
	 local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	 instance:name(name );
	 
	 if nameOnly then
		return;
	 end
	 
	 
	 	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
	
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live; 
	 
	 
	  instance:setLabelColor(Neutral);
   
     ATRP = instance.parameters.ATRP;
    MVAP = instance.parameters.MVAP; 
  
    
	MVA=core.indicators:create("MVA", source.close, MVAP );
	ATR=core.indicators:create("ATR", source, ATRP );
	
	first = math.max(MVA.DATA:first(),  ATR.DATA:first() );
	 
 
   instance:ownerDrawn(true);
    
   Signal = instance:addInternalStream(0, 0);
   
    
	 
	
	Initialization();	
	instance:ownerDrawn(true);	 
		
end



function Update(period, mode)

     ATR:update(mode);
	 MVA:update(mode);
 
	 
	                                                      if source.close[period] > MVA.DATA[period] + ATR.DATA[period]  then		 
																	 
															Signal[period]=1;
																 
														   
															elseif source.close[period] < MVA.DATA[period] - ATR.DATA[period] then	
																	 
																Signal[period]=-1; 
														   else	 
					   
															   Signal[period]=0; 
																					
														end		 
	 
	 
	 
	 if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
 
    Activate (1, period);
 
	
end



function Activate (id, period)


    
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period] ==1 
			and    Signal[period-1] ~=1 
			then
			            
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ");
							  SendAlert( Label[id]," Up Trend "); 
							  Pop(Label[id], " Up Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Signal[period] ==-1 
			and    Signal[period-1] ~=-1 
            then			
			
			            			 
			                 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ");								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end

 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
	
	local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, UpUp)       
			context:createSolidBrush(2, UpUp);
			
			  
			 context:createPen (7, context.SOLID, 1, DownDown)       
			context:createSolidBrush(8, DownDown);
			
			context:createPen (9, context.SOLID, 1, Neutral)       
			context:createSolidBrush(10, Neutral); 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			    
				
				 
										if ATR.DATA:hasData(period) and MVA.DATA:hasData(period-1) then 
										
												 
														 if source.close[period] > MVA.DATA[period] + ATR.DATA[period]  then		 
																	 
																	C2=2;
																	C1=1;
																 
														 
															elseif source.close[period] < MVA.DATA[period] - ATR.DATA[period] then	
																	 
																	C2=8;
																	C1=7;
														   else	 
					   
																 C1=9; C2=10;		
																					
														end		 
															
													 
												     
									   else		
									   C1=9; C2=10;										   
									   end 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
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
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	