
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2467

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


-- The indicator corresponds to the Automatic Up/Down Trend Line in Richard Trading System
-- Usage: core.indicators:create("ATL", source, Length) 
-- Description:darw the outter trend line base on the major wave Automaticlly 
-- version 1.1 to eliminate index out of range in GetLastWave
-- version 1.2 to redraw when update new bar 


-- initializes the indicator
function Init()
    indicator:name("AutomaticTrendLine");
    indicator:description("Automatic Up/Down Trend Line.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trends");

    indicator.parameters:addInteger("Length", "Length", "The minimum number of periods used to mark wave.", 30, 10, 200);
    indicator.parameters:addColor("clrUTL", "UpLineColor", "The color of the line.", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clrDTL", "DownLineColor", "The color of the line.", core.rgb(0, 64, 0));
    --best (30) for D1; (30) for H1
end

local Length = 0;
local source = nil;

local utl = nil;
local dtl = nil;
local SLR = nil;
local PVW = nil;
local ZZW = nil;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. "," .. Length .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    SLR = instance:addInternalStream(0, 0);
    PVW = instance:addInternalStream(0, 0);
    utl = instance:addStream("UTL", core.Line, name .. ".UTL", "UTL", instance.parameters.clrUTL,  0);
    dtl = instance:addStream("DTL", core.Line, name .. ".DTL", "DTL", instance.parameters.clrDTL,  0);
end

local pfr = 0;
local pto = 0;
local position1 = 0;
local position2 = 0;
local rangeT = nil;
local value1 = 0;
local value2 = 0;
local sourcehl;

-- calculate the value
function Update(period, mode)
    
    if (period == source:size()-1) then
        ZZW = core.makeArray(source:size());
        -- set main wave serial, bestfit for TL set 2
        SetZZP(ZZW, source, Length);
        
        for updn = -1, 1, 2 do
            pfr, pto = GetLastWave(ZZW, source:size()-1, updn);
            
            --avoid too short range to draw
            if pto - pfr > 5 then
                if updn < 0 then
                    sourcehl = source.high;
                else
                    sourcehl = source.low;
                end
                --get regression line
                value1, value2 = GetRegressionPoint(sourcehl, pfr, pto);
	            core.drawLine(SLR, core.range(pfr, pto), value1, pfr, value2, pto);

    	        --find peak
                position1, position2 = Find2Peak(PVW, SLR, sourcehl, pfr, pto, updn);
                
		        --draw only the latest  
		        rangeT = core.range(position1, source:size()-1);
                if updn < 0 then
                    for i=source:first(), period do dtl[i]=nil end
	                core.drawLine(dtl, rangeT, sourcehl[position1], position1, sourcehl[position2], position2);
                else
                    for i=source:first(), period do utl[i]=nil end
	                core.drawLine(utl, rangeT, sourcehl[position1], position1, sourcehl[position2], position2);
                end
            end
        end
	end
end

function SetZZP(ZZP, sourcep, lengthp)
    -- variable for ZZP
    local sMax = 0;
    local sMin = 0;
    local sback = 0;
    local lastback = 0;
    local newVal = 0;
    local newPeak = 0;
    local preVal = 0;
    local prePeak = 0;
    local searchhl;
    local srcfor;
    local srcback;
    local srcfirst = sourcep:first();
    local srclast = sourcep:size() - 1;

    for iperiod = srcfirst, srclast do
        if iperiod == srcfirst then
            sMax = core.max(sourcep.high, core.range(srcfirst, srclast));
            sMin = core.min(sourcep.low, core.range(srcfirst, srclast));
            sback = (sMax - sMin) / 100 * math.sqrt(lengthp) * 2;

            searchhl = 1;
            srcfor = sourcep.high;
            srcback = sourcep.low;
            preVal = sourcep.close[srcfirst];
            prePeak = srcfirst;
            newVal = sourcep.close[srcfirst];
            newPeak = srcfirst;
        end
        
        --find highest/lowest
        if (srcfor[iperiod]-newVal) * searchhl > 0 then
            newVal = srcfor[iperiod];
            newPeak = iperiod;
        end
        --turn
        if ( (iperiod-newPeak >= lengthp) and ((newVal-srcback[iperiod]) * searchhl > sback) ) then
            ZZP[newPeak] = newVal;
            preVal = newVal;
            prePeak = newPeak;
            searchhl = searchhl * -1;
            
            --adjust length inner peak and source to find
            if searchhl > 0 then
                newVal, newPeak = core.max(sourcep.high, core.range(newPeak, iperiod));
                srcfor = sourcep.high;
                srcback = sourcep.low;
            elseif searchhl < 0 then
                newVal, newPeak = core.min(sourcep.low, core.range(newPeak, iperiod));
                srcfor = sourcep.low;
                srcback = sourcep.high;
            end
        end

        --for at last allow turn wave
        if (iperiod == srclast) then    
            ZZP[newPeak] = newVal;
            preVal = newVal;
            prePeak = newPeak;
            
            --The best last drawback is percentage 25
            if lengthp>3 and lengthp<=20 then
                lastback = (sMax - sMin) / 100 * 1;
                --newPeak = iperiod;
            elseif lengthp>20 and lengthp<=40 then
                lastback = (sMax - sMin) / 100 * math.sqrt(lengthp*10);
            elseif lengthp>40 and lengthp<=100 then 
                lastback = (sMax - sMin) / 100 * (lengthp*0.75-10);
            else 
                lastback = sback;
            end
            
            if searchhl * -1 > 0 and iperiod-prePeak > 3 then
                newVal, newPeak = core.max(sourcep.high, core.range(newPeak, iperiod));
            elseif searchhl * -1 < 0 and iperiod-prePeak > 3 then
                newVal, newPeak = core.min(sourcep.low, core.range(newPeak, iperiod));
            end
            if (newVal-preVal) * searchhl * -1  > lastback then
                ZZP[newPeak] = newVal;
            end
        end
    end
end
--find the wave begin end
function GetLastWave(ZZP, srclast, updown)
    local peaka = {0,0,0};
    local markback = 3;
    local peakb, peake;
    
    for i = srclast, 1, -1 do
        if ZZP[i] > 0 then
	        peaka[markback] = i;
	        markback = markback - 1;
        end
        if markback < 1 then
            break;
        end
    end
    --check last up or down
    if (ZZP[peaka[3]]-ZZP[peaka[2]]) * updown > 0 then
        peakb = peaka[2];
        peake = peaka[3];
    else
        peakb = peaka[1];
        peake = peaka[2];
    end 
    
	return peakb, peake;
end
-- find the most peak two point
function Find2Peak(PVW, SLR, sourcep, pos1, pos2, updown)
    local peak1 = 0;
    local peak2 = 0;
    local peak3 = 0;
    local peak4 = 0;
    local pv1 = 0;
    local pv2 = 0;
    local pv3 = 0;
    local pv4 = 0;
    local span;
    
    -- set peak valley point serial
    for i = pos1, pos2 do
        PVW[i] = sourcep[i] - SLR[i];
    end
    --find peak
    span = math.floor((pos2-pos1)/4);
    if updown < 0 then
        if pos2 - pos1 > 8 then
            pv1, peak1 = core.max(PVW, core.range(pos1, pos1+span*1));
            pv2, peak2 = core.max(PVW, core.range(pos1+span*1+1, pos1+span*2));
            pv3, peak3 = core.max(PVW, core.range(pos1+span*2+1, pos1+span*3));
            pv4, peak4 = core.max(PVW, core.range(pos1+span*3+1, pos2));
            if (pv1-pv2)*updown > 0 then peak1, peak2 = peak2, peak1; end
            if (pv3-pv4)*updown > 0 then peak3, peak4 = peak4, peak3; end
            if peak3 - peak1 < span then
            if (PVW[peak1]-PVW[peak3])*updown > 0 then peak1, peak3 = peak3, peak1; end
            peak3 = peak4;
            end
        else
            --avoid too close to find
            pv1, peak1 = core.max(PVW, core.range(pos1, pos1+span*2));
            pv3, peak3 = core.max(PVW, core.range(pos1+span*2+1, pos2));
        end
    else
        if pos2 - pos1 > 8 then
            pv1, peak1 = core.min(PVW, core.range(pos1, pos1+span*1));
            pv2, peak2 = core.min(PVW, core.range(pos1+span*1+1, pos1+span*2));
            pv3, peak3 = core.min(PVW, core.range(pos1+span*2+1, pos1+span*3));
            pv4, peak4 = core.min(PVW, core.range(pos1+span*3+1, pos2));
            if (pv1-pv2)*updown > 0 then peak1, peak2 = peak2, peak1; end
            if (pv3-pv4)*updown > 0 then peak3, peak4 = peak4, peak3; end
            if peak3 - peak1 < span then    
            -- adjust peak too close to catch
            if (PVW[peak1]-PVW[peak3])*updown > 0 then peak1, peak3 = peak3, peak1; end
            peak3 = peak4;
            end
        else
            --avoid too close to find
            pv1, peak1 = core.min(PVW, core.range(pos1, pos1+span*2));
            pv3, peak3 = core.min(PVW, core.range(pos1+span*2+1, pos2));
        end
    end
   
	return peak1, peak3;
end

function GetRegressionPoint(sourcep, pos1, pos2)
    local b1 = 0;
    local b0 = 0;
    local x_avg = 0;
    local y_avg = 0;
    local dx_sum =0;
    local dv_sum =0;
    
    x_avg = (pos1 + pos2) / 2;
    y_avg = core.avg(sourcep, core.range(pos1, pos2));
    for i = pos1, pos2 do
        dv_sum = dv_sum + (i - x_avg)*(sourcep[i] - y_avg);
        dx_sum = dx_sum + (i - x_avg)^2;
    end
    b1 = dv_sum / dx_sum;
    b0 = y_avg - b1*x_avg;
    
    return b1*pos1+b0, b1*pos2+b0
end

