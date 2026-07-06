-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33107
-- Id: 8716

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Generic Time Frame Weighted Indicator")
	indicator:description("Generic Time Frame Weighted Indicator")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addString("INDICATOR", "Indicator", "", "RSI")
	indicator.parameters:setFlag("INDICATOR", core.FLAG_INDICATOR)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("NV_color", "Color of TFWI", "Color of TFWI", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first
local source = nil
local INDICATOR
local TFWI = nil
local TF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local Ratio = {}
local Source = {}
local loading = {}
local Indicator = {}
local weekoffset, offset
local Sum
-- Routine
function Prepare(nameOnly)
	INDICATOR = instance.parameters.INDICATOR
	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ", " .. INDICATOR .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		offset = core.host:execute("getTradingDayOffset")
		weekoffset = core.host:execute("getTradingWeekOffset")

		local TEMP

		local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))
		local tmpparams = instance.parameters:getCustomParameters("INDICATOR")

		if tmpprofile:requiredSource() == core.Tick then
			TEMP = tmpprofile:createInstance(source.close, tmpparams)
		else
			TEMP = tmpprofile:createInstance(source, tmpparams)
		end

		first = TEMP.DATA:first()

		local s2, e2, s1, e1
		Sum = 0

		local i
		for i = 1, 13, 1 do
			s2, e2 = core.getcandle(TF[i], core.now(), 0, 0)
			Ratio[i] = (e2 - s2)
			Sum = Sum + Ratio[i]

			Source[i] =
				core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), first + 1, 2000 + i, 1000 + i)
			loading[i] = true

			local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))
			local tmpparams = instance.parameters:getCustomParameters("INDICATOR")

			if tmpprofile:requiredSource() == core.Tick then
				Indicator[i] = tmpprofile:createInstance(Source[i].close, tmpparams)
			else
				Indicator[i] = tmpprofile:createInstance(Source[i], tmpparams)
			end
		end
		TFWI = instance:addStream("TFWI", core.Line, name, "TFWI", instance.parameters.NV_color, first)
    TFWI:setPrecision(math.max(2, instance.source:getPrecision()));
		TFWI:setWidth(instance.parameters.width)
		TFWI:setStyle(instance.parameters.style)
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	core.host:execute("setStatus", "")

	local i, p
	local FLAG = false

	for i = 1, 13, 1 do
		if loading[i] then
			FLAG = true
		end
	end

	if FLAG then
		return
	end

	TFWI[period] = 0

	for i = 1, 13, 1 do
		Indicator[i]:update(mode)
		p = Initialization(period, i)
		if p ~= false and Indicator[i].DATA:hasData(p) then
			TFWI[period] = TFWI[period] + Indicator[i].DATA[p] * (Ratio[i] / Sum)
		end
	end
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset)

	if loading[id] or Source[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(Source[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local i, j

	for i = 1, 13, 1 do
		if cookie == (1000 + i) then
			loading[i] = true
		elseif cookie == (2000 + i) then
			loading[i] = false
		end
	end

	local FLAG = false
	local Number = 0

	for i = 1, 13, 1 do
		if loading[i] then
			FLAG = true
			Number = Number + 1
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (13 - Number) .. " / " .. (13))
	else
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end
