-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4971

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("ATR pips indicator");
    indicator:description("ATR pips indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.7);
	indicator.parameters:addDouble("AlertLevel", "AlertLevel", "", 1);
 
    indicator.parameters:addString("Corner", "Corner", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Top-Right", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Top-Left", "", "1");
    indicator.parameters:addStringAlternative("Corner", "Bottom-Right", "", "2");
    indicator.parameters:addStringAlternative("Corner", "Bottom-Left", "", "3");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Neutral Color", "Color", core.COLOR_LABEL );
	indicator.parameters:addColor("Color", "Neutral Color", "Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("FontSize", "Font size", "", 20);
    indicator.parameters:addInteger("H_Shift", "Horizontal shift", "", 0);
    indicator.parameters:addInteger("V_Shift", "Vertical shift", "", 50);


    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Level");	   

end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
 
	
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


local OnlyOnceFlag;
local ShowAlert;

local ToTime;
local Shift=0; 

local first;
local source = nil;
local Period;
local Multiplier;
local Corner;
local ATR;
local font;
local Signal;
local AlertLevel;
function Prepare(nameOnly)
    source = instance.source;
	
	ToTime=instance.parameters.ToTime;
	AlertLevel=instance.parameters.AlertLevel;
	
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
	 
	
    Period=instance.parameters.Period;
    Multiplier=instance.parameters.Multiplier;
    Corner=tonumber(instance.parameters.Corner);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Multiplier .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("TATR") ~= nil, "Please, download and install TATR.LUA indicator");
	
    ATR = core.indicators:create("TATR", source, Period);
    first = ATR.DATA:first();
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
	
	
	Signal = instance:addInternalStream(0, 0); 
	
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	 
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");

	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	
	end
		 
end	



function Update(period, mode)


   
    ATR:update(mode);
	
   if period < first 
   then
   return;
   end
   
    
   local LabelColor=instance.parameters.Neutral 
    local Value1= ((ATR.DATA[period]/source:pipSize())*Multiplier);			 
 	  

    Signal[period]=Signal[period-1];
	  
	if Value1 > AlertLevel 	then
	Signal[period]=1;
	LabelColor=instance.parameters.Color;
	else
	Signal[period]=0;
    end
	
	
    
    local Text="" .. " (" .. Period .. ") " ..  string.format("%." .. math.max(2, source:getPrecision()) .. "f",( (ATR.DATA[period]*Multiplier)/source:pipSize()))  .. "";
    if Corner==0 then
     core.host:execute("drawLabel1", 1,-instance.parameters.H_Shift, core.CR_RIGHT,instance.parameters.V_Shift, core.CR_TOP, core.H_Left, core.V_Bottom, font,LabelColor,  Text);
    elseif Corner==1 then
     core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_LEFT,instance.parameters.V_Shift, core.CR_TOP, core.H_Right, core.V_Bottom, font, LabelColor,  Text);
    elseif Corner==2 then
     core.host:execute("drawLabel1", 1,-instance.parameters.H_Shift, core.CR_RIGHT,-instance.parameters.V_Shift, core.CR_BOTTOM, core.H_Left, core.V_Top, font, LabelColor,  Text);
    else
     core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_LEFT,-instance.parameters.V_Shift, core.CR_BOTTOM, core.H_Right, core.V_Top, font, LabelColor,  Text);
    end 

 
   
    if period < source:size()-1 then
	return;
	end
   
    if Live~= "Live" then
	period=period-1; 
	end
	
	

	
    Activate (1, period)
end



function Activate (id, period)


   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period] ==1
			and Signal[period-1] ~=1
			then
			           
						    
         
 			
			
			
						   
							  if U[id]~=source:serial(period)  
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Signal[period] ==-1
			and Signal[period-1]~=-1
            then			
			
			            
		     U[id] = nil;
		   
			             		   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
		U[id]=source:serial(period) 
        FIRST=false;      
        end		

end

function AsyncOperationFinished (cookie, success, message)

	return core.ASYNC_REDRAW;
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
	 
	 
	 
	 
function Pop(AlertLabel , AlertText, period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(AlertLabel , AlertText, period)

if not SendEmail then
return
end

   local delim = "\013\010";   

     local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
 terminal:alertEmail(Email, profile:id(), Text);
end
	 


function SendAlert(AlertLabel , AlertText, period)
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
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end


