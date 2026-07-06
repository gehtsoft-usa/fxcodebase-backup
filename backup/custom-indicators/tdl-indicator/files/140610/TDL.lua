-- The indicator is Richard Tao Directional Line

function Init()
    indicator:name("RichardTaoDirectionalLine");
    indicator:description("TechnicalAnalysisOffice tool for momentum trader");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addInteger("N", "Look back", "", 0, 0, 1000);
    indicator.parameters:addInteger("T", "Type of Line", "", 1, 0, 9);  
        indicator.parameters:addIntegerAlternative("T", "ACF", "", 1);    
        indicator.parameters:addIntegerAlternative("T", "ACS", "", 2);    
        indicator.parameters:addIntegerAlternative("T", "ATL", "", 3);  
        indicator.parameters:addIntegerAlternative("T", "RGS", "", 4);       
        indicator.parameters:addIntegerAlternative("T", "SNA", "", 5);  
    indicator.parameters:addGroup("IMode");
    indicator.parameters:addDouble("L", "Level", "", 0.0, -1000.0, 1000);
    indicator.parameters:addDouble("CK", "check", "", 0.0, -1000.0, 1000);
   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("LN_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LN_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("LN_width", "Line Pixels", "", 1);
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
        PRP[i].prvfr = 0;   --previous from position
        
        PRP[i].m1btm = 0;   --envelope of bottom
        PRP[i].m1top = 0;   --envelope of top
        PRP[i].m1rvp = 0;   --reverse position
        PRP[i].m2btm = 0;   --envelope of bottom
        PRP[i].m2top = 0;   --envelope of top
        PRP[i].psmod = 0;   --push mode
        PRP[i].mcbtm = 0;   --mix combine bottom
        PRP[i].mctop = 0;   --mix combine top
        PRP[i].r1dir = 0;   --primary regression direction
        PRP[i].r1pkk = 0;   --primary regression peak
        PRP[i].r2dir = 0;   --primary regression direction
        PRP[i].r2pkk = 0;   --primary regression peak
        PRP[i].m2pos = 0;   --ms2 band cross position
        PRP[i].m2sml = 0;   --ms2 adjust buffer

        PRP[i].a3val = 0;   --alpha 3 value
        PRP[i].psdir = 0;   --push direction
        PRP[i].asdir = 0;   --slow direction 
        PRP[i].amdir = 0;   --momentum direction 
        PRP[i].ampos = 0;   --momentum position
        PRP[i].asval = 0;   --fast value
        PRP[i].afdir = 0;   --fast direction 
        PRP[i].afpos = 0;   --fast reverse position with dir
        PRP[i].afval = 0;   --fast value
        PRP[i].afpkk = 0;   --fast peak value
        --wave
        PRP[i].sndir = 0;   --direction
        PRP[i].snpos = 0;   --fast sine position
        PRP[i].shpo1 = 0;   --previous sine cross position
        PRP[i].shpo2 = 0;   --the last sine cross position
        
        --stream
        PRP[i].ln1 = instance:addInternalStream(0, 0);    
        PRP[i].ln2 = instance:addInternalStream(0, 0);    
        PRP[i].ma1 = instance:addInternalStream(0, 0);    
        PRP[i].ma2 = instance:addInternalStream(0, 0);    
        PRP[i].ma3 = instance:addInternalStream(0, 0);    
        PRP[i].ra2 = instance:addInternalStream(0, 0);    
        PRP[i].std = instance:addInternalStream(0, 0);    
        PRP[i].reg = instance:addInternalStream(0, 0);    
        PRP[i].pvl = instance:addInternalStream(0, 0);    
        PRP[i].sin = instance:addInternalStream(0, 0);
        PRP[i].led = instance:addInternalStream(0, 0);
    end

    --set parameter
    SetParameter(oPara, source, period);

    if oPara.pIND and oPara.pTHS then
        PRP[1].ln1 = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrC, 0); 
        PRP[1].ln2 = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrF, 0); 
        PRP[1].pvl = instance:addStream("V", core.Line, name .. ".V", "V", instance.parameters.clrG, 0);

        PRP[1].ln1:setStyle(instance.parameters.LN_style);
        PRP[1].ln1:setWidth(instance.parameters.LN_width);
        PRP[1].ln2:setStyle(instance.parameters.LN_style);
        PRP[1].ln2:setWidth(instance.parameters.LN_width);
        FLG = instance:createTextOutput("F", "F", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrG, 0);
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
                PRA.sndir, PRA.snpos = CalcSineSkip(PRA, SRS, speriod);
                PRA.afdir, PRA.afpos, PRA.ln1[speriod], PRA.afpkk = CalcActFast(PRA, SRS, speriod);
                PRA.ln1:setColor(speriod, Iif(PRA.afdir==0, instance.parameters.clrG, Iif(PRA.afdir<0, instance.parameters.clrF, instance.parameters.clrC)));
            elseif oPara.pTYP == 2 then
                PRA.sndir, PRA.snpos = CalcSineSkip(PRA, SRS, speriod);
                PRA.asdir, PRA.amdir, PRA.ampos, PRA.a3val = CalcActSlow(PRA, SRS, speriod);
                FLG:set(speriod, PRA.a3val, "\159", nil, Iif(PRA.asdir<0, instance.parameters.clrF, instance.parameters.clrC));
            elseif oPara.pTYP == 3 then
                PRA.prvfr = CalcATL(oPara.pNBK, PRA.ln1, PRA.ln2, PRA.pvl, SRS, speriod);
            elseif oPara.pTYP == 4 then
                PRA.ln1[speriod], PRA.ln2[speriod] = CalcRgs(oPara.pNBK, math.floor(oPara.pNBK/10), SRS.close, speriod);
                PRA.ln1:setColor(speriod, Iif(PRA.ln1[speriod]-PRA.ln2[speriod-oPara.pCHK]<0, instance.parameters.clrF, instance.parameters.clrC));
            elseif oPara.pTYP == 5 then
                PRA.ln1[speriod] = CalcSna(oPara.pNBK, PRA.ln1[speriod-1], SRS.close, speriod);
                PRA.ln2[speriod] = CalcSma(oPara.pNBK, 0, SRS.close, speriod);
                PRA.r1dir, PRA.r1pkk = CalcLineDir(3, PRA.avrng*oPara.pTCL, PRA.r1pkk, PRA.ln1[speriod], speriod);
                if CheckCrosses(PRA.ln1[speriod-1], PRA.ln2[speriod-1], PRA.ln1[speriod], PRA.ln2[speriod])*PRA.r1dir > 0 
                and (PRA.ln2[speriod]-PRA.ln2[speriod-oPara.pNCP])*PRA.r1dir > 0 then PRA.m2pos = speriod; end
                PRA.m2sml = oPara.pCHK * math.min(1.0, (speriod-PRA.m2pos)/oPara.pCY2); 
                PRA.r2dir, PRA.r2pkk = CalcLineDir(3, PRA.avrng*PRA.m2sml, PRA.r2pkk, PRA.ln2[speriod], speriod);
                --set
                PRA.ln1:setColor(speriod, Iif(PRA.r1dir==0, instance.parameters.clrG, Iif(PRA.r1dir<0, instance.parameters.clrF, instance.parameters.clrC)));
                PRA.ln2:setColor(speriod, Iif(PRA.r2dir==0, instance.parameters.clrG, Iif(PRA.r2dir<0, instance.parameters.clrF, instance.parameters.clrC)));
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
function SetParameter(oPara, sourcep, speriod)
    oPara.pNBK = instance.parameters.N; 
    oPara.pTYP = instance.parameters.T;     
    oPara.pTCL = instance.parameters.L;     
    oPara.pCHK = instance.parameters.CK;
    
    oPara.pRNG = 40;    --period for hilo range
    oPara.pCY2 = 20;    --20 
    oPara.pCY3 = 30;    --30 
    oPara.pCY5 = 50;    --50     
    oPara.pCY6 = 60;    --60 
    oPara.pCY7 = 120;   --120
    oPara.pCY8 = 200;   --200    
    oPara.pNCP = 4;     --lookback check      
    if     oPara.pTYP == 1 or oPara.pTYP == 2 then
        if sourcep:barSize() == "D1" 
        then oPara.pXR1 = 1.0; oPara.pXR4 = 2.0; oPara.pDVL = 1.5; oPara.pNVC = 6; oPara.pNPK = 2; oPara.pMRB = 2.0;  
        else oPara.pXR1 = 2.0; oPara.pXR4 = 3.0; oPara.pDVL = 2.5; oPara.pNVC = 8; oPara.pNPK = 4; oPara.pMRB = 2.0;   
        end
        if oPara.pNBK == 0 then oPara.pNB2 = 20; end
        if oPara.pNB2 <= 20 then oPara.pNB1 = 10; oPara.pNB3 = 34;
        elseif oPara.pNB2 <= 40 then oPara.pNB1 = 20; oPara.pNB3 = 50; 
        elseif oPara.pNB2 <=120 then oPara.pNB1 = 60; oPara.pNB3 =200; 
        else oPara.pNB1 = 60; oPara.pNB3 = 240; end
        oPara.pSW7 = 0.7;        
        oPara.pNVC = 8;     --peak check      
    elseif oPara.pTYP == 3 then
        if oPara.pNBK == 0 then
            if string.sub(sourcep:barSize(),1,1)=="M" then oPara.pNBK = 9; end
            if string.sub(sourcep:barSize(),1,1)=="W" then oPara.pNBK = 12; end
            if string.sub(sourcep:barSize(),1,1)=="D" then oPara.pNBK = 14; end 
            if string.sub(sourcep:barSize(),1,1)=="H" then
                if sourcep:barSize()=="H1" or sourcep:barSize()=="H2" then  
                    oPara.pNBK = 30; else oPara.pNBK = 20; end
            end
            if string.sub(sourcep:barSize(),1,1)=="m" then oPara.pNBK = 30; end
        end
    else if oPara.pNBK == 0 then oPara.pNBK = 20; end

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
function CalcSna(mPeriod, preSna, sourcep, speriod)
    local sna = preSna;
    local sLeng = math.min(mPeriod*5 - 1, speriod);
    local sBase = 0;
    local sSumy = 0;
    local tens = 0;
    local alpha = 0;

    for i = 0, sLeng-1, 1 do
        alpha= Iif(tens <= 0.5, 1, 1.0/(3.0*math.pi*tens + 1.0)) * math.cos(math.pi*tens);
        sSumy = sSumy + alpha*sourcep[speriod-i];
        sBase = sBase + alpha;
        --recalc in the rear
        if tens < 1 then tens = tens + 1.0/(mPeriod-2);
        elseif tens < sLeng-1 then tens = tens + 7.0/(4.0*mPeriod - 1); end
    end
    if sBase > 0 then sna = sSumy/sBase; end
    
    return sna;
end

function CalcRgs(rPeriod, shtpos, sourcep, speriod)
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

    return b1*pos2+b0, b1*pos1+b0;
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
function CalcLineDir(nmod, prng, base, sline, speriod)
    local ndir = 0;
    local npkm = base;
    if     nmod == 1 then
        prng = math.min(prng, speriod);
        --depend on strm1
        ndir = sline[speriod] - sline[speriod-prng];   
    elseif nmod == 2 then
        ndir = Iif(sline[speriod]-base < 0, -1, 1);   
    elseif nmod == 3 then
        local thism = sline;    --sline as single value
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
function CalcPushDir(ndir, m1btm, m1top, m2btm, m2top, sourcep, speriod)
    if (ndir==-1 and sourcep.low [speriod]-m1btm > 0) or (ndir== 1 and sourcep.high[speriod]-m1top < 0) 
    or (ndir <-1 and m1btm-m2btm > 0) or (ndir > 1 and m1top-m2top < 0) then ndir = 0; end
    if m1btm-m2btm < 0 and sourcep.low [speriod]-m2btm < 0 then ndir =-3; end   
    if m1top-m2top > 0 and sourcep.high[speriod]-m2top > 0 then ndir = 3; end   
    if ndir >-1 and sourcep.high[speriod]-m1btm < 0 then ndir =-1; end  --reverse overwrite extreme out
    if ndir < 1 and sourcep.low [speriod]-m1top > 0 then ndir = 1; end
    return ndir;
end
function CalcSineSkip(PRA, SRS, speriod)
    local sndir = PRA.sndir;    --Skip shift
    local snpos = Iif(math.abs(PRA.snpos)==1, 0, PRA.snpos);
    local pcyc = oPara.pNB2;    
    local pswl = oPara.pSW7;
    local pnvc = oPara.pNVC;
    local pnpk = oPara.pNPK;    
    --identify cycle
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
function CalcActFast(PRA, SRS, speriod)
    local avrng = PRA.avrng;    --
    local afdir, afpos, afval, afpkk; 
    local pnb2 = oPara.pNB2;
    local prng = avrng*oPara.pTCL;
    local pbuf = avrng*oPara.pCHK;
    afdir = PRA.afdir;
    afpos = PRA.afpos;
    afpkk = PRA.afpkk;
    local afpre = PRA.reg[speriod-1] + prng*PRA.led[speriod-1];
    
    PRA.reg[speriod] = CalcRgs(pnb2, 0, SRS.close, speriod);
    PRA.sin[speriod], PRA.led[speriod] = CalcCsw(pnb2, SRS, speriod);
    --calc fast value base on led
    afval = PRA.reg[speriod] + prng*PRA.led[speriod];
    if PRA.sndir == 0 then 
        if     afpkk == nil or afpkk == 0 then afpkk = afval;
        elseif math.abs(PRA.snpos) == 1 then afpkk = afpre * PRA.snpos;
        elseif (afval-math.abs(afpkk))*afpkk > 0 or math.abs(afval-math.abs(afpkk)) > pbuf 
        then afdir = Iif(afval-math.abs(afpkk)<0,-1, 1); afpkk = afval*afdir; 
        end
    else afdir = PRA.sndir; 
    end    
    if afdir*PRA.afdir < 0 then afpos = Iif(afdir < 0,-speriod, speriod); end

    return afdir, afpos, afval, afpkk;  
end
function CalcActSlow(PRA, SRS, speriod)
    local asdir = PRA.asdir;
    local amdir = PRA.amdir;
    local ampos = PRA.ampos;
    local mslvl = PRA.avrng * 0.2;   --multiplier of ma slope  
    local pnb1 = oPara.pNB1;
    local pnb2 = oPara.pNB2;
    local pnb3 = oPara.pNB3;
    local pna2 = oPara.pNB3/2;
    local pns3 = math.floor(math.min(20, math.max(4, pnb1/3)));
    local pncp = oPara.pNCP;
    local pnpk = oPara.pNPK;    
    local pdvl = oPara.pDVL;
    local pxr1 = oPara.pXR1;
    local pxr4 = oPara.pXR4;
    PRA.ra2[speriod] = CalcRgs(pna2, 0, SRS.close, speriod);
    PRA.ma1[speriod] = CalcSma(pnb1, 0, SRS.close, speriod);
    PRA.ma2[speriod] = CalcSma(pnb2, 0, SRS.close, speriod);
    PRA.ma3[speriod] = CalcSma(pnb3, 0, SRS.close, speriod);
    PRA.m1dev = CalcStd(pnb1, SRS.close, speriod);
    PRA.m2dev = CalcStd(pnb2, SRS.close, speriod);
    PRA.m3dev = CalcStd(pnb3, SRS.close, speriod);
    PRA.m1btm, PRA.m1top = PRA.ma1[speriod]-PRA.m1dev*2, PRA.ma1[speriod]+PRA.m1dev*2;
    PRA.m2btm, PRA.m2top = PRA.ma2[speriod]-PRA.m2dev*2, PRA.ma2[speriod]+PRA.m2dev*2;
    PRA.m3btm, PRA.m3top = PRA.ma3[speriod]-PRA.m3dev*2, PRA.ma3[speriod]+PRA.m3dev*2;
    PRA.std[speriod] = PRA.m2dev;
    local asval = CalcRgs(pnb1, 0, SRS.close, speriod);  
    local a3val = PRA.a3val; 
    local a3pre = a3val;

    PRA.psdir = CalcPushDir(PRA.psdir, PRA.m1btm, PRA.m1top, PRA.m3btm, PRA.m3top, SRS, speriod)
    PRA.mcbtm = CalcEma(pns3, PRA.mcbtm, Iif(PRA.psmod==1, PRA.m1btm, PRA.m3btm));
    PRA.mctop = CalcEma(pns3, PRA.mctop, Iif(PRA.psmod==1, PRA.m1top, PRA.m3top));
    if PRA.m2dev/PRA.avrng > pxr4 and PRA.avrng/GetAvgRange(oPara.pRNG, SRS, speriod-pnb3) > pxr1 then PRA.psmod = 4; 
    else PRA.psmod = Iif((math.abs(amdir)<2 and speriod-math.abs(ampos)<pnb2) 
    or (asdir*amdir<0 and speriod-math.abs(ampos)>pnb2) or math.abs(PRA.psdir)==1, 1, Iif(PRA.psdir==0, 2, 3)); end

    if     PRA.psmod == 4 then
        if speriod - GetPivot(1, pnpk, pnpk, PRA.std, speriod) == pnpk then a3val = Iif(asval-PRA.ma2[speriod]>0, PRA.mctop, PRA.mcbtm); end
    elseif speriod+PRA.snpos == 0 and PRA.sndir ==-3 and PRA.ma2[speriod]-PRA.ma2[speriod-pncp*2]<-mslvl then a3val = PRA.mctop;   --set for reverse immediately
    elseif speriod-PRA.snpos == 0 and PRA.sndir == 3 and PRA.ma2[speriod]-PRA.ma2[speriod-pncp*2]> mslvl then a3val = PRA.mcbtm; 
    elseif amdir < 0 then a3val = Iif(PRA.psdir > 0 or PRA.ma3[speriod]-PRA.ma3[speriod-pncp] > 0 or asdir > 0, math.min(a3pre, PRA.mctop), PRA.mctop); 
    elseif amdir > 0 then a3val = Iif(PRA.psdir < 0 or PRA.ma3[speriod]-PRA.ma3[speriod-pncp] < 0 or asdir < 0, math.max(a3pre, PRA.mcbtm), PRA.mcbtm); 
    end

    --check reverse
    if(PRA.amdir)*(asval-a3val)<=0 then
        amdir = (asval-a3val)/math.abs(asval-a3val) * Iif(speriod-math.abs(ampos)>pnb2, 1, 2);    
        ampos = Iif(amdir<0,-speriod, speriod);      
    end
    if     PRA.psmod == 4 or (PRA.ra2[speriod]-PRA.ma2[speriod])*amdir > 0 or PRA.m2dev/PRA.avrng > pdvl then asdir = amdir;
    elseif asdir > 0 and SRS.low [speriod]-PRA.m2btm < 0 and SRS.high[speriod]-PRA.m2top < 0 then asdir =-1;  
    elseif asdir < 0 and SRS.high[speriod]-PRA.m2top > 0 and SRS.low [speriod]-PRA.m2btm > 0 then asdir = 1; end 
    
    return asdir, amdir, ampos, a3val;
end

function CalcATL(rPeriod, UTL, DTL, PVL, sourcep, speriod)
    rPeriod = math.min(rPeriod, speriod);
    local ZZW = core.makeArray(speriod+1);
    local pfr = 0;
    local pto = 0;
    local pos1 = 0;
    local pos2 = 0;
    local sourcehl, sourceoppt;
    local slopechn = 0;
    local slopepvt = 0;
    local posc = 0;
    local updn = 0;
    local lastud = 0;
    local prevfr = 0;

    for i=sourcep.open:first(), speriod do UTL[i]=nil; DTL[i]=nil; PVL[i]=nil; end
    --redefine 
    SetZZP(rPeriod, ZZW, sourcep);
    pfr, pto, updn = GetLastWave(1, ZZW, speriod);
    
    for i = 1, 2 do
        updn = updn * -1;
        pfr, pto, lastud = GetLastWave(updn, ZZW, speriod);
        if updn ~= lastud then prevfr = pfr; end
        if pto - pfr > 5 then
            if updn < 0 then
                sourcehl = sourcep.high;
                sourceoppt = sourcep.low;
            else
                sourcehl = sourcep.low;
                sourceoppt = sourcep.high;
            end
            pos1, pos2 = GetPeakPos(2, updn*-1, pfr, pto, sourcehl);
            
            if updn < 0 then
                core.drawLine(DTL, core.range(pos1, speriod), sourcehl[pos1], pos1, sourcehl[pos2], pos2);
                if updn == lastud then 
                    core.drawLine(PVL, core.range(pfr, speriod), sourcehl[pfr]+slopepvt, pfr-1, sourcehl[pfr], pfr);
                else slopepvt = (sourcehl[pos2]-sourcehl[pos1])/(pos2-pos1); end
                if pto - pfr > rPeriod * 1.5 and lastud == updn then
                    if prevfr > 0 then for i=prevfr, pos1 do UTL[i]=nil end end
                    slopechn = (sourcehl[pos2]-sourcehl[pos1])/(pos2-pos1);
                    posc = GetPeakPos(1, updn, pfr, pos2, sourceoppt);
                    core.drawLine(UTL, core.range(pos1, speriod), sourceoppt[posc]-slopechn, posc-1, sourceoppt[posc], posc);
                end
            else
                core.drawLine(UTL, core.range(pos1, speriod), sourcehl[pos1], pos1, sourcehl[pos2], pos2);
                if updn == lastud then 
                    core.drawLine(PVL, core.range(pfr, speriod), sourcehl[pfr]+slopepvt, pfr-1, sourcehl[pfr], pfr);
                else slopepvt = (sourcehl[pos2]-sourcehl[pos1])/(pos2-pos1); end

                if pto - pfr > rPeriod * 1.5 and lastud == updn then
                    if prevfr > 0 then for i=prevfr, pos1 do DTL[i]=nil end end
                    slopechn = (sourcehl[pos2]-sourcehl[pos1])/(pos2-pos1);
                    posc = GetPeakPos(1, updn, pfr, pos2, sourceoppt);
                    core.drawLine(DTL, core.range(pos1, speriod), sourceoppt[posc]-slopechn, posc-1, sourceoppt[posc], posc);
                end
            end
        end
    end
    return prevfr;
end
function SetZZP(lengthp, ZZP, sourcep)
    -- variable for ZZP
    local zinfo = {};
    local srcforw;
    local srcback;
    local srcfirst = sourcep.open:first();
    local srclast = sourcep.open:size() - 1;
    
    for speriod = srcfirst, srclast do
        if speriod == srcfirst then
            zinfo.rangev = core.max(sourcep.high, core.range(srcfirst, srclast)) 
                            - core.min(sourcep.low, core.range(srcfirst, srclast));
            zinfo.zback = zinfo.rangev / 100 * math.sqrt(lengthp) * 2;

            zinfo.searchhl = 1;
            srcforw = sourcep.high;
            srcback = sourcep.low;
            zinfo.newVal = sourcep.close[srcfirst];
            zinfo.newPos = srcfirst;
            zinfo.preVal = zinfo.newVal;
            zinfo.prePos = srcfirst;
        end
        if (srcforw[speriod]-zinfo.newVal)*zinfo.searchhl > 0 then
            zinfo.newVal = srcforw[speriod];
            zinfo.newPos = speriod;
        end
        --turn
        if ( (speriod-zinfo.newPos >= lengthp) and (srcback[speriod]-zinfo.newVal)*zinfo.searchhl*-1 > zinfo.zback )
        or ( (srcback[speriod]-zinfo.preVal)*zinfo.searchhl < 0 ) then
            ZZP[zinfo.newPos] = zinfo.newVal;
            zinfo.preVal = zinfo.newVal;
            zinfo.prePos = zinfo.newPos;
            zinfo.searchhl = zinfo.searchhl * -1;
            
            if zinfo.searchhl > 0 then
                if speriod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos+2, speriod)); end
                srcforw = sourcep.high;
                srcback = sourcep.low;
            elseif zinfo.searchhl < 0 then
                if speriod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos+2, speriod)); end
                srcforw = sourcep.low;
                srcback = sourcep.high;
            end
        end

        if (speriod == srclast) then    
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
            
            if zinfo.searchhl*-1>0 and speriod-zinfo.prePos>3 then
                zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos, speriod));
            elseif zinfo.searchhl*-1<0 and speriod-zinfo.prePos>3 then
                zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos, speriod));
            end
            if (zinfo.newVal-zinfo.preVal)*zinfo.searchhl*-1  > zinfo.lastback then
                ZZP[zinfo.newPos] = zinfo.newVal;
            end
        end
    end
end
--find the wave begin end
function GetLastWave(updown, ZZP, srclast)
    local peaka = {0,0,0};  --serial 123
    local markback = 3;
    local peakb, peake;
    local lastupdn = 0;
    
    for i = srclast, 1, -1 do
        if ZZP[i] > 0 then
	        peaka[markback] = i;
	        markback = markback - 1;
        end
        if markback < 1 then
            break;
        end
    end
    if (ZZP[peaka[3]]-ZZP[peaka[2]]) < 0 then
        lastupdn = -1;
    else
        lastupdn = 1;
    end 
    if (lastupdn) * updown < 0 then
        peakb = peaka[1];
        peake = peaka[2];
    else
        peakb = peaka[2];
        peake = peaka[3];
    end 
    if peakb < 0 then peakb = 0 end	
    if peake > srclast then peake = srclast end
    
	return peakb, peake, lastupdn;
end
function GetPeakPos(find, tpbm, pos1, pos2, sourcep)
    local PVW = core.makeArray(pos2+1);
    local value1 = 0;
    local value2 = 0;
    local lreg = 0;
    local oPeak = {};
    
    value2, value1 = CalcRgs(pos2-pos1, 0, sourcep, pos2);
    for i = pos1, pos2 do
        lreg = value1 + ((value2-value1)/(pos2-pos1))*(i-pos1);
        PVW[i] = sourcep[i] - lreg;
    end
    oPeak.span = math.floor((pos2-pos1)/4);
    if tpbm < 0 then
        if find == 1 then
            oPeak.pv1, oPeak.peak1 = GetMin(PVW, pos1, pos2);
            oPeak.peak3 = pos2;
        end
        if find == 2 then
            if pos2 - pos1 > 8 then
                oPeak.pv1, oPeak.peak1 = GetMin(PVW, pos1, pos1+oPeak.span*1);
                oPeak.pv2, oPeak.peak2 = GetMin(PVW, pos1+oPeak.span*1+1, pos1+oPeak.span*2);
                oPeak.pv3, oPeak.peak3 = GetMin(PVW, pos1+oPeak.span*2+1, pos1+oPeak.span*3);
                oPeak.pv4, oPeak.peak4 = GetMin(PVW, pos1+oPeak.span*3+1, pos2);
                if (oPeak.pv1>oPeak.pv2) then oPeak.peak1, oPeak.peak2 = oPeak.peak2, oPeak.peak1; end
                if (oPeak.pv3>oPeak.pv4) then oPeak.peak3, oPeak.peak4 = oPeak.peak4, oPeak.peak3; end
                if oPeak.peak3 - oPeak.peak1 < oPeak.span then    
                    if oPeak.peak4 - oPeak.peak3 > oPeak.peak3 - oPeak.peak1 then
                        if (PVW[oPeak.peak1]>PVW[oPeak.peak3]) then oPeak.peak1, oPeak.peak3 = oPeak.peak3, oPeak.peak1; end
                        oPeak.peak3 = oPeak.peak4;    
                    end
                end
            else
                oPeak.pv1, oPeak.peak1 = GetMin(PVW, pos1, pos1+oPeak.span*2);
                oPeak.pv3, oPeak.peak3 = GetMin(PVW, pos1+oPeak.span*2+1, pos2);
            end
        end
    else
        if find == 1 then
            oPeak.pv1, oPeak.peak1 = GetMax(PVW, pos1, pos2);
            oPeak.peak3 = pos2;
        end
        if find == 2 then
            if pos2 - pos1 > 8 then
                oPeak.pv1, oPeak.peak1 = GetMax(PVW, pos1, pos1+oPeak.span*1);
                oPeak.pv2, oPeak.peak2 = GetMax(PVW, pos1+oPeak.span*1+1, pos1+oPeak.span*2);
                oPeak.pv3, oPeak.peak3 = GetMax(PVW, pos1+oPeak.span*2+1, pos1+oPeak.span*3);
                oPeak.pv4, oPeak.peak4 = GetMax(PVW, pos1+oPeak.span*3+1, pos2);
                if (oPeak.pv1<oPeak.pv2) then oPeak.peak1, oPeak.peak2 = oPeak.peak2, oPeak.peak1; end
                if (oPeak.pv3<oPeak.pv4) then oPeak.peak3, oPeak.peak4 = oPeak.peak4, oPeak.peak3; end
                if oPeak.peak3 - oPeak.peak1 < oPeak.span then
                    if oPeak.peak4 - oPeak.peak3 > oPeak.peak3 - oPeak.peak1 then
                        if (PVW[oPeak.peak1]<PVW[oPeak.peak3]) then oPeak.peak1, oPeak.peak3 = oPeak.peak3, oPeak.peak1; end
                        oPeak.peak3 = oPeak.peak4;
                    end
                end
            else
                oPeak.pv1, oPeak.peak1 = GetMax(PVW, pos1, pos1+oPeak.span*2);
                oPeak.pv3, oPeak.peak3 = GetMax(PVW, pos1+oPeak.span*2+1, pos2);
            end
        end
    end
   
	return oPeak.peak1, oPeak.peak3;
end
function GetMax(stream, posfr, posto)
    local maxv = stream[posfr];
    local maxp = posfr;
    for i = posfr, posto do
        if stream[i] > maxv then maxv=stream[i]; maxp=i end
    end
    return maxv, maxp;
end
function GetMin(stream, posfr, posto)
    local minv = stream[posfr];
    local minp = posfr;
    for i = posfr, posto do
        if stream[i] < minv then minv=stream[i]; minp=i end
    end
    return minv, minp;
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
