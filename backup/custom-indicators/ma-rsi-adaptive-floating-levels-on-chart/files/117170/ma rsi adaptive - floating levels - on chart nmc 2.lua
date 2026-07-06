-- Id: 20405
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65656

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MA RSI Adaptice");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RsiPeriod", "RSI period", "", 14);
    indicator.parameters:addInteger("MinMaxPeriod", "Min/Max period", "", 100);
    indicator.parameters:addDouble("LevelUp", "Level Up", "", 76.4);
    indicator.parameters:addDouble("LevelDown", "Level Down", "", 23.6);
    indicator.parameters:addString("RsiMethod", "RSI Method", "", "rsi_rsi");
    indicator.parameters:addStringAlternative("RsiMethod", "Classical RSI", "", "rsi_rsi");
    indicator.parameters:addStringAlternative("RsiMethod", "Slow RSI", "", "rsi_slw");
    indicator.parameters:addStringAlternative("RsiMethod", "RSX", "", "rsi_rsx");
    indicator.parameters:addStringAlternative("RsiMethod", "Cuttler RSi", "", "rsi_cut");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("rsi_color", "RSI Color", "", core.colors().DeepSkyBlue);
    indicator.parameters:addInteger("rsi_width", "RSI Width", "", 2, 1, 5);
    indicator.parameters:addInteger("rsi_style", "RSI Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("rsi_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("rsi_up_color", "RSI UP Color", "", core.colors().DeepSkyBlue);
    indicator.parameters:addInteger("rsi_up_width", "RSI UP Width", "", 1, 1, 5);
    indicator.parameters:addInteger("rsi_up_style", "RSI UP Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("rsi_up_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("rsi_mi_color", "RSI MI Color", "", core.colors().DimGray);
    indicator.parameters:addInteger("rsi_mi_width", "RSI MI Width", "", 1, 1, 5);
    indicator.parameters:addInteger("rsi_mi_style", "RSI MI Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("rsi_mi_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("rsi_dn_color", "RSI DN Color", "", core.colors().PaleVioletRed);
    indicator.parameters:addInteger("rsi_dn_width", "RSI DN Width", "", 1, 1, 5);
    indicator.parameters:addInteger("rsi_dn_style", "RSI DN Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("rsi_dn_style", core.FLAG_LINE_STYLE);
end

local rsiMin;
local rsiMax;
local rsiLUp;
local rsiLMi;
local rsiLDn;
local rsi;
local rsiDa;
local rsiDb;
local slope;
local gap;
local RsiPeriod;
local MinMaxPeriod;
local LevelUp;
local LevelDown;
local RsiMethod;
local first;
local smma1;
local smma2;
local workRsi;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    RsiPeriod = instance.parameters.RsiPeriod;
    MinMaxPeriod = instance.parameters.MinMaxPeriod;
    LevelUp = instance.parameters.LevelUp;
    LevelDown = instance.parameters.LevelDown;
    RsiMethod = instance.parameters.RsiMethod;

    local name = string.format("MA %s adaptive(%d,%f,%f)", RsiMethod, RsiPeriod, LevelDown, LevelUp);
    instance:name(name);
    if nameOnly then
        return;
    end

    first = source:first() + RsiPeriod;

    rsi = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.rsi_color, first);
    rsi:setWidth(instance.parameters.rsi_width);
    rsi:setStyle(instance.parameters.rsi_style);

    rsiLDn = instance:addStream("RSI_DN", core.Line, name .. ".RSI_DN", "RSI_DN", instance.parameters.rsi_dn_color, first);
    rsiLDn:setWidth(instance.parameters.rsi_dn_width);
    rsiLDn:setStyle(instance.parameters.rsi_dn_style);
    rsiLMi = instance:addStream("RSI_MI", core.Line, name .. ".RSI_MI", "RSI_MI", instance.parameters.rsi_mi_color, first);
    rsiLMi:setWidth(instance.parameters.rsi_mi_width);
    rsiLMi:setStyle(instance.parameters.rsi_mi_style);
    rsiLUp = instance:addStream("RSI_UP", core.Line, name .. ".RSI_UP", "RSI_UP", instance.parameters.rsi_up_color, first);
    rsiLUp:setWidth(instance.parameters.rsi_up_width);
    rsiLUp:setStyle(instance.parameters.rsi_up_style);

    slope = instance:addInternalStream(0, 0);
    gap = instance:addInternalStream(0, 0);
    smma1 = instance:addInternalStream(0, 0);
    smma2 = instance:addInternalStream(0, 0);
    rsiDa = instance:addInternalStream(0, 0);
    rsiDb = instance:addInternalStream(0, 0);
    workRsi = {};
    workRsi[0] = instance:addInternalStream(0, 0);
    workRsi[1] = instance:addInternalStream(0, 0);
    workRsi[2] = instance:addInternalStream(0, 0);
    workRsi[3] = instance:addInternalStream(0, 0);
    workRsi[4] = instance:addInternalStream(0, 0);
    workRsi[5] = instance:addInternalStream(0, 0);
    workRsi[6] = instance:addInternalStream(0, 0);
    workRsi[7] = instance:addInternalStream(0, 0);
    workRsi[8] = instance:addInternalStream(0, 0);
    workRsi[9] = instance:addInternalStream(0, 0);
    workRsi[10] = instance:addInternalStream(0, 0);
    workRsi[11] = instance:addInternalStream(0, 0);
    workRsi[12] = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    if period < first then
        return;
    end
    if (slope[period] == 1) then
        CleanPoint(period, rsiDa, rsiDb);
    end
    local price = source.close[period];
    if period == first then
        rsi[period] = price;
    else
        local value = iRsi(price, RsiPeriod, period);
        rsi[period] = rsi[period - 1] + (2.0 * math.abs(value / 100.0 - 0.5)) * (price - rsi[period - 1]);
    end
    if period > 0 then
        slope[period] = slope[period - 1];
        if (rsi[period] > rsi[period - 1]) then
            slope[period] = 1;
        end
        if (rsi[period] < rsi[period - 1]) then
            slope[period] = -1;
        end
        if (slope[period] == -1) then
            PlotPoint(period, rsiDa, rsiDb, rsi);
        end
        gap[period] = 0;
        if (source.high[period] < source.low[period - 1]) then
            gap[period] = source.high[period] - source.low[period - 1];
        end
        if (source.low[period] > source.high[period - 1]) then
            gap[period] = source.low[period] - source.high[period - 1];
        end
        local displaceup = 0;
        local displacedn = 0;
        local max = rsi[period];
        local min = rsi[period];
        for k = math.max(0, period - MinMaxPeriod), period do
            if (gap[k] < 0) then
                displacedn = displacedn + gap[k];
            end
            if (gap[k] > 0) then
                displaceup = displaceup + gap[k];
            end
            if ((rsi[k] + displaceup) < min) then
                min = rsi[k] + displacedn;
            end
            if ((rsi[k] + displacedn) > max) then
                max = rsi[k] + displacedn;
            end
        end
        rsiMin = min;
        rsiMax = max;
    end
    local range = rsiMax - rsiMin;
    rsiLDn[period] = rsiMin + range * LevelDown / 100.0;
    rsiLMi[period] = rsiMin + range * 0.5;
    rsiLUp[period] = rsiMin + range * LevelUp / 100.0;
end

function iRsi(price, period, i)
    local r = i;
    workRsi[0][r] = price;
    if RsiMethod == "rsi_rsi" then
        local alpha = 1.0 / period; 
        if r < period then
            local sum = 0;
            for k = 0, period do
                sum = sum + math.abs(workRsi[0][r - k] - workRsi[0][r - k - 1]);
                workRsi[1][r] = (workRsi[0][r] - workRsi[0][0]) / math.max(k, 1);
                workRsi[2][r] = sum / math.max(k, 1);
            end
        else
            local change = workRsi[0][r] - workRsi[0][r - 1];
            workRsi[1][r] = workRsi[1][r - 1] + alpha * (change - workRsi[1][r - 1]);
            workRsi[2][r] = workRsi[2][r - 1] + alpha * (math.abs(change) - workRsi[2][r - 1]);
        end
        if workRsi[2]:hasData(r) then
            return 50.0 * (workRsi[1][r] / workRsi[2][r] + 1);
        end
    elseif RsiMethod == "rsi_slw" then
        workRsi[1][r] = iSmma(0.5*(math.abs(workRsi[0][r]-workRsi[0][r - 1])+(workRsi[0][r]-workRsi[0][r - 1])), 0.5*(period-1), i, smma1);
        workRsi[2][r] = iSmma(0.5*(math.abs(workRsi[0][r]-workRsi[0][r - 1])-(workRsi[0][r]-workRsi[0][r - 1])), 0.5*(period-1), i, smma2);
        if ((workRsi[1][r] + workRsi[2][r]) ~= 0) then
            return 100.0 * workRsi[1][r] / (workRsi[1][r] + workRsi[2][r]);
        end
    elseif RsiMethod == "rsi_rsx" then
        local Kg = (3.0) / (2.0 + period);
        local Hg = 1.0 - Kg;
        if (r < period) then
            for k = 1, 12 do
                workRsi[k][r] = nil;
            end
            return(50);
        end
        local mom = workRsi[0][r] - workRsi[0][r - 1]
        local moa = math.abs(mom);
        for k = 0, 2 do
            local kk = k * 2;
            workRsi[kk+1][r] = Kg * mom + Hg*workRsi[kk+1][r-1];
            workRsi[kk+2][r] = Kg * workRsi[kk+1][r] + Hg*workRsi[kk+2][r-1];
            mom = 1.5*workRsi[kk+1][r] - 0.5 * workRsi[kk+2][r];
            workRsi[kk+7][r] = Kg * moa + Hg*workRsi[kk+7][r-1];
            workRsi[kk+8][r] = Kg * workRsi[kk+7][r] + Hg*workRsi[kk+8][r-1];
            moa = 1.5*workRsi[kk+7][r] - 0.5 * workRsi[kk+8][r];
        end
        if (moa ~= 0) then
            return(math.max(math.min((mom/moa+1.0)*50.0,100.00),0.00)); 
        end
    elseif RsiMethod == "rsi_cut" then
        local sump = 0;
        local sumn = 0;
        for k = 0, period - 1 do
            local diff = workRsi[0][r - k] - workRsi[0][r - k - 1];
            if (diff > 0) then
                sump = sump + diff;
            end
            if (diff < 0) then
                sumn = sumn - diff;
            end
        end
        if (sumn > 0) then
            return(100.0-100.0/(1.0+sump/sumn));
        end
    end
    return 50;
end

function iSmma(price, period, r, smma)
    if (r < period) then
        smma[r] = price;
    else
        smma[r] = smma[r - 1] + (price - smma[r - 1]) / period;
    end
    return (smma[r]);
end

function CleanPoint(i, first, second)
    if (i < 3) then
        return;
    end
    if second:hasData(i) and second:hasData(i - 1) then
        second[i - 1] = nil;
    else
        if (first:hasData(i) and first:hasData(i - 1) and not first:hasData(i - 2)) then
            first[i - 1] = nil;
        end
    end
end

function PlotPoint(i, first, second, from)
    if (i < 2) then
        return;
    end
    if not first:hasData(i - 1) then
        if not first:hasData(i - 2) then
            first[i] = from[i];
            first[i - 1] = from[i - 1];
            second[i] = nil;
        else
            second[i] = from[i];
            second[i - 1] = from[i - 1];
            first[i] = nil;
        end
    else
        first[i] = from[i];
        second[i] = nil;
    end
end