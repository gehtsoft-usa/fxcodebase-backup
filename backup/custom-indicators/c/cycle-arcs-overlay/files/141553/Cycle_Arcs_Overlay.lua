-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71101

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    indicator:name("Cycle Arcs Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("perc", "% of the screen", "", 25);
    indicator.parameters:addColor("color", "Color", "", core.colors().Red);
end

local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local pen = 1;
local perc;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        perc = instance.parameters.perc;
        context:createPen(pen, context.SOLID, 1, instance.parameters.color);
    end
    local height2 = perc * (context:bottom() - context:top()) / 100;
    local y = context:bottom() - height2;
    local from_bar = math.max(source:first(), context:firstBar());
    local to_bar = math.min(context:lastBar(), source:size() - 1);
    for i = from_bar, to_bar, 1 do
        local x_center, x_left, x_right = context:positionOfBar(i);
        context:drawArc(pen, -1, x_left, y, x_right, context:bottom() + height2, x_right, context:bottom(), x_left, context:bottom());
    end    
end