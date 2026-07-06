-- Id:24870
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68401

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CM_Modified_Heik_Trend_Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("uema", "EMA UpTrend", "", 34);
    indicator.parameters:addInteger("dema", "EMA DownTrend", "", 34);

    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("down_color", "Down color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
end

local source;
local haopen, haclose, upEma, downEma, up_color, down_color, open, high, low, close;
function Prepare(nameOnly)
    local name = string.format("%s (%s)", profile:id(), instance.source:name());
    instance:name(name); 
    if nameOnly then
        return;
    end
    source = instance.source;
    
    haopen = instance:addInternalStream(0, 0);
    haclose = instance:addInternalStream(0, 0);
    upEma = core.indicators:create("EMA", haclose, instance.parameters.uema);
    downEma = core.indicators:create("EMA", haopen, instance.parameters.dema);
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;

    out = instance:addStream("OUT", core.Line, "EMA UpTrend", "EMA UpTrend", up_color, 0, 0);	
	out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);

    open = instance:addStream("open", core.Line, "Open", "Open", up_color, 0, 0);
    high = instance:addStream("high", core.Line, "High", "High", up_color, 0, 0);
    low = instance:addStream("low", core.Line, "Low", "Low", up_color, 0, 0);
    close = instance:addStream("close", core.Line, "Close", "Close", up_color, 0, 0);
    instance:createCandleGroup("candles", "candles", open, high, low, close);
end

function Update(period, mode)
    haclose[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
    if period == 0 then
        haopen[period] = (source.open[period] + source.close[period]) / 2;
    else
        haopen[period] = (haopen[period - 1] + haclose[period - 1]) / 2;
    end
    upEma:update(mode);
    downEma:update(mode);
    if not upEma.DATA:hasData(period) or not downEma.DATA:hasData(period) then
        return;
    end

    out[period] = (upEma.DATA[period] + downEma.DATA[period]) / 2;
    if period > 0 and source.typical[period] >= out[period - 1] then
        out:setColor(period, up_color);
    else
        out:setColor(period, down_color);
    end
    open[period] = source.open[period];
    high[period] = source.high[period];
    low[period] = source.low[period];
    close[period] = source.close[period];
    if source.typical[period] >= out[period] then
        open:setColor(period, up_color)
    else
        open:setColor(period, down_color)
    end
end