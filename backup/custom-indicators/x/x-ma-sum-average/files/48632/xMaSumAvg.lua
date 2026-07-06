-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27765
-- Id: 8130

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
    indicator:name("X MA Sum Average");
    indicator:description("MA Sum Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Start", "Start Period Length", "Start Period Length", 20);
    indicator.parameters:addInteger("End", "End Period Length", "End Period Length", 100);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addColor("MSA_color", "Color of MSA", "Color of MSA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Start;
local End;
local Method;
local first;
local source = nil;

-- Streams block
local MSA = nil;
local MA={};
-- Routine
function Prepare(nameOnly)
    Start = instance.parameters.Start;
    End = instance.parameters.End;
    source = instance.source;
	Method = instance.parameters.Method;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Start) .. ", " .. tostring(End) .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        local i;
        
        for i= Start,End, 1 do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA[i] = core.indicators:create(Method, source, i);
        end
        MSA = instance:addStream("MSA", core.Line, name, "MSA", instance.parameters.MSA_color, MA[End].DATA:first());
		MSA:setWidth(instance.parameters.width);
        MSA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	local i;
	for i = Start, End, 1 do
	MA[i]:update(mode);
	end 
	
	
	 if period < MA[End].DATA:first()  then
	return;
	end
	
	local Sum=0;
	
	for i = Start, End, 1 do
	Sum = Sum + MA[i].DATA[period];
	end 
	
        MSA[period] = Sum / (End-Start+1);
    
end

