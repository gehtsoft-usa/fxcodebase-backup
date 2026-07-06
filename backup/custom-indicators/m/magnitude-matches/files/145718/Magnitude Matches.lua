-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72095

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("Magnitude Matches")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation") 
	indicator.parameters:addBoolean("Volume", "Use Volume Correction", "", true)
	indicator.parameters:addBoolean("UseAverage", "Use Average", "", false)
	
	indicator.parameters:addInteger("Period", "Average Magnitude Period", "", 14)
	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line color", "Color", core.COLOR_LABEL )
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("up", "Up color", "Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("down", "Down color", "Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("transparency", "Transparency", "Transparency", 50)
	indicator.parameters:addInteger("Size", "Size", "Size", 5)
	indicator.parameters:addBoolean("Historical", "Historical", "", true)
	indicator.parameters:addBoolean("Lines", "Show Lines", "", true)
	indicator.parameters:addBoolean("Magnitude", "Magnitude", "", true)
end

local first 
local source
local transparency
local Up, Down
local Size
local Line
local Lines
local Historical
local Skip
local Max
local size
local Sum
local Magnitude
local Period;
local UseAverage;
function Prepare(onlyName)
	source = instance.source
	Up = instance.parameters.up
	Down = instance.parameters.down 
	Size = instance.parameters.Size
	Historical = instance.parameters.Historical
	UseAverage = instance.parameters.UseAverage;
	Lines = instance.parameters.Lines
	Skip = instance.parameters.Skip
	Volume = instance.parameters.Volume
	Magnitude = instance.parameters.Magnitude
	Period= instance.parameters.Period;
	first = source:first()  + 1

	name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if onlyName then
		return
	end

	Sum = instance:addInternalStream(0, 0)
	Vol = instance:addInternalStream(0, 0)
	Max = instance:addInternalStream(0, 0)
	size = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)

	Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", core.rgb(255, 0, 0), first)
	Line:setPrecision(math.max(2, instance.source:getPrecision()))
	Line:setStyle(core.LINE_NONE)
end
--b
function Update(period, mode)
	if period <= first+Period then
		return
	end

	Sum[period] = 0
	Vol[period] = 0
 
 
    for i= 1, Period, 1 do
 
		Vol[period] = Vol[period] + source.volume[period-i+1 ]

		Sum[period] = Sum[period] + (source.close[period-i+1] - source.open[period-i+1])
    end

	if Volume then
		Sum[period] = Sum[period] * Vol[period]
	end

	Max[period] = mathex.max(Sum, period -Period + 1, period)

	Line[period] = source.close[period]

	if not Magnitude then
		
		if UseAverage then
		value = (Sum[period] / (Max[period] / 100))
		else
		  if Volume then
		  		value = (( (source.close[period] - source.open[period])) / (Max[period] / 100))*source.volume[period];
		  else
		  		value = (( (source.close[period] - source.open[period])) / (Max[period] / 100));		  
		  end
		  
		  		value = (value / (Max[period] / 100))
		end
		
		

		if value >= 0 and value <= 10 then
			size[period] = 1
		elseif value > 10 and value <= 20 then
			size[period] = 2
		elseif value > 20 and value <= 30 then
			size[period] = 3
		elseif value > 30 and value <= 40 then
			size[period] = 4
		elseif value > 40 and value <= 50 then
			size[period] = 5
		elseif value > 50 and value <= 60 then
			size[period] = 6
		elseif value > 60 and value <= 70 then
			size[period] = 7
		elseif value > 70 and value <= 80 then
			size[period] = 8
		elseif value > 80 and value <= 90 then
			size[period] = 9
		elseif value > 90 and value <= 100 then
			size[period] = 10
		end
	else
	    if UseAverage then
		size[period] = (Sum[period] / (Max[period] / 100))
		else
		
		  if Volume then
		  		value = (( (source.close[period] - source.open[period])) / (Max[period] / 100))*source.volume[period];
		  else
		  		value = (( (source.close[period] - source.open[period])) / (Max[period] / 100));		  
		  end
		  
		  		size[period] = (value / (Max[period] / 100))
		  
		end
		
		
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			instance.parameters.color
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end
	if Historical then
		Start = math.max(context:firstBar(), first)
		End = math.min(context:lastBar(), source:size() - 1)
	else
		Start = source:size() - 1
		End = source:size() - 1
	end

	for period = Start, End, 1 do
	 
		
		
		---%	Modulus Operator and remainder of after an integer division	B % A will give 0	
		--5 % 1 = 0
		--5 % 2 = 1		
		-- 5 divided by 1 equals 5, with a remainder of 0

			x2, x = context:positionOfBar(period)	        --Current candle
			visible, y2 = context:pointOfPrice(source.close[period]) 	        --Current candle

							context:createFont(2, "Wingdings", (Size / 100) * size[period], (Size / 100) * size[period], 0)

							width, height = context:measureText(2, "\108", context.CENTER)
							if Sum[period] > 0 then
								context:drawText(
									2,
									"\108",
									Up,
									-1,
									x2 - width / 2,
									y2 - height / 2,
									x2 + width / 2,
									y2 + height / 2,
									context.CENTER
								)
							else
								context:drawText(
									2,
									"\108",
									Down,
									-1,
									x2 - width / 2,
									y2 - height / 2,
									x2 + width / 2,
									y2 + height / 2,
									context.CENTER
								)
							end

		 
				x1, x = context:positionOfBar(period - 1)
				visible, y1 = context:pointOfPrice(source.close[period-1 ])
				if Lines then
					context:drawLine(1, x1, y1, x2, y2, transparency) 
			 
		        end
	end
end
