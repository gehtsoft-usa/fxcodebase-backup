-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62945


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
    indicator:name("Support Resistance Levels");
    indicator:description("Support Resistance Levels");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	 indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addInteger("Delta", "Delta (in Pips)", "Delta", 10);
     indicator.parameters:addDouble("Level", "Price Level", "Price Level", 0);
	
	indicator.parameters:addGroup("Style");
 
	indicator.parameters:addColor("ZoneColor", "Zone Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("LineColor", "Line Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addString("Label", "Label", "", "Label");
 
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
 
	
	indicator.parameters:addGroup("Alerts");   
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
    indicator.parameters:addFile("CrossOver", "Cross Over Sound File", "", "");
    indicator.parameters:setFlag("CrossOver", core.FLAG_SOUND);
	indicator.parameters:addFile("CrossUnder", "Cross Under Sound File", "", "");
    indicator.parameters:setFlag("CrossUnder", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Flag;
local PlaySound, RecurrentSound;
local ShowAlert;
local first;
local source = nil;
local Label;
local init = false;
local transparency;
local CrossOver, CrossUnder;
local Delta;
local Level;
local LineColor;
local ZoneColor;
local SendEmail, Email;
-- Routine
function Prepare(nameOnly)
    Label= instance.parameters.Label;    
	ZoneColor= instance.parameters.ZoneColor;
	LineColor= instance.parameters.LineColor;
    Level= instance.parameters.Level;
	SendEmail= instance.parameters.SendEmail;
	Email= instance.parameters.Email;
	
	Flag=0;
	
    ShowAlert = instance.parameters.ShowAlert;
	PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        CrossOver = instance.parameters.CrossOver;
		CrossUnder = instance.parameters.CrossUnder;
    else
        CrossOver = nil;
		CrossUnder = nil;
    end
	
	
	local name = profile:id() .. " : " .. source:name() .. " : " ..Level.. " +/- " ..Delta .. " pips";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    assert(not(PlaySound) or (PlaySound and CrossUnder ~= ""), "Sound file must be chosen"); 
	assert(not(PlaySound) or (PlaySound and CrossOver ~= ""), "Sound file must be chosen"); 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	
    source = instance.source;
    first = source:first();
	
	Delta= instance.parameters.Delta * source:pipSize();
 
    
 

       instance:ownerDrawn(true); 
end

function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
     
     terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function Pop(label , note)
  
   if not Show then
   return;
   end
  
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
   

end

function SoundAlert(SoundFile)
    if not PlaySound then
        return;
    end
 
      terminal:alertSound(SoundFile, RecurrentSound);
end

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

  
 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
 
   
    text = Note  .. delim ..  Symbol   .. delim .. Time;
  
    terminal:alertEmail(Email, profile:id(), text);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

if period  < source:size()-1 then
return;
end

                if source[source:size()-1] > Level
				and source[source:size()-2] <= Level 
				and Flag ~= 1
				then
				Flag=1;
				Pop( " Support Resistance Levels " , " Cross Over ")
				SoundAlert(CrossOver);				
				SendAlert(" Cross Over ");
				EmailAlert(  " Support Resistance Levels ", " Cross Over ", period);
				elseif source[source:size()-1] < Level
				and source[source:size()-2] >= Level 
				and Flag ~= -1
				then
				Flag=-1;
				Pop( " Support Resistance Levels " ," Cross Under ")
				SoundAlert(CrossUnder);
				SendAlert(" Cross Under ");
				EmailAlert(  " Support Resistance Levels ", " Cross Under ", period);
                end
end


function Draw(stage, context)

    if stage ~=2 then
	return;
	end
	

 
					if not init then
						context:createPen (1, context.SOLID, 1, ZoneColor);
						context:createSolidBrush (2, ZoneColor);
						context:createPen (3, context.SOLID, 1, LineColor);
						
						transparency=context:convertTransparency (instance.parameters.transparency);
						init = true;
						
						Flag=0;
					end
 
                  
  
	             visible1, y3= context:pointOfPrice (Level);
			     visible2, y1 = context:pointOfPrice (Level+Delta);
				 visible3, y2 = context:pointOfPrice (Level-Delta);
				 
				   
				   context:drawRectangle (1,2, context:right() , y1, context:left(), y2,  transparency);
				   context:drawLine (3, context:right(), y3, context:left(), y3, 0);
                  
	 
 
	
	           
end

function AsyncOperationFinished(cookie, success, message, message1, message2) 
end

