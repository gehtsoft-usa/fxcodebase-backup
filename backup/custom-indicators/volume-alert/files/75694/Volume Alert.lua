-- Id: 9507

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=48694

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
    indicator:name("Volume Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Level", "Alert level", "", 0, 0, 1000000000);
  
	
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("color", "Volume Bar color", "Bar Line", core.rgb(255, 0, 0));

	    indicator.parameters:addColor("level_overboughtsold_color", "Alert Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	  
	

	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Alert Trend Color", "", core.rgb(0, 0, 255));
 
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Level")
 
	

	
	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
 
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up={};
 
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local up={};
 
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Volume;
local Alert;
local Indicator;
local PlaySound;

local FIRST=true;
 

local U={};
 

 
 
-- Routine
function Prepare(nameOnly)  
    
    source = instance.source;
	
	FIRST=true;
	
	Level  = instance.parameters.Level;
 

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Level .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
 

	first = source:first();
	
	Volume = instance:addStream("VOLUME", core.Bar, name, "Volume", instance.parameters.color, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
	Volume:addLevel(Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

	Initialization();
  
end


function  Initialization ()
     Size=instance.parameters.Size;
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
	  
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;	 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Alert", "Alert", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		
		end
	end
		
	

	
end	

 
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

 Volume[period]= source.volume[period];

if period < first or Level == 0  then 
return;
end


	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
	
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period)
	 
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if  source.volume[period] > Level
			
			then
			           
						     up[id]:set(period , Level, "\108");	
						   
			
			 
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .. " ("  ..  source.volume[period]..") Cross Over");
							  end
			end
		   
    end

end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

 if FIRST then
 FIRST= false;
 return;
 end
  
  terminal:alertSound(Sound, RecurrentSound);
end
 

function EmailAlert( Subject)

if not SendEmail then
return
end

    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text= profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL;
 terminal:alertEmail(Email,  Subject, text);
end
	 
function AsyncOperationFinished (cookie, success, message)
end
