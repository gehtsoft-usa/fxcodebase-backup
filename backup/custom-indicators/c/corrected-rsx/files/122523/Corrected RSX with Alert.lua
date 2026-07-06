-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67056
-- Id:  

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
    indicator:name("Corrected RSX with Alert");
    indicator:description("Corrected RSX");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSIperiod", "RSI Period", "", 15); 

    indicator.parameters:addGroup("RSX Line Style");
    indicator.parameters:addColor("LineUp1", "Up Line Color", "Line Color", core.rgb(0, 191, 255));
	indicator.parameters:addColor("LineDown1", "Down Line Color", "Line Color", core.rgb(255, 164, 96));
	indicator.parameters:addColor("LineNeutral1", "Neutral Line Color", "Line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_DASHDOT  );
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("RSX Line Style");
    indicator.parameters:addColor("LineUp2", "Up Line Color", "Line Color", core.rgb(0, 191, 255));
	indicator.parameters:addColor("LineDown2", "Down Line Color", "Line Color", core.rgb(255, 164, 96));
	indicator.parameters:addColor("LineNeutral2", "Neutral Line Color", "Line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style",core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
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

local Number = 1;
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
local RSIperiod; 
local Up1, Down1, Neutral1;
local Up2, Down2, Neutral2;
local RSX,CA;
local SA;
local smallRsiValue;
local f88;
 


 
 local f8;
 local f18;
 local f20; 
 local f90;
 
 
 local f10;
 local f0; 
 local v8;
 local f28;
 local f30;
 local vC;
 local f38;
 local f40;
 local v10;
 local f48;
 local f50;
 local v14;
 local f58;
 local f60;
 local v18;
 local  f68;
 
 local f70;
 local v1C;
 local f78;
 local f80;
 local v20;
 
 
 local Color;
function Prepare(nameOnly)
    
	
	source = instance.source;
	
    RSIperiod=instance.parameters.RSIperiod;
	--Len=instance.parameters.RSIperiod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSIperiod .. ")";
    instance:name(name);
    if nameOnly then
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
	
	first = source:first();
   
   -- SA = instance:addInternalStream(0, 0);
	  
	 f0 = instance:addInternalStream(0, 0);
	 f8 = instance:addInternalStream(0, 0);
 
     f20 = instance:addInternalStream(0, 0); 
     f90 = instance:addInternalStream(0, 0);
 
 
     f10 = instance:addInternalStream(0, 0);
  
	 v8 = instance:addInternalStream(0, 0);
	 f28 = instance:addInternalStream(0, 0);
	 f30 = instance:addInternalStream(0, 0);
	 vC = instance:addInternalStream(0, 0);
	 f38 = instance:addInternalStream(0, 0);
	 f40 = instance:addInternalStream(0, 0);
	 v10 = instance:addInternalStream(0, 0);
	 f48 = instance:addInternalStream(0, 0);
	 f50 = instance:addInternalStream(0, 0);
	 v14 = instance:addInternalStream(0, 0);
	 f58 = instance:addInternalStream(0, 0);
	 f60 = instance:addInternalStream(0, 0);
	 v18 = instance:addInternalStream(0, 0);
	 f68 = instance:addInternalStream(0, 0);
	 
	 f70 = instance:addInternalStream(0, 0);
	 v1C = instance:addInternalStream(0, 0);
	 f78 = instance:addInternalStream(0, 0);
	 f80 = instance:addInternalStream(0, 0);
	 v20 = instance:addInternalStream(0, 0);
	 
	 Color = instance:addInternalStream(0, 0);
	
	Up1=instance.parameters.LineUp1;
	Down1=instance.parameters.LineDown1;
	Neutral1=instance.parameters.LineNeutral1;
    Up2=instance.parameters.LineUp2;
	Down2=instance.parameters.LineDown2;
	Neutral2=instance.parameters.LineNeutral2;
  
	
    RSX = instance:addStream("RSX", core.Line, name .. ".RSX", "RSX",Up1, first);
    RSX:setWidth(instance.parameters.width1);
    RSX:setStyle(instance.parameters.style1);
    RSX:addLevel(30);
    RSX:addLevel(70);
	RSX:setPrecision(math.max(4, source:getPrecision()));
	
	
	CA = instance:addStream("CA", core.Line, name .. ".CA", "CA", Up2, first);
    CA:setWidth(instance.parameters.width2);
    CA:setStyle(instance.parameters.style2); 
	CA:setPrecision(math.max(4, source:getPrecision()));
	
	smallRsiValue = 0.0000000000000001
	
	if (RSIperiod-1 >= 5) then
	  f88 = RSIperiod-1.0
	 else
	  f88 = 5.0
 end 
 
    f18 = 3.0 / (RSIperiod + 2.0)
	f20 = 1.0 - f18;
	
	
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
 
	
   if (period<first) then
   return;
   end
    

 f0[period]=f0[period-1];

 
 
if (f90[period-1] == 0.0) then
 f90[period] = 1.0
 f0[period] = 0.0
 
 f8[period] = 100.0*(source[period])
 

else
 if (f88 <= f90[period-1]) then
  f90[period] = f88 + 1
 else
  f90[period] = f90[period-1] + 1
 end 
 
 f10[period] = f8[period-1]
 f8[period] = 100*source[period];
 v8[period] = f8[period] - f10[period]
 f28[period] = f20  * f28[period-1] + f18  * v8[period]
 f30[period] = f18  * f28[period] + f20  * f30[period-1]
 vC[period] = f28[period] * 1.5 - f30[period] * 0.5
 f38[period] = f20  * f38[period-1] + f18  * vC[period]
 f40[period] = f18  * f38[period] + f20  * f40[period-1]
 v10[period] = f38[period] * 1.5 - f40[period] * 0.5
 f48[period] = f20  * f48[period-1] + f18  * v10[period]
 f50[period] = f18  * f48[period] + f20  * f50[period-1]
 v14[period] = f48[period] * 1.5 - f50[period] * 0.5
 f58[period] = f20  * f58[period-1] + f18  * math.abs(v8[period])
 f60[period] = f18  * f58[period] + f20  * f60[period-1]
 v18[period] = f58[period] * 1.5 - f60[period] * 0.5
 f68[period] = f20  * f68[period-1] + f18  * v18[period]
 
 f70[period] = f18  * f68[period] + f20  * f70[period-1]
 v1C[period] = f68[period] * 1.5 - f70[period] * 0.5
 f78[period] = f20  * f78[period-1] + f18  * v1C[period]
 f80[period] = f18  * f78[period] + f20  * f80[period-1]
 v20[period] = f78[period] * 1.5 - f80[period] * 0.5
 
 if ((f88 >= f90[period]) and (f8[period] ~= f10[period])) then
  f0[period] = 1.0
 end
 if ((f88 == f90[period]) and (f0[period] == 0.0)) then
  f90[period] = 0.0
 end
end
 
 
if ((f88 < f90[period]) and (v20[period] > smallRsiValue)) then
 
 RSX[period] = (v14[period] / v20[period] + 1.0) * 50.0
	 if (RSX[period] > 100.0) then
	  RSX[period] = 100.0
	 end 
	 if (RSX[period] < 0.0) then
	  RSX[period] = 0.0
	 end 
else
 RSX[period] = 50.0
end
 
 
if period < RSIperiod then
return;
end
 
--Corrected function 
 local STD= mathex.stdev(RSX, period-RSIperiod+1, period) 
 local v1 =(STD)^2;
 local v2 = (CA[period-1]-RSX[period])^2;
 
 
 
 if(v2<v1) then
  k =0    
 else
  k =1-v1/v2 
 end
 
 
  
   CA[period]=CA[period-1]+k*(RSX[period]-CA[period-1])
  
  
--final cut
if CA[period]>CA[period-1] then
RSX:setColor(period, Up1);
CA:setColor(period, Up2); 
Color[period]=1;
elseif CA[period]<CA[period-1] then
RSX:setColor(period, Down1);
CA:setColor(period, Down2);
Color[period]=-1;
else
RSX:setColor(period, Neutral1);
CA:setColor(period, Neutral2);
Color[period]=0
end


   if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
     
    Activate (1, period);
 
end


function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if  ON[id]  then
	  
	       
			if Color[period] ~= Color[period-1] 
			then
			           
						    
                if Color[period-1]< Color[period] then
                Alert[id][period]= 1;	
				else
				Alert[id][period]= -1;	 
				end
				
 				AlertLevel[id][period]= RSX[period] 
						   
			
			    if Color[period]== 1 then
				AlertText="Up";
				elseif Color[period]== -1 then
				AlertText="Down";
				else
				AlertText="Neutral";
				end
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], AlertText);
							  SendAlert( Label[id], AlertText); 
							  Pop(Label[id], AlertText, period );  
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

