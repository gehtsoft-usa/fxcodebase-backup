-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5087
-- Id: 8699

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
	indicator:name("Generic Dynamic Momentum Oscillator")
	indicator:description("Generic Dynamic Momentum Oscillator")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addString("INDICATOR", "Indicator", "", "RSI")
	indicator.parameters:setFlag("INDICATOR", core.FLAG_INDICATOR)
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1, 100)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 21)
	indicator.parameters:addString("Method", "MA Method", "Method", "MVA")
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")

	indicator.parameters:addInteger("Mc", "Central Line of the Oscillator", "Midpoint of the Oscillator", 50)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "DMO Color", "DMO Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Central Line Style")
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Mc
local Number
local Period
local INDICATOR
local Indicator = nil
local Method
local FIRST
local source = nil
local Count
-- Streams block
local DMO = nil
local TEMP, MA
local INDEX
-- Routine
function Prepare(nameOnly)
	Mc = instance.parameters.Mc
	Period = instance.parameters.Period
	INDICATOR = instance.parameters.INDICATOR
	Number = instance.parameters.Number
	Method = instance.parameters.Method
	Number = Number - 1
	source = instance.source

	local name =
		profile:id() ..
		"(" .. source:name() .. ", " .. tostring(INDICATOR) .. ", " .. tostring(Mc) .. ", " .. tostring(Period) .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))
		local tmpparams = instance.parameters:getCustomParameters("INDICATOR")
	
		if tmpprofile:requiredSource() == core.Tick then
			TEMP = tmpprofile:createInstance(source.close, tmpparams)
		else
			TEMP = tmpprofile:createInstance(source, tmpparams)
		end
	
		Count = TEMP:getStreamCount()
	
		if Number >= Count then
			Number = Count
			assert(false, "Incorrect index of stream. The indicator has only " .. Count .. " stream(s).")
		end
	
		INDEX = TEMP:getStream(Number)
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, INDEX, Period)
	
		FIRST = INDEX:first()
	
		DMO = instance:addStream("DMO", core.Line, name, "DMO", instance.parameters.color, FIRST)
    DMO:setPrecision(math.max(2, instance.source:getPrecision()));
		DMO:setWidth(instance.parameters.width)
		DMO:setStyle(instance.parameters.style)
		DMO:addLevel(
			Mc,
			instance.parameters.level_overboughtsold_style,
			instance.parameters.level_overboughtsold_width,
			instance.parameters.level_overboughtsold_color
		)
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	TEMP:update(mode)
	MA:update(mode)

	if period < FIRST then
		return
	end

	DMO[period] = Mc - (MA.DATA[period] - INDEX[period])
end
