-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4971

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
    indicator:name("ATR pips indicator");
    indicator:description("ATR pips indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.7);
    indicator.parameters:addString("Corner", "Corner", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Top-Right", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Top-Left", "", "1");
    indicator.parameters:addStringAlternative("Corner", "Bottom-Right", "", "2");
    indicator.parameters:addStringAlternative("Corner", "Bottom-Left", "", "3");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Neutral Color", "Color", core.COLOR_LABEL );
	indicator.parameters:addColor("Color", "Neutral Color", "Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("FontSize", "Font size", "", 20);
    indicator.parameters:addInteger("H_Shift", "Horizontal shift", "", 0);
    indicator.parameters:addInteger("V_Shift", "Vertical shift", "", 50);
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	indicator.parameters:addDouble("AlertLevel", "Alert Level", "", 20);

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Level Cross");	
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
local AlertLevel;
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
local Shift=0; 
 

local first;
local source = nil;
local Period;
local Multiplier;
local Corner;
local ATR;
local font;

function Prepare(nameOnly)
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	AlertLevel= instance.parameters.AlertLevel;
	
	
    Period=instance.parameters.Period;
    Multiplier=instance.parameters.Multiplier;
    Corner=tonumber(instance.parameters.Corner);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Multiplier .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ATR = core.indicators:create("ATR", source, Period);
    first = ATR.DATA:first();
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
	
	Initialization();
	
	core.host:execute("subscribeTradeEvents", 1, "offers");
    core.host:execute ("setTimer", 3 , 1);
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




function Update(period, mode)

   if (period<source:size()-1)
   or period < first 
   then
   return;
   end
   
    ATR:update(mode);
	
	
	local LabelColor=instance.parameters.Neutral 
    local Value1= ((ATR.DATA[period]/source:pipSize())*Multiplier);			 
 	   
	if Value1 > AlertLevel then
	LabelColor=instance.parameters.Color;
    end
	
	
    
    local Text="" .. math.floor(Multiplier*100) .. "% of ATR (" .. Period .. "):" ..  string.format("%." .. math.max(2, source:getPrecision()) .. "f",( (ATR.DATA[period]*Multiplier)/source:pipSize()))  .. " pips";
    if Corner==0 then
     core.host:execute("drawLabel1", 1,-instance.parameters.H_Shift, core.CR_RIGHT,instance.parameters.V_Shift, core.CR_TOP, core.H_Left, core.V_Bottom, font,LabelColor,  Text);
    elseif Corner==1 then
     core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_LEFT,instance.parameters.V_Shift, core.CR_TOP, core.H_Right, core.V_Bottom, font, LabelColor,  Text);
    elseif Corner==2 then
     core.host:execute("drawLabel1", 1,-instance.parameters.H_Shift, core.CR_RIGHT,-instance.parameters.V_Shift, core.CR_BOTTOM, core.H_Left, core.V_Top, font, LabelColor,  Text);
    else
     core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_LEFT,-instance.parameters.V_Shift, core.CR_BOTTOM, core.H_Right, core.V_Top, font, LabelColor,  Text);
    end 

   
   
end



function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	  
	       	Value1= ((ATR.DATA[period]/source:pipSize())*Multiplier);			 
			Value2= ((ATR.DATA[period-1]/source:pipSize())*Multiplier);				   
	  
	       
			if  AlertLevel < 	Value1
			and  AlertLevel  >= 	Value2
			then
			           
						    
          

 		
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  AlertLevel > 	Value1
			and  AlertLevel <= 	Value2
            then			
			
			           
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)

    if cookie~=1
	and cookie~= 3 
	then
	return;
	end
	
	


    local period= source:size()-1;
	
    if Live~= "Live" then
	period=period-1;
	end
	
	
     if period < first then
	 return;
	 end
	
    Activate (1, period)
	
	
	
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
	 



