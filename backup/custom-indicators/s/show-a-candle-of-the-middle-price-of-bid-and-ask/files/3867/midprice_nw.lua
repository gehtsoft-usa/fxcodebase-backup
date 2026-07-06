
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1916

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
    indicator:name("Middle Price");
    indicator:description("The indicator shows a middle price between bid and ask prices");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("ShowHL", "Show Bid Low and Ask High prices", "", true);
    indicator.parameters:addBoolean("ShowPrice", "Show Bid and Ask Close prices", "", true);
    indicator.parameters:addColor("BidColor", "Color Of Bid Price", "", core.rgb(65, 105, 225));
    indicator.parameters:addColor("AskColor", "Color Of Ask Price", "", core.rgb(128, 0, 128));
    indicator.parameters:addInteger("DotSize", "Size Of Bid Low and Ask High Dots", "", 1, 1, 5);
    indicator.parameters:addInteger("LineSize", "Width Of Bid and Ask Close Line", "", 1, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Style Of Bid and Ask Close Line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
end

local first;
local bid, ask;
local o, h, l, c, v, hv;
local ShowHL;
local ShowPrice;
local h1, l1, c1, c2;
local format;
local source;
local AskColor, BidColor, LineSize, LineStyle;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    local name;
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    bid = core.host:execute("getBidPrice");
    ask = core.host:execute("getAskPrice");

    ShowHL = instance.parameters.ShowHL;
    ShowPrice = instance.parameters.ShowPrice;
    AskColor = instance.parameters.AskColor;
    BidColor = instance.parameters.BidColor;
    LineSize = instance.parameters.LineSize;
    LineStyle = instance.parameters.LineStyle;

    o = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first);
    h = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first);
    l = instance:addStream("low", core.Line, name .. ".low", "low", core.rgb(0, 0, 0), first);
    c = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first);
    if instance.source:supportsVolume() then
        hv = true;
        v = instance:addStream("volume", core.Line, name .. ".volume", "volume", core.rgb(0, 0, 0), first);
        instance:createCandleGroup("midprice", "midprice", o, h, l, c, v);
    else
        hv = false;
        instance:createCandleGroup("midprice", "midprice", o, h, l, c);
    end

    if ShowHL then
        h1 = instance:addStream("highask", core.Dot, name .. ".highask", "highask", AskColor, first);
        h1:setWidth(instance.parameters.DotSize);
        l1 = instance:addStream("lowbid", core.Dot, name .. ".lowbid", "lowbid", BidColor, first);
        l1:setWidth(instance.parameters.DotSize);
    end

    format = "%s:%." .. tonumber(source:getPrecision()) .. "f";
end

function Update(period, mode)
    if period >= first then
        o[period] = (bid.open[period] + ask.open[period]) / 2;
        h[period] = (bid.high[period] + ask.high[period]) / 2;
        l[period] = (bid.low[period] + ask.low[period]) / 2;
        c[period] = (bid.close[period] + ask.close[period]) / 2;
        if hv then
            v[period] = (bid.volume[period] + ask.volume[period]) / 2;
        end
        if ShowHL then
            h1[period] = ask.high[period];
            l1[period] = bid.low[period];
        end
        if ShowPrice and period == source:size() - 1 then
            core.host:execute("drawLine", 1, -2, ask.close[period], 1000, ask.close[period], AskColor, LineStyle, LineSize, string.format(format, "ask", ask.close[period]));
            core.host:execute("drawLine", 2, -2, bid.close[period], 1000, bid.close[period], BidColor, LineStyle, LineSize, string.format(format, "bid", ask.close[period]));
        end
    end
end
