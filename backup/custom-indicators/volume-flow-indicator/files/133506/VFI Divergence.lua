-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27497

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("VFI Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("Period", "Period", "Period", 130);
    indicator.parameters:addDouble("Coef", "Coef", "Coef", 0.2);
    indicator.parameters:addDouble("VCoef", "VCoef", "VCoef", 2.5);
    indicator.parameters:addInteger("SmoothingPeriods", "SmoothingPeriods", "SmoothingPeriods", 3);

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

local close;
local volume;
local first;
local V;
local UP;
local DN;
local source;
local div;
local indi;

function Prepare(nameOnly)
    source = instance.source;
    close = instance.source.close;
    volume = instance.source.volume;
    first = instance.source:first();

    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    local profile = core.indicators:findIndicator("VFI");
    assert(profile ~= nil, "Please, download and install " .. "VFI" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setInteger("Period", instance.parameters.Period);
    indicatorParams:setInteger("SmoothingPeriods", instance.parameters.SmoothingPeriods);
    indicatorParams:setDouble("Coef", instance.parameters.Coef);
    indicatorParams:setDouble("VCoef", instance.parameters.VCoef);
    indi = core.indicators:create("VFI", source, indicatorParams)
    V = instance:addStream("VFI", core.Line, name, "VFI", instance.parameters.clrV, first);
    V:setPrecision(0);

    div = CreateDivergenceDetector(V, source.high, source.low, instance.parameters.UP_color, instance.parameters.DN_color, false);
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

function Update(period, mode)
    indi:update(mode);
    V[period] = indi.DATA[period];
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
    pperiod1 = source:serial(period);
    div:Update(period, mode);
end
