-- Id: 21680
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22407

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
    indicator:name("BB Squeeze");
    indicator:description("BB Squeeze");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BP", "Bollinger Period", " ", 20);
	indicator.parameters:addDouble("BD", "Bollinger Deviations", " ", 2);
	
	indicator.parameters:addInteger("KP", "Keltner Period", " ", 20);
	indicator.parameters:addDouble("KF", "Keltner Factor", " ", 1.5);
	
	indicator.parameters:addDouble("MP", "Momentum Period", " ", 12);
	 indicator.parameters:addString("MS", "Momentum smoothing method", "", "MVA");
	  indicator.parameters:addStringAlternative("MS", "No smoothing", "", "NO");
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA");
	indicator.parameters:addDouble("MSP", "Momentum Smoothing Period", " ", 20);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BBS_up", "Color of Up Momentum", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("BBS_dn", "Color of Down Momentum", " ", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("yes", "BBS Squeeze Color", " ", core.rgb(0, 0, 255));
	  indicator.parameters:addColor("no", "No BBS Squeeze Color", " ", core.rgb(128, 128, 128));
	  indicator.parameters:addInteger("Size", "Font Size", " ", 10);
	  
	  
	   indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  
	
	indicator.parameters:addBoolean("ChangeOnly", "ChangeOnly", "", false);


 
	 
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

	
	Parameters (1, "Alert");	
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

local OnlyOnceFlag;
local ShowAlert;

local ToTime;
local ChangeOnly;
local Shift=0; 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BP,BD,KP,KF,MP,MS;
local Size;
local first;
local source = nil;
local yes,no;
-- Streams block
local BBS = nil;
local ATR, Momentum, M,MSP, Def;
local Signal,signal;
-- Routine
function Prepare(nameOnly)
    BP = instance.parameters.BP;
    BD = instance.parameters.BD;
	KP = instance.parameters.KP;
	KF = instance.parameters.KF;
	MP = instance.parameters.MP;
    MS = instance.parameters.MS;
	MSP= instance.parameters.MSP;
	Signal= instance.parameters.Signal;
	Size= instance.parameters.Size;
    source = instance.source;
	
	
	    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BP)  .. ", " .. tostring(BP) .. ", " .. tostring(KP) .. ", " .. tostring(KF) .. ", " .. tostring(MP).. ", " .. tostring(MS).. ", " .. tostring(MSP).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
		ToTime=instance.parameters.ToTime;
		ChangeOnly=instance.parameters.ChangeOnly;
	
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

	
	 ATR = core.indicators:create("ATR", source, KP);
     Momentum=instance:addInternalStream (0, 0); 
	 Def=instance:addInternalStream (0, 0); 
	 
	if MS ~= "NO" then	 
		local profile = core.indicators:findIndicator(MS);
		assert(profile ~= nil, "Please, download and install " .. MS .. ".LUA indicator");
	  	M = core.indicators:create( MS, Momentum, MSP);
		first = math.max(MP, BP, KP);
	end
	
    first = math.max(MP, BP, KP);



	
	     if Signal then
		 signal = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.yes, first);
		 signal:setStyle(core.LINE_NONE); 
		 
		 else
		 signal=instance:addInternalStream (0, 0);
		 end
        BBS = instance:addStream("BBSR", core.Line, name, "Momentum", instance.parameters.BBS_up, first);
		instance:createChannelGroup ("BBSL", "BBSL", BBS, Def,instance.parameters.BBS_up, 100);
		 yes = instance:createTextOutput ("yes", "yes", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.yes);
		 no = instance:createTextOutput ("no", "no", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.no);
		 
	     signal:setPrecision(math.max(2, instance.source:getPrecision()));	
	     BBS:setPrecision(math.max(2, instance.source:getPrecision()));	
 
	 
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



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    signal[period]=99.9999;

     if period < first or not source:hasData(period) then
	 return;
	 end
	 Def[period]= 100;
	  ATR:update(mode);
	 
    Momentum[period]=source.close[period]*100./source.close[period-MP];
    local Dev = mathex.stdev(source.close, period - BP + 1, period);
	
	 if MS ~= "NO" then
	 M:update(mode);
	  BBS[period]=  M.DATA[period];
	 else
	 BBS[period]=  Momentum[period];
	 end
	 
	 if BBS[period] >BBS[period-1] then
	  BBS:setColor(period,instance.parameters.BBS_up);
	 else
	  BBS:setColor(period,instance.parameters.BBS_dn);
	 end
    
       if  (Dev * BD) / (ATR.DATA[period] * KF) < 1 then
	   yes:set(period, 100, "\108");
	   signal[period]=100;
	   else
	   no:set(period, 100, "\108");
	   signal[period]=99.9999;
	   end
	   
	   
	   
    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end 
	
	
    Activate (1, period)
	   
    
end




function Activate (id, period)


    
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  signal[period]==100
			and ((signal[period-1]~=100 and ChangeOnly) or not ChangeOnly )
			then
			           
						    
         
            
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Squeeze ", period);
							  SendAlert( Label[id]," Squeeze ", period); 
							  Pop(Label[id], " Squeeze ", period );  
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

 


function EmailAlert( label , Subject, period)

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

 

