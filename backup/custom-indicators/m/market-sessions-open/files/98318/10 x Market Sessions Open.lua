-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61752

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("10 x Market Sessions Open")
	indicator:description("Market Sessions Open ")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	Add(1, "Sidney", -7, 9, core.rgb(255, 0, 0))
	Add(2, "Tokyo", -5, 9, core.rgb(0, 255, 0))
	Add(3, "Frankfurt", 7, 9, core.rgb(128, 128, 128))		
	Add(4, "London", 3, 9, core.rgb(0, 0, 255))
	Add(5, "New York", 8, 9, core.rgb(128, 128, 128))


	Add(6, "1. Custom ", 0, 9, core.rgb(128, 128, 128))
	Add(7, "2. Custom ", 0, 9, core.rgb(128, 128, 128))
	Add(8, "3. Custom ", 0, 9, core.rgb(128, 128, 128))		
	Add(9, "4. Custom ", 0, 9, core.rgb(128, 128, 128))
	Add(10, "5. Custom ", 0, 9, core.rgb(128, 128, 128))
	
	indicator.parameters:addGroup("Style")
	indicator.parameters:addBoolean("Show", "Show Label", "", true)
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15)
	indicator.parameters:addColor("Label", "label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

function Add(id, Name, From, Length, Color)
	indicator.parameters:addGroup(id .. ". Session")
    
	if id <= 5 then
	indicator.parameters:addBoolean("On" .. id, "Show  This Session", "", true)
	else
	indicator.parameters:addBoolean("On" .. id, "Show  This Session", "", false)	
	end
	
	indicator.parameters:addString("Name" .. id, "Session Name", "Session Name", Name)
	indicator.parameters:addDouble("From" .. id, "Session Start Time", "Session Start Time", From)
	indicator.parameters:addDouble("Length" .. id, "Session Length", "Session Length", Length)
	indicator.parameters:addColor("Color" .. id, "Session Color", "Session Color", Color)
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Name = {}
local From = {}
local Length = {}
local first
local Transparency
local source = nil
--local ShowPriceTarget;
local Color = {}
local Count
local points
local Size
local Label
local Placing
local Show
local DrawFlag;
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Size = instance.parameters.Size
	Label = instance.parameters.Label
	Placing = instance.parameters.Placing
	Show = instance.parameters.Show

	Count = 0
	local i

	for i = 1, 10, 1 do
		if instance.parameters:getBoolean("On" .. i) then
			Count = Count + 1
			Color[Count] = instance.parameters:getDouble("Color" .. i)
			Name[Count] = instance.parameters:getString("Name" .. i)
			From[Count] = instance.parameters:getDouble("From" .. i)
			Length[Count] = instance.parameters:getDouble("Length" .. i)
		end
	end
	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	
	local S, E = core.getcandle("H8", 0, 0, 0)
	local s, e = core.getcandle(source:barSize(), 0, 0, 0)
	
    if (e - s) <= (E-S) then
		DrawFlag = true
		core.host:execute("setStatus", " ")
	else
		DrawFlag = false
		core.host:execute("setStatus", "Time Frame should be equal to or smaller than 8 hours ")
	end
	
	s = math.floor(s * 86400 + 0.5) -- >>in seconds
	e = math.floor(e * 86400 + 0.5) -- >>in seconds
 
 
	instance:ownerDrawn(true)
 
end

function Draw(stage, context)
	if stage ~= 2
    or not DrawFlag	
	then
		return
	end

	points = context:pixelsToPoints(Size)
	context:createFont(3, "Arial", context:pointsToPixels(points), context:pointsToPixels(points), 0)

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	local first = math.max(first, context:firstBar())
	local last = math.min(context:lastBar(), source:size() - 1)

	local Start, End, Step

	if Placing == "Top" then
		Start = 1
		Stop = Count
		Step = 1
	else
		Start = Count
		Stop = 1
		Step = -1
	end

	for period = first, last, 1 do
		for session = Start, Stop, Step do
			DrawSession(session, context, period)
		end
	end
end

function Process(session, context, period)
	local date = source:date(period) -- bar date;

	local sfrom, sto

	-- 1) calculate the session to which the specified date belongs
	local t
	t = math.floor(date * 86400 + 0.5) -- date/time in seconds

	-- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
	t = t - From[session] * 3600
	-- truncate to the day only.
	t = math.floor(t / 86400 + 0.5) * 86400
	-- and shift it back to est time zone
	t = t + From[session] * 3600

	sfrom = t -- begin of the session
	sto = sfrom + Length[session] * 3600 -- end of the session

	sfrom = sfrom / 86400
	sto = sto / 86400

	if not (sto == date or sfrom == date) then
		return 0, 0
	end

	local p1 = core.findDate(source, sfrom, false)
	local p2 = core.findDate(source, sto, false)
	if p1 ~= -1 and p2 ~= -1 then
		local x1, x = context:positionOfBar(p1)
		local x2, x = context:positionOfBar(p2)
		return x1, x2, p1, p2
	else
		return 0, 0, 0, 0
	end
end

function DrawSession(session, context, period)
	local x1, x2, x3, x4 = Process(session, context, period)
	
	 
	if x1 == 0 or x2 == 0 then
		return
	end

	visible, y1 = context:pointOfPrice(source.open[x3])
	context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Color[session])
	context:createSolidBrush(2, Color[session])
	context:drawLine(1, x1, y1, x2, y1, 0)

	if Show then
		width, height = context:measureText(3, Name[session], context.LEFT)
		context:drawRectangle(1, 2, x1, y1 - height * 1.25, x1 + width, y1 - height * 0.25, Transparency) 
		context:drawText(3, Name[session], Label, -1, x1, y1 - height * 1.25, x1 + width, y1 - height * 0.25, context.LEFT)
		 
	end
end

function Update(period)
end



--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+