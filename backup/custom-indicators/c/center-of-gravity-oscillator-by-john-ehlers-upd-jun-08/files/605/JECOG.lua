-- Id: 859
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=366


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
function Init()
    indicator:name("John Ehlers' Center Of Gravity Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("FIR_N", "FIR (LWMA) number of periods", "No description", 10);
    indicator.parameters:addInteger("S_N", "Signal Line Smoothing Periods", "No description", 3);
    indicator.parameters:addString("PM", "Price Mode", "", "C");
    indicator.parameters:addStringAlternative("PM", "Close", "", "C");
    indicator.parameters:addStringAlternative("PM", "Median", "", "M");
    indicator.parameters:addStringAlternative("PM", "Typical", "", "T");
    indicator.parameters:addStringAlternative("PM", "Weighted", "", "W");
    indicator.parameters:addColor("CG_color", "Color of CG", "Color of CG", core.rgb(0, 255, 255));
    indicator.parameters:addColor("SIG_color", "Color of SIG", "Color of SIG", core.rgb(255, 128, 64));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local FIR_N;
local S_N;
local PM;

local firstCG;
local firstSIG;
local source = nil;

-- Streams block
local CG = nil;
local SIG = nil;
local PRICE;

-- Routine
function Prepare(nameOnly)
    FIR_N = instance.parameters.FIR_N;
    S_N = instance.parameters.S_N;
    PM = instance.parameters.PM;
    source = instance.source;
    firstCG = source:first() + FIR_N;
    firstSIG = firstCG + S_N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FIR_N .. ", " .. S_N .. ", " .. PM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if PM == "C" then
        PRICE = source.close;
    elseif PM == "M" then
        PRICE  = source.median;
    elseif PM == "T" then
        PRICE  = source.typical;
    elseif PM == "W" then
        PRICE  = source.weighted;
    end
    CG = instance:addStream("CG", core.Line, name .. ".CG", "CG", instance.parameters.CG_color, firstCG);
    CG:setPrecision(math.max(2, instance.source:getPrecision()));
    SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
    SIG:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period)
    if period >= firstCG then
        local k, i, s, w;
        k = FIR_N;
        s = 0;
        w = 0;
        for i = period - FIR_N + 1, period, 1 do
            w = w + k * PRICE[i];
            s = s + PRICE[i];
            k = k - 1;
        end
        CG[period] = -w / s;
    end

    if period >= firstSIG then
        SIG[period] = core.avg(CG, core.rangeTo(period, S_N));
    end
end

