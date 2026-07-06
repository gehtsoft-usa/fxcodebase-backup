
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61398

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
    indicator:name("Time Until End");
    indicator:description("Time Until End");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Type", "Type", "", "Time");
    indicator.parameters:addStringAlternative("Type", "Time", "", "Time");
    indicator.parameters:addStringAlternative("Type", "Percentage", "", "Percentage");
	
	indicator.parameters:addString("Units", "Units", "", "Minute");
    indicator.parameters:addStringAlternative("Units", "Minute", "", "Minute");
    indicator.parameters:addStringAlternative("Units", "Seconds", "", "Seconds");
	
	indicator.parameters:addDouble("TriggerLevel", "Trigger Level (in units / percentage)", "", 1, 0, 1000);
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "Color of Label ", core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10 );
	
	indicator.parameters:addString("vPos", "Vertical position", "", "Top");
    indicator.parameters:addStringAlternative("vPos", "Top", "", "Top");
    indicator.parameters:addStringAlternative("vPos", "Middle", "", "Middle");
    indicator.parameters:addStringAlternative("vPos", "Bottom", "", "Bottom");
    indicator.parameters:addString("hPos", "Horizontal position", "", "Right");
    indicator.parameters:addStringAlternative("hPos", "Left", "", "Left");
    indicator.parameters:addStringAlternative("hPos", "Centre", "", "Centre");
    indicator.parameters:addStringAlternative("hPos", "Right", "", "Right");
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Length;
local Color = nil;
local Context;
local Size;
local vPos, HPos;
local font;
local Type;
local TriggerLevel;
local Units;
local Sound;
local  RecurrentSound ,SoundFile  ;
local PlaySound;
local Alert=nil;
local Last;
local Length0, Length1;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Color= instance.parameters.Color;
	Size= instance.parameters.Size;
	vPos= instance.parameters.vPos;
	hPos= instance.parameters.hPos;
	Type= instance.parameters.Type;
	TriggerLevel= instance.parameters.TriggerLevel;
	Units= instance.parameters.Units;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Type.. ", " .. TriggerLevel.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 
	 assert(source:isAlive(), "The chart must be the live price, not a history");
    assert(source:barSize() ~= "t1", "The chart must be the bar history, not tick history");
    local s, e;  
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    Length = math.floor((e - s) * 86400 + 0.5);
		
	s0, e0 = core.getcandle("m1", 0, 0, 0);
	if Units== "Minute" then
	Length0= e0-s0;
	else
	Length0= (e0-s0)/60;
	end
	Length1= ( e-s)/Length0;
	
	if Type =="Time" then 
	     assert( not (TriggerLevel >=  (Length1/Length0)), "The maximum TriggerLevel in units must be less than " .. (Length1/Length0) );	   
	else 
	     assert( not (TriggerLevel >=  100), "Maximum percentage must be less than 100");
	end	
		
		
    font = core.host:execute("createFont",  "Arial", Size, false, false);
	core.host:execute ("setTimer", 1, 1);
	
	
	RecurrentSound= instance.parameters.RecurrentSound;
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	 
	 
	assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	  
end


function ReleaseInstance() 
core.host:execute("deleteFont", font);
core.host:execute ("killTimer", 1);
end

 --period
 function AsyncOperationFinished (cookie)
 
 
 if cookie~= 1 
 or source:size() <=0
 then
 return;
 end
 
    local HOffset;
    local VOffset;
  
   
        local HPos, HAlign;
		local HPos, HAlign;
        
        if vPos == "Top" then
            VPos, VAlign = core.CR_TOP, core.V_Center; 
            HOffset=0;
            VOffset=Size*1.5;			
        elseif vPos == "Bottom" then
            VPos, VAlign = core.CR_BOTTOM, core.V_Center;   
             HOffset=0;
            VOffset=-Size*1.5;			
        else
            VPos, VAlign = core.CR_CENTER, core.V_Center;    
             HOffset=0;
            VOffset=Size*1.5;			
        end
        
        if hPos == "Left" then
            HPos, HAlign = core.CR_LEFT, core.H_Right;
        elseif hPos == "Right" then
            HPos, HAlign = core.CR_RIGHT, core.H_Left;
        else
            HPos, HAlign = core.CR_CENTER, core.H_Center;
        end
 
  
  
		
		  local now = core.now();
       
        now = core.host:execute("convertTime", 3, 1, now); 
        local past = math.floor((now - source:date(source:size()-1)) * 86400 + 0.5);
        past = Length - past;
		
		if past> Length then
		 past= past - Length;
		end
		
		local Text="";
		
        if past > 0 then
		
		    if Type == "Time" then
            local h, m, s;
            s = math.floor(past % 60);
            m = math.floor((past / 60)) % 60;
            h = math.floor(past / 3600);
            Text=  string.format("%i:%02i:%02i\013\010", h, m, s);
			else
			Text=string.format("%." .. 2 .. "f",  past/(Length/100));
			end
			
        end		
		
		 core.host:execute("drawLabel1", 1, HOffset, HPos, VOffset, VPos, HAlign, VAlign,   font, Color, Text);
        
		if Units == "Minute" then
	    past= past/60;
		end
		
	    if Type ~="Time" then
		past= past/(Length1/100)
		end 
		
		
		
		if Type =="Time" 
		and past <=  TriggerLevel
		and Last~= source:serial(source:size()-1)
		then 
		   SoundAlert(Sound);
		    Last= source:serial(source:size()-1)
		elseif Type =="Percentage" 
		and  past < TriggerLevel
		and Last~= source:serial(source:size()-1)
		then	
		SoundAlert(Sound );
		Last= source:serial(source:size()-1)
		end	
 
		 
		 
 
 end
 
 

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
 
terminal:alertSound(iAlert, RecurrentSound);
end

	 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end

