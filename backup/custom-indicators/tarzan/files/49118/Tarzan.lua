-- Id: 8240
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27989

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
    indicator:name("TARZAN");
    indicator:description("TARZAN");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	

    indicator.parameters:addInteger("RsiPeriod", "Rsi Period", "Rsi Period", 5);
    indicator.parameters:addInteger("MaPeriod", "MA Period", "MA Period", 50);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Koridor", "Koridor", "Koridor", 20);
	indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));

    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RsiPeriod;
local MaPeriod;
local Koridor;

local first;
local source = nil;

-- Streams block
local RSI = nil;
local MA = nil;
local Top = nil;
local Bottom = nil;
local ma, rsi;
local Method;
-- Routine
function Prepare(nameOnly)
    RsiPeriod = instance.parameters.RsiPeriod;
    MaPeriod = instance.parameters.MaPeriod;
    Koridor = instance.parameters.Koridor;
	Method = instance.parameters.Method;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RsiPeriod) .. ", " .. tostring(MaPeriod) .. ", " .. tostring(Method) .. ", " .. tostring(Koridor) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        rsi = core.indicators:create("RSI", source,RsiPeriod );
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        ma = core.indicators:create(Method, rsi.DATA ,MaPeriod );
        
        first =  ma.DATA:first();
        RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		RSI:setWidth(instance.parameters.width1);
        RSI:setStyle(instance.parameters.style1);
        MA = instance:addStream("MA", core.Dot, name .. ".MA", "MA", instance.parameters.Up, first);	
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.width3);
        Top:setStyle(instance.parameters.style3);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.width4);
        Bottom:setStyle(instance.parameters.style4);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   rsi:update(mode);
   ma:update(mode);

    if period < first  then
	return;
	end
        RSI[period] = rsi.DATA[period];		
        MA[period] = ma.DATA[period];
        Top[period] = MA[period]+Koridor;
        Bottom[period] = MA[period]-Koridor;
	if RSI[period]> MA[period] then	
	MA:setColor(period, instance.parameters.Up);	
	else
	MA:setColor(period, instance.parameters.Down);	
	end

		
end

