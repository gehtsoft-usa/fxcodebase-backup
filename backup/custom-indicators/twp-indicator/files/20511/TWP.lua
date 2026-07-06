-- The indicator is Richard Tao Wave Predictor base on Elliott Wave and Fibonacci Analysis 
-- Richard Tao Predictor serials number 5

-- initializes the indicator
function Init()
    indicator:name("RichardTaoWavePredictor");
    indicator:description("Richard Tao Wave Predictor.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addInteger("M", "Trend Minimum", "Minimum Periods of Main Trend.", 50, 20, 120);
    indicator.parameters:addInteger("N", "Wave Minimum", "Minimum Periods of Wave, 0 is Automatic.", 0, 3, 60);
    indicator.parameters:addBoolean("ShowWaveNo", "Show WaveNo", "Display Wave Number.", true);   
    indicator.parameters:addBoolean("ShowProject", "Show Projection", "Display Projection.", true);   
    indicator.parameters:addColor("clrEWS", "TextColor", "The color of the Text.", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clrWPL", "ProjectionColor", "The color of the line.", core.rgb(0, 183, 183));
end

--global serial
local M;
local N;
local source = nil;
local forward = nil;
local backward = nil;
local ZZM = nil;
local ZZW = nil;
local BTL = nil;
local BBL = nil;
local PPJ = nil;
local PX = 20;

local EWN = nil;
local EWP = nil;
local EWL = nil;
local EWS = nil;
local WPL = nil;
local WPS = nil;


-- initializes the instance of the indicator
function Prepare()
    M = instance.parameters.M;
    N = instance.parameters.N;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. M .. ", " .. N .. ")";
    instance:name(name);
    forward = core.makeArray(50);
    backward = core.makeArray(50);

    BTL = instance:addInternalStream(0, 0);
    BBL = instance:addInternalStream(0, 0);
    EWN = instance:addInternalStream(0, 0);
    EWP = instance:addInternalStream(0, 0);

    if instance.parameters.ShowWaveNo then 
        EWL = instance:addStream("EWL", core.Line, name .. ".EWL", "EWL", instance.parameters.clrEWS, 0);
        EWS = instance:createTextOutput("EWS", "EWS", "Arial", 8, core.H_Left, core.V_Center, instance.parameters.clrEWS, 0);
    end
    if instance.parameters.ShowProject then 
        WPL = instance:addStream("WPL", core.Line, name .. ".WPL", "WPL", instance.parameters.clrWPL, 0);
        WPS = instance:createTextOutput("WPS", "WPS", "Arial", 8, core.H_Center, core.V_Center, instance.parameters.clrWPL, PX);
    end
end

local winfo = {};
local nfor = 0;
local nback = 0;
local peakb = {0,0,0,0,0,0,0,0,0,0};
local rangeT;

local sMax = 0;
local sMin = 0;
local sunit = 0;
                
local bn = 20;
local rl = {};
local proj = {};
local lastbar = nil;

-- calculate the value
function Update(period, mode)
    if period == source:first() then
        InitialUpdate(source);
    end

    if period > bn and period >= winfo.prevwfirst-bn then
        rangeT = core.rangeTo(period, bn);
        BTL[period] = core.avg(source.close, rangeT) + core.stdev(source.close, rangeT)*2;
        BBL[period] = core.avg(source.close, rangeT) - core.stdev(source.close, rangeT)*2;
    end

    if period >= winfo.prevwfirst then
        if period == winfo.prevwfirst then
            winfo.nw = -1;
            nfor, nback = SetWave(ZZW, forward, backward, source, N, winfo.prevwfirst, winfo.lastwfirst);
        end
        if period == winfo.lastwfirst+1 then
            winfo.nw = 1;
            nfor, nback = SetWave(ZZW, forward, backward, source, N, winfo.lastwfirst, source:size()-1);
        end
        winfo.thisnfor = 1;
        for i = 1, nfor do
            if period>forward[i-1] and period<=forward[i] then winfo.thisnfor=i; break; end
        end
        
        EWN[period] = GetEwn(ZZW, forward, nfor, winfo.thisnfor, winfo.lastupdn*winfo.nw, sunit, period);
        EWP[period] = GetPattern(ZZW, forward, winfo.thisnfor, EWN[period], source, period);

        proj.ppj, proj.expos = GetProject(ZZW, EWN, forward, winfo.thisnfor, EWP[period], source, period);
        PPJ[math.min(proj.expos, source:size()-2+PX)] = proj.ppj; 

    end

    if (period == source:size() - 1) and (mode ~= core.UpdateLast) then
        if instance.parameters.ShowWaveNo then 
            local ewa = {"A","B","C","D","E","F","G"};
            local lbladj = 0;
            local ewno = 0;

            winfo.prevp = winfo.prevwfirst;
            for iperiod = winfo.prevwfirst+1, period-1 do
                if EWN[iperiod]~=nil and ZZW[iperiod]>0 then
                    ewno = math.abs(EWN[iperiod]);
                    if ZZW[iperiod]<ZZW[winfo.prevp] then lbladj=sunit*-10 else lbladj=sunit*10 end
                    if iperiod<=winfo.lastwfirst then winfo.nw=-1 else winfo.nw=1 end 
                    if winfo.diffLen*winfo.nw < 0 then
                        EWS:set(iperiod, ZZW[iperiod]+lbladj, tostring(ewno)); 
                    else
                        EWS:set(iperiod, ZZW[iperiod]+lbladj, ewa[ewno]); 
                    end
                    rangeT = core.range(winfo.prevp, iperiod);
                    core.drawLine(EWL, rangeT, ZZW[winfo.prevp], winfo.prevp, ZZW[iperiod], iperiod);
                    winfo.prevp = iperiod;
                end
            end
        end     --end of wave
        
        if instance.parameters.ShowProject then
            for i = forward[nfor-1], period+PX-1 do
                if PPJ[i]>0 and (PPJ[i]-ZZW[forward[nfor-1]])*(ZZW[forward[nfor]]-ZZW[forward[nfor-1]])>0 
                then WPS:set(i, PPJ[i], "x"); proj.expos=i; end
            end      
            for i=period-10, period do WPL[i]=nil end
            rangeT = core.rangeTo(period, 5);
            core.drawLine(WPL, rangeT, PPJ[proj.expos], forward[nfor-1], PPJ[proj.expos], period);
        end     --end of project

	end
    if (period == source:size() - 1) and lastbar ~= source:date(period) then
        lastbar = source:date(period);
        instance:updateFrom(source:first());
    end

end

function InitialUpdate(source)
    local sourcesize = source:size() - 1;	
    sMax = core.max(source.high, core.range(source:first(), sourcesize));
    sMin = core.min(source.low, core.range(source:first(), sourcesize));
    sunit = (sMax - sMin) / sourcesize;
    ZZM = mathex.makeArray(source:size());
    ZZW = mathex.makeArray(source:size());
    PPJ = mathex.makeArray(source:size()+PX);
    
    peakb, lastupdn = GetBackPeakPos(ZZM, source, M);
    winfo.lastupdn = lastupdn;
    winfo.prevwfirst = peakb[3];
    winfo.lastwfirst = peakb[2];
    winfo.lastwend = peakb[1];
    
    winfo.diffLen = PriceLength(ZZM,winfo.prevwfirst,winfo.lastwfirst)
                    -PriceLength(ZZM,winfo.lastwfirst,winfo.lastwend);
    if N == 0 then
        if winfo.diffLen > 0 then
            N = math.floor((winfo.lastwfirst-winfo.prevwfirst)/10);
        else
            N = math.floor((winfo.lastwend-winfo.lastwfirst)/10);
        end
        if N < 4 then N = 4 end
        if N > 12 then N = 12 end
    end
end


function SetWave(ZZP, forward, backward, sourcep, nlen, istart, iend)
    local markfor = -1; 
    local markback = -1;
    local slopep = 0;
  
    SetZZP(ZZP, sourcep, nlen);
	for i = istart, iend do
	    if ZZP[i] > 0 then
	        markfor = markfor + 1;
	        forward[markfor] = i;
	    end
	end
	for i = iend, istart, -1 do
	    if ZZP[i] > 0 then
	        markback = markback + 1;
	        backward[markback] = i;
	    end
	end
	
	return markfor, markback;
end

function GetEwn(ZZP, forward, ntolw, nforw, nupdown, sunit, period)
    local num = 1;
    local wnp = {0,0,0,0,0,0,0,0,0,0,0};    --keep wave number position
    
    for i = 1, nforw do     
        if math.fmod(i, 2) == 1 and math.fmod(num, 2) == 0 then
            if i == ntolw then
                if WaveLength(ZZP,sunit,forward[i-1],forward[i]) > WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*(1+0.02) then
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            elseif num == 2 then
                if (ZZP[forward[i-1]]-ZZP[wnp[1]])*nupdown < 0  
                and WaveLength(ZZP,sunit,forward[i-1],forward[i]) > WaveLength(ZZP,sunit,forward[0],wnp[1])*0.96 then
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            elseif num > 2 then
                if (ZZP[forward[i-1]]-ZZP[wnp[num-3]])*nupdown > 0 
                and WaveLength(ZZP,sunit,forward[i-1],forward[i]) > WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*(1+0.618/1.25^(num/2-1)) then   --aternative /1.85^
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            end
        elseif math.fmod(i, 2) == 0 and math.fmod(num, 2) == 1 then
            if num == 1 then
                if WaveLength(ZZP,sunit,forward[i-1],forward[i]) > WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*0.384 
                and WaveLength(ZZP,sunit,forward[i-1],forward[i]) < WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*0.91 then
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            elseif num == 3 then
                if (ZZP[forward[i]]-ZZP[wnp[num-2]])*nupdown > 0   
                and WaveLength(ZZP,sunit,forward[i-1],forward[i]) < WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*0.618 then
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            elseif num > 3 then
                if WaveLength(ZZP,sunit,forward[i-1],forward[i]) < WaveLength(ZZP,sunit,forward[i-2],forward[i-1])*0.764 then
                    wnp[num] = forward[i-1];
                    num = num + 1;
                end
            end
        end
    end
    
	return num * nupdown;
end

function GetPattern(ZZP, forward, nforw, newn, sourcep, period)
    local spatt = 1;    --default as simple wave
    local trndupdn = 1;  
    if newn<0 then trndupdn=-1 else trndupdn=1 end

    for r = 0, 0, 1 do
        if math.fmod(newn, 2) == 1 and period > 24 then
            local d = core.stdev(sourcep.close, core.rangeTo(period-3, 20));
            for i = 0, 2 do
                if (sourcep.high[period-i] - sourcep.low[period-i] > d*3) then
                    spatt = 6
                    if math.abs(newn)>1 then trndupdn=trndupdn*-1 end
                    break;
                end
            end
        end
            
        if nforw > 2 and math.abs(newn) > 4 then
            local pr2b = math.abs(ZZP[forward[nforw-1]]-ZZP[forward[nforw-3]]);
            local lr2b = WaveLength(ZZP,sunit,forward[nforw-1],forward[nforw-2])/WaveLength(ZZP,sunit,forward[nforw-2],forward[nforw-3]);
            if (pr2b < sunit*5) and (lr2b > 0.95 and lr2b < 1.05) then
                spatt = 7;
                trndupdn = trndupdn * -1;
                break;
            end
        end               
        if nforw > 4 and math.abs(newn) > 4 then
            local pr3b = math.abs(ZZP[forward[nforw-1]]-ZZP[forward[nforw-5]]);
            local pr3n = math.abs(ZZP[forward[nforw-2]]-ZZP[forward[nforw-4]]);
            if (pr3b < sunit*5) and (pr3n < sunit*5) then
                spatt = 8;
                trndupdn = trndupdn * -1;
                break;
            end
        end               
        
        if period==source:size()-1 then
            local l1 = 0;
            local h1 = 0;
            local l2 = 0;
            local h2 = 0;
            local fupdown = 0;
            if sourcep.close[period] - sourcep.close[math.floor(period/4)] < 0 then
                fupdown = -1;
                h1 = sMin+(sMax-sMin)*0.3;
                l1 = sMin;
                h2 = sMax;
                l2 = sMin+(sMax-sMin)*0.7;
            else
                fupdown = 1;
                h1 = sMax;
                l1 = sMin+(sMax-sMin)*0.7;
                h2 = sMin+(sMax-sMin)*0.3;
                l2 = sMin;
            end            
            if InArea(sourcep, period/2, period, l1, h1, true) 
                and InArea(sourcep, period/4, period/2, l2, h2, false) then
                    spatt = 9;
                    trndupdn = fupdown * -1;
                    break;
            end
        end
        
        if math.fmod(newn, 2) == 0 and nforw > 1 then
            local polebegin = ZZP[forward[nforw-2]];
            local poleheight = (ZZP[forward[nforw-1]] - ZZP[forward[nforw-2]]);
            
            local fdbpos = forward[nforw-1]+3;
            if fdbpos > forward[nforw] then fdbpos=forward[nforw] end
            local fdbheight; 
            if poleheight < 0 then
                fdbheight = core.max(sourcep.high, core.range(forward[nforw-1], fdbpos)) - forward[nforw-1];
            else
                fdbheight = core.max(sourcep.low, core.range(forward[nforw-1], fdbpos)) - forward[nforw-1];
            end
            if fdbheight/poleheight*-1 < 0.5 and fdbheight/poleheight*-1 > 0.2 then
                h1 = polebegin + poleheight*0.5;
                l1 = polebegin + poleheight*1.0;
                h2 = polebegin + poleheight*0.7;
                l2 = polebegin + poleheight*1.2;
                if InArea(sourcep, forward[nforw-1], forward[nforw], l1, h1, true) 
                or InArea(sourcep, forward[nforw-1], forward[nforw], l2, h2, true) then
                    spatt = 4;
                    break;
                end
            end
            
            if nforw > 3 then
                local stair = true;
                for i = 0, nforw-2, 1 do
                    if (ZZP[forward[i+2]]-ZZP[forward[i]]) * newn < 0 then
                        stair = false;
                        break;
                    end
                end
                if stair then
                    spatt = 3;
                    break;
                end   
            end
            
            if nforw > 1 then
                    spatt = 2;
                    break;
            end
        end

    end --for
    
	return spatt*trndupdn;
end

function GetProject(ZZP, EWN, forward, nforw, patt, sourcep, period)
    local thisw = EWN[period];
    local prevw = EWN[period];
    if EWN:hasData(forward[nforw-1]) then
        prevw = EWN[forward[nforw-1]];
    end
    proj.isdire = EWN[period]*(ZZP[forward[nforw]]-ZZP[forward[nforw-1]]);
    proj.wstartpos = forward[nforw-1];
    proj.wstartval = ZZP[proj.wstartpos];
    proj.wendpos = period;    
    proj.wendval = sourcep.close[proj.wendpos];    
    proj.wdiffv = proj.wendval-proj.wstartval;
    if proj.wdiffv<0 then proj.wendpeak=sourcep.low[proj.wendpos] else proj.wendpeak=sourcep.high[proj.wendpos] end   
    proj.pwstart = 0;
    proj.pwfinish = 0;
    proj.ppj = 0;
    
    local lw = sourcep.close[period];
    if period>bn then lw = mathex.lwma(sourcep.close, core.rangeTo(period, bn)) end
    if (lw-ZZP[forward[nforw-1]])*(lw-sourcep.close[period]) < 0 
    and (lw-ZZP[forward[nforw-1]])*(lw-sourcep.close[period-1]) > 0 then
        proj.ppj = GetFactorValue(proj.wstartval, lw, proj.wstartval, 2.0);

        return proj.ppj, GetExtrapos(proj.wstartval, proj.wstartpos, lw, proj.wendpos, proj.ppj, period+50);    
    end
    
    if nforw > 2 then
        proj.r3 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.382);
        proj.r5 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.5);
        proj.r6 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.618);
        proj.e1 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.0);
        proj.e6 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.618);
        proj.e2 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 2.0);
        proj.ret = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.r3, proj.r5, proj.r6, 0);
        proj.ext = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.e1, proj.e6, proj.e2, 0);
    end
    
    if math.fmod(thisw, 2)==1 and thisw==prevw and proj.isdire<0 and nforw>2 then
        proj.p1 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.382);
        proj.p2 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.5);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.ret, 0);
    end
    if math.fmod(thisw, 2)==1 and thisw==prevw and proj.isdire>0 and nforw>2 then
        if math.abs(prevw)==1 then
            proj.p1 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.0);
            proj.p2 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.618);
            proj.pwstart, proj.pwfinish = GetPrevEWave(ZZP, EWN, -1, period);
            proj.p3 = proj.pwstart;
        elseif math.abs(prevw)==3 then
            proj.p1 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.618);
            proj.p2 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 2.0);
            proj.pwstart, proj.pwfinish, proj.twstart = GetPrevEWave(ZZP, EWN, -2, period);
            proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.twstart, 1.0);
        else
            proj.p1 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.0);
            proj.p2 = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.618);
            proj.pwstart, proj.pwfinish, proj.twstart = GetPrevEWave(ZZP, EWN, -2, period);
            proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.twstart, 1.0);
        end
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, 0);
    end
    if math.abs(prevw)==1 and math.abs(thisw)==2 and proj.isdire<0 then
        proj.pwstart, proj.pwfinish = GetPrevEWave(ZZP, EWN, -1, period);
        proj.p1 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -0.382);
        proj.p2 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -0.5);
        proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -0.618);
        proj.bbr = GetBBresist(BBL, BTL, PX);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, proj.bbr);
    end
    if math.fmod(thisw, 2)==0 and thisw==prevw then
        proj.p1 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.618);
        proj.p2 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -1.0);
        proj.p3 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -1.272);
        proj.bbr = GetBBresist(BBL, BTL, PX);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, proj.bbr);
        if proj.isdire<0 and (math.abs(patt)==7 or math.abs(patt)==8) then
            proj.ppj = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -2.0);
        end
    end
    if math.abs(prevw)==2 and math.abs(thisw)==3 then
        proj.pwstart, proj.pwfinish = GetPrevEWave(ZZP, EWN, -2, period);
        proj.p1 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 0.618);
        proj.p2 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 1.0);
        proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 1.618);
        proj.p4 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 2.0);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, proj.p4);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.ppj, proj.ext, 0, 0);
    end
    if math.abs(prevw)>2 and math.abs(thisw)>math.abs(prevw) and proj.isdire<0 then
        proj.p1 = GetFactorValue(ZZP[forward[nforw-2]], ZZP[forward[nforw-1]], proj.wstartval, -0.382);
        proj.bbr = GetBBresist(BBL, BTL, PX);
        proj.ppj = proj.bbr;
        if math.abs(patt)==3 then
            proj.ppj = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.0);
        end
    end
    if math.abs(prevw)>3 and math.abs(thisw)>math.abs(prevw) and proj.isdire>0 then
        proj.pwstart, proj.pwfinish = GetPrevEWave(ZZP, EWN, -2, period);
        proj.p1 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 0.618);
        proj.p2 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 1.0);
        proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, 1.618);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, proj.ext);
        if math.abs(patt)==3 then
            proj.ppj = GetFactorValue(ZZP[forward[nforw-3]], ZZP[forward[nforw-2]], proj.wstartval, 1.0);
        end
    end
    if math.abs(thisw) == 1 and thisw*prevw < 0 then
        proj.pwstart, proj.pwfinish = GetPrevEWave(ZZP, EWN, -1, period);
        proj.p1 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -0.618);
        proj.p2 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -1.0);
        proj.p3 = GetFactorValue(proj.pwstart, proj.pwfinish, proj.wstartval, -1.618);
        proj.ppj = GetCompProj(proj.wdiffv, proj.wendpeak, -1, proj.p1, proj.p2, proj.p3, 0);
    end

    return proj.ppj, GetExtrapos(proj.wstartval, proj.wstartpos, proj.wendval, proj.wendpos, proj.ppj, period+PX);    
end

function GetIntersect(L1sv, L1ev, L2sv, L2ev, pstart, pend, iend)
    local intersec = 0;
    local pos = 0;
    local dL1 = (L1ev-L1sv)/(pend-pstart);
    local dL2 = (L2ev-L2sv)/(pend-pstart);
    local dire = 1;
    if L1sv-L2sv < 0 then dire = -1 end
    
    for i = pstart, iend do
        if (L1sv+dL1*(i-pstart) - L2sv+dL2*(i-pstart)) * dire < 0 then
            intersec = L1sv+dL1*(i-pstart);
            pos = i;
            break;
        end
    end
    return intersec, pos;
end
function GetExtrapos(vstart, pstart, vend, pend, vtarg, iend)
    local pos = pstart;
    local delt = (vend-vstart)/(pend-pstart);
    local dire = 1;
    if vstart-vtarg < 0 then dire = -1 end
    
    for i = pstart, iend do
        if (vstart+delt*(i-pstart) - vtarg) * dire < 0 then
            pos = i;
            break;
        end
    end
    return pos;
end
function GetFactorValue(vstart, vend, fstart, factor)
    return fstart + (vend-vstart) * factor;
end
function GetPrevEWave(ZZP, EWN, nfind, period)
    local wstart = 0;
    local wfinish = 0;
    local w1finish = 0;
    
    for i = period-1, 1, -1 do
        if EWN:hasData(i) then
            if EWN:hasData(i-1) then
                if EWN[i]~=EWN[i+1] then nfind=nfind+1 end
            else 
                nfind = nfind + 1;
            end
            if nfind==-1 and w1finish==0 then
                w1finish = ZZP[i];
            end
            if nfind==0 and wfinish==0 then
                wfinish = ZZP[i];
            end
            if nfind==1 and wstart==0 then
                wstart = ZZP[i];
                break;
            end
        else
            break;
        end
    end
    return wstart, wfinish, w1finish;
end
function GetBBresist(BBL, BTL, iend)
    local isBBr = false;
    local bbp = 0;
    if proj.wendpos-proj.wstartpos < 3 then return bbp end
    proj.BLstart, proj.BLend = GetRegressionPoint(BBL, proj.wstartpos, proj.wendpos);
    proj.TLstart, proj.TLend = GetRegressionPoint(BTL, proj.wstartpos, proj.wendpos);
    proj.BLslope = (proj.BLend-proj.BLstart)/(proj.wendpos-proj.wstartpos);
    proj.TLslope = (proj.TLend-proj.TLstart)/(proj.wendpos-proj.wstartpos);

    if math.abs(proj.BLslope) < (BTL[proj.wendpos]-BBL[proj.wendpos])*0.02 
    and math.abs(proj.TLslope) < (BTL[proj.wendpos]-BBL[proj.wendpos])*0.02 then
        isBBr = true;
    end
    if proj.BLslope > 0 and proj.TLslope < 0 then
        isBBr = true;
    end
    if proj.BLslope*proj.wdiffv < 0 and proj.TLslope*proj.wdiffv < 0 then
        isBBr = true;
    end
    if isBBr then
        if proj.wdiffv < 0 then
            bbp = GetIntersect(proj.BLstart, proj.BLend, proj.wstartval, proj.wendval, proj.wstartpos, proj.wendpos, proj.wendpos+iend);
        else
            bbp = GetIntersect(proj.TLstart, proj.TLend, proj.wstartval, proj.wendval, proj.wstartpos, proj.wendpos, proj.wendpos+iend);
        end
    end
    return bbp;
end
function GetCompProj(wdiffv, wendpeak, minmax, p1, p2, p3, p4)
    local pp = 0;
    local buff = sunit*4;
    if wdiffv<0 then 
        if minmax<0 then
            pp=0;
            if p1>0 and p1-buff-wendpeak<0 and p1>pp then pp=p1 end
            if p2>0 and p2-buff-wendpeak<0 and p2>pp then pp=p2 end
            if p3>0 and p3-buff-wendpeak<0 and p3>pp then pp=p3 end
            if p4>0 and p4-buff-wendpeak<0 and p4>pp then pp=p4 end
        else
            pp=1000000;
            if p1>0 and p1-buff-wendpeak<0 and p1<pp then pp=p1 end
            if p2>0 and p2-buff-wendpeak<0 and p2<pp then pp=p2 end
            if p3>0 and p3-buff-wendpeak<0 and p3<pp then pp=p3 end
            if p4>0 and p4-buff-wendpeak<0 and p4<pp then pp=p4 end
        end
    else 
        if minmax<0 then
            pp=1000000;
            if p1>0 and p1+buff-wendpeak>0 and p1<pp then pp=p1 end
            if p2>0 and p2+buff-wendpeak>0 and p2<pp then pp=p2 end
            if p3>0 and p3+buff-wendpeak>0 and p3<pp then pp=p3 end
            if p4>0 and p4+buff-wendpeak>0 and p4<pp then pp=p4 end
        else
            pp=0;
            if p1>0 and p1+buff-wendpeak>0 and p1>pp then pp=p1 end
            if p2>0 and p2+buff-wendpeak>0 and p2>pp then pp=p2 end
            if p3>0 and p3+buff-wendpeak>0 and p3>pp then pp=p3 end
            if p4>0 and p4+buff-wendpeak>0 and p4>pp then pp=p4 end
        end
    end   
    return pp;
end

function GetBackPeakPos(ZZM, sourcep, mlen)
    local updown = 0;
    local peakb = {0,0,0,0,0,0,0,0,0,0};
    local markback = 1; --find last 10 point
    local srclast = sourcep:size() - 1;

    SetZZP(ZZM, sourcep, mlen);
    for i = srclast, 1, -1 do
        if ZZM[i] > 0 then
	        peakb[markback] = i;
	        markback = markback + 1;
        end
        if markback > 10 then
            break;
        end
    end
    if ZZM[peakb[1]]-ZZM[peakb[2]] < 0 then
        updown = -1;
    else
        updown = 1;
    end 
	
	return peakb, updown;
end
function SetZZP(ZZP, sourcep, lengthp)
    local zinfo = {};
    local srcforw;
    local srcback;
    local srcfirst = sourcep:first();
    local srclast = sourcep:size() - 1;
    
    for iperiod = srcfirst, srclast do
        if iperiod == srcfirst then
            zinfo.rangev = core.max(sourcep.high, core.range(srcfirst, srclast)) 
                            - core.min(sourcep.low, core.range(srcfirst, srclast));
            zinfo.zback = zinfo.rangev / 100 * math.sqrt(lengthp) * 2;
            zinfo.searchhl = 1;
            srcforw = sourcep.high;
            srcback = sourcep.low;
            zinfo.newVal = sourcep.close[srcfirst];
            zinfo.newPos = srcfirst;
            zinfo.preVal = zinfo.newVal;
        end
        if (srcforw[iperiod]-zinfo.newVal)*zinfo.searchhl > 0 then
            zinfo.newVal = srcforw[iperiod];
            zinfo.newPos = iperiod;
        end
        if ( (iperiod-zinfo.newPos >= lengthp) and (zinfo.newVal-srcback[iperiod])*zinfo.searchhl > zinfo.zback )
        or ( (srcback[iperiod]-zinfo.preVal)*zinfo.searchhl < 0 ) then
            ZZP[zinfo.newPos] = zinfo.newVal;
            zinfo.preVal = zinfo.newVal;
            zinfo.searchhl = zinfo.searchhl * -1;
            if zinfo.searchhl > 0 then
                if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos+2, iperiod)); end
                srcforw = sourcep.high;
                srcback = sourcep.low;
            elseif zinfo.searchhl < 0 then
                if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos+2, iperiod)); end
                srcforw = sourcep.low;
                srcback = sourcep.high;
            end
        end

        if (iperiod == srclast) then    
            ZZP[zinfo.newPos] = zinfo.newVal;
            zinfo.preVal = zinfo.newVal;
            zinfo.prePos = zinfo.newPos;
            
            if lengthp>3 and lengthp<=20 then
                zinfo.lastback = zinfo.rangev / 100 * 1;
            elseif lengthp>20 and lengthp<=40 then
                zinfo.lastback = zinfo.rangev / 100 * math.sqrt(lengthp*10);
            elseif lengthp>40 and lengthp<=100 then 
                zinfo.lastback = zinfo.rangev / 100 * (lengthp*0.75-10);
            else 
                zinfo.lastback = zinfo.zback;
            end
            
            if zinfo.searchhl*-1>0 and iperiod-zinfo.prePos>3 then
                zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos, iperiod));
            elseif zinfo.searchhl*-1<0 and iperiod-zinfo.prePos>3 then
                zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos, iperiod));
            end
            if (zinfo.newVal-zinfo.preVal)*zinfo.searchhl*-1  > zinfo.lastback then
                ZZP[zinfo.newPos] = zinfo.newVal;
            end
        end
    end
end
function PriceLength(ZZP, nfr, nto)
    nfr = math.floor(nfr);
    nto = math.floor(nto);
    return math.abs(ZZP[nto]-ZZP[nfr]);
end
function WaveLength(ZZP, sunit, nfr, nto)
    nfr = math.floor(nfr);
    nto = math.floor(nto);
    return math.sqrt(math.pow(ZZP[nto]-ZZP[nfr],2) + math.pow((nto-nfr)*sunit,2));
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
function InArea(sourcep, nfr, nto, plow, phigh, bflag)
    local rangeP = core.range(math.floor(nfr), math.floor(nto));
    if plow > phigh then
        phigh, plow = plow, phigh;
    end
	if bflag then
	    if (core.max(sourcep.high, rangeP) <= phigh) 
	    and (core.min(sourcep.low, rangeP) >= plow) then
	        return true;
	    else
	        return false;
	    end
	else
	    if (core.max(sourcep.high, rangeP) < plow) 
	    or (core.min(sourcep.low, rangeP) > phigh) then
	        return true;
	    else
	        return false;
	    end
	end
end


