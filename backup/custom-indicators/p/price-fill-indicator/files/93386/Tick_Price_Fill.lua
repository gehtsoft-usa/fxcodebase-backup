-- Id: 16079
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60503

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Price fill of the chart area");
    indicator:description("Fills the area below the chosen price with semi-transparent filling");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 

    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local price = nil, pricesrc;
local color, mcolor;
local transparency; 
-- initializes the instance of the indicator
function Prepare(onlyName)
    instance:name(profile:id());
    if onlyName then
        return ;
    end

    instance:setLabelColor(instance.parameters.color); 
        price = instance.source;
 

    color = instance.parameters.color;
    mcolor = instance.parameters.mcolor;
    transparency = instance.parameters.transparency;

    instance:ownerDrawn(true);
end

function Update(period)
end

local drawInit = false;

function Draw(stage, context)
    if stage == 0 then
        if not drawInit then
            context:createPen(1, context.SOLID, 1, color);
            context:createSolidBrush(2, color);
            transparency = context:convertTransparency(transparency);
            drawInit = true;
        end


        local points = ownerdraw_points.new();

        local first = true;
        local last = nil;
        local m, p;
        local y, yp, xp;
        local ix, iy;
        local leftmost;
        local rightmost;
        local index, c, x1, x2, c1, c2;
        local lastX = nil;

        context:startEnumeration();
        while true do
            index, c, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end

            
                x = x2;
            

            if lastX == nil or x - lastX >= 3 then
                last = index;
                m, y = context:pointOfPrice(price[index]);

                if first then
                    if index == 0 then
                        m, yp = context:pointOfPrice(instance.source.open[index]);
                        xp = context:left();
                    else
                        m, yp = context:pointOfPrice(price[index - 1]);
                        xp = context:positionOfBar(index - 1);
                    end
                    points:add(xp, yp);
                    leftmost = xp;
                    first = false;
                end
                points:add(x, y);
                lastX = x;
            end
        end

        -- if we have at least one peak
        if last ~= nil then
            if last < price:size() - 1 then
                m, yp = context:pointOfPrice(price[last + 1]);
                xp = context:positionOfBar(last + 1);
                rightmost = xp;
            else
                points:add(context:right(), y);
                rightmost = context:right();
            end

            points:add(rightmost, context:bottom());
            points:add(leftmost, context:bottom());

            context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
            context:drawPolygon(1, 2, points, transparency);
            context:resetClipRectangle();

           
        end
    end
end
