-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14219
-- Id: 5920

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Generic Index")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)
	indicator:setTag("group", "Currency Indexes")

	local InitSelection = {"USD", "GBP", "JPY", "AUD", "CHF", "EUR"}
	indicator.parameters:addString("Selection", "Select Index Currency", "", "USD")
	for i = 1, 6, 1 do
		indicator.parameters:addStringAlternative("Selection", InitSelection[i], "", InitSelection[i])
	end

	indicator.parameters:addColor("color", "color", "color", core.rgb(0, 255, 0))
end
local Instrument
local InstrumentList = {}
local patern = "(%a%a%a)/(%a%a%a)"
local crncy1, crncy2
local count = 0
local Selection

local source
local barSize
local loading = {}
local offset
local weekoffset

--*********
local instrument
local out
local Source = {}

local subscription = {}
local sub = 0

local first = nil
local last = nil
-- data table
local host
local weight = {}

-- prepare the indicator
function Prepare(nameOnly)
	Selection = instance.parameters.Selection
	source = instance.source
	host = core.host
	barSize = source:barSize()
	offset = host:execute("getTradingDayOffset")
	weekoffset = host:execute("getTradingWeekOffset")
	sub = 0

	Instrument, count = getInstrumentList()

	local i
	for i = 1, count, 1 do
		crncy1, crncy2 = string.match(Instrument[i], patern)

		if crncy1 == Selection or crncy2 == Selection then
			sub = sub + 1
			subscription[sub] = Instrument[i]
			if not nameOnly then
				Source[sub] =
					core.host:execute("getSyncHistory", subscription[sub], source:barSize(), source:isBid(), 1, 200 + sub, 100 + sub)
			end
			loading[sub] = true
		end
	end

	for i = 1, sub, 1 do
		crncy1, crncy2 = string.match(subscription[i], patern)
		if crncy2 == Selection then
			weight[i] = -1 / sub
		else
			weight[i] = 1 / sub
		end
	end

	local name = profile:id() .. "( " .. Selection .. ", " .. sub .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	out = instance:addStream("out", core.Line, "", "label", instance.parameters.color, source:first())
    out:setPrecision(math.max(2, instance.source:getPrecision()));
end

function getInstrumentList()
	local list = {}

	local num = 0
	local row, enum

	enum = host:findTable("offers"):enumerator()

	row = enum:next()
	while row ~= nil do
		num = num + 1
		list[num] = row.Instrument
		row = enum:next()
	end

	return list, num
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = false
	local Count = 0

	for j = 1, sub, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end
	end

	if Flag then
		core.host:execute("setStatus", " Loading " .. (sub - Count) .. "/" .. sub)
	else
		core.host:execute("setStatus", " Loaded " .. (sub - Count) .. "/" .. sub)
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

-- the function which is called to calculate the period
function Update(period)
	local Flag = false

	for j = 1, sub, 1 do
		if loading[j] then
			Flag = true
		end
	end

	if Flag then
		return
	end

	local Test = 0

	local x = 1
	for i = 1, sub, 1 do
		p1 = core.findDate(Source[i], source:date(source:first()), false)
		p2 = core.findDate(Source[i], source:date(period), false)

		if p1 ~= -1 and p2 ~= -1 then
			firstprice = Source[i].close[p1]
			lastprice = Source[i].close[p2]
			Test = Test + 1
			x = 100 * (1 / math.pow(firstprice, weight[i]))
			x = x * math.pow(lastprice, weight[i])
		end
	end

	if Test == sub then
		out[period] = x
	end
end
