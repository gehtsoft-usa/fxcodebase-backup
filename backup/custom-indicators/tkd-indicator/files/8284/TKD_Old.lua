-- Id: 15863

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=3477

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
 

-- The indicator is Richard Tao Adaptive Stochastic KD with Trailing Signal  
-- Richard Tao Predictor serials number 2

-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RichardTaoKDStochastic");
    indicator:description("Richard Tao Adaptive Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods for %K", "", 30, 2, 1000);
    indicator.parameters:addInteger("M", "Periods for Smooth", "", 5);
    indicator.parameters:addInteger("D", "Distance percentage", "", 100);
    indicator.parameters:addInteger("C", "Coefficient percentage", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrT", "LineColor of the T", "", core.rgb(0, 64, 128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrM", "LineColor of the M", "", core.rgb(128, 64, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrS", "LineColor of the S", "", core.rgb(0, 128, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Parameters block
local fk;
local mk;
local md;

local source = nil;
local smin = nil;
local smax = nil;
local FastK = nil;
local fFirst = nil;

-- Streams block
local T = nil;
local M = nil;
local S = nil;

-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    fk = instance.parameters.N;
    mk = instance.parameters.M;
    if mk < 4 then md = 3 else md = mk end
    source = instance.source;

    smin = instance:addInternalStream(source:first() + fk - 1, 0);
    smax = instance:addInternalStream(source:first() + fk - 1, 0);
    FastK = instance:addInternalStream(smin:first(), 0);
    fFirst = FastK:first();
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. fk .. ", " .. mk .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.clrT, fFirst + mk);
    T:setPrecision(math.max(2, instance.source:getPrecision()));
	T:setWidth(instance.parameters.width1);
    T:setStyle(instance.parameters.style1);
	
    M = instance:addStream("M", core.Line, name .. ".M", "M", instance.parameters.clrM, T:first() + md);
    M:setPrecision(math.max(2, instance.source:getPrecision()));
	M:setWidth(instance.parameters.width2);
    M:setStyle(instance.parameters.style2);
	
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.clrS, T:first());
    S:setPrecision(math.max(2, instance.source:getPrecision()));
	S:setWidth(instance.parameters.width3);
    S:setStyle(instance.parameters.style3);
	
    T:addLevel(50+instance.parameters.D/100*25);
    T:addLevel(50-instance.parameters.D/100*25);

end

local prehilo = 0;
-- Indicator calculation routine
function Update(period, mode)
    if period >= fFirst then
        local rangeT = core.rangeTo(period, fk);
        local minLow = core.min(source.low, rangeT);
        local maxHigh = core.max(source.high, rangeT);
        smin[period] = source.close[period] - minLow;
        smax[period] = maxHigh - minLow;
        if smax[period] > 0 then
            FastK[period] = smin[period] / smax[period] * 100;
        else
            FastK[period] = 50;
        end
    end
    if period >= T:first() then
        local rangeT = core.rangeTo(period, mk);
        local sumMax = core.sum(smax, rangeT);
        if sumMax == 0 then
            T[period] = 50;
        else
            local sumMin = core.sum(smin, rangeT);
            T[period] = sumMin / sumMax * 100;
        end
    end
    if period >= M:first() then
        M[period] = core.avg(T, core.rangeTo(period, md));
        
        S[period] = GetSignal(T, M, S, instance.parameters.D/100*25, instance.parameters.C/100, period);
    end
end

function GetSignal(T, M, S, dist, coef, period)
    local dift = (T[period] - T[period-1]);
    local thet = T[period];
    local cent = 50;
    local pres;
    if S:hasData(period-1) then
        pres = (S[period-1]);
    else
    --initial value
        pres = cent;
    end
    
    local signal = pres;
    local dire;
    
    if math.abs(thet-cent)-dist > 0 then
        if prehilo<=0 and (thet-cent)-dist>0 then prehilo=1 end
        if prehilo>=0 and (thet-cent)+dist<0 then prehilo=-1 end
        --frontier correction
        dire = 0;
        if dift<0 and (thet-cent)-dist>0 then dire=-1 end
        if dift>0 and (thet-cent)+dist<0 then dire=-1 end
    else
        --middle tier correction
        dire = -1;
        --follow up correction
        if dift<0 and (thet-pres)+dist<0 then dire=0.5 end
        if dift>0 and (thet-pres)-dist>0 then dire=0.5 end
    end
    --oppsite direction
    signal = pres + dift*dire*(coef);
    
    --resume break correction
    if prehilo<=0 and (thet-cent)<0 and thet-pres<0 and dift-(thet-pres)<0 then signal=cent+dist end 
    if prehilo>=0 and (thet-cent)>0 and thet-pres>0 and dift-(thet-pres)>0 then signal=cent-dist end 

    return signal
end

