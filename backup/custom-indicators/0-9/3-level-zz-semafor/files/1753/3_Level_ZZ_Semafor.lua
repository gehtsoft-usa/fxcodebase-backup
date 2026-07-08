-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=954

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--+------------------------------------------------------------------+

-- ---------------------------------------------------------------------------------------------
-- The trend, retrace and target lines are modification of the original ZigZag indicator
-- The alogrithm is described in Stock & Commodities V. 19:6 (38-42): The Folding Rule by Viktor Likhovidov
-- ---------------------------------------------------------------------------------------------
-- The standard Marketscope ZigZag algoritm is used in this implementation
-- ---------------------------------------------------------------------------------------------
function Init()
    indicator:name("3 level ZigZag semaphore");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	
    indicator.parameters:addGroup("First ZigZag");
    indicator.parameters:addBoolean("Show1", "Show", "", true);
    indicator.parameters:addInteger("Depth1", "Depth", "The minimum number of periods used to draw one ZigZag line.", 5);
    indicator.parameters:addInteger("Deviation1", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 1);
    indicator.parameters:addInteger("Backstep1", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 3);
    indicator.parameters:addColor("Color1", "Color of labels", "", core.rgb(128, 64, 0));
    indicator.parameters:addInteger("Size1", "Font Size", "", 6);
    indicator.parameters:addGroup("Second ZigZag");
    indicator.parameters:addBoolean("Show2", "Show", "", true);
    indicator.parameters:addInteger("Depth2", "Depth", "The minimum number of periods used to draw one ZigZag line.", 13);
    indicator.parameters:addInteger("Deviation2", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 8);
    indicator.parameters:addInteger("Backstep2", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 5);
    indicator.parameters:addColor("Color2", "Color of labels", "", core.rgb(255, 128, 255));
    indicator.parameters:addInteger("Size2", "Font Size", "", 8);
    indicator.parameters:addGroup("Third ZigZag");
    indicator.parameters:addBoolean("Show3", "Show", "", true);
    indicator.parameters:addInteger("Depth3", "Depth", "The minimum number of periods used to draw one ZigZag line.", 34);
    indicator.parameters:addInteger("Deviation3", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 21);
    indicator.parameters:addInteger("Backstep3", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 12);
    indicator.parameters:addColor("Color3", "Color of labels", "", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("Size3", "Font Size", "", 10);
    indicator.parameters:addGroup("Lines");
    indicator.parameters:addInteger("Extent", "Lines extend into future in bars", "", 100);
    indicator.parameters:addBoolean("ShowTrend", "Show trend lines", "", true);
	
    indicator.parameters:addColor("ColorTU", "Color of upper line", "", core.rgb(192, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("ColorTL", "Color of lower line", "", core.rgb(0, 0, 192));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addBoolean("ShowRetracement", "Show retracement lines", "", true);
    indicator.parameters:addInteger("RetracePips", "Pips for retracement lines", "", 20);
    indicator.parameters:addColor("ColorR", "Retracement line color", "", core.rgb(128, 64, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addBoolean("ShowTarget", "Show target lines", "", true);
    indicator.parameters:addInteger("TargetPips", "Pips for target lines", "", 20);
    indicator.parameters:addColor("ColorT", "Target line color", "", core.rgb(255, 128, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	end

local source;
local ZZ1 = nil;
local ZZ2 = nil;
local ZZ3 = nil;
local barSize;
local Extent;
local ShowTrend;
local ColorTU;
local ColorTL;
local ShowRetracement;
local ColorR;
local RetracePips;
local ShowTarget;
local ColorT;
local TargetPips;

function Prepare(nameOnly)
    source = instance.source;
    Extent = instance.parameters.Extent;
    ShowTrend = instance.parameters.ShowTrend;
    ColorTU = instance.parameters.ColorTU;
    ColorTL = instance.parameters.ColorTL;
    ShowRetracement = instance.parameters.ShowRetracement;
    ColorR = instance.parameters.ColorR;
    RetracePips = instance.parameters.RetracePips * source:pipSize();
    ShowTarget = instance.parameters.ShowTarget;
    ColorT = instance.parameters.ColorT;
    TargetPips = instance.parameters.TargetPips * source:pipSize();

    local l, e;
    l, e = core.getcandle(source:barSize(), 0, 0);
    barSize = e - l;

    instance:name(profile:id());
    if nameOnly then
        return;
    end

    ZZ1 = RegisterZZ("1");
    ZZ2 = RegisterZZ("2");
    ZZ3 = RegisterZZ("3");

    assert(not(ZZ1 == nil and ZZ2 == nil and ZZ3 == nil), "At least one zigzag must be turned on");
end

function RegisterZZ(n)
    if instance.parameters:getBoolean("Show" .. n) then
        local ZZ = {};
        ZZ.Depth = instance.parameters:getInteger("Depth" .. n);
        ZZ.Deviation = instance.parameters:getInteger("Deviation" .. n);
        ZZ.Backstep = instance.parameters:getInteger("Backstep" .. n);
        ZZ.Color = instance.parameters:getColor("Color" .. n);
        ZZ.Size = instance.parameters:getInteger("Size" .. n);
        ZZ.HighMap = instance:addInternalStream(0, 0);
        ZZ.LowMap = instance:addInternalStream(0, 0);
        ZZ.SearchMode = instance:addInternalStream(0, 0);
        ZZ.Peak = instance:addInternalStream(0, 0);
        ZZ.lastperiod = -1;
        ZZ.peak_count = 0;
        ZZ.lastlow = nil;
        ZZ.lasthigh = nil;
        --ZZ.ZigZag = instance:addStream("ZZ" .. n, core.Line, "ZZ" .. n, "ZZ" .. n, ZZ.Color,  0);
        ZZ.ZigZag = instance:addInternalStream(0, 0);
        ZZ.UP = instance:createTextOutput ("Up" .. n, "Up" .. n, "Wingdings", ZZ.Size, core.H_Center, core.V_Top, ZZ.Color, 0);
        ZZ.DN = instance:createTextOutput ("Dn" .. n, "Dn" .. n, "Wingdings", ZZ.Size, core.H_Center, core.V_Bottom, ZZ.Color, 0);
        if n == "1" then
            ZZ.Text = "\140";
        elseif n == "2" then
            ZZ.Text = "\141";
        elseif n == "3" then
            ZZ.Text = "\142";
        else
            ZZ.Text = "\076";
        end
        return ZZ;
    else
        return nil;
    end
end

function Update(period, mode)
    UpdateZZ(period, ZZ1);
    UpdateZZ(period, ZZ2);
    UpdateZZ(period, ZZ3);

    if period == source:size() - 1 and (ShowTrend or ShowRetracement or ShowTarget) then
        local u1 = nil;
        local u2 = nil;
        local d1 = nil;
        local d2 = nil;
        local to;

        to = math.max(period - 100, 0);

        for i = period, to, -1 do
            if (ZZ1 ~= nil and ZZ1.ZigZag[i] > 0) or
               (ZZ2 ~= nil and ZZ2.ZigZag[i] > 0) or
               (ZZ3 ~= nil and ZZ3.ZigZag[i] > 0) then
                if u1 == nil then
                    u1 = i;
                elseif u2 == nil then
                    u2 = i;
                end
            end
            if (ZZ1 ~= nil and ZZ1.ZigZag[i] < 0) or
               (ZZ2 ~= nil and ZZ2.ZigZag[i] < 0) or
               (ZZ3 ~= nil and ZZ3.ZigZag[i] < 0) then
                if d1 == nil then
                    d1 = i;
                elseif d2 == nil then
                    d2 = i;
                end
            end
            if u1 ~= nil and u2 ~= nil and d1 ~= nil and d2 ~= nil then
                break;
            end
        end

        if u1 ~= nil and u2 ~= nil and d1 ~= nil and d2 ~= nil then
            if ShowTrend then
                -- draw trend lines
                local to1, to2;
                to1 = source:date(u1) + Extent * barSize;
                to2 = source.high[u2] + (source.high[u1] - source.high[u2]) / (u1 - u2) * (u1 - u2 + Extent);
                core.host:execute("drawLine", 1, source:date(u2), source.high[u2], to1, to2, ColorTU, instance.parameters.style1, instance.parameters.width1);
                to1 = source:date(d1) + Extent * barSize;
                to2 = source.low[d2] + (source.low[d1] - source.low[d2]) / (d1 - d2) * (d1 - d2 + Extent);
                core.host:execute("drawLine", 2, source:date(d2), source.low[d2], to1, to2, ColorTL, instance.parameters.style1, instance.parameters.width2);
            end
            if ShowRetracement then
                local to;
                local l;
                to = source:date(u1) + Extent * barSize;
                l = source.high[u1] - RetracePips;
                core.host:execute("drawLine", 3, source:date(u1), l, to, l, ColorR,instance.parameters.style3, instance.parameters.width3);

                to = source:date(d1) + Extent * barSize;
                l = source.low[d1] + RetracePips;
                core.host:execute("drawLine", 4, source:date(d1), l, to, l, ColorR,instance.parameters.style3, instance.parameters.width3);
            end
            if ShowTarget then
                local to;
                local l;
                to = source:date(u1) + Extent * barSize;
                l = source.high[u1] + TargetPips;
                core.host:execute("drawLine", 5, source:date(u1), l, to, l, ColorT,instance.parameters.style4, instance.parameters.width4);

                to = source:date(d1) + Extent * barSize;
                l = source.low[d1] - TargetPips;
                core.host:execute("drawLine", 6, source:date(d1), l, to, l, ColorT,instance.parameters.style4, instance.parameters.width4);
            end
        end
    end
end

function UpdateZZ(period, zz)
    if zz ~= nil then
        CalcZZ(period, zz)
    end
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;

function RegisterPeak(zz, period, mode, peak)
    zz.peak_count = zz.peak_count + 1;
    zz.ZigZag:setBookmark(zz.peak_count, period);
    zz.SearchMode[period] = mode;
    zz.Peak[period] = peak;
end

function ReplaceLastPeak(zz, period, mode, peak)
    local p = zz.ZigZag:getBookmark(zz.peak_count);
    zz.ZigZag:setBookmark(zz.peak_count, period);
    zz.SearchMode[period] = mode;
    zz.Peak[period] = peak;
end

function GetPeak(zz, offset)
    local peak;
    peak = zz.peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = zz.ZigZag:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

function CalcZZ(period, zz)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == zz.lastperiod then
        return ;
    end

    if period < zz.lastperiod then
        zz.lastlow = nil;
        zz.lasthigh = nil;
        zz.peak_count = 0;
    end

    zz.lastperiod = period;

    if period >= zz.Depth then
        -- fill high/low maps
        local range = core.rangeTo(period, zz.Depth);
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = core.min(source.low, range);
        if val == zz.lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            zz.lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * zz.Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - zz.Backstep + 1, -1 do
                    if (zz.LowMap[i] ~= 0) and (zz.LowMap[i] > val) then
                        zz.LowMap[i] = 0;
                    end
                end
            end
        end
        if source.low[period] == val then
            zz.LowMap[period] = val;
        else
            zz.LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = core.max(source.high, range);
        if val == zz.lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            zz.lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * zz.Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - zz.Backstep + 1, -1 do
                    if (zz.HighMap[i] ~= 0) and (zz.HighMap[i] < val) then
                        zz.HighMap[i] = 0;
                    end
                end
            end
        end

        if source.high[period] == val then
            zz.HighMap[period] = val;
        else
            zz.HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(zz, -4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end

        start = zz.Depth;
        i = GetPeak(zz, -3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = zz.Peak[i];
            searchMode = zz.SearchMode[i];
            start = i;
        end

        zz.peak_count = zz.peak_count - 3;
        local u, d;
        for i = start, period, 1 do
            zz.UP:setNoData(i);
            zz.DN:setNoData(i);
            zz.ZigZag[i] = 0;
            if searchMode == searchBoth then
                if (zz.HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = zz.HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(zz, i, searchMode, last_peak);
                elseif (zz.LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = zz.LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(zz, i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (zz.LowMap[i] ~= 0 and zz.LowMap[i] < last_peak) then
                    zz.DN:setNoData(last_peak_i);
                    zz.ZigZag[last_peak_i] = 0;
                    last_peak = zz.LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        --core.drawLine(zz.ZigZag, core.range(prev_peak, i), zz.Peak[prev_peak], prev_peak, zz.LowMap[i], i);
                        zz.UP:set(prev_peak, zz.Peak[prev_peak], zz.Text);
                        zz.ZigZag[prev_peak] = zz.Peak[prev_peak];
                    end
                    zz.DN:set(i, zz.LowMap[i], zz.Text);
                    zz.ZigZag[i] = -zz.LowMap[i];
                    ReplaceLastPeak(zz, i, searchMode, last_peak);
                end
                if zz.HighMap[i] ~= 0 and zz.LowMap[i] == 0 then
                    --core.drawLine(zz.ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, zz.HighMap[i], i);
                    zz.UP:set(i, zz.HighMap[i], zz.Text);
                    zz.DN:set(last_peak_i, last_peak, zz.Text);
                    zz.ZigZag[i] = zz.HighMap[i];
                    zz.ZigZag[last_peak_i] = -last_peak;
                    prev_peak = last_peak_i;
                    last_peak = zz.HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(zz, i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (zz.HighMap[i] ~= 0 and zz.HighMap[i] > last_peak) then
                    zz.UP:setNoData(last_peak_i);
                    zz.ZigZag[last_peak_i] = 0;
                    last_peak = zz.HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        --core.drawLine(zz.ZigZag, core.range(prev_peak, i), zz.Peak[prev_peak], prev_peak, zz.HighMap[i], i);
                        zz.DN:set(prev_peak, zz.Peak[prev_peak], zz.Text);
                        zz.ZigZag[prev_peak] = -zz.Peak[prev_peak];
                    end
                    zz.UP:set(i, zz.HighMap[i], zz.Text);
                    zz.ZigZag[i] = zz.HighMap[i];
                    ReplaceLastPeak(zz, i, searchMode, last_peak);
                end
                if zz.LowMap[i] ~= 0 and zz.HighMap[i] == 0 then
                    --core.drawLine(zz.ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, zz.LowMap[i], i);
                    zz.UP:set(last_peak_i, last_peak, zz.Text);
                    zz.ZigZag[last_peak_i] = last_peak;
                    zz.DN:set(i, zz.LowMap[i], zz.Text);
                    zz.ZigZag[i] = -zz.LowMap[i];
                    prev_peak = last_peak_i;
                    last_peak = zz.LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(zz, i, searchMode, last_peak);
                end
            end
        end
    end
end
