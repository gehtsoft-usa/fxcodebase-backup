-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69826

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("Generic Index Delta")
	indicator:description("Generic Index")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator:setTag("group", "Currency Indexes")

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("color", "color", "color", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)

	indicator.parameters:addGroup("Levels")
	indicator.parameters:addDouble("Level1", "1. Level", "", 5)
	indicator.parameters:addDouble("Level2", "2. Level", "", -5)

	indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source = nil

local Indicator_Name = {}

local Line, Indicator1, Indicator2

local pauto = "(%a%a%a)/(%a%a%a)"

local last_first1, last_first2 = nil, nil
local MyFirst=false;
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	local name = profile:id() .. "()"
	instance:name(name)
	if nameOnly then
		return
	end

	last_first1, last_first2 = nil, nil

	Line = instance:addStream("Line", core.Line, "Line", "Line", instance.parameters.color, first)
	Line:setWidth(instance.parameters.width)
	Line:setStyle(instance.parameters.style)
	Line:setPrecision(math.max(5, instance.source:getPrecision()))

	Line:addLevel(
		instance.parameters.Level1,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color
	)
	Line:addLevel(
		instance.parameters.Level2,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color
	)
	Line:addLevel(
		0,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color
	)

	Indicator_Name["USD"] = "GENERIC DOLLAR INDEX"
	Indicator_Name["EUR"] = "GENERIC EURO INDEX"
	Indicator_Name["JPY"] = "GENERIC JEN INDEX"
	Indicator_Name["NZD"] = "GENERIC KIWI INDEX"
	Indicator_Name["AUD"] = "GENERIC AUSSIE INDEX"
	Indicator_Name["CAD"] = "GENERIC LOONIE INDEX"
	Indicator_Name["CHF"] = "GENERIC FRANC INDEX"
	Indicator_Name["GBP"] = "GENERIC POUND INDEX"

	crncy1, crncy2 = string.match(source:instrument(), pauto)

	core.host:execute("setStatus", tostring(crncy2))

	if Indicator_Name[crncy1] ~= nil then
		assert(
			core.indicators:findIndicator(Indicator_Name[crncy1]) ~= nil,
			"Please, download and install" .. Indicator_Name[crncy1] .. ".LUA indicator"
		)
		Indicator1 = core.indicators:create(Indicator_Name[crncy1], source)
	end

	if Indicator_Name[crncy2] ~= nil then
		assert(
			core.indicators:findIndicator(Indicator_Name[crncy2]) ~= nil,
			"Please, download and install" .. Indicator_Name[crncy2] .. ".LUA indicator"
		)
		Indicator2 = core.indicators:create(Indicator_Name[crncy2], source)
	end

	core.host:execute("setTimer", 100, 1)
	MyFirst=false
end

-- Indicator calculation routine

function Update(period)
	if Indicator1 ~= nil then
		Indicator1:update(mode)
	end
	if Indicator2 ~= nil then
		Indicator2:update(mode)
	end

	if period < first then
		return
	end

	Line[period] = 0

	if Indicator1 ~= nil and Indicator1.DATA:hasData(period) then
		Line[period] = Line[period] + Indicator1.DATA[period]
	else
		Line[period] = 100
	end

	if Indicator2 ~= nil and Indicator2.DATA:hasData(period) then
		Line[period] = Line[period] - Indicator2.DATA[period]
	else
		Line[period] = Line[period] - 100
	end
	
	
	
	
	
	if period <= first then
		return
	end
	
	Line[period-1] = 0
	
	if Indicator1 ~= nil and Indicator1.DATA:hasData(period-1) then
		Line[period-1] = Line[period-1] + Indicator1.DATA[period-1]
	else
		Line[period-1] = 100
	end

	if Indicator2 ~= nil and Indicator2.DATA:hasData(period-1) then
		Line[period-1] = Line[period-1] - Indicator2.DATA[period-1]
	else
		Line[period-1] = Line[period-1] - 100
	end
end

function GetFirstSerial1()
	if Indicator1 == nil then
		return nil
	end
	for i = 0, Indicator1.DATA:size() - 1 do
		if Indicator1.DATA:hasData(i) and Indicator1.DATA[i] ~= 0 then
			return Indicator1.DATA:serial(Indicator1.DATA:size() - 1)
		end
	end
	return nil
end

function GetFirstSerial2()
	if Indicator2 == nil then
		return nil
	end

	for i = 0, Indicator2.DATA:size() - 1 do
		if Indicator2.DATA:hasData(i) and Indicator2.DATA[i] ~= 0 then
			return Indicator2.DATA:serial(Indicator2.DATA:size() - 1)
		end
	end

	return nil
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 100 then
		local first1 = GetFirstSerial1()
		local first2 = GetFirstSerial2()

		if first1 == nil or first2 == nil or source:first() < first then
			instance:updateFrom(0)
			return
		end

		if last_first1 ~= first1 then
			instance:updateFrom(0)
			last_first1 = first1
			return;
		end

		if last_first2 ~= first2 then
			instance:updateFrom(0)
			last_first2 = first2
			return;
		end
		instance:updateFrom(source:size() - 1);
	end
end
