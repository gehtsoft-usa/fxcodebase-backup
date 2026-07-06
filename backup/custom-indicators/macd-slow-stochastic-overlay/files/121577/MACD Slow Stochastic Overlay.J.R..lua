-- Id: 
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

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "MACD Coloring", "", true)
	indicator.parameters:addBoolean("Two", "Stochastic Coloring", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("OB_entry", "Overbought entry color", "", core.rgb(128, 0, 0))
	indicator.parameters:addColor("OB_exit", "Overbought exit color", "", core.rgb(0, 128, 0))
	indicator.parameters:addColor("OS_entry", "Oversold entry color", "", core.rgb(128, 0, 0))
	indicator.parameters:addColor("OS_exit", "Oversold exit color", "", core.rgb(0, 128, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

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

function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

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
	TF[1] = instance.parameters.TF1

	if TF[1] == "Chart" then
		TF[1] = source:barSize()
	end

	TF[2] = instance.parameters.TF2

	if TF[2] == "Chart" then
		TF[2] = source:barSize()
	end

	if TF[1] ~= "Chart" then
		local s1, e1, s2, e2
		s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
		s2, e2 = core.getcandle(TF[1], 0, 0, 0)
		assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")
	end

	if TF[2] ~= "Chart" then
		local s1, e1, s2, e2
		s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
		s2, e2 = core.getcandle(TF[2], 0, 0, 0)
		assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")
	end

	if TF[1] ~= source:barSize() then
		Source[1] = core.host:execute("getSyncHistory", source:instrument(), TF[1], source:isBid(), 0, 100, 101)
		loading[1] = true

		macd = core.indicators:create("MACD", Source[1].close, SN, LN, IN)
	else
		macd = core.indicators:create("MACD", source, SN, LN, IN)
		first = macd.HISTOGRAM:first()
	end

	if TF[2] ~= source:barSize() then
		Source[2] = core.host:execute("getSyncHistory", source:instrument(), TF[2], source:isBid(), 0, 200, 201)
		loading[2] = true

		Stochastic = core.indicators:create("SSD", Source[2], K, SD, 3)
	else
		Stochastic = core.indicators:create("SSD", source, K, SD, 3)
		first = math.max(first, Stochastic.D:first())
	end

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	if loading[1] or loading[2] then
		return
	end

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		return
	end

	macd:update(mode)
	Stochastic:update(mode)

	if period < first then
		return
	end

	local S1 = 0
	local p1;
	if TF[1] ~= "Chart" and TF[1] ~= source:barSize() then
		p1 = Initialization(1, period)
		if not p1 then
			return
		end
	else
		p1 = period;
	end
	if macd.HISTOGRAM[p1] > macd.HISTOGRAM[p1 - 1] then
		S1 = 1
	elseif macd.HISTOGRAM[p1] < macd.HISTOGRAM[p1 - 1] then
		S1 = -1
	end
	if One then
		if S1 == 1 then
			open:setColor(period, Up)
		else
			open:setColor(period, Down)
		end
	end

	local p2;
	if TF[2] ~= "Chart" and TF[2] ~= source:barSize() then
		p2 = Initialization(2, period)
		if not p2 then
			return
		end
	else
		p2 = period;
	end
	if Two then
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
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading[1] = false
	elseif cookie == 101 then
		loading[1] = true
	end

	if cookie == 200 then
		loading[2] = false
	elseif cookie == 201 then
		loading[2] = true
	end

	if not loading1 and not loading2 then
		instance:updateFrom(0)
	end
end

function Initialization(id, period)
	local Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset)

	if loading[id] or Source[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local p = core.findDate(Source[id], Candle, false)

	-- candle is not found
	if p < 0 then
		return false
	else
		return p
	end
end
