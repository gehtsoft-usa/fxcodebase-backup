-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3610
-- Id: 3317

--+------------------------------------------------------------------+
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

-- The indicator is nominated as Richard Tao Trend Status indicator 
-- This for determining of strategy. could combine other indicator to confirm trend 


-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RichardTaoTrendStatus");
    indicator:description("Richard Tao Trend Status.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("T", "Timeframe", "", "D1");
    indicator.parameters:setFlag("T", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N", "Number of periods", "", 20);
    indicator.parameters:addInteger("L", "Level of threshold", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP3", "UP3 Color", "", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrDN3", "DN3 Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrUP2", "UP2 Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN2", "DN2 Color", "", core.rgb(255, 64, 0));
    indicator.parameters:addColor("clrUP1", "UP1 Color", "", core.rgb(128, 128, 0));
    indicator.parameters:addColor("clrDN1", "DN1 Color", "", core.rgb(255, 128, 0));

end

-- Parameters block
local N;
local L;
local aMa = {"EMA","MVA","LWMA","KAMA"};
local m = 3;

local firstPeriod;
local source = nil;

-- Streams block
local M1;
local M2;
local M3;
local M4;
local MA1 = nil;
local MA2 = nil;
local MA3 = nil;
local MA4 = nil;
local MAS1 = nil;
local MAS2 = nil;
local MAS3 = nil;
local MAS4 = nil;

--for Timeframe
local stream = nil;
local streamloading = false;
local ostream = {};
local iperiod=-1;

--for check wave
local forward = nil;
local backward = nil;
local ZZW = nil;

-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    N = instance.parameters.N;
    L = instance.parameters.L;
    source = instance.source;
    firstPeriod = source:first() + N - 1 + m;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. L .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    --for difference source Prepare
    if stream == nil then
        CheckBarSize(source:barSize(), instance.parameters.T);
    else
        CheckBarSize(source:barSize(), stream:barSize());
    end

    MAS1 = instance:addInternalStream(firstPeriod, 0);
    MAS2 = instance:addInternalStream(firstPeriod, 0);
    MAS3 = instance:addInternalStream(firstPeriod, 0);
    MAS4 = instance:addInternalStream(firstPeriod, 0);

    MA1 = instance:addInternalStream(firstPeriod, 0);
    MA2 = instance:addInternalStream(firstPeriod, 0);
    MA3 = instance:addInternalStream(firstPeriod, 0);
    MA4 = instance:addInternalStream(firstPeriod, 0);
    
    TSL = instance:addStream("TSL", core.Line, name .. ".TSL", "TSL", instance.parameters.clrDN2, firstPeriod)	
    TSN = instance:addStream("TSN", core.Line, name .. ".TSN", "TSN", instance.parameters.clrUP2, 0)	
    TSN:setStyle(core.LINE_NONE);
end

-- Indicator calculation routine
local sunit
function Update(period, mode)
    if streamloading == true then return; end
    if stream == nil then
        stream, ostream = GetStream(instance.parameters.T);
        if ostream.external == false then
            iperiod = PrepareStreamMA(stream);
        end
    else
        M1:update(mode);
        M2:update(mode);
        M3:update(mode);
        M4:update(mode);
        TSN[0] = 0;
        
        iperiod = GetStreamPeriod(period, ostream, stream);
        if period > firstPeriod and M4.DATA:hasData(iperiod-m) then
            --set InternalStream
            local MAS,MA,M;
            for m=1, 4 do
                if m==1 then MAS=MAS1; MA=MA1; M=M1; end
                if m==2 then MAS=MAS2; MA=MA2; M=M2; end
                if m==3 then MAS=MAS3; MA=MA3; M=M3; end
                if m==4 then MAS=MAS4; MA=MA4; M=M4; end
                local delta=0;
                if math.fmod(m, 2)==0 then
                    for i = 0, m-1 do
                        delta = delta+(M.DATA[iperiod-i]-M.DATA[iperiod-i-1]);    
                    end
                    delta = delta/m; 
                else
                    delta = (M.DATA[iperiod]-M.DATA[iperiod-1]);    
                end
                MAS[period] = (delta) / sunit /1 *100;    
                MA[period] = M.DATA[iperiod];
            end
            
            --display Status
            if MAS4:hasData(period-1) then
                TSL[period] = MA4[period]; 
                TSN[period] = GetTrendStatus(TSN[period-1], L, period); 
                if TSN[period] == -1 then TSL:setColor(period, instance.parameters.clrDN1); end
                if TSN[period] == 1 then TSL:setColor(period, instance.parameters.clrUP1); end
                if TSN[period] == -2 then TSL:setColor(period, instance.parameters.clrDN2); end
                if TSN[period] == 2 then TSL:setColor(period, instance.parameters.clrUP2); end
                if TSN[period] == -3 then TSL:setColor(period, instance.parameters.clrDN3); end
                if TSN[period] == 3 then TSL:setColor(period, instance.parameters.clrUP3); end
            end
            
        end
    end
end

function CheckBarSize(sbar, tbar)
    local s, e, s1, e1;
    s, e = core.getcandle(sbar, core.now(), 0, 0);
    s1, e1 = core.getcandle(tbar, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
end

function GetStream(barSize)
    local ostream = {};
    local odata = nil;
    local sfrom, sto;

    -- the size of the source
    if barSize == source:barSize() then
        ostream.barSize = barSize;
        ostream.external = false;
        ostream.loadFrom = source:first();
        ostream.loadTo = source:size() - 1;
        ostream.id = 0;
        odata = source;
    else
        --set standard source size to 150
        from, sto = core.getcandle(barSize, core.now(), 0, 0);
        sfrom = sto - (sto-from)*150;
        --set end to current
        if (source:isAlive()) then sto = 0 end;

        ostream.barSize = barSize;
        ostream.external = true;
        ostream.loadFrom = sfrom;
        ostream.loadTo = sto;
        ostream.id = 1;
        
        streamloading = true;
        odata = core.host:execute("getHistory", ostream.id, source:instrument(), barSize, sfrom, sto, source:isBid());
    end
    return odata, ostream;
end

function GetStreamPeriod(period, ostream, stream)
    assert(stream ~= nil, "Stream is not registered");
    local candlefr, sPeriod;
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;
    local day_offset, week_offset;
    
    if ostream.external then
        day_offset = core.host:execute("getTradingDayOffset");
        week_offset = core.host:execute("getTradingWeekOffset");
        candlefr = core.getcandle(ostream.barSize, source:date(period), day_offset, week_offset);
        datesec = math.floor(candlefr * 86400 + 0.5)
        min = 0;
        max = stream:size() - 1;

        if max < 1 then
            return -1;
        else
            while true do
                mid = math.floor((min + max) / 2);
                periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
                if datesec == periodsec then
                    sPeriod = mid;
                    break; 
                elseif datesec > periodsec then
                    min = mid + 1;
                else
                    max = mid - 1;
                end
                if min > max then
                    sPeriod = -1;
                    break; 
                end
            end
        end

        return sPeriod;
    else
        return period;
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    cookie = PrepareStreamMA(stream);

    streamloading = false;
    instance:updateFrom(1);
end
function PrepareStreamMA(stream)
    local rangeA; 
    if stream:size()>=150 then
        rangeA = core.rangeTo(stream:size()-1, 150);
    else
        rangeA = core.range(stream:first(), stream:size()-1);
    end
    sunit = (core.max(stream.close, rangeA) - core.min(stream.close, rangeA)) / 100;
    assert(core.indicators:findIndicator(aMa[1]) ~= nil, aMa[1] .. " indicator must be installed");
    M1 = core.indicators:create(aMa[1], stream.close, N);
    assert(core.indicators:findIndicator(aMa[2]) ~= nil, aMa[2] .. " indicator must be installed");
    M2 = core.indicators:create(aMa[2], stream.close, N);
    assert(core.indicators:findIndicator(aMa[3]) ~= nil, aMa[3] .. " indicator must be installed");
    M3 = core.indicators:create(aMa[3], stream.close, N);
    assert(core.indicators:findIndicator(aMa[4]) ~= nil, aMa[4] .. " indicator must be installed");
    M4 = core.indicators:create(aMa[4], stream.close, N);

    return 1;
end

function GetTrendStatus(tStatus, pMASL, period)
    local swup = 1;
    local swdn = -1;
    local sdup = 2;
    local sddn = -2;
    local saup = 3;
    local sadn = -3;
    
    --phase for trend accelerate
    if MAS2[period]<0 and core.crossesUnder(MA1, MA2, period) then tStatus=-3; end
    if MAS2[period]>0 and core.crossesOver(MA1, MA2, period) then tStatus=3; end

    --phase to trend decelerate : straddle
    if MAS2[period]<pMASL*-1 and core.crossesOver(MA1, MA2, period) then tStatus=-2; end
    if MAS2[period]>pMASL and core.crossesUnder(MA1, MA2, period) then tStatus=2; end
    
    --phase to trend end : change
    if (core.crossesUnder(MAS1, 0, period-1) or core.crossesUnder(MAS1, 0, period)) 
    and (core.crossesUnder(MAS3, 0, period-1) or core.crossesUnder(MAS3, 0, period)) 
    then tStatus=-1; end
    if (core.crossesOver(MAS1, 0, period-1) or core.crossesOver(MAS1, 0, period)) 
    and (core.crossesOver(MAS3, 0, period-1) or core.crossesOver(MAS3, 0, period)) 
    then tStatus=1; end
    
    --phase to whipsaw : strangle
    if core.crossesUnder(MAS4, pMASL, period) then tStatus=-1; end
    if core.crossesOver(MAS4, pMASL*-1, period) then tStatus=1; end
        
    --phase for trend start
    if core.crossesUnder(MAS4, pMASL*-1, period) then if MA1[period]<MA2[period] then tStatus=-3 else tStatus=-2 end end
    if core.crossesOver(MAS4, pMASL, period) then if MA1[period]>MA2[period] then tStatus=3 else tStatus=2 end end

    return tStatus;
end

