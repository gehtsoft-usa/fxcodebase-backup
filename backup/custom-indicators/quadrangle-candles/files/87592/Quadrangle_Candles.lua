-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58431
-- Id: 9572

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
    indicator:name("Rectangle candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPcolor", "UP color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local init;
local UPcolor, DNcolor, transparency;
local source;
local first;
local open, high, low, close;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source=instance.source;
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    first=source:first();

    local name = profile:id();
    instance:name(name);

    if onlyName then
        return ;
    end
    
    instance:setLabelColor(instance.parameters.UPcolor);
    
    instance:ownerDrawn(true);
    init=false;
    open = instance:addStream("open", core.Dot, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Dot, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Dot, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Dot, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("QC", "QC", open, high, low, close);
    open:setVisible(false);
    high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
end

function Update(period, mode)
 open[period]=source.open[period];
 high[period]=source.high[period];
 low[period]=source.low[period];
 close[period]=source.close[period];
end

function Draw(stage, context)
    if stage == 2 then
        if not init then
            transparency=context:convertTransparency(instance.parameters.transparency);
            context:createPen(1, context.SOLID, 1, UPcolor);
            context:createSolidBrush(2, UPcolor);
            context:createPen(3, context.SOLID, 1, DNcolor);
            context:createSolidBrush(4, DNcolor);
            init = true;
        end
        
        local m, po, pc, ph, pl;
        local m2, p2;
        local Hbegin, Hend;
        local Points;
        
        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            
            m, po = context:pointOfPrice(source.open[index]);
            m, ph = context:pointOfPrice(source.high[index]);
            m, pl = context:pointOfPrice(source.low[index]);
            m, pc = context:pointOfPrice(source.close[index]);
            
            Points = context:createPoints();
            Points:add(x1, po);
            Points:add(x, ph);
            Points:add(x2, pc);
            Points:add(x, pl);
            
            if source.open[index]<=source.close[index] then
             context:drawPolygon(1,2,Points,transparency);
            else
	     context:drawPolygon(3,4,Points,transparency);
	    end 
            
        end
    end

end
