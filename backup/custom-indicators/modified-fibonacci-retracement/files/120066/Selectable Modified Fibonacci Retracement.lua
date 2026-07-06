-- Id: 21760
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
	indicator:name("Selectable Modified Fibonacci Retracement")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Indicator_ID", "Indicator D", "", 1)

	--indicator.parameters:addBoolean("Historical", "Show Historical", "", true);

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

local first
local source = nil

-- Streams block

local On = {}
local Level = {}

local db
local pattern = "([^;]*);([^;]*)"
local Indicator_ID

local SD, ED
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	source = instance.source
	first = source:first()

	SD = 0
	ED = 0
	--SL=0;
	--EL=0;

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	for i = 1, 7, 1 do
		Level[i] = instance.parameters:getDouble("Level" .. i)
		On[i] = instance.parameters:getBoolean("On" .. i)
	end

	Indicator_ID = instance.parameters.Indicator_ID

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	instance:ownerDrawn(true)

	require("storagedb")
	db = storagedb.get_db(Indicator_ID .. name)

	core.host:execute("addCommand", 1, "Start Date")
	core.host:execute("addCommand", 2, "End Date")
	core.host:execute("addCommand", 3, "Reset")

	core.host:execute("setTimer", 10, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 10)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if SD == 0 or ED == 0 then
		return
	end

	if not init then
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

	x1, x = context:positionOfDate(SD)
	x2, x = context:positionOfDate(ED)

	for i = 1, 7, 1 do
		if On[i] then
			price = source.open[context:indexOfBar(x1)] ^ Level[i] * source.close[context:indexOfBar(x2)] ^ (1 - Level[i])
			visible, y = context:pointOfPrice(price)
			context:drawLine(i, x1, y, x2, y, 0)
		end
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 or cookie == 2 or cookie == 3 then
		level, date = string.match(message, pattern, 0)

		if cookie == 1 then
			--db:put( "SL", tostring(level));
			db:put("SD", tostring(date))
		elseif cookie == 2 then
			--	db:put( "EL", tostring(level));
			db:put("ED", tostring(date))
		elseif cookie == 3 then
			--db:put( "EL", tostring(0));
			db:put("ED", tostring(0))
			-- db:put( "SL", tostring(0));
			db:put("SD", tostring(0))
		end
	end

	if cookie == 10 then
		SD = tonumber(db:get("SD", 0))
		--SL=tonumber(db:get( "SL", 0));
		ED = tonumber(db:get("ED", 0))
	--	EL=tonumber(db:get( "EL", 0));
	end
end
