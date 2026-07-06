-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71753

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("ZigZag NK Fibo")
    indicator:description("")
    indicator:requiredSource(core.Bar)
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

    indicator.parameters:addBoolean("DynamicFiboFlag", "DynamicFibo display flag", "", true);
    indicator.parameters:addColor("DynamicFibo_color", "DynamicFibo color", "", core.colors().Blue)
    indicator.parameters:addInteger("DynamicFibo_width", "DynamicFibo line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("DynamicFibo_style", "DynamicFibo style", "Line style", core.LINE_DASHDOT)
    indicator.parameters:setFlag("DynamicFibo_style", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addBoolean("StaticFiboFlag", "StaticFibo display flag", "", true);
    indicator.parameters:addColor("StaticFibo_color", "StaticFibo color", "", core.colors().Red)
    indicator.parameters:addInteger("StaticFibo_width", "StaticFibo line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("StaticFibo_style", "StaticFibo style", "Line style", core.LINE_DASH)
    indicator.parameters:setFlag("StaticFibo_style", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addString("fib_levels", "Fibonacci levels", "", "-0.618,-0.382,-0.272,0,0.236,0.382,0.5,0.618,0.764,1,1.272,1.618")
end

local Depth
local Deviation
local Backstep

local first
local source = nil
local ZigC
local ZagC
local out
local pipSize
local zz;
local fib_levels = {};

function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    local items, count = core.parseCsv(instance.parameters.fib_levels, ",");
    for i = 1, count do
        fib_levels[i] = tonumber(items[i]);
    end

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)
    zz = CreateZigZag(out, Depth, Deviation, Backstep, instance.parameters.Zig_color, instance.parameters.Zag_color);
    instance:ownerDrawn(true);

    pipSize = source:pipSize()
end

local init = false;
local DYN_PEN = 1;
local STAT_PEN = 2;
local DynamicFiboFlag;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        DynamicFiboFlag = instance.parameters.DynamicFiboFlag;
        StaticFiboFlag = instance.parameters.StaticFiboFlag;
        context:createPen(DYN_PEN, context:convertPenStyle(instance.parameters.DynamicFibo_style), instance.parameters.DynamicFibo_width, instance.parameters.DynamicFibo_color)
        context:createPen(STAT_PEN, context:convertPenStyle(instance.parameters.StaticFibo_style), instance.parameters.StaticFibo_width, instance.parameters.StaticFibo_color)
    end

    local peaks = zz:EnumPeaks();
    if not peaks:Next() then
        return;
    end
    local period_1, peak_1, mode_1 = peaks:GetData();
    if not peaks:Next() then
        return;
    end
    local period_2, peak_2, mode_2 = peaks:GetData();
    local x1 = context:positionOfBar(period_2);
    local _, y1 = context:pointOfPrice(peak_2);
    if DynamicFiboFlag then
        local x2 = context:positionOfBar(period_1);
        local _, y2 = context:pointOfPrice(peak_1);
        DrawFibo(context, DYN_PEN, x1, x2, y1, y2);
    end
    x2 = x1;
    y2 = y1;
    if not peaks:Next() then
        return;
    end
    if StaticFiboFlag then
        local period_3, peak_3, mode_3 = peaks:GetData();
        local x1 = context:positionOfBar(period_3);
        local _, y1 = context:pointOfPrice(peak_3);
        DrawFibo(context, STAT_PEN, x1, x2, y1, y2);
    end
end

function DrawFibo(context, pen, x1, x2, y1, y2)
    local height = y2 - y1;
    for i, level in ipairs(fib_levels) do
        local level_y = y1 + level * height;
        context:drawLine(pen, x1, level_y, x2, level_y);
    end
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
end
