-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3610
-- Id: 18131

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
    indicator:name("RichardTaoTrendStatusChannel");
    indicator:description("Richard Tao Trend Status Channel with fill.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("T", "Timeframe", "", "D1");
    indicator.parameters:setFlag("T", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N1", "Number of periods 1", "", 34);
	indicator.parameters:addInteger("N2", "Number of periods 2", "", 55);
    indicator.parameters:addInteger("L", "Level of threshold", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP3", "UP3 Color", "", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrDN3", "DN3 Color", "", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clrUP2", "UP2 Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN2", "DN2 Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrUP1", "UP1 Color", "", core.rgb(128, 128, 0));
    indicator.parameters:addColor("clrDN1", "DN1 Color", "", core.rgb(255, 128, 0));
	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);

end

-- Parameters block
local N1;
local N2;
local L;
local aMa = {"EMA","MVA","LWMA","KAMA"};
local m = 3;

local firstPeriod;
local source = nil;

-- Streams block
local M11;
local M21;
local M31;
local M41;
local M12;
local M22;
local M32;
local M42;
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

-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    N1 = instance.parameters.N1;
	N2 = instance.parameters.N2;
    L = instance.parameters.L;
    source = instance.source;
    firstPeriod = source:first() + math.max(N1,N2) - 1 + m;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N1 .. ", " .. N2 .. ", " .. L .. ")";
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

    MAS11 = instance:addInternalStream(firstPeriod, 0);
    MAS21 = instance:addInternalStream(firstPeriod, 0);
    MAS31 = instance:addInternalStream(firstPeriod, 0);
    MAS41 = instance:addInternalStream(firstPeriod, 0);
	
	MAS12 = instance:addInternalStream(firstPeriod, 0);
    MAS22 = instance:addInternalStream(firstPeriod, 0);
    MAS32 = instance:addInternalStream(firstPeriod, 0);
    MAS42 = instance:addInternalStream(firstPeriod, 0);

    MA11 = instance:addInternalStream(firstPeriod, 0);
    MA21 = instance:addInternalStream(firstPeriod, 0);
    MA31 = instance:addInternalStream(firstPeriod, 0);
    MA41 = instance:addInternalStream(firstPeriod, 0);
	
	MA12 = instance:addInternalStream(firstPeriod, 0);
    MA22 = instance:addInternalStream(firstPeriod, 0);
    MA32 = instance:addInternalStream(firstPeriod, 0);
    MA42 = instance:addInternalStream(firstPeriod, 0);
    
    TSL1 = instance:addStream("TSL1", core.Line, name .. ".TSL1", "TSL1", instance.parameters.clrDN2, firstPeriod)	
    TSN1 = instance:addStream("TSN1", core.Line, name .. ".TSN1", "TSN1", instance.parameters.clrUP2, 0)	
    TSN1:setStyle(core.LINE_NONE);
	
	TSL2 = instance:addStream("TSL2", core.Line, name .. ".TSL2", "TSL2", instance.parameters.clrDN2, firstPeriod)	
    TSN2 = instance:addStream("TSN2", core.Line, name .. ".TSN2", "TSN2", instance.parameters.clrUP2, 0)	
    TSN2:setStyle(core.LINE_NONE);
	
	instance:createChannelGroup("TSLGroup","TSLG" , TSL1, TSL2, instance.parameters.clrUP1, 100-instance.parameters.Transparency);
end

-- Indicator calculation routine
local sunit
function Update(period, mode)
    if streamloading == true 
	then 
		return; 
	end
	
    if stream == nil 
	then
        stream, ostream = GetStream(instance.parameters.T);
        if ostream.external == false 
		then
            iperiod = PrepareStreamMA(stream);
        end
    else
        M11:update(mode);
        M21:update(mode);
        M31:update(mode);
        M41:update(mode);
		
		M12:update(mode);
        M22:update(mode);
        M32:update(mode);
        M42:update(mode);
		
        --set hashdata flag for external check
		
        TSN1[0] = 0;
		TSN2[0] = 0;
        
        iperiod = GetStreamPeriod(period, ostream, stream);
		
        if period > firstPeriod and M41.DATA:hasData(iperiod-m) 
		then
            --set InternalStream
            local MAS1,MA1,M1;
            for m=1, 4 do
                if m==1 then MAS1=MAS11; MA1=MA11; M1=M11; end
                if m==2 then MAS1=MAS21; MA1=MA21; M1=M21; end
                if m==3 then MAS1=MAS31; MA1=MA31; M1=M31; end
                if m==4 then MAS1=MAS41; MA1=MA41; M1=M41; end
                local delta1=0;
				if math.fmod(m, 2)==0 then
                    for i = 0, m-1 do
                        delta1 = delta1+(M1.DATA[iperiod-i]-M1.DATA[iperiod-i-1]);
                    end
                    delta1 = delta1/m; 
                else
                    delta1 = (M1.DATA[iperiod]-M1.DATA[iperiod-1]);					
                end
                MAS1[period] = (delta1) / sunit /1 *100; 				
                MA1[period] = M1.DATA[iperiod];
            end
            
            --display Status
            if MAS41:hasData(period-1) then
                TSL1[period] = MA41[period]; 
                TSN1[period] = GetTrendStatus(TSN1[period-1], L, period,1); 
                if TSN1[period] == -1 then TSL1:setColor(period, instance.parameters.clrDN1); end
                if TSN1[period] == 1 then TSL1:setColor(period, instance.parameters.clrUP1); end
                if TSN1[period] == -2 then TSL1:setColor(period, instance.parameters.clrDN2); end
                if TSN1[period] == 2 then TSL1:setColor(period, instance.parameters.clrUP2); end
                if TSN1[period] == -3 then TSL1:setColor(period, instance.parameters.clrDN3); end
                if TSN1[period] == 3 then TSL1:setColor(period, instance.parameters.clrUP3); end
            end
        end
		
		if period > firstPeriod and M42.DATA:hasData(iperiod-m) then
            --set InternalStream
            local MAS2,MA2,M2;
            for m=1, 4 do
                if m==1 then MAS2=MAS12; MA2=MA12; M2=M12; end
                if m==2 then MAS2=MAS22; MA2=MA22; M2=M22; end
                if m==3 then MAS2=MAS32; MA2=MA32; M2=M32; end
                if m==4 then MAS2=MAS42; MA2=MA42; M2=M42; end
                local delta2=0;
                if math.fmod(m, 2)==0 then
                    for i = 0, m-1 do
                        delta2 = delta2+(M2.DATA[iperiod-i]-M2.DATA[iperiod-i-1]);
                    end
                    delta2 = delta2/m; 
                else
                    delta2 = (M2.DATA[iperiod]-M2.DATA[iperiod-1]);					
                end
                MAS2[period] = (delta2) / sunit /1 *100; 				
                MA2[period] = M2.DATA[iperiod];
            end
            
            --display Status
			
			if MAS42:hasData(period-1) then
                TSL2[period] = MA42[period]; 
                TSN2[period] = GetTrendStatus(TSN2[period-1], L, period,2); 
                if TSN2[period] == -1 then TSL2:setColor(period, instance.parameters.clrDN1); end
                if TSN2[period] == 1 then TSL2:setColor(period, instance.parameters.clrUP1); end
                if TSN2[period] == -2 then TSL2:setColor(period, instance.parameters.clrDN2); end
                if TSN2[period] == 2 then TSL2:setColor(period, instance.parameters.clrUP2); end
                if TSN2[period] == -3 then TSL2:setColor(period, instance.parameters.clrDN3); end
                if TSN2[period] == 3 then TSL2:setColor(period, instance.parameters.clrUP3); end
            end
            
        end
		
		--if TS1[period]>TSL2[period] 
		--then
			--TSL1:setColor(period,instance.parameters.clrUP1);
		--else
			--TSL1:setColor(period,instance.parameters.clrDN1);
		--end
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
    M11 = core.indicators:create(aMa[1], stream.close, N1);
    assert(core.indicators:findIndicator(aMa[2]) ~= nil, aMa[2] .. " indicator must be installed");
    M21 = core.indicators:create(aMa[2], stream.close, N1);
    assert(core.indicators:findIndicator(aMa[3]) ~= nil, aMa[3] .. " indicator must be installed");
    M31 = core.indicators:create(aMa[3], stream.close, N1);
    assert(core.indicators:findIndicator(aMa[4]) ~= nil, aMa[4] .. " indicator must be installed");
    M41 = core.indicators:create(aMa[4], stream.close, N1);
	
	M12 = core.indicators:create(aMa[1], stream.close, N2);
    M22 = core.indicators:create(aMa[2], stream.close, N2);
    M32 = core.indicators:create(aMa[3], stream.close, N2);
    M42 = core.indicators:create(aMa[4], stream.close, N2);

    return 1;
end

function GetTrendStatus(tStatus, pMASL, period,flag)
    local swup = 1;
    local swdn = -1;
    local sdup = 2;
    local sddn = -2;
    local saup = 3;
    local sadn = -3;
    
    --phase for trend accelerate
	if flag == 1
	then
		if MAS41[period]<pMASL*-1 and core.crossesUnder(MA11, MA21, period) then tStatus=sadn; end
		if MAS41[period]>pMASL and core.crossesOver(MA11, MA21, period) then tStatus=saup; end
	elseif flag == 2
	then
		if MAS42[period]<pMASL*-1 and core.crossesUnder(MA12, MA22, period) then tStatus=sadn; end
		if MAS42[period]>pMASL and core.crossesOver(MA12, MA22, period) then tStatus=saup; end
	end

    --phase to trend decelerate : straddle
	if flag == 1
	then
		if MAS41[period]<pMASL*-1 and core.crossesOver(MA11, MA21, period) then tStatus=sddn; end
		if MAS41[period]>pMASL and core.crossesUnder(MA11, MA21, period) then tStatus=sdup; end
	elseif flag == 2
	then
		if MAS42[period]<pMASL*-1 and core.crossesOver(MA12, MA22, period) then tStatus=sddn; end
		if MAS42[period]>pMASL and core.crossesUnder(MA12, MA22, period) then tStatus=sdup; end
	end
    
    --phase to trend end : change
	if flag == 1
	then
		if (core.crossesUnder(MAS11, 0, period-1) or core.crossesUnder(MAS11, 0, period)) 
		and (core.crossesUnder(MAS31, 0, period-1) or core.crossesUnder(MAS31, 0, period)) 
		then 
			if MAS41[period]<pMASL*-1 
			then 
				tStatus=sddn; 
			else 
				tStatus=swdn; 
			end 
		end
		if (core.crossesOver(MAS11, 0, period-1) or core.crossesOver(MAS11, 0, period)) 
		and (core.crossesOver(MAS31, 0, period-1) or core.crossesOver(MAS31, 0, period)) 
		then 
			if MAS41[period]>pMASL 
			then 
				tStatus=sdup; 
			else 
				tStatus=swup; 
			end 
		end
	elseif flag == 2
	then
		if (core.crossesUnder(MAS12, 0, period-1) or core.crossesUnder(MAS12, 0, period)) 
		and (core.crossesUnder(MAS32, 0, period-1) or core.crossesUnder(MAS32, 0, period)) 
		then 
			if MAS42[period]<pMASL*-1 
			then 
				tStatus=sddn; 
			else 
				tStatus=swdn; 
			end 
		end
		if (core.crossesOver(MAS12, 0, period-1) or core.crossesOver(MAS12, 0, period)) 
		and (core.crossesOver(MAS32, 0, period-1) or core.crossesOver(MAS32, 0, period)) 
		then 
			if MAS42[period]>pMASL 
			then 
				tStatus=sdup; 
			else 
				tStatus=swup; 
			end 
		end
	end
    
    --phase to whipsaw : strangle
	if flag == 1
	then
		if core.crossesUnder(MAS41, pMASL, period) then tStatus=swdn; end
		if core.crossesOver(MAS41, pMASL*-1, period) then tStatus=swup; end
	elseif flag == 2
	then
		if core.crossesUnder(MAS42, pMASL, period) then tStatus=swdn; end
		if core.crossesOver(MAS42, pMASL*-1, period) then tStatus=swup; end
	end

    --phase for trend start
	if flag == 1
	then
		if core.crossesUnder(MAS41, pMASL*-1, period) then if MA11[period]<MA21[period] then tStatus=sadn else tStatus=sddn end end
		if core.crossesOver(MAS41, pMASL, period) then if MA11[period]>MA21[period] then tStatus=saup else tStatus=sdup end end
	elseif flag == 2
	then
		if core.crossesUnder(MAS42, pMASL*-1, period) then if MA12[period]<MA22[period] then tStatus=sadn else tStatus=sddn end end
		if core.crossesOver(MAS42, pMASL, period) then if MA12[period]>MA22[period] then tStatus=saup else tStatus=sdup end end
	end

    return tStatus;
end

