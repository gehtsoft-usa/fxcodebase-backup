-- Id: 10328
-- Description from the http://www.investopedia.com/articles/trading/03/022603.asp
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Elder-Ray");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("N", "Number of periods for smoothing", "", 13);
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
    indicator.parameters:addColor("BullC", "Color of the bull power line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addInteger("Type1", "Bar/Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("Type1", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("Type1", "Bar", "", core.Bar);
	
    indicator.parameters:addColor("BearC", "Color of the bear power line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addInteger("Type2", "Bar/Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("Type2", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("Type2", "Bar", "", core.Bar);
end
local Method;
local source;
local EMA;
local Bull;
local Bear;
local N;
local first;
local Type1,Type2;
-- process parameters and prepare for calculations
function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
	N=instance.parameters.N;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N  .. ", " .. Method.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    EMA = core.indicators:create(Method, source.close, N);
	first=EMA.DATA:first();
    Bull = instance:addStream("Bull", Type1, name .. ".Bull", "Bull", instance.parameters.BullC, first);
    Bull:setPrecision(math.max(2, instance.source:getPrecision()));
	Bull:setWidth(instance.parameters.width1);
    Bull:setStyle(instance.parameters.style1);
    Bear = instance:addStream("Bear", Type2, name .. ".Bear", "Bear", instance.parameters.BearC, first);
    Bear:setPrecision(math.max(2, instance.source:getPrecision()));
	Bear:setWidth(instance.parameters.width2);
    Bear:setStyle(instance.parameters.style2);
    Bull:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)
    EMA:update(mode);

    if  period  < first then
	return;
	end
	
        Bull[period] = source.high[period] - EMA.DATA[period];
        Bear[period] = source.low[period] - EMA.DATA[period];    
end
