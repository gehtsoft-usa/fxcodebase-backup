-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70203

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("ADX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrADX", "Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthADX", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleADX", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LEVEL_STYLE);
end

local n;
local first, dmifirst;
local source = nil;
local buffer = nil;
local dmi = nil;
local ema = nil;

local ADX = nil;
local plus_buffer, minus_buffer, minus, plus;
function Prepare(onlyName)
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    dmi = core.indicators:create("DMI", source, n);
    dmifirst = dmi.DIP:first();

    buffer = instance:addInternalStream(dmifirst, 0);

    ema = core.indicators:create("EMA", buffer, n);
    first = ema.DATA:first();

    ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.clrADX, first)
    ADX:setPrecision(2);
    ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);
    plus_buffer = instance:addInternalStream(0, 0);
    minus_buffer = instance:addInternalStream(0, 0);
    minus = core.indicators:create("EMA", minus_buffer, n);
    plus = core.indicators:create("EMA", plus_buffer, n);
end

function TrueRange(p)
    local hl = math.abs(source.high[p] - source.low[p]);
    local hc = math.abs(source.high[p] - source.close[p - 1]);
    local lc = math.abs(source.low[p] - source.close[p - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

function Update(period, mode)
    dmi:update(mode);
    if period >= dmifirst then
        plus_buffer[period] = dmi.DIP[period] / TrueRange(period);
        minus_buffer[period] = dmi.DIM[period] / TrueRange(period);
        minus:update(mode);
        plus:update(mode);
        
        local div = plus.DATA[period] + minus.DATA[period];
        if (div == 0) then
            buffer[period] = 0;
        else
            buffer[period] = 100 * (math.abs(plus.DATA[period] - minus.DATA[period]) / div)
        end
    end

    if period >= first then
        ema:update(mode);
        ADX[period] = ema.DATA[period];
    end
end
