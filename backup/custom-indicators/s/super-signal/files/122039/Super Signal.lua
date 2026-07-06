-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66909

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


-- Indicator profile initialization routine

function Init()
    indicator:name("Super Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("dist1", "1. Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("dist2", "2. Period", "", 21, 1, 2000);
    indicator.parameters:addInteger("Period", "ATR Period", "", 50, 1, 2000);
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("clrUP1", "1. Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrDN1", "1. Down Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("clrUP2", "2. Up Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("clrDN2", "2. Down Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("Size", "Size", "", 10); 
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	--indicator.parameters:addString("Live", "Execution", "", "End of Turn");
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

	
	Parameters (1, "1. Signal");	
	Parameters (2, "2. Signal");	
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

local dist1,dist2,Period; 
local first;
local source = nil;
local up1, down1;
local up2, down2; 
local Size;  
local ATR;

local Signal1;
local Signal2;
-- Routine
 function Prepare(nameOnly)    
 
    dist1= instance.parameters.dist1;
	dist2= instance.parameters.dist2; 
	Period= instance.parameters.Period;
	Size= instance.parameters.Size;
	
	local Parameters= dist1 ..  ", " .. dist2 ..  ", " .. Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
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
	 
			
    source = instance.source;
	ATR = core.indicators:create("ATR", source , Period); 
    first=math.max(ATR.DATA:first(),dist1, dist2);
  
    Signal1= instance:addInternalStream(0, 0); 
	Signal2= instance:addInternalStream(0, 0);  
   
 
    up1 = instance:createTextOutput ("Up1", "Up1", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP1, 0);
    down1 = instance:createTextOutput ("Dn1", "Dn1", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN1, 0);
	
	up2 = instance:createTextOutput ("Up2", "Up2", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP2, 0);
    down2 = instance:createTextOutput ("Dn2", "Dn2", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN2, 0);
    
	
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

 
    ATR:update(mode);
   
	
	if period < source:size()-1 then
	return;
	end
	

	Calculate();
	
	
	
		  
end

 

function Calculate()

   
 
 
    local Last1=Calculate1( );
	if Last1~=nil then
	Activate (1, Last1);
	end
	
    local Last2=Calculate2( ); 
    if Last2~=nil then
	Activate (2, Last2);
	end
    
end

function Calculate1 ( )

    local  Last=nil;
	for period=first, source:size()-1 do
     Signal1[period]=0; 

			up1:setNoData(period );
			down1:setNoData(period ); 

			local iShift=round(dist1/2, 0);

			if period > source:size()-1 -iShift then
			break;
			end
			 

			local min, max, minpos, maxpos = mathex.minmax (source, period-dist1, period+iShift);

			if period == maxpos then	
			down1:set(period, source.high[period]+ATR.DATA[period]/2, "\218", source.high[period]+ATR.DATA[period]/2);	
			Signal1[period]=-1;	
			Last=period;
			elseif period == minpos then	
			up1:set(period, source.low[period]-ATR.DATA[period]/2, "\217", source.low[period]-ATR.DATA[period]/2); 
			Signal1[period]=1;	
			Last=period;
			end	 
			
	end	 
	
	
	 return Last
end	 


function Calculate2 ()

    local Last=nil;
	for period=first, source:size()-1 do
     Signal2[period]=0;
 
	down2:setNoData(period );
	up2:setNoData(period ); 

	local iShift=round(dist2/2, 0);

	if period > source:size()-1 -iShift then
	break;
	end
	 

	local min, max, minpos, maxpos = mathex.minmax (source, period-dist2, period+iShift);


	if period == maxpos then	
	Signal1[period]=-1;	
	down2:set(period, source.high[period]+ATR.DATA[period] , "\218", source.high[period]+ATR.DATA[period] );	
    Last=period;	
	elseif period == minpos then	
	Signal1[period]=1;	
	up2:set(period, source.low[period]-ATR.DATA[period] , "\217", source.low[period]-ATR.DATA[period] ); 
	Last=period;	
	end	
	end
	
	
    return Last;
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


function Activate (id, period)


   
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal1[period] ==1  
			then
			           
						    
         
               
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
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
							  
			elseif  Signal1[period] ==-1  
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ");								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  elseif id == 1  and ON[id]  then
	  
	       
			if  Signal2[period] ==1  
			then
			           
						    
         
               
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
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
							  
			elseif  Signal2[period] ==-1  
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ");								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ");
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

