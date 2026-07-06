-- Id:  
-- Id:  
-- More information about this indicator can be found at:
--  http://fxcodebase.com/code/viewtopic.php?f=17&t=65683

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Multi Currency SSI Dashboard")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	for i = 1, 18, 1 do
		indicator.parameters:addGroup(i .. ". Currency Pair ")
		Add(i)
	end

	indicator.parameters:addGroup("Style")
	--indicator.parameters:addInteger("Size", "Size", "", 10);

	indicator.parameters:addInteger("Height", "Height (% of chart height)", "", 90)
	indicator.parameters:addInteger("Width", "Width (% of chart Width)", "", 90)

	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128))

	indicator.parameters:addString("dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
    indicator.parameters:addString("dde_topic", "DDE Topic", "value = instrument", "");
end

function Add(id)
	local Init = {
		"GER30",
		"US30",
		"SPX500",
		"UK100",
		"FRA40",
		"EUR/USD",
		"GBP/USD",
		"USD/JPY",
		"USD/CAD",
		"AUD/USD",
		"NZD/USD",
		"EUR/GBP",
		"GBP/JPY",
		"EUR/JPY",
		"AUD/JPY",
		"USD/CHF",
		"XAU/USD",
		"USOIL"
	}

	indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)

	indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size
local first
local source = nil
local Color, Up, Down, Neutral

local Indicator = {}

local loading = {}
local SourceData = {}
local Point = {}
local Pair = {}
local Count

--local Bold2, Bold1;
local id
local Dodaj = {}
--function ReleaseInstance()
--      core.host:execute("deleteFont", Bold1);
--      core.host:execute("deleteFont", Bold2);
--end

-- Routine

local Height, Width
local dde_server, dde_topic;
local dde_alerts = {};

function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Height = instance.parameters.Height
	Width = instance.parameters.Width

	source = instance.source
	first = source:first()
	Size = instance.parameters.Size
	Color = instance.parameters.Color
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral

	assert(core.indicators:findIndicator("SSI") ~= nil, "Please, download and install SSI.BIN indicator")

	require("ddeserver_lua");
	dde_server = ddeserver_lua.new(instance.parameters.dde_service);
	dde_topic = dde_server:addTopic(instance.parameters.dde_topic);
	Count = 0
	for i = 1, 18, 1 do
		Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
		if Dodaj[i] then
			Count = Count + 1
			Pair[Count] = instance.parameters:getString("Pair" .. i)
			Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
			dde_alerts[Pair[Count]] = dde_server:addValue(dde_topic, string.gsub(Pair[Count], "/", ""));
		end
	end

	Id = 0

	for j = 1, Count, 1 do
		Id = Id + 1
		SourceData[j] = core.host:execute("getSyncHistory", Pair[j], "D1", source:isBid(), 1, 2000 + Id, 1000 + Id)
		loading[j] = true

		Indicator[j] = core.indicators:create("SSI", SourceData[j], "SSI")
	end


	instance:setLabelColor(Color)
	instance:ownerDrawn(true)

	core.host:execute("setTimer", 1, 10)
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie)
	local i, j
	local Id = 0
	for j = 1, Count, 1 do
		Id = Id + 1
		if cookie == (1000 + Id) then
			loading[j] = true
		elseif cookie == (2000 + Id) then
			loading[j] = false
		end
	end

	local FLAG = false
	local Number = 0

	for j = 1, Count, 1 do
		if loading[j] then
			FLAG = true
			Number = Number + 1
		end
	end

	if not FLAG and cookie == 1 then
		for j = 1, Count, 1 do
			Indicator[j]:update(core.UpdateLast)
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. ((Count) - Number) .. " / " .. (Count))
		return
	else
		core.host:execute("setStatus", "")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

local initDraw = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	--id=0;

	local FLAG = false
	local Number = 0

	for j = 1, Count, 1 do
		if loading[j] then
			FLAG = true
			Number = Number + 1
		end
	end

	if FLAG then
		return
	end

	local top, bottom = context:top(), context:bottom()
	local left, right = context:left(), context:right()

	xCell = (right - left) / (12)
	yCell = (bottom - top) / 20

	xSize = (xCell / 100) * Width
	ySize = (yCell / 100) * Height

	context:createFont(10, "Arial", (xSize / 7) * 0.9, ySize * 0.9, 0)
	context:createFont(11, "Wingdings", ((xSize / 7) * 0.9) * 1.6, ySize * 0.9, 0)

	-- core.host:execute ("setStatus", " Loaded ");

	top = top + yCell * 2
	local BarColor = Neutral
	local Alert = "\113"

	for j = 1, Count, 1 do
		--core.host:execute("drawLabel1", id, Size  ,  core.CR_LEFT, 5*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  Pair[j]);
		--id = id+1;
		width, height = context:measureText(10, Pair[j], 0)
		context:drawText(10, Pair[j], Color, -1, left, top + (j - 1) * yCell, left + width, top + (j) * yCell, 0)
		--  i=1;

		--DATA
		if
			Indicator[j]:getStream(0):hasData(Indicator[j]:getStream(0):size() - 1) and
				Indicator[j]:getStream(0):hasData(Indicator[j]:getStream(0):size() - 2)
		 then
			dde_server:set(dde_topic, dde_alerts[Pair[j]], tostring(Indicator[j]:getStream(0)[Indicator[j]:getStream(0):size() - 1]));
			if Indicator[j]:getStream(0)[Indicator[j]:getStream(0):size() - 1] > 0 then
				Alert = "\230"
				if Indicator[j]:getStream(0)[Indicator[j]:getStream(0):size() - 2] < 0 then
					Alert = Alert .. "\37"
				end
				BarColor = Down
			elseif Indicator[j]:getStream(0)[Indicator[j]:getStream(0):size() - 1] < 0 then
				Alert = "\228"
				if Indicator[j]:getStream(0)[Indicator[j]:getStream(0):size() - 2] > 0 then
					Alert = Alert .. "\37"
				end
				BarColor = Up
			else
				BarColor = Neutral
				Alert = "\113"
			end

			-- core.host:execute("drawLabel1", id , Size*4 + Size*5*(i) ,  core.CR_LEFT, 5*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  Alert );
			-- id = id+1;

			width, height = context:measureText(11, Alert, 0)
			context:drawText(
				11,
				Alert,
				BarColor,
				-1,
				left + xCell * 2,
				top + (j - 1) * yCell,
				left + xCell * 2 + width,
				top + (j) * yCell,
				0
			)
		end
	end
end
