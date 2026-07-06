--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- The indicator corresponds to the Larry Williams' Percent Range indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 143)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("param_N_name"), resources:get("param_N_description"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRLW", resources:get("param_clrRLW_name"), resources:get("param_clrRLW_description"), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRLW", resources:get("param_widthRLW_name"), resources:get("param_widthRLW_description"), 1, 1, 5);
    indicator.parameters:addInteger("styleRLW", resources:get("param_styleRLW_name"), resources:get("param_styleRLW_description"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleRLW", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", resources:get("param_level_overbought_name"), resources:get("param_level_overbought_description"), -20, -100, 0);
    indicator.parameters:addInteger("oversold", resources:get("param_level_oversold_name"), resources:get("param_level_oversold_description"), -80, -100, 0);
    indicator.parameters:addInteger("level_overboughtsold_width", resources:get("param_level_overboughtsold_width_name"), resources:get("param_level_overboughtsold_width_description"), 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", resources:get("param_level_overboughtsold_style_name"), resources:get("param_level_overboughtsold_style_description"), core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", resources:get("param_level_overboughtsold_color_name"), resources:get("param_level_overboughtsold_color_description"), core.rgb(96, 96, 138));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;

-- Streams block
local RLW = nil;

-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, resources:get("error_bought_bigger_sold"));

    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    RLW = instance:addStream("RLW", core.Line, name, "%R", instance.parameters.clrRLW, first)
    RLW:setWidth(instance.parameters.widthRLW);
    RLW:setStyle(instance.parameters.styleRLW);
    RLW:setPrecision(2);

    RLW:addLevel(0);
    RLW:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(-100);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local from = period - n + 1;
        low, high = mathex.minmax(source, from, period);
        local diff = high - low;
        if (diff == 0) then
            RLW[period] = 0;
        else
            RLW[period] = (-100) * (high - source[period]) / diff;
        end
    end
end

