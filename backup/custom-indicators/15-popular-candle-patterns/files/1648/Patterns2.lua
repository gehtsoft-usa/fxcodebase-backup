-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=903
-- Id: 571

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

function Init()
    indicator:name("Candle Pattern 2");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("EQ", "Maximum of pips distance between equal prices", "", 1, 0, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FontSize", "Font Size", "", 6, 4, 12);
    indicator.parameters:addColor("LblColor", "Color for pattern labels", "", core.COLOR_LABEL);
end

local source;
local P;
local UP;
local DN;
local EQ;

function Prepare(nameOnly)
    EQ = instance.parameters.EQ * instance.source:pipSize();
    source = instance.source;

    local name;
    name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
    InitPattern(source);

    UP = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.LblColor, 0);
    DN = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.LblColor, 0);
end

local prevSerial = nil;

function Update(period, mode)
    if period == 0 then
        prevSerial = source:serial(period);
    else
        if prevSerial ~= source:serial(period) then
            prevSerial = source:serial(period);
            UpdatePattern(period - 1);
        end
    end
end

function RegisterPattern(period, pattern)
    local short, long, up, length;
    local price;
    short, long, up, length = DecodePattern(pattern);
    if up then
        price = core.max(source.high, core.rangeTo(period, length));
        UP:set(period, price, short, long);
    else
        price = core.min(source.low, core.rangeTo(period, length));
        DN:set(period, price, short, long);
    end
end

local O, H, L, C, T, B, BL, US, LS; -- open, high, low, close prices, top and bottom of the candle, body, upper shadow and lower shadow length

function InitPattern(source)
    O = source.open;
    H = source.high;
    L = source.low;
    C = source.close;
    T = instance:addInternalStream(0, 0);
    B = instance:addInternalStream(0, 0);
    BL = instance:addInternalStream(0, 0);
    US = instance:addInternalStream(0, 0);
    LS = instance:addInternalStream(0, 0);
end

local PAT_NONE = 0;
local PAT_DOUBLE_INSIDE = 1;
local PAT_INSIDE = 2;
local PAT_OUTSIDE = 4;
local PAT_PINUP = 5;
local PAT_PINDOWN = 6;
local PAT_PPRUP = 7;
local PAT_PPRDN = 8;
local PAT_DBLHC = 9;
local PAT_DBHLC = 10;
local PAT_CPRU = 11;
local PAT_CPRD = 12;
local PAT_NB = 13;
local PAT_FBU = 14;
local PAT_FBD = 15;
local PAT_MB = 16;

-- short name, name, up/down flag, length of pattern
function DecodePattern(pattern)
    if pattern == PAT_NONE then
        return nil, nil, nil, nil;
    elseif pattern == PAT_DOUBLE_INSIDE then
        return "DblIn", "Double Inside", true, 3;
    elseif pattern == PAT_INSIDE then
        return "In", "Inside", true, 2;
    elseif pattern == PAT_OUTSIDE then
        return "Out", "Outside", true, 2;
    elseif pattern == PAT_PINUP then
        return "PnUp", "Pin Up", true, 2;
    elseif pattern == PAT_PINDOWN then
        return "PnDn", "Pin Down", false, 2;
    elseif pattern == PAT_PPRUP then
        return "PPRU", "Pivot Point Reversal Up", false, 3;
    elseif pattern == PAT_PPRDN then
        return "PPRD", "Pivot Point Reversal Down", true, 3;
    elseif pattern == PAT_DBLHC then
        return "DBLHC", "Double Bar Low With A Higher Close", false, 2;
    elseif pattern == PAT_DBHLC then
        return "DBHLC", "Double Bar High With A Lower Close", true, 2;
    elseif pattern == PAT_CPRU then
        return "CPRU", "Close Price Reversal Up", false, 3;
    elseif pattern == PAT_CPRD then
        return "CPRD", "Close Price Reversal Down", true, 3;
    elseif pattern == PAT_NB then
        return "NB", "Neutral Bar", true, 1;
    elseif pattern == PAT_FBU then
        return "FBU", "Force Bar Up", false, 1;
    elseif pattern == PAT_FBD then
        return "FBD", "Force Bar Down", true, 1;
    elseif pattern == PAT_MB then
        return "MB", "Mirror Bar", true, 2;
    else
        return nil, nil, nil, nil;
    end
end

function Cmp(price1, price2)
    if math.abs(price1 - price2) < EQ then
        return 0;
    elseif price1 > price2 then
        return 1;
    else
        return -1;
    end
end

function UpdatePattern(p)
    T[p] = math.max(O[p], C[p]);
    B[p] = math.min(O[p], C[p]);
    BL[p] = T[p] - B[p];
    US[p] = H[p] - T[p];
    LS[p] = B[p] - L[p];

    if p >= 0 then
        -- 1 - candle patterns
        if Cmp(O[p], C[p]) == 0 and US[p] > math.max(EQ * 4, source:pipSize() * 4) and
                                    LS[p] > math.max(EQ * 4, source:pipSize() * 4) then
           RegisterPattern(p, PAT_NB);
        end

        if C[p] == H[p] then
           RegisterPattern(p, PAT_FBU);
        end

        if C[p] == L[p] then
           RegisterPattern(p, PAT_FBD);
        end
    end
    if p >= 1 then
        -- 2 - candle patterns
       if Cmp(H[p], H[p - 1]) < 0 and Cmp(L[p], L[p - 1]) > 0 then
           RegisterPattern(p, PAT_INSIDE);
       end
       if Cmp(H[p], H[p - 1]) > 0 and Cmp(L[p], L[p - 1]) < 0 then
           RegisterPattern(p, PAT_OUTSIDE);
       end
       if Cmp(H[p], H[p - 1]) == 0 and Cmp(C[p], C[p - 1]) < 0 and Cmp(L[p], L[p - 1]) <= 0 then
           RegisterPattern(p, PAT_DBHLC);
       end
       if Cmp(L[p], L[p - 1]) == 0 and Cmp(C[p], C[p - 1]) > 0 and Cmp(H[p], H[p - 1]) >= 0  then
           RegisterPattern(p, PAT_DBLHC);
       end
       if Cmp(BL[p - 1], BL[p]) == 0 and Cmp(O[p - 1], C[p]) == 0 then
           RegisterPattern(p, PAT_MB);
       end
    end

    if p >= 2 then
        -- 3 - candle patterns
        if Cmp(H[p], H[p - 1]) < 0 and Cmp(L[p], L[p - 1]) > 0 and
           Cmp(H[p - 1], H[p - 2]) < 0 and Cmp(L[p - 1], L[p - 2]) > 0 then
            RegisterPattern(p, PAT_DOUBLE_INSIDE);
        end
        if Cmp(H[p - 1], H[p - 2]) > 0 and Cmp(H[p - 1], H[p]) > 0 and
           Cmp(L[p - 1], L[p - 2]) > 0 and Cmp(L[p - 1], L[p]) > 0 and
           BL[p - 1] * 2 < US[p - 1] then
            RegisterPattern(p - 1, PAT_PINUP);
        end
        if Cmp(H[p - 1], H[p - 2]) < 0 and Cmp(H[p - 1], H[p]) < 0 and
           Cmp(L[p - 1], L[p - 2]) < 0 and Cmp(L[p - 1], L[p]) < 0 and
           BL[p - 1] * 2 < LS[p - 1] then
            RegisterPattern(p - 1, PAT_PINDOWN);
        end
        if Cmp(H[p - 1], H[p - 2]) > 0 and Cmp(H[p - 1], H[p]) > 0 and
           Cmp(L[p - 1], L[p - 2]) > 0 and Cmp(L[p - 1], L[p]) > 0 and
           Cmp(C[p], L[p - 1]) < 0 then
            RegisterPattern(p, PAT_PPRDN);
        end
        if Cmp(H[p - 1], H[p - 2]) < 0 and Cmp(H[p - 1], H[p]) < 0 and
           Cmp(L[p - 1], L[p - 2]) < 0 and Cmp(L[p - 1], L[p]) < 0 and
           Cmp(C[p], H[p - 1]) > 0 then
            RegisterPattern(p, PAT_PPRUP);
        end
        if Cmp(H[p - 1], H[p - 2]) < 0 and Cmp(L[p - 1], L[p - 2]) < 0 and
           Cmp(H[p], H[p - 1]) < 0 and Cmp(L[p], L[p - 1]) < 0 and
           Cmp(C[p], C[p - 1]) > 0 and Cmp(O[p], C[p]) < 0 then
            RegisterPattern(p, PAT_CPRU);
        end
        if Cmp(H[p - 1], H[p - 2]) > 0 and Cmp(L[p - 1], L[p - 2]) > 0 and
           Cmp(H[p], H[p - 1]) > 0 and Cmp(L[p], L[p - 1]) > 0 and
           Cmp(C[p], C[p - 1]) < 0 and Cmp(O[p], C[p]) > 0 then
            RegisterPattern(p, PAT_CPRD);
        end
    end
end
