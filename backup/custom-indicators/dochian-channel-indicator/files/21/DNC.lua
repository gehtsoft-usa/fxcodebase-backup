-- Id: 22

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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

-- http://vtsystems.com/resources/helps/0000/HTML_VTtrader_Help_Manual/index.html?ti_donchianchannel.html
--

-- initializes the indicator
function Init()
	-- indicator:fail()
	indicator:name("Donchian Channel")
	indicator:description(
		"The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods."
	)
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000)
	indicator.parameters:addString("AC", "Analyze the current period", "", "yes")
	indicator.parameters:addStringAlternative("AC", "no", "", "no")
	indicator.parameters:addStringAlternative("AC", "yes", "", "yes")

	indicator.parameters:addString("SM", "Show middle line", "", "no")
	indicator.parameters:addStringAlternative("SM", "no", "", "no")
	indicator.parameters:addStringAlternative("SM", "yes", "", "yes")

	indicator.parameters:addBoolean("Show", "Show Projections", "", false)

	indicator.parameters:addGroup("Line Style")
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Label Style")
	indicator.parameters:addBoolean("ShowLabel", "Show Label", "", true)
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 10)
end

local first = 0
local n = 0
local ac = true
local sm = false
local source = nil
local dn = nil
local du = nil
local dm = nil
local Show
local Color
local min = {}
local max = {}
local Size
local ShowLabel
-- initializes the instance of the indicator
function Prepare(nameOnly)
	source = instance.source
	n = instance.parameters.N

	local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ac = (instance.parameters.AC == "yes")
	sm = (instance.parameters.SM == "yes")
	Color = instance.parameters.Color
	Size = instance.parameters.Size
	local min = {}
	local max = {}

	Show = instance.parameters.Show
	ShowLabel = instance.parameters.ShowLabel

	first = n + source:first() - 1
	if (not ac) then
		first = first + 1
	end

	du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU, first)
	du:setWidth(instance.parameters.width1)
	du:setStyle(instance.parameters.style1)
	dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first)
	dn:setWidth(instance.parameters.width2)
	dn:setStyle(instance.parameters.style2)
	if (sm) then
		dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM, first)
		dm:setWidth(instance.parameters.width3)
		dm:setStyle(instance.parameters.style3)
	end

	if Show then
		instance:ownerDrawn(true)
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 or min[1] == nil then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style1),
			instance.parameters.width1,
			instance.parameters.clrDU
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style2),
			instance.parameters.width2,
			instance.parameters.clrDN
		)
		init = true
	end

	local X2, x = context:positionOfBar(source:size() - 1)
	local X1, x = context:positionOfBar(source:size() - 2)
	local Candle = X2 - X1

	context:createFont(3, "Arial", Candle / 3, Size, 0)

	for Shift = 1, n, 1 do
		width, height = context:measureText(3, tostring(n - Shift + 1), 0)

		visible, y1 = context:pointOfPrice(max[Shift])
		context:drawLine(1, X2 + Candle * n - (Shift) * Candle, y1, X2 + Candle * n - (Shift - 1) * Candle, y1)
		if ShowLabel then
			context:drawText(
				3,
				tostring(n - Shift + 1),
				Color,
				-1,
				X2 + Candle * n - (Shift) * Candle,
				y1 - height,
				X2 + Candle * n - (Shift) * Candle + width,
				y1,
				0
			)
		end

		visible, y2 = context:pointOfPrice(min[Shift])
		context:drawLine(2, X2 + Candle * n - (Shift) * Candle, y2, X2 + Candle * n - (Shift - 1) * Candle, y2)
		if ShowLabel then
			context:drawText(
				3,
				tostring(n - Shift + 1),
				Color,
				-1,
				X2 + Candle * n - (Shift) * Candle,
				y2,
				X2 + Candle * n - (Shift) * Candle + width,
				y2 + height,
				0
			)
		end
	end
end

-- calculate the value
function Update(period)
	if (period < first) then
		return
	end

	if period == source:size() - 1 then
		for Shift = 1, n, 1 do
			if (ac) then
				min[Shift], max[Shift] = mathex.minmax(source, period - Shift + 1, period)
			else
				min[Shift], max[Shift] = mathex.minmax(source, period - Shift + 1 - 1, period - 1)
			end
		end

		dn[period] = min[n]
		du[period] = max[n]
	else
		if (ac) then
			dn[period], du[period] = mathex.minmax(source, period - n + 1, period)
		else
			dn[period], du[period] = mathex.minmax(source, period - n + 1 - 1, period - 1)
		end
	end

	if (sm) then
		dm[period] = (du[period] + dn[period]) / 2
	end
end
