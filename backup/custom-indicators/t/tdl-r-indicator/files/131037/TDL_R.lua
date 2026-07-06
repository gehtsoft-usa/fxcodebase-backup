-- The indicator is Richard Tao Directional Line
-- A: active; B: base
-- A: smooth liner regression; B: liner regression look back begin
-- N: liner regression look back; C: liner regression look back begin shift position 

function Init()
    indicator:name("RichardTaoDirectionalLine_regress");
    indicator:description("TechnicalAnalysisOffice tool for momentum trader");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addInteger("N", "Look back", "", 0, 0, 1000);
    indicator.parameters:addDouble("C", "check", "", 0.0, -1000.0, 1000);
   
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
    indicator.parameters:addColor("clrH", "Hazel", "", core.rgb(224, 128, 128));
    indicator.parameters:addColor("clrS", "Sliver", "", core.rgb(224, 208, 208));
    indicator.parameters:addColor("clrM", "Magenta", "", core.rgb(255, 32, 224));
    indicator.parameters:addColor("clrL", "Lavender", "", core.rgb(240, 160, 255));
    indicator.parameters:addColor("clrD", "Dark", "", core.rgb(96, 96, 96));
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
    local name = profile:id() .. "(" .. instance.parameters.N .. ", " .. instance.parameters.C .. ")";
    instance:name(name);

    oPara.pTTF = source:barSize();      --set barsize
    oPara.pIND = true;
    oPara.pTHS = true;
    loaded = 1; toload = 1; SRC[1] = source;
    --set begin end
    oPara.pBGN = 0;    --source begin point
    oPara.pEND = 10000;
    --the last strength calculate begin as the original point  
    oPara.pSBG = 5000; 
    --set control
    local i = 1;
        PRP[i] = {};
        PRP[i].savut = 0;   --atr
        PRP[i].sunit = 0;   --atr
        PRP[i].sperd = 0;   --speriod
        PRP[i].funit = 0;   --fast atr
        PRP[i].fsema = 0;   --fast ema
        PRP[i].lstfr = 0;   --last from position
        PRP[i].rslvl = 0;   --reverse level
        PRP[i].lnclr = 0;   --color
        
        --fast slow regression
        PRP[i].m1dir = 0;   --primary regression direction
        PRP[i].m1rev = 0;   --reverse direction
        PRP[i].m1slp = 0;   --regression slope
        PRP[i].m1btm = 0;   --envelope of bottom
        PRP[i].m1top = 0;   --envelope of top
        PRP[i].m1rvp = 0;   --reverse position
        PRP[i].m2dir = 0;   --primary regression direction
        PRP[i].m2rev = 0;   --reverse direction
        PRP[i].m2slp = 0;   --regression slope
        PRP[i].m2btm = 0;   --envelope of bottom
        PRP[i].m2top = 0;   --envelope of top
        PRP[i].m2rvp = 0;   --reverse position
        --flat 
        PRP[i].fipos = 0;   --the box flat in position 
        PRP[i].fopos = 0;   --the box flat out position 
        PRP[i].ftbtm = 0;   --the flat bottom 
        PRP[i].fttop = 0;   --the flat top
        --activity
        PRP[i].atrnd = 0;   --activity trend mode
        PRP[i].atpos = 0;   --activity trend position
        PRP[i].moema = 0;   --momentum ma
        PRP[i].mosma = 0;   --momentum ma
        PRP[i].modir = 0;   --momentum flag
        PRP[i].mopos = 0;   --momentum slow in position 
        PRP[i].mfpos = 0;   --momentum flat in position 
        PRP[i].bfdir = 0;   --box flat effective
        PRP[i].efpos = 0;   --extreme fast position with direction
        PRP[i].expos = 0;   --extreme position
        PRP[i].bxpos = 0;   --bias position
        --wave
        PRP[i].ledw1 = 0;   --led wave
        PRP[i].sinw1 = 0;   --sin wave
        PRP[i].ledw2 = 0;   --led wave
        PRP[i].sinw2 = 0;   --sin wave
        
        --stream
        PRP[i].ln1 = instance:addInternalStream(0, 0);    
        PRP[i].ln2 = instance:addInternalStream(0, 0);    
        PRP[i].reg = instance:addInternalStream(0, 0);    
        PRP[i].pvl = instance:addInternalStream(0, 0);    
        PRP[i].sin = instance:addInternalStream(0, 0);
        PRP[i].led = instance:addInternalStream(0, 0);

    --set parameter
    SetParameter(oPara, source, period);

    if oPara.pIND and oPara.pTHS then
        PRP[1].ln1 = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrC, 0); 
        PRP[1].ln2 = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrG, 0); 
        PRP[1].ln1:setStyle(instance.parameters.LN_style);
        PRP[1].ln1:setWidth(instance.parameters.LN_width);
        PRP[1].ln2:setStyle(instance.parameters.LN_style);
        PRP[1].ln2:setWidth(instance.parameters.LN_width);
    else
    end
    
end                                                                 

-- Indicator calculation routine
function Update(period, mode)
    iperiod = period - 1; 
    
    --redefind the calculate range
    oPara.pEND = source:size()-1;      
    oPara.pBGN = math.max(oPara.pEND-oPara.pSBG, oPara.pRNG, oPara.pNBK);
    if loaded == toload and lastbar ~= source:serial(iperiod) 
    and iperiod > oPara.pBGN then
        local PRA = PRP[1]; --current properties
        local SRS = SRC[1]; --current sources
        local speriod = iperiod;  --redefine period form original
        local c = 1;    --counter
        --reset lastbar at first
        lastbar = source:serial(iperiod);
        
        PRA = PRP[c]; 
        SRS = SRC[c]; 
        PRA.sperd = iperiod;
        PRA.savut = GetAvgRange(oPara.pRNG, SRS, PRA.sperd-1);
        PRA.sunit = CalcEma(oPara.pRNG, PRA.sunit, PRA.savut);
        speriod = PRA.sperd;  
        if speriod > oPara.pNBK then
        PRA.funit = GetAvgRange(math.floor(oPara.pRNG/8), SRS, speriod);
        PRA.ln1[iperiod], PRA.ln2[iperiod] = CalcRgs(oPara.pNBK, math.floor(oPara.pNBK/10), SRS.close, speriod);
        PRA.ln1:setColor(iperiod, Iif(PRA.ln1[iperiod]-PRA.ln2[iperiod-oPara.pCHK]<0, instance.parameters.clrM, instance.parameters.clrC));
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
    oPara.pCHK = instance.parameters.C;
        --oPara.pNBK = 60, 100
    
    oPara.pTYP = 4;     
    
    oPara.pRNG = 40;    --period for hilo range
end
    
function TransTFnumber(timeFrame)
    --get timeframe to number
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
function CalcSma(mPeriod, oripos, sourcep, iperiod)
    if oripos == 0 then mPeriod = math.min(iperiod, mPeriod);
    else mPeriod = math.max(iperiod-oripos, 1); end
    local newSma = mathex.avg(sourcep, core.rangeTo(iperiod, mPeriod));
    return newSma;
end
function CalcSna(mPeriod, thres, preSna, sunit, sourcep, iperiod)
    local sna = preSna;
    local sLeng = math.min(mPeriod*5 - 1, iperiod);
    local sWght = 0;
    local sSumy = 0;
    local tens = 0;
    local cohes = 0;
    local beta = 0;
    local alpha = 0;
    local devi = 0;

    for i=0, sLeng-1, 1 do
        if tens <= 0.5 then cohes = 1; else cohes = 1./(3.*math.pi*tens + 1.); end
        beta = math.cos(math.pi*tens);
        alpha= cohes * beta;
        sSumy = sSumy + alpha*sourcep[iperiod-i];
        sWght = sWght + alpha;
        
        if tens < 1 then tens = tens + 1./(mPeriod-2);
        elseif tens < sLeng-1 then tens = tens + 7./(4.*mPeriod-1); end
    end
    --check if enough to set value
    if sWght > 0 then
        if sunit == nil or sunit == 0 then sunit = math.abs(sourcep[iperiod]-sourcep[iperiod-10]); end
        if math.abs((1.+devi/100.)*sSumy/sWght-preSna) > thres*sunit then sna = (1.+devi/100.)*sSumy/sWght; end
    end
    
    return sna;
end

function CalcRgs(rPeriod, shtpos, sourcep, iperiod)
    local offpos = 0;
    local pos1 = math.max(0, iperiod-rPeriod+offpos);
    local pos2 = iperiod;
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
function GetAvgRange(rng, sourcep, iperiod)
    rng = math.min(iperiod, rng);
    local ahi = mathex.avg(sourcep.high, core.rangeTo(iperiod, rng));
    local alo = mathex.avg(sourcep.low, core.rangeTo(iperiod, rng));
    return ahi-alo;
end
function GetSperiod(sources, sourcep, iperiod)
    local ifr = math.max(iperiod-20, sources:first());
    local ito = math.min(iperiod+2, sources:size()-1);
    local speriod = 0;
    for i = ito, ifr, -1 do
        if sources:date(i) <= sourcep:date(iperiod) then 
            speriod = i; break; end
    end
    return speriod;
end
function GetPivot(fdhl, nleft, nrght, sourcep, iperiod)
    local pos = 0;
    local pvl = 0;
    local fnd = true;
    local nfr = math.max(iperiod-(nleft+nrght)*2, nleft);
    local shilo
    if sourcep.low ~= nil then
        if fdhl < 0 then shilo = sourcep.low; else shilo = sourcep.high; end
    else shilo = sourcep; end
    for i = iperiod-nrght, nfr, -1 do
        fnd = true;
        for j = 1, nleft do if (shilo[i]-shilo[i-j])*fdhl < 0 then fnd = false; end end
        for j = 1, nrght do if (shilo[i]-shilo[i+j])*fdhl < 0 then fnd = false; end end
        if fnd and (shilo[i]-shilo[iperiod])*fdhl > 0 then pos = i; pvl = shilo[i]; break; end
    end
    return pos, pvl;
end
