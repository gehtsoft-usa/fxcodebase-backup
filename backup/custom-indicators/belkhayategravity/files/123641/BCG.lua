
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67311

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Belkhayate Gravity Center");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("bars_back", "Start Bars Back", "Bars Back", 125)
    indicator.parameters:addInteger("m", "Order", "Order", 2)
    indicator.parameters:addDouble("kstd", "Multiplier", "Multiplier", 2)
	
    indicator.parameters:addColor("GravityLine_color", "GravityLine Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UC1_color", "UC1 Line Color", "", core.colors().Gray);
    indicator.parameters:addColor("UC2_color", "UC2 Line Color", "", core.colors().Red);
    indicator.parameters:addColor("UC3_color", "UC3 Line Color", "", core.colors().Red);
    indicator.parameters:addColor("LC1_color", "LC1 Line Color", "", core.colors().Gray);
    indicator.parameters:addColor("LC2_color", "LC2 Line Color", "", core.colors().LimeGreen);
    indicator.parameters:addColor("LC3_color", "LC3 Line Color", "", core.colors().LimeGreen);
end

local first;
local source = nil;

local GravityLine;
local UC1;
local UC2;
local UC3;
local LC1;
local LC2;
local LC3;
local bars_back
local kstd, m, i, nn, p

function Prepare(nameOnly)   
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if (nameOnly) then
        return;
    end
    source = instance.source;
    bars_back = instance.parameters.bars_back
    kstd = instance.parameters.kstd
    m = instance.parameters.m
    nn = m + 1
    p = bars_back
    GravityLine = instance:addStream("GravityLine", core.Line, "GravityLine", "GravityLine", instance.parameters.GravityLine_color, 0);
    UC1 = instance:addStream("UC1", core.Line, "UC1", "UC1", instance.parameters.UC1_color, 0);
    UC2 = instance:addStream("UC2", core.Line, "UC2", "UC2", instance.parameters.UC2_color, 0);
    UC3 = instance:addStream("UC3", core.Line, "UC3", "UC3", instance.parameters.UC3_color, 0);
    LC1 = instance:addStream("LC1", core.Line, "LC1", "LC1", instance.parameters.LC1_color, 0);
    LC2 = instance:addStream("LC2", core.Line, "LC2", "LC2", instance.parameters.LC2_color, 0);
    LC3 = instance:addStream("LC3", core.Line, "LC3", "LC3", instance.parameters.LC3_color, 0);
end
local i = 0;
local sx = {}
local b = {}
local ai = {}
local x = {}
local fx = {}
function Update(period, mode)
    if (period < p) then
        return;
    end
			
    sx[1] = p + 1
    local mi, n, jj, ii, kk, mm, tt, qq
    -----------------------sx-------------------------------------------------------------------
    local sum = 0
    for mi = 1, nn * 2 - 2, 1 do
        sum = 0
        for n = i, i + p, 1 do
            sum = sum + math.pow(n, mi)
        end
        sx[mi + 1] = sum
    end
    ----------------------syx-----------
    for mi = 1, nn, 1 do
        sum = 00

        for n = i, i + p, 1 do
            if (mi == 1) then
                sum = sum + source[period - n]
            else
                sum = sum + source[period - n] * math.pow(n, mi - 1)
            end
        end
        b[mi] = sum
    end

    --===============Matrix=======================================================================================================
    for jj = 1, nn, 1 do
        ai[jj] = {}
    end

    for jj = 1, nn, 1 do
        for ii = 1, nn, 1 do
            kk = ii + jj - 1
            ai[ii][jj] = sx[kk]
        end
    end

    --===============Gauss========================================================================================================
    for kk = 1, nn - 1, 1 do
        ll = 0
        mm = 0
        for ii = kk, nn, 1 do
            if math.abs(ai[ii][kk]) > mm then
                mm = math.abs(ai[ii][kk])
                ll = ii
            end
        end

        if (ll == 0) then
            return
        end

        if (ll ~= kk) then
            for jj = 1, nn, 1 do
                tt = ai[kk][jj]
                ai[kk][jj] = ai[ll][jj]
                ai[ll][jj] = tt
            end
            tt = b[kk]
            b[kk] = b[ll]
            b[ll] = tt
        end

        for ii = kk + 1, nn, 1 do
            qq = ai[ii][kk] / ai[kk][kk]
            for jj = 1, nn, 1 do
                if (jj == kk) then
                ai[ii][jj] = 0
                else
                ai[ii][jj] = ai[ii][jj] - qq * ai[kk][jj]
                end
            end
            b[ii] = b[ii] - qq * b[kk]
        end
    end

    x[nn] = b[nn] / ai[nn][nn]
    for ii = nn - 1, 1, -1 do
        tt = 0
        for jj = 1, nn - ii, 1 do
            tt = tt + ai[ii][ii + jj] * x[ii + jj]
            x[ii] = (1 / ai[ii][ii]) * (b[ii] - tt)
        end
    end

    if period < source:size() - 1 then
        return
    end

    period = source:size() - 1

    --===========================================================================================================================
    for n = i, i + p, 1 do
        sum = 0
        for kk = 1, m, 1 do
            sum = sum + x[kk + 1] * math.pow(n, kk)
        end
        GravityLine[period - n] = x[1] + sum
		
    end
	
	if source:size()-1 - p-1 > source:first() then
	GravityLine[source:size()-1 - p-1] = nil;
	end
	
	
    local sq = 0
    local std = 0

    for n = i, i + p, 1 do
        sq = sq + math.pow(source[period - n] - GravityLine[period - n], 2)
    end

    sq = math.sqrt(sq / (p + 1)) * kstd;
	
	
	    UC1[source:size()-1 - p-1] = nil;
        LC1[source:size()-1 - p-1] = nil;
        UC2[source:size()-1 - p-1] = nil;
        LC2[source:size()-1 - p-1] = nil;
        UC3[source:size()-1 - p-1] = nil;
        LC3[source:size()-1 - p-1] = nil;
	
    for n = 0, p, 1 do
        UC1[period - n] = GravityLine[period - n] + sq
        LC1[period - n] = GravityLine[period - n] - sq
        UC2[period - n] = GravityLine[period - n] + sq * 2
        LC2[period - n] = GravityLine[period - n] - sq * 2
        UC3[period - n] = GravityLine[period - n] + sq * 3
        LC3[period - n] = GravityLine[period - n] - sq * 3
		
		
    end
end
