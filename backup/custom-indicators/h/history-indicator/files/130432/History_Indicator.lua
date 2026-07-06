-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69269

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
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("History");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addFile("file", "File", "", "history.csv");
    indicator.parameters:addColor("profit_color", "Profit color", "", core.colors().Green);
    indicator.parameters:addColor("loss_color", "Loss color", "", core.colors().Red);
end

local positions = {};

local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    
    --26/8/2019 00:00   16/12/2019 10:00   AUDCAD   Buy   0.93   0.89314   0.90412   566.84
    for line in io.lines(instance.parameters.file) do
        local day_start,
            month_start,
            year_start,
            hour_start,
            minute_start,
            day_end,
            month_end,
            year_end,
            hour_end,
            minute_end,
            symbol,
            bs,
            lots,
            open_price,
            close_price,
            profit = string.match(line, '(%d+)/(%d+)/(%d+) (%d+):(%d+) +(%d+)/(%d+)/(%d+) (%d+):(%d+) +(%w+) +(%w+) +(%d+.%d+) +(%d+.%d+) +(%d+.%d+) +(-?%d+.%d+)');
        if day_start ~= nil then
            local position = {};
            local startDate = 
            {
                month = tonumber(month_start);
                day = tonumber(day_start);
                year = tonumber(year_start);
                hour = tonumber(hour_start);
                min = tonumber(minute_start);
                sec = 0;
            };
            position.OpenDate = core.tableToDate(startDate);
            local endDate = 
            {
                month = tonumber(month_end);
                day = tonumber(day_end);
                year = tonumber(year_end);
                hour = tonumber(hour_end);
                min = tonumber(minute_end);
                sec = 0;
            };
            position.CloseDate = core.tableToDate(endDate);
            position.Symbol = symbol;
            position.BS = bs;
            position.Lots = tonumber(lots);
            position.OpenPrice = tonumber(open_price);
            position.ClosePrice = tonumber(close_price);
            position.Profit = tonumber(profit);

            positions[#positions + 1] = position;
        end
    end
    instance:ownerDrawn(true)
end

function Update(period, mode)
end

local init = false;
local LOSS_LINE = 1;
local PROFIT_LINE = 2;
local ARROW_FONT = 3;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(LOSS_LINE, context.SOLID, 1, instance.parameters.loss_color);
        context:createPen(PROFIT_LINE, context.SOLID, 1, instance.parameters.profit_color);
        context:createFont(ARROW_FONT, "Wingdings", 0, context:pointsToPixels(8), 0);
        init = true;
    end

    for i, pos in ipairs(positions) do
        local x1 = context:positionOfDate(pos.OpenDate);
        local x2 = context:positionOfDate(pos.CloseDate);
        local _, y1 = context:pointOfPrice(pos.OpenPrice);
        local _, y2 = context:pointOfPrice(pos.ClosePrice);
        local open_arrow;
        local close_arrow;
        if pos.BS == "B" then
            open_arrow = "\218";
            close_arrow = "\217";
        else
            open_arrow = "\217";
            close_arrow = "\218";
        end
        local color;
        local pen;
        if pos.Profit >= 0 then
            color = instance.parameters.profit_color;
            pen = PROFIT_LINE;
        else
            color = instance.parameters.loss_color;
            pen = LOSS_LINE;
        end
        local w, h = context:measureText(ARROW_FONT, open_arrow, 0);
        context:drawText(ARROW_FONT, open_arrow, color, -1, x1 - w / 2, y1 - h / 2, x1 + w / 2, y1 + h / 2, 0);
        local w, h = context:measureText(ARROW_FONT, close_arrow, 0);
        context:drawText(ARROW_FONT, close_arrow, color, -1, x2 - w / 2, y2 - h / 2, x2 + w / 2, y2 + h / 2, 0);
        context:drawLine(pen, x1, y1, x2, y2);
        core.host:trace(tostring(x1));
    end
end