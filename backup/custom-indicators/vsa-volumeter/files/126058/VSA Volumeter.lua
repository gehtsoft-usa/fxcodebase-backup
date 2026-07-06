-- Id: 24855

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68395

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
    indicator:name("VSA Volumeter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("periods_back", "Periods back", "", 1000);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);

    indicator.parameters:addDouble("x_value", "X", "", 35);
    indicator.parameters:addDouble("y_value", "Y", "", 55)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("x_color", "< X color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("xy_color", "X-Y color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("y_color", "> Y color", "", core.rgb(255, 0, 0))
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
local zz, periods_back, x_color, xy_color, y_color, x, y;
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    periods_back = instance.parameters.periods_back;
    x_color = instance.parameters.x_color;
    xy_color = instance.parameters.xy_color;
    y_color = instance.parameters.y_color;
    x = instance.parameters.x_value;
    y = instance.parameters.y_value;
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

    out = instance:addStream("out", core.Bar, name, "VSA", x_color, first)
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    buffer = instance:addInternalStream(0, 0);
    zz = CreateZigZag(buffer, Depth, Deviation, Backstep, 0, 0);

    pipSize = source:pipSize()
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchBoth = 0
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
    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);

    local lastDirection;
    local lastPeriod = period + 1;
    local peaks = zz:EnumPeaks();
    local upVolume = 0;
    local downVolume = 0;
    while peaks:Next() and lastPeriod > period - periods_back do
        local peakPeriod, peak, direction = peaks:GetData();
        if peakPeriod == nil then
            break;
        end
        if lastDirection == nil then
            lastDirection = direction;
        end
        for i = peakPeriod, lastPeriod - 1 do
            if direction == 1 then
                upVolume = upVolume + source.volume[i];
            else
                downVolume = downVolume + source.volume[i];
            end
        end
        lastPeriod = peakPeriod;
        lastDirection = direction;
    end
    out[period] = upVolume / (upVolume + downVolume) * 100;
    if out[period] < x then
        out:setColor(period, x_color);
    elseif out[period] > y then
        out:setColor(period, y_color);
    else
        out:setColor(period, xy_color);
    end
end
