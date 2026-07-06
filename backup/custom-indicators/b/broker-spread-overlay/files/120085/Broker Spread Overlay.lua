-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66306
-- Id: 

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

function Init()
    indicator:name("Broker Spread Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
    indicator.parameters:addGroup("Spread");
    indicator.parameters:addDouble("oneSpread", "Pips", "", 0.0002);
    indicator.parameters:addBoolean("jpyToggle", "JPY Pips", "", false);

    indicator.parameters:addGroup("Chart");
    indicator.parameters:addBoolean("areaToggle", "Area", "", false);
    indicator.parameters:addBoolean("candleToggle", "Candlesticks", "", false);
    indicator.parameters:addBoolean("Shit", "Heikinashi", "", false);

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Area;
local open, high, low, close;
local haopen, hahigh, halow, haclose;
local ha;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if nameOnly then
        return;
    end
    if instance.parameters.areaToggle then
        Area = instance:addStream("Area", core.Line, name, "Area", instance.parameters.color, 0);
        Area:setWidth(instance.parameters.width);
        Area:setStyle(instance.parameters.style);
    end
    if instance.parameters.candleToggle then
        open = instance:addStream("open", core.Line, name .. "." .. "open", "open", 0, 0, 0);
        high = instance:addStream("high", core.Line, name .. "." .. "high", "high", 0, 0, 0);
        low = instance:addStream("low", core.Line, name .. "." .. "low", "low", 0, 0, 0);
        close = instance:addStream("close", core.Line, name .. "." .. "close", "close", 0, 0, 0);
        instance:createCandleGroup("Candle", "Candle", open, high, low, close);
    end
    if instance.parameters.Shit then
        haopen = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), 0)
        hahigh = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), 0)
        halow = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), 0)
        haclose = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), 0)
        instance:createCandleGroup("HA", "HA", haopen, hahigh, halow, haclose);
        ha = core.indicators:create("HA", source);
    end
end

function Update(period, mode)
    local spread = instance.parameters.oneSpread;
    if instance.parameters.jpyToggle then
        spread = spread * 100;
    end
    local oneClose = source.close[period] + spread;
    local oneOpen = source.open[period] + spread
    local oneHigh = source.high[period] + spread
    local oneLow = source.low[period] + spread
    if Area ~= nil then
        Area[period] = oneClose;
    end
    if open ~= nil then
        open[period] = oneOpen;
        high[period] = oneHigh;
        low[period] = oneLow;
        close[period] = oneClose;
    end
    if ha ~= nil then
        ha:update(mode);
        haopen[period] = ha.open[period] + spread;
        hahigh[period] = ha.high[period] + spread;
        halow[period] = ha.low[period] + spread;
        haclose[period] = ha.close[period] + spread;
    end
end