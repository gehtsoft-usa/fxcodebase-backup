-- Id: 8706
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32941

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
    indicator:name("Trend Analysis Index");
    indicator:description("Trend Analysis Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AP", "Averaging Period", "Averaging Period", 28);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("TP", "TAI Period", "TAI Period", 5);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TAI_color", "Color of TAI", "Color of TAI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AP;
local TP;
local Method;
local first;
local source = nil;
local MA;
-- Streams block
local TAI = nil;

-- Routine
function Prepare(nameOnly)
    AP = instance.parameters.AP;
    TP = instance.parameters.TP;
	Method = instance.parameters.Method;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AP) .. ", " .. tostring(Method).. ", " .. tostring(TP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA = core.indicators:create(Method, source, AP);
        first = MA.DATA:first();
        TAI = instance:addStream("TAI", core.Line, name, "TAI", instance.parameters.TAI_color, first+TP);
    TAI:setPrecision(math.max(2, instance.source:getPrecision()));
		TAI:setWidth(instance.parameters.width);
        TAI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	
    if period < first +TP and source:hasData(period) then
	return;
	end
	
	local min, max;
	min, max= mathex.minmax(MA.DATA, period-TP+1, period );
	
	
   --	TAI = (Highest(Average(Price,AvgLen),TAILen)- Lowest(Average(Price,AvgLen),TAILen))*100/Close
	TAI[period] =(max-min)*100/source[period];
    
end

