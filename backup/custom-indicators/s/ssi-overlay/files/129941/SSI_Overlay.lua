-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69158

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
    indicator:name("SSI Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("color", "Color", "", core.colors().Red);
end

local source;
local ssi;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    instance:ownerDrawn(true);
    ssi = core.indicators:create("SSI", source, "SSI");
end

function Update(period, mode)
    ssi:update(mode);
end

local init = false;
local pen = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(pen, context.SOLID, 1, instance.parameters.color);
    end

    local stream = ssi.DATA;

    local from_bar = math.max(source:first(), context:firstBar() - 1)
    local to_bar = math.min(context:lastBar(), source:size() - 1)
    local indi_min, indi_max;
    for i = from_bar, to_bar, 1 do
        if stream:hasData(i) then
            if indi_min == nil then
                indi_min = stream[i];
                indi_max = stream[i];
            else
                if indi_min > stream[i] then
                    indi_min = stream[i];
                end
                if indi_max < stream[i] then
                    indi_max = stream[i];
                end
            end
        end
    end
    if indi_min == nil then
        return;
    end

    local previous_value, previous_x, previous_y;
    local top = context:top();
    local bottom = context:bottom();
    local range = bottom - top;
    local indi_range = indi_max - indi_min;
    if indi_range == nil then
        return;
    end
	for i = from_bar, to_bar, 1 do
        local x_center, x_left, x_right = context:positionOfBar(i);
        if stream:hasData(i) then
            local y = top + range * (indi_max - stream[i]) / indi_range;
            if previous_value ~= nil then
                context:drawLine(pen, previous_x, previous_y, x_center, y);
            end
            previous_x = x_center;
            previous_y = y;
            previous_value = stream[i];
        end
	end
end