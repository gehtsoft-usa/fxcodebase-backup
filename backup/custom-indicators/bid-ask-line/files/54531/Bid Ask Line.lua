-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31986
-- Id: 8495

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
    indicator:name("Bid Ask Line");
    indicator:description("Bid Ask Line"); 
    indicator:requiredSource(core.Bar);
	indicator:setTag("AllowAllSources", "y");
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Type", "", "Bid");
    indicator.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	indicator.parameters:addStringAlternative("Type", "Chart Selection", "", "Chart");
	indicator.parameters:addStringAlternative("Type", "Both", "", "Both");
	


     indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("clr", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Type;
local first;
local source = nil;
local clr, style, width;
local bid, ask;
local Price;

-- Routine
function Prepare(nameOnly)
    clr = instance.parameters.clr;
	style = instance.parameters.style;
	width = instance.parameters.width;
	Type = instance.parameters.Type;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period <  source:size()-1 then
    return;    
    end
	
	Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
	
	local Flag="";
	
    if 	Type~= "Chart" then
	 
			 if Type ~= "Ask" then
				core.host:execute("drawLine",1, source:date(first),Bid , source:date(source:size()-1), Bid, clr, style, width);
				Flag = Flag.." Bid " ..Bid;
			 end	
			  if Type ~= "Bid" then
				core.host:execute("drawLine",2, source:date(first),Ask , source:date(source:size()-1), Ask, clr, style, width);
				Flag =Flag.. " Ask " ..Ask;
			 end
     else	
             core.host:execute("drawLine",1, source:date(first),source[source:size()-1] , source:date(source:size()-1), source[source:size()-1], clr, style, width);
             Flag = source[source:size()-1];			 
     end	 
	 
	 core.host:execute ("setStatus", tostring(Flag));
end

