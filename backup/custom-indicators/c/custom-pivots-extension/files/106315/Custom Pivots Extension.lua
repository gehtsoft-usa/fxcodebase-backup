-- Id: 16063

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63492

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

function Init()
	indicator:name("Custom Pivots Extension")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("TF", "Time Frame", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

	indicator.parameters:addString("Mode", "Mode", "", "Historic")
	indicator.parameters:addStringAlternative("Mode", "Historic", "", "Historic")
	indicator.parameters:addStringAlternative("Mode", "Present", "", "Present")

	indicator.parameters:addGroup("Extension Levels")
	indicator.parameters:addDouble("Level1", "1. Level", "", 25)
	indicator.parameters:addDouble("Level2", "2. Level", "", 50)
	indicator.parameters:addDouble("Level3", "3. Level", "", 75)
	indicator.parameters:addDouble("Level4", "4. Level", "", 100)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.COLOR_LABEL)
	indicator.parameters:addInteger("LabelSize", "Label Size", "", 25)
	for i = 1, 14, 1 do
		AddStyle(i)
	end
end

function AddStyle(id)
	local Label = {"High", "Low", "Close", "PP", "BP", "TP", "R1", "R2", "R3", "R4", "S1", "S2", "S3", "S4"}
	indicator.parameters:addGroup(Label[id] .. " Line Style")
	if id == 1 then
		Color = core.rgb(0, 255, 0)
	elseif id == 2 then
		Color = core.rgb(255, 0, 0)
	else
		Color = core.rgb(128, 128, 128)
	end
	indicator.parameters:addColor("color" .. id, "Line Color", "", Color)
	indicator.parameters:addInteger("width" .. id, "Line Width", "", 1, 1, 5)
	indicator.parameters:addInteger("style" .. id, "Line Stylw", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style" .. id, core.FLAG_LEVEL_STYLE)
end

local source
local Mode
local TF
local dayoffset
local weekoffset
local name
local Source, loading
local Level1, Level2, Level3, Level4
local stream = {}
local Label = {"High", "Low", "Close", "PP", "BP", "TP", "R1", "R2", "R3", "R4", "S1", "S2", "S3", "S4"}
local color = {}
local width = {}
local style = {}
local Value = {}
local LabelColor, LabelSize
local InNot = false

function Prepare(nameOnly)
	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	source = instance.source
	instr = source:instrument()
	TF = instance.parameters.TF
	Mode = instance.parameters.Mode
	LabelSize = instance.parameters.LabelSize
	LabelColor = instance.parameters.LabelColor

	for i = 1, 14, 1 do
		color[i] = instance.parameters:getColor("color" .. i)
		width[i] = instance.parameters:getInteger("width" .. i)
		style[i] = instance.parameters:getInteger("style" .. i)
	end

	Level1 = instance.parameters.Level1 / 100
	Level2 = instance.parameters.Level2 / 100
	Level3 = instance.parameters.Level3 / 100
	Level4 = instance.parameters.Level4 / 100

	name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 300, 100, 101)
	loading = true
	-- show stream for historical mode
	if Mode == "Historic" then
		for i = 1, 14, 1 do
			stream[i] = instance:addStream(Label[i], core.Line, Label[i], Label[i], color[i], 0)
			stream[i]:setWidth(width[i])
			stream[i]:setStyle(style[i])
		end
	end

	local s2, e2, s1, e1
	s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0)
	s2, e2 = core.getcandle(TF, core.now(), 0, 0)

	if (e1 - s1) >= (e2 - s2) then
		instance:ownerDrawn(false)
		InNot = true
	else
		instance:ownerDrawn(true)
	end
end

function Update(period)
	if InNot then
		return
	end

	local p1 = Initialization(period)

	if not p1 or p1 <= 1 then
		return
	end

	Value[1] = Source.high[p1 - 1]
	Value[2] = Source.low[p1 - 1]
	Value[3] = Source.close[p1 - 1]

	Value[4] = (Value[1] + Value[2] + Value[3]) / 3
	Value[5] = (Value[1] + Value[2]) / 2
	Value[6] = Value[4] + (Value[4] - Value[5])

	local Range = Value[1] - Value[2]

	Value[7] = Value[1] + Range * Level1
	Value[8] = Value[1] + Range * Level2
	Value[9] = Value[1] + Range * Level3
	Value[10] = Value[1] + Range * Level4

	Value[11] = Value[2] - Range * Level1
	Value[12] = Value[2] - Range * Level2
	Value[13] = Value[2] - Range * Level3
	Value[14] = Value[2] - Range * Level4

	if Mode ~= "Historic" then
		return
	end

	local p2 = Initialization(period - 1)

	if p1 ~= p2 then
		for i = 1, 14, 1 do
			stream[i]:setBreak(period, true)
		end
	end

	stream[1][period] = Value[1]
	stream[2][period] = Value[2]
	stream[3][period] = Value[3]

	stream[4][period] = Value[4]
	stream[5][period] = Value[5]
	stream[6][period] = Value[6]

	stream[7][period] = Value[7]
	stream[8][period] = Value[8]
	stream[9][period] = Value[9]
	stream[10][period] = Value[10]

	stream[11][period] = Value[11]
	stream[12][period] = Value[12]
	stream[13][period] = Value[13]
	stream[14][period] = Value[14]
end

function Initialization(period)
	local Candle
	Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)

	if loading or Source:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local p = core.findDate(Source, Candle, false)

	-- candle is not found
	if p < 0 then
		return false
	else
		return p
	end
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

local init = false
function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Arila", LabelSize, LabelSize, 0)
		for i = 1, 14, 1 do
			context:createPen(1 + i, context:convertPenStyle(style[i]), context:pointsToPixels(width[i]), color[i])
		end
		init = true
	end

	x, _, X = context:positionOfBar(source:size() - 1)
	S, E = core.getcandle(TF, source:date(source:size() - 1), dayoffset, weekoffset)

	Index1 = core.findDate(source, S, false)

	if Index1 == -1 then
		return
	end

	for i = 1, 14, 1 do
		if Value[i] ~= nil then
			visible, y = context:pointOfPrice(Value[i])

			TextWidth, TextHeight = context:measureText(1, Label[i], 0)
			context:drawText(1, Label[i], LabelColor, -1, X, y - TextHeight, X + TextWidth, y, 0)

			if Mode ~= "Historic" then
				context:drawLine(1 + i, Index1, y, X, y)
			end
		end
	end
end
