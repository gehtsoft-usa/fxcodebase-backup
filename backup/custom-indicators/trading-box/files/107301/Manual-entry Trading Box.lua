-- Id: 16423

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63703

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
	indicator:name("Manual-entry Trading Box")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Data Entry")
	indicator.parameters:addDouble("Level1", "1. Level", "", core.FLAG_PRICE)
	indicator.parameters:addDouble("Level2", "2. Level", "", core.FLAG_PRICE)

	indicator.parameters:addDate("Date1", "1. Date", "", 0)
	indicator.parameters:setFlag("Date1", core.FLAG_DATETIME)

	indicator.parameters:addDate("Date2", "2. Date", "", 0)
	indicator.parameters:setFlag("Date2", core.FLAG_DATETIME)

	indicator.parameters:addGroup("Zone Style")
	indicator.parameters:addBoolean("Extend", "Extend ", "", true)

	indicator.parameters:addString("Type", "Presentation Type", "", "Zone")
	indicator.parameters:addStringAlternative("Type", "Line", "", "Line")
	indicator.parameters:addStringAlternative("Type", "Zone", "", "Zone")

	indicator.parameters:addInteger("transparency", "Transparency", "", 50)
	indicator.parameters:addColor("color", "Zone/Zone Color", "", core.rgb(0, 255, 0))

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
local transparency
local Extend
local Type
local Level1, Level2
local Date1, Date2
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Extend = instance.parameters.Extend
	Type = instance.parameters.Type
	Level1 = instance.parameters.Level1
	Level2 = instance.parameters.Level2
	Date1 = instance.parameters.Date1
	Date2 = instance.parameters.Date2

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)
end

local init = false

function ResolveData(Value)
	local Data = core.findDate(source, Value, false)

	return Data
end

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createSolidBrush(2, instance.parameters.color)
		init = true
	end

	visible, y1 = context:pointOfPrice(Level1)
	visible, y2 = context:pointOfPrice(Level2)

	local Index1 = ResolveData(Date1)
	local Index2 = ResolveData(Date2)

	if Index1 == -1 or Index2 == -1 then
		return
	end
	if Type == "Zone" then
		if Extend then
			context:drawRectangle(1, 2, context:left(), y1, context:right(), y2, transparency)
		else
			x1, x = context:positionOfBar(Index1)
			x2, x = context:positionOfBar(Index2)
			context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)
		end
	else
		if Extend then
			--context:drawRectangle (1, 2, context:left (), y1, context:right (), y2, transparency );
			context:drawLine(1, context:left(), y1, context:right(), y1)
			context:drawLine(1, context:left(), y2, context:right(), y2)
		else
			x1, x = context:positionOfBar(Index1)
			x2, x = context:positionOfBar(Index2)
			--context:drawRectangle (1, 2, x1, y1,x2, y2, transparency );

			context:drawLine(1, x1, y1, x2, y1)
			context:drawLine(1, x1, y2, x2, y2)
		end
	end
end
