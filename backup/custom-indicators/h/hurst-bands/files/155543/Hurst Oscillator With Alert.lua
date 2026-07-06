-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=154010

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 8;
local Symbols={"\225","\226", "\225","\226","\225","\226", "\225","\226"};
local Font={"Wingdings", "Wingdings", "Wingdings", "Wingdings","Wingdings", "Wingdings", "Wingdings", "Wingdings"};
local Alert_Name={ "1. Level" ,"1. Level", "2. Level" ,"2. Level",  "3. Level" ,"3. Level", "4. Level" ,"4. Level"};
local Signal_Name={"Cross Over", "Cross Under", "Cross Over", "Cross Under","Cross Over", "Cross Under", "Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



function Init()
    indicator:name("Hurst Oscillator");
    indicator:description("Hurst Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "Length", 10, 1, 2000);
    indicator.parameters:addInteger("smooth", "MA Length for Close", "MA Length for Close", 1, 1, 2000);
	 
 
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
   
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
	Color[7]= core.rgb(0, 255, 0);
	Color[8]= core.rgb(255, 0, 0);	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],Color[i]);	
 
 	end
 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.01);	
	indicator.parameters:addDouble("Level2", "2. Level","", 0.005);	
    indicator.parameters:addDouble("Level3", "3. Level","", -0.005);
	indicator.parameters:addDouble("Level4", "4. Level","", -0.01);		
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	 
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
local length;
local InnerValue;
local OuterValue;
local ExtremeValue;
local showClosingPriceLine;
local showExtremeBands;
local smooth;
local first;
local source = nil;
 local displacement;
local FlowValue;
local MasterSwitch;
-- Streams block
 
local FlowPrice = nil;
local MVA;
local CMA;
local showOuterBand;
local showInnerBand;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length; 
	smooth = instance.parameters.smooth;
    InnerValue = instance.parameters.InnerValue;
    OuterValue = instance.parameters.OuterValue;
    ExtremeValue = instance.parameters.ExtremeValue; 
	Level = instance.parameters.Level; 
	displacement = (length / 2) + 1
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(length).. ", " .. tostring(smooth)  .. ")";
    instance:name(name);

    if nameOnly then
	return;
	end
	
	Level1 = instance.parameters.Level1;
	Level2 = instance.parameters.Level2;
	Level3 = instance.parameters.Level3;
	Level4 = instance.parameters.Level4;
	
	MasterSwitch = instance.parameters.MasterSwitch;
	
        MVA = core.indicators:create("MVA", source.median,length );
        first = MVA.DATA:first()+displacement;
        CMA= instance:addInternalStream(0, 0); 
		
		FlowValue= instance:addInternalStream(0, 0)
		SMA= core.indicators:create("MVA", FlowValue,smooth );
		
        FlowPrice = instance:addStream("FlowPrice", core.Line, name .. ".FlowPrice", "FlowPrice", instance.parameters.color, SMA.DATA:first());
        FlowPrice:setPrecision(math.max(2, instance.source:getPrecision()));
		FlowPrice:setWidth(instance.parameters.width);
        FlowPrice:setStyle(instance.parameters.style);
        FlowPrice:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        FlowPrice:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        FlowPrice:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        FlowPrice:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
			 			 
    
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
function Update(period, mode)


    MVA:update(mode);
    if period  <= first or not source:hasData(period) then
	return;
	end
	
	
	CMA[period]= MVA.DATA[period-displacement];
	
	 
	 if source.close[period] > source.close[period-1] then
	 FlowValue[period]=  source.high[period];
	 elseif source.close[period] < source.close[period-1] then
	 FlowValue[period]= source.low [period]
	 else
	 FlowValue[period]=source.median[period]
	 end
	 
	 
     SMA:update(mode); 
	 if period <= SMA.DATA:first() then
	 return;
	 end

        FlowPrice[period] = SMA.DATA[period]-CMA[period];
   
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

		if  period <= first  
		or not MasterSwitch 
		then
		return;
		end

  
	
	    --id 1 will define Cross Over Alert
	    if id== 1  then   
			if  FlowPrice[period] > Level1
			and   FlowPrice[period-1] <= Level1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level1
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  FlowPrice[period] < Level1
			and   FlowPrice[period-1] >= Level1
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 2   then  
			if  FlowPrice[period] < Level1
			and   FlowPrice[period-1] >= Level1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level1
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  FlowPrice[period] > Level1
			and   FlowPrice[period-1] <= Level1
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end

	    if id== 3  then   
			if  FlowPrice[period] > Level2
			and   FlowPrice[period-1] <= Level2
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level2
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  FlowPrice[period] < Level2
			and   FlowPrice[period-1] >= Level2
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 4   then  
			if  FlowPrice[period] < Level2
			and   FlowPrice[period-1] >= Level2
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level2
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  FlowPrice[period] > Level2
			and   FlowPrice[period-1] <= Level2
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
	    --id 1 will define Cross Over Alert
	    if id== 5  then   
			if  FlowPrice[period] > Level3
			and   FlowPrice[period-1] <= Level3
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level3
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  FlowPrice[period] < Level3
			and   FlowPrice[period-1] >= Level3
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 6   then  
			if  FlowPrice[period] < Level3
			and   FlowPrice[period-1] >= Level3
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level3
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  FlowPrice[period] > Level3
			and   FlowPrice[period-1] <= Level3
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end

	    if id== 7  then   
			if  FlowPrice[period] > Level4
			and   FlowPrice[period-1] <= Level4
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level4
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  FlowPrice[period] < Level4
			and   FlowPrice[period-1] >= Level4
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 8   then  
			if  FlowPrice[period] < Level4
			and   FlowPrice[period-1] >= Level4
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level4
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  FlowPrice[period] > Level4
			and   FlowPrice[period-1] <= Level4
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
	
	
     if Last_Period <= first 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	
	

end




 

function Alert_Logic (id, period)



	if period <= first	
    or not source:hasData(period)
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
 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+