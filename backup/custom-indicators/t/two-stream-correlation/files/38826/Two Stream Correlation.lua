-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22506
-- Id: 7156

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Two Stream Correlation")
	indicator:description("Two Stream Correlation")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 20)

	indicator.parameters:addGroup("First Stream")

	indicator.parameters:addString("M1", "First Source", "", "I")
	indicator.parameters:addStringAlternative("M1", "Indicator", "", "I")
	indicator.parameters:addStringAlternative("M1", "Price", "", "P")

	indicator.parameters:addString("I1", "1.Indicator", "", "")
	indicator.parameters:setFlag("I1", core.FLAG_INDICATOR)

	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1, 100)

	indicator.parameters:addString("S1", "First Price Stream Source ", "", "close")
	indicator.parameters:addStringAlternative("S1", "open", "", "open")
	indicator.parameters:addStringAlternative("S1", "high", "", "high")
	indicator.parameters:addStringAlternative("S1", "low", "", "low")
	indicator.parameters:addStringAlternative("S1", "close", "", "close")
	indicator.parameters:addStringAlternative("S1", "median", "", "median")
	indicator.parameters:addStringAlternative("S1", "typical", "", "typical")
	indicator.parameters:addStringAlternative("S1", "weighted", "", "weighted")

	indicator.parameters:addGroup("Second Stream")
	indicator.parameters:addString("M2", "Second Stream Source", "", "I")
	indicator.parameters:addStringAlternative("M2", "Indicator", "", "I")
	indicator.parameters:addStringAlternative("M2", "Price", "", "P")

	indicator.parameters:addString("I2", "2.Indicator", "", "")
	indicator.parameters:setFlag("I2", core.FLAG_INDICATOR)

	indicator.parameters:addInteger("Number2", "Data Stream Number", "", 1, 1, 100)

	indicator.parameters:addString("S2", "Second Price Stream Source ", "", "close")
	indicator.parameters:addStringAlternative("S2", "open", "", "open")
	indicator.parameters:addStringAlternative("S2", "high", "", "high")
	indicator.parameters:addStringAlternative("S2", "low", "", "low")
	indicator.parameters:addStringAlternative("S2", "close", "", "close")
	indicator.parameters:addStringAlternative("S2", "median", "", "median")
	indicator.parameters:addStringAlternative("S2", "typical", "", "typical")
	indicator.parameters:addStringAlternative("S2", "weighted", "", "weighted")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Correlation_color", "Color of Correlation", "Color of Correlation", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period

local first
local source = nil
-- Streams block
local Correlation = nil
local indicator1, indicator2
local I1, I2, M1, M2, S1, S2
local DATA1, DATA2, Number2, Number1
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	source = instance.source
	I1 = instance.parameters.I1
	I2 = instance.parameters.I2
	M1 = instance.parameters.M1
	M2 = instance.parameters.M2
	S1 = instance.parameters.S1
	S2 = instance.parameters.S2
	Number2 = instance.parameters.Number2
	Number1 = instance.parameters.Number1

	Number1 = Number1 - 1
	Number2 = Number2 - 1

	first = source:first()

	local Count

	if M1 ~= "I" then
		I1 = S1
	end
	if M2 ~= "I" then
		I2 = S2
	end

	local name =
		profile:id() ..
		"(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(I1) .. ", " .. tostring(I2) .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		if M1 == "I" then
			local iprofile1
			local iparams1
	
			iprofile1 = core.indicators:findIndicator(instance.parameters:getString("I1"))
			iparams1 = instance.parameters:getCustomParameters("I1")
			if iprofile1:requiredSource() == core.Tick then
				indicator1 = iprofile1:createInstance(source.close, iparams1)
			else
				indicator1 = iprofile1:createInstance(source, iparams1)
			end
	
			Count = indicator1:getStreamCount()
	
			if Number1 >= Count then
				Number1 = Count
				assert(false, "Incorrect index of stream.  1. indicator has only " .. Count .. " stream(s).")
			end
	
			DATA1 = indicator1:getStream(Number1)
			first = math.max(first, indicator1.DATA:first())
		else
			I1 = S1
			DATA1 = source[S1]
		end
	
		if M2 == "I" then
			local iprofile2
			local iparams2
	
			iprofile2 = core.indicators:findIndicator(instance.parameters:getString("I2"))
			iparams2 = instance.parameters:getCustomParameters("I2")
			if iprofile2:requiredSource() == core.Tick then
				indicator2 = iprofile2:createInstance(source.close, iparams2)
			else
				indicator2 = iprofile2:createInstance(source, iparams2)
			end
	
			Count = indicator2:getStreamCount()
	
			if Number2 >= Count then
				Number2 = Count
				assert(false, "Incorrect index of stream.  2. indicator has only " .. Count .. " stream(s).")
			end
	
			DATA2 = indicator2:getStream(Number2)
			first = math.max(first, indicator2.DATA:first())
		else
			I2 = S2
			DATA2 = source[S2]
		end
		Correlation =
			instance:addStream("Correlation", core.Line, name, "Correlation", instance.parameters.Correlation_color, first)
    Correlation:setPrecision(math.max(2, instance.source:getPrecision()));
		Correlation:setWidth(instance.parameters.width)
		Correlation:setStyle(instance.parameters.style)
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < first or not source:hasData(period) then
		return
	end

	if M1 == "I" then
		indicator1:update(mode)
	end

	if M2 == "I" then
		indicator2:update(mode)
	end

	if period < first + Period then
		return
	end

	Correlation[period] = mathex.correl(DATA1, DATA2, period - Period + 1, period, period - Period + 1, period)
end
