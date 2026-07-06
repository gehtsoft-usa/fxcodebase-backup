
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23668

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

-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag with counter4");
    indicator:description("ZigZag with counts of Bars, Pips, Ticks Volumes and Fibonacci Levels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("Text_color", "Text color", "Text color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("TextSize", "Text size", "Text size", 10);
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
local TextBuff= nil;
local pipSize;
local VolSize;		-- for counting ticks volumes

local TopPos = 1			-- to place a line from the top of candle to better seeing for function Update()
local BottomPos = 1		-- to place a line from the bottom of candle to better seeing for function Update()

-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
    out:setWidth(instance.parameters.widthZigZag);
    out:setStyle(instance.parameters.styleZigZag);
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;

    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
    TextBuff = instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Center, instance.parameters.Text_color, first);
    pipSize=source:pipSize();

    VolSize = instance:addInternalStream(0, 0);
    CountVol = source:supportsVolume();
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
function RegisterTicksVolume(from, period)
	return mathex.sum(source.volume, from, period);
end

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

function DeleteLabels(startBar, endBar)
 local i;
 for i=startBar,endBar,1 do
  TextBuff:setNoData(i);
 end
 return;
end

function TextFormat(bars, pips, pips2, tickvol)	-- called by lines 255,  261, 271, 287, 297 and 303
	--Modified for printing text with "RETURN" & "NEW LINE" in accordance with the LUA Language ; with also TopPos and BottomPos (see function Update() below) 
	if math.abs(pips)>math.abs(pips2) then
		return "Bars: " .. math.abs(bars)+1 .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10 .. "\r\n" .. "Vols: ".. tickvol;
	else
		return "Bars: " .. math.abs(bars)+1 .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10 .. "\r\n" .. "Vols: ".. tickvol .. "\r\n" .. "Fibo: " .. math.floor(math.abs(pips/pips2)*1000+0.5)/1000;
	end 
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;
    --VolSize = VolSize + 
    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;
    
    local TicksVolume = source.volume[period]
    
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
        local pp_peak;

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
                            DeleteLabels(prev_peak+1, i);
                            pp_peak=GetPeak(-2);
                            TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i)));
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            out:setColor(prev_peak, ZagC);
                            DeleteLabels(prev_peak+1, i);
                            pp_peak=GetPeak(-2);
                            TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i)));
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    out:setColor(last_peak_i, ZagC);
                    DeleteLabels(last_peak_i+1, i);
                    pp_peak=GetPeak(-1);
                    TextBuff:set(i, HighMap[i]+TopPos, TextFormat(i-last_peak_i, HighMap[i]-last_peak, Peak[last_peak_i]-HighMap[pp_peak], RegisterTicksVolume(last_peak_i, i)));
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
                        DeleteLabels(prev_peak+1, i);
                        pp_peak=GetPeak(-2);
                        TextBuff:set(i, HighMap[i]+TopPos, TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak], Peak[prev_peak]-HighMap[pp_peak], RegisterTicksVolume(prev_peak, i)));
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        out:setColor(last_peak_i, ZigC);
                        DeleteLabels(last_peak_i+1, i);
                        pp_peak=GetPeak(-1);
                        TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i)));
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        out:setColor(last_peak_i, ZagC);
                        DeleteLabels(last_peak_i+1, i);
                        pp_peak=GetPeak(-1);
                        TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i)));
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

