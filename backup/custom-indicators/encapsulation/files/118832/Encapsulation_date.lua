-- Id: 21047
-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Encapsulation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addDate("StartTime", "Start Time", "", 0);
    indicator.parameters:setFlag("StartTime", core.FLAG_DATETIME);
    indicator.parameters:addDate("StopTime", "Stop Time", "", 0);
    indicator.parameters:setFlag("StopTime", core.FLAG_DATETIME);
    
    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Channel transparency (%)", "", 80, 0, 100);
end

local source;
local OpenTime;
local CloseTime;
local Transparency;

function Prepare(nameOnly)
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if (nameOnly) then
        return;
    end

    OpenTime = instance.parameters.StartTime;
    CloseTime = instance.parameters.StopTime;
    
    source = instance.source;
    color = instance.parameters.color;
    width = instance.parameters.width;
    style = instance.parameters.style;
    Transparency = instance.parameters.Transparency;
    instance:ownerDrawn(true);
end

-- Indicator calculation routine
function Update(period)
end

function InRange(now, OpenTime, CloseTime)
    -- from, to
    return now >= OpenTime and now <= CloseTime;
end

local main_pen = 1;
local main_brush = 2;
local init = false;

function DrawRect(context, range)
    if range.Start == nil then
        return;
    end
    local _1, x1 = context:positionOfBar(range.Start);
    local _2, _3, x2 = context:positionOfBar(range.End);
    local _4, y1 = context:pointOfPrice(range.High);
    local _5, y2 = context:pointOfPrice(range.Low);
    context:drawRectangle(main_pen, main_brush, x1, y1, x2, y2, Transparency);
end

function Draw(stage, context)
    if stage ~= 0  then
        return;
    end
    if not init then
        context:createPen(main_pen, context:convertPenStyle(style), width, color);
        context:createSolidBrush(main_brush, color);
        init = true;
    end
    local range = {};

    local first = math.max(source:first(), context:firstBar());
    local last = math.min(context:lastBar(), source:size() - 1);
    for i = first, last, 1 do
        local now = source:date(i);
        if InRange(now, OpenTime, CloseTime) then
            if range.Start == nil then
                range.Start = i;
                range.High = source.high[i];
                range.Low = source.low[i];
            else
                if range.High < source.high[i] then
                    range.High = source.high[i];
                end
                if range.Low > source.low[i] then
                    range.Low = source.low[i];
                end
            end
            range.End = i;
        else
            DrawRect(context, range);
            range = {};
        end
    end
    DrawRect(context, range);
end