-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10917
-- Id: 5494

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

-- The indicator is Richard Tao Dynamic Analysis beta version - measure momentum to predict next force
-- Richard Tao Predictor serials number 7
-- initializes the indicator
function Init()
    indicator:name("bRichardTaoDynamicAnalysis");
    indicator:description("Richard Tao Dynamic Analysis.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Display");
    indicator.parameters:addBoolean("ShowSignal", "Show Signal", "", true);   
    indicator.parameters:addBoolean("ShowTrendLine", "Show ATL", "", true);   
    indicator.parameters:addInteger("WaveLength", "Minimum of Wave length", "", 14, 9, 100);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBSET", "BuySColor", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrSSET", "SellSColor", "", core.rgb(255, 64, 255));
    indicator.parameters:addColor("clrBCOUNT", "BuyCColor", "", core.rgb(0, 128, 64));
    indicator.parameters:addColor("clrSCOUNT", "SellCColor", "", core.rgb(196, 0, 0));
    indicator.parameters:addColor("clrUTL", "UpLineColor", "", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clrDTL", "DownLineColor", "", core.rgb(0, 64, 0));
end

local source = nil;

local TB = nil;
local TL2 = nil;
local BL2 = nil;
local TL1 = nil;
local BL1 = nil;
local PL1 = nil;

local TDS = nil;
local BSL = nil;
local RSL = nil;
local UTL = nil;
local DTL = nil;

local oSeq = {};
local oPara = {};
local oIndi = {};
local zinfo = {};

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    if instance.parameters.ShowNumber or instance.parameters.ShowSignal then 
        TB = instance:addInternalStream(0, 0);
        TL1 = instance:addInternalStream(0, 0);
        BL1 = instance:addInternalStream(0, 0);
        TL2 = instance:addInternalStream(0, 0);
        BL2 = instance:addInternalStream(0, 0);
        PL1 = instance:addInternalStream(0, 0);
        PL2 = instance:addInternalStream(0, 0);
    
        RSL = instance:addStream("RSL", core.Line, name .. ".RSL", "RSL", instance.parameters.clrBCOUNT, 0);
        BSL = instance:addStream("BSL", core.Line, name .. ".BSL", "BSL", instance.parameters.clrSCOUNT, 0);
        RSL:setStyle(core.LINE_DASH);
        BSL:setStyle(core.LINE_DASH);
    end

    if instance.parameters.ShowTrendLine then 
        SLR = instance:addInternalStream(0, 0);
        PVW = instance:addInternalStream(0, 0);
        UTL = instance:addStream("UTL", core.Line, name .. ".UTL", "UTL", instance.parameters.clrUTL,  0);
        DTL = instance:addStream("DTL", core.Line, name .. ".DTL", "DTL", instance.parameters.clrDTL,  0);
    end
        TDS = instance:createTextOutput("TDS", "TDS", "Wingdings", 12, core.H_Center, core.V_Center, instance.parameters.clrBSET, 0);
end

local symup = {"\236","\228","\246","\241","\200","6","7","\228","\225","\230","11","\233","\233"};
local symdn = {"\238","\230","\248","\242","\202","6","7","\230","\226","\228","11","\234","\234"};
local lastbar = nil;
local iperiod = 0;

-- calculate the value
function Update(period, mode)
    if period == source:first() then
        SetParameter(oPara, source, period);
        InitialUpdate(source, period);
    end
    if (source:isAlive()) then iperiod = period-1 else iperiod = period end;
    if (iperiod-oSeq.SInterval >= source:first()) and (mode ~= core.UpdateLast) then
        if instance.parameters.ShowNumber or instance.parameters.ShowSignal then 
            UpdateBBD(source, iperiod);
            if iperiod > oPara.pBBN*oPara.pTBN + oPara.pZRO then
                SetZZPoint(source, oPara.pZZN, iperiod);
                SetProject(oIndi, iperiod);
                if oSeq.SSeek <= 0 then
                    oSeq = SetSetup(source, oSeq, -1, iperiod);
                end
                if oSeq.SSeek >= 0 and oSeq.PreSEnd ~= iperiod then
                    oSeq = SetSetup(source, oSeq, 1, iperiod);
                end
                if oSeq.Completed == -1 then
                    oSeq = SetCountdown(source, oSeq, -2, iperiod);
                elseif oSeq.Completed == 1 then
                    oSeq = SetCountdown(source, oSeq, 2, iperiod);
                end
                SetDigest(source, oSeq, iperiod);
                SetForce(source, oSeq, iperiod);
            end
        end
    end
    
    if (period == source:size() - 1) and (mode ~= core.UpdateLast) then
        if instance.parameters.ShowNumber or instance.parameters.ShowSignal then 
            SetStopLevel(source, oSeq, period);
        end
        if instance.parameters.ShowTrendLine then 
            SetATL(source, instance.parameters.WaveLength, period);
        end
        lastbar = source:date(period);
	end
	
    if (period == source:size() - 1) and lastbar ~= source:date(period) then
        lastbar = source:date(period);
        instance:updateFrom(source:first());
    end
end

function SetParameter(oPara, source, iperiod)
    oPara.pBBN = 15;
    oPara.pTBN = 5;
    oPara.pUNC = 100;
    oPara.pBBD = 2;
    oPara.pTSD = 1;
    oPara.pZZN = 12;
    oPara.pZRO = 0;
    oPara.pSint = 4; 
    oPara.pCint = 2; 
    oPara.pExclusive = 1; 
    oPara.pStpInc = 2;
    oPara.pTPR = true;

        oPara.pBAR = source:barSize();
        local dt = core.dateToTable( source:date(iperiod) );
        local pre = nil;
    
        if string.sub(source:barSize(),1,1)=="M" then 
            oPara.pTBN = 4;
            for i=iperiod, iperiod+5 do
                dt = core.dateToTable( source:date(i) );
                if math.fmod(dt.month,3)==1 then oPara.pZRO=i; break; end
            end
        end
        if string.sub(source:barSize(),1,1)=="W" then
            oPara.pTBN = 4;
            for i=iperiod, iperiod+14 do
                pre = dt.month;
                dt = core.dateToTable( source:date(i) );
                if dt.month>pre then oPara.pZRO=i; break; end
            end
        end
        if string.sub(source:barSize(),1,1)=="D" then 
            oPara.pTBN = 5;
            for i=iperiod, iperiod+8 do
                dt = core.dateToTable( source:date(i) );
                if dt.wday==2 then oPara.pZRO=i; break; end
            end
        end
        if string.sub(source:barSize(),1,1)=="H" then
            if source:barSize()=="H1" then  
                oPara.pBBN = 20;
                oPara.pTBN = 4;
            elseif source:barSize()=="H4" then
                oPara.pTBN = 6;
            else
                oPara.pTBN = 4;
            end
            for i=iperiod, iperiod+25 do
                dt = core.dateToTable( source:date(i) );
                if dt.hour==17 then oPara.pZRO=i; break; end
            end
        end
        if string.sub(source:barSize(),1,1)=="m" then
                oPara.pBBN = 20;
            if source:barSize()=="m1" then  
                oPara.pTBN = 5;
            elseif source:barSize()=="m5" then
                oPara.pTBN = 6;
            else
                oPara.pTBN = 4;
            end
            for i=iperiod, iperiod+61 do
                pre = dt.hour;
                dt = core.dateToTable( source:date(i) );
                if dt.hour>pre then oPara.pZRO=i; break; end
            end
        end

end
function InitialUpdate(source, period)
    local rangev = (core.max(source.high, core.rangeTo(source:size()-1,200)) 
            - core.min(source.low, core.rangeTo(source:size()-1,200)));
    zinfo.zback = rangev / 100 * math.sqrt(oPara.pZZN) * 2;
    zinfo.searchhl = 1;
    zinfo.srcforw = source.high;
    zinfo.srcback = source.low;
    zinfo.newVal = source.close[period];
    zinfo.newPos = period;
    zinfo.preVal = zinfo.newVal;
    zinfo.prePos = zinfo.newPos;
    zinfo.prebbv = zinfo.newVal;
    oIndi.ppj = 0;
    oIndi.expos = 0;
    oIndi.pdist = 0;
    oIndi.pjval = 0;
    oIndi.pjpos = 0;
    oIndi.touch = 0;
    oIndi.pjcrs = 0;
    oIndi.mtrnd = 0;
    oIndi.smask = 0;
    oIndi.updown = 0;
    oIndi.prevud = 0;
    oIndi.protect = 0;
    oIndi.trndlevel = 0;
    oIndi.pretlevel = 0;
    oIndi.revslevel = 0;
    oIndi.sunit = rangev / oPara.pUNC;
    oPara.sunit = rangev / 150;
    oSeq = ResetSeqinfo(oSeq, 0);
end

function UpdateBBD(source, iperiod)
    local speriod;
    if iperiod-oPara.pZRO >= 0 then
        speriod = math.floor((iperiod-oPara.pZRO)/oPara.pTBN);
    else
        speriod = 0;
    end
    if math.fmod(iperiod-oPara.pZRO, oPara.pTBN)==0 then
        TB[speriod] = source.close[math.min(oPara.pZRO + (speriod+1)*oPara.pTBN -1, source:size()-1)];
    end
    if TL2:hasData(iperiod-1) then 
        TL2[iperiod] = TL2[iperiod-1];
        BL2[iperiod] = BL2[iperiod-1];
        TL1[iperiod] = TL1[iperiod-1];
        BL1[iperiod] = BL1[iperiod-1];
    end

    if speriod >= oPara.pBBN then
        local ml = core.avg(TB, core.rangeTo(speriod, oPara.pBBN));
        local dv = core.stdev(TB, core.rangeTo(speriod, oPara.pBBN));
        if TL2 ~= nil then
            TL2[iperiod] = ml + dv * oPara.pBBD;
            BL2[iperiod] = ml - dv * oPara.pBBD;
        end
        if TL1 ~= nil then
            TL1[iperiod] = ml + dv * oPara.pTSD;
            BL1[iperiod] = ml - dv * oPara.pTSD;
        end
    end
end

function SetZZPoint(sourcep, lengthp, iperiod)
    if (zinfo.srcforw[iperiod]-zinfo.newVal)*zinfo.searchhl > 0 then
        zinfo.newVal = zinfo.srcforw[iperiod];
        zinfo.newPos = iperiod;
    end
    if ( (iperiod-zinfo.newPos >= lengthp) and (zinfo.newVal-zinfo.srcback[iperiod])*zinfo.searchhl > zinfo.zback )
    or ( (zinfo.srcback[iperiod]-zinfo.preVal)*zinfo.searchhl < 0 ) then
        zinfo.preVal = zinfo.newVal;
        zinfo.prePos = zinfo.newPos;
        zinfo.searchhl = zinfo.searchhl * -1;
        if zinfo.searchhl > 0 then
            if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos+2, iperiod)); end
            zinfo.srcforw = sourcep.high;
            zinfo.srcback = sourcep.low;
        elseif zinfo.searchhl < 0 then
            if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos+2, iperiod)); end
            zinfo.srcforw = sourcep.low;
            zinfo.srcback = sourcep.high;
        end
    end
    return zinfo.searchhl;
end
function SetProject(oIndi, iperiod)
    if oIndi.mtrnd<=0 and core.crossesOver(source.close, TL1, iperiod) then oIndi.mtrnd=1; end
    if oIndi.mtrnd>=0 and core.crossesUnder(source.close, BL1, iperiod) then oIndi.mtrnd=-1; end
    if oIndi.touch<0 and source.high[iperiod]-TL1[iperiod]>0 then oIndi.touch=0; oIndi.pdist=0; end
    if oIndi.touch>0 and source.low[iperiod]-BL1[iperiod]<0 then oIndi.touch=0; oIndi.pdist=0; end
    if oIndi.touch==0 and core.crossesUnder(source.low, BL2[iperiod]-(BL2[iperiod]-BL1[iperiod])/4, iperiod) then oIndi.smask=1; end
    if oIndi.touch==0 and core.crossesOver(source.high, TL2[iperiod]-(TL2[iperiod]-TL1[iperiod])/4, iperiod) then oIndi.smask=-1; end
    if oIndi.touch==0 and core.crossesUnder(source.close, BL2, iperiod) then
        oIndi.touch = -1;
        oIndi.pjcrs = 0;
        oIndi.pjval = BL2[iperiod];
        oIndi.pjpos = iperiod;
        oIndi.pdist = CalcRadius(zinfo.preVal, zinfo.prePos, oIndi.pjval, oIndi.pjpos, oIndi.sunit)*-1;
    end
    if oIndi.touch==0 and core.crossesOver(source.close, TL2, iperiod) then
        oIndi.touch = 1;
        oIndi.pjcrs = 0;
        oIndi.pjval = TL2[iperiod];
        oIndi.pjpos = iperiod;
        oIndi.pdist = CalcRadius(zinfo.preVal, zinfo.prePos, oIndi.pjval, oIndi.pjpos, oIndi.sunit);
    end
    if oIndi.pdist ~= 0 then
        PL1[iperiod] = GetArc(oIndi.pdist*0.9, oIndi.pjval, oIndi.pjpos, oIndi.sunit, iperiod);
        PL2[iperiod] = GetArc(oIndi.pdist*1.9, oIndi.pjval, oIndi.pjpos, oIndi.sunit, iperiod);
    end
    if oIndi.pdist<0 and core.crossesUnder(source.close, PL1, iperiod) then oIndi.pjcrs=-1; oIndi.smask=1; end
    if oIndi.pdist>0 and core.crossesOver(source.close, PL1, iperiod) then oIndi.pjcrs=1; oIndi.smask=-1; end
    if oIndi.pdist<0 and core.crossesUnder(source.close, PL2, iperiod) then oIndi.pdist=0; oIndi.touch=0; oIndi.smask=0; end
    if oIndi.pdist>0 and core.crossesOver(source.close, PL2, iperiod) then oIndi.pdist=0; oIndi.touch=0; oIndi.smask=0; end
        
end
function GetConsecutive(source, dire, iperiod)
    local consec = 0;
    for i=iperiod, math.max(iperiod-12,source:first()+4), -1 do
        if (source.close[i]-source.close[i-4])*dire > 0 then consec = consec + 1; else break; end
    end
    return consec;
end
function CalcRadius(vstart, pstart, vend, pend, sunit)
    return math.sqrt(math.pow(vend-vstart,2) + math.pow((pend-pstart)*sunit,2));
end
function GetArc(radius, vstart, pstart, sunit, iperiod)
    local arc = nil; 
    if iperiod <= pstart then return arc end
    if math.pow(radius,2)-math.pow((iperiod-pstart)*sunit,2)>0 then
        if radius < 0 then arc = vstart - math.sqrt(math.pow(radius,2)-math.pow((iperiod-pstart)*sunit,2));
            else arc = math.sqrt(math.pow(radius,2)-math.pow((iperiod-pstart)*sunit,2)) + vstart; end
    else
        arc = vstart;
    end
    return arc;
end

function ResetSeqinfo(oSeq, sc)
    if sc == 0 then
        oSeq.SInterval = oPara.pSint;
        oSeq.CInterval = oPara.pCint;
        oSeq.Completed = 0;
        oSeq.PreSEnd = 0;
        oSeq.PreCEnd = 0;
        oSeq.StopLevel = 0;
        oSeq.StrdLevel = 0;
        oSeq.SBrkLevel = 0;
        oSeq.SRevLevel = 0;
        oSeq.DistanceA = 0;
        oSeq.DistanceB = 0;
        oSeq.DistanceC = 0;
        oSeq.DigestA = 0;
        oSeq.DigestB = 0;
        oSeq.DigestC = 0;
        oSeq.STrndCont = 0;
        oSeq.DigsCont = 0;
        oSeq.DigsMask = 0;
        oSeq.PreSign = 0;
        oSeq.OuterBL = 0;
        oSeq.OuterPos = 0;
    end
    if sc == 0 or sc == 1 then
        oSeq.SSeek = 0;
        oSeq.Setup = 0;
        oSeq.SStart = 0;
        oSeq.SEnd = 0;
        oSeq.SPerfect = 0;
        oSeq.SCriteria = 0;
        oSeq.SStradPos = 0;
        oSeq.SCnlCount = 0;
    end
    if sc == 0 or sc == 2 then
        oSeq.CSeek = 0;
        oSeq.Countdown = 0;
        oSeq.CStart = 0;
        oSeq.CEnd = 0;
        oSeq.CQualifier = 0;
        oSeq.ConsSetup = 0;
        oSeq.CStraddle = 0;
    end
    return oSeq;
end

function SetDecision(oSeq, source, iperiod)
    if oSeq.SSeek < 0 then
        oSeq.SRevLevel = core.max(source.high, core.range(oSeq.SStart, iperiod));
        oSeq.SBrkLevel = core.min(source.low, core.range(oSeq.SStart, iperiod));
        oSeq.StopLevel = core.min(source.low, core.range(oSeq.SStart, iperiod))-GetStopIncre(source, iperiod);
        oSeq.StrdLevel = core.max(source.high, core.range(oSeq.SStradPos, iperiod));
    else
        oSeq.SRevLevel = core.min(source.low, core.range(oSeq.SStart, iperiod));
        oSeq.SBrkLevel = core.max(source.high, core.range(oSeq.SStart, iperiod));
        oSeq.StopLevel = core.max(source.high, core.range(oSeq.SStart, iperiod))+GetStopIncre(source, iperiod);
        oSeq.StrdLevel = core.min(source.low, core.range(oSeq.SStradPos, iperiod));
    end
    if oSeq.ConsSetup < 2 then 
        oSeq.DistanceA = oSeq.SBrkLevel - oSeq.SCriteria;
        oSeq.DistanceB = oSeq.SBrkLevel - oSeq.SCriteria;
        oSeq.DistanceC = oSeq.SBrkLevel - oSeq.SRevLevel;
    else
        if oSeq.SSeek < 0 then
            oSeq.DistanceA = oSeq.SBrkLevel - core.max(source.high, core.rangeTo(iperiod, oSeq.ConsSetup*9 -5));
            oSeq.DistanceB = oSeq.SBrkLevel - core.max(source.high, core.rangeTo(iperiod, oSeq.ConsSetup*9 -5));
            oSeq.DistanceC = oSeq.SBrkLevel - core.max(source.high, core.rangeTo(iperiod, oSeq.ConsSetup*9));
        else
            oSeq.DistanceA = oSeq.SBrkLevel - core.min(source.low, core.rangeTo(iperiod, oSeq.ConsSetup*9 -5));
            oSeq.DistanceB = oSeq.SBrkLevel - core.min(source.low, core.rangeTo(iperiod, oSeq.ConsSetup*9 -5));
            oSeq.DistanceC = oSeq.SBrkLevel - core.min(source.low, core.rangeTo(iperiod, oSeq.ConsSetup*9));
        end
    end
    oSeq.STrndCont = 0;
    oSeq.DigestA = 0;
    oSeq.DigestB = 0;
    oSeq.DigestC = 0;
    if oSeq.DigsMask == 0 then 
        oSeq.DigsCont = 0;
    else
        oSeq.DigsMask = 0; 
        oSeq.DigsCont = 10;
    end
    
    oIndi.revslevel = oSeq.SRevLevel;
    return oSeq;
end

function GetStopIncre(sourcep, iperiod)
    local coef = 1;
    local barSize = sourcep:barSize();
    if string.sub(barSize,1,1)=="H" then
        local timeh = tonumber(string.sub(barSize,2,2));
    end
    local philo = core.max(sourcep.high, core.rangeTo(iperiod, oPara.pStpInc))
                - core.min(sourcep.low, core.rangeTo(iperiod, oPara.pStpInc));
    return philo*coef;
end

function SetSetup(source, oSeq, inSeq, iperiod)
    local stratshow = 6;
    local posofs = 6;
    local hilo;
    local symary;
    local clrSet;
    if inSeq < 0 then
        hilo = source.low;
        symary = symup;
        clrSet = instance.parameters.clrBSET;
    else
        hilo = source.high;
        symary = symdn;
        clrSet = instance.parameters.clrSSET;
    end
    local spos = hilo[iperiod]+oPara.sunit*posofs*inSeq;
    local bCancel = false;
    if oSeq.SCnlCount > 0 then
        bCancel = true;
    end

    if bCancel then
        oSeq = ResetSeqinfo(oSeq, 1);
      
    elseif oSeq.Setup == 0 then
        if (source.close[iperiod]-source.close[iperiod-oSeq.SInterval])*inSeq > 0 then
            oSeq.SSeek = inSeq;
            oSeq.Setup = 1;
            oSeq.SStart = iperiod;
            oSeq.SEnd = iperiod;
        end
    elseif oSeq.SEnd == iperiod-1 then
        if (source.close[iperiod]-source.close[iperiod-oSeq.SInterval])*oSeq.SSeek > 0 then
            oSeq.Setup = oSeq.Setup+1;
            oSeq.SEnd = iperiod;
	        if oSeq.Setup>=stratshow and instance.parameters.ShowNumber then 
	            STU:set(iperiod, spos, tostring(oSeq.Setup), nil, clrSet); end
	        if oSeq.Setup == 6 then
                oSeq.SStradPos = iperiod;
	            if oSeq.SSeek < 0 then
	                oSeq.SCriteria = source.high[iperiod];
	                if source.high[iperiod]-source.low[oSeq.PreSEnd] < 0 then oSeq.SThrough=true else oSeq.SThrough=flase end
	            else
	                oSeq.SCriteria = source.low[iperiod];
	                if source.low[iperiod]-source.high[oSeq.PreSEnd] > 0 then oSeq.SThrough=true else oSeq.SThrough=flase end
	            end
                if oSeq.SThrough and (iperiod - oSeq.PreSEnd) == oSeq.Setup and oSeq.Completed == oSeq.SSeek then
                    if instance.parameters.ShowSignal then
	                    TDS:set(oSeq.PreSEnd, hilo[oSeq.PreSEnd]+oPara.sunit*posofs*inSeq, symary[10], nil, clrSet);
                    end
                end
	        end
	        if oSeq.Setup == 7 then
	            if oSeq.SSeek < 0 then
	                oSeq.SPerfect = core.min(hilo, core.rangeTo(iperiod, 2));
	            else
	                oSeq.SPerfect = core.max(hilo, core.rangeTo(iperiod, 2));
	            end
	        end
	        if oSeq.Setup > 7 and (hilo[iperiod]-oSeq.SPerfect)*oSeq.SSeek <= 0 then
                if instance.parameters.ShowNumber then STU:set(iperiod, spos, "0", nil, clrSet) end
                oSeq.SStradPos = oSeq.SStradPos - 1;
	        end
	        if oSeq.Setup == 9 then
                if instance.parameters.ShowSignal then 
                    if oIndi.smask*oSeq.SSeek > 0 then
                        if (hilo[iperiod]-oSeq.SPerfect)*oSeq.SSeek <= 0 then 
                        TDS:set(iperiod, spos, symary[3], nil, clrSet) 
                        else
                        TDS:set(iperiod, spos, symary[4], nil, clrSet) 
                        end
                    else
                        if (hilo[iperiod]-oSeq.SPerfect)*oSeq.SSeek <= 0 then 
                        TDS:set(iperiod, spos, symary[8], nil, clrSet) 
                        else
                        TDS:set(iperiod, spos, symary[9], nil, clrSet) 
                        end
                        if math.abs(oIndi.smask) == 1 then oIndi.smask = oIndi.smask*-2 end
                    end
                end
                if oSeq.Completed == oSeq.SSeek then
                    if (iperiod - oSeq.PreSEnd) == oSeq.Setup and oSeq.ConsSetup > 1 then oSeq.ConsSetup = oSeq.ConsSetup+1;
                    elseif (iperiod - oSeq.PreSEnd) == oSeq.Setup then oSeq.ConsSetup = 2;
                    elseif (iperiod - oSeq.PreSEnd - oSeq.Setup) < oSeq.SInterval then oSeq.ConsSetup = 1;
                    else oSeq.ConsSetup = 0; end
                end
                SetDecision(oSeq, source, iperiod);
                oSeq.PreSign = iperiod;
                oSeq.PreSEnd = iperiod;
                oSeq.Completed = oSeq.SSeek;
                oSeq = ResetSeqinfo(oSeq, 1);
	        end
        else
	        if oSeq.Setup == 8 and iperiod-oSeq.PreSign > 4 then
                if instance.parameters.ShowSignal then 
                    if oIndi.smask*oSeq.SSeek > 0 then
                        TDS:set(iperiod, spos, symary[3], nil, clrSet) 
                    else
                        TDS:set(iperiod, spos, symary[8], nil, clrSet) 
                        if math.abs(oIndi.smask) == 1 then oIndi.smask = oIndi.smask*-2 end
                    end
                end
	            oSeq.ConsSetup = 0;  
                SetDecision(oSeq, source, iperiod);
                oSeq.PreSign = iperiod;
                oSeq.PreSEnd = iperiod;
                oSeq.Completed = oSeq.SSeek;
	        end
            oSeq = ResetSeqinfo(oSeq, 1);
        end
    end
    return oSeq;
end

function SetCountdown(source, oSeq, inSeq, iperiod)
    local stratshow = 10;
    local posofs = 8;
    local hilo;
    local symary;
    local clrCount;
    if inSeq < 0 then
        hilo = source.low;
        symary = symup;
        clrCount = instance.parameters.clrBCOUNT;
    else
        hilo = source.high;
        symary = symdn;
        clrCount = instance.parameters.clrSCOUNT;
    end
    local spos = hilo[iperiod]+oPara.sunit*posofs*inSeq;
    local bCancel = false;
    if inSeq*oSeq.CSeek < 0 then
        bCancel = true;
    end
    if (hilo[iperiod]-oSeq.SRevLevel)*oSeq.CSeek < 0 and (source.close[iperiod-1]-oSeq.SRevLevel)*oSeq.CSeek < 0 then
        bCancel = true;
    end
    if (oSeq.ConsSetup) > 0 then
        bCancel = true;
    end
        
    if bCancel then
        oSeq = ResetSeqinfo(oSeq, 2);
    
    elseif oSeq.Countdown == 0 then
        if (source.close[iperiod]-hilo[iperiod-oSeq.CInterval])*inSeq >= 0 then
            oSeq.CSeek = inSeq;
            oSeq.Countdown = 1;
            oSeq.CStart = iperiod;
            oSeq.CEnd = iperiod;
        end
    else
        if (source.close[iperiod]-hilo[iperiod-oSeq.CInterval])*oSeq.CSeek >= 0 then
            oSeq.Countdown = oSeq.Countdown+1;
            oSeq.CEnd = iperiod;
	        if oSeq.Countdown == 8 then
	            oSeq.CQualifier = source.close[iperiod];
	            if oSeq.CSeek < 0 then
	                oSeq.CStraddle = source.high[iperiod];
	            else
	                oSeq.CStraddle = source.low[iperiod];
	            end
	        end
	        if oSeq.Countdown > 12 and (hilo[iperiod]-oSeq.CQualifier)*oSeq.CSeek < 0 then
                oSeq.Countdown = 12;
	        end
	        if oSeq.Countdown == 13 then
                if instance.parameters.ShowSignal then 
                    if oIndi.smask*oSeq.CSeek > 0 then
                        TDS:set(iperiod, spos, symary[5], nil, clrCount) 
                    else
                        if (hilo[iperiod-1]-oSeq.CQualifier)*oSeq.CSeek < 0 then
                        TDS:set(iperiod, spos, symary[12], nil, clrCount) 
                        else
                        TDS:set(iperiod, spos, symary[13], nil, clrCount) 
                        end
                    end
                end
	            if oSeq.CSeek < 0 then
	                oSeq.StopLevel = core.min(hilo, core.rangeTo(iperiod, 8))-GetStopIncre(source, iperiod);
	            else
	                oSeq.StopLevel = core.max(hilo, core.rangeTo(iperiod, 8))+GetStopIncre(source, iperiod);
	            end
                oSeq.PreSign = iperiod;
                oSeq.PreCEnd = iperiod;
                oSeq.Completed = oSeq.CSeek;
                oSeq.StrdLevel = oSeq.CStraddle;
                oSeq.DigsMask = oSeq.CSeek;
                oSeq = ResetSeqinfo(oSeq, 2);
                
	        end
        end
    end
    return oSeq;
end

function SetDigest(source, oSeq, iperiod)
    local posofs = 10;
    local bhilo;     
    local symary;
    local symdigest = 2;
    local clrSet;
    local clrCount;
    local spos;
    local pval, ppos;
    local peakpos = 0;
    local compliant;
    
    if oSeq.Completed < 0 then
        bhilo = source.high[iperiod];
        symary = symdn;
        clrSet = instance.parameters.clrSSET;
        spos = source.high[iperiod]+oPara.sunit*posofs;
        pval, peakpos = core.min(source.low, core.rangeTo(iperiod, 9));
        compliant = not IsAccelerate(source, iperiod, 1) and oIndi.mtrnd*oSeq.Completed > 0;
    elseif oSeq.Completed > 0 then
        bhilo = source.low[iperiod];
        symary = symup;
        clrSet = instance.parameters.clrBSET;
        spos = source.low[iperiod]+oPara.sunit*posofs*-1;
        pval, peakpos = core.max(source.high, core.rangeTo(iperiod, 9));
        compliant = not IsAccelerate(source, iperiod, -1) and oIndi.mtrnd*oSeq.Completed > 0;
    end
    if peakpos > 0 and oSeq.DigsCont < 1 then 
        if oSeq.DistanceA ~= 0 and (source.close[iperiod]-oSeq.SBrkLevel)*oSeq.Completed > 0 then 
            oSeq.DistanceA = 0;
        end
        if oSeq.DistanceA * (source.close[iperiod]-source.close[iperiod-1]) < 0 then
            if (source.close[iperiod]-source.close[iperiod-1]) < 0 then
                oSeq.DigestA = oSeq.DigestA + (source.low[iperiod]-math.max(source.close[iperiod-1],source.high[iperiod]));
            else
                oSeq.DigestA = oSeq.DigestA + (source.high[iperiod]-math.min(source.close[iperiod-1],source.low[iperiod]));
            end
        else
            if (source.close[iperiod]-source.close[iperiod-1]) < 0 then
                oSeq.DigestA = oSeq.DigestA + (source.low[iperiod]-math.max(source.close[iperiod-1],source.open[iperiod])) + (source.close[iperiod]-source.high[iperiod]);
            else
                oSeq.DigestA = oSeq.DigestA + (source.high[iperiod]-math.min(source.close[iperiod-1],source.open[iperiod])) + (source.close[iperiod]-source.low[iperiod]);
            end
        end
        if oSeq.DistanceB ~= 0 and (source.close[iperiod]-(oSeq.StopLevel+oSeq.SBrkLevel)/2)*oSeq.Completed > 0 then 
            oSeq.DistanceB = 0;
        end
        if oSeq.DistanceB * (source.close[iperiod]-source.close[iperiod-1]) < 0 then
            oSeq.DigestB = oSeq.DigestB + (source.close[iperiod]-source.close[iperiod-1]); 
        end
        if oSeq.DistanceC ~= 0 and (source.close[iperiod]-oSeq.StopLevel)*oSeq.Completed > 0 then 
            oSeq.DistanceC = 0;
        end
        if oSeq.DistanceC * (source.close[iperiod]-source.close[iperiod-1]) < 0 then
            oSeq.DigestC = oSeq.DigestC + (source.close[iperiod]-source.close[iperiod-1]); 
        end
        if oSeq.DistanceA * (oSeq.DistanceA+oSeq.DigestA) < 0 then
            oSeq.DistanceA = 0;
            if compliant and InRange(source, peakpos+3, oSeq.PreSEnd+15, iperiod)  
            and (source.close[iperiod]-oSeq.StrdLevel)*oSeq.Completed > 0 then 
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symdigest], nil, clrSet); end
                oSeq.DigsCont=oSeq.DigsCont+1; 
                oSeq.PreSign = iperiod;
            end
        end
        if oSeq.DistanceB * (oSeq.DistanceB+oSeq.DigestB) < 0 then
            oSeq.DistanceB = 0;
            if compliant and InRange(source, peakpos+4, oSeq.PreSEnd+18, iperiod)  
            and (source.close[iperiod]-oSeq.StrdLevel)*oSeq.Completed > 0 then 
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symdigest], nil, clrSet); end
                oSeq.DigsCont=oSeq.DigsCont+2; 
                oSeq.PreSign = iperiod;
            end
        end
        if oSeq.DistanceC * (oSeq.DistanceC+oSeq.DigestC) < 0 and oSeq.PreSEnd > 28 then
            oSeq.DistanceC = 0;
            if oSeq.Completed < 0 then
                pval, ppos = core.max(source.high, core.rangeTo(oSeq.PreSEnd, 28));
            else
                pval, ppos = core.min(source.low, core.rangeTo(oSeq.PreSEnd, 28));
            end
            if compliant and InRange(source, peakpos+4, oSeq.PreSEnd+21, iperiod)  
            and (source.close[iperiod]-pval)*oSeq.Completed > 0 then 
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symdigest], nil, clrSet); end
                oSeq.DigsCont=oSeq.DigsCont+3; 
                oSeq.PreSign = iperiod;
            end
        end
        if oSeq.DigsCont < 2 and oSeq.Setup >= 6 then
            if compliant and InRange(source, peakpos+6, oSeq.PreSEnd+21, iperiod)  
            and (source.close[iperiod]-oSeq.SRevLevel)*oSeq.Completed < 0 then 
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symdigest], nil, clrSet); end
                oSeq.DigsCont=oSeq.DigsCont+4; 
                oSeq.PreSign = iperiod;
            end
        end
    end        
end
function InRange(source, pfr, pto, iperiod)
    if iperiod-pfr >= 0 and pto-iperiod >= 0 then return true else return false end
end

function IsAccelerate(source, iperiod, updn)
    local accel = false;
    local pval, ppos;
    local cdir = 0;
    if iperiod-source:first() > 10 then
        if updn < 0 then 
            pval, ppos = core.max(source.high, core.rangeTo(iperiod, 9));
            pval = core.min(source.close, core.range(iperiod-8, ppos));
            if (source.high[iperiod]-source.high[iperiod-1])*updn > 0
            and (source.high[iperiod-1]-source.high[iperiod-2])*updn > 0
            and (source.high[iperiod-2]-source.high[iperiod-3])*updn > 0
            then accel = true end
        else
            pval, ppos = core.min(source.low, core.rangeTo(iperiod, 9));
            pval = core.max(source.close, core.range(iperiod-8, ppos));
            if (source.low[iperiod]-source.low[iperiod-1])*updn > 0
            and (source.low[iperiod-1]-source.low[iperiod-2])*updn > 0
            and (source.low[iperiod-2]-source.low[iperiod-3])*updn > 0
            then accel = true end
        end
        if iperiod-ppos >= 3 then
            for i=iperiod-3, iperiod do
                if (source.close[i]-source.open[i])*updn > 0 then cdir=cdir+1 end
            end
            if accel and cdir > 2 then accel = true end
        else
            if (source.close[iperiod]-pval)*updn > 0 then accel = true end
        end
    end
    
    return accel;
end

function SetForce(source, oSeq, iperiod)
    local posofs = 10;
    local bhilo;     
    local symary;
    local symforce = 1;
    local clrSet;
    local clrCount;
    local spos;
    local pval, ppos;
    
    if math.abs(oSeq.Completed) == 1 then
        if oSeq.Completed < 0 then
            bhilo = source.high[iperiod];
            symary = symdn;
            clrSet = instance.parameters.clrSSET;
            spos = source.high[iperiod]+oPara.sunit*posofs;
        else
            bhilo = source.low[iperiod];
            symary = symup;
            clrSet = instance.parameters.clrBSET;
            spos = source.low[iperiod]+oPara.sunit*posofs*-1;
        end
        
        if oSeq.STrndCont < 1 and (source.close[iperiod]-oSeq.StopLevel)*oSeq.Completed > 0  
        and iperiod-oSeq.PreSEnd < 4 and iperiod-source:first() > 40 then 
            if iperiod-zinfo.prePos < 18 then
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symforce], nil, clrSet); end
                oSeq.STrndCont=1;
            end
        end
    end

    if oPara.pTPR then
        if core.crossesUnder(source.close, BL2, iperiod) then oSeq.OuterBL = -1; oSeq.OuterPos = iperiod; end
        if oSeq.OuterBL < 0 and source.close[iperiod] > BL2[iperiod] then oSeq.OuterBL = 0 end
        if oSeq.OuterBL < 0 and iperiod-oSeq.OuterPos > 4 and oIndi.pjcrs < 0 then
            pval, ppos = core.min(source.low, core.rangeTo(iperiod, 13));
            if iperiod-oSeq.PreSign > 6 and iperiod-ppos == 5 then
                symary = symup;
                clrSet = instance.parameters.clrBSET;
                spos = source.low[iperiod]+oPara.sunit*posofs*-1;
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symforce], nil, clrSet); end
                oSeq.StopLevel = pval*2 - source.high[iperiod];
                oSeq.StrdLevel = BL1[iperiod];
            end
        end
        if core.crossesOver(source.close, TL2, iperiod) then oSeq.OuterBL = 1; oSeq.OuterPos = iperiod; end
        if oSeq.OuterBL > 0 and source.close[iperiod] < TL2[iperiod] then oSeq.OuterBL = 0 end
        if oSeq.OuterBL > 0 and iperiod-oSeq.OuterPos > 4 and oIndi.pjcrs > 0 then
            pval, ppos = core.max(source.high, core.rangeTo(iperiod, 13));
            if iperiod-oSeq.PreSign > 6 and iperiod-ppos == 5 then
                symary = symdn;
                clrSet = instance.parameters.clrSSET;
                spos = source.high[iperiod]+oPara.sunit*posofs;
                if instance.parameters.ShowSignal then TDS:set(iperiod, spos, symary[symforce], nil, clrSet); end
                oSeq.StopLevel = pval*2 - source.low[iperiod];
                oSeq.StrdLevel = TL1[iperiod];
            end
        end
    end
    
end


function SetStopLevel(sourcep, oSeq, iperiod)
    local psl = math.max(oSeq.PreSEnd, oSeq.PreCEnd);
    psl = math.min(psl, iperiod-3);
    local prl = math.max(sourcep:first(),psl-8);

    for i=prl-10, iperiod do BSL[i]=nil; RSL[i]=nil; end
    core.drawLine(BSL, core.range(psl,iperiod), oSeq.StopLevel, psl, oSeq.StopLevel, iperiod); 
    core.drawLine(RSL, core.range(prl,iperiod), oSeq.SRevLevel, prl, oSeq.SRevLevel, iperiod); 
end

function SetATL(sourcep, M, iperiod)
    local ZZW = core.makeArray(sourcep:size());
    local pfr = 0;
    local pto = 0;
    local pos1 = 0;
    local pos2 = 0;
    local value1 = 0;
    local value2 = 0;
    local sourcehl;

    SetZZP(ZZW, sourcep, M);
    for updn = -1, 1, 2 do
        pfr, pto = GetLastWave(ZZW, sourcep:size()-1, updn);
        if pto - pfr > 5 then
            if updn < 0 then
                sourcehl = sourcep.high;
            else
                sourcehl = sourcep.low;
            end
            value1, value2 = GetRegressionPoint(sourcehl, pfr, pto);
            core.drawLine(SLR, core.range(pfr, pto), value1, pfr, value2, pto);
            pos1, pos2 = Find2Peak(PVW, SLR, sourcehl, pfr, pto, updn);
            if updn < 0 then
                for i=sourcep:first(), iperiod do DTL[i]=nil end
                core.drawLine(DTL, core.range(pos1, sourcep:size()-1), sourcehl[pos1], pos1, sourcehl[pos2], pos2);
            else
                for i=sourcep:first(), iperiod do UTL[i]=nil end
                core.drawLine(UTL, core.range(pos1, sourcep:size()-1), sourcehl[pos1], pos1, sourcehl[pos2], pos2);
            end
        end
    end
end

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
    if (ZZP[peaka[3]]-ZZP[peaka[2]]) * updown > 0 then
        peakb = peaka[2];
        peake = peaka[3];
    else
        peakb = peaka[1];
        peake = peaka[2];
    end 
    if peakb < 0 then peakb = 0 end	
    if peake > srclast then peake = srclast end
    
	return peakb, peake;
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
    
    for i = pos1, pos2 do
        PVW[i] = sourcep[i] - SLR[i];
    end
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
            if (PVW[peak1]-PVW[peak3])*updown > 0 then peak1, peak3 = peak3, peak1; end
            peak3 = peak4;
            end
        else
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


