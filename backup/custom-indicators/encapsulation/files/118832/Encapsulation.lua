-- Id: 21045
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65966
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
    indicator:name("Encapsulation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("StartTime", "Start Time", "", "00:00:00");
    indicator.parameters:addString("StopTime", "Stop Time", "", "24:00:00");
    
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

    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    
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

function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
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
        now = now - math.floor(now);
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