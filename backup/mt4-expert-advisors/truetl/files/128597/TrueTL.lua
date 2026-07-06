-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("TrueTL");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("Normal_TL_Period", "Normal_TL_Period", "", 500);
    indicator.parameters:addBoolean("Three_Touch", "Three_Touch", "", true);
    indicator.parameters:addBoolean("Mark_source.highest_and_source.lowest_TL", "Mark_source.highest_and_source.lowest_TL", "", true);
    indicator.parameters:addInteger("Expiration_Day_Alert", "Expiration_Day_Alert", "", 5)

    indicator.parameters:addColor("Normal_TL_Color", "Normal_TL_Color", "", core.colors().Gainsboro);
end

local fractal, Normal_TL_Color;
local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Normal_TL_Color = instance.parameters.Normal_TL_Color;

    fractal = core.indicators:create("FRACTAL", source);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    fractal:update(mode);
end

function FindHigh(context)
    for i = -1, -50, -1 do
        if fractal:getTextOutput(0):hasData(i) then
            return i;
        end
        local prev_close = source.close[i - 1];
        local close = source.close[i];
        local prev_low = source.low[i - 1];
        local prev_high = source.high[i - 1];
        local prev_open = source.open[i - 1];
        local open = source.open[i];
        if prev_close > prev_open and (prev_close - prev_low) < 0.6 * (prev_high - prev_low) and close < open then
            return i;
        end
        if prev_close <= prev_open and close < open then
            return i;
        end
        if close < open and close < prev_low then
            return i;
        end
    end
    return nil;
end

local init = false;
local HIGH_PEN = 1;
local LOW_PEN = 2;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(HIGH_PEN, context.SOLID, 1, Normal_TL_Color);
        context:createPen(LOW_PEN, context.SOLID, 1, Normal_TL_Color);
        init = true;
    end

    local line_end = context:firstBar();
    local line_start = context:firstBar();
    local line_end_low = context:firstBar();
    local line_start_low = context:firstBar();
    for ii = 1, 30 do
        line_start = line_end;
        line_end = line_end + 1;
        for i = line_end + 1, math.min(source:size() - 1, context:lastBar()) do
            if (source.high[line_end] < source.high[line_start]) then
                line_end = i;
            else
                local rate = (source.high[line_end] - source.high[line_start]) / (line_end - line_start + 1);
                local ld_76 = source.high[line_start] + rate * (i - line_start);
                if ld_76 < source.high[i] then
                    line_end = i;
                end
            end
        end
        if line_end < source:size() - 1 and source.high[line_start] < source.high[line_end] then
            local _, y1 = context:pointOfPrice(source.high[line_start]);
            local _, y2 = context:pointOfPrice(source.high[line_end]);
            local x1 = context:positionOfBar(line_start);
            local x2 = context:positionOfBar(line_end);
            context:drawLine(HIGH_PEN, x1, y1, x2, y2);
        end

        line_start_low = line_end_low;
        line_end_low = line_end_low + 1;
        for i = line_end_low + 1, math.min(source:size() - 1, context:lastBar()) do
            if (source.low[line_end_low] > source.low[line_start_low]) then
                line_end_low = i;
            else
                local rate = (source.low[line_end_low] - source.low[line_start_low]) / (line_end_low - line_start_low + 1);
                local ld_76 = source.low[line_start_low] + rate * (i - line_start_low);
                if ld_76 > source.low[i] then
                    line_end_low = i;
                end
            end
        end
        if line_end_low < source:size() - 1 and source.low[line_start_low] > source.low[line_end_low] then
            local _, y1 = context:pointOfPrice(source.low[line_start_low]);
            local _, y2 = context:pointOfPrice(source.low[line_end_low]);
            local x1 = context:positionOfBar(line_start_low);
            local x2 = context:positionOfBar(line_end_low);
            context:drawLine(LOW_PEN, x1, y1, x2, y2);
        end
    end
end