-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69262

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
    indicator:name("Leavitt Conv Slope");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Length", "Length", "", 61);
    indicator.parameters:addDouble("UnSure", "Unsure", "", 0.0002);

    indicator.parameters:addColor("slope_color_up", "Up Color", "", core.colors().Green);
    indicator.parameters:addColor("slope_color_down", "Down Color", "", core.colors().Red);
    indicator.parameters:addInteger("slope_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("slope_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("slope_style", core.FLAG_LINE_STYLE);
end

local slope_color_up, slope_color_down;
local source, slope, reg1, reg2;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    slope_color_down = instance.parameters.slope_color_down;
    slope_color_up = instance.parameters.slope_color_up;
    slope = instance:addStream("slope", core.Line, "Slope", "Slope", instance.parameters.slope_color_down, 0, 0);
    slope:setWidth(instance.parameters.slope_width);
    slope:setStyle(instance.parameters.slope_style);
    slope:addLevel(instance.parameters.UnSure);
    slope:addLevel(-instance.parameters.UnSure);

    local Length = instance.parameters.Length;
    local LenConv = math.floor(math.sqrt(Length));
    reg1 = core.indicators:create("REGRESSION", source, Length);
    reg2 = core.indicators:create("REGRESSION", reg1.DATA, LenConv);
end

function Update(period, mode)
    reg1:update(mode);
    reg2:update(mode);
    if period == 0 or not reg2.DATA:hasData(period - 1) then
        return;
    end

    slope[period] = reg2.DATA[period] - reg2.DATA[period - 1];
    if slope:hasData(period - 1) then
        if slope[period] > slope[period - 1] then
            slope:setColor(period, slope_color_up);
        else
            slope:setColor(period, slope_color_down);
        end
    end
end
