-- Id: 9947
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59441

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
    indicator:name(" Mel Widner Averaged Rainbow");
    indicator:description("Averaged Rainbow");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period", "MA Period", "MA Period", 2);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Color", "Color", "Color", core.rgb(255, 0, 0));

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Number=10;
local Color;
local Period;
local Method;
local first={};
local source = nil;
local ma={};
-- Streams block
local MA = {};
local Avg, FIRST;
local Weight={5,4,3,2,1,1,1,1,1,1};
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	Method = instance.parameters.Method;
    Period = instance.parameters.Period;
    source = instance.source;
	FIRST=source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Number) .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		local i;
		for i = 1, Number, 1 do
			if i == 1 then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
			ma[i] = core.indicators:create(Method, source, Period);
			else
			ma[i] = core.indicators:create(Method, ma[i-1].DATA, Period);
			end
			first[i] = ma[i].DATA:first();
			FIRST= math.max(FIRST,first[i] );
			MA[i]= instance:addInternalStream(0, 0);
        end
		
		 Avg = instance:addStream("Avg", core.Line, name, "MA " ,  Color, FIRST);
		 Avg:setWidth(instance.parameters.width);
         Avg:setStyle(instance.parameters.style);
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if not source:hasData(period) then
	return;
	end
	
	local i;	
	local Sum=0;
	local Num=0;
	for i = 1, Number, 1 do	
	 ma[i]:update(mode); 
	 if period >= first[i]  then
	 MA[i][period] = ma[i].DATA[period];
	 Num= Num+Weight[i];
	 Sum=Sum+ma[i].DATA[period]*Weight[i] ;
	 end
	end
       
    if period <FIRST then
	return;
	end
	
	Avg[period]= Sum / Num;
end

 
