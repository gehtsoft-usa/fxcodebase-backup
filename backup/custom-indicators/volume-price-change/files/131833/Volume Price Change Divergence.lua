-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65729

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

function Init()
	indicator:name("Volume Price Change")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("length", "Period", "", 15, 2, 2000)
	indicator.parameters:addInteger("price_smoothing", "Price Smoothing", "", 15)
	indicator.parameters:addInteger("signal_smoothing", "Signal Smoothing", "", 15)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color1", "Line Color Down", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("color2", "Line Color Up", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

	indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end

	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

local length, price_smoothing, signal_smoothing
local first
local source = nil
local MVA, EMA1, EMA2, EMA3
local vpc, signal, indi_source, UP_color, DN_color

function Prepare(nameOnly)
	length = instance.parameters.length
	price_smoothing = instance.parameters.price_smoothing
	signal_smoothing = instance.parameters.signal_smoothing

	local name = profile:id() .. "(" .. instance.source:name() .. ", " .. length .. ", " .. signal_smoothing .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

    DN_color = instance.parameters.DN_color;
    UP_color = instance.parameters.UP_color;
	indi_source = instance.source;
	source = sources:Request(1, indi_source);

	if price_smoothing > 1 then
		EMA1 = core.indicators:create("EMA", source.close, price_smoothing)
		EMA2 = core.indicators:create("EMA", source.volume, price_smoothing)

		MVA = core.indicators:create("MVA", EMA2.DATA, length)
		first = MVA.DATA:first()
	else
		MVA = core.indicators:create("MVA", source.volume, length)
		first = MVA.DATA:first()
	end

	vpc = instance:addStream("vpc", core.Line, "vpc", "vpc", instance.parameters.color1, first)
	vpc:setWidth(instance.parameters.width1)
	vpc:setStyle(instance.parameters.style1)

	if signal_smoothing > 1 then
		EMA3 = core.indicators:create("EMA", vpc, signal_smoothing)
		signal = instance:addStream("signal", core.Line, "signal", "signal", instance.parameters.color3, first)
		signal:setWidth(instance.parameters.width2)
		signal:setStyle(instance.parameters.style2)

		signal:setPrecision(math.max(2, instance.source:getPrecision()))
		vpc:setPrecision(math.max(2, instance.source:getPrecision()))
	end
    div = CreateDivergenceDetector(vpc, indi_source, indi_source, instance.parameters.UP_color, instance.parameters.DN_color, true);
    instance:ownerDrawn(true);
end

function Update(period, mode)
	if not sources:IsAllLoaded() then
		return;
	end
	if price_smoothing > 1 then
		EMA1:update(mode)
		EMA2:update(mode)
		MVA:update(mode)

		if period < MVA.DATA:first() or period < length then
			return
		end

		vpc[period] = (EMA1.DATA[period] - EMA1.DATA[period - length + 1]) * MVA.DATA[period]
	else
		MVA:update(mode)

		if period < MVA.DATA:first() then
			return
		end

		vpc[period] = (source.close[period] - source.close[period - length + 1]) * MVA.DATA[period]
	end

	if signal_smoothing > 1 then
		EMA3:update(mode)

		if period < EMA3.DATA:first() then
			return
		end

		signal[period] = EMA3.DATA[period]

		if vpc[period] > signal[period] then
			vpc:setColor(period, instance.parameters.color1)
		else
			vpc:setColor(period, instance.parameters.color2)
		end
	end
    div:Update(period, mode);
end

function Draw(stage, context) 
    div:Draw(stage, context);
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

function AsyncOperationFinished(cookie, successful, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
		instance:updateFrom(0);
	end
end