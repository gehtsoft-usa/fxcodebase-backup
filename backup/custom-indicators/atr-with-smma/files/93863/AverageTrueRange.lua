-- Id: 11680
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60655

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

 
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Average True Range");
    indicator:description("Average True Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

    indicator.parameters:addGroup("True Range Calculation");
    indicator.parameters:addInteger("N", "ATR period", "The number of periods.", 14, 2, 1000);
	
	indicator.parameters:addGroup("True Range Smoothing");
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period", "Period", "The number of periods.", 14, 2, 1000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line color", 
        string.format("The color of the %s.", "Average True Range line"), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", "Line width",
        string.format("The width of the %s.", "Average True Range line"), 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line style",
        string.format("The style of the %s.", "Average True Range line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local Method;
local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;
local MA;
local Period;
-- Streams block
local ATR = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " ..Method.. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    tr = instance:addInternalStream(source:first() + 1, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, tr, Period);
    first = MA.DATA:first()  ;
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first);
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
    trFirst = tr:first();
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
function Update(period, mode)
    if period < trFirst then
	return;
	end
	
    tr[period] = getTrueRange(period);
    	
	MA:update(mode);
	
    if (period< first) then
	return;
	end
	
      
        ATR[period] = MA.DATA[period];
   
end




