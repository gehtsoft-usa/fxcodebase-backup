-- Id: 13830
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62025

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
    indicator:name("Moving Averages Mirror");
    indicator:description("Moving Averages  Mirror");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addString("Method", "Method", "Method", "MVA");
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Range", "Standard Deviation Period ", "Period", 14);
	indicator.parameters:addDouble("Multiplier", "Standard Deviation Multiplier ", "Multiplier", 1);
	
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Mirror_color", "Color of Mirror", "Color of Mirror", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local Multiplier;
local first;
local source = nil;

-- Streams block
local MA = nil;
local Mirror = nil;
local ma, atr;
local Range;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Method = instance.parameters.Method;
	Range = instance.parameters.Range;
	Multiplier = instance.parameters.Multiplier;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method).. ", " .. tostring(Range).. ", " .. tostring(Multiplier)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        ma = core.indicators:create(Method, source, Period); 
        first = math.max(ma.DATA:first(), source:first()+Range);
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color, first);
		MA:setWidth(instance.parameters.width1);
        MA:setStyle(instance.parameters.style1);
        Mirror = instance:addStream("Mirror", core.Line, name .. ".Mirror", "Mirror", instance.parameters.Mirror_color, first);
		Mirror:setWidth(instance.parameters.width2);
        Mirror:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ma:update(mode);  
	
    if period <first or not  source:hasData(period) then
	return;
	end
	
        MA[period] = ma.DATA[period];
        Mirror[period] = ma.DATA[period]+ mathex.stdev(source, period-Range+1, period)*Multiplier;
   
end

