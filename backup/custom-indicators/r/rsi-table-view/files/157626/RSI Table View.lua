 
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75451

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 
 
function Init()
    indicator:name("RSI Table View")
    indicator:description("Displays RSI values for up to 10 currencies across 5 timeframes.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)
    --indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")	
    indicator.parameters:addInteger("Period", "RSI Period", "RSI Period", 14, 0, 1000)
    indicator.parameters:addInteger("Overbought", "Overbought Level", "Define overbought level", 70, 50, 100)
    indicator.parameters:addInteger("Oversold", "Oversold Level", "Define oversold level", 30, 0, 50)
	
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("TextColor", "Text Color", "Color of the text in the grid", core.COLOR_LABEL )
    indicator.parameters:addColor("OverboughtColor", "Overbought RSI Color", "Color for RSI overbought levels", core.rgb(255, 0, 0))
    indicator.parameters:addColor("OversoldColor", "Oversold RSI Color", "Color for RSI oversold levels", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("FontSize", "Font Size (as % of cell)", "Size of the text font as a percentage of the cell", 80, 60, 100)
    instruments = { "EUR/USD", "USD/JPY", "GBP/USD", "AUD/USD", "USD/CAD", 
                    "NZD/USD", "USD/CHF", "USD/SGD", "USD/HKD", "USD/ZAR" }
    
    for i = 1, 10 do
        Add( i,  instruments[i])
    end
	
   local timeframes = {"m1", "m5", "H1", "H4", "D1"}	
	
	for i= 1, 5 , 1 do
	    AddTF(i,timeframes[i] )

	end
end

function Add(id,  Instrument)
    indicator.parameters:addGroup(id .. " Instrument") 
    indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument)
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS)
end

function AddTF(id,  TF)

    indicator.parameters:addGroup(id .. " TF") 
    indicator.parameters:addString("timeframes" .. id, "Time Frame", "", TF) 
    indicator.parameters:setFlag("timeframes" .. id, core.FLAG_PERIODS)
	 
end

local instruments = {}
local timeframes = {}
local rsiValues = {}
local rsiStreams = {}
local TextColor, OverboughtColor, OversoldColor, FontSize
local InitView = false
local loading = {}

function Prepare(nameOnly)
    TextColor = instance.parameters.TextColor
    OverboughtColor = instance.parameters.OverboughtColor
    OversoldColor = instance.parameters.OversoldColor
    FontSize = instance.parameters.FontSize
	Period = instance.parameters.Period;
	Overbought = instance.parameters.Overbought;
	Oversold = instance.parameters.Oversold;

    local name = "RSI Table View"
    instance:name(name)

    if nameOnly then
        return
    end

    for i = 1, 5 do
    timeframes[#timeframes + 1] = instance.parameters["timeframes" .. i]
	end

    local ID = 0
    for i = 1, 10 do 
 
			instruments[#instruments + 1] =  instance.parameters["Instrument" .. i]
	 
    end

    for i = 1, #instruments do
        rsiStreams[i] = {}
        rsiValues[i] = {}
        loading[i] = {}
        for j = 1, #timeframes do
            ID = ID + 1
            local source = core.host:execute("getHistory1", 20000 + ID, instruments[i], timeframes[j], 100, 0, true)
            rsiStreams[i][j] = core.indicators:create("RSI", source.close, Period)
            rsiValues[i][j] = 0
            loading[i][j] = true
        end
    end

    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView(name, 0, 1, false, true)
    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)

    core.host:execute("setTimer", 1, 1)
end

function ReleaseInstance()
    core.host:execute("killTimer", 1)
end

function Update(period)
    -- Placeholder for compliance with Override.lua
end

function AsyncOperationFinished(cookie)
    local ID = 0
    for i = 1, #instruments do
        for j = 1, #timeframes do
            ID = ID + 1
            if cookie == 20000 + ID then
                loading[i][j] = false
            end
        end
    end

    local FLAG = false
    for i = 1, #instruments do
        for j = 1, #timeframes do
            if loading[i][j] then
                FLAG = true
            end
        end
    end

    if FLAG then
        core.host:execute("setStatus", "Loading")
    else
        core.host:execute("setStatus", "Loaded")

        if not InitView then
            InitView = true
            instance:addViewBar(1)
        end

        if cookie == 1 or cookie == 999 then
            for i = 1, #instruments do
                for j = 1, #timeframes do
                    local rsi = rsiStreams[i][j]
                    rsi:update(core.UpdateLast)
					if  rsi.DATA:hasData(rsi.DATA:size() - 1) then
                    rsiValues[i][j] = rsi.DATA[rsi.DATA:size() - 1]
					else
					rsiValues[i][j] = 0;
					end
                end
            end
        end
    end

    return core.ASYNC_REDRAW
end

function Draw(stage, context)
    if stage ~= 0 then
        return
    end

    local top, bottom = context:top(), context:bottom()
    local left, right = context:left(), context:right()

    local yGap = (context:bottom() - context:top()) / math.max((#instruments + 1), 15)
    local xGap = (right - left) / (#timeframes + 1)
    local pixelHeight = yGap * (FontSize / 100)
    local pixelWidth = (xGap/10) * (FontSize / 100)	
    context:createFont(1, "Arial", pixelWidth, pixelHeight, 0)

    context:resetClipRectangle()

    -- Draw headers
    for j = 1, #timeframes do
        local x1 = xGap + left + (j - 1) * xGap
        local y1 = top
        local text = timeframes[j]
        context:drawText(1, text, TextColor, -1, x1, y1, x1 + xGap, y1 + yGap, context.CENTER + context.VCENTER)
    end

    -- Draw data rows with instrument labels
    for i = 1, #instruments do
        local labelX = left
        local labelY = top + i * yGap
        context:drawText(1, instruments[i], TextColor, -1, labelX, labelY, labelX + xGap, labelY + yGap, context.CENTER + context.VCENTER)

        for j = 1, #timeframes do
            local x1 = left + xGap + (j - 1) * xGap
            local y1 = top + i * yGap

            local text = string.format("%.2f", rsiValues[i][j])
            local color = TextColor

            if rsiValues[i][j] >= Overbought then
                color = OverboughtColor
            elseif rsiValues[i][j] <= Oversold then
                color = OversoldColor
            end

            context:drawText(1, text, color, -1, x1, y1, x1 + xGap, y1 + yGap, context.CENTER + context.VCENTER)
        end
    end
end
 
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75451

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 