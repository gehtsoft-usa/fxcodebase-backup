-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69826

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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("Generic Aussie Index")
	indicator:description("Generic Index")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator:setTag("group", "Currency Indexes")

	indicator.parameters:addGroup("Selector")

	AddInstrument(1, "EUR/AUD")
	AddInstrument(2, "AUD/JPY")
	AddInstrument(3, "GBP/AUD")
	AddInstrument(4, "AUD/USD")

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("base_instrument", "Base Instrument", "Base Instrument", "AUD")

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("color", "color", "color", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)
end

function AddInstrument(id, Instrument)
	indicator.parameters:addBoolean("Use" .. id, " Use " .. id .. " Instrument", "Use", true)
	indicator.parameters:addString("Instrument" .. id, id .. ". Instrument", " Instrument", Instrument)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source = nil

local Instrument = {}
local dayoffset, weekoffset

local SCALEFACTOR

local Close
local Open
local High
local Low

local SourceData = {}
local label = {}
local base_instrument
local pauto = "(%a%a%a)/(%a%a%a)"
local Index = {}
local Number
local loading = {}
local Method
local tmp = {}
local MyFirst=false;
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")
	Method = instance.parameters.Method
	base_instrument = instance.parameters.base_instrument

	local name = profile:id() .. "()"
	instance:name(name)
	if nameOnly then
		return
	end

	Number = 0
	for i = 1, 4, 1 do
		if instance.parameters:getBoolean("Use" .. i) then
			Number = Number + 1
			Instrument[Number] = instance.parameters:getString("Instrument" .. i)
		end
	end

	Close = instance:addStream("Out", core.Line, "", base_instrument, instance.parameters.color, first)
	Close:setWidth(instance.parameters.width)
	Close:setStyle(instance.parameters.style)
	Close:setPrecision(math.max(5, instance.source:getPrecision()))

	for i = 1, Number, 1 do
		crncy1, crncy2 = string.match(Instrument[i], pauto)
		if crncy1 == base_instrument then
			Index[i] = 1
		elseif crncy2 == base_instrument then
			Index[i] = -1
		else
			error("Selected instrument should contain " .. base_instrument)
		end

		assert(core.host:findTable("offers"):find("Instrument", Instrument[i]) ~= nil, "Subscribe for " .. Instrument[i]);
		SourceData[i] =
			core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0, 200 + i, 100 + i)
		loading[i] = true
	end
	MyFirst=false
end
-- Indicator calculation routine

function Update(period)
	if period < source:first() then
		return
	end

	local Flag = false
	for i = 1, Number, 1 do
		if loading[i] then
			Flag = true
		end
	end

	if Flag then
		return
	end

	local p = {}
	local denominator = 1
	local numerator = 1
	local RETURN = false

	for i = 1, Number, 1 do
		p[i] = Initialization(period, i)
		if p[i] == false then
			RETURN = true
		end
	end

	if RETURN then
		Close[period] = nil
		return
	end

	if not MyFirst then
	MyFirst=true;
		Close[period] = 100

		for i = 1, Number, 1 do
			tmp[i] = SourceData[i].close[p[i]]
			denominator = denominator * (1 ^ (Index[i] / Number))
		end

		SCALEFACTOR = 100 / denominator
	else
		for i = 1, Number, 1 do
			numerator = numerator * ((SourceData[i].close[p[i]] / tmp[i]) ^ (Index[i] / Number))
		end

		Close[period] = numerator * SCALEFACTOR
	end
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = false
	local Count = 0

	for j = 1, Number, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
			instance:updateFrom(0)
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end

		if Flag then
			core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
		else
			core.host:execute("setStatus", " Loaded " .. (Number - Count) .. "/" .. Number)
		end
	end

	return core.ASYNC_REDRAW
end
