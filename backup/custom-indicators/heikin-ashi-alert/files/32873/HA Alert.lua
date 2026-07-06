-- Id: 6536
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18230

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("HA Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live"); 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);

	
	
	indicator.parameters:addGroup("Alerts");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFileUp", "Up Trend Sound File", "", "");
    indicator.parameters:setFlag("SoundFileUp", core.FLAG_SOUND);
	
	indicator.parameters:addFile("SoundFileDown", "Down Trend Sound File", "", "");
    indicator.parameters:setFlag("SoundFileDown", core.FLAG_SOUND);
	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local Line;
local up, down;
local Size;
local Email;
local SendEmail;
local PlaySound, RecurrentSound ,SoundFileDown, SoundFileUp  ;
local Crossover, Crossunder;
local Alert;
local HA;
local Live;
local Show;
-- Routine
function Prepare(nameOnly)   
    source = instance.source;
   
	Size=instance.parameters.Size;
	Live=instance.parameters.Live;
	Show=instance.parameters.Show;
	
	 SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFileUp = instance.parameters.SoundFileUp;
		 SoundFileDown = instance.parameters.SoundFileDown;
    else
        SoundFileDown = nil;
		 SoundFileUp = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFileUp ~= ""), "Sound file must be chosen"); 
	assert(not(PlaySound) or (PlaySound and SoundFileDown ~= ""), "Sound file must be chosen"); 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	Crossover=nil;
	Crossunder=nil;	
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	HA = core.indicators:create( "HA", source)
	 first = HA.DATA:first();	
	
	 up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
  
end
local LAST;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

     HA:update(mode);
	 down:setNoData (period); 
      up:setNoData (period); 	
	  

if period < first then
return;
end

local Shift=0;

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	end

	
		    
			if 	HA.open[period-1] > HA.close[period-1] 
			and HA.open[period]  <  HA.close[period] 
			then
			
			               up:set(period , HA.low[period], "\217");	
						   down:setNoData (period); 	  
						   
			
			Crossunder = nil;
						   
							  if Crossover~=source:serial(period) 
							  and period == source:size()-1-Shift
							  then
							 Crossover=source:serial(period);
							 
							 SendAlert("HA Alert", "Crossed over"); 							        
							 Pop("HA Alert", " Cross Over " ); 
							 
							 SoundAlert(SoundFileUp);
							 EmailAlert( "Cross Over");
							 end
			elseif	HA.open[period-1] < HA.close[period-1] 
			and HA.open[period]  >  HA.close[period] 			
            then			
			
			               
			               down:set(period , HA.high[period], "\218");	
						   up:setNoData (period); 	  
						   
		     Crossover = nil;
		   
			                 if  Crossunder~=source:serial(period)
							 and period == source:size()-1-Shift
							 then
							 Crossunder=source:serial(period);
							 SoundAlert(SoundFileDown);			 
							 EmailAlert( "Cross Under");	
                              
                             SendAlert("HA Alert", "Crossed Under"); 							        
							 Pop("HA Alert", " Cross Under " ); 
							 							  
			                 end			   
	         end
			 
			 
    
end



function SoundAlert(SoundFile)

 if not PlaySound then
 return;
 end
 
  
 
 terminal:alertSound(SoundFile, RecurrentSound);
end

 


function EmailAlert( Subject)

if not SendEmail then
return
end

  
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")" .. source.close[NOW]..", " .. Subject..", " .. LABEL ;
  terminal:alertEmail(Email, Subject, text);
end

function Pop(label , note)
  
   if not Show then
   return;
   end
  
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
  

end


function SendAlert(label , note)
    if not ShowAlert then
        return;
    end
 
   terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
 
    
end
	 
function AsyncOperationFinished (cookie, success, message)
end
