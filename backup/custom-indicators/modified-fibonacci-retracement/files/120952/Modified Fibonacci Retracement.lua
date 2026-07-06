-- Id: 22239
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66302

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
	indicator:name("Modified Fibonacci Retracement")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("TF", "Pivot Time Frame", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

	indicator.parameters:addBoolean("Historical", "Show Historical", "", true)

	indicator.parameters:addGroup("Level Selection")
	indicator.parameters:addBoolean("On1", " Use 1. Level", "", true)
	indicator.parameters:addDouble("Level1", "Level", "", 0.875)
	indicator.parameters:addBoolean("On2", " Use 2. Level", "", true)
	indicator.parameters:addDouble("Level2", "Level", "", 0.764)
	indicator.parameters:addBoolean("On3", " Use 3. Level", "", true)
	indicator.parameters:addDouble("Level3", "Level", "", 0.618)
	indicator.parameters:addBoolean("On4", " Use 4. Level", "", true)
	indicator.parameters:addDouble("Level4", "Level", "", 0.5)

	indicator.parameters:addBoolean("On5", " Use 5. Level", "", true)
	indicator.parameters:addDouble("Level5", "Level", "", 0.382)
	indicator.parameters:addBoolean("On6", " Use 6. Level", "", true)
	indicator.parameters:addDouble("Level6", "Level", "", 0.236)
	indicator.parameters:addBoolean("On7", " Use 7. Level", "", true)
	indicator.parameters:addDouble("Level7", "Level", "", 0.125)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true)
	indicator.parameters:addString("LabelLoc", "Line labels location", "Defines the location of line labels.", "E")
	indicator.parameters:addStringAlternative("LabelLoc", "At the end", "", "E")
	indicator.parameters:addStringAlternative("LabelLoc", "At the beginning", "", "B")
	indicator.parameters:addStringAlternative("LabelLoc", "At both", "", "A")

	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color5", "5. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color6", "6. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color7", "7. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Historical
local first
local source = nil
local loading
-- Streams block
local Source
local TF
local On = {}
local Level = {}
local LabelLoc
local ShowLabels

local O_END = 1
local O_BEG = 2
local O_BOTH = 3

-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Historical = instance.parameters.Historical
	TF = instance.parameters.TF
	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	for i = 1, 7, 1 do
		Level[i] = instance.parameters:getDouble("Level" .. i)
		On[i] = instance.parameters:getBoolean("On" .. i)
	end

	local s1, e1, s2, e2
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
	s2, e2 = core.getcandle(TF, 0, 0, 0)
	assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")

	ShowLabels = instance.parameters.ShowLabels
	if instance.parameters.LabelLoc == "E" then
		LabelLoc = O_END
	elseif instance.parameters.LabelLoc == "B" then
		LabelLoc = O_BEG
	elseif instance.parameters.LabelLoc == "A" then
		LabelLoc = O_BOTH
	else
		assert(false, "Unknown label location" .. ": " .. instance.parameters.LabelLoc)
	end

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 300, 100, 101)
	loading = true

	instance:ownerDrawn(true)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Arial", 8, 8, 0)
		for i = 1, 7, 1 do
			context:createPen(
				i,
				context:convertPenStyle(instance.parameters:getInteger("style" .. i)),
				instance.parameters:getInteger("width" .. i),
				instance.parameters:getColor("color" .. i)
			)
		end
		init = true
	end

	if loading then
		return
	end

	local s, e

	if Historical then
		local p1 = core.findDate(Source, source:date(context:firstBar()), false)
		local p2 = core.findDate(Source, source:date(context:lastBar()), false)

		for p = p1, p2, 1 do
			s, e =
				core.getcandle(
				TF,
				Source:date(p),
				core.host:execute("getTradingDayOffset"),
				core.host:execute("getTradingWeekOffset")
			)

			P1 = core.findDate(source, s, false)
			P2 = core.findDate(source, e, false)

			x1, x = context:positionOfBar(P1)
			x2, x = context:positionOfBar(P2)

			for i = 1, 7, 1 do
				if On[i] then
					price = Source.open[p] ^ Level[i] * Source.close[p] ^ (1 - Level[i])
					visible, y = context:pointOfPrice(price)
					context:drawLine(i, x1, y, x2, y, 0)
					if ShowLabels then
						local label = tostring(Level[i])
						width, height = context:measureText(1, label, 0)
						if LabelLoc == O_END or LabelLoc == O_BOTH then
							context:drawText(1, label, instance.parameters:getColor("color" .. i), -1, x2, y - height, x2 + width, y, 0)
						end
						if LabelLoc == O_BEG or LabelLoc == O_BOTH then
							context:drawText(1, label, instance.parameters:getColor("color" .. i), -1, x1, y - height, x1 + width, y, 0)
						end
					end
				end
			end
		end
	else
		p = Source:size() - 1
		s, e =
			core.getcandle(
			TF,
			Source:date(p),
			core.host:execute("getTradingDayOffset"),
			core.host:execute("getTradingWeekOffset")
		)

		P1 = core.findDate(source, s, false)
		P2 = core.findDate(source, e, false)

		x1, x = context:positionOfBar(P1)
		x2, x = context:positionOfBar(P2)

		for i = 1, 7, 1 do
			if On[i] then
				price = Source.open[Source:size() - 1] ^ Level[i] * Source.close[Source:size() - 1] ^ (1 - Level[i])
				visible, y = context:pointOfPrice(price)
				context:drawLine(i, x1, y, x2, y, 0)
				if ShowLabels then
					local label = tostring(Level[i])
					width, height = context:measureText(1, label, 0)
					if LabelLoc == O_END or LabelLoc == O_BOTH then
						context:drawText(1, label, instance.parameters:getColor("color" .. i), -1, x2, y - height, x2 + width, y, 0)
					end
					if LabelLoc == O_BEG or LabelLoc == O_BOTH then
						context:drawText(1, label, instance.parameters:getColor("color" .. i), -1, x1, y - height, x1 + width, y, 0)
					end
				end
			end
		end
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false
		instance:updateFrom(0)
	elseif cookie == 101 then
		loading = true
	end
end
