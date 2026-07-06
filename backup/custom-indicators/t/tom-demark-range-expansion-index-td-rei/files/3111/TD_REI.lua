-- Id: 1063
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1585

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tom Demark Range Expansion Index");
    indicator:description("The indicator is intended to identify exaggeration phases (overbought or oversold), which generally coincide with price highs and lows.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Number of periods", "", 5, 1, 100);
    indicator.parameters:addInteger("OS", "Oversold level", "", -45);
    indicator.parameters:addInteger("OB", "Overbough level", "", 45);
    indicator.parameters:addColor("REI_color", "Color of the oscillator", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local OS;
local OB;

local first, firstD;
local source = nil;

-- Streams block
local REI = nil;
local H, L, C;
local D, R;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    OS = instance.parameters.OS;
    OB = instance.parameters.OB;
    source = instance.source;
    H = source.high;
    L = source.low;
    C = source.close;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. OS .. ", " .. OB .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    -- deltas
    firstD = source:first() + 9;
    D = instance:addInternalStream(firstD, 0);
    R = instance:addInternalStream(firstD, 0);
    first = firstD + N;
    REI = instance:addStream("REI", core.Line, name, "REI", instance.parameters.REI_color, first);
    REI:setPrecision(math.max(2, instance.source:getPrecision()));
    REI:addLevel(OS);
    REI:addLevel(0);
    REI:addLevel(OB);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= firstD then
        -- calculate trend
        local c1, c2, c3, c4, trend;

        -- TD1:= (H>=Ref(L,-5) OR H>=Ref(L,-6));
        c1 = (H[period] >= L[period - 5] or H[period] >= L[period - 6]);
        -- TD2:= (Ref(H,-2)>=Ref(C,-7) OR Ref(H,-2)>=Ref(C,-8));
        c2 = (H[period - 2] >= C[period - 7] or H[period - 2] >= C[period - 8]);
        -- TD3:= (L<=Ref(H,-5) OR L<=Ref(H,-6));
        c3 = (L[period] <= H[period - 5] or L[period] <= H[period - 6]);
        -- TD4:= (Ref(L,-2)<=Ref(C,-7) OR Ref(L,-2)<=Ref(C,-8));
        c4 = (L[period - 2] <= C[period - 7] or L[period - 2] <= C[period - 8]);

        -- TD5:= (TD1 OR TD2) AND (TD3 OR TD4);
        -- HighMom:= H - Ref(H,-2);
        -- LowMom:= L - Ref(L,-2);
        -- TD6:= If(TD5,HighMom + LowMom,0);
        -- TD7:= Abs(HighMom) + Abs(LowMom);
        if (c1 or c2) and (c3 or c4) then
            D[period] = (H[period] - H[period - 2]) + (L[period] - L[period - 2]);
        else
            D[period] = 0;
        end
        R[period] = math.abs(H[period] - H[period - 2]) + math.abs(L[period] - L[period - 2]);

        -- TDREI:= 100 * Sum(TD6,Periods) / Sum(TD7,Periods);
        if period >= first then
            local range = core.rangeTo(period, N);
            REI[period] = 100 * core.sum(D, range) / core.sum(R, range);
        end
    end
end

