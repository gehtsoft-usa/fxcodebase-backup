-- The indicator is Richard Tao Activity for Options
-- Technical Analysis Office simple tool for swing/options trader 

function Init()
    indicator:name("RichardTaoActivityOptions");
    indicator:description("TechnicalAnalysisOffice tool for swing/options trader");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addInteger("N", "Look back", "", 0, 0, 1000);
    indicator.parameters:addDouble("L", "WeekRange lookback", "", 20, -1000.0, 1000);
    indicator.parameters:addGroup("IMode");
    indicator.parameters:addBoolean("ShowIC", "Show Iron Condor", "", true);   
    indicator.parameters:addBoolean("ShowCS", "Show Credit Spread", "", true);   
    indicator.parameters:addBoolean("ShowSN", "Show Synthetic", "", true);   
    indicator.parameters:addBoolean("ShowHV", "Show Week Range", "", true);   
    indicator.parameters:addBoolean("ShowCL", "Show Calendar", "", true);   
    indicator.parameters:addInteger("W", "Weekday project", "", 6);
        indicator.parameters:addIntegerAlternative("W", "Monday", "", 2);
        indicator.parameters:addIntegerAlternative("W", "Tuesday", "", 3);
        indicator.parameters:addIntegerAlternative("W", "Wednesday", "", 4);
        indicator.parameters:addIntegerAlternative("W", "Thursday", "", 5);
        indicator.parameters:addIntegerAlternative("W", "Friday", "", 6);
   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrR", "Red", "", core.rgb(255, 0, 128));
    indicator.parameters:addColor("clrO", "Orange", "", core.rgb(255, 208, 64));
    indicator.parameters:addColor("clrY", "Yellow", "", core.rgb(255, 250, 0));
    indicator.parameters:addColor("clrG", "Green", "", core.rgb(0, 224, 0));
    indicator.parameters:addColor("clrB", "Blue", "", core.rgb(0, 128, 255));
    indicator.parameters:addColor("clrC", "Cyan", "", core.rgb(0, 255, 224));
    indicator.parameters:addColor("clrP", "Purple", "", core.rgb(192, 0, 192));
    indicator.parameters:addColor("clrS", "Sliver", "", core.rgb(240, 240, 240));
    indicator.parameters:addColor("clrF", "Fuchsia", "", core.rgb(255, 64, 240));
    indicator.parameters:addColor("clrI", "Lime", "", core.rgb(144, 255, 144));
    indicator.parameters:addColor("clrL", "Lavender", "", core.rgb(240, 192, 255));
    indicator.parameters:addColor("clrM", "Maroon", "", core.rgb(212, 0, 0));
    indicator.parameters:addColor("clrN", "Navy", "", core.rgb(0, 0, 192));
    indicator.parameters:addColor("clrD", "DarkRed", "", core.rgb(224, 0, 0));
    indicator.parameters:addColor("clrU", "Royal", "", core.rgb(0, 0, 208));
end

local source = nil;
local SRC = {};     --multiple source
local SIN = {};     --multiple instrument
local PRP = {};     --multiple parameter position control

local oIndi = {};
local oPara = {};
--for outstream
local FLG = nil;    --singal of single mode
local PRJ = nil;    --project of single mode
--for outsignal
local EVT = {};     --multiple event 
local LVT = {};     --multiple entry level
--multiple event/entry name
local EVN = {"E01","E02","E03","E04","E05","E06","E07","E08","E09","E10"
            ,"E11","E12","E13","E14","E15","E16","E17","E18","E19","E20"
            ,"E21","E22","E23","E24","E25","E26","E27","E28","E29","E30"};     
--multiple level name
local LVN = {"L01","L02","L03","L04","L05","L06","L07","L08","L09","L10"
            ,"L11","L12","L13","L14","L15","L16","L17","L18","L19","L20"
            ,"L21","L22","L23","L24","L25","L26","L27","L28","L29","L30"};

--async load
local onload = false;
local toload = 1;
local loaded = 1;
local lastbar = nil;
local iperiod;

-- Routine
function Prepare()
    source = instance.source;
    local name = profile:id() .. "(" .. instance.parameters.N .. ")";
    instance:name(name);

    oPara.pTTF = source:barSize();      --set barsize
    oPara.pIND = true;
    oPara.pINS = "";
    if oPara.pINS == "" then oPara.pTHS = true; else oPara.pTHS = false; end
    if oPara.pTHS then SIN[0], toload = source:instrument(), 1; 
    else SIN, toload = core.parseCsv(oPara.pINS, ","); end
    oPara.pBGN = 0;    --source begin point
    oPara.pEND = 10000;
    if oPara.pIND then oPara.pSBG = 5000; else oPara.pSBG = 250; end
    --set control
    for i = 1, toload do
        PRP[i] = {};
        PRP[i].ccyn1 = string.sub(SIN[i-1], 1, 3);   
        PRP[i].ccyn2 = string.sub(SIN[i-1], 5, 7);   
        PRP[i].avrng = 0;   --atr
        PRP[i].sperd = 0;   --speriod
        PRP[i].pipsz = 0;   --pipsize
        --historic daily
        PRP[i].date = instance:addInternalStream(0, 0); --day
        PRP[i].open = instance:addInternalStream(0, 0); --day open
        PRP[i].high = instance:addInternalStream(0, 0); --day high
        PRP[i].low  = instance:addInternalStream(0, 0);  --day low
        PRP[i].close = instance:addInternalStream(0, 0);--day close
        --stream
        PRP[i].rg1 = instance:addInternalStream(0, 0);    
        PRP[i].rg2 = instance:addInternalStream(0, 0);    
        PRP[i].ma1 = instance:addInternalStream(0, 0);    
        PRP[i].ma2 = instance:addInternalStream(0, 0);    
        PRP[i].ma3 = instance:addInternalStream(0, 0);    
        PRP[i].ra2 = instance:addInternalStream(0, 0);    
        PRP[i].avr = instance:addInternalStream(0, 0);
        PRP[i].std = instance:addInternalStream(0, 0);
        PRP[i].rgc = instance:addInternalStream(0, 0);    
        PRP[i].pcc = instance:addInternalStream(0, 0);    
        PRP[i].rsl = instance:addInternalStream(0, 0);  --resistance level    
        PRP[i].top = instance:addInternalStream(0, 0);    
        PRP[i].btm = instance:addInternalStream(0, 0);    
        PRP[i].sin = instance:addInternalStream(0, 0);
        PRP[i].led = instance:addInternalStream(0, 0);
        PRP[i].sn1 = instance:addInternalStream(0, 0);
        --volatility, 
        PRP[i].art = instance:addInternalStream(0, oPara.pEXT);    
        PRP[i].arb = instance:addInternalStream(0, oPara.pEXT);    
        PRP[i].drt = instance:addInternalStream(0, oPara.pEXT);    
        PRP[i].drb = instance:addInternalStream(0, oPara.pEXT);    
        
        --strategy
        PRP[i].stdir = 0;   --strategy direction
        PRP[i].stpos = 0;   --start position of strategy
        PRP[i].stval = 0;   --value of strategy filled without direction
        PRP[i].stlmt = 0;   --limit of strategy
        PRP[i].ststp = 0;   --stop of strategy
        PRP[i].token = 0;   --the token 
        PRP[i].toval = 0;   --the value of entry with direction
        PRP[i].topos = 0;   --start position of token
    end

    --set parameter
    SetParameter(oPara, source, period);

    if oPara.pIND and oPara.pTHS then 
        if oPara.pFIC then
            --show cloud 
            instance:createChannelGroup("I", "I", PRP[1].top, PRP[1].btm, instance.parameters.clrY, 15);
        end
        if oPara.pFCS then
            PRP[1].rsl = instance:addStream("R", core.Line, name .. ".R", "R", instance.parameters.clrG, 0, oPara.pEXT);
            PRP[1].rsl:setWidth(3);
        end
        if oPara.pFHV then
            PRP[1].art = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clrG, 0, oPara.pEXT);
            PRP[1].arb = instance:addStream("B", core.Line, name .. ".B", "B", instance.parameters.clrS, 0, oPara.pEXT);
            PRP[1].drt = instance:addStream("C", core.Line, name .. ".C", "C", instance.parameters.clrS, 0, oPara.pEXT);
            PRP[1].drb = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrS, 0, oPara.pEXT);
            --show cloud 
            instance:createChannelGroup("T", "T", PRP[1].art, PRP[1].drt, instance.parameters.clrS, 20);
            instance:createChannelGroup("B", "B", PRP[1].arb, PRP[1].drb, instance.parameters.clrS, 20);
        end
        FLG = instance:createTextOutput("F", "F", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrG, 0);
        PRJ = instance:createTextOutput("P", "P", "Arial", 8, core.H_Right, core.V_Center, instance.parameters.clrB, oPara.pEXT+5);
    end
    --for outsignal
    if oPara.pIND then
        for i = 1, toload do EVT[i] = instance:addInternalStream(0, 0); end
        for i = 1, toload do LVT[i] = instance:addInternalStream(0, 0); end
    else    --for strategy
        for i = 1, toload do EVT[i] = instance:addStream(EVN[i], core.Line, name .. "." .. EVN[i], EVN[i], instance.parameters.clrY, 0); end
        for i = 1, toload do LVT[i] = instance:addStream(LVN[i], core.Line, name .. "." .. LVN[i], LVN[i], instance.parameters.clrL, 0); end
    end
    oIndi.evsdr = 100081;  --for synthetic direction
    oIndi.evstd = 100082;  --for straddle
    oIndi.evcsp = 100083;  --for credit spread or inout spread
    oIndi.evcld = 100084;  --for calendar
    oIndi.evbkr = 100085;  --for backratio of short
    
    if oPara.pTHS then loaded = 1; toload = 1; SRC[1] = source; else LoadSource(SRC, SIN); end
end                                                                 

-- Indicator calculation routine
function Update(period, mode)
    assert(source:barSize()=="D1" or source:barSize()=="H4", "TimeFrame only D1 or H4");
    if onload then return; end
    iperiod = period - 1; 
    
    oPara.pEND = source:size()-1;      
    oPara.pBGN = math.max(oPara.pEND-oPara.pSBG, oPara.pNB2);
    if loaded == toload and lastbar ~= source:serial(iperiod) then
        local PRA = PRP[1]; --current properties
        local SRS = SRC[1]; --current sources
        local c;    --counter
        lastbar = source:serial(iperiod);
        --calculate day    
            for c = 1, toload do
                PRA = PRP[c]; 
                SRS = SRC[c];
                if period == source:first() then ResetInfo(c, SRS, iperiod); end
                if PRA.pipsz == 0 then PRA.pipsz = SRS:pipSize(); end
                PRA.dperd = CalcDaySource(PRA, SRS, GetDperiod(SRS, source, iperiod));
            end 
        --calculate enable 
        if iperiod > oPara.pBGN and iperiod <= oPara.pEND then
            
            --check each 
            for c = 1, toload do
                EVA = EVT[c]; 
                LVA = LVT[c];
                PRA = PRP[c]; 
                SRS = SRC[c]; 
                PRA.sperd = GetDperiod(SRS, source, iperiod);
                local speriod = PRA.sperd;
                PRA.avrng = Iif(source:barSize()=="D1", GetAvgRange(oPara.pRNG, SRS, PRA.sperd-1), CalcEma(oPara.pRNG, PRA.avrng, GetAvgRange(oPara.pRNG, SRS, PRA.sperd-1)));
                PRA.rg1[speriod] = CalcRgs(oPara.pNB1, 0, SRS.close, speriod);
                PRA.rg2[speriod] = CalcRgs(oPara.pNB2, 0, SRS.close, speriod);
                --calc base 
                PRA.ra2[speriod] = CalcRgs(oPara.pNB3/2, 0, SRS.close, speriod);
                PRA.ma1[speriod] = CalcSma(oPara.pNB1, 0, SRS.close, speriod);
                PRA.ma2[speriod] = CalcSma(oPara.pNB2, 0, SRS.close, speriod);
                PRA.ma3[speriod] = CalcSma(oPara.pNB3, 0, SRS.close, speriod);
                PRA.m1dev = CalcStd(oPara.pNB1, SRS.close, speriod);
                PRA.m2dev = CalcStd(oPara.pNB2, SRS.close, speriod);
                PRA.m3dev = CalcStd(oPara.pNB3, SRS.close, speriod);
                PRA.m1btm, PRA.m1top = PRA.ma1[speriod]-PRA.m1dev*2, PRA.ma1[speriod]+PRA.m1dev*2;
                PRA.m2btm, PRA.m2top = PRA.ma2[speriod]-PRA.m2dev*2, PRA.ma2[speriod]+PRA.m2dev*2;
                PRA.m3btm, PRA.m3top = PRA.ma3[speriod]-PRA.m3dev*2, PRA.ma3[speriod]+PRA.m3dev*2;

                PRA.sndir, PRA.snpos = CalcSineSkip(PRA, SRS, speriod);
                PRA.dvdir, PRA.bfbtm, PRA.bftop = CalcConDiv(PRA, SRS, speriod);
                PRA.asdir, PRA.amdir, PRA.ampos, PRA.a3val = CalcActSlow(PRA, SRS, speriod);
                PRA.atrnd = PRA.psmod * (PRA.asdir/math.abs(PRA.asdir));
                PRA.dbgin = CalcWeekRange(oPara.pNHV, PRA, SRS, speriod);
                PRA.pcdir, PRA.pcpos = CalcCorrEnd(PRA, SRS, speriod);
                PRA.rldir, PRA.rlval = CalcZoneResist(PRA, SRS, speriod);
                
                --for strategy 
                PRA.token, PRA.toval = SetToken(PRA, SRS, speriod);
                --set event stream
                EVA[iperiod], LVA[iperiod] = SetTrigger(PRA, SRS, speriod);
            end
            
            if oPara.pIND and oPara.pTHS then 
                PRA = PRP[1]; 
                SRS = SRC[1]; 
                local speriod = PRA.sperd;
                if oPara.pFIC then
                    if PRA.bfbtm > 0 then 
                        PRA.btm[speriod] = PRA.bfbtm; PRA.top[speriod] = PRA.bftop; 
                        PRA.top:setColor(speriod, instance.parameters.clrY); 
                    end
                end
                if oPara.pFCS then
                    if PRA.rldir ~= 0 then 
                        PRA.rsl[speriod] = PRA.rlval; 
                        PRA.rsl:setColor(speriod, Iif(PRA.rldir<0, instance.parameters.clrD, instance.parameters.clrU)); 
                    end
                end
                if oPara.pFSN then
                    if PRA.pcdir ~= 0 then 
                        FLG:set(speriod, SRS.close[speriod], "\228\n\230", nil, Iif(PRA.pcdir<0, instance.parameters.clrD, instance.parameters.clrU)); end
                    if PRA.dvdir ~= 0 and PRA.dvdir ~=-1 then
                        local cddir = PRA.rg2[speriod]-PRA.rg2[speriod-oPara.pNCP]
                        FLG:set(speriod, SRS.close[speriod], Iif(cddir<0,"\230","\228"), nil, Iif(cddir<0, instance.parameters.clrD, instance.parameters.clrU)); end
                end
                if oPara.pFHV then
                    if     PRA.atrnd == 0 then PRA.art:setColor(speriod, instance.parameters.clrY); PRA.arb:setColor(speriod, instance.parameters.clrY);
                    elseif PRA.atrnd ==-1 then PRA.art:setColor(speriod, instance.parameters.clrF); PRA.arb:setColor(speriod, instance.parameters.clrF);
                    elseif PRA.atrnd ==-2 then PRA.art:setColor(speriod, instance.parameters.clrF); PRA.arb:setColor(speriod, instance.parameters.clrF);
                    elseif PRA.atrnd ==-3 then PRA.art:setColor(speriod, instance.parameters.clrR); PRA.arb:setColor(speriod, instance.parameters.clrR);
                    elseif PRA.atrnd ==-4 then PRA.art:setColor(speriod, instance.parameters.clrM); PRA.arb:setColor(speriod, instance.parameters.clrM);
                    elseif PRA.atrnd == 1 then PRA.art:setColor(speriod, instance.parameters.clrC); PRA.arb:setColor(speriod, instance.parameters.clrC);
                    elseif PRA.atrnd == 2 then PRA.art:setColor(speriod, instance.parameters.clrC); PRA.arb:setColor(speriod, instance.parameters.clrC);
                    elseif PRA.atrnd == 3 then PRA.art:setColor(speriod, instance.parameters.clrB); PRA.arb:setColor(speriod, instance.parameters.clrB);
                    elseif PRA.atrnd == 4 then PRA.art:setColor(speriod, instance.parameters.clrN); PRA.arb:setColor(speriod, instance.parameters.clrN);
                    end
                end
                if oPara.pFCL then
                    PRA.wdval, PRA.wdpos = CalcWdayPrj(PRA, SRS, period);
                end
            end
        end    
    end
    --for last display
    if oPara.pIND and oPara.pTHS and period == source:size()-1 
    and mode ~= core.UpdateLast and lastbar ~= source:date(period) then
            lastbar = source:date(period);
            local PRA = PRP[1];
            local SRS = SRC[1]; 
            local speriod = PRA.sperd;
            if oPara.pFHV and PRA.art:size()-period > 0 then
                for speriod = period, period+oPara.pEXT-1 do
                    PRA.art[speriod] = PRA.art[speriod-1];
                    PRA.arb[speriod] = PRA.arb[speriod-1];
                    PRA.drt[speriod] = PRA.drt[speriod-1];
                    PRA.drb[speriod] = PRA.drb[speriod-1];
                    if     PRA.atrnd == 0 then PRA.art:setColor(speriod, instance.parameters.clrY); PRA.arb:setColor(speriod, instance.parameters.clrY);
                    elseif PRA.atrnd ==-1 then PRA.art:setColor(speriod, instance.parameters.clrF); PRA.arb:setColor(speriod, instance.parameters.clrF);
                    elseif PRA.atrnd ==-2 then PRA.art:setColor(speriod, instance.parameters.clrF); PRA.arb:setColor(speriod, instance.parameters.clrF);
                    elseif PRA.atrnd ==-3 then PRA.art:setColor(speriod, instance.parameters.clrR); PRA.arb:setColor(speriod, instance.parameters.clrR);
                    elseif PRA.atrnd ==-4 then PRA.art:setColor(speriod, instance.parameters.clrM); PRA.arb:setColor(speriod, instance.parameters.clrM);
                    elseif PRA.atrnd == 1 then PRA.art:setColor(speriod, instance.parameters.clrC); PRA.arb:setColor(speriod, instance.parameters.clrC);
                    elseif PRA.atrnd == 2 then PRA.art:setColor(speriod, instance.parameters.clrC); PRA.arb:setColor(speriod, instance.parameters.clrC);
                    elseif PRA.atrnd == 3 then PRA.art:setColor(speriod, instance.parameters.clrB); PRA.arb:setColor(speriod, instance.parameters.clrB);
                    elseif PRA.atrnd == 4 then PRA.art:setColor(speriod, instance.parameters.clrN); PRA.arb:setColor(speriod, instance.parameters.clrN);
                    end
                end 
            end
            if oPara.pFCL and PRJ:size()-period > 0 then
                local epos = PRA.wdpos+oPara.pEXT+5;
                local ebtm = PRA.wdval-PRA.avrng*10;
                local etop = PRA.wdval+PRA.avrng*10;
                if IsBetween(PRA.p12, ebtm, etop) then PRJ:set(epos-5, PRA.p12, "@" .. GetRound(PRA.p12,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[1]/PRA.wdcnt*100,0) .. "%]"); end
                if IsBetween(PRA.p13, ebtm, etop) then PRJ:set(epos-4, PRA.p13, "@" .. GetRound(PRA.p13,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[2]/PRA.wdcnt*100,0) .. "%]"); end
                if IsBetween(PRA.p14, ebtm, etop) then PRJ:set(epos-3, PRA.p14, "@" .. GetRound(PRA.p14,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[3]/PRA.wdcnt*100,0) .. "%]"); end
                if IsBetween(PRA.p23, ebtm, etop) then PRJ:set(epos-2, PRA.p23, "@" .. GetRound(PRA.p23,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[4]/PRA.wdcnt*100,0) .. "%]"); end
                if IsBetween(PRA.p24, ebtm, etop) then PRJ:set(epos-1, PRA.p24, "@" .. GetRound(PRA.p24,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[5]/PRA.wdcnt*100,0) .. "%]"); end
                if IsBetween(PRA.p34, ebtm, etop) then PRJ:set(epos-0, PRA.p34, "@" .. GetRound(PRA.p34,oPara.pDIG) .. "[" .. GetRound(PRA.wdpfm[6]/PRA.wdcnt*100,0) .. "%]"); end
            end
    end
end
    
function LoadSource(SRC, SIN)
    if not onload then
        onload = true;
        loaded = 0;
        for i = 1, toload do
            SRC[i] = core.host:execute("getSyncHistory", SIN[i-1], oPara.pTTF, true, 0, 800+i, 810+i); 
        end
    end
end
function AsyncOperationFinished(cookie, success, error)
    if IsBetween(cookie, 811, 820) then
    elseif IsBetween(cookie, 801, 810) then
        loaded = loaded + 1; 
        core.host:execute("setStatus", tostring(loaded) .. " loaded");
        assert(success, error);
        if loaded == toload then
            onload = false;
            instance:updateFrom(0);
        end
    end
    return;
end
function ReleaseInstance()
    source = nil;
    SRC = nil;     
    SIN = nil;     
    oIndi = nil;
    oPara = nil;
    --for outstream
    FLG = nil;    
    PRJ = nil;    
    PRP = nil;
    --for outsignal
    EVT = nil;    
    LVT = nil;
    EVN = nil;    
    LVN = nil;
    collectgarbage();    
    return;
end
function SetParameter(oPara, sourcep, iperiod)

    --set optimise
    oPara.pNBK = instance.parameters.N; 
    oPara.pNHV = instance.parameters.L;
    oPara.pWKE = instance.parameters.W;     
    oPara.pFIC = instance.parameters.ShowIC;     
    oPara.pFCS = instance.parameters.ShowCS;     
    oPara.pFSN = instance.parameters.ShowSN;     
    oPara.pFHV = instance.parameters.ShowHV;     
    oPara.pFCL = instance.parameters.ShowCL;     
    --basic
    oPara.pRNG = 40;    --period for hilo range
    oPara.pBAS = 15;    --block after previous singal     10-20
    oPara.pCY2 = 20;    --20 
    oPara.pCY3 = 30;    --30 
    oPara.pCY5 = 50;    --50     
    oPara.pCY6 = 60;    --60 
    oPara.pCY7 = 120;   --120
    oPara.pCY8 = 200;   --200   sp:120  

    oPara.pNCP = 4;     --lookback check      
    oPara.pRML = 0.5;   --reverse main level
    oPara.pSW7 = 0.7;   --swing level  .7-.8
    oPara.pMRB = 4.0;       --Multiplier for Threshold of resistance range  
    oPara.pMBF = 0.01;       --Multiplier for Threshold of band flat  
    oPara.pMPZ = 1.0;     --multipler of the project zone
    oPara.pDIG = Iif(sourcep:pipSize()<0, string.len(tostring(sourcep:pipSize()))-string.find(tostring(sourcep:pipSize()),".")-2, 0);
    --defind para by timeframe
if oPara.pTTF == "D1" then 
    if oPara.pNBK == 0 then oPara.pNB2 = 20; else oPara.pNB2 = oPara.pNBK; end
    oPara.pNWK = 5; oPara.pWKE = oPara.pWKE-1;
    oPara.pBAS = 10;    --block after previous singal     10-20
    oPara.pBAP = 30;    --block after previous straddle     30-40
    oPara.pMRB = 2.0;       --Multiplier for Threshold of resistance range  
    oPara.pXR1 = 1.0;     --mod1 level,       
    oPara.pXR4 = 2.0;     --mod4 extreme level,       
    oPara.pDVL = 1.5;   --multiplier of deviation
    oPara.pTCL = 1.0;     --level of vertical change
    oPara.pNVC = 6;     --span of skip range
    oPara.pNPK = 2;     --span of sine peak
else
    if oPara.pNBK == 0 then oPara.pNB2 = 120; else oPara.pNB2 = oPara.pNBK; end
    oPara.pNWK = 120/tonumber(string.sub(sourcep:barSize(),2,-1));
    oPara.pBAS = 15;    --block after previous singal     10-20
    oPara.pBAP = 50;    --block after previous straddle     40-60
    oPara.pMRB = 4.0;       --Multiplier for Threshold of resistance range  
    oPara.pXR1 = 2.0;     --mod1 level,       
    oPara.pXR4 = 3.0;     --mod4 extreme level,       
    oPara.pDVL = 2.5;   --multiplier of deviation
    oPara.pTCL = 2.0;     --level of vertical change
    oPara.pNVC = 8;     --span of skip range
    oPara.pNPK = 4;     --span of sine peak
end
    --activity line
    if oPara.pNB2 <= 20 then oPara.pNB1 = 10; oPara.pNB3 = 34;
    elseif oPara.pNB2 <= 40 then oPara.pNB1 = 20; oPara.pNB3 = 50; 
    elseif oPara.pNB2 <=120 then oPara.pNB1 = 60; oPara.pNB3 =200; 
    else oPara.pNB1 = 60; oPara.pNB3 = 240; end
    oPara.pEXT = math.min(15, oPara.pNWK);    --extended period to show line
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
function IsSlopeFlat(rflat, vfr, vto, pfr, pto)
    local slope = (vto-vfr)/(pto-pfr);
    return IsBetween(math.abs(slope), 0, rflat);
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
function ResetInfo(i, SRS, iperiod)
        --flat 
        PRP[i].bfbtm = 0;   --the flat bottom 
        PRP[i].bftop = 0;   --the flat top
        --activity
        PRP[i].atrnd = 0;   --activity trend mode
        
        PRP[i].afdir = 0;   --fast direction 
        PRP[i].afpos = 0;   --fast reverse position with dir
        PRP[i].afval = 0;   --fast value
        PRP[i].afpkk = 0;   --fast peak value

        PRP[i].asdir = 0;   --slow direction 
        PRP[i].amdir = 0;   --momentum direction 
        PRP[i].ampos = 0;   --momentum position
        PRP[i].a3val = 0;   --alpha 3 value
        PRP[i].psdir = 0;   --push direction
        PRP[i].psmod = 0;   --push mode
        PRP[i].mcbtm = 0;   --mix combine bottom
        PRP[i].mctop = 0;   --mix combine top
        
        --historic volatility
        PRP[i].dbgin = 0;   --day begin
        PRP[i].dperd = iperiod;   --day period
        --correlation cross
        PRP[i].pcdir = 0;   --the phase correlation direction
        PRP[i].pcpos = 0;   --the phase end position
        --sine skip shift
        PRP[i].shpo1 = 0;   --previous sine cross position
        PRP[i].shpo2 = 0;   --the last sine cross position
        PRP[i].sndir = 0;   --the sine direction
        PRP[i].snpos = 0;   --the sine skip position
        --volatility divergent
        PRP[i].sddir = 0;   --the sd direction
        PRP[i].sdpps = 0;   --the sd peak position
        PRP[i].dvdir = 0;   --the divergent direction
        PRP[i].dvpos = 0;   --the divergent end position with direction
        --zone band
        PRP[i].zrdir = 0;   --zone resistance direction
        PRP[i].zrpos = 0;   --resistance level position of near
        PRP[i].rldir = 0;   --resistance level direction
        PRP[i].rlval = 0;   --resistance level value of near
        --weekly project
        PRP[i].wdval = 0;  --the last weekday value
        PRP[i].wdpos = 0;  --the last weekday position
        PRP[i].wdcnt = 0;  --the counter of weekday
        PRP[i].wmval = 0;  --34 mid(three-four-center) value
        PRP[i].wmpos = 0;  --34 mid(three-four-center) point 
        PRP[i].wdpnt = {0,0,0,0};
        PRP[i].wdpfm = {0,0,0,0,0,0};
        PRP[i].p12 = 0;
        PRP[i].p13 = 0;
        PRP[i].p14 = 0;
        PRP[i].p23 = 0;
        PRP[i].p24 = 0;
        PRP[i].p34 = 0;
        
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
function CalcPushDir(ndir, m1btm, m1top, m2btm, m2top, sourcep, speriod)
    if (ndir==-1 and sourcep.low [speriod]-m1btm > 0) or (ndir== 1 and sourcep.high[speriod]-m1top < 0) 
    or (ndir <-1 and m1btm-m2btm > 0) or (ndir > 1 and m1top-m2top < 0) then ndir = 0; end
    if m1btm-m2btm < 0 and sourcep.low [speriod]-m2btm < 0 then ndir =-3; end   --extreme out, 
    if m1top-m2top > 0 and sourcep.high[speriod]-m2top > 0 then ndir = 3; end   --major push
    if ndir >-1 and sourcep.high[speriod]-m1btm < 0 then ndir =-1; end  --reverse overwrite extreme out
    if ndir < 1 and sourcep.low [speriod]-m1top > 0 then ndir = 1; end  --minor push
    return ndir;
end
function CalcSineSkip(PRA, SRS, speriod)
    local sndir = PRA.sndir;    --
    local snpos = Iif(math.abs(PRA.snpos)==1, 0, PRA.snpos);
    local pcyc = oPara.pNB2;    --
    local pswl = oPara.pSW7;
    local pnvc = oPara.pNVC;
    local pnpk = oPara.pNPK;    --h4:4, D1:2
    local pefc = math.floor(math.min(20, math.max(pnvc, pcyc/6)));
    --identify cycle
    PRA.sin[speriod], PRA.led[speriod] = CalcCsw(pcyc, SRS, speriod);
    if CheckCrosses(PRA.sin[speriod-1], pswl, PRA.sin[speriod], pswl) < 0 then PRA.shpo1 =-speriod; end
    if CheckCrosses(PRA.sin[speriod-1],-pswl, PRA.sin[speriod],-pswl) > 0 then PRA.shpo1 = speriod; end
    if CheckCrosses(PRA.sin[speriod-1], pswl, PRA.sin[speriod], pswl) > 0 then PRA.shpo2 = speriod; end
    if CheckCrosses(PRA.sin[speriod-1],-pswl, PRA.sin[speriod],-pswl) < 0 then PRA.shpo2 =-speriod; end
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
    local pbuf = avrng*0.3;
    afdir = PRA.afdir;
    afpos = PRA.afpos;
    afpkk = PRA.afpkk;
    local afpre = PRA.reg[speriod-1] + prng*PRA.led[speriod-1];
    
    PRA.reg[speriod] = CalcRgs(pnb2, 0, SRS.close, speriod);
    PRA.sin[speriod], PRA.led[speriod] = CalcCsw(pnb2, SRS, speriod);
    afval = PRA.reg[speriod] + prng*PRA.led[speriod];
    if PRA.sndir == 0 then 
        if     afpkk == nil or afpkk == 0 then afpkk = afval;
        elseif math.abs(PRA.snpos) == 1 then afpkk = afpre * PRA.snpos;
        elseif afpkk < 0 then
            if     (afval+afpkk) > pbuf then afpkk = afval; afdir = 1;       --reverse
            elseif (afval+afpkk) < 0    then afpkk =-afval; afdir =-1; end   --resume 
        elseif afpkk > 0 then
            if     (afpkk-afval) > pbuf then afpkk =-afval; afdir =-1;
            elseif (afpkk-afval) < 0    then afpkk = afval; afdir = 1; end
        end
    else afdir = PRA.sndir; 
    end    
    --check reverse 
    if afdir*PRA.afdir < 0 then afpos = Iif(afdir < 0,-speriod, speriod); end

    return afdir, afpos, afval, afpkk; --linedir 
end
function CalcActSlow(PRA, SRS, speriod)
    local asdir = PRA.asdir;
    local amdir = PRA.amdir;
    local ampos = PRA.ampos;
    local mslvl = PRA.avrng * 0.2;   --multiplier of ma slope  
    local pnb1 = oPara.pNB1;
    local pnb2 = oPara.pNB2;
    local pnb3 = oPara.pNB3;
    local pns3 = math.floor(math.min(20, math.max(4, pnb1/3)));
    local pncp = oPara.pNCP;
    local pnpk = oPara.pNPK;    --h4:4, D1:2
    local pdvl = oPara.pDVL;
    local pxr1 = oPara.pXR1;
    local pxr4 = oPara.pXR4;
    local asval = CalcRgs(pnb1, 0, SRS.close, speriod); --H4:50, D1:10-30? 
    local a3val = PRA.a3val; 
    local a3pre = PRA.a3val;

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
        ampos = Iif(amdir<0,-speriod, speriod);     --keep position with direction 
    end
    if     PRA.psmod == 4 or (PRA.ra2[speriod]-PRA.ma2[speriod])*amdir > 0 or PRA.m2dev/PRA.avrng > pdvl then asdir = amdir;
    elseif asdir > 0 and SRS.low [speriod]-PRA.m2btm < 0 and SRS.high[speriod]-PRA.m2top < 0 then asdir =-1;  
    elseif asdir < 0 and SRS.high[speriod]-PRA.m2top > 0 and SRS.low [speriod]-PRA.m2btm > 0 then asdir = 1; end 
    
    return asdir, amdir, ampos, a3val;
end

function CalcConDiv(PRA, SRS, speriod)
    local dvdir = 0;
    local dvpos = 0;
    local rbuff = PRA.avrng*0.2;
    local fbuff = PRA.avrng*oPara.pMRB;
    local pnb3 = oPara.pNB3;
    local pxr1 = oPara.pXR1;
    local pxr4 = oPara.pXR4;
    local pdvl = pxr1+0.3;
    local bfbtm = PRA.bfbtm
    local bftop = PRA.bftop
    local creg = PRA.rg2[speriod];
    
    PRA.avr[speriod] = PRA.avrng;
    PRA.std[speriod] = PRA.m2dev;
    local sdpre = PRA.sddir;    --std slow direction
    PRA.sddir, PRA.sdpps = CalcLineDir(3, rbuff, PRA.sdpps, PRA.std[speriod], speriod);
    --reverse set position
    if sdpre * PRA.sddir < 0 then dvpos = Iif(PRA.sddir < 0,-speriod, speriod); end
    --reverse after extreme
    if PRA.std[speriod]/PRA.avr[speriod] > pxr4 and PRA.avr[speriod]/PRA.avr[speriod-pnb3] > pxr1 
    and speriod+dvpos == 0 then dvdir =-3; end
    if CheckCrosses(PRA.std[speriod-1], PRA.avr[speriod-1]*pdvl, PRA.std[speriod], PRA.avr[speriod]*pdvl) < 0 then dvdir =-1; 
        bfbtm = creg - fbuff; bftop = creg + fbuff; end 
    if (PRA.std[speriod]/PRA.avr[speriod] < pxr1 and speriod-dvpos == 0) then dvdir = 1; end
    if CheckCrosses(PRA.std[speriod-1], PRA.avr[speriod-1], PRA.std[speriod], PRA.avr[speriod]) > 0 then dvdir = 3; end 
    if dvdir > 0 or (SRS.high[speriod]-bfbtm < 0 or SRS.low[speriod]-bftop > 0) then 
        bfbtm = 0; 
        bftop = 1000000; 
    end
    return dvdir, bfbtm, bftop;
end
function CalcCorrEnd(PRA, SRS, iperiod)
    local speriod = PRA.sperd;  --redefine period form original
    local pcdir = 0;
    local pcpos = PRA.pcpos;
    local pcyc = oPara.pNB2;       
    local pbap = oPara.pBAP;
    PRA.rgc[iperiod] = CalcRgs(pcyc, 0, SRS.close, speriod);
    PRA.pcc[iperiod] = CalcPcc(pcyc, PRA.rgc, SRS.close, speriod);
    if CheckCrosses(PRA.pcc[speriod-1], 0, PRA.pcc[speriod], 0) > 0 then pcdir = 1; pcpos = speriod; end
    
    return pcdir, pcpos;
end
--calc week range
function CalcWeekRange(pnhv, PRA, SRS, speriod)
    local dperd = PRA.dperd;
    local dbgin = math.max(dperd - pnhv, pnhv);    --
    local dunit, avpst, avngt;  --day atr,average positive,average negative
    if dperd - dbgin >= pnhv 
    and IsWdayNext(oPara.pWKE, SRS:date(speriod-1), SRS:date(speriod)) then
        dunit = GetAvgRange(oPara.pRNG, PRA, dperd-1);
        PRA.arb[speriod] = SRS.close[speriod-1] - dunit;
        PRA.art[speriod] = SRS.close[speriod-1] + dunit;
        avngt, avpst = CalcDistribution(pnhv, PRA, dbgin, dperd-1);
        PRA.drb[speriod] = SRS.close[speriod-1] - avngt;
        PRA.drt[speriod] = SRS.close[speriod-1] + avpst;
    else
        PRA.arb[speriod] = PRA.arb[speriod-1];
        PRA.art[speriod] = PRA.art[speriod-1];
        PRA.drb[speriod] = PRA.drb[speriod-1];
        PRA.drt[speriod] = PRA.drt[speriod-1];
    end
    return dbgin;
end
function CalcDaySource(PRA, SRS, speriod)
    local dperd = PRA.dperd;
    local pdate = core.dateToTable(SRS:date(speriod-1));
    local tdate = core.dateToTable(SRS:date(speriod));
    if SRS:barSize() == "D1" and speriod > 0 then
        dperd = dperd + 1; PRA.date[dperd] = SRS:date(speriod); 
        PRA.open[dperd] = SRS.open[speriod];
        PRA.high[dperd] = SRS.high[speriod];
        PRA.low[dperd] = SRS.low[speriod]; 
        PRA.close[dperd] = SRS.close[speriod]; 
    elseif dperd < speriod and (pdate.hour < 17 and tdate.hour >= 17) then
        dperd = dperd + 1; PRA.date[dperd] = SRS:date(speriod); 
        PRA.open[dperd] = SRS.open[speriod];
        PRA.high[dperd] = SRS.high[speriod];
        PRA.low[dperd] = SRS.low[speriod]; 
        PRA.close[dperd] = SRS.close[speriod]; 
    elseif dperd <= speriod and dperd > 0 then
        PRA.high[dperd] = math.max(PRA.high[dperd], SRS.high[speriod]);
        PRA.low[dperd] = math.min(PRA.low[dperd], SRS.low[speriod]); 
        PRA.close[dperd] = SRS.close[speriod]; 
    end
    return dperd;
end
function CalcDistribution(pnhv, sourcep, cbgn, cend)
    local speriod = 0;
    local ccnt = cend - cbgn + 1;
    local psla = "HL";
    local VDN = {};
    
    --zero base array set len+1
    VDN.drp = mathex.makeArray(ccnt + 1);   --direction move for positive
    VDN.drn = mathex.makeArray(ccnt + 1);   --direction move for negative
    VDN.dmv = mathex.makeArray(ccnt + 1);   --direction move
    VDN.dvp = mathex.makeArray(ccnt + 1);   --deviation for positive
    VDN.dvn = mathex.makeArray(ccnt + 1);   --deviation for negative
    
    --calculate
    for i = 1, ccnt do
        speriod = math.max(cbgn - 1 + i, pnhv);
		if     psla == "CL" then
            VDN.drn[i] = sourcep.close[speriod] - sourcep.close[speriod-pnhv];
            VDN.drp[i] = sourcep.close[speriod] - sourcep.close[speriod-pnhv];
		elseif psla == "HL" then
            VDN.drn[i] = sourcep.low [speriod] - sourcep.close[speriod-pnhv];
            VDN.drp[i] = sourcep.high[speriod] - sourcep.close[speriod-pnhv];
		end
        if sourcep.close[speriod] - sourcep.close[speriod-pnhv] < 0 then
            VDN.dmv[i] = VDN.drn[i]; else VDN.dmv[i] = VDN.drp[i]; end
        if sourcep.close[speriod] - sourcep.close[speriod-pnhv] < 0 then
            if pnhv == 1 then VDN.dvn[i] = math.abs(VDN.drn[i]) / 2; 
            else VDN.dvn[i] = CalcStd(pnhv, VDN.dmv, i); end
            VDN.dvp[i] = 0;
        else
            if pnhv == 1 then VDN.dvp[i] = math.abs(VDN.drp[i]) / 2; 
            else VDN.dvp[i] = CalcStd(pnhv, VDN.dmv, i); end
            VDN.dvn[i] = 0;
        end
    end
    return GetAverage(VDN.dvn, 1, ccnt), GetAverage(VDN.dvp, 1, ccnt);
end
function CalcZoneResist(PRA, SRS, speriod)
    local avrng = PRA.avrng;
    local rldir = 0; 
    local rlval = PRA.rlval; 
    local asdir = PRA.asdir; 
    local zt1pr, zt1pv, zb1pr, zb1pv;   
    local zt2pr, zt2pv, zb2pr, zb2pv;
    local pnb2 = oPara.pNB2;
    local pnb3 = oPara.pNB3;
    local pmrb = oPara.pMRB;    --flat range
    local pnsf = math.max(6, math.min(20, oPara.pNB1/3));    --20
    local pmbf = 0.01;    --0.01
    local rgpv = PRA.rg2[speriod];  --length = pnb2
    local rgpr = PRA.rg2[speriod-pnsf];
    local mapv = PRA.ma2[speriod];
    local mapr = PRA.ma2[speriod-pnsf];
    local mspv = PRA.ma3[speriod];
    local mspr = PRA.ma3[speriod-pnsf];

    local zt3pr, zt3pv, zb3pr, zb3pv;   
    local ztfpr, ztfpv, zbfpr, zbfpv;
    
    if speriod-PRA.zrpos < pnsf and (PRA.rg1[speriod]-rlval)*PRA.zrdir > 0 then
        rldir = PRA.zrdir;
    elseif speriod-PRA.zrpos > pnsf then
        zb1pr, zt1pr = CalcZoneBand(1, mapr, pnb2, 2.0, SRS, speriod-pnsf);
        zb2pr, zt2pr = CalcZoneBand(2, rgpr, pnb2, pmrb, SRS, speriod-pnsf);
        zb1pv, zt1pv = CalcZoneBand(1, mapv, pnb2, 2.0, SRS, speriod);
        zb2pv, zt2pv = CalcZoneBand(2, rgpv, pnb2, pmrb, SRS, speriod);
        if     asdir < 0 then
            if math.abs(SRS.close[speriod]-zt2pv) < avrng and (zt1pv-zt1pr)*asdir > avrng*-pmbf then
                rlval = Iif(math.abs(zt1pv-zt2pv) < avrng*2 and SRS.close[speriod]-zt2pv > 0, math.max(zt1pv, zt2pv), zt2pv); 
                PRA.zrdir = asdir*Iif(math.abs(zt1pv-zt2pv) < avrng, 2, 1); 
                PRA.zrpos = speriod; 
            end
            if math.abs(SRS.close[speriod]-zb1pv) < avrng and math.abs(zb1pv-zb2pv) < avrng 
            and IsSlopeFlat(avrng*pmbf, zb1pr, zb1pv, speriod-pnsf, speriod) then
                rlval = Iif(SRS.close[speriod]-zb2pv < 0, math.min(zb1pv, zb2pv), zb2pv);
                PRA.zrdir = asdir*-2; 
                PRA.zrpos = speriod; 
            end
        elseif asdir > 0 then
            if math.abs(SRS.close[speriod]-zb2pv) < avrng and (zb1pv-zb1pr)*asdir > avrng*-pmbf then 
                rlval = Iif(math.abs(zb1pv-zb2pv) < avrng*2 and SRS.close[speriod]-zb2pv < 0, math.min(zb1pv, zb2pv), zb2pv); 
                PRA.zrdir = asdir*Iif(math.abs(zb1pv-zb2pv) < avrng, 2, 1); 
                PRA.zrpos = speriod; 
            end 
            if math.abs(SRS.close[speriod]-zt1pv) < avrng and math.abs(zt1pv-zt2pv) < avrng 
            and IsSlopeFlat(avrng*pmbf, zt1pr, zt1pv, speriod-pnsf, speriod) then
                rlval = Iif(SRS.close[speriod]-zt2pv > 0, math.max(zt1pv, zt2pv), zt2pv);
                PRA.zrdir = asdir*-2; 
                PRA.zrpos = speriod;
            end
        end
    end
    return rldir, rlval; 
end
function CalcZoneBand(ztyp, zbml, nPeriod, mtpr, sourcep, speriod)
    nPeriod = math.min(nPeriod, speriod);
    local prng = oPara.pRNG;
    local cbl, ctl;
    if     ztyp == 1 then
        --standard deviation
        local dv = CalcStd(nPeriod, sourcep.close, speriod);
        cbl = zbml - dv*mtpr;
        ctl = zbml + dv*mtpr;
    elseif ztyp == 2 then
        --atr
        local ut = GetAvgRange(prng, sourcep, speriod-1);
        cbl = zbml - ut*mtpr;
        ctl = zbml + ut*mtpr;
    elseif ztyp == 3 then
        --simple combine
        local mt = math.sqrt(nPeriod) / 2;  --better approach 20:2.2, 40:3.2, 60:3.8, 100:5
        local dv = CalcStd(nPeriod, sourcep.close, speriod);
        local ut = GetAvgRange(prng, sourcep, speriod-1);
        --get outter band
        local wd = math.max(dv*mtpr, ut*mt);
        cbl = zbml - wd;
        ctl = zbml + wd;
    end

    return cbl, ctl;
end
function CalcWdayPrj(PRA, SRS, speriod)
    local avrng = PRA.avrng;
    if IsWdayNext(oPara.pWKE, SRS:date(speriod-1), SRS:date(speriod)) then
        local extp = speriod-1+oPara.pNWK;
        for i = 1, 3 do PRA.wdpnt[i] = PRA.wdpnt[i+1]; end PRA.wdpnt[4] = speriod-1;
        PRA.wdval = SRS.close[speriod-1]; 
        PRA.wdpos = speriod-1;
        PRA.wdcnt = PRA.wdcnt + 1;
        --34 mid(three-four-center) point and value 
        PRA.wmval = (SRS.close[PRA.wdpnt[3]]+SRS.close[PRA.wdpnt[4]])/2; 
        PRA.wmpos = math.floor((PRA.wdpnt[3]+PRA.wdpnt[4])/2);
        --calc performance
        PRA.wdpfm[1] = PRA.wdpfm[1] + math.max(oPara.pMPZ-math.abs((PRA.p12-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 
        --PRJ.p12[average] = PRA.wdpfm[1] / PRA.wdcnt; 
        PRA.wdpfm[2] = PRA.wdpfm[2] + math.max(oPara.pMPZ-math.abs((PRA.p13-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 
        PRA.wdpfm[3] = PRA.wdpfm[3] + math.max(oPara.pMPZ-math.abs((PRA.p14-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 
        PRA.wdpfm[4] = PRA.wdpfm[4] + math.max(oPara.pMPZ-math.abs((PRA.p23-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 
        PRA.wdpfm[5] = PRA.wdpfm[5] + math.max(oPara.pMPZ-math.abs((PRA.p24-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 
        PRA.wdpfm[6] = PRA.wdpfm[6] + math.max(oPara.pMPZ-math.abs((PRA.p34-PRA.wdval)/PRA.avrng)*(1/oPara.pMPZ), 0); 

        if PRA.wdpnt[1] > 0 then PRA.p12 = GetExtraPolation(SRS.close[PRA.wdpnt[1]], PRA.wdpnt[1], PRA.wmval, PRA.wmpos, extp); end 
        if PRA.wdpnt[1] > 0 then PRA.p13 = GetExtraPolation(SRS.close[PRA.wdpnt[1]], PRA.wdpnt[1], SRS.close[PRA.wdpnt[3]], PRA.wdpnt[3], extp); end 
        if PRA.wdpnt[1] > 0 then PRA.p14 = GetExtraPolation(SRS.close[PRA.wdpnt[1]], PRA.wdpnt[1], SRS.close[PRA.wdpnt[4]], PRA.wdpnt[4], extp); end 
        if PRA.wdpnt[2] > 0 then PRA.p23 = GetExtraPolation(SRS.close[PRA.wdpnt[2]], PRA.wdpnt[2], PRA.wmval, PRA.wmpos, extp); end 
        if PRA.wdpnt[2] > 0 then PRA.p24 = GetExtraPolation(SRS.close[PRA.wdpnt[2]], PRA.wdpnt[2], SRS.close[PRA.wdpnt[4]], PRA.wdpnt[4], extp); end 
        if PRA.wdpnt[3] > 0 then PRA.p34 = GetExtraPolation(SRS.close[PRA.wdpnt[3]], PRA.wdpnt[3], SRS.close[PRA.wdpnt[4]], PRA.wdpnt[4], extp); end 
    end
    return PRA.wdval, PRA.wdpos;
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
function CalcCsw(rPeriod, sourcep, speriod)
    local tyval = 0;
    local realP = 0;
    local imagP = 0;
    local phase = 90;
    for i = 0, rPeriod-1 do
        tyval = (sourcep.close[speriod-i]);
        realP = realP + math.sin(math.rad(360 * i / rPeriod)) * (tyval); 
        imagP = imagP + math.cos(math.rad(360 * i / rPeriod)) * (tyval); 
    end
    if math.abs(imagP) > 0 then
        phase = math.deg(math.atan(realP / imagP)) + 90;
    else phase = 90; end
    if imagP < 0 then phase = phase + 180; end
    if phase > 315 then phase = phase - 360; end
    return math.sin(math.rad(phase)), math.sin(math.rad(phase + 45));
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
function GetAverage(PST, ifrom, ito)
    local cnta = 0;
    local suma = 0;
    local cntp = 0;
    local sump = 0;
    local cntn = 0;
    local sumn = 0;
    for i = ifrom, ito do
        if PST[i] ~= nil then
            --calculate by +-
            if     PST[i] < 0 then 
                cnta = cnta+1; suma = suma+PST[i];
                cntn = cntn+1; sumn = sumn+PST[i];
            elseif PST[i] > 0 then 
                cnta = cnta+1; suma = suma+PST[i];
                cntp = cntp+1; sump = sump+PST[i];
            else    --skip zero
            end
        end
    end
    if cnta == 0 then cnta = 1; end
    if cntn == 0 then cntn = 1; end
    if cntp == 0 then cntp = 1; end
    return suma/cnta, sumn/cntn, sump/cntp;
end
function GetAvgRange(mPeriod, sourcep, speriod)
    speriod = math.max(speriod, 1);
    mPeriod = math.min(speriod, mPeriod);
    local ahi = mathex.avg(sourcep.high, core.rangeTo(speriod, mPeriod));
    local alo = mathex.avg(sourcep.low, core.rangeTo(speriod, mPeriod));
    return ahi-alo;
end
function GetExtraPolation(val1, pos1, val2, pos2, epos)
    local incr = (val2-val1)/(pos2-pos1);
    local eval = val1 + incr*(epos-pos1);
    return eval;
end
function GetDperiod(sources, sourcep, iperiod)
    local ifr = math.max(iperiod-20, sources:first());
    local ito = math.min(iperiod+2, sources:size()-1);
    local speriod = 0;
    if sourcep:barSize() == "D1" then
        speriod = core.findDate(sources, sourcep:date(iperiod), false);
    else
        for i = ito, ifr, -1 do
            if sources:date(i) <= sourcep:date(iperiod) then 
                speriod = i; break; end
        end
    end
    return speriod;
end
function GetRound(numf, digi)
    return tonumber(string.format("%." .. (digi or 0) .. "f", numf));
end
function GetRoundPip(numf, psiz)
    local digi = math.log10(psiz);
    if digi > 0 then digi = 0; else digi = math.abs(digi)+1; end
    return tonumber(string.format("%." .. (digi or 0) .. "f", numf));
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

--signal
function SetToken(PRA, SRS, speriod)
    local settkn = 0;   --token
    local setval = PRA.toval;   --fill level
    local pbas = oPara.pBAS;
    --directional
    if PRA.dvdir ==-3 and PRA.amdir < 0  
    then settkn =-oIndi.evsdr; setval = SRS.close[speriod] *-1; end
    if PRA.dvdir ==-3 and PRA.amdir > 0  
    then settkn = oIndi.evsdr; setval = SRS.close[speriod]; end

    --by atr/flat band
    if IsBetween(PRA.bftop, SRS.low[speriod], SRS.high[speriod]) and PRA.amdir < 0
    and (PRA.stdir >= 0 or speriod-PRA.stpos > pbas) 
    then settkn =-oIndi.evsdr; setval = SRS.close[speriod] *-1; end
    if IsBetween(PRA.bfbtm, SRS.low[speriod], SRS.high[speriod]) and PRA.amdir > 0
    and (PRA.stdir <= 0 or speriod-PRA.stpos > pbas) 
    then settkn = oIndi.evsdr; setval = SRS.close[speriod]; end
    --straddle
    if PRA.pcdir ~= 0 and speriod-PRA.stpos > pbas 
    then settkn = oIndi.evstd * Iif(PRA.pcdir<0,-1, 1); setval = SRS.close[speriod] * Iif(PRA.pcdir<0,-1, 1); end
    --spread
    if PRA.rldir < 0 and (PRA.stdir >= 0 or speriod-PRA.stpos > pbas)
    then settkn =-oIndi.evcsp; setval = PRA.rlval *-1; end
    if PRA.rldir > 0 and (PRA.stdir <= 0 or speriod-PRA.stpos > pbas)
    then settkn = oIndi.evcsp; setval = PRA.rlval; end

    return settkn, setval;  --both with direction
end
function SetTrigger(PRA, SRS, speriod)
    local vevt, vlvt;
    if PRA.token ~= 0 then
        --set direction and position
        PRA.stdir = Iif(PRA.token<0, -1, 1); PRA.stpos = speriod;
        vevt, vlvt = PRA.token, GetRoundPip(math.abs(PRA.toval), PRA.pipsz);
    end
    return vevt, vlvt;
end
