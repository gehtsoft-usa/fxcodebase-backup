-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59367
-- Id: 12728
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Advanced Support/Resistance")
	indicator:description("Advanced Support/Resistance")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)



	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Qualified", "Min Number to Qualify", "Min Number to Qualify", 1)
	indicator.parameters:addInteger("Tolerance", "Tolerance", "Tolerance", 0)
	indicator.parameters:addInteger("MinLength", "Min Length", "Min Length", 10)
	indicator.parameters:addInteger("MaxLength", "Max Length", "Max Length", 100)
	indicator.parameters:addInteger("Zone", "Zone width (in Pips)", "Zone width (in Pips)", 10)
	indicator.parameters:addInteger("Fractal", "Fractal", "", 2, 1, 100)
	indicator.parameters:addString("Find", "Search for ", "Search for ", "Both")
	indicator.parameters:addStringAlternative("Find", "Support", "", "Support")
	indicator.parameters:addStringAlternative("Find", "Resistance", "", "Resistance")
	indicator.parameters:addStringAlternative("Find", "Both", "", "Both")

	indicator.parameters:addString("Break", "Break On ", "Body ", "Body")
	indicator.parameters:addStringAlternative("Break", "Body", "", "Body")
	indicator.parameters:addStringAlternative("Break", "Wick", "", "Wick")

	indicator.parameters:addString("Method", "Draw Method", "Method", "Chart")
	indicator.parameters:addStringAlternative("Method", "Number Of Zones", "", "Number")
	indicator.parameters:addStringAlternative("Method", "Show On Chart Zones ", "EMA", "Chart")
	indicator.parameters:addStringAlternative("Method", "Show All Zones", "Show All", "All")
	indicator.parameters:addInteger("Number", "Number of shown Support/Resistance Zones", "", 5)
	
	indicator.parameters:addGroup("Filter")
		indicator.parameters:addBoolean("Filter", "Use Filter", "", false)
		
	indicator.parameters:addString("R", "Resistance Method", "Method", "Both")
	indicator.parameters:addStringAlternative("R", "Both", "", "Both")
	indicator.parameters:addStringAlternative("R", "Up Candle", "Up", "Up")
    indicator.parameters:addStringAlternative("R", "Down Candle", "Down", "Down")	
		
	indicator.parameters:addString("S", "Support Method", "Method", "Both")
	indicator.parameters:addStringAlternative("S", "Both", "", "Both")
	indicator.parameters:addStringAlternative("S", "Up Candle", "Up", "Up")
    indicator.parameters:addStringAlternative("S", "Down Candle", "Down", "Down")

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("Resistance", "Resistance Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Support", "Support Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)

	indicator.parameters:addBoolean("Extend", " Line Extend", "", false)

	indicator.parameters:addGroup("Alerts")
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false)
	indicator.parameters:addFile("CrossOver", "Cross Over Sound File", "", "")
	indicator.parameters:setFlag("CrossOver", core.FLAG_SOUND)
	indicator.parameters:addFile("CrossUnder", "Cross Under Sound File", "", "")
	indicator.parameters:setFlag("CrossUnder", core.FLAG_SOUND)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
	indicator.parameters:addBoolean("strategy_mode", "Strategy mode", "", false);
end

local PlaySound, RecurrentSound
local ShowAlert
local Qualified
local Zone
local Find
local Resistance, Support
local first
local source = nil

local Method, Number
local SIZE, size
local Extend
local id = 0
local FRACTAL
local MinLength
local MaxLength
local Tolerance
local Break
local Up, Down
local init = false
local transparency
local Color
local Top = {}
local Bottom = {}
local Flag = {}
--local Index;
local CrossOver, CrossUnder
local LastSerial
local Show, UpS, DownS
local Filter;

local S, R;
-- Routine
function Prepare(nameOnly)
	Break = instance.parameters.Break
	Show = instance.parameters.Show
	Color = instance.parameters.Color
	Method = instance.parameters.Method
	Number = instance.parameters.Number
	Support = instance.parameters.Support
	Resistance = instance.parameters.Resistance
	Tolerance = instance.parameters.Tolerance
	MinLength = instance.parameters.MinLength
	MaxLength = instance.parameters.MaxLength
	FRACTAL = instance.parameters.Fractal
	Extend = instance.parameters.Extend
	
	Filter = instance.parameters.Filter;
	S = instance.parameters.S;
	R = instance.parameters.R;

	Qualified = instance.parameters.Qualified
	Zone = instance.parameters.Zone
	Find = instance.parameters.Find

	ShowAlert = instance.parameters.ShowAlert
	PlaySound = instance.parameters.PlaySound
	if PlaySound then
		CrossOver = instance.parameters.CrossOver
		CrossUnder = instance.parameters.CrossUnder
	else
		CrossOver = nil
		CrossUnder = nil
	end
	assert(not (PlaySound) or (PlaySound and CrossUnder ~= ""), "Sound file must be chosen")
	assert(not (PlaySound) or (PlaySound and CrossOver ~= ""), "Sound file must be chosen")
	RecurrentSound = instance.parameters.RecurrentSound

	source = instance.source
	first = source:first()

	SIZE = Zone * source:pipSize()

	local s, e
	s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
	size = e - s

	local name =
		profile:id() ..
		"(" ..
			source:name() ..
				", " ..
					tostring(Qualified) ..
						", " ..
							tostring(Tolerance) ..
								", " ..
									tostring(MinLength) ..
										", " ..
											tostring(MaxLength) ..
												", " ..
													tostring(Zone) ..
														", " ..
															tostring(FRACTAL) ..
																", " ..
																	tostring(Find) ..
																		", " .. tostring(Break) .. ", " .. tostring(Method) .. ", " .. tostring(Number) .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	if instance.parameters.strategy_mode then
		UpS = instance:addStream("Up", core.Line, "Up", "Up", core.rgb(0, 0, 0), 0, 0);
		DownS = instance:addStream("Down", core.Line, "Down", "Down", core.rgb(0, 0, 0), 0, 0);
		Up = instance:addInternalStream(0, 0)
		Down = instance:addInternalStream(0, 0)
	else
		Up = instance:addInternalStream(0, 0)
		Down = instance:addInternalStream(0, 0)
	end

	instance:ownerDrawn(true)
end

function SendAlert(message)
	if not ShowAlert then
		return
	end

	terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW))
end

function Pop(label, note)
	if not Show then
		return
	end

	core.host:execute(
		"prompt",
		1,
		label,
		" ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note
	)
end

function SoundAlert(SoundFile)
	if not PlaySound then
		return
	end

	terminal:alertSound(SoundFile, RecurrentSound)
end

function Update(period)
	if source:serial(source:size() - 1) ~= LastSerial then
		LastSerial = source:serial(source:size() - 1)
		Flag = {}
	end

	Up[period] = 0
	Down[period] = 0

	if period <= first + FRACTAL then
		return
	end

	local signal = Fractal(period - FRACTAL);
	if signal == 1 then
		Up[period] = 1;
	elseif signal == -1 then
		Down[period] = 1;
	end
	
	if  (Up[period]==1 and  Filter and source.close[period]> source.open[period] and R == "Down" ) 
	or (Up[period]==1  and  Filter and source.close[period]< source.open[period] and R == "Up" ) 
	then
		Up[period]=0;
	end
	
	
	if  (Down[period]==1 and  Filter and source.close[period]> source.open[period] and S == "Down" ) 
	or (Down[period]==1  and  Filter and source.close[period]< source.open[period] and S == "Up" ) 
	then
		Down[period]=0;
	end
	

	if ( DOWN and not Filter) 
	or (DOWN and  Filter and source.close[period]> source.open[period]  and S ~= "Down") 
	or (DOWN and  Filter and source.close[period]< source.open[period]  and S ~= "Up") 
	then
		return -1;
	end
	
	if instance.parameters.strategy_mode then
		Start = Search(period);
		for period2 = Start - 1, period, 1 do
			local min, max
			if Up[period2] == 1 then
				max = Last(period2, true, period)
			end
			if Down[period2] == 1 then
				min = Last(period2, false, period)
			end
	
			if max ~= nil then
				for i = period2, max do
					UpS[i] = source.high[period2] + SIZE;
					DownS[i] = source.high[period2] - SIZE;
				end
			end
	
			if min ~= nil then
				for i = period2, min do
					UpS[i] = source.low[period2] + SIZE;
					DownS[i] = source.low[period2] - SIZE;
				end
			end
		end
	end
end

function Search(ref_period)
	if ref_period == nil then
		ref_period = source:size() - 1;
	end
	local Count = 0
	local period
	local RETURN
	for period = ref_period, first, -1 do
		if Up[period] == 1 or Down[period] == 1 then
			if Last(period, true, ref_period) ~= nil or Last(period, false, ref_period) ~= nil then
				Count = Count + 1
			end
		end
		RETURN = period
		if Count >= Number then
			break
		end
	end

	return RETURN
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, Resistance)
		context:createSolidBrush(2, Resistance)

		context:createPen(3, context.SOLID, 1, Support)
		context:createSolidBrush(4, Support)

		context:createPen(5, context.SOLID, 2, Color)

		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end

	local right = context:right()

	if Method == "Chart" then
		Start = context:firstBar()
	elseif Method == "Number" then
		Start = Search()
	elseif Method == "All" then
		Start = source:first()
	end

	LastValid, x = context:positionOfBar(source:size() - 1)
	Top = {}
	Bottom = {}

	local Index = 0

	for period = Start - 1, source:size() - 1, 1 do
		local min, max, MAX, MIN
		if Up[period] == 1 then
			max = Last(period, true)
		end

		if Down[period] == 1 then
			min = Last(period, false)
		end

		if Find ~= "Support" and max ~= nil then
			visible1, y1 = context:pointOfPrice(source.high[Up[period]])
			visible2, y2 = context:pointOfPrice(math.max(source.open[Up[period]], source.close[Up[period]]))
			x1, x = context:positionOfBar(period)

			if not Extend then
				x2, x = context:positionOfBar(max)
			else
				x2 = right
			end

			context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)

			if x2 >= LastValid then
				Index = Index + 1
				Top[Index] = source.high[Up[period]]
				Bottom[Index] = math.max(source.open[Up[period]], source.close[Up[period]])
			end
		end

		if Find ~= "Resistance" and min ~= nil then
			visible1, y1 = context:pointOfPrice(source.low[Down[period]])
			visible2, y2 = context:pointOfPrice(math.min(source.open[Down[period]], source.close[Down[period]]))

			x1, x = context:positionOfBar(period)

			if not Extend then
				x2, x = context:positionOfBar(min)
			else
				x2 = right
			end

			context:drawRectangle(3, 4, x1, y1, x2, y2, transparency)

			if x2 >= LastValid then
				Index = Index + 1
				Top[Index] = source.low[Down[period]]
				Bottom[Index] = math.min(source.open[Down[period]], source.close[Down[period]])
			end
		end
	end

	Sound()
end

function Sound()
	period = source:size() - 1

	if #Top == 0 then
		return
	end

	for i = 1, math.max(#Top, #Bottom), 1 do
		if Flag[i] ~= 1 then
			if (Top[i] > source.close[period] and Top[i] < source.close[period - 1]) then
				SendAlert("Crossed over")
				SoundAlert(CrossOver)
				Pop("Advanced Support Resistance", " Cross Over ")
				Flag[i] = 1
			end
		end

		if Flag[i] ~= 1 then
			if (Bottom[i] < source.close[period] and Bottom[i] > source.close[period - 1]) then
				SendAlert("Crossed under")
				SoundAlert(CrossUnder)
				Pop("Advanced Support Resistance", " Cross Under ")
				Flag[i] = 1
			end
		end
	end
end

function Last(period, flag, ref_period)
	if ref_period == nil then
		ref_period = source:size() - 1;
	end
	local i

	local RETURN = nil

	local Number = 0
	local Q = 0
	local T = 0

	local Price
	if Break == "Body" then
		Price = source.close
	else
		if flag then
			Price = source.high
		else
			Price = source.low
		end
	end

	if flag then
		for i = period + 1, ref_period, 1 do
			if Price[i] > Price[period] then
				Number = Number + 1
				T = T + 1
				if T > Tolerance then
					RETURN = i
					break
				end
			else
				RETURN = i
				Number = Number + 1
				if Price[i] >= math.max(source.open[Up[period]], source.close[Up[period]]) and Price[i] <= source.high[Up[period]] then
					Q = Q + 1
				end
			end
		end
	end

	if not flag then
		for i = period + 1, ref_period, 1 do
			if Price[i] < source.low[period] then
				Number = Number + 1
				T = T + 1
				if T > Tolerance then
					RETURN = i
					break
				end
			else
				RETURN = i
				Number = Number + 1
				if Price[i] >= math.min(source.open[Down[period]], source.close[Down[period]]) and Price[i] <= source.low[Down[period]] then
					Q = Q + 1
				end
			end
		end
	end

	if Number < MinLength then
		RETURN = nil
	end

	if Number > MaxLength then
		RETURN = period + MaxLength
	end

	if Q < Qualified then
		RETURN = nil
	end

	return RETURN
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end

function Fractal(period)
	local UP = true
	local DOWN = true
	for i = 1, FRACTAL, 1 do
		if source.low[period - i] < source.low[period] then
			DOWN = false
		end

		if source.high[period - i] > source.high[period] then
			UP = false
		end

		if source.low[period + i] < source.low[period] then
			DOWN = false
		end
		if source.high[period + i] > source.high[period] then
			UP = false
		end

		if not UP and not DOWN then
			break
		end
	end

	if  UP 
	then
		return 1;
	end

	if   DOWN  
	then
		return -1;
	end
	return 0;
end
