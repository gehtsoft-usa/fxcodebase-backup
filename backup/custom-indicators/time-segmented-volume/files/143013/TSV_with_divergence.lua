-- Id: 8798
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33848

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
    indicator.parameters:addStringAlternative(id, "Regression", "", "REGRESSION");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA" or method == "REGRESSION"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Time Segmented Volume")
    indicator:description("Time Segmented Volume")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "Period", 14)

    indicator.parameters:addInteger("ma_period", "Avg Period", "", 14);
    AddAverages("ma_method", "Avg Method", "MVA");

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up_color", "Positive TSV Color", "Color of TSV", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Dn_color", "Negativ TSV Color", "Color of TSV", core.rgb(255, 0, 0))
    indicator.parameters:addColor("ma_color", "Avg Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("ma_width", "Avg Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ma_style", "Avg Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ma_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period

local first
local source = nil
local temp
-- Streams block
local TSV = nil
local ma, mas;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period
    source = instance.source

    first = source:first() + Period

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    assert(source:supportsVolume(), "The source must have volume")

    temp = instance:addInternalStream(0, 0)
    TSV = instance:addStream("TSV", core.Bar, name, "TSV", instance.parameters.Up_color, first)
    TSV:setPrecision(math.max(2, instance.source:getPrecision()))
    ma = CreateAverages(instance.parameters.ma_period, instance.parameters.ma_method, TSV);
    mas = instance:addStream("MA", core.Line, "MA", "MA", instance.parameters.ma_color, 0, 0);
    mas:setWidth(instance.parameters.ma_width);
    mas:setStyle(instance.parameters.ma_style);
    div = CreateDivergenceDetector(TSV, source.high, source.low, instance.parameters.UP_color, instance.parameters.DN_color, false);
    div.UP = instance:createTextOutput("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    div.DN = instance:createTextOutput("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    instance:ownerDrawn(true);
    instance:drawOnMainChart(true);
end

function CreateDivergenceDetector(indi, high, low, up_color, down_color, double_peaks)
    local controller = {};
    controller.indi = indi;
    controller.high = high;
    controller.low = low;
    controller.lines = {};
    controller.double_peaks = double_peaks;
    controller.init = false;
    controller.init2 = false;
    controller.up_color = up_color;
    controller.down_color = down_color;
    controller.UP_PEN = 1;
    controller.DN_PEN = 2;
    function controller:Update(period, mode)
        if mode == core.UpdateAll then
            self.lines = {};
        end
        if period >= 2 then
            self:processBullish(period - 2);
            self:processBearish(period - 2);
        end
    end
    function controller:Draw(stage, context)
        if stage == 102 then
            if not self.init then
                context:createPen(self.UP_PEN, context.SOLID, 1, self.up_color);
                context:createPen(self.DN_PEN, context.SOLID, 1, self.down_color);
                self.init = true;
            end
            for _, line in ipairs(self.lines) do
                local x1 = context:positionOfDate(line.Date1);
                local x2 = context:positionOfDate(line.Date2);
                local visible, y1 = context:pointOfPrice(line.Price1);
                local visible, y2 = context:pointOfPrice(line.Price2);
                context:drawLine(line.IsDown and self.DN_PEN or self.UP_PEN, x1, y1, x2, y2);
            end
        elseif stage == 2 then
            if not self.init2 then
                context:createPen(self.UP_PEN, context.SOLID, 1, self.up_color);
                context:createPen(self.DN_PEN, context.SOLID, 1, self.down_color);
                self.init2 = true;
            end
            for _, line in ipairs(self.lines) do
                local x1 = context:positionOfDate(line.Date1);
                local x2 = context:positionOfDate(line.Date2);
                local visible, y1 = context:pointOfPrice(line.IndiVal1);
                local visible, y2 = context:pointOfPrice(line.IndiVal2);
                context:drawLine(line.IsDown and self.DN_PEN or self.UP_PEN, x1, y1, x2, y2);
            end
        end
    end
    function controller:processBullish(period)
        if self:isTrough(period, self.indi) then
            local curr = period;
            local prev = self:prevTrough(period);
            if prev == nil then
                return;
            end
            if double_peaks and (not self:isTrough(curr, self.low) or not self:isTrough(prev, self.low)) then
                return;
            end
            if self.indi[curr] > self.indi[prev] and self.low[curr] < self.low[prev] then
                if self.DN ~= nil then
                    self.DN:set(curr, self.indi[curr], "\225", "Classic bullish");
                end
                local line = {};
                line.Date1 = self.indi:date(prev);
                line.Date2 = self.indi:date(curr);
                line.IndiVal1 = self.indi[prev];
                line.IndiVal2 = self.indi[curr];
                line.Price1 = self.low[prev];
                line.Price2 = self.low[curr]
                line.IsDown = true;
                self.lines[#self.lines + 1] = line;
            elseif self.indi[curr] < self.indi[prev] and self.low[curr] > self.low[prev] then
                if self.DN ~= nil then
                    self.DN:set(curr, self.indi[curr], "\225", "Reversal bullish");
                end
                local line = {};
                line.Date1 = self.indi:date(prev);
                line.Date2 = self.indi:date(curr);
                line.IndiVal1 = self.indi[prev];
                line.IndiVal2 = self.indi[curr];
                line.Price1 = self.low[prev];
                line.Price2 = self.low[curr]
                line.IsDown = true;
                self.lines[#self.lines + 1] = line;
            end
        end
    end
    function controller:isTrough(period, src)
        if src[period] < src[period - 1] and src[period] < src[period + 1] then
            for i = period - 1, first, -1 do
                if src[i] > src[period] then
                    return true;
                elseif src[period] > src[i] then
                    return false;
                end
            end
        end
        return false;
    end
    function controller:prevTrough(period)
        for i = period - 5, first, -1 do
            if self.indi[i] <= self.indi[i - 1] 
                and self.indi[i] < self.indi[i - 2] 
                and self.indi[i] <= self.indi[i + 1] 
                and self.indi[i] < self.indi[i + 2] 
            then
                return i;
            end
        end
        return nil;
    end
    function controller:processBearish(period)
        if self:isPeak(period, self.indi) then
            local curr = period;
            local prev = self:prevPeak(period);
            if prev == nil then
                return;
            end
            if double_peaks and (not self:isPeak(curr, self.low) or not self:isPeak(prev, self.low)) then
                return;
            end
            if self.indi[curr] < self.indi[prev] and self.high[curr] > self.high[prev] then
                if self.UP ~= nil then
                    self.UP:set(curr, self.indi[curr], "\226", "Classic bearish");
                end
                local line = {};
                line.Date1 = self.indi:date(prev);
                line.Date2 = self.indi:date(curr);
                line.IndiVal1 = self.indi[prev];
                line.IndiVal2 = self.indi[curr];
                line.Price1 = self.high[prev];
                line.Price2 = self.high[curr];
                line.IsDown = false;
                self.lines[#self.lines + 1] = line;
            elseif self.indi[curr] > self.indi[prev] and self.high[curr] < self.high[prev] then
                if self.UP ~= nil then
                    self.UP:set(curr, self.indi[curr], "\226", "Reversal bearish");
                end
                local line = {};
                line.Date1 = self.indi:date(prev);
                line.Date2 = self.indi:date(curr);
                line.IndiVal1 = self.indi[prev];
                line.IndiVal2 = self.indi[curr];
                line.Price1 = self.high[prev];
                line.Price2 = self.high[curr];
                line.IsDown = false;
                self.lines[#self.lines + 1] = line;
            end
        end
    end
    function controller:isPeak(period, src)
        if src[period] > src[period - 1] and src[period] > src[period + 1] then
            for i = period - 1, first, -1 do
                if src[i] < src[period] then
                    return true;
                elseif src[period] < src[i] then
                    return false;
                end
            end
        end
        return false;
    end
    function controller:prevPeak(period)
        for i = period - 5, first, -1 do
            if self.indi[i] >= self.indi[i - 1] 
                and self.indi[i] > self.indi[i - 2] 
                and self.indi[i] >= self.indi[i + 1] 
                and self.indi[i] > self.indi[i + 2] 
            then
                return i;
            end
        end
        return nil;
    end

    return controller;
end

local pperiod = nil;
local pperiod1 = nil;
function Draw(stage, context)
    div:Draw(stage, context);
end

function Update(period)
    if source.close[period] > source.close[period - 1] then
        temp[period] = source.volume[period] * (source.close[period] - source.close[period - 1])
    elseif source.close[period] < source.close[period - 1] then
        temp[period] = (-1) * source.volume[period] * (source.close[period - 1] - source.close[period])
    else
        temp[period] = 0
    end

    if period < first then
        return
    end

    TSV[period] = mathex.sum(temp, period - Period + 1, period)

    if TSV[period] > TSV[period - 1] then
        TSV:setColor(period, instance.parameters.Up_color)
    else
        TSV:setColor(period, instance.parameters.Dn_color)
    end
    ma:update(period);
    mas[period] = ma.DATA[period];
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
    pperiod1 = source:serial(period);
    div:Update(period, mode);
end
