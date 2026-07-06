-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62296

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
    indicator:name("Tick Count Label");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period (In seconds)", "Period", 60);
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(0, 255, 255))
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
    indicator.parameters:addString("Corner", "Corner", "", "Right-Top")
    indicator.parameters:addStringAlternative("Corner", "Right-Top", "", "Right-Top")
    indicator.parameters:addStringAlternative("Corner", "Right-Bottom", "", "Right-Bottom")
    indicator.parameters:addStringAlternative("Corner", "Left-Bottom", "", "Left-Bottom")
end

local color
local transparency
local Corner, IntCorner
local indi;

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    
    Corner = instance.parameters.Corner

    if Corner == "Right-Top" then
        IntCorner = 0
    elseif Corner == "Right-Bottom" then
        IntCorner = 1
    elseif Corner == "Left-Top" then
        IntCorner = 2
    else
        IntCorner = 3
    end


    instance:ownerDrawn(true)


    local profile = core.indicators:findIndicator("TICK COUNT");
    assert(profile ~= nil, "Please, download and install " .. "TICK COUNT" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indi = core.indicators:create("TICK COUNT", source, instance.parameters.Period)

    color = instance.parameters.color
    transparency = instance.parameters.transparency
    if transparency == 100 then
        transparency = 255
    elseif transparency == 0 then
        transparency = 0
    else
        transparency = math.floor(255 * (transparency / 100.0) + 0.5)
    end
end

local init = false;
local x1, y1, x2, y2
local CustomX, CustomY
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createSolidBrush(1, color)
        context:createPen(2, context.SOLID, 1, color)
        context:createFont(3, "Arial", 5, 0, 0)
        init = true;
    end

    local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right()
    Size = 30;
    if IntCorner == 0 then
        x1 = right - Size
        y1 = top
        x2 = right
        y2 = top + Size
    elseif IntCorner == 1 then
        x1 = right - Size
        y1 = bottom - Size
        x2 = right
        y2 = bottom
    elseif IntCorner == 2 then
        x1 = left
        y1 = top
        x2 = left + Size
        y2 = top + Size
    elseif IntCorner == 3 then
        x1 = left
        y1 = bottom - Size
        x2 = left + Size
        y2 = bottom
    else
        x1 = CustomX
        y1 = CustomY
        x2 = x1 + Size
        if x2 > right then
            x2 = right
            x1 = right - Size
        end
        y2 = y1 + Size
        if y2 > bottom then
            y2 = bottom
            y1 = bottom - Size
        end
    end

    t = tostring(indi.DATA[indi.DATA:size() - 1]);
    local width, height = context:measureText(3, t, context.CENTER)
    if y2 + height <= bottom then
        context:drawText(3, t, color, -1, x1, y2, x2, y2 + height, context.CENTER)
    else
        context:drawText(3, t, color, -1, x1, y2 - height, x2, y2, context.CENTER)
    end
end

function Update(period, mode)
    indi:update(mode);
end