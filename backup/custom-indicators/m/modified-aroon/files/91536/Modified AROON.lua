-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60118
-- Id: 10702

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


-- AROON Indicator
-- Developed by Tushar Chande in 1995, Aroon is an indicator system
-- that can be used to determine whether a stock is trending or not and
-- how strong the trend is. "Aroon" means "Dawn's Early Light" in
-- Sanskrit and Chande choose that name for this indicator since it is
-- designed to reveal the beginning of a new trend.
-- The Aroon indicator system consists of two lines, 'Aroon(up)' and
-- 'Aroon(down)'. It takes a single parameter which is the number of time
-- periods to use in the calculation. Aroon(up) is the amount of time (on
-- a percentage basis) that has elapsed between the start of the time
-- period and the point at which the highest price during that time
-- period occurred. If the stock closes at a new high for the given
-- period, Aroon(up) will be +100. For each subsequent period that passes
-- without another new high, Aroon(up) moves down by an amount equal to
-- (1 / # of periods) x 100.
-- Technically, the formula for Aroon(up) is:
-- [[ (# of periods) - (# of periods since highest high during that time) ] / (# of periods) ] x 100--
-- The formula for Aroon(down) is :
-- [[ (# of periods) - (# of periods since lowest low during that time) ] / (# of periods) ] x 100

-- Indicator profile initialization routine
function Init()
    indicator:name("AROON Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 25, 3, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Up Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthUP", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleUP", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleUP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrDown", "Down Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDOWN", "Line Width","", 1, 1, 5);
   indicator.parameters:addInteger("styleDOWN", "Line Style","", core.LINE_SOLID);
   indicator.parameters:setFlag("styleDOWN", core.FLAG_LEVEL_STYLE);
   
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addDouble("central","Cental Level","", 50);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.clrUp, firstPeriod)
    UP:setWidth(instance.parameters.widthUP);
    UP:setStyle(instance.parameters.styleUP);
    UP:setPrecision(2);
    DOWN = instance:addStream("DOWN", core.Line, name .. ".DOWN", "DOWN", instance.parameters.clrDown, firstPeriod)
    DOWN:setWidth(instance.parameters.widthDOWN);
    DOWN:setStyle(instance.parameters.styleDOWN);
    DOWN:setPrecision(2);
	UP:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	UP:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	UP:addLevel(instance.parameters.central, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
end

-- Indicator calculation routine
function Update(period)
    local vmin, pmin;
    local vmax, pmax;
    if period >= firstPeriod then
        vmin, vmax, pmin, pmax = mathex.minmax(source, period - N + 1, period);
        UP[period] = (N - (period - pmax)) / N * 100;
        DOWN[period] = (N - (period - pmin)) / N * 100;
    end
end
