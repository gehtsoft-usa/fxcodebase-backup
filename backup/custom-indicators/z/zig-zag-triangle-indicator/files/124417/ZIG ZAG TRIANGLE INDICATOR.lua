-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67446

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

function Init()
    indicator:name("ZigZag Triangle Indicator")
    indicator:description(" ")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

    indicator.parameters:addGroup("Zig Zag Line Style")
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addColor("bull_color", "Bull color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("bear_color", "Bear color", "", core.rgb(255, 0, 0))
end

local Depth
local Deviation
local Backstep

local first
local source = nil
-- Streams block
local ZigC
local ZagC
local out
local pipSize
local format
local zz;
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    first = source:first()

    format = "%." .. 1 .. "f"

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)
    zz = CreateZigZag(out, Depth, Deviation, Backstep, instance.parameters.Zig_color, instance.parameters.Zag_color);

    pipSize = source:pipSize()

    instance:ownerDrawn(true);
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchBoth = 0;
    local searchPeak = 1;
    local searchLawn = -1;
    local zz = {};
    zz.out = stream;
    zz.Depth = Depth;
    zz.Deviation = Deviation;
    zz.Backstep = Backstep;
    zz.TotalPeaks = 0;
    zz.SearchMode = instance:addInternalStream(0, 0)
    zz.Peak = instance:addInternalStream(0, 0)
    zz.HighMap = instance:addInternalStream(0, 0)
    zz.LowMap = instance:addInternalStream(0, 0)
    function zz:RegisterPeak(period, mode, peak)
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index + 1, bookmark)
            bookmark = nextBookmark;
            index = index + 1;
        end
        self.TotalPeaks = index - 1;
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
    end
    function zz:EnumPeaks()
        local enum = {};
        enum.zz = self;
        enum.Index = 0;
        function enum:Next()
            self.Index = self.Index + 1;
            return self.Index <= self.zz.TotalPeaks;
        end
        function enum:GetData()
            local period = self.zz.out:getBookmark(self.Index);
            if period == -1 then
                return nil;
            end
            return period, self.zz.Peak[period], self.zz.SearchMode[period];
        end
        return enum;
    end
    function zz:ReplaceLastPeak(period, mode, peak)
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
    end
    function zz:Clear()
        self.lastlow = nil
        self.lasthigh = nil
        self.TotalPeaks = 0;
    end
    function zz:Calc(period)
        if (period < self.Depth) then
            return;
        end
        local range = period - self.Depth + 1
        local val = mathex.min(source, range, period)
        if val ~= self.lastlow then
            self.lastlow = val
            if (source[period] - val) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.LowMap[i] ~= 0) and (self.LowMap[i] > val) then
                        self.LowMap[i] = 0
                    end
                end
            end
            if source[period] == val then
                self.LowMap[period] = val
            else
                self.LowMap[period] = 0
            end
        end
        val = mathex.max(source, range, period)
        if val ~= lasthigh then
            self.lasthigh = val
            if (val - source[period]) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.HighMap[i] ~= 0) and (self.HighMap[i] < val) then
                        self.HighMap[i] = 0
                    end
                end
            end
            if source[period] == val then
                self.HighMap[period] = val
            else
                self.HighMap[period] = 0
            end
        end

        local prev_peak = self.out:getBookmark(2)
        local start = self.Depth
        local last_peak_i = self.out:getBookmark(1)
        if last_peak_i ~= -1 then
            start = last_peak_i
        end

        for i = start, period, 1 do
            if last_peak_i == -1 then
                if (self.HighMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                elseif (self.LowMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchPeak then
                if (self.LowMap[i] ~= 0 and self.LowMap[i] < self.Peak[last_peak_i]) then
                    last_peak_i = i
                    if prev_peak ~= -1 then
                        core.drawLine(self.out, core.range(prev_peak, i), self.Peak[prev_peak], prev_peak, self.LowMap[i], i, ZagC)
                        self.out:setColor(prev_peak, ZigC)
                    end
                    self:ReplaceLastPeak(i, searchPeak, self.LowMap[i])
                end
                if self.HighMap[i] ~= 0 and self.LowMap[i] == 0 then
                    core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.HighMap[i], i, ZigC)
                    self.out:setColor(last_peak_i, ZagC)
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchLawn then
                if (self.HighMap[i] ~= 0 and self.HighMap[i] > self.Peak[last_peak_i]) then
                    last_peak_i = i
                    if prev_peak ~= -1 then
                        core.drawLine(self.out, core.range(prev_peak, i), self.Peak[prev_peak], prev_peak, self.HighMap[i], i, ZigC)
                        self.out:setColor(prev_peak, ZagC)
                    end
                    self:ReplaceLastPeak(i, searchLawn, self.HighMap[i])
                end
                if self.LowMap[i] ~= 0 and self.HighMap[i] == 0 then
                    if self.Peak[last_peak_i] > self.LowMap[i] then
                        core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.LowMap[i], i, ZagC)
                        self.out:setColor(last_peak_i, ZigC)
                    else
                        core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.LowMap[i], i, ZigC)
                        self.out:setColor(last_peak_i, ZagC)
                    end
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            end
        end
    end
    
    return zz;
end

local lastserial = -1

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);
end

local BULL_PEN = 1;
local BULL_BRUSH = 2;
local BEAR_PEN = 3;
local BEAR_BRUSH = 4;
local init = false;
function Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    if not init then
        local bull_color = instance.parameters.bull_color;
        local bear_color = instance.parameters.bear_color;
        context:createPen(BULL_PEN, context.SOLID, 1, bull_color);
        context:createPen(BEAR_PEN, context.SOLID, 1, bear_color);
        context:createSolidBrush(BULL_BRUSH, bull_color)
        context:createSolidBrush(BEAR_BRUSH, bear_color)
        init = true;
    end

    local a;
    local b;
    local c;
    local d;
    local e;
    local peaks = zz:EnumPeaks();
    while peaks:Next() do
        local period, value, next_side = peaks:GetData();
        e = d;
        d = c;
        c = b;
        b = a;
        a = {};
        a.Period = period;
        a.Value = value;
        a.NextSide = next_side;

        if e ~= nil then
            local a_x = context:positionOfBar(a.Period);
            local _, a_y = context:pointOfPrice(a.Value);
            local b_x = context:positionOfBar(b.Period);
            local _, b_y = context:pointOfPrice(b.Value);
            local c_x = context:positionOfBar(c.Period);
            local _, c_y = context:pointOfPrice(c.Value);
            local ca = Distance(c_x, c_y, a_x, a_y);
            local cb = Distance(c_x, c_y, b_x, b_y);
            local ab = Distance(b_x, b_y, a_x, a_y);
            if b.Value > d.Value
                and a.Value < c.Value 
                and a.Value < b.Value 
                and c.Value < e.Value
                --and (ca == cb or ca == ab)
            then
                local points = ownerdraw_points.new();
                points:add(a_x, a_y);
                points:add(b_x, b_y);
                points:add(c_x, c_y);
                context:drawPolygon(BULL_PEN, BULL_BRUSH, points);
            end
            if b.Value < d.Value
                and a.Value > c.Value 
                and a.Value > b.Value 
                and c.Value > e.Value
                --and (ca == cb or ca == ab)
            then
                local points = ownerdraw_points.new();
                points:add(a_x, a_y);
                points:add(b_x, b_y);
                points:add(c_x, c_y);
                context:drawPolygon(BEAR_PEN, BEAR_BRUSH, points);
            end
        end
    end
end

function Distance(x1, y1, x2, y2)
	return math.floor(math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)))
end