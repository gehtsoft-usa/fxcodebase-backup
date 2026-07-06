-- Id: 494
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=850

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- port of Kiko Segui's MT4 indicator FX_FISH_2MA.mq4
-- http://codebase.mql4.com/2075
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Firsher Transform with 2 Moving average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Periods for finding highest high and lowest low", "", 10);
    indicator.parameters:addString("PT", "Price Type", "", "M");
    indicator.parameters:addStringAlternative("PT", "Open", "", "O");
    indicator.parameters:addStringAlternative("PT", "High", "", "H");
    indicator.parameters:addStringAlternative("PT", "Low", "", "L");
    indicator.parameters:addStringAlternative("PT", "Close", "", "C");
    indicator.parameters:addStringAlternative("PT", "Median", "", "M");
    indicator.parameters:addStringAlternative("PT", "Typical", "", "T");
    indicator.parameters:addStringAlternative("PT", "Weighted", "", "W");
    indicator.parameters:addString("MA1M", "First smoothing method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA1M", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA1M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA1M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA1M", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA1M", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA1M", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA1M", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("MA1N", "First smoothing number of periods", "No description", 9);
    indicator.parameters:addString("MA2M", "Smoothign 2 method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "LWMA");
    indicator.parameters:addStringAlternative("MA2M", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA2M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA2M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA2M", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA2M", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA2M", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA2M", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("MA2N", "Smoothing 2 number of periods", "No description", 45);
    indicator.parameters:addColor("U_color", "Color of U", "Color of U", core.rgb(77, 109, 243));
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 194, 14));
    indicator.parameters:addColor("MA1_color", "Color of MA1", "Color of MA1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MA2_color", "Color of MA2", "Color of MA2", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local MA1M;
local MA1N;
local MA2M;
local MA2N;
local PT;

local first;
local source = nil;

-- Streams block
local U = nil;
local D = nil;
local O = nil;
local F = nil;
local MA1 = nil;
local MA2 = nil;
local firstMA1 = nil;
local firstMA2 = nil;
local IMA1 = nil;
local IMA2 = nil;
local p = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    MA1M = instance.parameters.MA1M;
    MA1N = instance.parameters.MA1N;
    MA2M = instance.parameters.MA2M;
    MA2N = instance.parameters.MA2N;
    PT = instance.parameters.PT;

    source = instance.source;

    if PT == "O" then
        p = source.open;
    elseif PT == "H" then
        p = source.high;
    elseif PT == "L" then
        p = source.low;
    elseif PT == "C" then
        p = source.close;
    elseif PT == "M" then
        p = source.median;
    elseif PT == "T" then
        p = source.typical;
    elseif PT == "W" then
        p = source.weighted;
    else
        assert(false, "Unknown price type");
    end

    first = source:first() + N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. MA1M .. ", " .. MA1N .. ", " .. MA2M .. ", " .. MA2N .. ", " .. PT .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    U = instance:addStream("U", core.Bar, name .. ".U", "U", instance.parameters.U_color, first);
    U:setPrecision(math.max(2, instance.source:getPrecision()));
    D = instance:addStream("D", core.Bar, name .. ".D", "D", instance.parameters.D_color, first);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    O = instance:addInternalStream(first, 0);
    F = instance:addInternalStream(first, 0);
	
	assert(core.indicators:findIndicator(MA1M) ~= nil, "Please, download and install " .. MA1M.. " indicator");    
	assert(core.indicators:findIndicator(MA2M) ~= nil, "Please, download and install " .. MA2M.. " indicator");    

    IMA1 = core.indicators:create(MA1M, F, MA1N);
    firstMA1 = IMA1.DATA:first();
    IMA2 = core.indicators:create(MA2M, IMA1.DATA, MA2N);
    firstMA2 = IMA1.DATA:first();

    MA1 = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1_color, firstMA1);
    MA1:setPrecision(math.max(2, instance.source:getPrecision()));
    MA2 = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2_color, firstMA2);
    MA2:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first then
        local HH, LL, O1, v, f, F1;
        LL, HH = core.minmax(source, core.rangeTo(period, N));
        if period == first then
            O1 = 0;
            F1 = 0;
        else
            O1 = O[period - 1];
            F1 = F[period - 1];
        end

        v = 0.33 * 2 * ((p[period] - LL) / (HH - LL) - 0.5) + 0.67 * O1;
        v = math.min(math.max(v, -0.999), 0.999);
        O[period] = v;
        f = 0.5 * math.log((1 + v) / (1 - v)) + 0.5 * F1;
        F[period] = f;
        if f > 0 then
            U[period] = f;
            D[period] = 0;
        else
            U[period] = 0;
            D[period] = f;
        end
    end

    IMA1:update(mode);
    IMA2:update(mode);

    if period >= firstMA1 then
        MA1[period] = IMA1.DATA[period];
    end
    if period >= firstMA2 then
        MA2[period] = IMA2.DATA[period];
    end
end

