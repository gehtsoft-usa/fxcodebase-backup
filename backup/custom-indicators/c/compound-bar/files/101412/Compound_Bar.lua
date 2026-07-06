-- Id: 14447
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62425

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Compound Bar");
    indicator:description("Compound Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    
    indicator.parameters:addColor("color", "Up Fill Color", "", core.rgb(128, 128, 255));
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(128, 128, 255));
    indicator.parameters:addColor("color2", "Down Fill Color", "", core.rgb(255, 128, 64));
    indicator.parameters:addColor("color3", "Down Line Color", "", core.rgb(255, 128, 64));
end

local source = nil;
local color, color1, color2, color3;


-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    instance:ownerDrawn(true);
    
    color = instance.parameters.color;
    color1 = instance.parameters.color1;
    color2 = instance.parameters.color2;
    color3 = instance.parameters.color3;


    instance:setLabelColor(color);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 1 then
    
        if not init then
            
            context:createSolidBrush(2, color);
            context:createSolidBrush(22, color2);
            context:createPen(1, context.SOLID, 1, color1);
            context:createPen(11, context.SOLID, 1, color3);
            
            init = true;
        end

        local m1, p1;
        local m2, p2;
        local m3, p3;
        local m4, p4;
        local a, b, c, d, h, l, aa, bb, cc, dd, hh, ll;
        local f1=0;
        local f2=0;
           
        context:setClipRectangle (context:left(), context:top(), context:right(), context:bottom());

        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
                                    
            m1, p1 = context:pointOfPrice(source.open[index]);
            m2, p2 = context:pointOfPrice(source.close[index]);
            m3, p3 = context:pointOfPrice(source.high[index]);
            m4, p4 = context:pointOfPrice(source.low[index]);


            if p1>p2 then 
                b=c2;
                d=p2;
                
                if f1==0 then
                f1=1;
                a=c1;
                c=p1;
                h=10000000000;
                l=0;
                end 
                if p3<h then
                    h=p3;
                end    
                if p4>l then
                    l=p4;
                end                   
            end;

            if p1<p2 and f1==1 then
                f1=0;
                context:drawRectangle (1, 2, a, c, b, d, 140);
                context:drawLine (1, (a+b)/2, h, (a+b)/2, d, 0);
                context:drawLine (1, (a+b)/2, l, (a+b)/2, c, 0);

            end;  

             if p1<p2 then
                bb=c2;
                dd=p2;
                if f2==0 then 
                f2=1;
                aa=c1;
                cc=p1;
                hh=10000000000;
                ll=0;
                end
                if p3<hh then
                    hh=p3;
                end    
                if p4>ll then
                    ll=p4;
                end  
            end;

            if p1>p2 and f2==1 then
                f2=0;                
                context:drawRectangle (11, 22, aa, cc, bb, dd, 140);
                context:drawLine (11, (aa+bb)/2, hh, (aa+bb)/2, cc, 0);
                context:drawLine (11, (aa+bb)/2, ll, (aa+bb)/2, dd, 0);
            end;          

            
            
        end

        context:resetClipRectangle();

    end
end



