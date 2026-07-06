-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27461
-- Id: 18406

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("WideRangePredictor");
    indicator:description("WideRangePredictor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addInteger("Confirmation", "Confirmation Period", "Period", 3,0, 10000);
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Range_Up", "Color of Range Up", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Range_Down", "Color of Range Down", " ", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Range_MA", "Color of Body MA", " ", core.rgb(0, 0, 255));
	
    indicator.parameters:addColor("Body_Up", "Color of Body Up", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Body_Down", "Color of Body Down", " ", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Body_MA", "Color of Body MA", " ", core.rgb(0, 0, 255));
	
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("AlertColor", "Alert Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
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


    indicator.parameters:addFile("AlertSound"..id, Label .. " Alert Sound", "", "");
    indicator.parameters:setFlag("AlertSound"..id, core.FLAG_SOUND);
	
 
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
local AlertSound={};
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
local A={};
local AlertColor;
local OnlyOnceFlag;
local font;
local ShowAlert;
 
local Shift=0; 
local Alert={}; 
local AlertLevel={};
local Confirmation;

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
	  AlertSound[i]=instance.parameters:getString("AlertSound" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       AlertSound[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (AlertSound[i] == "" or AlertSound[i] == nil ) ), "Sound file must be chosen");
        
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	A[i] = nil;	 
	end
		 
end	



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Range = nil;
local Body = nil;
local range, body;
local Neutral;
local Range_Up, Range_Down;
local Body_Up, Body_Down;
local UpStream, DownStream;
local Range_MA, Body_MA;
-- Routine
function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	AlertColor = instance.parameters.AlertColor;
	
	Confirmation=instance.parameters.Confirmation;
	
	Size=instance.parameters.Size;
	
  
    Period = instance.parameters.Period;
	Range_MA = instance.parameters.Range_MA;
	Body_MA = instance.parameters.Body_MA;
	Range_Up = instance.parameters.Range_Up;
	Range_Down = instance.parameters.Range_Down;
    Body_Up = instance.parameters.Body_Up;
	Body_Down = instance.parameters.Body_Down;
    source = instance.source;
	Neutral = instance.parameters.Neutral;	 
	 
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Range = instance:addStream("Range", core.Bar, name .. ".Range", "Range", Neutral, first);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
        Body = instance:addStream("Body", core.Bar, name .. ".Body", "Body", Neutral, first);
    Body:setPrecision(math.max(2, instance.source:getPrecision()));
		
		range = core.indicators:create("MVA", Range, Period);
	    body = core.indicators:create("MVA", Body, Period);
		
		UpStream = instance:addStream("Range_MA", core.Line, name .. ".Range_MA", "Range_MA", Range_MA, range.DATA:first() );
    UpStream:setPrecision(math.max(2, instance.source:getPrecision()));
		DownStream = instance:addStream("Body_MA", core.Line, name .. ".Body_MA", "Body_MA",Body_MA, body.DATA:first());
    DownStream:setPrecision(math.max(2, instance.source:getPrecision()));
       
		for i= 1, Number , 1 do
			Alert[i]=instance:addInternalStream(0, 0);
			AlertLevel[i]=instance:addInternalStream(0, 0);
		end
		
		Initialization();	
		instance:ownerDrawn(true);	 
    end
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
			
			  width, height = context:measureText (1,  "\108", 0);
              context:drawText (1,   "\108", AlertColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	

		    end
		  end
		    
		 
		end
		end
		
  
end		


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


     if period < first   then 
	return;
	end

    Range:setColor(period, Neutral);
	Body:setColor(period, Neutral);
  
	
   Range[period] = source.high[period] - source.low[period];
   Body[period] = math.abs(source.close[period]-source.open[period]);
   

   
    range:update(mode);
	body:update(mode);
	
	if period < range.DATA:first() then
	 return;
	end
	
	UpStream[period]=range.DATA[period];
	DownStream[period]=body.DATA[period];
	
	if Range[period] > range.DATA[period] then
	Range:setColor(period, Range_Up);
	else
	Range:setColor(period, Range_Down);
	end

  
    if Body[period] > body.DATA[period] then
	Body:setColor(period, Body_Up);
    else
	Body:setColor(period, Body_Down);
    end	
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
    Activate (1, period)
end


function ItIs (period)

if period <= Confirmation then
return false;
end

if Confirmation==0 then
return true;
end


local Return=true;

for i= period-1, period-1-(Confirmation -1), -1 do

if  Range[i] > range.DATA[i] then
Return=false;
end

end

return Return;



end

function Activate (id, period)


--[[


1. range(period)(close)>range ma
2.range (previous 3 bars )< range ma

alert message: " potentional trend reversal area"
alert : sound1
email : optional


]]


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Range[period] > range.DATA[period]
			and  ItIs(period)
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= range.DATA[period] 
	 
							  if A[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  A[id]=source:serial(period);
							  SoundAlert(AlertSound[id]);
							  EmailAlert(  Label[id], " Potentional trend reversal area ");
							  SendAlert( Label[id]," Potentional trend reversal area "); 
							  Pop(Label[id], " Potentional trend reversal area " );  
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

 


function EmailAlert( label , Subject )

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
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
   
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject )
    if not ShowAlert then
        return;
    end
	
	local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 
 
 

