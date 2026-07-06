 
-- Available @  http://fxcodebase.com/code/viewtopic.php?f=17&t=66877
 
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

-- Indicator profile initialization routine

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 6;
local Symbols={"\225","\226", "\225","\226", "\225","\226"};
local Font={"Wingdings", "Wingdings", "Wingdings", "Wingdings", "Wingdings", "Wingdings"};
local Alert_Name={ "Up Trend" ,"Up Trend",  "Down Trend" ,"Down Trend",  "Neutral Trend" ,"Neutral Trend"};
local Signal_Name={"Start of", "End of", "Start of", "End of", "Start of", "End of"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function Init()
    indicator:name("True Direction Oscillator with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 0, 2000);	 
    indicator.parameters:addInteger("Period2", "1. Period", "", 20, 0, 2000);
    indicator.parameters:addInteger("Period3", "2. Period", "", 40, 0, 2000);	 
    indicator.parameters:addInteger("Period4", "3. Period", "", 80, 0, 2000);
	indicator.parameters:addInteger("Period5", "4. Period", "", 160, 0, 2000);
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color3", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
 
    indicator.parameters:addGroup("Alert Parameters");  
    indicator.parameters:addBoolean("MasterSwitch" , "Alert Master Switch", "", true);		
	
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
	Color[3]= core.rgb(0, 255, 0);
	Color[4]= core.rgb(255, 0, 0);
	Color[5]= core.rgb(0, 255, 0);
	Color[6]= core.rgb(255, 0, 0);
	
	
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
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period={}; 
local first;
local source = nil;
 
local Oscillator;  
local Bars; 
local Data={};
-- Routine
 function Prepare(nameOnly)   
 
    Period[1]= instance.parameters.Period1;
	Period[2]= instance.parameters.Period2;
	Period[3]= instance.parameters.Period3;
	Period[4]= instance.parameters.Period4;
	Period[5]= instance.parameters.Period5;
	
    
	
	
	local Parameters= Period[1] ..  ", " .. Period[2] ..  ", " .. Period[3]..  ", " ..Period[4] ..  ", " .. Period[5];
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period[1] ,Period[2], Period[3],Period[4] , Period[5]);
	
	for i= 1, 5, 1 do 
    Data[i] = instance:addInternalStream(0, 0);
    end
	
	Oscillator = instance:addStream("TDO" , core.Line, " TDO"," TDO",instance.parameters.color, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Bars= instance:addStream("Signal" , core.Bar, " Signal"," Signal",instance.parameters.color3, first);
    Bars:setPrecision(math.max(2, instance.source:getPrecision()));
	
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

   
   	Alert_Triger= instance.parameters.Alert_Triger;
	
	 
 
    if Alert_Triger ~= "Timer" then
    core.host:execute("subscribeTradeEvents", 1, "offers");
    end
	

	
	Timer= instance.parameters.Timer 
	Initialization();	
	instance:ownerDrawn(true);	
	
	if Alert_Triger ~= "Price" then-- this will work for Timer and Both
    core.host:execute ("setTimer", 3 , Timer);
	end
	
	
	Signal = instance:addInternalStream(0, 0);
			
end 

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
end 
 
 
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Indicator calculation routine
function Update(period )


     if period < first then
	return;
	end

   Signal[period]=Signal[period-1];

   for i= 1, 5, 1 do
   Add(i,period);
   end
   
  
		
     Oscillator[period]=Data[1][period];	

     Bars[period]=Oscillator[period]; 
	 
	 if Data[1][period] >0  and  Data[2][period] >0 and  Data[3][period] >0  and  Data[4][period] >0 and  Data[5][period] >0 then
	 Bars:setColor(period, instance.parameters.color1);
	 Signal[period]=1;
	 elseif Data[1][period] <0  and  Data[2][period] <0 and  Data[3][period] <0  and  Data[4][period] <0 and  Data[5][period] <0 then
	 Bars:setColor(period, instance.parameters.color2);
	 Signal[period]=-1;	 
	 else
	 Signal[period]=0;	 
	 Bars:setColor(period, instance.parameters.color3);
	 end



--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	
	if Signal_Execution~= "Live" then-- if Signal_Execution is NOT a Live shift period by 1 
	period=period-1;	 
	end
	
	
	if period <= first	 
	then
	return;
	end

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
end


function Add(id, period)


local A=source[period];
local B=source[period-Period[id]+1];
local Center = (A + B)/2;

Data[id][period]=100*(A-B)/Center;

end






 

function  Initialization ()


    ToTime=instance.parameters.ToTime;
	MasterSwitch = instance.parameters.MasterSwitch;
	
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

 


function Signal_Logic (id, period)

		if period <= first	 	
		then
		return;
		end
       
	  --  if not Show_Unconfirmed then
	   -- Alert[id][period]= 0;	
		--end
  
	
	    --id 1 will define Cross Over Alert
	    if id== 1  then   
			if  Signal[period] ==1 
			and   Signal[period-1] ~=1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
				Alignment[id][period]= -1;		   
					
						   							  
			else 	
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
 
	    --id 2 will define Cross Under Alert		
		if id== 2   then  
			if Signal[period] ~= 1 
			and   Signal[period-1] == 1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
				Alignment[id][period]= 1;		   
			
						   
							  							  
			else 			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		    --id 1 will define Cross Over Alert
	    if id== 3  then   
			if  Signal[period] ==-1 
			and   Signal[period-1] ~=-1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
				Alignment[id][period]= -1;		   
					
						   							  
			else 	
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 4   then  
			if Signal[period] ~= -1 
			and   Signal[period-1] == -1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
				Alignment[id][period]= 1;		   
			
						   
							  							  
			else 			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end	

	    --id 1 will define Cross Over Alert
	    if id== 5  then   
			if  Signal[period] ==0 
			and   Signal[period-1] ~=0 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
				Alignment[id][period]= -1;		   
					
						   							  
			else 	
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 6   then  
			if Signal[period] ~= 0 
			and   Signal[period-1] == 0 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0
				Alignment[id][period]= 1;		   
			
						   
							  							  
			else 			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end 
end
 





function AsyncOperationFinished (cookie, success, message)

    if cookie~=1--subscribeTradeEvents
	and cookie~= 3 --Timer
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
	
	
     if Last_Period <= first 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	
	

end




 

function Alert_Logic (id, period)


	if  period <= first  
	or not MasterSwitch 
	then
	return;
	end
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
	  
	    if   Alert[id][period]== 1  then   
		 
			           
  	   
							  if ItIs[id]~=source:serial(period)  
							  --and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  --and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag== true))
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
    
   --delim == djelim == new line	
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
							
							  width, height = context:measureText (1,  Symbols[Level], 0);

                              if Alignment[Level][period]==-1 then
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	--low
							  else
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	--high, have my arrow above the high
							  end
							  
				   
							 end
					  end
						
				 
				end
		end
		
  
end		
 
 
-- Available @  http://fxcodebase.com/code/viewtopic.php?f=17&t=66877
 
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 