-- Id: 9541
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=54668&p=113782#p113782


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
    indicator:name("Bogie");
    indicator:description("Bogie");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short", "Short", "Short", 7);
    indicator.parameters:addInteger("Long", "Long", "Long", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PPC_color", "Color of PPC", "Color of PPC", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Bogie Style");
	  indicator.parameters:addString("Method", "Method", "", "Dot");
    indicator.parameters:addStringAlternative("Method", "Dot", "", "Dot");
    indicator.parameters:addStringAlternative("Method", "Line", "", "Line");
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("Size", "Bogie Size", "", 20);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local Method;
local first;
local source = nil;
local Size;
-- Streams block
local PPC = nil;
local format;
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
	Method = instance.parameters.Method;
    Long = instance.parameters.Long;
	Size = instance.parameters.Size;
    source = instance.source;
    first = source:first()+math.max(Short, Long);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	format = "%." .. source:getPrecision() .. "f";


 
        PPC = instance:addStream("PPC", core.Line, name, "PPC", instance.parameters.PPC_color, first);
    PPC:setPrecision(math.max(2, instance.source:getPrecision()));
		PPC:setWidth(instance.parameters.width);
        PPC:setStyle(instance.parameters.style);
		
		
		if Method == "Dot" then
		Bogie = instance:createTextOutput("Bogie", "Bogie", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.PPC_color, 0);
		core.host:execute ("attachTextToChart", "Bogie")
		else		
		Bogie = instance:addStream("Bogie", core.Line, name, "Bogie", instance.parameters.PPC_color, first);
    Bogie:setPrecision(math.max(2, instance.source:getPrecision()));
		Bogie:setWidth(instance.parameters.width1);
        Bogie:setStyle(instance.parameters.style1);
		core.host:execute ("attachOuputToChart", "Bogie")
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;	
	end
	

local Left = Long * mathex.sum(source,  period - Short+1, period-1);
local Right = Short * mathex.sum(source , period- Long+1, period-1);
local Bottom = Short-Long;

local BogiePX = (Left- Right) / Bottom;
if Method == "Dot" then
Bogie:set(period, BogiePX, "\158", string.format(format, BogiePX));
else
Bogie[period]= BogiePX;
end

        PPC[period] =  ((BogiePX / source[period]) - 1)*100 ;
		
		

    
end

