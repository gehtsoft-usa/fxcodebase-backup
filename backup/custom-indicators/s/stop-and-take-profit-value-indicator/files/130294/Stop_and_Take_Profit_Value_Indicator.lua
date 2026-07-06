-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69240

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
    indicator:name("Stop and Take Profit Value");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("font_size", "Font size", "", 12);
    indicator.parameters:addColor("stop_color", "Stop color", "", core.colors().Red);
    indicator.parameters:addColor("limit_color", "Limit color", "", core.colors().Green);
end

local source;
local offer;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    offer = core.host:findTable("offers"):find("Instrument", source:instrument());
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local FONT = 1;

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(instance.parameters.font_size), 0);
    end

    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == source:instrument() then
            if row.Stop ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = -math.abs(row.Stop - row.Open) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Stop);
                context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
            if row.Limit ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = math.abs(row.Limit - row.Open) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Limit);
                context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
        end
        row = enum:next();
    end

    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == source:instrument() then
            if row.Stop ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = -math.abs(row.Stop - row.Rate) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Stop);
                context:drawText(FONT, cost_text, instance.parameters.stop_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
            if row.Limit ~= 0 then
                local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, row.AccountID);
                local distance = math.abs(row.Limit - row.Rate) / source:pipSize();
                local cost = distance * offer.PipCost * row.Lot / base_unit_size;
                local cost_text = win32.formatNumber(cost, false, 2);
                local w, h = context:measureText(FONT, cost_text, 0);
                local _, y = context:pointOfPrice(row.Limit);
                context:drawText(FONT, cost_text, instance.parameters.limit_color, -1, context:right() - w, y - h, context:right(), y, 0);
            end
        end
        row = enum:next();
    end
end
