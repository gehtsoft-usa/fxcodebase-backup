-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=511
-- Id: 2807

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Average Directional Movement Index (VTTrader version)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("SM1", "Smoothing periods 1", "", 14, 1, 100);
    indicator.parameters:addInteger("SM2", "Smoothing periods 2", "", 14, 1, 100);
	indicator.parameters:addDouble("Level", "Level", "Level", 20, 1, 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ADX_color", "Color of ADX", "Color of ADX", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SM1;
local SM2;

local first;
local firstTR;
local firstDI;
local source = nil;

-- Streams block
local TR = nil;
local TR_W = nil;
local PlusDM = nil;
local PlusDM_W = nil;
local PlusDI = nil;
local MinusDM = nil;
local MinusDM_W = nil;
local MinusDI = nil;
local R = nil;
local R_W = nil;
local ADX = nil;
local H, L, C;
local Level;

-- Routine
function Prepare(nameOnly)
    Level = instance.parameters.Level;
    SM1 = instance.parameters.SM1;
    SM2 = instance.parameters.SM2;
    source = instance.source;
    firstTR = source:first() + 1;
    H = source.high;
    L = source.low;
    C = source.close;

    local name = profile:id() .. "(" .. source:name() .. ", " .. SM1 .. ", " .. SM2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TR = instance:addInternalStream(firstTR, 0);
    PlusDM = instance:addInternalStream(firstTR, 0);
    MinusDM = instance:addInternalStream(firstTR, 0);
	
    TR_W = core.indicators:create("WMA", TR, SM1);
    PlusDM_W = core.indicators:create("WMA", PlusDM, SM1);
    MinusDM_W = core.indicators:create("WMA", MinusDM, SM1);

    firstDI = TR_W.DATA:first();

    PlusDI = instance:addInternalStream(firstDI, 0);
    MinusDI = instance:addInternalStream(firstDI, 0);
    R = instance:addInternalStream(firstDI, 0);

    R_W = core.indicators:create("WMA", R, SM2);

    first = R_W.DATA:first();
    ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.ADX_color, first);
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
    ADX:addLevel(Level);
	ADX:setWidth(instance.parameters.width);
    ADX:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(p, mode)
    if p >= firstTR then
        local th, tl;

        if C[p - 1] > H[p] then
            th = C[p - 1];
        else
            th = H[p];
        end

        if C[p - 1] < L[p] then
            tl = C[p - 1];
        else
            tl = L[p];
        end

        TR[p] = th - tl;

        if H[p] > H[p - 1] and L[p] >= L[p - 1] then
            PlusDM[p] = H[p] - H[p - 1];
        elseif  H[p] > H[p - 1] and L[p] < L[p - 1] and ((H[p] - H[p - 1]) > (L[p - 1] - L[p])) then
            PlusDM[p] = H[p] - H[p - 1];
        else
            PlusDM[p] = 0;
        end
        if L[p] < L[p - 1] and H[p] <= H[p - 1] then
            MinusDM[p] = L[p - 1] - L[p];
        elseif  L[p] < L[p - 1] and H[p] > H[p - 1] and ((H[p] - H[p - 1]) < (L[p - 1] - L[p])) then
            MinusDM[p] = L[p - 1] - L[p];
        else
            MinusDM[p] = 0;
        end
    end

    TR_W:update(mode);
    PlusDM_W:update(mode);
    MinusDM_W:update(mode);

    if p >= firstDI then
        PlusDI[p] = 100 * PlusDM_W.DATA[p] / TR_W.DATA[p]
        MinusDI[p] = 100 * MinusDM_W.DATA[p] / TR_W.DATA[p]

        local diff, sum;

        diff = math.abs(PlusDI[p] - MinusDI[p]);
        summ = PlusDI[p] + MinusDI[p];
        R[p] = diff / summ;
    end

    R_W:update(mode);

    if p >= first then
        ADX[p] = 100 * R_W.DATA[p];		
	
    end
end

