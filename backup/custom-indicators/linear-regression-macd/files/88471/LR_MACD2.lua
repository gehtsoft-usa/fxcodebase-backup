-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59055
-- Id: 9683

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Linear regression MACD oscillator");
    indicator:description("Linear regression MACD oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortPeriod", "Short period", "", 12);
    indicator.parameters:addInteger("LongPeriod", "Long period", "", 26);
    indicator.parameters:addInteger("SignalPeriod", "Signal period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACDclr", "MACD color", "MACD color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MACDwidth", "MACD width", "MACD width", 1, 1, 5);
    indicator.parameters:addInteger("MACDstyle", "MACD style", "MACD style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACDstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Swidth", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Hclr", "Histogram color", "Histogram color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local ShortPeriod;
local LongPeriod;
local SignalPeriod;
local ShortLR, LongLR;
local SignalLR;
local MACD=nil;
local Signal=nil;
local Histogram=nil;

function Prepare(nameOnly)
    source = instance.source;
    ShortPeriod=instance.parameters.ShortPeriod;
    LongPeriod=instance.parameters.LongPeriod;
    SignalPeriod=instance.parameters.SignalPeriod;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortPeriod .. ", " .. instance.parameters.LongPeriod .. ", " .. instance.parameters.SignalPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("LINEAR REGRESSION LINE") ~= nil, "Please, download and install LINEAR REGRESSION LINE.LUA indicator");    
    ShortLR = core.indicators:create("LINEAR REGRESSION LINE", source, ShortPeriod);
    LongLR = core.indicators:create("LINEAR REGRESSION LINE", source, LongPeriod);
	
	first = math.max( ShortLR.DATA:first(),LongLR.DATA:first());
	
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACDclr, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.MACDwidth);
    MACD:setStyle(instance.parameters.MACDstyle);
	
	SignalLR = core.indicators:create("LINEAR REGRESSION LINE", MACD, SignalPeriod);
	
	
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr,  SignalLR.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.Swidth);
    Signal:setStyle(instance.parameters.Sstyle);
    Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Hclr,  SignalLR.DATA:first());
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    ShortLR:update(mode);
    LongLR:update(mode);
    MACD[period]=ShortLR.DATA[period]-LongLR.DATA[period];
    SignalLR:update(mode);
	
	if period <  SignalLR.DATA:first() then
	return;
	end
	
	
	
    Signal[period]=SignalLR.DATA[period];
    Histogram[period]=MACD[period]-Signal[period];
 
end

