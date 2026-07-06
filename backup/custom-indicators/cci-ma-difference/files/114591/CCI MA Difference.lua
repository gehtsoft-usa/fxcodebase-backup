-- Id: 18954
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65046

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
    indicator:name("CCI MA Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI_Period", "Period", 14);
    indicator.parameters:addInteger("MA_Period", "MA Period", "Period", 14);
	indicator.parameters:addString("MA_Method", "MA_MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	 
	
end
 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CCI_Period;
local MA_Period;
local MA_Method;
local CCI,MA;

local first;
local source = nil;
-- Streams block
local Difference = nil;

-- Routine
function Prepare(nameOnly)

	CCI_Period= instance.parameters.CCI_Period;
	MA_Period= instance.parameters.MA_Period;
	MA_Method= instance.parameters.MA_Method;
	
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CCI_Period) .. ", " .. tostring(MA_Period) .. ", " .. tostring(MA_Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
	    CCI= core.indicators:create("CCI", source , CCI_Period);
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
		MA= core.indicators:create(MA_Method, CCI.DATA , MA_Period);
	    first=MA.DATA:first();
		
        Difference = instance:addStream("Difference", core.Line, name .. ".Difference", "Difference", instance.parameters.color, first);
		Difference:setWidth(instance.parameters.width);
        Difference:setStyle(instance.parameters.style);
		Difference:addLevel(0);
	    
		Difference:setPrecision(math.max(2, instance.source:getPrecision()));
		 
   
	
 
end


 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        if period < CCI.DATA:first()  then
		return;
		end
        
        CCI:update(mode);
		
		if period < first  then
		return;
		end
			
		MA:update(mode);
		
 
		
        Difference[period] = CCI.DATA[period]- MA.DATA[period];
 
    
end 