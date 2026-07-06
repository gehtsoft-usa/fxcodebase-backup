-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70568

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("All Time Frames All Currency Pairs Stochastic Scanner View")
	indicator:description("All Time Frames All Currency Pairs Stochastic Scanner View")
	indicator:requiredSource(core.Bar)
	indicator:type(core.View)

	indicator.parameters:addGroup("Period")
	indicator.parameters:addString("Select", "Tag Data", "", "EUR/USD")
	indicator.parameters:setFlag("Select", core.FLAG_INSTRUMENTS)
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "Multiple currency pair");
	indicator.parameters:addStringAlternative(
		"Type",
		"Multiple currency pair",
		"Multiple currency pair",
		"Multiple currency pair"
	)
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "All currency pair")

	indicator.parameters:addDouble("OB", "Overbought Level", "", 80, 0, 100)
	indicator.parameters:addDouble("OS", "Oversold Level", "", 20, 0, 100)

	indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "MT4","", "FS");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA"); 	

   
	for i = 1, 20, 1 do
		indicator.parameters:addGroup(i .. ". Currency Pair ")
		Add(i)
	end

	indicator.parameters:addGroup("Time Frame Selector")
	AddTimeFrame(1, "m1", false)
	AddTimeFrame(2, "m5", false)
	AddTimeFrame(3, "m15", false)
	AddTimeFrame(4, "m30", false)
	AddTimeFrame(5, "H1", true)
	AddTimeFrame(6, "H2", false)
	AddTimeFrame(7, "H3", false)
	AddTimeFrame(8, "H4", false)
	AddTimeFrame(9, "H6", false)
	AddTimeFrame(10, "H8", false)
	AddTimeFrame(11, "D1", true)
	AddTimeFrame(12, "W1", true)
	AddTimeFrame(13, "M1", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("UUColor", "Up Trend Up Color", "Label Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("UDColor", "Up Trend Down Color", "Label Color", core.rgb(0, 200, 0))
	
	indicator.parameters:addColor("DUColor", "Down Trend Up Color", "Label Color", core.rgb(200, 0, 0))
	indicator.parameters:addColor("DDColor", "Down Trend Down Color", "Label Color", core.rgb(255, 0, 0))
	
	indicator.parameters:addColor("TUUColor", "OB Up Trend  Up Color", "Label Color", core.rgb(0, 50, 255))
	indicator.parameters:addColor("TUDColor", "OB Up Trend Down Color", "Label Color", core.rgb(0, 50, 200))
	
		indicator.parameters:addColor("TDUColor", "OB Down Trend Up Color", "Label Color", core.rgb(50, 0, 255))
	indicator.parameters:addColor("TDDColor", "OB Down Trend Down Color", "Label Color", core.rgb(50, 0, 200))
	
	indicator.parameters:addColor("BUUColor", "OS Up Trend Up Color", "Label Color", core.rgb(128, 255, 128))
	indicator.parameters:addColor("BUDColor", "OS Up Trend Down Color", "Label Color", core.rgb(100, 255, 100))
	
	indicator.parameters:addColor("BDUColor", "OS Down Trend Up Color", "Label Color", core.rgb(255, 128, 128))
	indicator.parameters:addColor("BDDColor", "OS Down Trend Down Color", "Label Color", core.rgb(255, 100, 100))
	
	
	
	indicator.parameters:addColor("NeutralColor", "Neutral Color", "Neutral Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128, 128))
 

	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false)
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 95, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 60, 0, 100)
end

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
end

function getInstrumentList()
	local list = {}
	local point = {}

	local count = 0
	local row, enum

	enum = core.host:findTable("offers"):enumerator()
	row = enum:next()
	while row ~= nil do
		count = count + 1
		list[count] = row.Instrument
		point[count] = row.PointSize
		row = enum:next()
	end

	return list, count, point
end

function Add(id)
	local Init = {
		"EUR/USD",
		"USD/JPY",
		"GBP/USD",
		"USD/CHF",
		"EUR/CHF",
		"AUD/USD",
		"USD/CAD",
		"NZD/USD",
		"EUR/GBP",
		"EUR/JPY",
		"GBP/JPY",
		"CHF/JPY",
		"GBP/CHF",
		"EUR/AUD",
		"EUR/CAD",
		"AUD/CAD",
		"AUD/JPY",
		"CAD/JPY",
		"NZD/JPY",
		"GBP/CAD"
	}

	if id <= 5 then
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)
	else
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", false)
	end
	indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

local Filter
local Show
local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local TF = {}
local Period
local pauto = "(%a%a%a)/(%a%a%a)"
local Color
local Source = {}
local Size
local transparency
local loading = {}
local source
local Pair = {}
local Count
local Type
local Dodaj = {}
local Point = {}
local Use = {}
local Num
local ShowCells
local UpColor, DownColor, NeutralColor
local OB, OS
local Select
local SelectColor
local Price
local Indicator = {}
--local OBColor, OSColor

local K, SD,D, KS, DS;
 
function Prepare(nameOnly)
	local name = profile:id()
	instance:name(name)
	if (nameOnly) then
		return
	end
	instance:initView("Stochastic", 2, 0.01, true, true)

	Size = instance.parameters.Size
	Mode = instance.parameters.Mode
	OB = instance.parameters.OB
	OS = instance.parameters.OS
	Select = instance.parameters.Select
	SelectColor = instance.parameters.SelectColor
	Type = instance.parameters.Type
	ShowCells = instance.parameters.ShowCells
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor
	NeutralColor = instance.parameters.NeutralColor
	Price = instance.parameters.Price
	--OBColor = instance.parameters.OBColor
	--OSColor = instance.parameters.OSColor
	 
	source = instance.source
	
	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	KS= instance.parameters.KS;
	DS= instance.parameters.DS;

	if Type == "Multiple currency pair" then
		Count = 0
		for i = 1, 20, 1 do
			Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
			if Dodaj[i] then
				Count = Count + 1
				Pair[Count] = instance.parameters:getString("Pair" .. i)
				Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
			end
		end
	elseif Type == "All currency pair" then
		Pair, Count, Point = getInstrumentList()
	
	end

	Num = 0
	for i = 1, 13, 1 do
		Use[i] = instance.parameters:getBoolean("Use" .. i)

		if Use[i] then
			Num = Num + 1

			TF[Num] = iTF[i]
		end
	end

	local ID = 0
	Color = instance.parameters.Color

	for i = 1, Count, 1 do
		Source[i] = {}
		loading[i] = {}
		Indicator[i] = {}

		for j = 1, Num, 1 do
			ID = ID + 1

			Source[i][j] = core.host:execute("getHistory1", 20000 + ID, Pair[i], TF[j], 500, 0, true)
			loading[i][j] = true

			Indicator[i][j] = core.indicators:create("STOCHASTIC", Source[i][j] , K, SD,D, KS, DS)
		end
	end
	open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, "m1");

	instance:ownerDrawn(true)
	core.host:execute("setTimer", 1, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

local added = false;
function AsyncOperationFinished(cookie)
	if not added then
		instance:addViewBar(core.host:execute("getServerTime"));
		core.host:trace("test");
		added = true;
	end
	local i
	local ID = 0
	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			ID = ID + 1
			if cookie == (20000 + ID) then
				loading[i][j] = false
			end
		end
	end

	local FLAG = false
	local Number = 0
	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				FLAG = true
				Number = Number + 1
			end
		end
	end

	if not FLAG and cookie == 1 then
		for i = 1, Count, 1 do
			for j = 1, Num, 1 do
				Indicator[i][j]:update(core.UpdateLast)
			end
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (Count * 13 - Number) .. " / " .. Count * 13)
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false
local iwidth, iheight;
function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Loading = false

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				Loading = true
			end
		end
	end

	if Loading then
		return
	end
	
	top, bottom = context:top(), context:bottom()
	left, right = context:left(), context:right()

	xGap = (right - left) / (Count + 1)
	yGap = (bottom - top) / (Num + 2)
	

	if not init then
		context:createPen(1, context.SOLID, 1, Color)
		context:createSolidBrush(2, Color)
		context:createSolidBrush(3, SelectColor)

		transparency = context:convertTransparency(instance.parameters.transparency)

		init = true
	end
	
	iwidth = ((xGap / 7) / 100) * Size
	iheight = (yGap / 100) * Size

	context:createFont(7, "Arial", iwidth, iheight, context.ITALIC)
	

	

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			Calculate(context, i, j)
		end
	end
end

function Calculate(context, i, j)
	if not Indicator[i][j].D:hasData(Indicator[i][j].D:size() - 1) or not Indicator[i][j].D:hasData(Indicator[i][j].D:size() - 2) then
		return
	end

	local Symbol = string.format("%." .. 2 .. "f", Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1])
	local color1 = Neutral
	local color2 = -1

	if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].D[Indicator[i][j].D:size() - 2]  and Indicator[i][j].K[Indicator[i][j].K:size() - 1] < OB and   Indicator[i][j].K[Indicator[i][j].K:size() - 1] > OS  then
	
	    if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.UUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] < Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.UDColor;
		end
	elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1]< Indicator[i][j].D[Indicator[i][j].D:size() - 2]  and Indicator[i][j].K[Indicator[i][j].K:size() - 1] < OB and  Indicator[i][j].K[Indicator[i][j].K:size() - 1] > OS  then
	
	    if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.DUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] <Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.DDColor;
		end	
		
	elseif  Indicator[i][j].K[Indicator[i][j].K:size() - 1] > OB   and Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].D[Indicator[i][j].D:size() - 2]then
	
	      if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.TUUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] <Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.TUDColor;
		end	
		
	elseif  Indicator[i][j].K[Indicator[i][j].K:size() - 1] > OB   and Indicator[i][j].K[Indicator[i][j].K:size() - 1] < Indicator[i][j].D[Indicator[i][j].D:size() - 2]then
	
	      if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.TDUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] <Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.TDDColor;
		end	
		
		
	elseif  Indicator[i][j].K[Indicator[i][j].K:size() - 1] < OS  and Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].D[Indicator[i][j].D:size() - 2]then
	
	        if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.BUUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] <Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.BUDColor;
		end	
	elseif  Indicator[i][j].K[Indicator[i][j].K:size() - 1] < OS and Indicator[i][j].K[Indicator[i][j].K:size() - 1] < Indicator[i][j].D[Indicator[i][j].D:size() - 2]then
		  if Indicator[i][j].K[Indicator[i][j].K:size() - 1] > Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 = instance.parameters.BDUColor;
		elseif Indicator[i][j].K[Indicator[i][j].K:size() - 1] <Indicator[i][j].K[Indicator[i][j].K:size() - 2]  then
		color1 =  instance.parameters.BDDColor;
		end	
	else
		color1 = NeutralColor
	end

--OB  OS 
	y1 = bottom - j * yGap - yGap
	y2 = bottom - (j - 1) * yGap - yGap

	x1 = left + (i - 1) * xGap
	x2 = left + i * xGap

	

	if j == 1 then
		width, height = context:measureText(7, Pair[i], 0)
		context:drawText(7, Pair[i], Color, -1, x1, y2, x2, context:right(), 0)
	end

	if i == Count then
		width, height = context:measureText(7, TF[j], 0)
		context:drawText(7, TF[j], Color, -1, x2, y1, context:right(), y2, 0)
	end

	if ShowCells then
		context:drawRectangle(1, -1, x1, y1, x2, y2, transparency)
	end

	if Select == Pair[i] then
		context:drawRectangle(-1, 3, x1, y1, x2, y2, transparency)
	end

	width, height = context:measureText(7, Symbol, 0)
	context:drawText(7, Symbol, color1, color2, x1 + (x2 - x1) / 2 - width / 2, y1, x1 + (x2 - x1) / 2 + width / 2, y2, 0)
end
