-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41915
-- Id: 9424

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
	indicator:name("Averages Overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("Price", "Price Source", "", "close")
	indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
	indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

	indicator.parameters:addString("Method", "Method", "", "MVA")
	indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder")
	indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA")
	indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA")
	indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA")
	indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA")
	indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA")
	indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA")
	indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA")
	indicator.parameters:addStringAlternative("Method", "T3", "", "T3")
	indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend")
	indicator.parameters:addStringAlternative("Method", "Median", "", "Median")
	indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean")
	indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA")
	indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS")
	indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2")
	indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen")
	indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth")
	indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA")

	indicator.parameters:addInteger("Period", "Period", "", 20)

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "Use Slope Filter", "", true)
	indicator.parameters:addBoolean("Two", "Use Cross Filter", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Color of Up in Uptrend", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("UpDn", "Color of Down in Up Trend", "", core.rgb(0, 200, 0))
	indicator.parameters:addColor("DnUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Dn", "Color of  Down in Down Trend", "", core.rgb(200, 0, 0))
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

local Method
local Period

local One, Two, Indicator

function Prepare(nameOnly)
	Method = instance.parameters.Method
	Period = instance.parameters.Period
	Price = instance.parameters.Price

	One = instance.parameters.One
	Two = instance.parameters.Two

	source = instance.source

	local Label1, Label2, Lebel3

	if One then
		Label1 = "On"
	else
		Label1 = "Off"
	end

	if Two then
		Label2 = "On"
	else
		Label2 = "Off"
	end

	local name =
		profile:id() ..
		"(" ..
			source:name() ..
				", " ..
					Price .. ", " .. Method .. ", " .. Period .. ", Slope Filter : " .. Label1 .. ", Cross Filter : " .. Label2 .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")
	Indicator = core.indicators:create("AVERAGES", source[Price], Method, Period, false)

	first = Indicator.DATA:first()

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

	Indicator:update(mode)

	if period < first then
		return
	end

	local ONE = nil
	local TWO = nil

	if One then
		if Indicator.DATA[period] > Indicator.DATA[period - 1] then
			ONE = true
		else
			ONE = false
		end
	end

	if Two then
		if source[Price][period] > Indicator.DATA[period] then
			TWO = true
		else
			TWO = false
		end
	end

	if ONE == nil and TWO == nil then
		open:setColor(period, instance.parameters.No)
	elseif One and not Two then
		if ONE then
			open:setColor(period, instance.parameters.Up)
		else
			open:setColor(period, instance.parameters.Dn)
		end
	elseif not One and Two then
		if TWO then
			open:setColor(period, instance.parameters.Up)
		else
			open:setColor(period, instance.parameters.Dn)
		end
	elseif One and Two then
		if ONE then
			if TWO then
				open:setColor(period, instance.parameters.Up)
			else
				open:setColor(period, instance.parameters.UpDn)
			end
		elseif not ONE then
			if TWO then
				open:setColor(period, instance.parameters.DnUp)
			else
				open:setColor(period, instance.parameters.Dn)
			end
		end
	else
		open:setColor(period, instance.parameters.No)
	end
end
