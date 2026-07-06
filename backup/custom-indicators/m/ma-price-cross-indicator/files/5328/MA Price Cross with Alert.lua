-- Id: 2018
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2451

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 2;
local Symbols={"\225","\226", "Some Text", "Some Text"};
local Font={"Wingdings", "Wingdings", "Arial", "Arial"};
local Alert_Name={ "Long/Short" ,"Short/Long", "My Alert"};
local Signal_Name={"Cross Over", "Cross Under", "We have a Cross"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function Init()
    indicator:name("MA Price Cross indicator");
    indicator:description("MA Price Cross indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("MA Parameters");
	indicator.parameters:addInteger("IN" , "Data Source", "", 4);
    indicator.parameters:addIntegerAlternative("IN" , "Open", "", 1);
    indicator.parameters:addIntegerAlternative("IN", "High", "", 2);
    indicator.parameters:addIntegerAlternative("IN" , "Low", "", 3);
	indicator.parameters:addIntegerAlternative("IN" , "Close", "", 4);
	indicator.parameters:addIntegerAlternative("IN", "Median", "", 5);
    indicator.parameters:addIntegerAlternative("IN" , "Typical", "", 6);
	indicator.parameters:addIntegerAlternative("IN" , "Weighted ", "", 7);		    			
	indicator.parameters:addString("M" , "Method for avegage", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "LWMA", "", "LWMA");
				
    indicator.parameters:addInteger("Frame", "MA Frame", "", 50, 2, 1000);  

 
    indicator.parameters:addGroup("Cross Type"); 
    indicator.parameters:addString("Type" , "Method of Cross", "", "Cross");
    indicator.parameters:addStringAlternative("Type" , "Cross", "", "Cross");
    indicator.parameters:addStringAlternative("Type", "Touch", "", "Touch");
	
	
	indicator.parameters:addGroup("Price Type"); 
	
	indicator.parameters:addInteger("PIN" , "Data Source", "", 4);
    indicator.parameters:addIntegerAlternative("PIN" , "Open", "", 1);
    indicator.parameters:addIntegerAlternative("PIN", "High", "", 2);
    indicator.parameters:addIntegerAlternative("PIN" , "Low", "", 3);
	indicator.parameters:addIntegerAlternative("PIN" , "Close", "", 4);
	indicator.parameters:addIntegerAlternative("PIN", "Median", "", 5);
    indicator.parameters:addIntegerAlternative("PIN" , "Typical", "", 6);
	indicator.parameters:addIntegerAlternative("PIN" , "Weighted ", "", 7);	
 
	
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("CrossUP", "Up Cross Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("CrossDN", "Down Cross Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("TouchUp", "Up Touch Color", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("TouchDown", "Down Touch Color", "", core.rgb(128, 0, 255));
	
	indicator.parameters:addInteger("ArrowSize", "Arrow Size", "", 15);
		
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
 
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
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local IN,PIN, Type, M, Frame;

local first;
local source = nil;

-- Streams block
local PRICE, DATA, indicator = nil, NOTE1, NOTE2;

local Crossdown, Crossup, Touchup, Touchdown;
local ArrowSize;
local Signal;
-- Routine
function Prepare(nameOnly)

    IN = instance.parameters.IN;
    PIN = instance.parameters.PIN;
    Type = instance.parameters.Type;
    M = instance.parameters.M;
    Frame = instance.parameters.Frame;
	ArrowSize= instance.parameters.ArrowSize;
 
    source = instance.source;
   
	
	
     	if PIN == 1 then
		PRICE = source.open;	
        NOTE1="Open"  		
		elseif PIN==2 then
		PRICE = source.high;	
		NOTE1="High"
		elseif PIN==3 then
		PRICE = source.low;
        NOTE1="Low"		
		elseif PIN==4 then
		PRICE = source.close;	
		NOTE1="Close"
		elseif PIN==5 then
		PRICE = source.median;	
		NOTE1="Median"
		elseif PIN==6 then
		PRICE = source.typical;	
		NOTE1="Typical"
		elseif PIN==7 then
		PRICE = source.weighted;	
		NOTE1="Weighted"
		end
		
		
		
		if IN == 1 then
		DATA = source.open;	
        NOTE2="Open"		
		elseif IN==2 then
		DATA = source.high;	
		 NOTE2="High"	
		elseif IN==3 then
		DATA = source.low;	
		 NOTE2="Low"	
		elseif IN==4 then
		DATA = source.close;	
		 NOTE2="Close"	
		elseif IN==5 then
		DATA = source.median;	
		 NOTE2="Median"	
		elseif IN==6 then
		DATA = source.typical;	
		 NOTE2="Typical"	
		elseif IN==7 then
		DATA = source.weighted;	
		 NOTE2="Weighted"	
		end
	

    local name = profile:id() .. "(" .. source:name() ..", Price Type ".. NOTE1  .. ", MA Type " .. NOTE2.. ", ".. M..", ".. Frame..", ".. Type..")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	Signal = instance:addInternalStream(0, 0);

			   
    assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed");
	    indicator= core.indicators:create(M, DATA, Frame);		
	
	 first = indicator.DATA:first();

    if not Type == "Cross" then 	 
	Touchup = instance:createTextOutput ("TU", "Touch UP", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.TouchUp, 0);
	Touchdown = instance:createTextOutput ("TD", "Touchup Down", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.TouchDown, 0);
	else
    Crossdown = instance:createTextOutput ("CD", "Cross Down", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.CrossDN, 0);
    Crossup = instance:createTextOutput ("CU", "Cross Up", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.CrossUP, 0);
    end

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
			
end 

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
end 
 
 
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   	 indicator:update(mode);  
	  
	
	Signal[period]=0;
	  
	if indicator.DATA:hasData(period) and indicator.DATA:hasData(period-1) and period > 1 then	
	
	    if Type == "Cross" then 		
		        if  core.crossesOver(PRICE, indicator.DATA,   period)  then
				Crossup:set(period, source.low[period], "\225");	
				Signal[period]=1;
                elseif  core.crossesUnder(PRICE, indicator.DATA,   period)  then 				
				Crossdown:set(period, source.high[period], "\226");
				Signal[period]=-1;				
		        end  
		else
				if source.low[period] <  indicator.DATA[period]  and source.high[period] >  indicator.DATA[period]then 
				
						if source.close[period]> indicator.DATA[period] then
						Signal[period]=1;
						Touchup:set(period, source.low[period], "\108"); 	
						else				
						Touchdown:set(period, source.high[period], "\108"); 
						Signal[period]=-1;						
						end
				end
		end	
							
	end		
	
		
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	
	if Signal_Execution~= "Live" then-- if Signal_Execution is NOT a Live shift period by 1 
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

 


function Signal_Logic (id, period)


       
	  --  if not Show_Unconfirmed then
	   -- Alert[id][period]= 0;	
		--end
  
	
	    --id 1 will define Cross Over Alert
	    if id== 1  then   
			if Signal[period]==1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= indicator.DATA[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif Signal[period]== -1
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 2   then  
			if  Signal[period]== - 1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]=  indicator.DATA[period] 
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif Signal[period]==1
            then			
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
	
	
     if Last_Period < first 
	 then
	 return;
	 end
	
	if Number ~=0 then
		for i=1, Number, 1 do
		Alert_Logic (i, Last_Period);
		end
	end
	
	

end




 

function Alert_Logic (id, period)



   
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
  	
	if Alert[id]== nil then
	ItIs[id]=nil;
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
				 
				    if Alert[Level]~= nil then
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
		
  
end		
 
 --^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 

