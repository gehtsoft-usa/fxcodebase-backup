-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 2;
local Symbol={"\225","\226"};
local Font={"Wingdings", "Wingdings"};
local Alert_Name={ "Long/Short" ,"Short/Long"};
local Signal_Name={"Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function Init()
    indicator:name("Bollinger Bands Breakout");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 0, 2000);
	
	indicator.parameters:addBoolean("Central", "Central Line", "", false);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
		
	 indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Signal_Execution", "Signal Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Signal_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Signal_Execution", "Live", "", "Live");  
	
 
	indicator.parameters:addString("Alert_Execution", "Alert Execution", "", "Live");
    indicator.parameters:addStringAlternative("Alert_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Alert_Execution", "Live", "", "Live");  

   
   	indicator.parameters:addString("Alert_Triger", "Alert Triger", "", "Both");
    indicator.parameters:addStringAlternative("Alert_Triger", "Timer", "", "Timer");
	indicator.parameters:addStringAlternative("Alert_Triger", "Price", "", "Price");
    indicator.parameters:addStringAlternative("Alert_Triger", "Both", "", "Both");
	
    indicator.parameters:addInteger("Timer", "Execution Timer (in seconds)", "", 1, 0, 1000);
 
   
    
 
	 
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
--indicator.parameters:addBoolean("Show_Unconfirmed", "Show Unconfirmed Signals", "", false);
 
  
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	local Color={};
	Color[1]= core.rgb(0, 255, 0);
	Color[2]= core.rgb(255, 0, 0);
	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],Color[i]);	
 
 	end
	
	
end



function Parameters ( id, Label1,Label2,internal_color )
  
  
   indicator.parameters:addGroup(Label1 .. " Alert");
  
    indicator.parameters:addBoolean("Alert_ON"..id , "Show " .. Label2 .." Alert" , "", true);
    indicator.parameters:addBoolean("Signal_ON"..id , "Show " .. Label2 .." Signal" , "", true); 
	

    indicator.parameters:addFile("Sound"..id, Label2 .. " Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

    indicator.parameters:addString("Alert_Label1"..id, "Alert Label", "", Label1);
	 indicator.parameters:addString("Alert_Label2"..id, "Alert Signal", "", Label2);
	 
	 
	 indicator.parameters:addColor("Color"..id, "Label Color", "",internal_color); 
	indicator.parameters:addInteger("Size"..id, "Label Size", "", 10, 1 , 100);

end 



local Sound={};
local Label1={};
local Label2={};
local Signal_ON={}; 
local Alert_ON={}; 
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
 
local PlaySound;
--local Live;
--local FIRST=true;
local OnlyOnce;
local ItIs={};
local Color={};
local Size={};
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local Timer;
--local Show_Unconfirmed;
local Signal_Execution, Alert_Execution,Alert_Triger;
local Alignment={};

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Central;
local Period,Deviation; 
local first;
local source = nil;
 
local Oscillator;  
local BB;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Deviation= instance.parameters.Deviation;
	Central= instance.parameters.Central;
	
	
	local Parameters= Period..", "..Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	BB = core.indicators:create("BB", source, Period, Deviation);
    first=source:first();
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	
   	Alert_Triger= instance.parameters.Alert_Triger;
	
	 
 
    if Alert_Triger ~= "Timer" then
    core.host:execute("subscribeTradeEvents", 1, "offers");
    end
	

	
	Timer= instance.parameters.Timer 
	Initialization();	
	instance:ownerDrawn(true);	
	
	if Alert_Triger ~= "Price" then
    core.host:execute ("setTimer", 3 , Timer);
	end
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
   
    BB:update(mode);
	
	if period < first
	then
	return;
	end
	 
	 if Central then
	 
	         Oscillator[period]= source[period]-BB.AL[period];  
	 
	 else
	 
			 if 	source[period] > BB.TL[period] then
			 Oscillator[period]= source[period]-BB.TL[period];
			 elseif 	source[period] < BB.BL[period] then
			 Oscillator[period]= source[period]-BB.BL[period];
			 else
			 Oscillator[period]=0;
			 end
	 end
	 
	 
	 
	 if Signal_Execution~= "Live" then
	period=period-1;	 
	end
	
	

	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
				  
end





function  Initialization ()


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
	
	Signal_Execution = instance.parameters.Signal_Execution;
	Alert_Execution = instance.parameters.Alert_Execution;

	 
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	--Live = instance.parameters.Live;
	Show_Unconfirmed= instance.parameters.Show_Unconfirmed;

     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
		Alignment[i]= instance:addInternalStream(0, 0);
     end
	 
	 
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label1[i]=instance.parameters:getString("Alert_Label1" .. i);
	  Label2[i]=instance.parameters:getString("Alert_Label2" .. i);
	  Signal_ON[i]=instance.parameters:getBoolean("Signal_ON" .. i);
	  Alert_ON[i]=instance.parameters:getBoolean("Alert_ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	for i = 1, Number , 1 do 
	  Color[i]=instance.parameters:getColor("Color" .. i);
	  Size[i]=instance.parameters:getInteger("Size" .. i);
	end  
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	 
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil; 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (Sound[i] == "" or Sound[i] == nil ) ), "Sound file must be chosen");
    
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	ItIs[i] = nil; 
	end
		 
end	


--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function Signal_Logic (id, period)


       
	if period < source:first()
	then
	return;
	end
	
	  
	    if id== 1  then   
			if Oscillator[period] > 0
			and   Oscillator[period-1] <= 0
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  Oscillator[period] < 0
			and   Oscillator[period-1] >= 0
            then			
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 2   then  
			if  Oscillator[period] < 0
			and   Oscillator[period-1] >= 0
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  Oscillator[period] >0
			and   Oscillator[period-1] <= 0
            then			
			 
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end


end

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\





function AsyncOperationFinished (cookie, success, message)

    if cookie~=1
	and cookie~= 3 
	then
	return;
	end
	
 
	
    local Last_Period=source:size()-1;
	
	
	if Signal_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
    if Alert_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
	
     if Last_Period < first 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	
	

end




 

function Alert_Logic (id, period)



   
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
	  
	    if   Alert[id][period]== 1  then   
		 
			           
  	   
							  if ItIs[id]~=source:serial(period)  
							  --and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  ItIs[id]=source:serial(period);
							  SoundAlert(Sound[id]);
							  EmailAlert( Label1[id], Label2[id]);
							  SendAlert( Label1[id],Label2[id],period); 
							  Pop(Label1[id], Label2[id], period );  
							  OnlyOnceFlag=false;
							  end 
		else
		
							   ItIs[id]=nil;
			 
			
	    end
		
 
	  
		   
       -- if FIRST then
        --FIRST=false;      
       -- end		

end

 

function SoundAlert(internal_sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(internal_sound, RecurrentSound);
end

 


function EmailAlert( label1,label2 )

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label1  .. delim .. "Alert : " .. label2 ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .."Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 
function Pop(label1,label2 , period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(sound_file)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(sound_file, RecurrentSound);
end

function EmailAlert(label1,label2, period)

if not SendEmail then
return
end

   local delim = "\013\010";   

     local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
 terminal:alertEmail(Email, profile:id(), Text);
end
	 


function SendAlert(label1,label2, period)
    if not ShowAlert then
        return;
    end
	
	local delim = "\013\010";  
	
	 local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end


 




local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
		   for Level = 1 , Number ,  1 do
           context:createFont (Level, Font[Level], context:pointsToPixels (Size[Level]), context:pointsToPixels (Size[Level]), 0);
		   end
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
				 for Level = 1 , Number ,  1 do
					   if Alert[Level]:hasData(period) and Signal_ON[Level] then
						 
							if Alert[Level][period]== 1
							and Alert[Level][period-1]~= 1
							then
							visible, y = context:pointOfPrice (AlertLevel[Level][period]);
							
							  width, height = context:measureText (1,  Symbol[Level], 0);

                              if Alignment[Level][period]==-1 then
							   context:drawText (Level,  Symbol[Level], Color[Level], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
							  else
							   context:drawText (Level,  Symbol[Level], Color[Level], -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
							  end
							  
				   
							 end
					  end
						
				 
				end
		end
		
  
end		
 
 
 