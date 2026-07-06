-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72516

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

local Number = 2;
local Symbol={"\225","\226"};
local Font={"Wingdings", "Wingdings"};
local Alert_Name={ "Long/Short" ,"Short/Long"};
local Signal_Name={"Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function Init()
    indicator:name("Adaptive ATR-ADX Trend with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	 
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Price", "Price", "", "median");
	indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	

	
   indicator.parameters:addBoolean("useHeiken", "Use Heiken", "", true);	
   indicator.parameters:addBoolean("aboveThresh", "ADX Above Threshold uses ATR Falling Multiplier Even if Rising?", "", true);
   
    indicator.parameters:addInteger("atrLen", "ATR Period", "", 21, 1, 2000);	   
    indicator.parameters:addInteger("adxLen", "ADX Period", "", 14, 1, 2000);	


    indicator.parameters:addDouble("m1", "ATR Multiplier - ADX Rising", "", 3.5, 1, 2000);	   
    indicator.parameters:addDouble("m2", "ATR Multiplier - ADX Falling", "", 1.75, 1, 2000);	

    indicator.parameters:addDouble("adxThresh", "ADX Threshold", "", 30, 0, 2000);	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));	
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

	
	local TheColor={};
	TheColor[1]=core.rgb(0, 255, 0);
	TheColor[2]=core.rgb(255, 0, 0);
	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],TheColor[i]);	
 
 	end	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
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
 
local HA, Line

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Price= instance.parameters.Price;
    useHeiken= instance.parameters.useHeiken;
    aboveThresh = instance.parameters.aboveThresh;
	
	atrLen= instance.parameters.atrLen;
    adxLen= instance.parameters.adxLen;
    m1 = instance.parameters.m1;
    m2 = instance.parameters.m2;	
	adxThresh = instance.parameters.adxThresh;
	
	local Parameters= Price ..  ", " .. atrLen ..  ", " .. adxLen..  ", " ..m1 ..  ", " .. m2 ..  ", " .. adxThresh;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	
	sTR = instance:addInternalStream(0, 0); 
	sDMPos = instance:addInternalStream(0, 0); 
	sDMNeg = instance:addInternalStream(0, 0); 
	DX = instance:addInternalStream(0, 0); 
	aadx= instance:addInternalStream(0, 0);
	xHigh= instance:addInternalStream(0, 0);
	xLow= instance:addInternalStream(0, 0);	
 	xOpen= instance:addInternalStream(0, 0);
	xClose= instance:addInternalStream(0, 0);	
    trueRange = instance:addInternalStream(0, 0);	
    m= instance:addInternalStream(0, 0);	
	TUp= instance:addInternalStream(0, 0);	
	TDown= instance:addInternalStream(0, 0);	
    src= instance:addInternalStream(0, 0);	
    c= instance:addInternalStream(0, 0);
    trend= instance:addInternalStream(0, 0);	
  
    HA = core.indicators:create("HA", source  ); 
    TR = core.indicators:create("ATR", source, 1  );
    ATR = core.indicators:create("ATR", source, atrLen  );  
    WilderAverage = core.indicators:create("WMA", trueRange, atrLen  );  	
    first=math.max(HA.DATA:first())+1;
	
  
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first+adxLen);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
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

-- Indicator calculation routine
function Update(period, mode)

 
 
    HA:update(mode);
    TR:update(mode);	
    ATR:update(mode);	
	
    if period <= first then
	return;
	end
	 
	local HR = source.high[period]-source.high[period-1]
	local LR = -(source.low[period]-source.low[period-1])
	 
	if HR>LR then
	dmPos=math.max(HR,0)
	else
	dmPos=0
	end
	if LR>HR then
	dmNeg=math.max(LR,0)
	else
	dmNeg=0
	end
	


   sTR[period] = (sTR[period-1] - sTR[period-1]) / adxLen + TR.DATA[period];
   
   
    sDMPos[period]   = (sDMPos[period-1] - sDMPos[period-1]) / adxLen + dmPos
    sDMNeg[period] = (sDMNeg[period-1] - sDMNeg[period-1]) / adxLen + dmNeg

	local DIP = sDMPos[period] / sTR[period] * 100
	local DIN = sDMNeg[period] / sTR[period] * 100
	DX[period] = math.abs(DIP - DIN) / (DIP + DIN) * 100
	
	if period > first+adxLen then
 	aadx[period] = mathex.avg(DX, period-adxLen+1, period);	
	end
	

	
	
	if period<2 then
	xClose[period] = source.close[period]
	xOpen[period] = source.open[period]
	else 
	xClose[period] = (source.open[period]+source.high[period]+source.low[period]+source.close[period])/4;
	xOpen[period] = (xOpen[period-1] + source.close[period-1]) / 2
	end 
	xHigh[period] = math.max(source.high[period], math.max(xOpen[period], xClose[period]))
	xLow[period] = math.min(source.low[period], math.min(xOpen[period], xClose[period]))
 
 
 
 
	local v1 = math.abs(xHigh[period] - xClose[period-1])
	local v2 = math.abs(xLow[period] - xClose[period-1])
	local v3 = xHigh[period] - xLow[period]
	 
	trueRange[period] = math.max(v1, math.max(v2, v3))
	WilderAverage:update(mode);
	
	if period < WilderAverage.DATA:first() then
	return;
	end
	
	local atr;
	
	if useHeiken then
	atr = WilderAverage.DATA[period];
	else
	atr = ATR.DATA[period];
	end 
	
	if aadx[period]>aadx[period-1] and (aadx[period] < adxThresh or not aboveThresh) then
	m[period]=m1
	elseif aadx[period]<aadx[period-1] or (aadx[period] > adxThresh and aboveThresh) then
	m[period]=m2
	else
	m[period] = m[period-1]
	end 
	
	if DIP >= DIN then
	mUp=m[period]
	else
	mUp=m2
	end 
	if DIN >= DIP then
	mDn=m[period]
	else
	mDn=m2
	end 

	if useHeiken then
	src[period]=xClose[period]
	c[period]=xClose[period]
	t=(xHigh[period]+xLow[period])/2
	else
	src[period]=source[Price][period]
	c[period]=source.close[period]
	t=source.median[period]
	end 
	
	local up = t - mUp * atr
    local dn = t + mDn * atr
	
	
	if math.max(src[period-1], c[period-1]) > TUp[period-1] then
	TUp[period] = math.max(up,TUp[period-1])
	else
	TUp[period] = up
	end 
 
 
 
	
	 if math.min(src[period-1], c[period-1]) < TDown[period-1] then
	TDown[period] = math.min(dn, TDown[period-1])
	else
	TDown[period] = dn
	end 
	
	
	if math.min(src[period],math.min(c[period],source.close[period]))>TDown[period-1] then
	trend[period]=1
	elseif math.max(src[period],math.max(c[period],source.close[period]))<TUp[period-1] then
	trend[period]=-1
	else
	trend[period]=trend[period-1]
	end 
	
	
	
	if trend[period]==1 then
	Line[period]=TUp[period] 
	Line:setColor(period,  instance.parameters.color1);
	else
	Line[period]=TDown[period] 
	Line:setColor(period,  instance.parameters.color2);	
	end 
 	  
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
			if  trend[period] ==1
			and   trend[period-1] ~= 1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Line[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  trend[period] == - 1
			and   trend[period-1] ~= -1 
            then			
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 2   then  
			if  trend[period] == - 1
			and   trend[period-1] ~= -1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Line[period] 
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  trend[period] ==1
			and   trend[period-1] ~= 1 
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