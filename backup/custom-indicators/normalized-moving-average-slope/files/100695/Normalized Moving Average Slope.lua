-- Id: 14248
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62272

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
    indicator:name("Normalized Moving Average Slope");
    indicator:description("Normalized Moving Average Slope");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	

    indicator.parameters:addInteger("MA_Period", "Period", "Period", 14);
    indicator.parameters:addString("MA_Method", "MA Method", "MA Method", "MVA");
	indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "ATR Period", 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("NMAS_color", "Color of NMAS", "Color of NMAS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MA_Period;
local MA_Method;
local ATR_Period;

local first;
local source = nil;

-- Streams block
local NMAS = nil;
local MA, ATR;
local Price;
-- Routine
function Prepare(nameOnly)
    MA_Period = instance.parameters.MA_Period;
    MA_Method = instance.parameters.MA_Method;
    ATR_Period = instance.parameters.ATR_Period;
	Price = instance.parameters.Price;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Price).. ", " .. tostring(MA_Period) .. ", " .. tostring(MA_Method) .. ", " .. tostring(ATR_Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        ATR = core.indicators:create("ATR", source, ATR_Period);
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
        MA = core.indicators:create(MA_Method, source[Price], MA_Period);
        first =math.max(MA.DATA:first(), ATR.DATA:first());
        NMAS = instance:addStream("NMAS", core.Line, name, "NMAS", instance.parameters.NMAS_color, first);
    NMAS:setPrecision(math.max(2, instance.source:getPrecision()));
		NMAS:setWidth(instance.parameters.width);
        NMAS:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ATR:update(mode);
	MA:update(mode);
    if period <first or not source:hasData(period) then
	return;
	end
        NMAS[period] = (MA.DATA[period]/MA.DATA[period])/(ATR.DATA[period]/100);
    
end

