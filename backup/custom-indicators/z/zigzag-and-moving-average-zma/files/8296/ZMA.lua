
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3485&sid=6eb856b7a0e3a5289eb215e2282f8b31

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Other instrument ZigZag");
    indicator:description("Other instrument ZigZag");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "Depth", 12, 1, 10000);
    indicator.parameters:addInteger("Deviation", "Deviation", "Deviation", 5, 1, 1000);
    indicator.parameters:addInteger("Backstep", "Backstep", "Backstep", 3, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Zig_color", "Up color", "Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Dn color", "Dn color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "widthZigZag", "widthZigZag", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "styleZigZag", "styleZigZag", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;

-- Streams block
local ZigC;
local ZagC;
local out;
local HighMap = nil;
local LowMap = nil;

local MA_UP_Buff=nil;
local MA_DN_Buff=nil;

-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
    out:setWidth(instance.parameters.widthZigZag);
    out:setStyle(instance.parameters.styleZigZag);
    MA_UP_Buff = instance:addStream("MA_UP_Buff", core.Dot, name, "MA_UP", instance.parameters.Zag_color, first);
    MA_DN_Buff = instance:addStream("MA_DN_Buff", core.Dot, name, "MA_DN", instance.parameters.Zig_color, first);
    MA_UP_Buff:setWidth(instance.parameters.widthZigZag);
    MA_DN_Buff:setWidth(instance.parameters.widthZigZag);
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;

    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local peak_count = 0;

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = out:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

local lastperiod = -1;

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1;
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0;
                    end
                end
            end
        end
        if source.low[period] == val then
            LowMap[period] = val;
        else
            LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0;
                    end
                end
            end
        end

        if source.high[period] == val then
            HighMap[period] = val;
        else
            HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(-4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end
        
        start = Depth;
        i = GetPeak(-3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = Peak[i];
            searchMode = SearchMode[i];
            start = i;
        end

        peak_count = peak_count - 3;

        for i = start, period, 1 do
        
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC);
                            out:setColor(prev_peak, ZigC);
                            DrawMA(prev_peak,i,"DN");
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            out:setColor(prev_peak, ZagC);
                            DrawMA(prev_peak,i,"UP");
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    out:setColor(last_peak_i, ZagC);
                    DrawMA(last_peak_i,i,"UP");
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC);
                        out:setColor(prev_peak, ZagC);
                        DrawMA(prev_peak,i,"UP");
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        out:setColor(last_peak_i, ZigC);
                        DrawMA(last_peak_i,i,"DN");
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        out:setColor(last_peak_i, ZagC);
                        DrawMA(last_peak_i,i,"UP");
                    end
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
end

function DrawMA(from,to,Direction)
 local i;
 for i=from,to,1 do
  local Avg=core.avg(source.close,core.range(from,i));
  if Direction=="UP" then
   MA_UP_Buff[i]=Avg;
  else
   MA_DN_Buff[i]=Avg;
  end
 end
end
