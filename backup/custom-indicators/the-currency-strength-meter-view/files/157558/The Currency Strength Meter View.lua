-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75427

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 
function Init()
	indicator:name("The Currency Strength Meter")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.View)
	
	indicator.parameters:addGroup("Calculation")	
	indicator.parameters:addInteger("NeutralColorLimit", "Neutral Color Limit", "", 25, 0, 100)	
	

	local TF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
	indicator.parameters:addGroup("1. Time Frame")

	indicator.parameters:addInteger("TF1", "Price Time Frame", "", 3)
	for i = 1, 13, 1 do
		indicator.parameters:addIntegerAlternative("TF1", TF[i], "", i)
	end

	indicator.parameters:addGroup("2. Time Frame")

	indicator.parameters:addInteger("TF2", "Price Time Frame", "", 5)
	for i = 1, 13, 1 do
		indicator.parameters:addIntegerAlternative("TF2", TF[i], "", i)
	end

	indicator.parameters:addGroup("3. Time Frame")

	indicator.parameters:addInteger("TF3", "Price Time Frame", "", 8)
	for i = 1, 13, 1 do
		indicator.parameters:addIntegerAlternative("TF3", TF[i], "", i)
	end

	indicator.parameters:addGroup("4. Time Frame")

	indicator.parameters:addInteger("TF4", "Price Time Frame", "", 11)
	for i = 1, 13, 1 do
		indicator.parameters:addIntegerAlternative("TF4", TF[i], "", i)
	end

	indicator.parameters:addGroup("Selected Time Frame")

	indicator.parameters:addInteger("Selected", "Selected Time Frame", "", 4)
	for i = 1, 4, 1 do
		indicator.parameters:addIntegerAlternative("Selected", i .. ".", "", i)
	end

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL)

	indicator.parameters:addColor("Up", "Up Color", "Label Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "Label Color", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Color", "Label Color", core.rgb(255, 165, 0))

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 60, 0, 100)
end

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
end

local TF = {}
local Point = {}
local Color
local Source = {}

local Size
local transparency
local loading = {}
local source
local Pair = {}
local Num
local Up, Down, Neutral

local Pair = {"EUR/USD", "GBP/USD", "AUD/USD", "NZD/USD", "USD/JPY"}
local Count = 5
local Instruments = {"USD", "EUR", "GBP", "AUD", "NZD", "JPY"}
local Index = {1, 1, 2, 3, 4, 5}
local Invert = {true, false, false, false, false, true}
local tf = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local Selected
local Orientation

local Value = {}
local Result={};
local SortedKey;
local Max={};
local NeutralColorLimit;
function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	Size = instance.parameters.Size
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral
	Selected = instance.parameters.Selected
    NeutralColorLimit = instance.parameters.NeutralColorLimit;
	source = instance.source

	Num = 4
	for i = 1, 4, 1 do
		TF[i] = tf[instance.parameters:getInteger("TF" .. i)]
	end

	Color = instance.parameters.Color
	
	for i= 1, 5, 1 do   
    assert(core.host:findTable("offers"):find("Instrument", Pair[i]) ~= nil, "You must be subscribed to " .. Pair[i]);
	end

	Value[1] = {}
	Value[2] = {}
	Value[3] = {}
	Value[4] = {}
	Value[5] = {}
	Value[6] = {}
 

	local ID = 0
	for i = 1, Count, 1 do
		Source[i] = {}
		loading[i] = {}

		Point[i] = core.host:findTable("offers"):find("Instrument", Pair[i]).PointSize

		for j = 1, Num, 1 do
			ID = ID + 1

			Source[i][j] = core.host:execute("getHistory1", 20000 + ID, Pair[i], TF[j], 2, 0, true)
			loading[i][j] = true
		end
	end

	instance:ownerDrawn(true)
	core.host:execute("subscribeTradeEvents", 999, "offers")
	instance:initView("The Currency Strength Meter", 0, 1, false, true)

	open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
	open:setVisible(false)

	core.host:execute("setTimer", 1, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

function AsyncOperationFinished(cookie)
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

	if FLAG then
		core.host:execute("setStatus", Number .. " / " .. Count * Num)
	else
		core.host:execute("setStatus", "Loaded")
		for i = 1, Source[1][1]:size() - 1 do
			instance:addViewBar(Source[1][1]:date(i))
		end
        Max={}; 
		for i = 1, 6, 1 do
			for j = 1, Num, 1 do
				Calculate(i, j)
			end
		end
		
		SortTheArray()
	end

	if cookie == 999 or cookie == 1 then
	Max={}; 
		for i = 1, 6, 1 do
			for j = 1, Num, 1 do
				Calculate(i, j)
			end
		end
		
		SortTheArray()
	end

	return core.ASYNC_REDRAW
end

function Calculate(i, j)
	Value[i][j] = 0
	

       
	if
		Source[Index[i]][j].close:hasData(Source[Index[i]][j].close:size() - 1) and
			Source[Index[i]][j].close:hasData(Source[Index[i]][j].close:size() - 2)
	 then
		if Point[Index[i]] ~= 0 then
		
		
			Value[i][j] =
				(Source[Index[i]][j].close[Source[Index[i]][j].close:size() - 1] -
				Source[Index[i]][j].close[Source[Index[i]][j].close:size() - 2]) /
				Point[Index[i]]
				
			if Invert[i] then
			Value[i][j]=-Value[i][j];
            end			
			if j== Selected then
			Result[i]=Value[i][j];
			end
			
			
			if Max[j]==nil then
			Max[j]=math.abs(Value[i][j]);
			elseif Max[j] < math.abs(Value[i][j]) then
			Max[j] = math.abs(Value[i][j])
			end
	
		end
	end

	return
end



function SortTheArray()

	SortedKey= BubbleSort(Result,1,1, 5 );
return
end

function BubbleSort(Data)
 
 local Key={};
 local Temp;
 local Sort=true;
 
   
   for i=1, #Data, 1 do
   Key[i]=i;
   end
   
   

     while Sort do
	 Sort=false;
   
				for i = 2, #Data , 1 do
						
						  if Data[Key[i]] <  Data[Key[i-1]] then
						   Sort=true;						
						   
                            Temp= Key[i];						   
							Key[i]=Key[i-1];
							Key[i-1]=Temp;							  
						  end
			  
			 end
	 
	 end
  
  return Key;
end



local top, bottom
local left, right
local xGap
local yGap
local init = false

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false
local iwidth, iheight
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

	xGap = (right - left) / (Num + 3)
	yGap = (bottom - top) / (7)

	width = ((xGap / 7) / 100) * Size
	height = (yGap / 100) * Size

	context:createFont(7, "Arial", width, height, 0)

	if not init then
		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end

	for i = 1, 6, 1 do
		for j = 1, Num, 1 do
			DrawTheDraw(context, i, j)
		end
	end
end

function DrawTheDraw(context, i, j)
	local color1 = Neutral
	local color2 = -1

	y1 = top + (i - 1) * yGap + yGap
	y2 = top + (i) * yGap + yGap

	x1 = left + (j) * xGap
	x2 = left + (j + 1) * xGap

	if i == 1 then
		context:drawText(7, TF[j], Color, -1, x1, y1 - yGap, x2, y2 - yGap, context.CENTER)
	end

	if j == 1 then
		context:drawText(7, Instruments[i], Color, -1, x1 - xGap, y1, x2 - xGap, y2, context.CENTER)
	end

 
		if Value[i][j] > NeutralColorLimit*(Max[j]/100) then
			context:drawText(7, win32.formatNumber(Value[i][j], false, 2), Up, -1, x1, y1, x2, y2, context.CENTER)
		elseif Value[i][j] < -NeutralColorLimit*(Max[j]/100) then
			context:drawText(7, win32.formatNumber(Value[i][j], false, 2), Down, -1, x1, y1, x2, y2, context.CENTER)
		else
			context:drawText(7, win32.formatNumber(Value[i][j], false, 2), Neutral, -1, x1, y1, x2, y2, context.CENTER)
		end
 
	--Selected
 
	    if   j == Num   then
		
			        if Result[i] > NeutralColorLimit*(Max[j]/100) then
						context:drawText(7, win32.formatNumber(Result[SortedKey[i]], false, 2), Up, -1, x1+xGap*2, y1, x2+xGap*2, y2, context.CENTER)
					elseif Result[i] < - NeutralColorLimit*(Max[j]/100) then
						context:drawText(7, win32.formatNumber(Result[SortedKey[i]], false, 2), Down, -1, x1+xGap*2, y1, x2+xGap*2, y2, context.CENTER)
					else
						context:drawText(7, win32.formatNumber(Result[SortedKey[i]], false, 2), Neutral, -1, x1+xGap*2, y1, x2+xGap*2, y2, context.CENTER)
					end		
		end		
		
		if j == Num then
		context:drawText(7, Instruments[SortedKey[i]], Color, -1, x1 + xGap, y1, x2 + xGap, y2, context.CENTER)
	    end
		 
	return
end
-- Available @ http://fxcodebase.com/ 

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 