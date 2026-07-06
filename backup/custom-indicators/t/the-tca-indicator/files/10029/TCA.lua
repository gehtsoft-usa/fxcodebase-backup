-- Id: 3730
-- The indicator is Richard Tao Adaptive Commodity Channel with Trailing Signal 
-- Richard Tao Predictor serials number 1 version 1.1

-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RichardTaoCCIAnalysis");
    indicator:description("Richard Tao Adaptive Commodity Channel.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 50, 2, 1000);
    indicator.parameters:addInteger("M", "Periods for Smooth", "", 5);
    indicator.parameters:addInteger("D", "Distance from center", "", 100);
    indicator.parameters:addInteger("C", "Coefficient percentage", "", 100);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrT", "LineColor of the T", "", core.rgb(0, 64, 128));
	indicator.parameters:addInteger("widthT", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrF", "LineColor of the F", "", core.rgb(128, 64, 0));
	indicator.parameters:addInteger("widthF", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleF", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleF", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrS", "LineColor of the S", "", core.rgb(0, 128, 0));
	indicator.parameters:addInteger("widthS", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS", core.FLAG_LINE_STYLE);
end

-- Parameters block
local n;
local m;
local mm;
local d;

local source = nil;
local tp = nil;
local matp = nil;
local tpFirst = nil;
local matpFirst = nil;
local cciFirst = nil;

-- Streams block
local T = nil;
local M = nil;
local F = nil;
local S = nil;

-- Processes indicator parameters and creates output streams
function Prepare()
    n = instance.parameters.N;
    m = instance.parameters.M;
    if m < 4 then mm = 3 else mm = m end
    d = instance.parameters.D;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. m .. ")";
    instance:name(name);
    
    tp = instance:addInternalStream(source:first(), 0);
    tpFirst = tp:first();
    matp = instance:addInternalStream(tp:first() + n - 1, 0);
    matpFirst = matp:first();
    fcci = instance:addInternalStream(matp:first(), 0);
    cciFirst = fcci:first();
    
    T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.clrT, cciFirst+m);
    T:setPrecision(math.max(2, instance.source:getPrecision()));
	T:setWidth(instance.parameters.widthT);
    T:setStyle(instance.parameters.styleT);
    F = instance:addStream("F", core.Line, name .. ".F", "F", instance.parameters.clrF, T:first())
    F:setPrecision(math.max(2, instance.source:getPrecision()));
	F:setWidth(instance.parameters.widthF);
    F:setStyle(instance.parameters.styleF);
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.clrS, T:first());
    S:setPrecision(math.max(2, instance.source:getPrecision()));
	S:setWidth(instance.parameters.widthS);
    S:setStyle(instance.parameters.styleS);
    M = instance:addInternalStream(T:first()+mm, 0);

    T:addLevel(0-d);
    T:addLevel(0);
    T:addLevel(d);
end

local prehilo = 0;
-- Indicator calculation routine
function Update(period)
    if period >= tpFirst then
        tp[period] = (source.high[period] + source.low[period] + source.close[period]) / 3;
    end
    if period >= matpFirst then
        local range = core.rangeFrom(period - n + 1, n);
        matp[period] = core.avg(tp, range);
        local matpPeriod = matp[period];
        local summ = 0;
        for i = period - n + 1, period do
            summ = summ + math.abs(matpPeriod - tp[i]);
        end
        if (summ == 0) then
            fcci[period] = 0;
        else
            fcci[period] = (tp[period] - matpPeriod) / (summ * 0.015 / n);
        end
    end
    if period >= T:first() then
        T[period] = core.avg(fcci, core.rangeTo(period, m));
    end
    if period >= M:first() then
        M[period] = core.avg(T, core.rangeTo(period, mm));
        
        F[period] = GetFastSignal(T, F, instance.parameters.D, instance.parameters.C/100, period);
        S[period] = GetSlowSignal(T, F, S, n, instance.parameters.D, instance.parameters.C/100, period);
    end
end

function GetFastSignal(T, F, dist, coef, period)
    local cent = 0;
    local dift = (T[period] - T[period-1]);
    local thet = T[period];
    local pres = cent;
    if F:hasData(period-1) then pres = (F[period-1]) end
    
    local signal = pres;
    local dire = 0;
    
    if (thet-pres)*dift > 0 then
        --move far
        if (thet-cent)*dift>0 and math.abs(thet-cent)-dist>0 
        then dire=0.5 else dire=0.1 end
    else
        --move near
        if (thet-cent)*dift<0 then dire=0.5 end
    end
    --set step follow
    signal = pres + (thet-pres)*dire*(coef);
    
    return signal
end

function GetSlowSignal(T, F, S, N, dist, coef, period)
    local cent = 0;
    local thet = T[period];
    local pret = T[period-1];
    local thef = F[period];
    local pref = F[period];
    local pres = cent;
    if S:hasData(period-1) then
        pres = (S[period-1]);
        pref = F[period-1];
    end
    
    local signal = pres;
    local dire = 0;
    
    if math.abs(thet-cent)-dist > 0 then
        if prehilo<=0 and (thet-cent)-dist>0 then prehilo=1 end
        if prehilo>=0 and (thet-cent)+dist<0 then prehilo=-1 end
    end
        
    if math.abs(thet-cent)-dist > 0 then
        --frontier correction
        dire = 0;
        if (thet-pret)<0 and (thet-cent)-dist>0 then dire=-1 end
        if (thet-pret)>0 and (thet-cent)+dist<0 then dire=-1 end
        if (thet-pret)<0 and (thet-cent)+dist*2<0 then dire=-2 end
        if (thet-pret)>0 and (thet-cent)-dist*2>0 then dire=-2 end
    else
        --middle tier correction
        dire = -0.5;
        --follow up correction
        if (thet-pret)<0 and (thet-pres)+dist<0 then dire=1 end
        if (thet-pret)>0 and (thet-pres)-dist>0 then dire=1 end
        --avoid entangled correction
        if (thet-pret)*(thef-pref)<0 and (thet-pres)*(thet-pret)<0 then dire=1 end
    end
    --set step move
    signal = pres + (thet-pret)*dire*(coef);
    
    --crossesunder correction
    if (thet-signal)<=0 and pret-pres>=0 and (thet-cent)+dist>0 then signal=cent+dist end 
    if (thet-signal)<=0 and pret-pres>=0 and (thet-cent)+dist<0 then signal=cent end 
    --crossesover correction
    if (thet-signal)>=0 and pret-pres<=0 and (thet-cent)-dist<0 then signal=cent-dist end 
    if (thet-signal)>=0 and pret-pres<=0 and (thet-cent)-dist>0 then signal=cent end 
     
    return signal
end




