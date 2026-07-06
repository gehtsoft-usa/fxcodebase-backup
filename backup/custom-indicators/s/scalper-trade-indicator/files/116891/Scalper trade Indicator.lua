-- Id: 20299
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65610

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
    indicator:name("Scalper trade");
    indicator:description("Scalper trade");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("Calculation");
	  indicator.parameters:addInteger("Period", "Period","",20);
	 indicator.parameters:addInteger("k", "k","",48);
	 indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("Line1", "1. Line Color","", core.rgb(0,255,0));
	indicator.parameters:addColor("Line2", "2. Line Color","", core.rgb(255,0,0));
	indicator.parameters:addColor("Line3", "3. Line Color","", core.rgb(0,0,255));
	
 
end

local average = nil;
local dpo_high = nil;
local dpo_low = nil;
local dpo_close = nil;
local averagetruerange = nil;
local moyh;
local moyl;
local moyc;
local clot;
local hi;
local lo;
local k ,Period;
local n;
local p;

local l;
local h;
local mb;

local Line1,Line2,Line3;
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Line1= instance.parameters.Line1;
	Line2= instance.parameters.Line2;
	Line3= instance.parameters.Line3;
	k= instance.parameters.k;
	Period= instance.parameters.Period;

    n = (k * 2) - 4;
    p = (n / 2) - 1;

    assert(core.indicators:findIndicator("MVA") ~= nil, "Please, download and install MVA indicator");
    assert(core.indicators:findIndicator("DETRENDED PRICE OSCILLATOR") ~= nil, "Please, download and install DETRENDED PRICE OSCILLATOR indicator");
    assert(core.indicators:findIndicator("ATR") ~= nil, "Please, download and install ATR indicator");
    average = core.indicators:create("MVA", source.typical, Period);
    dpo_high = core.indicators:create("DETRENDED PRICE OSCILLATOR", source.high, n);
    dpo_low = core.indicators:create("DETRENDED PRICE OSCILLATOR", source.low);
    dpo_close = core.indicators:create("DETRENDED PRICE OSCILLATOR", source.close);
    averagetruerange = core.indicators:create("ATR", source, Period);

    moyh = instance:addInternalStream(0, 0);
    moyl = instance:addInternalStream(0, 0);
    moyc = instance:addInternalStream(0, 0);
    hi = instance:addInternalStream(0, 0);
    lo = instance:addInternalStream(0, 0);
    clot = instance:addInternalStream(0, 0);

    bari = instance:addInternalStream(0, 0);
    bar = instance:addInternalStream(0, 0);
    targeth = instance:addInternalStream(0, 0);
    targetl = instance:addInternalStream(0, 0);
    target1 = instance:addInternalStream(0, 0);
    target2 = instance:addInternalStream(0, 0);
    rr = instance:addInternalStream(0, 0);

    l = instance:addStream("L", core.Line, name .. ".L", "L", Line1, 0);
    l:setPrecision(math.max(2, instance.source:getPrecision()));
    h = instance:addStream("H", core.Line, name .. ".H", "H", Line2, 0);
    h:setPrecision(math.max(2, instance.source:getPrecision()));
    mb = instance:addStream("MB", core.Line, name .. ".MB", "MB", Line3, 0);
    mb:setPrecision(math.max(2, instance.source:getPrecision()));
end
    
function Update(period, mode)
    average:update(core.UpdateLast);
    dpo_high:update(core.UpdateLast);
    dpo_low:update(core.UpdateLast);
    dpo_close:update(core.UpdateLast);
    averagetruerange:update(core.UpdateLast);

    bari[period] = bari[period - 1];
    bar[period] = bar[period - 1];
    targeth[period] = targeth[period - 1];
    targetl[period] = targetl[period - 1];
    target1[period] = target1[period - 1];
    target2[period] = target2[period - 1];
    rr[period] = rr[period - 1];
    mb[period] = average.DATA[period];
    moyh[period] = source.high[period] - dpo_high.DATA[period];
    moyl[period] = source.low[period] - dpo_low.DATA[period];
    moyc[period] = source.close[period] - dpo_close.DATA[period];
    
    if period < math.max(46, p) then
        return;
    end
    hi[period] = math.floor(((moyh[period] - moyh[period - 1] + (source.high[period - p]) / n) * n) * 100) / 100;
    lo[period] = math.floor(((moyl[period] - moyl[period - 1] + (source.low[period - p]) / n) * n) * 100) / 100;
    clot[period] = math.floor(((moyc[period] - moyc[period - 1] + (source.close[period - p]) / n) * n) * 100) / 100;

    local cond1 = (source.high[period] > source.high[period - 1] and source.high[period] > source.high[period - 2]
        and source.high[period] > hi[period - 46]) and (period > bari[period] or rr[period] == -1);
    h[period] = h[period - 1];
    l[period] = l[period - 1];
    if cond1 then
        targeth[period] = source.high[period];
        targetl[period] = lo[period - 46];
    else
        h[period] = mb[period];
    end
    if targeth[period] == 0.0 or period < 45 then
        return;
    end
    for zz=0, 45 do
        if clot[period - 45 + zz] < targetl[period] and hi[period - 45 + zz] <= targeth[period] and cond1 then
            h[period] = source.high[period] + (averagetruerange.DATA[period]) * 0.5;
            rr[period] = 1;
            bari[period] = period + zz + 2;
            break;
        elseif hi[period - 45 + zz] > targeth[period] then
            h[period] = mb[period];
            break;
        end
    end
    local condi = (source.low[period] < source.low[period - 1] and source.low[period] < source.low[period - 2]) and source.low[period] < lo[period - 46] and (period > bar[period] or rr[period] == 1);
    if condi then
        target1[period] = source.low[period];
        target2[period] = hi[period - 46];
    else
        l[period] = mb[period];
    end
    if target1[period] == 0.0 then
        return;
    end
    for kk = 0, 45 do
        if clot[period - 45 + kk] > target2[period] and lo[period - 45 + kk] >= target1[period] and condi then
            l[period] = source.low[period] - (averagetruerange.DATA[period]) * 0.5;
            rr[period] = -1;
            bar[period] = period + kk + 2;
            break;
        elseif lo[period - 45 + kk] < target1[period] then
            l[period] = mb[period];
            break;
        end
    end
end
