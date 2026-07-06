-- Id: 6993
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20973

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
    indicator:name("DMI Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addGroup("Zone Style");
	indicator.parameters:addBoolean("Show" , "Show Zones" , "", true);
	indicator.parameters:addColor("Top", "OB Zone Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bottom", "OS Zone Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Transparency", "Channel transparency (%)", "", 70, 0, 100);

	
	indicator.parameters:addDouble("Top_Level", "Top Level", "", 25);
	indicator.parameters:addDouble("Bottom_Level", "Bottom Level", "", -25);
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Show;
local Top, Bottom;
local  Difference=nil;
local OB,OS;
local Max, Step, Period;
local Transparency;
local DMI;
local SAR;

local Difference_OB, Difference_OS;
function Prepare(nameOnly)
    Period= instance.parameters.Period;	
	source = instance.source;
	Show= instance.parameters.Show;
	Top= instance.parameters.Top;
	Bottom= instance.parameters.Bottom;
	Top_Level= instance.parameters.Top_Level;
	Bottom_Level= instance.parameters.Bottom_Level;
	Transparency= instance.parameters.Transparency;
   
    local name = profile:id() .. "(" .. source:name() ..", ".. Period.. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	DMI=core.indicators:create("DMI",  source, Period); 
	
	first= DMI.DATA:first();

    	
	Difference = instance:addStream("Difference", core.Line, name, "Difference",  instance.parameters.color, first);
	Difference:setWidth(instance.parameters.width );
    Difference:setStyle(instance.parameters.style );
	Difference:addLevel(Top_Level);
    Difference:addLevel(Bottom_Level);
	
	Difference:setPrecision(math.max(2, instance.source:getPrecision()));
	
	OS = instance:addInternalStream(0, 0);
	OB = instance:addInternalStream(0, 0);
	
    Difference_OS = instance:addInternalStream(0, 0);
	Difference_OB = instance:addInternalStream(0, 0);	
	
	if Show then
	instance:createChannelGroup ("OB", "OB",   Difference_OS, OS, Top, Transparency);
	instance:createChannelGroup ("OS", "OS",   OB, Difference_OB,  Bottom, Transparency);
	end
end

-- Indicator calculation routine
function Update(period, mode)
		

			DMI:update(mode);
			
			if period < first then
			return;
			end
	    
    Difference[period]= DMI.DIP[period]-DMI.DIM[period];
	OB[period]= Top_Level;
	Difference_OB[period]=100; 
	 
	OS[period]=Bottom_Level;	
    Difference_OS[period]= -100; 
	
 end


