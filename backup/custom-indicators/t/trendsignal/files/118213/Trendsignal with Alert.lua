-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65833

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Trend Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("RISK", "Risk", "", 3);
    indicator.parameters:addInteger("SSP", "SSP", "", 9);
 
	
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("Size", "Size", "", 9);
	
	
	    indicator.parameters:addGroup("Alert Parameters");  
	--indicator.parameters:addString("Live", "Execution", "", "Live");
   -- indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	--indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
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

	
	Parameters (1, " Signal ");	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Down Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Up Trend Sound", "", "");
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
--local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local RISK, SSP ; 
local K;
local Range;
local Trend;
local UpColor, DownColor,Size;
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local up, down;
local Line;
local LastCandle;
-- Routine
 function Prepare(nameOnly)   
 
    RISK= instance.parameters.RISK;
	SSP= instance.parameters.SSP; 
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	Size= instance.parameters.Size;
	
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  RISK .. ", " ..  SSP .. ")";
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
	--Live = instance.parameters.Live;
	 
	
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, UpColor, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, DownColor, 0);
	
	
	 Range = instance:addInternalStream(0, 0);
	 Trend = instance:addInternalStream(0, 0);
	 K=33-RISK;

   
    source = instance.source;     
    first= source:first()+SSP;
	
	
	Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.color, first);
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
	
 
	
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
function Update(period, mode)
  
  
    LastCandle=period;
	
    Range[period]= source.high[period]-source.low[period];
  
    if period < first then
	return;
	end
	
	 up:setNoData(period);
	 down:setNoData(period);
	
	local AvgRange=mathex.avg(Range, period-SSP+1, period);
	local SsMin, SsMax=mathex.minmax(source, period-SSP+1, period);
	
	local  smin = SsMin+(SsMax-SsMin)*K/100;
    local  smax = SsMax-(SsMax-SsMin)*K/100;	
	
	  if(source.close[period]<smin) then       
         Trend[period]=-1;
   
	  
      elseif(source.close[period]>smax) then        
         Trend[period]=1;
       else
	   
	   Trend[period]=Trend[period-1];
	   
	   end
		
	 
	  if( Trend[period]~=  Trend[period-1] and Trend[period]==1) then       
        Value=source.low[period]-Range[period]*0.5;
		up:set(period, Value, "\217", Value);
      end

      if( Trend[period]~=  Trend[period-1] and Trend[period]==-1) then
         Value=source.high[period]+Range[period]*0.5;		 
		 down:set(period , Value, "\218", Value);
      end
	  
	  
	
	  period=period-1;
	  
	  if( Trend[period]~=  Trend[period-1]  ) then
	  
	  local  Last, Price1,Price2 = Get(period);
	   if Last~=nil then
			   core.drawLine(Line, core.range(Last, period), Price1, Last, Price2, period, instance.parameters.color, first);
			   
				   if LastCandle == source:size()-1 then
				   Activate (1, period);  
				   end
		  end		   
      end	  
	  
	  
	 	  
end

function  Get(period)

  local Price1, Price2;
  local   Last=nil;
  
  for i= period-1, first, -1 do
  
	  Last=i;
	  if Trend[i]~=  Trend[i-1] then  
	  break;
	  end
	  
	  
  
  end
  
  
  if Trend[Last] == 1 then
  Price1=source.low[Last];  
  else
   Price1=source.high[Last];  
  end
  
  
    
  if Trend[period] == 1 then
  Price2=source.low[period];  
  else
   Price2=source.high[period];  
  end
  
  
  return Last,  Price1, Price2;
  
end



function Activate (id, period)


 
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if   Trend[period]== 1
			and    Trend[period-1]~= 1
			then
			           
						    
          
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Down Trend ");
							  SendAlert( Label[id]," Down Trend "); 
							  Pop(Label[id], " Down Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif   Trend[period]== -1
			and    Trend[period-1]~= -1
            then			
			
			             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Up Trend ");								 
							 Pop(Label[id], " Up Trend ", period );  	
							 SendAlert( Label[id]," Up Trend ");
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

 
 
 