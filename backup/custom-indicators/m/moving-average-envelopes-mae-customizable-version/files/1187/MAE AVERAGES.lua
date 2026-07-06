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
    indicator:name("Moving Average Envelope (AVERAGES)");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");

    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addDouble("B", "Band Width", "", 25);
    indicator.parameters:addString("BWU", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("SM", "Show MA line", "", true);
    indicator.parameters:addColor("MVA_color", "Color of MA line", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("B_color", "Color of Band", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local B;
local BWU;
local Method;
local SM;

local first;
local source = nil;
local IND;

-- Streams block
local MVA = nil;
local UB = nil;
local LB = nil;

-- Routine
 function Prepare(nameOnly) 
    Period = instance.parameters.Period;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    Method = instance.parameters.Method;
    SM = instance.parameters.SM;
    source = instance.source;
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
    IND = core.indicators:create("AVERAGES", source, Method, Period);
    first = IND.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. "," ..Method .. "(" .. Period .. ")," .. B .. BWU .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if BWU == "%%" then
        BWU = 1;
    else
        BWU = 2;
        B = B * source:pipSize();
    end

    if SM then
        MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_color, first);
    end
    UB = instance:addStream("UB", core.Line, name .. ".UB", "UB", instance.parameters.B_color, first);
    LB = instance:addStream("LB", core.Line, name .. ".LB", "LB", instance.parameters.B_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first then
        IND:update(mode);

        local d = IND.DATA[period];
        local s;

        if BWU == 1 then
            s = d * B / 10000;
        else
            s = B;
        end

        if SM then
            MVA[period] = d;
        end
        UB[period] = d + s;
        LB[period] = d - s;
    end
end

