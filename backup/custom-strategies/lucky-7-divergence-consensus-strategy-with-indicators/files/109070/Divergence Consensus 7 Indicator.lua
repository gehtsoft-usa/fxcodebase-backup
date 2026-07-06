-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64096
-- Id: 17052
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
local _gUpdatePeriods = {}
function Init()
	indicator:name("Divergence Consensus 7 Indicator")
	indicator:description("Divergence Consensus 7 Indicator")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Choose Indicators for Divergence")

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "Use MACD Filter", "", true)
	indicator.parameters:addBoolean("Two", "Use CCI Filter", "", true)
	indicator.parameters:addBoolean("Three", "Use ROC Filter", "", true)
	indicator.parameters:addBoolean("Four", "Use TSI Filter", "", true)
	indicator.parameters:addBoolean("Five", "Use RSI Filter", "", true)
	indicator.parameters:addBoolean("Six", "Use MFI Filter", "", true)
	indicator.parameters:addBoolean("Seven", "Use STOCHASTIC Filter", "", true)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("MACD_N", "Period of short EMA for MACD", "", 12)
	indicator.parameters:addInteger("MACD_N2", "Period of long EMA for MACD", "", 26)
	indicator.parameters:addInteger("MACD_N3", "Signal period of MACD", "", 9)
	indicator.parameters:addDouble("MACD_OB", "MACD Overbought Level", "", 0.0002, -0.1, 0.1)
	indicator.parameters:addDouble("MACD_OS", "MACD Oversold Level", "", -0.0002, -0.1, 0.1)

	indicator.parameters:addGroup("CCI Calculation")
	indicator.parameters:addInteger("CCI_N", "Number of periods", "The number of periods.", 14, 2, 1000)
	indicator.parameters:addDouble("CCI_OB", "CCI Overbought (usually 100)", "", 100, 0, 500)
	indicator.parameters:addDouble("CCI_OS", "CCI Oversold (usually -100)", "", -100, -500, 0)

	indicator.parameters:addGroup("ROC Calculation")
	indicator.parameters:addInteger("ROC_N", "Periods for ROC Indicator ", "", 7)
	indicator.parameters:addDouble("ROC_OB", "ROC Overbought Level", "", 0.10, -5.00, 5.00)
	indicator.parameters:addDouble("ROC_OS", "ROC Oversold Level", "", -0.10, -5.00, 5.00)

	indicator.parameters:addGroup("TSI Calculation")
	indicator.parameters:addInteger("TSI_N", "Periods for TSI Indicator 1", "", 7)
	indicator.parameters:addInteger("TSI_N2", "Periods for TSI Indicator 2", "", 14)
	indicator.parameters:addDouble("TSI_OB", "TSI Overbought Level", "", 30, -100, 100)
	indicator.parameters:addDouble("TSI_OS", "TSI Oversold Level", "", -30, -100, 100)

	indicator.parameters:addGroup("RSI Calculation")
	indicator.parameters:addInteger("RSI_N", "Periods for RSI Indicator ", "", 7)
	indicator.parameters:addDouble("RSI_OB", "RSI Overbought Level", "", 70)
	indicator.parameters:addDouble("RSI_OS", "RSI Oversold Level", "", 30)

	indicator.parameters:addGroup("MFI Calculation")
	indicator.parameters:addInteger("MFI_N", "MFI Periods", "", 7)
	indicator.parameters:addDouble("MFI_OB", "MFI Overbought Level", "", 70)
	indicator.parameters:addDouble("MFI_OS", "MFI Oversold Level", "", 30)

	indicator.parameters:addGroup("Stochastic Calculation")
	indicator.parameters:addInteger("STOCH_N", "periods for %K", "", 5, 2, 1000)
	indicator.parameters:addInteger("STOCH_N2", "D smoothing periods", "", 3, 2, 1000)
	indicator.parameters:addInteger("STOCH_N3", "periods for %D", "", 3, 2, 1000)
	indicator.parameters:addDouble("STOCH_OB", "Stochastic Overbought Level", "", 70.0, 20, 100)
	indicator.parameters:addDouble("STOCH_OS", "Stochastic Oversold Level", "", 30.0, 1, 80)

	indicator.parameters:addGroup("Common")
	indicator.parameters:addBoolean("showHidden", "Show Hidden (continuation) divergence?", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40, 0, 100)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local open
local close
local showHidden

local first
local source = nil

-- Streams block

local Parameters = {}
local Indicator = {}
local One, Two, Three, Four, Five, Six, Seven

-- Routine

function Prepare(name)
	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if nameOnly then
		return
	end

	Transparency = (100 - instance.parameters.Transparency)
	One = instance.parameters.One
	Two = instance.parameters.Two
	Three = instance.parameters.Three
	Four = instance.parameters.Four
	Five = instance.parameters.Five
	Six = instance.parameters.Six
	Seven = instance.parameters.Seven

	showHidden = instance.parameters.showHidden
	first = source:first()

	Parameters["MACD_N"] = instance.parameters.MACD_N
	Parameters["MACD_N2"] = instance.parameters.MACD_N2
	Parameters["MACD_N3"] = instance.parameters.MACD_N3
	Parameters["MACD_OB"] = instance.parameters.MACD_OB
	Parameters["MACD_OS"] = instance.parameters.MACD_OS

	Parameters["CCI_N"] = instance.parameters.CCI_N
	Parameters["CCI_OB"] = instance.parameters.CCI_OB
	Parameters["CCI_OS"] = instance.parameters.CCI_OS

	Parameters["ROC_N"] = instance.parameters.ROC_N
	Parameters["ROC_OB"] = instance.parameters.ROC_OB
	Parameters["ROC_OS"] = instance.parameters.ROC_OS

	Parameters["TSI_N"] = instance.parameters.TSI_N
	Parameters["TSI_N2"] = instance.parameters.TSI_N2
	Parameters["TSI_OB"] = instance.parameters.TSI_OB
	Parameters["TSI_OS"] = instance.parameters.TSI_OS

	Parameters["RSI_N"] = instance.parameters.RSI_N
	Parameters["RSI_OB"] = instance.parameters.RSI_OB
	Parameters["RSI_OS"] = instance.parameters.RSI_OS

	Parameters["MFI_N"] = instance.parameters.MFI_N
	Parameters["MFI_OB"] = instance.parameters.MFI_OB
	Parameters["MFI_OS"] = instance.parameters.MFI_OS

	Parameters["STOCH_N"] = instance.parameters.STOCH_N
	Parameters["STOCH_N2"] = instance.parameters.STOCH_N2
	Parameters["STOCH_N3"] = instance.parameters.STOCH_N3
	Parameters["STOCH_OB"] = instance.parameters.STOCH_OB
	Parameters["STOCH_OS"] = instance.parameters.STOCH_OS

	assert(
		core.indicators:findIndicator("SUPER DIVERGENCE INDICATOR V3") ~= nil,
		"Please, download and install SUPER DIVERGENCE INDICATOR V3.LUA indicator"
	)

	if One then
		Indicator["MACD"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"MACD",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["MACD"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["MACD"].DATA:first())
	end

	if Two then
		Indicator["CCI"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"CCI",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["CCI"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["CCI"].DATA:first())
	end

	if Three then
		Indicator["ROC"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"ROC",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["ROC"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["ROC"].DATA:first())
	end

	if Four then
		Indicator["TSI"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"TSI",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["TSI"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["TSI"].DATA:first())
	end

	if Five then
		Indicator["RSI"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"RSI",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["RSI"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["RSI"].DATA:first())
	end

	if Six then
		Indicator["MFI"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"MFI",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["MFI"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["MFI"].DATA:first())
	end

	if Seven then
		Indicator["STOCH"] =
			core.indicators:create(
			"SUPER DIVERGENCE INDICATOR V3",
			source,
			"STOCHASTIC",
			Parameters["MACD_N"],
			Parameters["MACD_N2"],
			Parameters["MACD_N3"],
			Parameters["MACD_OB"],
			Parameters["MACD_OS"],
			Parameters["CCI_N"],
			Parameters["CCI_OB"],
			Parameters["CCI_OS"],
			Parameters["ROC_N"],
			Parameters["ROC_OB"],
			Parameters["ROC_OS"],
			Parameters["TSI_N"],
			Parameters["TSI_N2"],
			Parameters["TSI_OB"],
			Parameters["TSI_OS"],
			Parameters["RSI_N"],
			Parameters["RSI_OB"],
			Parameters["RSI_OS"],
			Parameters["MFI_N"],
			Parameters["MFI_OB"],
			Parameters["MFI_OS"],
			Parameters["STOCH_N"],
			Parameters["STOCH_N2"],
			Parameters["STOCH_N3"],
			Parameters["STOCH_OB"],
			Parameters["STOCH_OS"],
			false,
			showHidden
		)
		_gUpdatePeriods[Indicator["STOCH"].DATA] = _gUpdatePeriods[source]
		first = math.max(first, Indicator["STOCH"].DATA:first())
	end

	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first)
	open:setPrecision(math.max(2, instance.source:getPrecision()))
	close:setPrecision(math.max(2, instance.source:getPrecision()))
	instance:createChannelGroup("UpGroup", "Up", open, close, instance.parameters.Up, Transparency)
end

-- Indicator calculation routine

function Update(period, mode)
	open[period] = 0
	close[period] = 0

	open:setColor(period, instance.parameters.No)

	local ONE_B = nil
	local ONE_S = nil
	local TWO_B = nil
	local TWO_S = nil
	local THREE_B = nil
	local THREE_S = nil
	local FOUR_B = nil
	local FOUR_S = nil
	local FIVE_B = nil
	local FIVE_S = nil
	local SIX_B = nil
	local SIX_S = nil
	local SEVEN_B = nil
	local SEVEN_S = nil

	if One then
		Indicator["MACD"]:update(mode)
		if Indicator["MACD"].DN:hasData(period) then
			ONE_B = true
		else
			ONE_B = false
		end

		if Indicator["MACD"].UP:hasData(period) then
			ONE_S = true
		else
			ONE_S = false
		end
	end

	if Two then
		Indicator["CCI"]:update(mode)
		if Indicator["CCI"].DN:hasData(period) then
			TWO_B = true
		else
			TWO_B = false
		end

		if Indicator["CCI"].UP:hasData(period) then
			TWO_S = true
		else
			TWO_S = false
		end
	end

	if Three then
		Indicator["ROC"]:update(mode)

		if Indicator["ROC"].DN:hasData(period) then
			THREE_B = true
		else
			THREE_B = false
		end

		if Indicator["ROC"].UP:hasData(period) then
			THREE_S = true
		else
			THREE_S = false
		end
	end

	if Four then
		Indicator["TSI"]:update(mode)

		if Indicator["TSI"].DN:hasData(period) then
			FOUR_B = true
		else
			FOUR_B = false
		end

		if Indicator["TSI"].UP:hasData(period) then
			FOUR_S = true
		else
			FOUR_S = false
		end
	end

	if Five then
		Indicator["RSI"]:update(mode)

		if Indicator["RSI"].DN:hasData(period) then
			FIVE_B = true
		else
			FIVE_B = false
		end

		if Indicator["RSI"].UP:hasData(period) then
			FIVE_S = true
		else
			FIVE_S = false
		end
	end

	if Six then
		Indicator["MFI"]:update(mode)

		if Indicator["MFI"].DN:hasData(period) then
			SIX_B = true
		else
			SIX_B = false
		end

		if Indicator["MFI"].UP:hasData(period) then
			SIX_S = true
		else
			SIX_S = false
		end
	end

	if Seven then
		Indicator["STOCH"]:update(mode)

		if Indicator["STOCH"].DN:hasData(period) then
			SEVEN_B = true
		else
			SEVEN_B = false
		end

		if Indicator["STOCH"].UP:hasData(period) then
			SEVEN_S = true
		else
			SEVEN_S = false
		end
	end

	if period < first + 1 then
		return
	end

	if
		ONE_B == nil and ONE_S == nil and TWO_B == nil and TWO_S == nil and THREE_B == nil and THREE_S == nil and
			FOUR_B == nil and
			FOUR_S == nil and
			FIVE_B == nil and
			FIVE_S == nil and
			SIX_B == nil and
			SIX_S == nil and
			SEVEN_B == nil and
			SEVEN_S == nil
	 then
		open:setColor(period, instance.parameters.No)
	elseif
		(ONE_B == true or ONE_B == nil) and (TWO_B == true or TWO_B == nil) and (THREE_B == true or THREE_B == nil) and
			(FOUR_B == true or FOUR_B == nil) and
			(FIVE_B == true or FIVE_B == nil) and
			(SIX_B == true or SIX_B == nil) and
			(SEVEN_B == true or SEVEN_B == nil)
	 then
		open:setColor(period, instance.parameters.Up)
		open[period] = 1
	elseif
		(ONE_S == true or ONE_S == nil) and (TWO_S == true or TWO_S == nil) and (THREE_S == true or THREE_S == nil) and
			(FOUR_S == true or FOUR_S == nil) and
			(FIVE_S == true or FIVE_S == nil) and
			(SIX_S == true or SIX_S == nil) and
			(SEVEN_S == true or SEVEN_S == nil)
	 then
		open:setColor(period, instance.parameters.Dn)
		open[period] = -1
	else
		open:setColor(period, instance.parameters.No)
		open[period] = 0
	end
end
