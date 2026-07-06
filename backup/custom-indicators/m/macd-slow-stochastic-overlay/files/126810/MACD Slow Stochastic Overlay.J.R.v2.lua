-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66700

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("MACD Slow Stochastic Overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addString("TF1", "Time frame", "", "Chart")
	indicator.parameters:addString("Price", "Data Source", "", "close")
	indicator.parameters:addStringAlternative("Price", "Open", "", "open")
	indicator.parameters:addStringAlternative("Price", "High", "", "high")
	indicator.parameters:addStringAlternative("Price", "Low", "", "low")
	indicator.parameters:addStringAlternative("Price", "Close", "", "close")
	indicator.parameters:addStringAlternative("Price", "Median", "", "median")
	indicator.parameters:addStringAlternative("Price", "Typical", "", "typical")
	indicator.parameters:addStringAlternative("Price", "Weighted ", "", "weighted")

	indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000)
	indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000)
	indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000)

	indicator.parameters:addGroup("Slow Stochastic Calculation")
	indicator.parameters:addString("TF2", "Time frame", "", "Chart")
	indicator.parameters:addInteger("K", "K Period", "", 5, 2, 1000)
	indicator.parameters:addInteger("SD", "K Slowing Period", "", 3, 2, 1000)
	indicator.parameters:addInteger("OS_level", "Oversold level", "", 20);
	indicator.parameters:addInteger("OB_level", "Overbought level", "", 80);

	indicator.parameters:addGroup("RSI Calculation")
	indicator.parameters:addString("TF3", "Time frame", "", "Chart")
	indicator.parameters:addInteger("rsi_periods", "Period", "", 5, 2, 1000)
	indicator.parameters:addInteger("rsi_os_level", "Oversold level", "", 20);
	indicator.parameters:addInteger("rsi_ob_level", "Overbought level", "", 80);

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "MACD Coloring", "", true)
	indicator.parameters:addBoolean("Two", "Stochastic Coloring", "", true)
	indicator.parameters:addBoolean("show_rsi", "RSI Coloring", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("OB_entry", "Overbought entry color", "", core.rgb(128, 0, 0))
	indicator.parameters:addColor("OB_exit", "Overbought exit color", "", core.rgb(0, 128, 0))
	indicator.parameters:addColor("OS_entry", "Oversold entry color", "", core.rgb(128, 0, 0))
	indicator.parameters:addColor("OS_exit", "Oversold exit color", "", core.rgb(0, 128, 0))
end

-- Sources v1.1
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

	self.items[id] = core.host:execute("getSyncHistory", source:instrument(), tf, source:isBid(), 100, ids.loaded_id, ids.loading_id)
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

local Up, Down
local first
local source = nil

local K, SK, D, Stochastic

local open = nil
local close = nil
local high = nil
local low = nil

local SN, LN, IN, Price

local TF = {}
local weekoffset, dayoffset

local loading = {}
local Source = {}

local macd

local One, Two
local OB_entry;
local OB_exit;
local OS_entry;
local OS_exit;
local OS_level;
local OB_level;
local show_rsi;

local TF3;
local rsi_periods;
local rsi_os_level;
local rsi_ob_level;
local rsi;

function GetSource(id, tf)
	if tf == "Chart" then
		return source;
	end
	return sources:Request(id, source, tf);
end

function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	TF3 = instance.parameters.TF3;
	rsi_periods = instance.parameters.rsi_periods;
	rsi_os_level = instance.parameters.rsi_os_level;
	rsi_ob_level = instance.parameters.rsi_ob_level;
	show_rsi = instance.parameters.show_rsi;
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	OB_entry = instance.parameters.OB_entry;
	OB_exit = instance.parameters.OB_exit;
	OS_entry = instance.parameters.OS_entry;
	OS_exit = instance.parameters.OS_exit;
	OS_level = instance.parameters.OS_level;
	OB_level = instance.parameters.OB_level;

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	IN = instance.parameters.IN
	SN = instance.parameters.SN
	LN = instance.parameters.LN
	Price = instance.parameters.Price

	K = instance.parameters.K
	SD = instance.parameters.SD

	One = instance.parameters.One
	Two = instance.parameters.Two

	if (LN <= SN) then
		error("The short EMA period must be smaller than long EMA period")
	end

	source = instance.source
	first = source:first()

	local Source1 = GetSource(1, instance.parameters.TF1);
	macd = core.indicators:create("MACD", Source1.close, SN, LN, IN)
	first = macd.DATA:first();

	local Source2 = GetSource(2, instance.parameters.TF2);
	Stochastic = core.indicators:create("SSD", Source2, K, SD, 3)
	first = math.max(first, Stochastic.D:first())

	local Source3 = GetSource(3, instance.parameters.TF3);
	rsi = core.indicators:create("RSI", Source3, rsi_periods)
	first = math.max(first, rsi.DATA:first())

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	if not sources:IsAllLoaded() then
		return
	end

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		return
	end
	
	if One then
		macd:update(mode)
		local S1 = 0
		local p1 = core.findDate(macd.DATA, source:date(period), false);
		if macd.HISTOGRAM[p1] > macd.HISTOGRAM[p1 - 1] then
			open:setColor(period, Up)
		elseif macd.HISTOGRAM[p1] < macd.HISTOGRAM[p1 - 1] then
			open:setColor(period, Down)
		end
	end

	if Two then
		Stochastic:update(mode)
		local p2 = core.findDate(macd.DATA, source:date(period), false);
		if core.crossesUnder(Stochastic.K, OS_level, p2) then
			open:setColor(period, OS_entry);
		elseif core.crossesOver(Stochastic.K, OS_level, p2) then
			open:setColor(period, OS_exit);
		elseif core.crossesOver(Stochastic.K, OB_level, p2) then
			open:setColor(period, OB_entry);
		elseif core.crossesUnder(Stochastic.K, OB_level, p2) then
			open:setColor(period, OB_exit);
		end
	end
	if show_rsi then
		rsi:update(mode);
		local p3 = core.findDate(rsi.DATA, source:date(period), false);
		if core.crossesUnder(rsi.DATA, rsi_os_level, p3) then
			open:setColor(period, OS_entry);
		elseif core.crossesOver(rsi.DATA, rsi_os_level, p3) then
			open:setColor(period, OS_exit);
		elseif core.crossesOver(rsi.DATA, rsi_ob_level, p3) then
			open:setColor(period, OB_entry);
		elseif core.crossesUnder(rsi.DATA, rsi_ob_level, p3) then
			open:setColor(period, OB_exit);
		end
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, successful, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
	end
end
