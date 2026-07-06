-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58433
-- Id: 9577

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Current position on the whole chart indicator");
    indicator:description("Displays an image of the whole chart and the position of the screen on this chart.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("oscm", "Oscillator mode", "", false);
    indicator.parameters:addInteger("height", "Height of the indicator on the screen in pixels", "", 50, 10, 1000);
    indicator.parameters:addColor("color", "Whole chart color", "", core.rgb(0, 128, 128));
    indicator.parameters:addColor("mcolor", "Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("transparency", "Whole chart transparency (%)", "0% - opaque, 100% - transparent", 75, 0, 100);
    indicator.parameters:addInteger("mtransparency", "Marker transparency (%)", "0% - opaque, 100% - transparent", 50, 0, 100);
end

local source, first, alive;
local cmax, cmin;
local points;
local color, transparency, mtransparency, height, oscm;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instance:name(profile:id());
    if onlyName then
        return ;
    end

    height = instance.parameters.height;
    color = instance.parameters.color;
    mcolor = instance.parameters.mcolor;
    oscm = instance.parameters.oscm;
    transparency = instance.parameters.transparency;
    mtransparency = instance.parameters.mtransparency;


    instance:ownerDrawn(true);


    source = instance.source.close;
    first = source:first();
    alive = source:isAlive();
    instance:setLabelColor(color);

    if oscm then
        output = instance:addStream("t", core.Line, "t", "t", color, first, 0);
    end

    points = nil;
end

local lastPeriod = nil;
local pointsRebuild = false;

function Update(period)
    if lastPeriod ~= nil and period < lastPeriod then
        -- scroll back detection
        points = nil;
    end
    lastPeriod = period;

    if period > first + 1 and period == source:size() - 1 then
        if points == nil then
            buildPoints();
        else
            if alive then
                if source[period] > cmax or source[period] < cmin then
                    buildPoints();
                else
                    updatePoints(period - 1);
                end
            end
        end
    end
end

function buildPoints()
    local last = source:size() - 1;
    cmin, cmax = mathex.minmax(source, first, last);
    points = ownerdraw_points.new();

    pointsRebuild = true;

    local i;
    local range = cmax - cmin;
    for i = first, last, 1 do
        if oscm then
            output[i] = (source[i] - cmin) / range * 1000;
        end
        points:add(i, (source[i] - cmin) / range * 1000);
    end
end

function updatePoints(from)
    local last = source:size() - 1;
    local range = cmax - cmin;
    for i = from, last, 1 do
        if i < points:size() then
            points:set(i - first, i, (source[i] - cmin) / range * 1000);
        else
            pointsRebuild = true;
            points:add(i, (source[i] - cmin) / range * 1000);
        end
        if oscm then
            output[i] = (source[i] - cmin) / range * 1000;
        end
    end
end

local drawInit = false;
local lastW, lastH, lastPoints = nil;

function Draw(stage, context)
    if stage == 0 then
        if not drawInit then
            context:createSolidBrush(1, color);
            context:createSolidBrush(2, mcolor);
            context:createPen(3, context.SOLID, 1, mcolor);
            transparency = context:convertTransparency(transparency);
            mtransparency = context:convertTransparency(mtransparency);
            drawInit = true;
        end

        if points:size() > 1 then
            local src = ownerdraw_points.new();
            src:add(0, 0);
            src:add(points:size() - 1, 1000);
            local dst = ownerdraw_points.new();
            dst:add(context:left(), context:bottom());
            dst:add(context:right(), context:bottom() - height);

            local res;

            -- update the main polygon only if either points are window size is changed
            if pointsRebuild or lastPoints == nil or lastW ~= context:right() or lastH ~= context:bottom() then
                res = math2d.scaleShiftTransform(points, src, dst, 5, 1);
                res:add(context:right(), context:bottom());
                res:add(context:left(), context:bottom());
                lastPoints = res;
                lastW = context:right();
                lastH = context:bottom();
                pointsRebuild = false;
            else
                res = lastPoints;
            end

            if res:size() > 1 then
                context:drawPolygon(-1, 1, res, transparency);
                local x1 = context:firstBar();
                if x1 < first then
                    x1 = first;
                end
                local x2 = context:lastBar();
                if x2 >= source:size() then
                    x2 = source:size() - 1;
                end
                local range = cmax - cmin;
                local y1 = (source[x1] - cmin) / range * 1000;
                local y2 = (source[x2] - cmin) / range * 1000;

                local res1 = ownerdraw_points.new();
                res1:add(x1, y1);
                res1:add(x2, y2);

                local res2 = math2d.scaleShiftTransform(res1, src, dst);

                x1, y1 = res2:get(0);
                x2, y2 = res2:get(1);
                context:setClipRectangle(x1, context:bottom(), x2, context:bottom() - height);
                context:drawPolygon(-1, 2, res, mtransparency);
                context:resetClipRectangle();
            end
        end
    end
end