--ID: 23959
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67360

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Sequence Numbers");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("Shift", "Shift", "", 1, 0, 2000);
	indicator.parameters:addInteger("Max", "Max", "", 10, 0, 2000);
    indicator.parameters:addBoolean("Recalculate", "Recalculate", "Recalculate", true);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addInteger("FontSize", "Font Size", "", 15);
	indicator.parameters:addColor("Color", "Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SequenceColor", "Sequence Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addString("HS", "Horizontal Alignment", "Horizontal Alignment" , "C");
    indicator.parameters:addStringAlternative("HS", "Central", "Central" , "C");
    indicator.parameters:addStringAlternative("HS", "Right", "Right" , "R");
    indicator.parameters:addStringAlternative("HS", "Left", "Left" , "L");
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Recalculate;
local Shift,Max;
local FontSize, Color,SequenceColor; 
local first;
local source = nil;
local font; 
local HS; 
local Recalculate;
local Style;
local ItIs;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   
-- Routine
 function Prepare(nameOnly)   
 
    Max= instance.parameters.Max;
    Shift= instance.parameters.Shift 
    FontSize= instance.parameters.FontSize;
	Color= instance.parameters.Color;
	SequenceColor= instance.parameters.SequenceColor;
	Recalculate= instance.parameters.Recalculate;
	
	HS= instance.parameters.HS;
	
	
  
	font = core.host:execute("createFont", "Courier", FontSize, true, false);

	local Parameters=Shift.. ", ".. Max;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;  
    first=source:first(); 
	
	
	if HS=="R" then
	Style=core.H_Right;
	elseif HS=="L" then
	Style=core.H_Left;
	else
	Style=core.H_Center;
	end
	
	ItIs=false;
end

-- Indicator calculation routine
function Update(period, mode) 
	
 
	
	if Recalculate or (not Recalculate and ItIs==false) then
	
	ItIs=true;
		for Index=1, Max, 1 do 
		
			if Index == Max then
			core.host:execute("drawLabel1", Index, source:date(source:size()-1-Max+Index-Shift), core.CR_CHART, source.high[source:size()-1-Max+Index-Shift], core.CR_CHART, Style, core.V_Top,font, SequenceColor, win32.formatNumber(Index, false, 0));		 
			else
			core.host:execute("drawLabel1", Index, source:date(source:size()-1-Max+Index-Shift), core.CR_CHART, source.high[source:size()-1-Max+Index-Shift], core.CR_CHART, Style, core.V_Top,font, Color, win32.formatNumber(Index, false, 0));
			end
		end	
	
	end				  
end

