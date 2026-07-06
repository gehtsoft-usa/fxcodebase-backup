-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3918


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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Signal");
    indicator:description("Trend Signal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "", 9,2,2000);
	indicator.parameters:addInteger("RISK", "Risk", "", 30);
	indicator.parameters:addDouble("Shift", "Shift", "", 50);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_Color", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_Color", "Color of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("SIZE", "Font Size", "", 9);
	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	Parameters (1, "Alert")
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up={};
local Down={};
local Label={};
local ON={}; 
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local OnlyOnceFlag;


local PERIOD;
local RISK;
local SIZE;

local first;
local source = nil;

-- Streams block
local  TREND = nil;
local up,down;
local RANGE, AVG_RANGE;
local Signal;
local SIGNAL;
local Shift;
-- Routine
function Prepare(nameOnly)
    Signal = instance.parameters.Signal;
	Shift = (instance.parameters.Shift/100);
    SIZE = instance.parameters.SIZE;
    RISK = instance.parameters.RISK;
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD+1;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live; 
	 
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ", " .. tostring(RISK) .. ")";
    instance:name(name); 

    if   (nameOnly) then
        return;
    end
	
	RANGE = instance:addInternalStream(0, 0); 
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", SIZE, core.H_Center, core.V_Bottom, instance.parameters.Up_Color, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", SIZE, core.H_Center, core.V_Top, instance.parameters.Down_Color, 0);
    
	
	
	if Signal then
	SIGNAL = instance:addStream("SIGNAL", core.Line, "", "", core.rgb(255, 0, 0), first);
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
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
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
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    period = period-1;

    RANGE[period]=source.high[period]-source.low[period];
     
    if period < first or not source:hasData(period) then
	return;
	end
	
	local AVG_RANGE= mathex.avg(RANGE, period -PERIOD, period)
	
		
    local max=mathex.max (source.high, period- PERIOD-1, period-1);
	local min=mathex.min (source.low, period- PERIOD-1, period-1);


	local MIN = min+(max-min)*RISK/100;
	local MAX = max-(max-min)*RISK/100;
	
    	 
	 
	if core.crossesOver (source.close, MAX, period) and TREND ~= true then
	TREND = true;
	if Signal then
	SIGNAL[period]=1;
	end
	up:set(period, source.low[period]- AVG_RANGE*Shift, "\217", source.low[period]- AVG_RANGE*0.5);
	Activate (1,  period, 1);
	elseif core.crossesUnder (source.close, MIN, period) and TREND ~= false then
	TREND = false;
	if Signal then
	SIGNAL[period]=2;
	end
	down:set(period, source.high[period]+ AVG_RANGE*Shift,"\218", source.high[period]+ AVG_RANGE*0.5);
	Activate (1,  period, -1);
	end  
	
    
end



function Activate (id, period, SignalFlag)

   local Shift=1;
   

    if Live~= "Live" then
	period=period-1;
	Shift=Shift+1;
	end
 
	  if not  ON[id]  then
	  return;
	  end
	  
	       
			if  SignalFlag== 1 
			then
			           
			 
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  
							  EmailAlert(  Label[id], " Up Trend ", period);
							  SendAlert( Label[id], " Up Trend ", period);							        
							  Pop(Label[id], " Up Trend ", period );  	
								    
								 
							  end
			elseif SignalFlag== -1 
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);		
							 
							 EmailAlert(  Label[id], " Down Trend ", period);
							  SendAlert( Label[id], " Down Trend ", period);							        
							  Pop(Label[id], " Down Trend ", period); 
							 
			                  end			   
	         end
			
	  
	  
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , Subject, period)
  
   if not Show then
   return;
   end
   
         local date = source:date(period);
	     local DATA = core.dateToTable (date);
	
			
		   local delim = "\013\010";  
		   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
		   local Symbol= "Instrument : " .. source:instrument() ;
		   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
		   local TF= "Time Frame : " .. source:barSize();  
		   
			local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
   core.host:execute ("prompt", 1, profile:id() ,  text );
  

end


function SendAlert(label , Subject, period)
    if not ShowAlert then
        return;
    end
 
   
 
	     local date = source:date(period);
	     local DATA = core.dateToTable (date);
	
			
		   local delim = "\013\010";  
		   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
		   local Symbol= "Instrument : " .. source:instrument() ;
		   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
		   local TF= "Time Frame : " .. source:barSize();  
		   
			local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
        terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
    
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
   local TF= "Time Frame : " .. source:barSize();  
   
    text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
  
 terminal:alertEmail(Email, profile:id(), text);
end
	 



