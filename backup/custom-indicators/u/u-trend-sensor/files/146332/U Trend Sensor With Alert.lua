-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72370

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 4;
local Symbol={"\225","\226","\225","\226"};
local Font={"Wingdings", "Wingdings","Wingdings", "Wingdings"};
local Alert_Name={ "1./2. Line" ,"1./2. Line","1./Zero Line" ,"1./Zero Line"};
local Signal_Name={"Cross Over", "Cross Under","Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name(" U Trend Sensor With Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periodf", "Fast Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("periods", "Slow Period", "", 200, 1, 2000);

    indicator.parameters:addDouble("fpercent", "Fast percent", "", 1, 0, 2000);
    indicator.parameters:addDouble("spercent", "Slow percent", "", 0.5, 0, 2000);
	
    indicator.parameters:addInteger("p", "Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("psignal", "Signal Period", "", 20, 1, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
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
	Color[3]= core.rgb(0, 255, 0);
	Color[4]= core.rgb(255, 0, 0);	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],Color[i]);	
 
 	end
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
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
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


local first;
local source = nil;
local periodf, periods; 
local fpercent, spercent; 
local p, psignal; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	periodf=instance.parameters.periodf;
	periods=instance.parameters.periods;
	fpercent=instance.parameters.fpercent;
	spercent=instance.parameters.spercent;	
	p=instance.parameters.p;
	psignal=instance.parameters.psignal;		
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  periodf.. "," ..  periods .. "," ..  fpercent.. "," ..  psignal .. "," ..  p.. "," ..  spercent.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("TMA", source, periodf);
	Indicator2= core.indicators:create("TMA", source, periods);	
	first=math.max(Indicator1.DATA:first(),Indicator1.DATA:first()) ; 
	
	
	U = instance:addInternalStream(0, 0);
	fss= instance:addInternalStream(0, 0);
 	sss= instance:addInternalStream(0, 0);
	
	Indicator3= core.indicators:create("EMA", U, p);	
	Indicator4= core.indicators:create("EMA", Indicator3.DATA, psignal);		
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, Indicator3.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, Indicator4.DATA:first() );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



   
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

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
end 


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	
	 if period <= first then 
	 return;
	 end
	 

    fss[period] = source[period]
    sss[period] = source[period]
 
	

	local fMA = Indicator1.DATA[period]
	local sMA = Indicator2.DATA[period]

	if(fMA > fss[period] + (fMA/100)*fpercent) then
	  fss[period] = fMA
	elseif (fMA < fss[period] - (fMA/100)*fpercent) then
	  fss[period] = fMA    
	end

	if(sMA > sss[period] + (sMA/100)*spercent) then
	  sss[period] = sMA
	elseif (sMA < sss[period] - (sMA/100)*spercent) then
	  sss[period] = sMA   
	end

   U[period] = fss[period] - sss[period];
   
  	Indicator3:update(mode); 
  	Indicator4:update(mode); 
	
	 if period <= Indicator3.DATA:first() or period <= Indicator4.DATA:first()  then
	 return;
	 end
	 
   Line1[period] = Indicator3.DATA[period];
   Line2[period] = Indicator4.DATA[period];
 

 
	if Signal_Execution~= "Live" then
	period=period-1;	 
	end
	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
end


--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

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


       
	  --  if not Show_Unconfirmed then
	   -- Alert[id][period]= 0;	
		--end
  
	
	  
	    if id== 1  then   
			if  Line1[period] > Line2[period] 
			and   Line1[period-1] <= Line2[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Line2[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  Line1[period] < Line2[period] 
			and   Line1[period-1] >= Line2[period-1] 
            then			
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 2   then  
			if  Line1[period] < Line2[period] 
			and   Line1[period-1] >= Line2[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Line2[period] 
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  Line1[period] > Line2[period] 
			and   Line1[period-1] <= Line2[period-1] 
            then			
			 
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end

	    if id== 3  then   
			if  Line1[period] > 0
			and   Line1[period-1] <= 0
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  Line1[period] < 0
			and   Line1[period-1] >= 0
            then			
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 4   then  
			if  Line1[period] < 0
			and   Line1[period-1] >= 0
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  Line1[period] > 0
			and   Line1[period-1] <= 0
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