-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67250

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Room Up/Down")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addString("UpLevels", "Up levels", "", "75,100,125");
    indicator.parameters:addString("DownLevels", "Down levels", "", "75,100,125");
    indicator.parameters:addInteger("StartCandle", "Start candle", "", 10);
    indicator.parameters:addInteger("LineLength", "Line length", "", 5);
    indicator.parameters:addInteger("ADRdays", "ADR days", "", 30);
    indicator.parameters:addBoolean("FixFromOpen", "Fix From Open", "", false);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UpLineColor", "Up in Up Trend Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownLineColor", "Up in Down Trend Color", "", core.rgb(200, 0, 0))
	indicator.parameters:addInteger("LineWidth", "Line Width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
end

local UpLineColor, DownLineColor, LineWidth, LineStyle;
local UpLevels = {};
local DownLevels = {};
local StartCandle, LineLength, ADRdays, FixFromOpen;
local d1_source, source;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    source = instance.source
    UpLineColor = instance.parameters.UpLineColor;
    DownLineColor = instance.parameters.DownLineColor;
    LineWidth = instance.parameters.LineWidth;
    LineStyle = instance.parameters.LineStyle;
    StartCandle = instance.parameters.StartCandle;
    FixFromOpen = instance.parameters.FixFromOpen;
    ADRdays = instance.parameters.ADRdays;
    LineLength = instance.parameters.LineLength;
    UpLevels, upcount = core.parseCsv(instance.parameters.UpLevels, ",");
    if upcount > 0 and UpLevels[0] ~= "" then
        UpLevels[#UpLevels + 1] = UpLevels[0];
    end
    DownLevels, downcount = core.parseCsv(instance.parameters.DownLevels, ",");
    if downcount > 0 and DownLevels[0] ~= "" then
        DownLevels[#DownLevels + 1] = DownLevels[0];
    end
  
    d1_source = core.host:execute("getSyncHistory", source:instrument(), 
        "D1", source:isBid(), ADRdays, 1, 1);

    instance:ownerDrawn(true)
end

function Update(period, mode)
end

local init = false

local UP_PEN = 1;
local DOWN_PEN = 2;

function Draw(stage, context)
    if stage ~= 2 or d1_source.close:size() == 0 then
        return
    end
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
    if not init then
        context:createPen(UP_PEN, context:convertPenStyle(LineStyle), LineWidth, UpLineColor);
        context:createPen(DOWN_PEN, context:convertPenStyle(LineStyle), LineWidth, DownLineColor);
        init = true
    end

    local sum = 0;
    local cnt = 0;
    for k = 1, ADRdays do
        local index = d1_source:size() - 1 - k;
        if index >= 0 then
            local range = d1_source.high[index] - d1_source.low[index];
            sum = sum + range / d1_source:pipSize();
            cnt = cnt + 1;
        end
    end
    local adr = 0;
    if cnt ~= 0 then
        adr = (sum / cnt) * d1_source:pipSize();
    end

    for _, lvl in ipairs(UpLevels) do
        local level;
        if FixFromOpen then
            level = d1_source.open[NOW] + adr * lvl / 100;
        else
            level = d1_source.low[NOW] + adr * lvl / 100;
        end
        local x1 = context:positionOfBar(source:size() - 1 - StartCandle);
        local x2 = context:positionOfBar(source:size() - 1 - StartCandle + LineLength);
        local _, y = context:pointOfPrice(level);
        context:drawLine(UP_PEN, x1, y, x2, y);
    end
  
    for _, lvl in ipairs(DownLevels) do
        local level;
        if FixFromOpen then
            level = d1_source.open[NOW] - adr * lvl / 100;
        else
            level = d1_source.low[NOW] - adr * lvl / 100;
        end
        local x1 = context:positionOfBar(source:size() - 1 - StartCandle);
        local x2 = context:positionOfBar(source:size() - 1 - StartCandle + LineLength);
        local _, y = context:pointOfPrice(level);
        context:drawLine(UP_PEN, x1, y, x2, y);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
end