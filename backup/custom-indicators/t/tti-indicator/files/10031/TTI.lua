--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- The indicator is nominated as Richard Tao Trailing Signal indicator 
-- This is to signal trend by ma, momentum and deviation 
-- Richard Tao Predictor serials number 3 version 1.1

-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RichardTaoTrailingIndicator");
    indicator:description("Richard Tao Trailing Indicator.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20);
    indicator.parameters:addInteger("M", "Periods for Smooth", "", 2);
    indicator.parameters:addInteger("D", "Distance deviation percentage", "", 100);
    indicator.parameters:addInteger("C", "Coefficient percentage", "", 100);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("ShowTF", "Show T and F", "", false);   
    indicator.parameters:addBoolean("ShowTag", "Show Tag", "", false);   
    indicator.parameters:addColor("clrT", "LineColor of the T", "", core.rgb(0, 64, 128));
    indicator.parameters:addColor("clrF", "LineColor of the F", "", core.rgb(128, 64, 0));
    indicator.parameters:addColor("clrS", "LineColor of the S", "", core.rgb(128, 128, 0));   
end

-- Parameters block
local n;
local m;
local mm;
local B = 2;

local firstPeriod;
local source = nil;
local ShowTag = false;

-- Streams block
local T = nil;
local F = nil;
local S = nil;
local tl = nil;
local bl = nil;
local al = nil;
local tp = nil;

-- Processes indicator parameters and creates output streams
function Prepare()
    n = instance.parameters.N;
    m = instance.parameters.M;
    if m < 4 then mm = 3 else mm = m end
    
    ShowTag = instance.parameters.ShowTag;
    source = instance.source;
    firstPeriod = source:first() + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    
    al = instance:addInternalStream(firstPeriod, 0);
    bl = instance:addInternalStream(firstPeriod, 0);
    tl = instance:addInternalStream(firstPeriod, 0);
    tp = instance:addInternalStream(firstPeriod, 0);
    
    T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.clrT, firstPeriod+m)	
    F = instance:addStream("F", core.Line, name .. ".F", "F", instance.parameters.clrF, T:first())
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.clrS, T:first())	
    if instance.parameters.ShowTF == false then
    T:setStyle(core.LINE_NONE);
    F:setStyle(core.LINE_NONE);
    end 
    if ShowTag then 
    lbl = instance:createTextOutput("TG", "TG", "Arial", 8, core.H_Center, core.V_Center, core.rgb(0, 0, 0), 0);
    end
end

local oSignal = {};
-- Indicator calculation routine
function Update(period)
    if period >= firstPeriod then 
        local p = core.rangeTo(period, n);
        local ma = core.avg(source.close, p);
        local sd = core.stdev(source.close, p);
        
        al[period] = ma;
        bl[period] = ma - B * sd;
        tl[period] = ma + B * sd;
        tp[period] = source.typical[period];
        if period == firstPeriod then
            oSignal = ResetInfo(oSignal); 
            oSignal.prehilo = 0;
        end
        
        if period >= T:first() then
            T[period] = core.avg(tp, core.rangeTo(period, m));
        end
        if period >= T:first()+mm then
            F[period] = GetFastSignal(T, al, F, sd*instance.parameters.D/100, instance.parameters.C/100, period);
            S[period] = GetSlowSignal(T, al, bl, tl, S, sd*instance.parameters.D/100, instance.parameters.C/100, oSignal, period);
        end

    end
end

function GetFastSignal(T, AL, F, dist, coef, period)
    local cent = AL[period];
    local dift = (T[period] - T[period-1]);
    local thet = T[period];
    local pres = cent;
    if F:hasData(period-1) then pres = (F[period-1]) end
    
    local signal = pres;
    local dire = 0;
    
    if (thet-pres)*dift > 0 then
        --move far
        if (thet-cent)*dift>0 and math.abs(thet-cent)-dist>0 
        then dire=0.4 else dire=0.1 end
    else
        --move near
        if (thet-cent)*dift<0 then dire=0.3 end
    end
    --set step follow
    signal = pres + (thet-pres)*dire*(coef);
    
    return signal
end

function ResetInfo(oSignal)
    oSignal.cross = 0;
    oSignal.croslevel = 0;
    oSignal.freeze = 0;
    oSignal.frozlevel = 0;
    return oSignal;
end

function GetSlowSignal(T, AL, BL, TL, S, dist, coef, oSignal, period)
    local cent = AL[period];
    local dift = (T[period] - T[period-1]);
    local difm = (AL[period] - AL[period-1]);
    local difb = (BL[period] - BL[period-1]);
    local difu = (TL[period] - TL[period-1]);
    local tag = "";    
    
    local thet = T[period];
    local pret = T[period-1];
    local pres = cent;
    if S:hasData(period-1) then pres = (S[period-1]) end
    local signal = pres; 

    --1 direction base on oppsite channel line
    if dift<0 then 
        if oSignal.freeze==0 then signal = pres + difm + difu*coef; end
    else
        if oSignal.freeze==0 then signal = pres + difm + difb*coef; end
    end

    --2 boundary correction
    if oSignal.prehilo<=0 and oSignal.frozlevel>0 and (signal-oSignal.frozlevel)+dist<0 then signal=pres; tag=tag .. "B" end 
    if oSignal.prehilo>=0 and oSignal.frozlevel>0 and (signal-oSignal.frozlevel)-dist>0 then signal=pres; tag=tag .. "B" end 

    --3 first cross correction
    if oSignal.prehilo<=0 and oSignal.frozlevel==0 and pret-pres<0 and thet-signal>0 then oSignal.frozlevel=signal; tag=tag .. "X" end 
    if oSignal.prehilo>=0 and oSignal.frozlevel==0 and pret-pres>0 and thet-signal<0 then oSignal.frozlevel=signal; tag=tag .. "X" end 

    --4 unfroze correction
    if oSignal.freeze<0 and (thet-pres)+dist<0 then oSignal.freeze=0; tag=tag .. "U"; end 
    if oSignal.freeze>0 and (thet-pres)-dist>0 then oSignal.freeze=0; tag=tag .. "U"; end 
    if oSignal.freeze<0 and pret-pres<0 and thet-signal>0 then oSignal.freeze=0; tag=tag .. "U"; end 
    if oSignal.freeze>0 and pret-pres>0 and thet-signal<0 then oSignal.freeze=0; tag=tag .. "U"; end 
    
    --5 resume break freeze correction on frontier
    if oSignal.prehilo<=0 and oSignal.frozlevel>0 and pret-pres>0 and thet-signal<0 
    then signal=oSignal.frozlevel; oSignal.frozlevel=0; oSignal.freeze=-1; tag=tag .. "Z"; end 
    if oSignal.prehilo>=0 and oSignal.frozlevel>0 and pret-pres<0 and thet-signal>0 
    then signal=oSignal.frozlevel; oSignal.frozlevel=0; oSignal.freeze=1; tag=tag .. "Z" end 

    --9 frontier correction
    if oSignal.prehilo<=0 and (thet-cent)-dist>0 then signal=thet-dist*2; ResetInfo(oSignal); oSignal.prehilo=1; tag=tag .. "R" end
    if oSignal.prehilo>=0 and (thet-cent)+dist<0 then signal=thet+dist*2; ResetInfo(oSignal); oSignal.prehilo=-1; tag=tag .. "R" end
    
    if ShowTag and tag~="" then 
    lbl:set(period, source.low[period], tag); end

    return signal
end
