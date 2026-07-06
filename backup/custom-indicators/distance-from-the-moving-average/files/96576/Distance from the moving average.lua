-- Id: 12736

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61337

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
    indicator:name("Distance from the moving average");
    indicator:description("Distance from the moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "Period", 14);
    indicator.parameters:addString("Method1", "Method1", "Method", "MVA");
	indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Smoothing", "Uses Smoothing", "", true);
	
	
	indicator.parameters:addInteger("Period2", "Period", "Period", 14);
    indicator.parameters:addString("Method2", "Method2", "Method", "MVA");
	indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Mode", "Mode", "Mode", "Value");
	indicator.parameters:addStringAlternative("Mode", "Value", "Value" , "Value");
    indicator.parameters:addStringAlternative("Mode", "Pip", "Pip" , "Pip");
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of Distance", "Color of Distance", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "Color of Smoothed", "Color of Smoothed", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Method1;
local Period2;
local Method2;
local Smoothing;
local first1, first2;
local source = nil;
local ma1, ma2, MA;
local Mode;
-- Streams block
local Distance = nil;

-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Method1 = instance.parameters.Method1;
	
	Period2 = instance.parameters.Period2;
    Method2 = instance.parameters.Method2;
	
	Mode= instance.parameters.Mode;
	
	Smoothing= instance.parameters.Smoothing;
	
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Method1).. ", " .. tostring(Period2) .. ", " .. tostring(Method2).. ", " .. tostring(Mode) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	ma1= core.indicators:create(Method1, source, Period1);
    first1 = ma1.DATA:first();

    
 
        Distance = instance:addStream("Distance", core.Line, name, "Distance", instance.parameters.color1, first1);
		Distance:setWidth(instance.parameters.width1);
        Distance:setStyle(instance.parameters.style1);
		Distance:setPrecision(math.max(2, instance.source:getPrecision()));
		
		if Smoothing then
		ma2= core.indicators:create(Method2, Distance, Period2);
        first2 = ma2.DATA:first();
		
		MA = instance:addStream("Smoothed", core.Line, name, "Smoothed", instance.parameters.color2, first2);
		MA:setWidth(instance.parameters.width2);
        MA:setStyle(instance.parameters.style2);
		
		MA:setPrecision(math.max(2, instance.source:getPrecision()));
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    ma1:update(mode);
    if period < first1 or not source:hasData(period) then
	return;
	end
	    if Mode== "Pip" then
		Distance[period] = (source[period]- ma1.DATA[period])/source:pipSize();
		else
        Distance[period] = source[period]- ma1.DATA[period];
		end
		
	if not Smoothing then
    return;
    end	
	ma2:update(mode);
	
    if period < first2   then
	return;
	end	
	
	   MA[period] =  ma2.DATA[period];
    
end

