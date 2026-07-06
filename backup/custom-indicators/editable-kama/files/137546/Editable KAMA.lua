
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70422

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


-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 17 "Adaptive Techniques" (page 436-438)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("KAMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "", 14, 1, 1000);
	indicator.parameters:addDouble("fastend", "fastend", "", 0.666 );
	indicator.parameters:addDouble("slowend", "slowend", "",  0.0645);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrKAMA", "Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthKAMA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleKAMA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleKAMA", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local first1;
local source = nil;
local slowend, fastend;
-- Streams block
local KAMA = nil;
local INT = nil;

 

-- Routine
function Prepare()
    n = instance.parameters.N;
	slowend= instance.parameters.slowend;
	fastend= instance.parameters.fastend;
	
    source = instance.source;
    first1 = source:first() + 1;
    first = first1 + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n.. ", " .. slowend.. ", " .. fastend .. ")";
    instance:name(name);
    INT = instance:addInternalStream(first1, 0);
    KAMA = instance:addStream("KAMA", core.Line, name, "KAMA", instance.parameters.clrKAMA, first)
    KAMA:setWidth(instance.parameters.widthKAMA);
    KAMA:setStyle(instance.parameters.styleKAMA);
 
end




-- Indicator calculation routine
 

function Update(period)
    if period >= first1 then
        INT[period] = math.abs(source[period] - source[period - 1]);
    end
    if period >= first then
        local value = 0;
        if (period == first) then
            value = source[period];
        else
            value = KAMA[period - 1];
        end
        local i = 0;
        local er = 0;
        er = core.sum(INT, period - n + 1, period);
        if er ~= 0 then
            er = math.abs(source[period] - source[period - n + 1]) / er;
        end
        local sc = er * (fastend - slowend) + slowend;
        sc = sc * sc;
        KAMA[period] = value + sc * (source[period] - value);
    end
end

 