-- The indicator is Richard Tao Delimitor Oscillator
-- Technical Analysis Office simple tool for contrarian trader

function Init()
    indicator:name("RichardTaoDelimitorOscillator");
    indicator:description("TechnicalAnalysisOffice tool for contrarian trader");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addInteger("N", "Look back", "", 0, 0, 1000);
    indicator.parameters:addInteger("T", "Type of separator", "", 1, 0, 9);  
        indicator.parameters:addIntegerAlternative("T", "CDV", "conver divergent", 1);  --40
        indicator.parameters:addIntegerAlternative("T", "PVG", "pivot divergent", 2);  --60
        indicator.parameters:addIntegerAlternative("T", "SWK", "sine wave skip", 3);       --120
        indicator.parameters:addIntegerAlternative("T", "MFH", "volume force", 4);     --60
        indicator.parameters:addIntegerAlternative("T", "CRF", "correlation", 5);      --100
    indicator.parameters:addGroup("IMode");
    indicator.parameters:addDouble("L", "Level", "", 0.0, -1000.0, 1000);
    indicator.parameters:addDouble("CK", "check", "", 0.0, -1000.0, 1000);
   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrR", "Red", "", core.rgb(255, 96, 96));
    indicator.parameters:addColor("clrO", "Orange", "", core.rgb(255, 208, 64));
    indicator.parameters:addColor("clrY", "Yellow", "", core.rgb(255, 250, 0));
    indicator.parameters:addColor("clrG", "Green", "", core.rgb(0, 192, 0));
    indicator.parameters:addColor("clrB", "Blue", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrC", "Cyan", "", core.rgb(0, 192, 255));
    indicator.parameters:addColor("clrP", "Purple", "", core.rgb(192, 0, 192));
    indicator.parameters:addColor("clrS", "Sliver", "", core.rgb(224, 208, 208));
    indicator.parameters:addColor("clrF", "Fuchsia", "", core.rgb(255, 64, 240));
    indicator.parameters:addColor("clrI", "Lime", "", core.rgb(144, 255, 144));
    indicator.parameters:addColor("clrL", "Lavender", "", core.rgb(240, 160, 255));
end

local source = nil;
local SRC = {};     --multiple source
local SIN = {};     --multiple instrument
local PRP = {};     --multiple parameter position control

local oIndi = {};
local oPara = {};
--for outstream
local FLG = nil;    --singal of single mode
local FCO = nil;    --for financial center opened bar

--async load
local onload = false;
local toload = 1;
local loaded = 1;
local lastbar = nil;
local iperiod;

-- Routine
function Prepare()
    source = instance.source;
    local name = profile:id() .. "(" .. instance.parameters.N .. ", " .. instance.parameters.T .. ")";
    instance:name(name);

    oPara.pTTF = source:barSize();      --set barsize
    oPara.pIND = true;
    oPara.pTHS = true;
    loaded = 1; toload = 1; SRC[1] = source;
    oPara.pBGN = 0;    --source begin point
    oPara.pEND = 10000;
    if oPara.pIND then oPara.pSBG = 5000; else oPara.pSBG = 250; end
    --set control
    for i = 1, toload do
        PRP[i] = {};
        PRP[i].avrng = 0;   --atr
        PRP[i].sperd = 0;   --speriod
        
        PRP[i].reg = instance:addInternalStream(0, 0);    
        PRP[i].atr = instance:addInternalStream(0, 0);    
        PRP[i].std = instance:addInternalStream(0, 0);    
        PRP[i].sin = instance:addInternalStream(0, 0);
        PRP[i].led = instance:addInternalStream(0, 0);
        --volume force
        PRP[i].vtb = instance:addInternalStream(0, 0);  --incremental
        PRP[i].vtc = instance:addInternalStream(0, 0);  --incremental
        PRP[i].vtd = instance:addInternalStream(0, 0);  --degree 
        PRP[i].vte = instance:addInternalStream(0, 0);  --weighting
        PRP[i].vtf = instance:addInternalStream(0, 0);  --force
        PRP[i].vta = core.makeArray(24);
        for h = 0, 23 do PRP[i].vta[h] = 0; end
        --stochatic
        PRP[i].sto = instance:addInternalStream(0, 0);
        PRP[i].stk = instance:addInternalStream(0, 0);
        PRP[i].dvk = instance:addInternalStream(0, 0);
        PRP[i].pcc = instance:addInternalStream(0, 0);
        PRP[i].fcc = instance:addInternalStream(0, 0);
        PRP[i].sbr = instance:addInternalStream(0, 0);
        --sine 
        PRP[i].shpo1 = 0;   --previous sine cross position
        PRP[i].shpo2 = 0;   --the last sine cross position
        PRP[i].sndir = 0;   --the sine direction
        PRP[i].snpos = 0;   --the sine skip position
        
        --divergent
        PRP[i].dlpos = 0;   --the last low peak position
        PRP[i].dhpos = 0;   --the last high peak position
        PRP[i].dvdir = 0;   --the divergent direction
        PRP[i].dvpos = 0;   --the divergent end position
        PRP[i].dvpps = 0;   --the divergent begin position
        PRP[i].kipos = 0;   --the into exetreme position
        PRP[i].kopos = 0;   --the out of exetreme position
        PRP[i].kedir = 0;   --the stay exetreme flag
        
    end

    --set parameter
    SetParameter(oPara, source, period);

    if oPara.pIND and oPara.pTHS then
        if     oPara.pTYP == 1 then
            PRP[1].std = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrB, 0); 
            PRP[1].atr = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrG, 0); 
            --PRP[1].fcc = instance:addStream("C", core.Line, name .. ".C", "C", instance.parameters.clrY, 0); 
        elseif oPara.pTYP == 2 then
            PRP[1].stk = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrB, 0); 
            PRP[1].dvk = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrG, 0); 
            PRP[1].stk:addLevel(-instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
            PRP[1].stk:addLevel(instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
        elseif oPara.pTYP == 3 then
            PRP[1].sin = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrB, 0); 
            PRP[1].led = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrG, oPara.pNBK); 
            PRP[1].sbr = instance:addStream("V", core.Bar,  name .. ".V", "V", instance.parameters.clrG, 0);
            PRP[1].sin:addLevel(-instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
            PRP[1].sin:addLevel(instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
        elseif oPara.pTYP == 4 then
            PRP[1].vtf = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrB, 0); 
            PRP[1].vtd = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrF, 0); 
            PRP[1].vtf:addLevel(-instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
            PRP[1].vtf:addLevel(instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
        elseif oPara.pTYP == 5 then
            PRP[1].pcc = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrB, 0); 
            PRP[1].fcc = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrF, 0); 
            PRP[1].pcc:addLevel(instance.parameters.L, core.LINE_DOT, 1, oPara.clrS);
        end
    else
    end
    
end                                                                 

-- Indicator calculation routine
function Update(period, mode)
    if onload then return; end
    iperiod = period - 1; 
    
    --redefind the calculate range
    oPara.pEND = source:size()-1;      
    oPara.pBGN = math.max(oPara.pEND-oPara.pSBG, oPara.pRNG, oPara.pNBK);
    if loaded == toload and lastbar ~= source:serial(iperiod) 
    and iperiod > oPara.pBGN then
        local PRA = PRP[1]; --current properties
        local SRS = SRC[1]; --current sources
        local speriod = PRA.sperd;  --redefine period form original
        local c;    --counter
        lastbar = source:serial(iperiod);
        
        --check each 
        for c = 1, toload do
            PRA = PRP[c]; 
            SRS = SRC[c]; 
            PRA.sperd = GetSperiod(SRS, source, iperiod);
            PRA.avrng = Iif(source:barSize()=="D1", GetAvgRange(oPara.pRNG, SRS, PRA.sperd-1), CalcEma(oPara.pRNG, PRA.avrng, GetAvgRange(oPara.pRNG, SRS, PRA.sperd-1)));
            speriod = PRA.sperd;  --redefine period form original
            if     oPara.pTYP == 1 then
                --(120,2.0,0.5)H4; (20,1.0,0.3)D1
                PRA.atr[speriod] = PRA.avrng*oPara.pTCL;     
                PRA.std[speriod] = CalcStd(oPara.pNBK, SRS.close, speriod);
                PRA.dvdir, PRA.dvpps = CalcLineDir(3, PRA.avrng*oPara.pCHK, PRA.dvpps, PRA.std[speriod], speriod);
                PRA.std:setColor(speriod, Iif(PRA.dvdir==0, instance.parameters.clrG, Iif(PRA.dvdir<0, instance.parameters.clrF, instance.parameters.clrB)));
            elseif oPara.pTYP == 2 then
                PRA.dvdir, PRA.dvpos, PRA.dvpps = CalcDivergEnd(PRA, SRS, speriod);
                if PRA.dvdir ~= 0 and PRA.dvpos ~= 0 and PRA.dvpps > 0 then 
                core.drawLine(PRA.dvk, core.range(PRA.dvpps, math.abs(PRA.dvpos)), PRA.stk[PRA.dvpps], PRA.dvpps, PRA.stk[math.abs(PRA.dvpos)], math.abs(PRA.dvpos)); end
            elseif oPara.pTYP == 3 then
                --(120,0.7,8) as H4; (30,0.7,6) as D1
                PRA.sndir, PRA.snpos = CalcSineSkip(PRA, SRS, speriod);
                if speriod - math.abs(PRA.snpos) == 0 then PRA.sbr[speriod] = Iif(PRA.sndir<0,-1, 1); end
                PRA.sin:setColor(speriod, Iif(PRA.sndir==0, instance.parameters.clrL, Iif(PRA.sndir<0, instance.parameters.clrF, instance.parameters.clrB)));
            elseif oPara.pTYP == 4 then
                if oPara.pCHK == 1 then PRA.vtf[speriod] = CalcVtf(oPara.pNBK, PRA.vta, PRA.vtb, PRA.vte, PRA.vtf[speriod-1], SRS, speriod); 
                                   else PRA.vtf[speriod] = CalcVth(oPara.pNBK, PRA.vta, PRA.vtc, PRA.vtf[speriod-1], SRS, speriod); end
                PRA.vtf:setColor(speriod, Iif(IsBetween(PRA.vtf[speriod], -oPara.pTCL, oPara.pTCL), instance.parameters.clrG, instance.parameters.clrB));
            elseif oPara.pTYP == 5 then
                PRA.reg[speriod] = CalcRgs(oPara.pNBK, 0, SRS.close, speriod);
                PRA.pcc[speriod] = CalcPcc(oPara.pNBK, PRA.reg, SRS.close, speriod);
                PRA.fcc[speriod] = CalcFcc(oPara.pNBK, PRA.avrng, PRA.reg, SRS.close, speriod);
                PRA.pcc:setColor(speriod, Iif(PRA.pcc[speriod] < oPara.pTCL, instance.parameters.clrG, instance.parameters.clrB));
            end
        end
    end
    
end
    
function ReleaseInstance()
    source = nil;
    SRC = nil;     
    SIN = nil;     
    oIndi = nil;
    oPara = nil;
    --for outstream
    FLG = nil;    
    PRP = nil;
    collectgarbage();    
    return;
end
function SetParameter(oPara, sourcep, iperiod)
    oPara.pNBK = instance.parameters.N; 
    oPara.pTYP = instance.parameters.T;     
    oPara.pTCL = instance.parameters.L;     
    oPara.pCHK = instance.parameters.CK;
    
    oPara.pRNG = 40;    --period for hilo range
    oPara.pCY2 = 20;
    oPara.pCY5 = 50;    --50     
    oPara.pCY6 = 60;    --60 
    oPara.pCY7 = 120;   --120
    oPara.pCY8 = 200;   --200   sp:120  
    oPara.pCY9 = 240;   --200   sp:120  
    if oPara.pNBK == 0 then oPara.pNBK = 20; end
    if     oPara.pTYP == 1 then
    elseif oPara.pTYP == 2 then
        oPara.pVTL = oPara.pTCL;   --force, swing extreme level  .6-.9
    elseif oPara.pTYP == 3 then
        oPara.pSW7 = oPara.pTCL;        
        oPara.pNVC = oPara.pCHK;     --peak check      
        oPara.pNPK = 2;           
    elseif oPara.pTYP == 4 then
    elseif oPara.pTYP == 5 then
        oPara.pTCL = 0;
    end
end
    
function TransTFnumber(timeFrame)
    local tff = 0;
    if string.sub(timeFrame,1,1)=="M" then tff = 500 end
    if string.sub(timeFrame,1,1)=="W" then tff = 400 end
    if string.sub(timeFrame,1,1)=="D" then tff = 300 end
    if string.sub(timeFrame,1,1)=="H" then tff = 200 end
    if string.sub(timeFrame,1,1)=="m" then tff = 100 end
    return tff + tonumber(string.sub(timeFrame,2,-1));
end
function Iif(bcheck, tval, fval)
    if bcheck then return tval else return fval end
end
function IsBetween(vcheck, vbegin, vend)
    if vcheck >= vbegin and vcheck <= vend 
    then return true else return false end
end
function IsTimeOpen(imt, ctz, sourcep, speriod)
    local hrchange = false;
    local prevbar, thisbar;
    if ctz == "UTC" then
        prevbar = core.host:execute("convertTime", 1, 2, sourcep:date(speriod-1));
        thisbar = core.host:execute("convertTime", 1, 2, sourcep:date(speriod));
    else
        prevbar = sourcep:date(speriod-1);
        thisbar = sourcep:date(speriod);
    end
    local dph = core.dateToTable(prevbar).hour;
    local dth = core.dateToTable(thisbar).hour;

    if dph - dth > 0 then dph = dph-24; end
    if dph ~= dth and dth >= imt then hrchange = true; end
    return hrchange;
end
function IsWdayNext(wday, pdate, tdate)
    local isnext = false;
    if pdate - tdate >= 0 then return isnext end
    
    local pred = core.dateToTable(pdate).wday;
    local thed = core.dateToTable(tdate).wday;
    if thed - pred < 0 then thed = thed + 7; end
    if pred <= wday and thed > wday then isnext = true; end
    return isnext;    
end

function CalcEma(mPeriod, preEma, newSrc)
    local newEma;
    local smooth = 2.0 / (mPeriod + 1.0);
    if preEma == nil or preEma == 0 then preEma = newSrc end
    newEma = (1 - smooth) * preEma + smooth * newSrc;
    return newEma;
end
function CalcSma(mPeriod, oripos, sourcep, speriod)
    if oripos == 0 then mPeriod = math.min(speriod, mPeriod);
    else mPeriod = math.max(speriod-oripos, 1); end
    
    local newSma = mathex.avg(sourcep, core.rangeTo(speriod, mPeriod));
    return newSma;
end

function CalcRgs(rPeriod, shtpos, sourcep, speriod)
    --regression momentum by shift center
    --pos1 as beginning position
    local offpos = 0;
    local pos1 = math.max(0, speriod-rPeriod+offpos);
    local pos2 = speriod;
    local b1 = 0;
    local b0 = 0;
    local x_avg = 0;
    local y_avg = 0;
    local dx_sum =0;
    local dv_sum =0;
     
    x_avg = ((pos1 + pos2) / 2) + shtpos;
    y_avg = core.avg(sourcep, core.range(pos1, pos2));
    for i = pos1, pos2 do
        dv_sum = dv_sum + (i - x_avg)*(sourcep[i] - y_avg);
        dx_sum = dx_sum + (i - x_avg)^2;
    end
    b1 = dv_sum / dx_sum;
    b0 = y_avg - b1*x_avg;
    --return the last, the first value
    return b1*pos2+b0, b1*pos1+b0;
end

function CalcFcc(rPeriod, avrng, strm1, strm2, speriod)
    rPeriod = math.min(rPeriod, speriod);
    local ifrom = speriod - rPeriod + 1;
    local rcxp = ifrom;     --last cross position    local mtp = 1.3;
    local mtp = 1.3;
    local diff, std1, nrml, wght;
    local sumn = 0;     --negative
    local sump = 0;     --positive
    local sum2 = 0;     --sum of square 
    for i = ifrom, speriod do
        diff = strm2[i]-strm1[i]; 
        if diff < 0 then sumn = sumn + diff; end 
        if diff > 0 then sump = sump + diff; end 
        if (strm2[i]-strm1[i])*(strm2[i-1]-strm1[i-1]) < 0 then rcxp = i; end
    end
    for i = ifrom, speriod do  if strm2[i]-strm1[i] ~= nil then sum2 = sum2 + (strm2[i]-strm1[i]- (sumn+sump)/rPeriod) ^ 2; end end
    std1 = math.sqrt(sum2/rPeriod);
    nrml = math.sqrt(math.sqrt(rPeriod));
    wght = 1 - math.abs(sump/(sump-sumn) - 0.5)*mtp;
    return math.min(std1/(avrng*nrml) * wght, mtp);
end
function CalcPcc(rPeriod, strm1, strm2, speriod)
    local pos1 = math.max(0, speriod-rPeriod+1);
    local pos2 = speriod;
    local s1_sum = 0;
    local s2_sum = 0;
    local s1_sqr = 0;
    local s2_sqr = 0;
    local ss_pdt = 0;
    local relatn = 0;
     
    for i = pos1, pos2 do
        s1_sum = s1_sum + strm1[i];
        s2_sum = s2_sum + strm2[i];
        s1_sqr = s1_sqr + strm1[i]^2;
        s2_sqr = s2_sqr + strm2[i]^2;
        ss_pdt = ss_pdt + strm1[i]*strm2[i];
    end
    relatn = (rPeriod*ss_pdt - s1_sum*s2_sum) / 
    (math.sqrt(rPeriod*s1_sqr - s1_sum^2) * math.sqrt(rPeriod*s2_sqr - s2_sum^2));
    
    return relatn;
end
function CalcStd(rPeriod, sourcep, speriod)
    rPeriod = math.min(rPeriod, speriod);
    local suma = 0;
    local mean = 0;
    local sump = 0;
    local ifrom = speriod - rPeriod + 1;
    for i = ifrom, speriod do if sourcep[i] ~= nil then suma = suma + sourcep[i]; end end
    mean = suma / rPeriod;
    for i = ifrom, speriod do if sourcep[i] ~= nil then sump = sump + (sourcep[i]-mean) ^ 2; end end
    return math.sqrt(sump/rPeriod);
end
function CalcStk(mPeriod, prek, sourcep, speriod)
    mPeriod = math.min(mPeriod, speriod-1);
    local k;
    local pnsk = 8;
    local minLow = core.min(sourcep, core.rangeTo(speriod, mPeriod));
    local maxHigh = core.max(sourcep, core.rangeTo(speriod, mPeriod));
    local sMin = sourcep[speriod] - minLow;
    local sMax = maxHigh - minLow;
    local smoothk = 2.0 / (pnsk + 1.0);
    if sMax > 0 then k = sMin / sMax * 100; else k = 50; end  --(0 to 100)
    k = (k-50)/50; --(-1 to +1)
    if prek == nil or prek == 0 then prek = k end
    return (1 - smoothk) * prek + smoothk * k;   
end
function CalcSkr(mPeriod, STO, sourcep, speriod)
    mPeriod = math.min(mPeriod, speriod-1);
    local k;
    local prek = STO[speriod-1];
    local minLow = core.min(sourcep, core.rangeTo(speriod, mPeriod));
    local maxHigh = core.max(sourcep, core.rangeTo(speriod, mPeriod));
    local sMin = sourcep[speriod] - minLow;
    local sMax = maxHigh - minLow;
    local pnsm = 4;
    local pnem = 10;
    local smoothk = 2.0 / (pnem + 1.0);
    if sMax > 0 then k = sMin / sMax * 100; else k = 50; end  --(0 to 100)
    k = (k-50)/50; --(-1 to +1)
    if prek == nil or prek == 0 then prek = k end
    STO[speriod] = (1 - smoothk) * prek + smoothk * k;
    return CalcRgs(pnem, pnsm, STO, speriod);   
end
function CalcVth(rPeriod, VTA, VTC, pdgre, sourcep, speriod)
    rPeriod = math.min(rPeriod, speriod);   --120
    local vdgre = pdgre;   --volume degree
    local psmc = 50;   --smooth average
    local vhequ = sourcep.volume[speriod]/(sourcep.high[speriod]-sourcep.low[speriod]);
    local vdate = core.dateToTable(sourcep:date(speriod));
    if vhequ > 0 and IsBetween(vdate.month*100 + vdate.day, 103, 1229) then
        VTA[vdate.hour] = CalcEma(rPeriod, VTA[vdate.hour], vhequ);
        VTC[speriod] = CalcEma(psmc, VTC[speriod-1], vhequ/VTA[vdate.hour]);
        vdgre = CalcStk(rPeriod, pdgre, VTC, speriod);  --level -0.7+
    end
    return vdgre;
end
function CalcVtf(rPeriod, VTA, VTB, VTE, vfrce, sourcep, speriod)
    rPeriod = math.min(rPeriod, speriod);
    local pfrce = vfrce;   --previous volume force
    local pmid = 0.02; --middle level
    local pmnc = 1.0;
    local pmnr = 120;   --multipler of normalize 
    local psmc = 20;   --smooth average
    local psmf = 4;    --smooth average
    local vhequ = sourcep.volume[speriod]/(sourcep.high[speriod]-sourcep.low[speriod]);
    local vdate = core.dateToTable(sourcep:date(speriod));
    if vhequ > 0 and IsBetween(vdate.month*100 + vdate.day, 103, 1229) then
        local vhavg = CalcEma(rPeriod, VTA[vdate.hour], vhequ);
        VTA[vdate.hour] = vhavg;
        VTB[speriod] = (vhequ/vhavg) * GetOneScale(sourcep.close[speriod], sourcep.low[speriod], sourcep.high[speriod]);    --with direction
        vfrce = CalcSma(rPeriod, 0, VTB, speriod);
        pmnr = math.max(psmc, pmnr-math.floor((speriod-VTB[0])*pmnc));
        if math.abs(vfrce) > pmid then vfrce = math.log10(math.abs(vfrce)*pmnr) * vfrce/math.abs(vfrce); end
        VTE[speriod] = vfrce;
        vfrce = CalcRgs(psmc, psmf, VTE, speriod);
        if CheckCrosses(pfrce, pmid, vfrce, pmid) ~= 0 then VTB[0] = speriod; end
        if CheckCrosses(pfrce,-pmid, vfrce,-pmid) ~= 0 then VTB[0] = speriod; end
    end
    return vfrce;
end
function CalcCsw(rPeriod, sourcep, speriod)
    local tpval = 0;
    local realP = 0;
    local imagP = 0;
    local phase = 90;
    for i = 0, rPeriod-1 do
        tpval = (sourcep.close[speriod-i]);
        realP = realP + math.sin(math.rad(360 * i / rPeriod)) * (tpval); 
        imagP = imagP + math.cos(math.rad(360 * i / rPeriod)) * (tpval); 
    end
    if math.abs(imagP) > 0 then
        phase = math.deg(math.atan(realP / imagP)) + 90;
    else phase = 90; end
    if imagP < 0 then phase = phase + 180; end
    if phase > 315 then phase = phase - 360; end
    return math.sin(math.rad(phase)), math.sin(math.rad(phase + 45));
end
function CalcLineDir(nmod, prng, base, sline, speriod)
    local ndir = 0;
    local npkm = base;
    if     nmod == 1 then
        prng = math.min(prng, speriod);
        --depend on strm1
        ndir = sline[speriod] - sline[speriod-prng];   
    elseif nmod == 2 then
        --cross
        ndir = Iif(sline[speriod]-base < 0, -1, 1);   
    elseif nmod == 3 then
        local thism = sline;
        if     npkm == nil or npkm == 0 then npkm = thism; 
        elseif npkm < 0 then
            if     (thism+npkm) > prng then npkm = thism; ndir = 1;       --reverse
            elseif (thism+npkm) < 0    then npkm =-thism; ndir =-1; end   --resume 
        elseif npkm > 0 then
            if     (npkm-thism) > prng then npkm =-thism; ndir =-1;
            elseif (npkm-thism) < 0    then npkm = thism; ndir = 1; end
        end
    elseif nmod == 4 then
        local flbk = math.min(base, speriod);   --flat lookback
        local fmid = math.floor(flbk/2);        --half position        
        if  math.abs(sline[speriod]-sline[speriod-flbk]) < prng
        and math.abs(sline[speriod]-sline[speriod-fmid]) < prng then ndir = 0;
        else ndir = Iif(sline[speriod]-sline[speriod-flbk]<0,-1, 1); end 
    end
    return ndir, npkm;
end
function CalcDivergEnd(PRA, SRS, speriod)
    local avrng = PRA.avrng;
    local dvdir = 0;
    local dvpos = PRA.dvpos;
    local dvpps = PRA.dvpps;
    local ppos, pval;
    local pnpk = 20;    --period of peak check back    15,20
    local pndt = oPara.pNBK;    --period of direct trend     60 -120
    local pnlt = oPara.pNBK;    --period of stay extreme trend     120
    local plvl = oPara.pVTL;   --equal standard 65: -1.0+0.3+1.0
    local pkxl = oPara.pVTL;
    local prav = 5;
    PRA.stk[speriod] = CalcSkr(pndt, PRA.sto, SRS, speriod);
    
    if PRA.stk[speriod-pnpk] > plvl and speriod-PRA.dhpos > pnpk*2 then
        ppos, pval = GetPivot( 1, pnpk, pnpk, PRA.stk, speriod);
        pval = SRS.high[ppos];
        if speriod-ppos == pnpk and math.abs(pval-SRS.high[PRA.dhpos]) > avrng then
            if (pval-SRS.high[PRA.dhpos]) > 0 and (PRA.stk[ppos]-PRA.stk[PRA.dhpos]) < 0 and ppos-PRA.dhpos > pndt 
            then dvdir =-1; dvpos = ppos*dvdir; dvpps = PRA.dhpos; end
            PRA.dhpos = ppos; end
    elseif PRA.stk[speriod-pnpk] < -plvl and speriod-PRA.dlpos > pnpk*2 then
        ppos, pval = GetPivot(-1, pnpk, pnpk, PRA.stk, speriod);
        pval = SRS.low[ppos];
        if speriod-ppos == pnpk and math.abs(pval-SRS.low[PRA.dlpos]) > avrng then
            if (pval-SRS.low[PRA.dlpos]) < 0 and (PRA.stk[ppos]-PRA.stk[PRA.dlpos]) > 0 and ppos-PRA.dlpos > pndt 
            then dvdir = 1; dvpos = ppos*dvdir; dvpps = PRA.dlpos; end
            PRA.dlpos = ppos; end
    end
    if CheckCrosses(PRA.stk[speriod-1],-pkxl, PRA.stk[speriod],-pkxl) < 0 then PRA.kipos =-speriod; end
    if CheckCrosses(PRA.stk[speriod-1],-pkxl, PRA.stk[speriod],-pkxl) > 0 then if speriod-math.abs(PRA.kipos) > pnlt then PRA.kedir = 1; dvpos = speriod; else PRA.kedir = 0; end PRA.kopos = speriod; end
    if CheckCrosses(PRA.stk[speriod-1], pkxl, PRA.stk[speriod], pkxl) > 0 then PRA.kipos = speriod; end
    if CheckCrosses(PRA.stk[speriod-1], pkxl, PRA.stk[speriod], pkxl) < 0 then if speriod-math.abs(PRA.kipos) > pnlt then PRA.kedir =-1; dvpos =-speriod; else PRA.kedir = 0; end PRA.kopos =-speriod; end
    return dvdir, dvpos, dvpps;
end
function CalcSineSkip(PRA, SRS, speriod)
    local sndir = PRA.sndir;    --Skip shift
    local snpos = Iif(math.abs(PRA.snpos)==1, 0, PRA.snpos);
    local pcyc = oPara.pNBK;    --120
    local pswl = oPara.pSW7;
    local pnvc = oPara.pNVC;
    local pnpk = oPara.pNPK;    --h4:4, D1:2
    local pefc = math.floor(math.min(20, math.max(pnvc, pcyc/6)));
    PRA.sin[speriod], PRA.led[speriod] = CalcCsw(pcyc, SRS, speriod);
    if CheckCrosses(PRA.sin[speriod-1], pswl, PRA.sin[speriod], pswl) < 0 then PRA.shpo1 =-speriod; end
    if CheckCrosses(PRA.sin[speriod-1],-pswl, PRA.sin[speriod],-pswl) > 0 then PRA.shpo1 = speriod; end
    if CheckCrosses(PRA.sin[speriod-1], pswl, PRA.sin[speriod], pswl) > 0 then PRA.shpo2 = speriod; end
    if CheckCrosses(PRA.sin[speriod-1],-pswl, PRA.sin[speriod],-pswl) < 0 then PRA.shpo2 =-speriod; end
    --check skip
    local pdiff = math.abs(PRA.shpo2)-math.abs(PRA.shpo1);
    if pdiff >= 0 and PRA.shpo1*PRA.shpo2 > 0 and speriod-math.abs(PRA.shpo2) == 0 and IsBetween(pdiff, 0, pnvc) then sndir = Iif(PRA.shpo2<0,-1, 1); snpos = PRA.shpo2; end
    if (not (math.abs(sndir) == 1 and not IsBetween(PRA.sin[speriod],-pswl,pswl)) and CheckCrosses(PRA.led[speriod-1], PRA.sin[speriod-1], PRA.led[speriod], PRA.sin[speriod])~= 0) then sndir = 0; snpos = Iif(PRA.led[speriod]-PRA.sin[speriod] < 0,-1, 1); end
    if (math.abs(sndir) == 1 and IsBetween(PRA.sin[speriod],-pswl,pswl)) then sndir = 0; snpos = Iif(PRA.sin[speriod]-PRA.led[speriod] < 0,-1, 1); end
    if math.abs(sndir) < 3 and speriod - GetPivot(PRA.led[speriod]-PRA.sin[speriod], pnpk, pnpk, PRA.sin, speriod) == pnpk then
        sndir = Iif(PRA.sin[speriod]-PRA.led[speriod] < 0,-3, 3); snpos = Iif(sndir < 0,-speriod, speriod); end

    return sndir, snpos;
end

function CheckCrosses(p1, p2, t1, t2)
    local cross = 0;
    if p1==nil then p1 = 0 end  --previous primary
    if p2==nil then p2 = 0 end  --previous baseline
    if t1==nil then t1 = 0 end  --present primary
    if t2==nil then t2 = 0 end  --present baseline
    if (p1>=p2 and t1<t2) then cross = -1 end
    if (p1<=p2 and t1>t2) then cross = 1 end
    return cross;
end
function GetAvgRange(mPeriod, sourcep, speriod)
    speriod = math.max(speriod, 1);
    mPeriod = math.min(speriod, mPeriod);
    local ahi = mathex.avg(sourcep.high, core.rangeTo(speriod, mPeriod));
    local alo = mathex.avg(sourcep.low, core.rangeTo(speriod, mPeriod));
    return ahi-alo;
end
function GetSperiod(sources, sourcep, iperiod)
    --the same timeframe
    local idt = sourcep:date(iperiod);
    local speriod = core.findDate(sources, idt, false);
    if speriod == -1 then speriod = 0; end
    return speriod;
end
function GetPivot(fdhl, nleft, nrght, sourcep, speriod)
    local pos = 0;
    local pvl = 0;
    local fnd = true;
    local nfr = math.max(speriod-math.max((nleft+nrght)*2, 20), nleft);
    local shilo;
    --set hilo
    if sourcep.low ~= nil then
        if fdhl < 0 then shilo = sourcep.low; else shilo = sourcep.high; end
    else shilo = sourcep; end
    for i = speriod-nrght, nfr, -1 do
        fnd = true;
        for j = 1, nleft do if (shilo[i]-shilo[i-j])*fdhl < 0 then fnd = false; end end
        for j = 1, nrght do if (shilo[i]-shilo[i+j])*fdhl < 0 then fnd = false; end end
        if fnd and (shilo[i]-shilo[speriod])*fdhl > 0 then pos = i; pvl = shilo[i]; break; end
    end
    return pos, pvl;
end
function GetOneScale(vcheck, vbegin, vend)
    local val = 0;
    if vend-vbegin > 0 then val = (vcheck-(vend+vbegin)*0.5) / ((vend-vbegin)*0.5); end
    return val;
end
