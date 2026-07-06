-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75461

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
    indicator:name("Variable Instrument Heatmap View")
    indicator:description("Displays a heatmap of instrument percentage changes.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("NeutralColor", "Neutral Change Color", "Color for neutral percentage changes (close to zero)", core.rgb(128, 128, 128))
    indicator.parameters:addColor("PositiveColor", "Positive Change Color", "Color for positive percentage changes", core.rgb(0, 255, 0))
    indicator.parameters:addColor("NegativeColor", "Negative Change Color", "Color for negative percentage changes", core.rgb(255, 0, 0))
    indicator.parameters:addColor("TextColor", "Text Color", "Color of the text in the heatmap", core.COLOR_LABEL )
	indicator.parameters:addInteger("FontSizePercentage", "Font Size (% of cell height)", "Text size as a percentage of cell height",95, 50,100)	
end

local instruments = {}
local changes = {}
local Source = {}
local loading = {}
local PositiveColor, NegativeColor, NeutralColor, TextColor, FontSize
local InitTheView=false;
function getInstrumentList()
    local list = {}
    local count = 0
    local enum = core.host:findTable("offers"):enumerator()
    local row = enum:next()
    while row ~= nil do
        count = count + 1
        list[count] = row.Instrument
        row = enum:next()
    end
    return list, count
end

function Prepare(nameOnly)


     local name = "Variable Instrument Heatmap View"
    instance:name(name)
    if nameOnly then
        return
    end

    PositiveColor = instance.parameters.PositiveColor
    NeutralColor = instance.parameters.NeutralColor
    NegativeColor = instance.parameters.NegativeColor
    TextColor = instance.parameters.TextColor
    FontSizePercentage = instance.parameters.FontSizePercentage

    instruments, _ = getInstrumentList()
 
    for i = 1, #instruments do 
            Source[i] = core.host:execute("getHistory1", 20000 + i, instruments[i], "D1", 2, 0, true)
            loading[i] = true 
    end
  
    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)	 
	
	instance:ownerDrawn(true)
	core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView(name, 0, 1, false, true)
	
    core.host:execute("setTimer", 1, 1) -- Update every 60 seconds
end

function AsyncOperationFinished(cookie)
if not InitTheView then
    InitTheView = true
    if Source[1]:size() > 0 then
        instance:addViewBar(Source[1]:date(0))
    else
        instance:addViewBar(core.now())
    end
end
	
 
    for i = 1, #instruments do	   
		
	 
            if cookie == 20000 +i then  
                loading[i] = false
            end
        
    end
	
	if cookie == 999 or cookie == 1 then
	
	    for i = 1, #instruments do
        
				if loading[i]== true or Source[i]:size() < 2 then
					changes[i] = 0 -- Assign default value if data is insufficient
				else
					local lastClose = Source[i].close[Source[i]:size() - 1]
					local prevClose = Source[i].close[Source[i]:size() - 2]
					changes[i] = ((lastClose - prevClose) / prevClose) * 100
			 
                end
        end
	
	end
end

function Update(period)

end

 

function Draw(stage, context)
    if stage ~= 0 then
        return
    end

    local occupiedAreas = {} -- Keeps track of occupied areas on the canvas

    context:createSolidBrush(1, PositiveColor)
    context:createSolidBrush(2, NegativeColor)
    context:createSolidBrush(3, NeutralColor)

    local top, bottom = context:top(), context:bottom()
    local left, right = context:left(), context:right()
    local width = (right - left) * 0.70 -- Reduce usable area by 30%
    local height = (bottom - top) * 0.70

    local totalArea = width * height
    local totalChange = 0
    for i = 1, #instruments do
        if changes[i] ~= nil then
            totalChange = totalChange + math.abs(changes[i])
        end
    end

    local function isAvailable(x, y, cellWidth, cellHeight)
        for _, area in ipairs(occupiedAreas) do
            if not (x + cellWidth < area.x or x > area.x + area.width or y + cellHeight < area.y or y > area.y + area.height) then
                return false
            end
        end
        return true
    end

    local function findIdealPosition(cellWidth, cellHeight)
        for row = 0, math.floor(height / cellHeight) do
            for col = 0, math.floor(width / cellWidth) do
                local x = left + col * cellWidth
                local y = top + row * cellHeight
                if isAvailable(x, y, cellWidth, cellHeight) then
                    return x, y
                end
            end
        end
        return nil, nil
    end

    for i = 1, #instruments do
        local change = changes[i]
        if changes[i] ~= nil and changes[i] ~= 0 then
            local relativeArea = totalArea * (math.abs(change) / totalChange)
            local cellWidth = math.sqrt(relativeArea)
            local cellHeight = cellWidth  -- Ensure squares maintain proportional size

            local color = math.abs(change) < 0.1 and 3 or (change >= 0 and 1 or 2)
            local text = string.format("%s\n%.2f%%", instruments[i], change)

            -- Find ideal position
            local x, y = findIdealPosition(cellWidth, cellHeight)
            if x and y then
                -- Draw the rectangle
                context:drawRectangle(-1, color, x, y, x + cellWidth, y + cellHeight)

                -- Mark this area as occupied
                table.insert(occupiedAreas, {x = x, y = y, width = cellWidth, height = cellHeight})

                -- Draw text
                context:createFont(4, "Arial", ((cellWidth /100)*FontSizePercentage)/ 10,  ((cellHeight /100)*FontSizePercentage)/ 2, 0)
                context:drawText(4, text, TextColor, -1, x, y, x + cellWidth, y + cellHeight, context.CENTER + context.VCENTER)
            end
        end
    end
end




	
function ReleaseInstance()
    core.host:execute("killTimer", 1)
end	

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75461

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
