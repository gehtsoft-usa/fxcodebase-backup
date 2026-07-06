

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65037


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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Three Inside Outside Up Down candle pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("S1", "Show Bullish Three Outside Signal", "", true);
	indicator.parameters:addBoolean("S2", "Show Bearish Three Outside Signal", "", true);
	indicator.parameters:addBoolean("S3", "Show Bullish Three Inside Signal", "", true);
	indicator.parameters:addBoolean("S4", "Show Bearish Three Inside Signal", "", true);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color_S1","Bullish Three Outside Signal Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Color_S2", "Bearish Three Outside Signal Color ", "", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Color_S3","Bullish Three Inside Signal Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Color_S4", "Bearish Three Inside Signal Color ", "", core.COLOR_DOWNCANDLE);
	
 
	
	indicator.parameters:addInteger("Size", "Size", "", 15);
	
	
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

	
	Parameters (1, "Three Outside Alert");	
	Parameters (2, "Three Inside Alert");
     
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

local 	Number = 2;
local Up={};
local Down={};
local Label={};
local ON={};
--local Size;
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
--local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
--local AlertLevel={};
local ToTime;
local Shift=0; 

local source;
local BullishThreeOutside, BearishThreeOutside;
local BullishThreeInside, BearishThreeInside;
local Size;
local S1, S2, S3, S4;

function Prepare(nameOnly) 
    source = instance.source;
	
	S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
	S4=instance.parameters.S4;
	
	Size=instance.parameters.Size;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	if S1 then
    BullishThreeOutside = instance:createTextOutput ("BullishThreeOutside", "BullishThreeOutside", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Color_S1, 0);
	end
	
	if S2 then
    BearishThreeOutside = instance:createTextOutput ("BearishThreeOutside", "BearishThreeOutside", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Color_S2, 0);
    end
	
	if S3 then
    BullishThreeInside = instance:createTextOutput ("BullishThreeInside", "BullishThreeInside", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Color_S3, 0);
	end
	
	if S4 then
    BearishThreeInside = instance:createTextOutput ("BearishThreeInside", "BearishThreeInside", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Color_S4, 0);
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
	--UpTrendColor = instance.parameters.UpTrendColor;
	--DownTrendColor = instance.parameters.DownTrendColor;
	--Size=instance.parameters.Size;
	
	     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
	--	AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
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

 
 
function Update(period, mode)
     if (period <= 3) then
	 return;
	 end
	 
	 
	  Alert[1][period]=0;
	  Alert[2][period]=0;
	
	 period = period-3;
	 if S1 then
	 BullishThreeOutside:setNoData(period);
	 end
	 if S2 then
	 BearishThreeOutside:setNoData(period);
	 end
	 if S3 then
	 BullishThreeInside:setNoData(period);
	 end
	 if S4 then
	 BearishThreeInside:setNoData(period);
	 end
	 
	 if source.close[period]< source.open[period]
	 and source.close[period+1] >  source.high[period]
	 and source.close[period+2] >  source.high[period+1]
	 and S1
	 then
	 BullishThreeOutside:set(period, source.low[period ], "\217", source.low[period ]);
     Alert[1][period]=1;
	 elseif source.close[period]> source.open[period]
	 and source.close[period+1] <  source.low[period]
	 and source.close[period+2] < source.low[period+1]
	 and S2
	 then
	 Alert[1][period]=-1;
	 BearishThreeOutside:set(period, source.high[period ], "\218", source.high[period ]);
	 end
	 
	 
	  if source.close[period]< source.open[period]
	  and source.high[period+1] <=  source.high[period]
	  and source.low[period+1] >=  source.low[period]
	 and source.close[period+2] >  source.high[period+1]
	 and S3
	 then
	 Alert[2][period]=1;
	 BullishThreeInside:set(period, source.low[period ], "\217", source.low[period ]);
 
	 elseif source.close[period]> source.open[period]
	 and source.high[period+1] <=  source.high[period]
	  and source.low[period+1] >=  source.low[period]
	 and source.close[period+2] < source.low[period+1]
	 and S4
	 then
	 Alert[2][period]=-1;
	 BearishThreeInside:set(period, source.high[period ], "\218", source.high[period ]);
	 end
	 
	 
	   if Live~= "Live" then
	period=period-1;
	Shift=4;
	else
	Shift=3;
	end
	
	 
 
    Activate (1, period); 
	Activate (2, period);
	 
 
end



function Activate (id, period)

 
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Alert[1][period]== 1
			and   Alert[1][period-1]~= 1
			then           
						    
          
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift 
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Bullish ");
							  SendAlert( Label[id]," Bullish "); 
							  Pop(Label[id], " Bullish ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Alert[1][period]== -1
			and   Alert[1][period-1]~= -1
            then			
			
			            			 
			           
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift 
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Bearish ");								 
							 Pop(Label[id], " Bearish ", period );  	
							 SendAlert( Label[id]," Bearish ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  Alert[2][period]== 1
			and   Alert[2][period-1]~= 1
			  then         
						    
          
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Bullish ");
							  SendAlert( Label[id]," Bullish "); 
							  Pop(Label[id], " Bullish ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Alert[2][period]== -1
			and   Alert[2][period-1]~= -1
            then			
			
			            			 
			           
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Bearish ");								 
							 Pop(Label[id], " Bearish ", period );  	
							 SendAlert( Label[id]," Bearish ");
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

 
 
 
