-- Id: 4722
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7022

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator is Richard Tao Wave segregate to gauge force
-- Richard Tao Predictor serials number 4

function Init()
    indicator:name("RichardTaoWaveForce");
    indicator:description("Richard Tao Wave Force");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 14);
    indicator.parameters:addInteger("S", "Slope in percentage", "", 25);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("ShowTag", "Show Tag", "", false);   
    indicator.parameters:addColor("clrFL", "flColor", "", core.rgb(128, 255, 0));
    indicator.parameters:addColor("clrUP", "upColor", "", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrDN", "dnColor", "", core.rgb(196, 0, 0));
    indicator.parameters:addColor("clrNET", "netColor", "", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local N;
local S;

-- Streams block
local U, D;
local PUP = nil;
local PDN = nil;
local NET = nil;
local TWN = nil;
local TAG = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    S = instance.parameters.S;
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. S .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

	U =instance:addInternalStream (first, 0);
	D =instance:addInternalStream (first, 0);
	
    PUP = instance:addStream("PUP", core.Bar, name .. ".PUP", "PUP", instance.parameters.clrFL, first);
    PUP:setPrecision(math.max(2, instance.source:getPrecision()));
    PDN = instance:addStream("PDN", core.Bar, name .. ".PDN", "PDN", instance.parameters.clrFL, first);
    PDN:setPrecision(math.max(2, instance.source:getPrecision()));
    NET = instance:addStream("NET", core.Line, name .. ".NET", "NET", instance.parameters.clrNET, first);
    NET:setPrecision(math.max(2, instance.source:getPrecision()));
    TWN = instance:addStream("TWN", core.Line, name .. ".TWN", "TWN", instance.parameters.clrFL, first);
    TWN:setPrecision(math.max(2, instance.source:getPrecision()));
    TWN:setStyle(core.LINE_NONE);
	
    TAG = instance:createTextOutput("TAG", "TAG", "Wingdings", 10, core.H_Center, core.V_Center, core.rgb(0, 64, 0), 0);
end

local zinfo = {};
local srcforw;
local srcback;
local tStart, tVal, tTrnd;
function Update(period, mode)
    if period == source:first() then
        initzinfo(zinfo, source, N, S);
    end
    if period > source:first() then
        if source.close[period]-source.close[period-1] < 0 then
            U[period] = 0;
            D[period] = source.close[period]-source.close[period-1];
        else
            U[period] = source.close[period]-source.close[period-1];
            D[period] = 0;
        end
        
        tStart, tVal, tTrnd = GetZstart(zinfo, source, period);
            
        PUP[period]= core.sum(U, tStart, period);		 
        PDN[period]= core.sum(D, tStart, period);
        NET[period]= tVal*-1 ;
        
        if tTrnd < 0 then
            if instance.parameters.ShowTag and core.crossesUnder(PDN, NET, period) then 
                if tTrnd == -4 then TAG:set(period, 0, "\221") else TAG:set(period, 0, "\222") end
            end
            if PDN[period]<NET[period] then
                PDN:setColor(period, instance.parameters.clrDN); 
                tTrnd= -6;
            else 
                PDN:setColor(period, instance.parameters.clrFL); 
            end
        else
            if instance.parameters.ShowTag and core.crossesOver(PUP, NET, period) then 
                if tTrnd == 4 then TAG:set(period, 0, "\222") else TAG:set(period, 0, "\221") end
            end
            if PUP[period]>NET[period] then
                PUP:setColor(period, instance.parameters.clrUP); 
                tTrnd= 6;
            else 
                PUP:setColor(period, instance.parameters.clrFL); 
            end
        end
        TWN[period]= tTrnd/1000;
    end
end

function initzinfo(zinfo, sourcep, lengthp, slopep)
    local srcfirst = sourcep:first();
    local srclast = sourcep:size() - 1;
    
    zinfo.rangev = core.max(sourcep.high, core.rangeTo(srclast, 150)) 
                    - core.min(sourcep.low, core.rangeTo(srclast, 150));
    zinfo.zleng = lengthp;
    zinfo.zback = zinfo.rangev / 100 * math.sqrt(lengthp) * 2;
    zinfo.slope = (zinfo.rangev / 100) * (slopep / 100);
    zinfo.markup = (zinfo.rangev / 100) * 2;
    zinfo.istrnd = true;

    zinfo.searchhl = 1;
    srcforw = sourcep.high;
    srcback = sourcep.low;
    zinfo.newVal = sourcep.close[srcfirst];
    zinfo.newPos = srcfirst;
    zinfo.preVal = zinfo.newVal;
    zinfo.prePos = 0;
    zinfo.extVal = 0;
    zinfo.thisturn = 0;
end
function GetZstart(zinfo, sourcep, iperiod)
        zinfo.zturn = 0;
        if (srcforw[iperiod]-zinfo.newVal- zinfo.slope*(iperiod-zinfo.newPos)*zinfo.searchhl)*zinfo.searchhl > 0 then
            if zinfo.istrnd then
                zinfo.newVal = srcforw[iperiod];
                zinfo.newPos = iperiod;
            else
                if zinfo.searchhl < 0 then
                    if iperiod-zinfo.prePos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.prePos, iperiod)) end
                elseif zinfo.searchhl > 0 then
                    if iperiod-zinfo.prePos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.prePos, iperiod)) end
                end
                if (zinfo.newVal-zinfo.preVal)*zinfo.searchhl > 0 then
                    zinfo.zturn = 0;
                    if zinfo.searchhl < 0 then
                        if iperiod-zinfo.prePos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.prePos, iperiod)) end
                    elseif zinfo.searchhl > 0 then
                        if iperiod-zinfo.prePos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.prePos, iperiod)) end
                    end
                else
                    zinfo.zturn = 1;
                end
                zinfo.istrnd = true;
            end
        end

        --check turn
        if zinfo.istrnd then
            if ( (srcback[iperiod]-zinfo.preVal)*zinfo.searchhl*-1 > 0 and (srcback[iperiod]-zinfo.newVal)*zinfo.searchhl*-1 > zinfo.zback ) then
                zinfo.zturn = 3;
            elseif (iperiod-zinfo.newPos >= zinfo.zleng) and (sourcep:hasData(zinfo.newPos-zinfo.zleng)) 
            and (srcback[iperiod]-srcback[zinfo.newPos-zinfo.zleng]- zinfo.slope*(iperiod-zinfo.newPos-zinfo.zleng)*zinfo.searchhl*-1)*zinfo.searchhl*-1 < 0 then
                zinfo.zturn = 4;
                zinfo.istrnd = false;
            elseif ( (iperiod-zinfo.newPos >= zinfo.zleng) and (srcback[iperiod]-zinfo.newVal)*zinfo.searchhl*-1 > zinfo.zback ) then
                zinfo.zturn = 2;
            end
        else
            if (srcback[iperiod]-zinfo.preVal- zinfo.markup*zinfo.searchhl*-1)*zinfo.searchhl*-1 > 0 
            and (srcback[iperiod]-zinfo.newVal)*zinfo.searchhl*-1 > zinfo.zback then
                zinfo.zturn = 5;
                zinfo.istrnd = true;
                if zinfo.searchhl < 0 then
                    zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.rangeTo(iperiod, zinfo.zleng)) 
                elseif zinfo.searchhl > 0 then
                    zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.rangeTo(iperiod, zinfo.zleng)) 
                end
            end
        end

        --turn
        if zinfo.zturn > 0 then
            zinfo.extVal = zinfo.newVal - zinfo.preVal;
            zinfo.prePos = zinfo.newPos;
            zinfo.preVal = zinfo.newVal;
            if zinfo.zturn > 1 then zinfo.searchhl = zinfo.searchhl * -1; end
            zinfo.thisturn = zinfo.zturn;
            
            if zinfo.searchhl < 0 then
                if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.min(sourcep.low, core.range(zinfo.newPos+2, iperiod)); end
                srcforw = sourcep.low;
                srcback = sourcep.high;
            elseif zinfo.searchhl > 0 then
                if iperiod-zinfo.newPos>2 then zinfo.newVal, zinfo.newPos = core.max(sourcep.high, core.range(zinfo.newPos+2, iperiod)); end
                srcforw = sourcep.high;
                srcback = sourcep.low;
            end
        end
    return zinfo.prePos, zinfo.extVal, zinfo.thisturn*zinfo.searchhl;      
end

