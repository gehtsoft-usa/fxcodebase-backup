-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62424


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
    indicator:name("Draws 3D shadows on the candles");
    indicator:description("Draws 3D shadows on the candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("x_shift", "Horizontal shift", "Horizontal shift", 20);
    indicator.parameters:addInteger("y_shift", "Vertical shift", "Vertical shift", 20);
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(193, 240, 155));
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 128, 64));
    indicator.parameters:addColor("color2", "Fill bottom Color", "", core.rgb(151, 230, 87));
end

local source = nil;
local color;
local x_shift, y_shift;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
    
    x_shift = instance.parameters.x_shift/100;
    y_shift = instance.parameters.y_shift/100; 
    color = instance.parameters.color;
    color1 = instance.parameters.color1;
    color2 = instance.parameters.color2;

    instance:setLabelColor(color);
	instance:ownerDrawn(true);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createSolidBrush(2, color);
            context:createSolidBrush(22, color2);
            context:createPen(1, context.SOLID, 1, color1);
            context:createPen(11, context.DOT, 1, color1);
            init = true;
        end

        local m1, p1;
        local m2, p2;
        local h, l;
        local x_shift_p, y_shift_p;
       
        context:setClipRectangle (context:left(), context:top(), context:right(), context:bottom());

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
            
           
            

            local points = context:createPoints();
            local points1 = context:createPoints();

            local points2 = context:createPoints();
            local points3 = context:createPoints();

            points:add(c2+x_shift_p, l+y_shift_p);
            points:add(c2+x_shift_p, h+y_shift_p);
            points:add(c2, h);
            points:add(c2, l);

            points1:add(c2+x_shift_p, h+y_shift_p);
            points1:add(c1+x_shift_p, h+y_shift_p);
            points1:add(c1, h);
            points1:add(c2, h);

            points2:add(x, l);
            points2:add(x, p1);
            points2:add(x+x_shift_p, p1+y_shift_p);
            points2:add(x+x_shift_p, l+y_shift_p); 

            points3:add(x, h);
            points3:add(x, p2);
            points3:add(x+x_shift_p, p2+y_shift_p);
            points3:add(x+x_shift_p, h+y_shift_p);

            if p1~=l then
                context:drawPolygon (1, 2, points2);
            end  


            context:drawPolygon (1, 2, points);
            context:drawPolygon (1, 22, points1);

            context:drawLine (11, c1, l, c1+x_shift_p, l+y_shift_p);
            context:drawLine (11, c1+x_shift_p, h+y_shift_p, c1+x_shift_p, l+y_shift_p);
            context:drawLine (11, c1+x_shift_p, l+y_shift_p, c2+x_shift_p, l+y_shift_p);
            
            if p1~=l then
             context:drawLine(1, x+x_shift_p, l+y_shift_p, x+x_shift_p, p1+y_shift_p);
             context:drawLine(1, x, p1, x+x_shift_p, p1+y_shift_p);
             context:drawLine(11, x, l, x+x_shift_p, l+y_shift_p);
             context:drawLine(11, x+x_shift_p, h+y_shift_p, x+x_shift_p, l+y_shift_p);
            end 
            if p2~=h then
             context:drawLine(1, x+x_shift_p, h+y_shift_p, x+x_shift_p, p2+y_shift_p);
             context:drawLine(1, x, p2, x+x_shift_p, p2+y_shift_p);
             context:drawLine(1, x, h, x+x_shift_p, h+y_shift_p);
             context:drawPolygon (1, 2, points3);
            end 

        end
        context:resetClipRectangle();

    end
end



