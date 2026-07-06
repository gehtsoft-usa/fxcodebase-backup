-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68869

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

-- Indicator profile initialization routine

function Init()
	indicator:name("Bid Ask Volume")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color1", "Bid Volume Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

	indicator.parameters:addColor("color2", "Ask Volume Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil

local Oscillator
local HighLow, OpenClose
-- Routine
function Prepare(nameOnly)
	Period1 = instance.parameters.Period1
	Period2 = instance.parameters.Period2
	Period3 = instance.parameters.Period3

	local Parameters = ""

	local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Parameters .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	source = instance.source
	first = source:first()

	HighLow = instance:addInternalStream(0, 0)
	OpenClose = instance:addInternalStream(0, 0)

	Oscillator = instance:addInternalStream(0, 0)

	Bid = instance:addStream("Bid", core.Line, " Bid", " Bid", instance.parameters.color1, first)
	Bid:setWidth(instance.parameters.width1)
	Bid:setStyle(instance.parameters.style1)
	Bid:setPrecision(math.max(2, source:getPrecision()))

	Ask = instance:addStream("Ask", core.Line, " Ask", " Ask", instance.parameters.color2, first)
	Ask:setWidth(instance.parameters.width2)
	Ask:setStyle(instance.parameters.style2)
	Ask:setPrecision(math.max(2, source:getPrecision()))
end

-- Indicator calculation routine
function Update(period, mode)
	if period < first then
		return
	end

	HighLow[period] = source.high[period] - source.low[period]
	OpenClose[period] = source.close[period] - source.open[period]
	Oscillator[period] = OpenClose[period] / HighLow[period]

	if Oscillator[period] > 0 then
		Ask[period] = (source.volume[period]) * Oscillator[period]
		Bid[period] = (source.volume[period]) * (1 - Oscillator[period])
	else
		Ask[period] = (source.volume[period]) * (1 - Oscillator[period])
		Bid[period] = (source.volume[period]) * Oscillator[period]
	end
end
