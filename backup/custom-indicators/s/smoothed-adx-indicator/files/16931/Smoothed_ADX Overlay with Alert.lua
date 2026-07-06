-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX#p111559

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




function Init()
    indicator:name("Smoothed ADX indicator Overlay with Alert");
    indicator:description("Smoothed ADX indicator Overlay with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25);
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33);
	
	indicator.parameters:addDouble("Level" , "ADX Level", "", 20);

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpColor", "Up color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownColor", "Down color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("UpStrong", "Up color Strong Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownStrong", "Down color Strong Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
	
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
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
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

	 

local first;
local source = nil;
local Period;
local Alpha1;
local Alpha2;
local Level;
local DIP_Temp;
local DIM_Temp;
local ADX_Temp;
local DMI_I;
local ADX_I;
local DIP=nil;
local DIM=nil;
local ADX=nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


local UpColor,DownColor, Neutral,UpStrong,DownStrong;
local Signal;

function Prepare(nameOnly) 
    source = instance.source;
    Period=instance.parameters.Period;
    Alpha1=instance.parameters.Alpha1;
    Alpha2=instance.parameters.Alpha2;
	Level=instance.parameters.Level;
	
	UpColor = instance.parameters.UpColor;
    DownColor= instance.parameters.DownColor;
	UpStrong = instance.parameters.UpStrong;
    DownStrong= instance.parameters.DownStrong;
    Neutral= instance.parameters.Neutral;
   
 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Alpha1 .. ", " .. Alpha2.. ", " .. Level .. ")";
    instance:name(name);
	
	if   (nameOnly) then
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
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	
	
	DIP_Temp = instance:addInternalStream(0, 0);
    DIM_Temp = instance:addInternalStream(0, 0);
    ADX_Temp = instance:addInternalStream(0, 0);
    DMI_I = core.indicators:create("DMI", source, Period);
    ADX_I = core.indicators:create("ADX", source, Period);
	
	first =ADX_I.DATA:first();
	
	
	DIP = instance:addInternalStream(0, 0);
    DIM = instance:addInternalStream(0, 0);
    ADX = instance:addInternalStream(0, 0);
	
	Signal= instance:addInternalStream(0, 0);
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	 for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
 
end



local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
		    end
		  end
		    
		 
		end
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

function Update(period, mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
   if (period<first) then
   open:setColor(period, Neutral);	
   return;
   end
   
    DMI_I:update(mode);
    ADX_I:update(mode);
    DIP_Temp[period]=2*DMI_I.DIP[period]+(Alpha1-2)*DMI_I.DIP[period-1]+(1-Alpha1)*DIP_Temp[period-1];
    DIM_Temp[period]=2*DMI_I.DIM[period]+(Alpha1-2)*DMI_I.DIM[period-1]+(1-Alpha1)*DIM_Temp[period-1];
    ADX_Temp[period]=2*ADX_I.DATA[period]+(Alpha1-2)*ADX_I.DATA[period-1]+(1-Alpha1)*ADX_Temp[period-1];
    DIP[period]=Alpha2*DIP_Temp[period]+(1-Alpha2)*DIP[period-1];
    DIM[period]=Alpha2*DIM_Temp[period]+(1-Alpha2)*DIM[period-1];
    ADX[period]=Alpha2*ADX_Temp[period]+(1-Alpha2)*ADX[period-1];
	
	
	Signal[period]= Signal[period-1];
	
	if DIP[period] > DIM[period] then
		
		if DIP[period] > Level then
		open:setColor(period,UpStrong);	
		Signal[period]=2;
		else
		open:setColor(period,UpColor);	
		Signal[period]=1;
		end	
	elseif DIP[period] < DIM[period] then
	 
		if DIM[period] > Level then
		Signal[period]=-2;
		open:setColor(period,DownStrong);	
		else
		Signal[period]=-1;
		open:setColor(period,DownColor);	
		end
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


 
   
    Alert[id][period]= 0;	
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if   Signal[period] == 2
			and   Signal[period-1]~=2
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= source.low[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Strong Up Trend ");
							  SendAlert( Label[id]," Strong Up Trend "); 
							  Pop(Label[id], " Strong Up Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif   Signal[period] == -2
			and   Signal[period-1]~= -2
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= source.high[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Strong Down Trend  ");								 
							 Pop(Label[id], " Strong Down Trend ", period );  	
							 SendAlert( Label[id]," Strong Down Trend  ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	  if   Signal[period] == 1
			and   Signal[period-1]~=1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= source.low[period] 
						   
			
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
							  
			elseif   Signal[period] == -1
			and   Signal[period-1]~= -1
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= source.high[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend  ");								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend  ");
							 OnlyOnceFlag=false;
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


