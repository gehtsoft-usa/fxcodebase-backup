
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=35595&p=60142#p60142

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

--[[ 

    Point and Figure only Version
    This indicator only draw the Point and Figure Chart No Signals Not Trendlines
    
    
    written 2013 by Gidien
]]--

function Init()
    indicator:name("P&F Only 1.1");
    indicator:description("Point & Figure Only V1.1");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Type", "Box Size Calculation Method", "" , "Pips");
    indicator.parameters:addStringAlternative("Type", "ATR", "" , "ATR");
    indicator.parameters:addStringAlternative("Type", "Percentage", "" , "Percentage");
    indicator.parameters:addStringAlternative("Type", "Pips", "" , "Pips");

    indicator.parameters:addInteger("BS", "Box Size (in pips)", "", 5, 1, 100000);
    indicator.parameters:addDouble("Percentage", "Box Size (Percentage)", "", 0.2, 0.1 , 20);
    indicator.parameters:addInteger("RS", "Reversal Count (in boxes)", "", 3, 1, 100);
    indicator.parameters:addInteger("ATRFrame", "ATR Period", "", 14, 2, 1000);    
    indicator.parameters:addDouble("Multiplier", "ATR Multiplier", "", 1, 0.1 , 100);
     
    indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "" ,  false);

    indicator.parameters:addGroup("Source TimeFrame");
    indicator.parameters:addString(   "TF", "TF", "Source Time frame ('m1', 'm5', etc.)", "m1");
    indicator.parameters:setFlag(   "TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("MC", "MaxRows", "", 200, 100, 1000);    

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FSize", "Font Size", "", 8, 2, 1000);    
    indicator.parameters:addString("FName", "Font Name", "", "Courier");    
    indicator.parameters:addColor("Bull", "Color of X's", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Bear", "Color of O's", "", core.COLOR_DOWNCANDLE );    
    indicator.parameters:addColor("N", "Color of Next", "Color of Next Row or Column", core.rgb(128,128,128) );    
    
    indicator.parameters:addGroup("Candle Color");
    indicator.parameters:addColor("B", "DO NOT CHANGE", "Automatic Candle Color Set to Chart Background Color , if you change it, then Candle will be visible", core.COLOR_BACKGROUND );    
end

local point = nil;
local first;
local BS, RS;
local Percentage;
local ATRFrame;
local ATR;
local Ignore;
local Multiplier;
local source_low,source_high;
local Type;
local source = nil;
local i;
local Debug;
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local volume = nil;

local TEST=true;
local lineCount = 0;

local Support;
local Resistance;

local Up={};
local Down={};

-- Style ---------------------
local Bull;
local Bear;
local Transparency;

local sF;

local initFirst = true;

-- New Code
local pf         = {close={},open={},period=0,swing=nil,flag=nil,update=false,move=false};
local lastPeriod = 0;
local up ="X";
local dn ="O";
local oT = {};
local isLoaded = false;

function Prepare(nameOnly)
    assert(instance.parameters.TF ~= "t1", "The Indicator cannot be applied on ticks.");
    point           = instance.source:pipSize();
    
    if instance.parameters.TF == instance.source:barSize() then
        source          = instance.source;
        isLoaded = true;
    else
        source = core.host:execute ("getSyncHistory", instance.source:instrument(), instance.parameters.TF, instance.source:isBid(), 300, 1, 2)
    end
    first           = source:first()+2;

    Type            = instance.parameters.Type;
    BS              = instance.parameters.BS;
    Percentage      = instance.parameters.Percentage;
    RS              = instance.parameters.RS;
    ATRFrame        = instance.parameters.ATRFrame;
    Multiplier      = instance.parameters.Multiplier;
    Ignore          = instance.parameters.Ignore;
    Bull = instance.parameters.Bull;
    Bear = instance.parameters.Bear;

    initFirst = true;
    lineCount = 0;
    
    pf.period = 0;
    
    local name;
    if Type == "Pips" then
        name    =  profile:id() .. "(" .. source:name() .. ", " .. BS ..", " ..RS..", "..Type;
    elseif Type == "Percentage" then
        name    =  profile:id() .. "(" .. source:name() .. ", " .. Percentage ..", " ..RS..", "..Type;
    else
        name    = profile:id() .. "(" .. source:name() .. ", " .. ATRFrame ..", " ..RS..", "..Type..  ", " .. Multiplier;
        ATR     = core.indicators:create("ATR", source, ATRFrame);
        first   = ATR.DATA:first();
    end
    name    = name .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

    TEST=true;

    if Ignore then
        source_low=source.close;
        source_high=source.close;
    else
        source_low=source.low;
        source_high=source.high;
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first+1)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first+1)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first+1)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first+1)
    volume = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first+1)
    instance:createCandleGroup("Point & Figure", "Point & Figure", open, high, low, close, volume);

    sF         = core.host:execute("createFont",instance.parameters.FName,instance.parameters.FSize,false,false);
    N = instance:createTextOutput("", "N", instance.parameters.FName, instance.parameters.FSize, core.H_Center, core.V_Center, instance.parameters.N, 5);
    NP = instance:createTextOutput("", "NP", instance.parameters.FName, instance.parameters.FSize, core.H_Right, core.V_Center, instance.parameters.N, 5);
    for i = 1 , instance.parameters.MC do
        oT[i] = instance:createTextOutput("", "C" .. tostring(i), instance.parameters.FName, instance.parameters.FSize, core.H_Center, core.V_Center, Bull, 5);
    end
    dummy = instance:addStream("dummy", core.Line, name, "", Bull, first+1, 10)
end

function ReleaseInstance()
    core.host:execute("deleteFont", sF);
    core.host:execute("removeAll");
end

function Update(period, mode)
    if mode == core.UpdateAll then
        core.host:execute("setStatus","Reset Indicator recieving more data ...");
        initFirst = true;
        return;
    end
    
    if (period < first) or (period ~= (instance.source:size() - 1)) then
        core.host:execute("setStatus", "Waiting for loading history finished ... " .. tostring(period) .. "/" .. tostring(instance.source:size()-1));
        return;
    end
    if TEST and Type ~= "ATR" then
        TEST = false;
        if Type == "Percentage" then
            BS = ((source.close[period] / point) / 100) * Percentage;
        end
    end
    if Type == "ATR" and TEST then
        ATR:update(mode);
        if not ATR.DATA:hasData(period) then
            core.host:execute ("setStatus","ATR has no data!");
            return;
        end
        TEST = false;
        BS = (ATR.DATA[period]*Multiplier)/point;
    end
    -- New Code ----------------------------------------------------------------------------------------------
    if mode == core.UpdateLast  and period >= first+3 and isLoaded then
        local p = source:size() - 1;
        if initFirst then
            -- first load or when extend History
            pf.period = 0;
            core.host:execute("setStatus", "Read History");
            for i = first + 1, p, 1 do
                if pf.period == 0 then
                    pf.period = 1;
                    pf.close[pf.period] = round(source.open[i], BS);
                    pf.open[pf.period] = round(source.open[i], BS);
                    if pf.open[pf.period] < source.close[i] then
                        pf.swing = "Up";
                        pf.flag  = "Up";
                    else
                        pf.swing = "Down";
                        pf.flag  = "Down";
                    end
                else
                    pf.flag = "Nothing";
                    local bs_point = BS * point;
                    if source_high[i] > pf.close[pf.period] + bs_point then
                        pf.flag = "Up";
                        if pf.swing == "Up" then
							while source_high[i] >= pf.close[pf.period] + BS*point do
								pf.close[pf.period] = pf.close[pf.period] + BS*point;
							end
                        end
                    elseif source_low[i] < pf.close[pf.period] - bs_point then
                        pf.flag = "Down";
                        if pf.swing == "Down" then
							while source_low[i] <= pf.close[pf.period] - BS*point do
								pf.close[pf.period] = pf.close[pf.period] - BS*point;
							end
                        end
                    end
                    if pf.swing == "Up" and  pf.flag == "Down" and source_low[i] <= pf.close[pf.period] - bs_point*RS then
                        pf.period = pf.period + 1;
                        pf.swing = "Down";
                        pf.open[pf.period]     = pf.close[pf.period-1] - bs_point;
                        pf.close[pf.period] = pf.close[pf.period-1] - bs_point*RS;
                    elseif pf.swing == "Down" and  pf.flag == "Up" and source_high[i] >= pf.close[pf.period] + bs_point*RS then
                        pf.period = pf.period + 1;
                        pf.swing = "Up";
                        pf.open[pf.period]     = pf.close[pf.period-1] + bs_point;
                        pf.close[pf.period] = pf.close[pf.period-1] + bs_point*RS;
                    end
                end
            end
            pf.update=true;
            initFirst = false;
        elseif pf.update == false then
            -- history loaded update by realtime data.
            pf.flag="Nothing";
            local sClose = source.close[p];
            if sClose >= pf.close[pf.period] + BS*point then
                pf.flag = "Up";
                if pf.swing == "Up" then
                    while sClose >= pf.close[pf.period] + BS*point do
                        pf.close[pf.period] = pf.close[pf.period] + BS*point;
                        pf.update=true;
                    end
                end
            elseif sClose <= pf.close[pf.period] - BS*point  then
                pf.flag = "Down";
                if pf.swing == "Down" then
                    while sClose <= pf.close[pf.period] - BS*point do
                        pf.close[pf.period] = pf.close[pf.period] - BS*point;
                        pf.update=true;
                    end
                end
            end
            if pf.swing == "Up" and  pf.flag == "Down" and sClose <= pf.close[pf.period] - BS*point*RS then
                pf.period = pf.period + 1;
                pf.swing = "Down";
                pf.open[pf.period] = pf.close[pf.period-1] - BS*point;
                pf.close[pf.period] = pf.close[pf.period-1] - BS*point*RS;
                pf.update=true;
            elseif pf.swing == "Down" and  pf.flag == "Up" and sClose >= pf.close[pf.period] + BS*point*RS then
                pf.period = pf.period + 1;
                pf.swing = "Up";
                pf.open[pf.period] = pf.close[pf.period-1] + BS*point;
                pf.close[pf.period] = pf.close[pf.period-1] + BS*point*RS;
                pf.update=true;
            end
            N:setNoData(period + 1);
            N:setNoData(period - 1);
            N:setNoData(period);
            NP:setNoData(period + 1);
            NP:setNoData(period - 1);
            NP:setNoData(period);
            if pf.swing == "Up" then
                local nU  = ((close[period] + BS*point) - source.close[p])/point;
                local nR  = ((pf.close[pf.period] - BS*point*RS) - source.close[p])/point;
                local s = string.format("Live Data - Next UP in (%.1f) |  Next Reversal in(%.1f)",nU, nR);
                core.host:execute ("setStatus",s);
                if sClose > close[period] then
                    N:set(period,close[period] + BS*point,up,"PUF",instance.parameters.N);
                    NP:set(period,close[period] + BS*point,string.format(" (%.1f)",nU),"PUF",instance.parameters.N);
                else
                    N:set(period+1,close[period] - RS*BS*point,dn,"PUF",instance.parameters.N);
                    NP:set(period+1,close[period] - RS*BS*point,string.format(" (%.1f)",nR),"PUF",instance.parameters.N);
                end
            end
            if pf.swing == "Down" then
                local nD = (source.close[p] - (pf.close[pf.period] - BS*point))/point;
                local nR = (source.close[p] - (pf.close[pf.period] + BS*point*RS))/point;
                local s = string.format("Live Data - Next DN in (%.1f) |  Next Reversal in(%.1f)",nD, nR);
                core.host:execute ("setStatus",s);
                if sClose < close[period] then
                    N:set(period,close[period] - BS*point,dn,"PUF",instance.parameters.N);
                    NP:set(period,close[period] - BS*point,string.format(" (%.1f)",nD),"PUF",instance.parameters.N);
                else
                    N:set(period+1,close[period] + RS*BS*point,up,"PUF",instance.parameters.N);
                    NP:set(period+1,close[period] + RS*BS*point,string.format(" (%.1f)",nR),"PUF",instance.parameters.N);
                end
            end
        end
        if pf.update then
            local sClose = source.close[p];
            updatePF(period);
            N:setNoData(period+1);
            N:setNoData(period-1);
            N:setNoData(period);
            NP:setNoData(period+1);
            NP:setNoData(period-1);
            NP:setNoData(period);
            if pf.swing == "Up" then
                local nU  = ((close[period] + BS*point) - source.close[p])/point;
                local nR  = ((pf.close[pf.period] - BS*point*RS) - source.close[p])/point;
                local s = string.format("Live Data - Next UP in (%.1f) |  Next Reversal in(%.1f)",nU, nR);
                core.host:execute ("setStatus", s);
                if sClose > close[period] then
                    N:set(period,close[period] + BS*point,up,"PUF",instance.parameters.N);
                    NP:set(period,close[period] + BS*point,string.format(" (%.1f)",nU),"PUF",instance.parameters.N);
                else
                    N:set(period+1,close[period] - RS*BS*point,dn,"PUF",instance.parameters.N);
                    NP:set(period+1,close[period] - RS*BS*point,string.format(" (%.1f)",nR),"PUF",instance.parameters.N);
                end
            end
            if pf.swing == "Down" then
                local nD = ( source.close[p] - (pf.close[pf.period] - BS*point))/point;
                local nR = ( source.close[p] - (pf.close[pf.period] + BS*point*RS))/point;
                local s = string.format("Live Data - Next DN in (%.1f) |  Next Reversal in(%.1f)",nD, nR);
                core.host:execute ("setStatus",s);
                if sClose < close[period] then
                    N:set(period,close[period] - BS*point,dn,"PUF",instance.parameters.N);
                    NP:set(period,close[period] - BS*point,string.format(" (%.1f)",nD),"PUF",instance.parameters.N);
                else
                    N:set(period+1,close[period] + RS*BS*point,up,"PUF",instance.parameters.N);
                    NP:set(period+1,close[period] + RS*BS*point,string.format(" (%.1f)",nR),"PUF",instance.parameters.N);
                end
            end
            pf.update = false;
        end
    elseif mode == core.UpdateNew and not initFirst then -- new Bar on SourceStream update the Candle
        pf.update = true;
    elseif isLoaded == false then
        core.host:execute ("setStatus",string.format("Wait until getSyncHistory is finished ..."));
    end
end

function updatePF(period)
    local z;
    local y = pf.period;
    for z=period,0,-1 do
        if y >= 2 then
            if pf.close[y-1] < pf.close[y] then
                for i = 1 , table.maxn(oT) do
                    oT[i]:setNoData(z);
                end
                open[z]=pf.open[y];
                close[z]=pf.close[y];
                high[z]=close[z];
                low[z]=open[z];
                volume[z] = math.modf(((close[z] - open[z])/point/BS)+1.01);
                for i = 1, volume[z] do
                    oT[i]:set(z,open[z] + (i-1)*BS*point,up,"PUF",Bull);
                end
            elseif pf.close[y-1] > pf.close[y] then
                for i = 1, table.maxn(oT) do
                    oT[i]:setNoData(z);
                end
                open[z]=pf.open[y];
                close[z]=pf.close[y];
                high[z]=open[z];
                low[z]=close[z];
                volume[z] = math.modf(((open[z] - close[z])/point/BS)+1.01);
                for i = 1, volume[z] do
                    oT[i]:set(z,open[z] - (i-1)*BS*point,dn,"PUF",Bear);
                end
            end
        else
            for i = 1 , table.maxn(oT) do
                oT[i]:setNoData(z);
            end
            open[z]        = nil;
            close[z]    = nil;
            high[z]        = nil;
            low[z]        = nil;
            volume[z]   = nil;
            if open[z-1] == 0  or close[z-1] == 0 or open[z-1] == nil  or close[z-1] == nil then 
                open[z]        = nil;
                close[z]    = nil;
                high[z]        = nil;
                low[z]        = nil;
                volume[z]   = nil;
                open:setColor(z,instance.parameters.B );
                y = y-1;
                break; 
            end
        end
        open:setColor(z,instance.parameters.B );
        y = y-1;
    end
end

function AsyncOperationFinished(cookie, success, msg1,msg2,msg3)
    if cookie == 1 then
        isLoaded = true;
    elseif cookie == 2 then
        isLoaded = false;
    end
end

function round(i,y)
    local decimal = y * point;
    return math.floor(i/decimal)*decimal;
end








