-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13771
-- Id: 5872

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
	indicator:name("Filter Overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000)
	indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000)
	indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000)

	indicator.parameters:addGroup("DMI Calculation")
	indicator.parameters:addInteger("DN", "Period", "", 14, 2, 1000)

	indicator.parameters:addGroup("EMA Slope Calculation")
	indicator.parameters:addInteger("EN", "Period", "", 50, 2, 1000)

	indicator.parameters:addGroup("EMA Price Calculation")
	indicator.parameters:addInteger("PN", "Period", "", 50, 2, 1000)

	indicator.parameters:addGroup("Price")
	indicator.parameters:addString("Price", "Data Source", "", "close")
	indicator.parameters:addStringAlternative("Price", "Open", "", "open")
	indicator.parameters:addStringAlternative("Price", "High", "", "high")
	indicator.parameters:addStringAlternative("Price", "Low", "", "low")
	indicator.parameters:addStringAlternative("Price", "Close", "", "close")
	indicator.parameters:addStringAlternative("Price", "Median", "", "median")
	indicator.parameters:addStringAlternative("Price", "Typical", "", "typical")
	indicator.parameters:addStringAlternative("Price", "Weighted ", "", "weighted")

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "Use DMI Filter", "", true)
	indicator.parameters:addBoolean("Two", "Use EMA Slope Filter", "", true)
	indicator.parameters:addBoolean("Three", "Use MACD Filter", "", true)
	indicator.parameters:addBoolean("Four", "Use EMA / Price  Filter", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil

local Price

local open = nil
local close = nil
local high = nil
local low = nil

local SN, LN, IN = nil
local EN, DN
local MACD
local DMI
local EMA
local PEMA
local PN
local One, Two, Three, Four

function Prepare(nameOnly)
	PN = instance.parameters.PN
	EN = instance.parameters.EN
	DN = instance.parameters.DN
	IN = instance.parameters.IN
	SN = instance.parameters.SN
	LN = instance.parameters.LN
	Price = instance.parameters.Price

	One = instance.parameters.One
	Two = instance.parameters.Two
	Three = instance.parameters.Three
	Four = instance.parameters.Four

	if (LN <= SN) then
		error("The short EMA period must be smaller than long EMA period")
	end

	source = instance.source
	local name =
		profile:id() ..
		"(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", " .. EN .. ", " .. DN .. ", " .. PN .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	MACD = core.indicators:create("MACD", source[Price], SN, LN, IN)
	EMA = core.indicators:create("EMA", source[Price], EN)
	DMI = core.indicators:create("DMI", source, DN)
	PEMA = core.indicators:create("EMA", source[Price], PN)


	first = math.max(EMA.DATA:first(), DMI.DATA:first(), EMA.DATA:first(), MACD.SIGNAL:first(), PEMA.DATA:first())

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		return
	end

	local ONE = nil
	local TWO = nil
	local THREE = nil
	local FOUR = nil

	MACD:update(mode)
	EMA:update(mode)
	DMI:update(mode)
	PEMA:update(mode)

	if One then
		if DMI.DIP[period] > DMI.DIM[period] then
			ONE = true
		else
			ONE = false
		end
	end

	if Two then
		if EMA.DATA[period] > EMA.DATA[period - 1] then
			TWO = true
		else
			TWO = false
		end
	end

	if Three then
		if MACD.MACD[period] > MACD.SIGNAL[period] then
			THREE = true
		else
			THREE = false
		end
	end

	if Four then
		if source.close[period] > PEMA.DATA[period] then
			FOUR = true
		else
			FOUR = false
		end
	end

	if ONE == nil and TWO == nil and THREE == nil and FOUR == nil then
		open:setColor(period, instance.parameters.No)
	elseif ONE ~= false and TWO ~= false and THREE ~= false and FOUR ~= false then
		open:setColor(period, instance.parameters.Up)
	elseif ONE ~= true and TWO ~= true and THREE ~= true and FOUR ~= true then
		open:setColor(period, instance.parameters.Dn)
	else
		open:setColor(period, instance.parameters.No)
	end
end
