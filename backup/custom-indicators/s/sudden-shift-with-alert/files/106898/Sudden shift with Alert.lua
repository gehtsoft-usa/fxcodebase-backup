-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63620

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
    indicator:name("Sudden shift with Alert");
    indicator:description("");
   indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("Calculation");		
	 
	indicator.parameters:addInteger("Period", "Period (in seconds)", "", 60);
	 indicator.parameters:addDouble("Level", "Alert Level (in pips)", "", 10);
 
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Shift Line Up");	
	Parameters (2, "Shift Line Down");	
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
local first;
local source = nil;
local Period;
local ShiftLine;
local Shift=0; 
local Level;
local BaseUnit;
local TimeFlagDown;
local TimeFlagUp;
-- Routine
function Prepare(nameOnly)   
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Level = instance.parameters.Level;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	
	Period = instance.parameters.Period;	
    BaseUnit= 1/ 86400;
     
	source = instance.source; 


    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Level  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	 
	first= source:first() ;

     TimeFlagDown=nil;
     TimeFlagUp=nil;
	 
	   
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
function Update(period ) 

     
    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	

   if period< source:size()-1-Shift  then
   return;
   end
   
 
     if TimeFlagUp==nil then
     TimeFlagDown=source:date(period);
     TimeFlagUp=source:date(period);
	 end
	 
	 date= source:date(period)-(Period*BaseUnit);
	 
	 Index= core.findDate (source, date, false);
	 
	 if Index== -1 then
	 return;
	 end
	 
	 PriceFlag=  source[Index];
 
	
	if ((source[period] - PriceFlag)/source:pipSize()) > Level and TimeFlagUp < source:date(period) then 
    Activate (1, period);
	TimeFlagUp=source:date(period)+(Period*BaseUnit)
	end
	if ((source[period] - PriceFlag)/source:pipSize()) < -Level  and TimeFlagDown < source:date(period) then 
    Activate (2, period);
	TimeFlagDown =source:date(period)+(Period*BaseUnit)
	end
	
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
		 
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Shift Up ", period);
							  SendAlert(" Shift Up ");  
							        
									Pop(Label[id], " Shift Up " );  	
								    
								 
							  end
		 
			
	  
	 
	  end
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			 
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source[period], core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Shift Down ", period);
							  SendAlert(" Shift Down ");  
							        
									Pop(Label[id], " Shift Down " );  	
								    
								 
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
   
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
   

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
   
    
   
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
	 
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 

