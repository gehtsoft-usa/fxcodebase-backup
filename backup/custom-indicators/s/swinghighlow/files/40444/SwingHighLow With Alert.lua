-- Id: 19910

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23506 
 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Swing High/Low");
    indicator:description("Swing High/Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
     
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("ShiftPosition", "Shift Position", "", false);	 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Size", "Arrow Size", "", 12);
    indicator.parameters:addColor("clrUP", "Up Swing Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Swing Color", "", core.COLOR_DOWNCANDLE);
	
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

	
	Parameters (1, "Top Alert");	
	Parameters (2, "Bottom Alert");
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
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local OnlyOnceFlag;
local ShowAlert;
local ToTime;
local Shift=0; 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local SLOPE;
local SLH;
local LOW,HIGH;
local LAST;
local Size;
local ShiftPosition;
local Signal;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first()+6;
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

	 if (nameOnly) then  
	return;
	end
	
	
	
	Size= instance.parameters.Size;
	ShiftPosition= instance.parameters.ShiftPosition;
	
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
	 
	
    
 
	Signal = instance:addInternalStream(0, 0);
  
     up = instance:createTextOutput ("Up", "Up", "Verdana", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
	 down = instance:createTextOutput ("Dn", "Dn", "Verdana", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
   
	
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
function Update(period)
    local Note, Color;
	if period < first or not source:hasData(period) then
        return;
    end

	  
	  if period == first then
	  HIGH=period;
	  LOW=period;
	  end
	  Signal[period]=0;
	
	
	 local curr = period - 2;
        if (source.high[curr]  > source.high[curr -1]  and source.high[curr] > source.high[curr -2] and
            source.high[curr]  > source.high[curr + 1] and source.high[curr]  > source.high[curr+2]) then
			
			if LAST  and  source.high[HIGH] < source.high[curr] then
			up:setNoData (HIGH);
			elseif LAST then
			return;
			end
			
			
			if source.high[curr] > source.high[HIGH]  then
             Note="HH";
			 Color = instance.parameters.clrUP;
			 Signal[curr]=2;
			else
			Note="LH";
			Signal[curr]=1;
			Color = instance.parameters.clrDN;
			end
			
			
			if ShiftPosition then
			up:set(curr+2, source.high[curr], Note, source.high[curr],Color);
			else
			up:set(curr, source.high[curr], Note, source.high[curr],Color);
			end
            LAST= true;			
			HIGH= curr;
           
        end
         
        if (source.low[curr]  < source.low[curr -1] and source.low[curr] < source.low[curr -2] and
            source.low[curr] < source.low[curr + 1] and source.low[curr] < source.low[curr+2]) then
			
			if not LAST   and  source.low[LOW] > source.low[curr] then
			down:setNoData (LOW);
			elseif not LAST then
			return;			
			end
			
			if source.low[curr] < source.low[LOW]  then
             Note="LL";
			 Color = instance.parameters.clrDN;
			 Signal[curr]=-2;
			else
			Note="HL";
			Signal[curr]=-1;
			Color = instance.parameters.clrUP;
			end
			if ShiftPosition then
			down:set(curr+2, source.low[curr], Note, source.low[curr],Color);
            else			
            down:set(curr, source.low[curr], Note, source.low[curr],Color);
			end
            LOW= curr;
			LAST= false;
			
        end
	
         
    if Live~= "Live" then
	curr=curr-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
     if curr < first then
	 return;
	 end
	
    Activate (1, curr);
	Activate (2, curr);
	 
end



function Activate (id, period)

 
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period] == 2  
			then
			           
						    
         
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift-2
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Higher High ");
							  SendAlert( Label[id]," Higher High "); 
							  Pop(Label[id], " Higher High ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif Signal[period] == 1  
            then			
			
			           
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift-2
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Lower High ");								 
							 Pop(Label[id], " Lower High ", period );  	
							 SendAlert( Label[id]," Lower High ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  Signal[period] == -2  
			then
			           
						    
         
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift-2
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Lower Low ");
							  SendAlert( Label[id]," Lower Low "); 
							  Pop(Label[id], " Lower Low ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif Signal[period] == -1  
            then			
			
			           
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift-2
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Higher Low ");								 
							 Pop(Label[id], " Higher Low ", period );  	
							 SendAlert( Label[id]," Higher Low ");
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
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
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
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
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
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end

 
 
 
