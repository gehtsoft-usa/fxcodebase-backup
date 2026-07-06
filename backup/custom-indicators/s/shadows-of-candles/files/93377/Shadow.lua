-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60498
-- Id: 11451

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
    indicator:name("Draw shadows on the candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("x_shift", "x shift", "x shift", 20);
    indicator.parameters:addInteger("y_shift", "y shift", "y shift", 20);
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(128, 128, 128));
end

local source = nil;
local color;
local x_shift, y_shift;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    x_shift = instance.parameters.x_shift/100;
    y_shift = instance.parameters.y_shift/100; 
    color = instance.parameters.color;
    instance:setLabelColor(color);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createSolidBrush(2, color);
            context:createPen(1, context.SOLID, 1, color);
            init = true;
        end

        local m1, p1;
        local m2, p2;
        local h, l;
        local x_shift_p, y_shift_p;

        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            
            if 2*(x2-c2)<=x_shift*(x2-x1) or x_shift*(x2-x1)<1 then
             break;
            end; 
            
            m1, p1 = context:pointOfPrice(source.open[index]);
            m2, p2 = context:pointOfPrice(source.close[index]);
            h=math.max(p1, p2);
            l=math.min(p1, p2);
            m1, p1 = context:pointOfPrice(source.high[index]);
            m2, p2 = context:pointOfPrice(source.low[index]);
            
            x_shift_p=x_shift*(x2-x1);
            y_shift_p=y_shift*(x2-x1);
            
            context:drawRectangle(1, 2, c1+x_shift_p, h+y_shift_p, c2+x_shift_p, l+y_shift_p);
            if p1~=l then
             context:drawLine(1, x+x_shift_p, l+y_shift_p, x+x_shift_p, p1+y_shift_p);
            end 
            if p2~=h then
             context:drawLine(1, x+x_shift_p, h+y_shift_p, x+x_shift_p, p2+y_shift_p);
            end 
            
        end

    end
end



