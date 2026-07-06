-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69170

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
	indicator:name("Support Resistance Lines")
	indicator:description("Support Resistance Lines")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("LookBack", "Look Back Period", "Period", 1000)
	indicator.parameters:addString("Find", "Search for ", "Search for ", "Both")
	indicator.parameters:addStringAlternative("Find", "Support", "", "Support")
	indicator.parameters:addStringAlternative("Find", "Resistance", "", "Resistance")
	indicator.parameters:addStringAlternative("Find", "Both", "", "Both")

	indicator.parameters:addString("Method", "Validation Method", "Validation", "High/Low")
	indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low", "High/Low")
	indicator.parameters:addStringAlternative("Method", "Open/Close", "Open/Close", "Open/Close")

	indicator.parameters:addString("Zone", "Zone Method", "Zone Method", "Narrow")
	indicator.parameters:addStringAlternative("Zone", "Narrow", "Narrow", "Narrow")
	indicator.parameters:addStringAlternative("Zone", "Wide", "Wide", "Wide")

	indicator.parameters:addInteger("Tolerance", "Tolerance", "Tolerance", 0, 0, 10)

	indicator.parameters:addString("MA_Method", "MA Method", "MA Method", "MVA")
	indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addInteger("MA_Period", "MA period", "MA period", 10)
	indicator.parameters:addBoolean("Show_MA", "Show MA", "Show MA", true)
	indicator.parameters:addBoolean("Use_MA", "Use MA filter", "Use MA filter", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 128, 255))
	indicator.parameters:addColor("Up_Color", "Resistance Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down_Color", "Support Color", "", core.rgb(255, 0, 0))

	indicator.parameters:addColor("MAclr", "MA Color", "MAColor", core.rgb(255, 255, 0))
	indicator.parameters:addInteger("widthLinReg", "MA Line width", "MA Line width", 1, 1, 5)
	indicator.parameters:addInteger("styleLinReg", "MA Line style", "MA Line style", core.LINE_SOLID)
	indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("ChartAlert", "Chart alert", "", true)
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
	indicator.parameters:addFile("AlertSound", "Alert Sound", "", "")
	indicator.parameters:setFlag("AlertSound", core.FLAG_SOUND)
	indicator.parameters:addBoolean("SendEmail", "Send email", "", false)
	indicator.parameters:addString("Email", "Email address", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
	indicator.parameters:addBoolean("strategy_mode", "Strategy mode", "", false);
end
local LookBack
local Zone
local first
local source = nil
local color, Down_Color, Up_Color
local transparency
local Method
local TLclr, BLclr, TRclr, BRclr
local init = false
local up, down, Up, Down
local Last
local Find
local Method
local Count = 0
local Tolerance
local MA_Ind
local MA = nil
local UpCount, DnCount = nil, nil
local signals

function Signal(Msg)
	if instance.parameters.ChartAlert then
		core.host:execute("prompt", 1, "Alert", Msg)
	end

	if instance.parameters.PlaySound then
		terminal:alertSound(instance.parameters.AlertSound, instance.parameters.RecurrentSound)
	end

	if instance.parameters.SendEmail then
		local Subj = "Support Resistance Alert"
		terminal:alertEmail(instance.parameters.Email, Subj, Msg)
	end
end

function Prepare(onlyName)
	source = instance.source
	Tolerance = instance.parameters.Tolerance
	color = instance.parameters.color
	Method = instance.parameters.Method
	Zone = instance.parameters.Zone
	LookBack = instance.parameters.LookBack
	Down_Color = instance.parameters.Down_Color
	Up_Color = instance.parameters.Up_Color
	Find = instance.parameters.Find
	local name =
		profile:id() ..
		"(" .. source:name() .. ", " .. LookBack .. ", " .. Find .. ", " .. Method .. ", " .. Zone .. ", " .. Tolerance .. ")"
	instance:name(name)

	MA_Ind = core.indicators:create(instance.parameters.MA_Method, source.close, instance.parameters.MA_Period)

	first = source:first() + 6

	if instance.parameters.strategy_mode then
		up = instance:addStream("up1", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first)
		down = instance:addStream("down1", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first)

		Up = instance:addStream("up2", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first)
		Down = instance:addStream("down2", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first)
	else
		up = instance:addInternalStream(0, 0)
		down = instance:addInternalStream(0, 0)

		Up = instance:addInternalStream(0, 0)
		Down = instance:addInternalStream(0, 0)
	end

	if instance.parameters.Show_MA then
		MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first)
		MA:setWidth(instance.parameters.widthLinReg)
		MA:setStyle(instance.parameters.styleLinReg)
	else
		MA = instance:addInternalStream(first, 0)
	end

	Count = 0

	if onlyName then
		return
	end

	signals = instance:addStream("signals", core.Bar, "Signals", "Signals", core.colors().Black, 0, 0);

	instance:ownerDrawn(true)
	instance:setLabelColor(color)
end

function Update(period)
	MA_Ind:update(mode)
	MA[period] = MA_Ind.DATA[period]

	up[period] = nil
	down[period] = nil

	if period < 2 then
		return
	end

	up[period - 2] = nil
	down[period - 2] = nil

	if period < first then
		return
	end

	Fractal(period)

	if period < source:size() - 1 then
		return
	end

	Filters()

	local UpCount2, DnCount2 = 0, 0
	for i = math.max(first, period - LookBack + 1), period do
		if Up:hasData(i) and up:hasData(i) then
			if Up[i] >= -Tolerance and Up[i] ~= nil and Find ~= "Support" then
				UpCount2 = UpCount2 + 1
			end
		end
		if Down:hasData(i) and down:hasData(i) then
			if Down[i] >= -Tolerance and Down[i] ~= nil and Find ~= "Resistance" then
				DnCount2 = DnCount2 + 1
			end
		end
	end

	if UpCount ~= nil and UpCount2 > UpCount then
		if not (instance.parameters.Use_MA) or source.close[period] > MA[period] then
			signals[period] = 1;
		end
	end
	UpCount = UpCount2

	if DnCount ~= nil and DnCount2 > DnCount then
		if not (instance.parameters.Use_MA) or source.close[source:size() - 1] < MA[source:size() - 1] then
			signals[period] = -1;
		end
	end
	DnCount = DnCount2
end

function Filters()
	local i, j
	local Value
	for i = math.max(first, source:size() - 1 - LookBack + 1), source:size() - 1, 1 do
		if up[i] ~= nil then
			Up[i] = 0

			j = up[i] + 1
			while (j <= source:size() - 1 and Up[i] >= -Tolerance) do
				if Zone == "Narrow" then
					Value = math.max(source.close[up[i]], source.open[up[i]])
				else
					Value = math.min(source.close[up[i]], source.open[up[i]])
				end

				if Method == "High/Low" then
					if source.high[j] > Value then
						Up[i] = Up[i] - 1
					end
				else
					if source.close[j] > Value then
						Up[i] = Up[i] - 1
					end
				end

				j = j + 1
			end
		else
			Up[i] = nil
		end

		if down[i] ~= nil then
			Down[i] = 0

			j = down[i] + 1
			while (j <= source:size() - 1 and Down[i] >= -Tolerance) do
				if Zone == "Narrow" then
					Value = math.min(source.close[down[i]], source.open[down[i]])
				else
					Value = math.max(source.close[down[i]], source.open[down[i]])
				end

				if Method == "High/Low" then
					if source.low[j] < Value then
						Down[i] = Down[i] - 1
					end
				else
					if source.close[j] < Value then
						Down[i] = Down[i] - 1
					end
				end

				j = j + 1
			end
		else
			Down[i] = nil
		end
	end
end

function Fractal(period)
	local curr

	curr = source.high[period - 2]
	if
		(curr > source.high[period - 4] and curr > source.high[period - 3] and curr > source.high[period - 1] and
			curr > source.high[period])
	 then
		up[period - 2] = period - 2
	else
		up[period - 2] = nil
	end

	curr = source.low[period - 2]
	if
		(curr < source.low[period - 4] and curr < source.low[period - 3] and curr < source.low[period - 1] and
			curr < source.low[period])
	 then
		down[period - 2] = period - 2
	else
		down[period - 2] = nil
	end
end

function Draw(stage, context)
	local visible1, y1
	local visible2, y2
	local p1, p2, p3

	if stage ~= 0 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, Up_Color)
		context:createSolidBrush(2, Up_Color)

		context:createPen(3, context.SOLID, 1, Down_Color)
		context:createSolidBrush(4, Down_Color)
		init = true
	end
	local right = context:right()

	local i
	local UpCount2, DnCount2 = 0, 0
	for i = math.max(first, source:size() - 1 - LookBack + 1), source:size() - 1, 1 do
		if Up:hasData(i) and up:hasData(i) then
			if Up[i] >= -Tolerance and Up[i] ~= nil and Find ~= "Support" then
				visible1, y1 = context:pointOfPrice(source.high[up[i]])
				visible2, y2 = context:pointOfPrice(math.max(source.open[up[i]], source.close[up[i]]))
				p1, p2, p3 = context:positionOfBar(up[i])
				context:drawRectangle(1, 2, p1, y1, right, y2, instance.parameters.transparency)
				UpCount2 = UpCount2 + 1
			end
		end
		if Down:hasData(i) and down:hasData(i) then
			if Down[i] >= -Tolerance and Down[i] ~= nil and Find ~= "Resistance" then
				visible1, y1 = context:pointOfPrice(source.low[down[i]])
				visible2, y2 = context:pointOfPrice(math.min(source.open[down[i]], source.close[down[i]]))
				p1, p2, p3 = context:positionOfBar(down[i])
				context:drawRectangle(3, 4, p1, y2, right, y1, instance.parameters.transparency)
				DnCount2 = DnCount2 + 1
			end
		end
	end

	if UpCount ~= nil and UpCount2 > UpCount then
		if not (instance.parameters.Use_MA) or source.close[source:size() - 1] > MA[source:size() - 1] then
			Signal("New support")
		end
	end
	UpCount = UpCount2

	if DnCount ~= nil and DnCount2 > DnCount then
		if not (instance.parameters.Use_MA) or source.close[source:size() - 1] < MA[source:size() - 1] then
			Signal("New resistance")
		end
	end
	DnCount = DnCount2
end

function AsyncOperationFinished(cookie)
end
