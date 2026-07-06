-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3367
-- Id: 5935

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

 function Init()
    indicator:name("Rollover Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
	
	
	indicator.parameters:addGroup("Calculatin"); 
	indicator.parameters:addInteger("SIZE", "Position Size (in Lots)", "", 1);
	indicator.parameters:addGroup("Presentation"); 
	indicator.parameters:addString("Mode", "Display Mode", "", "A");
	indicator.parameters:addStringAlternative("Mode", "Simple", "", "S");
    indicator.parameters:addStringAlternative("Mode", "Advanced", "", "A");

	indicator.parameters:addInteger("size", "Font Size", "", 13);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0);
	indicator.parameters:addColor("Label", "Color of Label", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Positiv", "Pozitiv Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Negativ", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	
end

local SIZE;
local size;
local first;
local source = nil;
local font,bold;
local Instrument;
local Shift;
local Label;
local Mode;
local Wingdings;
-- Routine
function Prepare(nameOnly)
     Mode=instance.parameters.Mode; 
     Label=instance.parameters.Label;
	host=   core.host;
    source = instance.source;
    first = source:first();	
	size=instance.parameters.size;
    Instrument= source:instrument ();
	Shift=instance.parameters.Shift;
	SIZE=instance.parameters.SIZE;
   
    local name = profile:id() ;
	instance:name(name);
	if nameOnly then
		return;
	end
	Wingdings = core.host:execute("createFont", "Wingdings", size, false, false);
	 font = core.host:execute("createFont", "Courier", size, false, false);
	 bold = core.host:execute("createFont", "Courier", size, false, true);
					   
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	if period ~= source:size() -1 then
	return;
	end	
	
  local L, S;
  L, S =	DATA();
  DRAW(L,S);
end



function DRAW(L,S)

if L == nil then
return;
end

local Color= core.rgb(0, 0, 0);

if L > S then
Color= instance.parameters.Positiv;
elseif L< S then
Color= instance.parameters.Negativ;
else
Color= instance.parameters.Neutral;
end

if Mode == "A" then
	 
core.host:execute("drawLabel1", 3 ,-200, core.CR_RIGHT, 25 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Long");
									  
core.host:execute("drawLabel1", 1 ,-200, core.CR_RIGHT, 50 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Positiv, string.format("%." .. 4 .. "f", L *SIZE));
		
core.host:execute("drawLabel1", 4 ,-100, core.CR_RIGHT, 25 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Short");
		
  core.host:execute("drawLabel1", 2 ,-100, core.CR_RIGHT, 50+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Negativ, string.format("%." .. 4 .. "f", S*SIZE ));
else


 core.host:execute("drawLabel1", 1 ,-100, core.CR_RIGHT, 50+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  Wingdings, Color,"\108" );
end									  
									  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font); 
	   core.host:execute("deleteFont", bold); 	 
        core.host:execute("deleteFont", Wingdings); 	   
end


function DATA()

		local Table=core.host:findTable("offers");
		local enum = Table:enumerator();
	    local S=nil;
		local L=nil;		
		
	    while true do
		
	    local row = enum:next();	
	    
				if row == nil then
				break;
				end   
						
				if Instrument == row.Instrument then	
				  S =  row.IntrS;
				  L = row.IntrB;
				  break;
				end
						
		end
		
		return L, S;
end