-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68993

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
	indicator:name("Tick Volume")
	indicator:description("Tick Volume")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("Method", "Method", "Method", "Cumulative")
	indicator.parameters:addStringAlternative("Method", "Separated", "Separated", "Separated")
	indicator.parameters:addStringAlternative("Method", "Cumulative", "Cumulative", "Cumulative")
	indicator.parameters:addStringAlternative("Method", "Absolute Cumulative", "Absolute Cumulative", "Absolute")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Color of Up Volume", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Color of Down Volume", "", core.rgb(255, 0, 0))
end

local Method
local first
local source = nil
local From, To
-- Streams block
local Up = nil
local Down = nil
local Bid = nil
local Ask = nil
local loadingAsk, loadingBid
local weekoffset, offset
local prevAsk, prevBid
local UpCount = 0
local DownCount = 0
local Cumulative
local Absolute
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Method = instance.parameters.Method

	offset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		if Method == "Cumulative" then
			Up = instance:addInternalStream(0, 0)
			Down = instance:addInternalStream(0, 0)
			Cumulative =
				instance:addStream("Cumulative", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.Up, first)
			Cumulative:setPrecision(math.max(2, instance.source:getPrecision()))
		elseif Method == "Absolute" then
			Up = instance:addInternalStream(0, 0)
			Down = instance:addInternalStream(0, 0)
			Absolute =
				instance:addStream(
				"Absolute",
				core.Bar,
				name .. ".Absolute Cumulative",
				"Absolute Cumulative",
				instance.parameters.Up,
				first
			)
			Absolute:setPrecision(math.max(2, instance.source:getPrecision()))
		else
			Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.Up, first)
			Up:setPrecision(math.max(2, instance.source:getPrecision()))
			Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.Down, first)
			Down:setPrecision(math.max(2, instance.source:getPrecision()))
		end
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local init = true
function Update(period)
	if period < first or not source:hasData(period) then
		return
	end

	local from, to

	if Bid == nil then
		-- if the data is not loaded yet at all
		-- load the data
		from = source:date(source:first()) -- oldest data to load
		if source:isAlive() then -- newest data to load or 0 if the source is "alive"
			to = 0
		else
			to = source:date(source:size() - 1)
		end
		load_from = from
		loadingBid = true
		loadingAsk = true
		Bid = core.host:execute("getHistory", 1, source:instrument(), "t1", from, to, true)
		Ask = core.host:execute("getHistory", 2, source:instrument(), "t1", from, to, false)
		return
	end

	if loadingBid or loadingAsk then
		return
	end

	local curr_date = source:date(period)

	if curr_date < load_from then
		-- if the data we are trying to get is oldest than previously loaded
		-- the extend the history to the oldest data we can request
		from = source:date(source:first()) -- load from the oldest data we have in source
		if Bid:size() > Bid:first() then
			to = Bid:date(Bid:first()) -- to the oldest data we have in other instrument
		else
			to = load_from
		end
		load_from = from
		loading = true
		core.host:execute("extendHistory", 1, Bid, from, to)
		core.host:execute("extendHistory", 2, Ask, from, to)
		return
	end

	s, e = core.getcandle(source:barSize(), source:date(period), offset, weekoffset)

	s = core.findDate(Ask, s, false)
	e = core.findDate(Ask, e, false)

	if s == -1 or e == -1 then
		return
	end

	for index = s, e, 1 do
		Calculate(index, period)
	end

	if Method == "Cumulative" then
		Cumulative[period] = Up[period] + Down[period]
		if Cumulative[period] > 0 then
			Cumulative:setColor(period, instance.parameters.Up)
		else
			Cumulative:setColor(period, instance.parameters.Down)
		end
	elseif Method == "Absolute" then
		Absolute[period] = Up[period] + math.abs(Down[period])
		if Up[period] > math.abs(Down[period]) then
			Absolute:setColor(period, instance.parameters.Up)
		else
			Absolute:setColor(period, instance.parameters.Down)
		end
	end
end

function Calculate(index, period)
	if index < Bid:first() or index < Ask:first() or not Bid:hasData(index) or not Ask:first(index) then
		return
	end
	local val = Ask[index] + Bid[index];
	local prevValue = Ask[index - 1] + Bid[index - 1];
	if index == s then
		Up[period] = 0
		Down[period] = 0
	end
	if Ask[index] ~= prevAsk then
		if val > prevValue then
			Up[period] = Up[period] + 1
		else
			Down[period] = Down[period] - 1
		end
		prevAsk = Ask[index]
	end

	if Bid[index] ~= prevBid then
		if val > prevValue then
			Up[period] = Up[period] + 1
		else
			Down[period] = Down[period] - 1
		end
		prevBid = Bid[index]
	end
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 then
		-- update the indicator output when loading is finished
		loadingAsk = false
	elseif cookie == 2 then
		loadingBid = false
	-- update the indicator output when loading is finished
	end

	if loadingAsk == false and loadingBid == false then
		instance:updateFrom(source:first())
	end
end
