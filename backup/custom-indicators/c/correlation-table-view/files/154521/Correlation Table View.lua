-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74647

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Correlation Tables View")
    indicator:description("Correlation Tables View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation")
	
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
 

    for i = 1, 6, 1 do
        indicator.parameters:addGroup(i .. ". Currency Pair ")
        Add(i)
    end

 

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL )
    indicator.parameters:addColor("Positive", "Positive Correlation Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Negative", "Negative Correlation Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))
 

    indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 50, 0, 100)


end

 


function Add(id)
    local Init = {
        "10USNote",
        "DIA.us",
        "SPX500",
        "VOLX",
        "AAPL.us",
        "QQQ.us"
    }

   --[[local Init = {
        "EUR/USD",
        "USD/JPY",
        "AUD/USD",
        "AUD/JPY",
        "GBP/USD",
        "EUR/NOK"
    }  ]]
 
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Pair = {};
 
local pauto = "(%a%a%a)/(%a%a%a)"
local Color
local Source = {}
local Size
local transparency
local loading = {}
local source 
local Count=6;
local Type 
local Point = {} 
local Num=6;
local ShowCells
local Positive, Negative, Neutral
local TF; 
local HISTORY_LOADING_ID = 1000
local Period;
local Value={};
-- Routine
function Prepare(nameOnly)

    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    
 
    Color = instance.parameters.Color
    Size = instance.parameters.Size
 
    Type = instance.parameters.Type
    Positive = instance.parameters.Positive
    Negative = instance.parameters.Negative
    Neutral = instance.parameters.Neutral
   
    TF = instance.parameters.TF;
    Period= instance.parameters.Period;
 
    
 
    local ID = 0
  
        for i = 1, Count, 1 do
                Value[i]={};

                Pair[i]=instance.parameters:getString("Pair" .. i)
           
                ID = ID + 1
                Source[i] =
                    core.host:execute(
                    "getHistory",
                    HISTORY_LOADING_ID + ID,
                    Pair[i],
                    TF,
                    0,
                    0,
                    true
                )
                loading[i] = true 
           
        end
 

    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView("Correlation Tables View", 0, 1, false, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
	
	core.host:execute ("setTimer", 1, 5);
end

 

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message, message1, message2)

    if cookie >= HISTORY_LOADING_ID then
        local i
        local ID = 0

        for i = 1, Count, 1 do
          
                ID = ID + 1
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i] = false
                end
            
        end

        local FLAG = false
        local Number = 0

        for i = 1, Count, 1 do
         
                if loading[i] then
                    FLAG = true
                    Number = Number + 1
                end
          
        end

        if FLAG then
            core.host:execute("setStatus", (Count  - Number) .. " / " .. Count)
        else
            core.host:execute("setStatus", "Loaded")
            for i = 1, Source[1]:size() - 1 do
                instance:addViewBar(Source[1]:date(i))
			end	
			
			for i = 1, Count, 1 do
				for j = 1, Num, 1 do
				   
				
							FindLast(i,j)				
					
				end
			end			
            
        end


    end
	if cookie == 999 or cookie == 1 then
 
        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
               
            
						FindLast(i,j)				
                
            end
        end
    end
	       
	        return core.ASYNC_REDRAW
end

function FindLast(i,j)
 
        if loading[i] or loading[j] then
		return;
		end
			
		local Index1= Source[i].close:size()-1
		local Index2= Source[j].close:size()-1	

        if Index1 <= Period or Index2 <= Period then
		return;
		end		
		Value[i][j]= mathex.correl(Source[i].close, Source[j].close, Index1-Period+1, Index1, Index2-Period+1, Index2);	     
 	

end

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    --shoudn't be called
end

 
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    for i = 1, Count, 1 do
            if loading[i]  then
               return
            end
      
    end

 

    top, bottom = context:top(), context:bottom()
    left, right = context:left(), context:right()

    xGap = (right - left) / (Num + 1)
    yGap = (bottom - top) / (Count + 1)

    

    for i = 1, Count, 1 do
        for j = 1, Num, 1 do
          
            Calculate(context, i, j)
        end
    end
end
function Calculate(context, i, j)


    y1 = bottom - (i + 1) * yGap
    y2 = bottom - (i) * yGap
    y0 = y1 + yGap * 3 / 2

    x1 = right - (j + 1) * xGap
    x2 = right - (j) * xGap

    iwidth = ((xGap / 7) / 100) * Size
    iheight = (yGap / 100) * Size

    context:createFont(7, "Arial", iwidth, iheight, 0) 
    if j == Num then
        width, height = context:measureText(7, Pair[i], context.CENTER)
        context:drawText(7, Pair[i], Color, -1, x1, y0 - height / 2, x2, y0 + height / 2, context.CENTER, 0)
    end

    if i == Count then
        width, height = context:measureText(7, Pair[j], 0)
        context:drawText(7, Pair[j], Color, -1, x1 + xGap, y1, x2 + xGap, y2, context.CENTER)
    end
	

 
 
	if Value[i][j] ~= nil then
 
		local ShortValue = win32.formatNumber(Value[i][j], false, 2);  
		width, height = context:measureText(7, ShortValue, context.CENTER)
	 
		if Value[i][j] > 0.5 then
		   context:drawText(7, ShortValue, Positive, -1, x1 + xGap, y0 - height / 2   , x2 + xGap, y0 + height / 2 , context.CENTER)

		elseif Value[i][j] < -0.5 then 
		   context:drawText(7, ShortValue, Negative, -1, x1 + xGap, y0 - height / 2   , x2 + xGap, y0 + height / 2 , context.CENTER)
	    else
		
 		   context:drawText(7, ShortValue, Neutral, -1, x1 + xGap, y0 - height / 2   , x2 + xGap, y0 + height / 2 , context.CENTER)
		end 
    end
	
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+