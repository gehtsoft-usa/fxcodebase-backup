-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=659

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Automatic Fib or Gann levels on the base of H/L values");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("N", "Number of periods to find H/L", "", 50);
    indicator.parameters:addString("M", "Lines Method", "", "F");
    indicator.parameters:addStringAlternative("M", "Fibonacci", "", "F");
    indicator.parameters:addStringAlternative("M", "Gann", "", "G");
    indicator.parameters:addString("L", "Levels number", "", "3");
    indicator.parameters:addStringAlternative("L", "3 Lines", "", "3");
    indicator.parameters:addStringAlternative("L", "5 Lines", "", "5");
    indicator.parameters:addStringAlternative("L", "7 Lines", "", "7");
    indicator.parameters:addStringAlternative("L", "9 Lines", "", "9");
    indicator.parameters:addInteger("E", "Number of bars to show lines after the latest bar char", "", 20, 1, 100);
    indicator.parameters:addBoolean("Flip", "Use L-H instead H-L", "", false);  
    indicator.parameters:addColor("L_color", "Color of level lines", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0));
    --indicator.parameters:addColor("T_color", "Label color", "", core.COLOR_LABEL);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local M;
local L;
local E;
local L_color;
local M_color;
--local T_color;

local first;
local source = nil;
local barSize;
local Flip;
-- Streams block
local D = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    M = instance.parameters.M;
    L = instance.parameters.L;
    E = instance.parameters.E;
    Flip = instance.parameters.Flip;
    L_color = instance.parameters.L_color;
    M_color = instance.parameters.M_color;
    --T_color = instance.parameters.T_color;
    source = instance.source;
    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    barSize = math.floor(((e - s) * 1440) + 0.5) / 1440;

    first = source:first() + N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ", " .. L .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    D = instance:addStream("D", core.Line, name, "D", instance.parameters.L_color, first, E);
end

local MIN = nil;
local MAX = nil;
local P = nil;
local levels = nil;
local index = nil;

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local min, max, minp, maxp, p, k, v, f, t, price, d;
        min, max, minp, maxp = core.minmax(source, core.rangeTo(period, N));
        p = math.min(minp, maxp);
        if MIN == nil or
           MIN ~= min or MAX ~= max or P ~= p then
            MIN = min;
            MAX = max;
            d = max - min;
            P = p;

            if levels == nil then
                CalcLevels();
            end
            local idx;
            idx = index[L];

            f = source:date(p);
            t = source:date(source:size() - 1) + ((E - 1) * barSize);

            for k, v in pairs(idx) do

                if Flip then
                    price = max - d * levels[v];
                else
                    price = min + d * levels[v];
                end    
                core.host:execute("drawLine", k, f, price, t, price, L_color);
                core.host:execute("drawLabel", k, f, price, "" .. levels[v] .. "=" .. price);

            end
            core.host:execute("drawLine", 10, f, min, f, max, M_color);
        end
    end
end

function CalcLevels()
    levels = {};
    index = {};
    if M == "F" then
        levels[1] = -0.236;
        levels[2] = 0;
        levels[3] = 0.236;
        levels[4] = 0.382;
        levels[5] = 0.5;
        levels[6] = 0.618;
        levels[7] = 0.764;
        levels[8] = 1;
        levels[9] = 1.272;
        index["3"] = {4, 5, 6};
        index["5"] = {2, 4, 5, 6, 8};
        index["7"] = {2, 3, 4, 5, 6, 7, 8};
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    else
        levels[1] = 0;
        levels[2] = 0.125;
        levels[3] = 0.25;
        levels[4] = 0.375;
        levels[5] = 0.5;
        levels[6] = 0.625;
        levels[7] = 0.75;
        levels[8] = 0.875;
        levels[9] = 1;
        index["3"] = {3, 5, 7};
        index["5"] = {1, 3, 5, 7, 9};
        index["7"] = {1, 3, 4, 5, 6, 7, 9};
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    end

end
