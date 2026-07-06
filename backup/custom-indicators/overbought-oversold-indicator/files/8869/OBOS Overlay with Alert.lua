-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3664

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
    indicator:name("Overbought/Oversold Indicator Overlay");
    indicator:description("Overbought/Oversold Indicator Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PERIOD", "Period", "", 9);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN_color", "Color of DOWN", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OB_color", "Color of Overbought/Oversold", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));  
	indicator.parameters:addBoolean("Colouring" , "Show OB/OS Colouring "  , "", true);
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
   
   
 
	
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
	
	Parameters (1, "Up");
	Parameters (2, "Down");
	Parameters (3, "Overbought/Oversold");
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

local 	Number = 3;

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
local font;
local ShowAlert;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local iFIRST;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local source = nil;

-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};
local iopen, iclose, ihigh, ilow;
local UP, DOWN;
local Signal;
local Colouring;
-- Routine
function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	Colouring= instance.parameters.Colouring;	
	
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    iFIRST = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);
	
	
	 if   (nameOnly) then
        return;
    end

          Signal= instance:addInternalStream(0, 0);	
	    
	      BUFFER[1]= instance:addInternalStream(iFIRST, 0);	
		  BUFFER[2]= instance:addInternalStream(iFIRST, 0);	
          BUFFER[3]= instance:addInternalStream(iFIRST, 0);		 
          BUFFER[4]= instance:addInternalStream(iFIRST, 0);			   
		  BUFFER[5]= instance:addInternalStream(iFIRST, 0);				
		  BUFFER[6]= instance:addInternalStream(iFIRST, 0);		 
		  
		  UP= instance:addInternalStream(iFIRST, 0);
		  DOWN= instance:addInternalStream(iFIRST, 0);		  
		  
	      MA[1] = core.indicators:create("EMA", BUFFER[1],  PERIOD);
	      MA[2] = core.indicators:create("EMA", BUFFER[5],  PERIOD);
		  MA[3] = core.indicators:create("EMA",  BUFFER[6],  PERIOD);
		  MA[4] = core.indicators:create("EMA", UP,  PERIOD);
		   first = MA[4].DATA:first();

    
	
    iopen= instance:addInternalStream(0, 0);
	iclose= instance:addInternalStream(0, 0);
	--ilow= instance:addInternalStream(0, 0);
	--ihigh= instance:addInternalStream(0, 0);
	if Colouring then	  
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	else
	open = instance:addInternalStream(source:first(), 0);
    high= instance:addInternalStream(source:first(), 0);
    low = instance:addInternalStream(source:first(), 0);
    close = instance:addInternalStream(source:first(), 0);
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


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];

   open:setColor(period, instance.parameters.Neutral);	
	

    if period < iFIRST or not source:hasData(period) then
        return;		
    end
	
    
	BUFFER[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA[1]:update(mode);	
	BUFFER[3][period]= MA[1].DATA[period];
	
	if  period <  iFIRST + PERIOD  then
	return;
	end
		
	
	BUFFER[4][period] = mathex.stdev (BUFFER[1], period - PERIOD, period);
	
		
	BUFFER[5][period] =  (BUFFER[1][period]  - BUFFER[3][period]) *100  / BUFFER[4][period];

	MA[2]:update(mode);
	BUFFER[6][period]= MA[2].DATA[period] ;

	MA[3]:update(mode);
	UP[period]=MA[3].DATA[period];

	MA[4]:update(mode);
	DOWN[period] =MA[4].DATA[period];
	
	
	if UP[period] < DOWN[period] then
        iclose[period] = UP[period];
        iopen[period]  = DOWN[period];
    else
        iopen[period] = DOWN[period];
       iclose[period]  = UP[period];
    end
	
	 
	 
 
	
	 if iopen[period - 1] < iopen[period] and iclose[period-1] < iclose[period ] then
        open:setColor(period, instance.parameters.UP_color);
		Signal[period]= 1;
    elseif iopen[period - 1] > iopen[period] and iclose[period-1] > iclose[period ] then
         open:setColor(period, instance.parameters.DN_color);	
		 Signal[period]= -1;       
    else
         open:setColor(period, instance.parameters.OB_color);
         Signal[period]= 0;		 
    end
	
	
	 Activate (1, period);
	 Activate (2, period);
	 Activate (3, period);
	
end



function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period]==1 
			and   Signal[period-1]~=1 
			then
			           
						    
       

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Alert ", period);
							  SendAlert(" Alert ");  
							        
									Pop(Label[id], " Alert " );  	
								    
								 
						 
								    SendAlert(" Alert ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	    if id == 2  and ON[id]  then
	  
	       
			if  Signal[period]==-1 
			and   Signal[period-1]~=-1 
			then
			           
						    
       

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Alert ", period);
							  SendAlert(" Alert ");  
							        
									Pop(Label[id], " Alert " );  	
								    
								 
						 
								    SendAlert(" Alert ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	    if id == 3  and ON[id]  then
	  
	       
			if  Signal[period]==0
			and   Signal[period-1]~=0 
			then
			           
						    
       

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Alert ", period);
							  SendAlert(" Alert ");  
							        
									Pop(Label[id], " Alert " );  	
								    
								 
						 
								    SendAlert(" Alert ");
							 
			                  end			   
	         end
			
	  
	 
	  end
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
    
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
   

end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
 
   terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
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
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 

