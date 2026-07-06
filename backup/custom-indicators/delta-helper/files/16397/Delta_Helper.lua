-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7353
-- Id: 4788

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator is Richard Tao detla line

function Init()
    indicator:name("RichardTaoDeltaTimeLine");
    indicator:description("Richard Tao Delta Time Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addString("SELC", "Select", "", "STD");
    indicator.parameters:addStringAlternative("SELC", "STD", "", "STD");
    indicator.parameters:addStringAlternative("SELC", "ITD", "", "ITD");
    indicator.parameters:addStringAlternative("SELC", "MTD", "", "MTD");
    indicator.parameters:addStringAlternative("SELC", "LTD", "", "LTD");
    indicator.parameters:addInteger("N", "Wave Minimum", "", 5, 3, 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("DL", "Display Line", "", true);   
    indicator.parameters:addColor("clrR", "RColor", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrB", "BColor", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrO", "OColor", "", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clrG", "GColor", "", core.rgb(0, 255, 0));
end

local source = nil;
local ZZW = nil;
local R,B,O,G,D;
local barh = 30000;

local strln="";
local posln=0;
local sunit=0;
local prevl=0;
local lastbar = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.SELC .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert (string.sub(source:barSize(),1,1)~="m", "The chosen time frame must be bigger than H1!");

    R = instance:addStream("R", core.Bar, name .. ".R", "R", instance.parameters.clrR, 0);
    B = instance:addStream("B", core.Bar, name .. ".B", "B", instance.parameters.clrB, 0);
    O = instance:addStream("O", core.Bar, name .. ".O", "O", instance.parameters.clrO, 0);
    G = instance:addStream("G", core.Bar, name .. ".G", "G", instance.parameters.clrG, 0);
    if instance.parameters.DL then
        barh = 30000;
    else
        barh = 0;
    end
    D = instance:createTextOutput("D", "D", "Arial", 8, core.H_Center, core.V_Center, instance.parameters.clrG, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    if period == source:first() then
        InitialUpdate(source, instance.parameters.N);
    end
    
    if period > source:first() and period < source:size() - 1 then
		local ln;
		if instance.parameters.SELC == "STD" then
			ln = GetSTDline(source, period);
		end
		if instance.parameters.SELC == "ITD" then
			ln = GetITDline(source, period);
		end
		if instance.parameters.SELC == "MTD" then
			ln = GetMTDline(source, period);
		end
		if instance.parameters.SELC == "LTD" then
			ln = GetLTDline(source, period);
		end
		if ln ~= nil then
			if ln == 0 then R[period]=barh; posln=period; strln="R"; end
			if ln == 1 then B[period]=barh; posln=period; strln="B"; end
			if ln == 2 then O[period]=barh; posln=period; strln="O"; end
			if ln == 3 then G[period]=barh; posln=period; strln="G"; end
		end
		--display position
		local offset = 0;
		local clrln = core.rgb(255, 255, 255);
		if ZZW[period] > 0 then
			if ZZW[period]-prevl < 0 then offset = sunit*-10; else offset = sunit*10; end
			if strln == "R" then clrln = instance.parameters.clrR; end
			if strln == "B" then clrln = instance.parameters.clrB; end
			if strln == "O" then clrln = instance.parameters.clrO; end
			if strln == "G" then clrln = instance.parameters.clrG; end
	        
			D:set(period, ZZW[period]+offset, "+" .. tostring(period-posln), nil, clrln); 
			prevl = ZZW[period];
		end
    end
    if (period == source:size() - 1) and lastbar ~= source:date(period) then
        lastbar = source:date(period);
        instance:updateFrom(source:first());
    end
end

function GetSTDline(source, period)
    local dtp = core.dateToTable( source:date(period-1) );
    local dt = core.dateToTable( source:date(period) );
    local remainder = nil;

    if dt.day~=dtp.day then 
        remainder = math.fmod(math.floor(source:date(period)), 4); 
    end
    return remainder;
end
function GetITDline(source, period)
    local dtp = core.dateToTable( source:date(period-1) );
    local dt = core.dateToTable( source:date(period) );
    local remainder = nil;
    local val2000 = 36561;
    local dperm = 29.5306;
    
    if dt.day~=dtp.day then 
        local mtp = math.floor((source:date(period-1)-val2000)/dperm);
        local mt = math.floor((source:date(period)-val2000)/dperm);
        if mt - mtp > 0 then
            remainder = math.fmod(mt, 4); 
        end
    end
    return remainder;
end
function GetMTDline(source, period)
    local dtp = core.dateToTable( source:date(period-1) );
    local dt = core.dateToTable( source:date(period) );
    local remainder = nil;
    
    if dt.month == 12 and dtp.day < 22 and dt.day >= 22 then remainder = 0 end
    if dt.month == 3 and dtp.day < 21 and dt.day >= 21 then remainder = 1 end
    if dt.month == 6 and dtp.day < 22 and dt.day >= 22 then remainder = 2 end
    if dt.month == 9 and dtp.day < 24 and dt.day >= 24 then remainder = 3 end
    return remainder;
end
function GetLTDline(source, period)
    local dtp = core.dateToTable( source:date(period-1) );
    local dt = core.dateToTable( source:date(period) );
    local remainder = nil;

    if dt.year-dtp.year > 0 then 
        remainder = math.fmod(dt.year, 4); 
    end
    return remainder;
end

function InitialUpdate(source, N)
  if source:size()-source:first()>151 then 
    sunit = (core.max(source.high, core.rangeTo(source:size()-1,150)) 
            - core.min(source.low, core.rangeTo(source:size()-1,150))) / 150;
    ZZW = mathex.makeArray(source:size());
    SetZZP(ZZW, source, N);
  end  
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
