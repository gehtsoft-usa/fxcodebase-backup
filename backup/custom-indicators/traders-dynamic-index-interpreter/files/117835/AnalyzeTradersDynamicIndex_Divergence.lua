-- Id: 20597
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4133

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- original indicator:
-- Traders Dynamic Index.mq4
-- Copyright � 2006, Dean Malone
-- www.compassfx.com


function Init()
    indicator:name("Analyze of the Traders Dynamic Index Indicator data (diveregence)");
    indicator:description("The indicator interprets the TradersDynamicIndex indicator output and shows ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Traders Dynamic Index Calculation");

    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("L1", "Low Level", "", 32, 0, 100);
    indicator.parameters:addInteger("L2", "Middle Level", "", 50, 0, 100);
    indicator.parameters:addInteger("L3", "High Level", "", 68, 0, 100);

    indicator.parameters:addGroup("Analysis");
    indicator.parameters:addString("T", "Target Price", "", "close");
    indicator.parameters:addStringAlternative("T", "Open", "", "open");
    indicator.parameters:addStringAlternative("T", "High", "", "high");
    indicator.parameters:addStringAlternative("T", "Low", "", "low");
    indicator.parameters:addStringAlternative("T", "Close", "", "close");
    indicator.parameters:addStringAlternative("T", "Median", "", "median");
    indicator.parameters:addStringAlternative("T", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("T", "Weighed", "", "weighted");

    indicator.parameters:addInteger("S", "Strategy", "", 2);
    indicator.parameters:addIntegerAlternative("S", "Scaliping", "", 0);
    indicator.parameters:addIntegerAlternative("S", "Active", "", 1);
    indicator.parameters:addIntegerAlternative("S", "Moderate", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TLC", "Trend Line/Entry Signal Line Color", "", core.rgb(0, 128, 0));
    indicator.parameters:addColor("ELC", "Exit Line/Exit Signal Line Color", "", core.rgb(128, 0, 0));
    indicator.parameters:addColor("VBC", "Volatility Band C/D color", "", core.rgb(0, 0, 128));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

local source;
local iTDI, P, VBU, VBD, MB, TS;
local L1, L2, L3;
local first, first1, first2;
local E, X;         -- enter and exit signals
local OR;           -- out of range
local VB;           -- volatility speed and direction
local Strategy;
local line_id = 0;

function Prepare(onlyName)
    local pTDI = core.indicators:findIndicator("TRADERSDYNAMICINDEX");
    assert(pTDI ~= nil, "Please download and install TradersDynamicIndex.lua indicator");
    DN_color = instance.parameters.DN_color;
    UP_color = instance.parameters.UP_color;

    local sn;
    if instance.parameters.S == 0 then
        sn = "Scalping";
        Strategy = StrategyScalping;
    elseif instance.parameters.S == 1 then
        sn = "Active";
        Strategy = StrategyActive;
    else
        sn = "Moderate";
        Strategy = StrategyModerate;
    end

    local name = profile:id() .. "(" .. instance.source:name() .. "." .. instance.parameters.T  .. "," ..
                                        sn .. "," ..
                                        instance.parameters.RSI_N .. "," ..
                                        instance.parameters.VB_N .. "," .. instance.parameters.VB_W .. "," ..
                                        instance.parameters.RSI_P_N .. "," .. instance.parameters.RSI_P_M .. "," ..
                                        instance.parameters.TS_N .. "," .. instance.parameters.TS_M .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    source = instance.source;

    local p = pTDI:parameters();

    p:setInteger("RSI_N", instance.parameters.RSI_N);
    p:setInteger("VB_N", instance.parameters.VB_N);
    p:setDouble("VB_W", instance.parameters.VB_W);
    p:setInteger("RSI_P_N", instance.parameters.RSI_P_N);
    p:setString("RSI_P_M", instance.parameters.RSI_P_M);
    p:setInteger("TS_N", instance.parameters.TS_N);
    p:setString("TS_M", instance.parameters.TS_M);

    iTDI = pTDI:createInstance(source[instance.parameters.T], p);
    P = iTDI.RSI_P;
    VBU = iTDI.VBU;
    VBD = iTDI.VBD;
    MB = iTDI.MB;
    TS = iTDI.TS;

    L1 = instance.parameters.L1;
    L2 = instance.parameters.L2;
    L3 = instance.parameters.L3;

    first = math.max(P:first(), VBU:first(), VBD:first(), MB:first(), TS:first());
    first1 = first + 1;
    first2 = first + 2;

    E = instance:addStream("E", core.Line, name .. ".E", "Entry", instance.parameters.TLC, first);
    E:setPrecision(math.max(2, instance.source:getPrecision()));
    E:setWidth(2);
    X = instance:addStream("X", core.Line, name .. ".X", "Exit", instance.parameters.ELC, first2);
    X:setPrecision(math.max(2, instance.source:getPrecision()));
    X:setWidth(2);
    VB = instance:addStream("VB", core.Line, name .. ".VB", "VolBand", instance.parameters.VBC, first2);
    VB:setPrecision(math.max(2, instance.source:getPrecision()));
    VB:setStyle(core.LINE_DOT);

    OR = instance:addInternalStream(first, 0);
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
end

local pperiod;

function Update(period, mode)
    iTDI:update(mode);

    -- entry condition and watch for the cross of green and blue lines
    if period >= first then
        -- get entry signals
        E[period] = Strategy(period);

        -- calculate out-of-range
        if P[period] > VBU[period] then
            OR[period] = 1;
        elseif P[period] < VBD[period] then
            OR[period] = -1;
        else
            OR[period] = 0;
        end
    end

    -- exit conditions
    if period >= first2 then
        X[period] = 0;

        if P[period] > TS[period] and ((P[period - 1] < TS[period - 1]) or
                                       ((P[period - 1] == TS[period - 1]) and
                                       (P[period - 2] < TS[period - 2]))) then
            X[period] = -1;
        elseif P[period] < TS[period] and ((P[period - 1] > TS[period - 1]) or
                                           ((P[period - 1] == TS[period - 1]) and
                                           (P[period - 2] > TS[period - 2]))) then
            X[period] = 1;
        else
            if OR[period] == 0 and OR[period - 1] > 0 then
                X[period] = 0.5;
            elseif OR[period] == 0 and OR[period - 1] < 0 then
                X[period] = -0.5;
            end
        end

        -- vol band

        local a0, a1;
        a0 = VBU[period] - VBD[period];
        a1 = VBU[period - 1] - VBD[period - 1];

        if a0 > a1 then
            VB[period] = 1.5;
        elseif a0 < a1 then
            VB[period] = -1.5;
        else
            VB[period] = 0;
        end
    end

    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
    pperiod1 = source:serial(period);

    if period >= first then
        if period >= first + 2 then
            processBullish(period - 2);
            processBearish(period - 2);
        end
    end
end

function StrategyScalping(period)
    if P[period] > TS[period] then
        return 2;
    elseif P[period] < TS[period] then
        return -2;
    else
        return 0;
    end
end

function StrategyActive(period)
    if P[period] > TS[period] and P[period] > MB[period] then
        return 2;
    elseif P[period] < TS[period] and P[period] < MB[period] then
        return -2;
    else
        return 0;
    end
end

function StrategyModerate(period)
    if P[period] > TS[period] and P[period] > MB[period] and P[period] > L2 then
        return 2;
    elseif P[period] < TS[period] and P[period] < MB[period] and P[period] < L2 then
        return -2;
    else
        return 0;
    end
end

function processBullish(period)
    if isTrough(E, period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(E, period);
        if prev ~= nil then
            if E[curr] > E[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, E[curr], "\225", "Classic bullish on entry");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), E[prev], source:date(curr), E[curr], DN_color);
            elseif E[curr] < E[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, E[curr], "\225", "Reversal bullish on entry");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), E[prev], source:date(curr), E[curr], DN_color);
            end
        end
    end
    if isTrough(X, period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(X, period);
        if prev ~= nil then
            if X[curr] > X[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, X[curr], "\225", "Classic bullish on exit");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), X[prev], source:date(curr), X[curr], DN_color);
            elseif X[curr] < X[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, X[curr], "\225", "Reversal bullish on exit");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), X[prev], source:date(curr), X[curr], DN_color);
            end
        end
    end
end

function isTrough(indic_source, period)
    local i;
    if indic_source[period] < indic_source[period - 1] and indic_source[period] < indic_source[period + 1] then
        for i = period - 1, first, -1 do
            if indic_source[i] > indic_source[period] then
                return true;
            elseif indic_source[period] > indic_source[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(indic_source, period)
    local i;
    for i = period - 5, first, -1 do
        if indic_source[i] <= indic_source[i - 1] and indic_source[i] < indic_source[i - 2] and
           indic_source[i] <= indic_source[i + 1] and indic_source[i] < indic_source[i + 2] then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(E, period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(E, period);
        if prev ~= nil then
            if E[curr] < E[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, E[curr], "\226", "Classic bearish on entry");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), E[prev], source:date(curr), E[curr], UP_color);
            elseif E[curr] > E[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, E[curr], "\226", "Reversal bearish on entry");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), E[prev], source:date(curr), E[curr], UP_color);
            end
        end
    end
    if isPeak(X, period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(X, period);
        if prev ~= nil then
            if X[curr] < X[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, X[curr], "\226", "Classic bearish on exit");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), X[prev], source:date(curr), X[curr], UP_color);
            elseif X[curr] > X[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, X[curr], "\226", "Reversal bearish on exit");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), X[prev], source:date(curr), X[curr], UP_color);
            end
        end
    end
end

function isPeak(indic_source, period)
    local i;
    if indic_source[period] > indic_source[period - 1] and indic_source[period] > indic_source[period + 1] then
        for i = period - 1, first, -1 do
            if indic_source[i] < indic_source[period] then
                return true;
            elseif indic_source[period] < indic_source[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(indic_source, period)
    local i;
    for i = period - 5, first, -1 do
        if indic_source[i] >= indic_source[i - 1] and indic_source[i] > indic_source[i - 2] and
           indic_source[i] >= indic_source[i + 1] and indic_source[i] > indic_source[i + 2] then
           return i;
        end
    end
    return nil;
end