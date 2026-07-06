-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75708

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    indicator:name("ZigZag")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
end

local Depth
local Deviation
local Backstep
local hist;
local up_color;
local down_color;

local first
local source = nil
local ZigC
local ZagC
local out
local pipSize
local zz;

function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    out = instance:addInternalStream(0, 0);
    zz = CreateZigZag(out, Depth, Deviation, Backstep, instance.parameters.Zig_color, instance.parameters.Zag_color);

    pipSize = source:pipSize()
    hist = instance:addStream("HIST", core.Bar, "Histogram", "HIST", up_color, 0, 0);
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchPeak = 1
    local searchLawn = -1
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
    function zz:ClearStreams(period)
        self.SearchMode:setNoData(period);
        self.Peak:setNoData(period);
        self.out:setNoData(period);
    end
    function zz:RemoveLast()
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if bookmark == -1 then
            return;
        end
        self:ClearStreams(bookmark);
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index, nextBookmark);
            bookmark = nextBookmark;
            index = index + 1;
        end
        self.TotalPeaks = self.TotalPeaks - 1;
    end
    function zz:DrawLine()
        local period = self.out:getBookmark(1);
        local last = self.out:getBookmark(2);
        if last == -1 then
            return;
        end
        if self.SearchMode[period] == -1 then
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZagC)
            self.out:setColor(last, ZigC)
        else
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZigC)
            self.out:setColor(last, ZagC)
        end
    end
    function zz:RegisterPeak(period, mode, peak)
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if (bookmark == period) then
            if mode ~= self.SearchMode[period] then
                self:RemoveLast();
                self:ReplaceLastPeak(period, mode, peak);
            end
            return;
        end
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
        self:DrawLine();
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
        local last = self.out:getBookmark(1);
        if last ~= -1 then
            self:ClearStreams(last);
        end
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
        self:DrawLine();
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
        local range = period - self.Depth + 1;
        local val = mathex.min(source.low, range, period)
        if val ~= self.lastlow then
            self.lastlow = val
            if (source.low[period] - val) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.LowMap[i] ~= 0) and (self.LowMap[i] > val) then
                        self.LowMap[i] = 0
                    end
                end
            end
            if source.low[period] == val then
                self.LowMap[period] = val
            else
                self.LowMap[period] = 0
            end
        end
        val = mathex.max(source.high, range, period)
        if val ~= lasthigh then
            self.lasthigh = val
            if (val - source.high[period]) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.HighMap[i] ~= 0) and (self.HighMap[i] < val) then
                        self.HighMap[i] = 0
                    end
                end
            end
            if source.high[period] == val then
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
                    self:ReplaceLastPeak(i, searchPeak, self.LowMap[i])
                end
                if self.HighMap[i] ~= 0 and self.LowMap[i] == 0 then
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchLawn then
                if (self.HighMap[i] ~= 0 and self.HighMap[i] > self.Peak[last_peak_i]) then
                    last_peak_i = i
                    self:ReplaceLastPeak(i, searchLawn, self.HighMap[i])
                end
                if self.LowMap[i] ~= 0 and self.HighMap[i] == 0 then
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
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);

    local peaks = zz:EnumPeaks();
    if not peaks:Next() then return; end
    local period_1, value_1, next_side_1 = peaks:GetData();
    if not peaks:Next() then return; end
    if not peaks:Next() then return; end
    local period_2, value_2, next_side_2 = peaks:GetData();
    if not peaks:Next() then return; end
    if not peaks:Next() then return; end
    local period_3, value_3, next_side_3 = peaks:GetData();
    if value_1 == nil or value_2 == nil or value_3 == nil then return; end
    if next_side_1 == 1 then
        if value_1 > value_2 and value_2 < value_3 then
            hist[period] = 1;
            hist:setColor(period, up_color);
        end
    else
        if value_1 < value_2 and value_2 > value_3 then
            hist[period] = -1;
            hist:setColor(period, down_color);
        end
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75708

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 