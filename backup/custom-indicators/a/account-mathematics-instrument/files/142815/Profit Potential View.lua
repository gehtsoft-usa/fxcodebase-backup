-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71340

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
    indicator:name("Profit Potential View")
    indicator:description("Profit Potential View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)
	
   
    
    indicator.parameters:addGroup("Calculation")  
	indicator.parameters:addBoolean("Inverse"  , "Inverse Sort", "", false)
	indicator.parameters:addBoolean("Highest"  , "Show Highest Values Only", "", true)
	 indicator.parameters:addInteger("High", "Number of Values Shown", "Number of Values Shown", 10)	
	 indicator.parameters:addInteger("AtRisk", "Value At Risk", "Value At Risk", 100)
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "AllCurrencyPair")
    indicator.parameters:addStringAlternative("Type","Multiple currency pair", "Multiple currency pair","MultipleCurrencyPair")
    indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "AllCurrencyPair")
	
	
	indicator.parameters:addInteger("InstrumentType", "Instrument Type", "Instrument Type", 0)
    indicator.parameters:addIntegerAlternative("InstrumentType","All","",0)
    indicator.parameters:addIntegerAlternative("InstrumentType","Forex","",1)
    indicator.parameters:addIntegerAlternative("InstrumentType","Indices","",2)
    indicator.parameters:addIntegerAlternative("InstrumentType","Commodity","",3)
    indicator.parameters:addIntegerAlternative("InstrumentType","Treasury","",4)
    indicator.parameters:addIntegerAlternative("InstrumentType","Bullion","",5)
    indicator.parameters:addIntegerAlternative("InstrumentType","Shares","",6)
    indicator.parameters:addIntegerAlternative("InstrumentType","FXIndex","",7)	
    indicator.parameters:addIntegerAlternative("InstrumentType","CFD Shares","",8)
    indicator.parameters:addIntegerAlternative("InstrumentType","Crypto","",9)
	
 
 

	
    indicator.parameters:addGroup("Instruments")	
	for i= 1 , 20, 1 do
	Add(i);
	end

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color",  core.COLOR_LABEL )
 

    indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70, 0, 100)

 
end




function Add(id)
    local Init = {
        "EUR/USD",
        "USD/JPY",
        "GBP/USD",
        "USD/CHF",
        "EUR/CHF",
        "AUD/USD",
        "USD/CAD",
        "NZD/USD",
        "EUR/GBP",
        "EUR/JPY",
        "GBP/JPY",
        "CHF/JPY",
        "GBP/CHF",
        "EUR/AUD",
        "EUR/CAD",
        "AUD/CAD",
        "AUD/JPY",
        "CAD/JPY",
        "NZD/JPY",
        "GBP/CAD"
    }

    if id <= 5 then
        indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)
    else
        indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", false)
    end
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local Color
local Source={};  
local Size
local transparency
local loading ={};  
local source  
local HISTORY_LOADING_ID = 1000
local dayoffset, weekoffset; 
local PipCost={}
local MMR={}
local Pair={};
local Dodaj={}; 
local Count; 
local Index={};  
local LookBack=1;
local InstrumentType;
local Value={};
local AtRisk;
local Inverse;
local Highest, High;
function getInstrumentList()
    local list = {}
    local pipcost = {}
    local mmr = {} 
	
    local count = 0
    local row, enum

    enum = core.host:findTable("offers"):enumerator()
    row = enum:next()
    while row ~= nil do
	
	    if  row.InstrumentType == InstrumentType or InstrumentType== 0 then
        count = count + 1
        list[count] = row.Instrument
        pipcost[count] = row.PipCost
		mmr[count] = row.MMR
		end
        row = enum:next()
    end

 
	 return  count,list, pipcost,mmr;
end
-- Routine
function Prepare(nameOnly)
 
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    Color = instance.parameters.Color
    Size = instance.parameters.Size  
	Type=instance.parameters.Type; 
	Inverse=instance.parameters.Inverse;
	Highest=instance.parameters.Highest;
	High=instance.parameters.High;
	InstrumentType=instance.parameters.InstrumentType;  
	
	AtRisk=instance.parameters.AtRisk;
   
	
 if Type == "MultipleCurrencyPair" then
        Count = 0
        for i = 1, 20, 1 do
            Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
            if Dodaj[i] 
			and (core.host:findTable("offers"):find("Instrument",instance.parameters:getString("Pair" .. i)).InstrumentType == InstrumentType or InstrumentType== 0 )			 
			then
                Count = Count + 1
                Pair[Count] = instance.parameters:getString("Pair" .. i)
                PipCost[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PipCost
				MMR[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).MMR
            end
        end
    elseif Type == "AllCurrencyPair" then
          Count,Pair,PipCost,MMR =getInstrumentList() 
    end

  
    local ID = 0
 
        for i = 1, Count, 1 do
          
          
                ID = ID + 1
                Source[i]  =
                    core.host:execute(
                    "getHistory",
                    HISTORY_LOADING_ID + ID,
                    Pair[i],
                    "m1" ,
                    0,
                    0,
                    true
                )
                loading[i]  = true 
            end
 
	 
	    Index={};
		local IndexIndex=0;  
 
					for i = 1, Count, 1 do
					  Index[i]=i;
					  Value[i]=win32.formatNumber( (AtRisk/MMR[i])*PipCost[i] , false, 5); 
					 end 
					 
					 
		NewIndex= BubbleSortKey(Index , #Index ); 
		Index=NewIndex;
		 
		
    instance:ownerDrawn(true)
 
    instance:initView("Profit Potential View", 0, 1, true, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
 
end
 


function BubbleSortKey(Data,columns )
 
 local Key={};
 local Temp;
 local SortFlag=true;
 
   
   for i=1, columns, 1 do
   Key[i]=Data[i];
   end
   
   

     while SortFlag do
    SortFlag=false;
   
            for i = 2, columns , 1 do
                    
					if Inverse then
						if Value [Key[i]] <  Value [Key[i-1]] then
						 SortFlag=true;  
						 Temp= Key[i];                     
						 Key[i]=Key[i-1];
						 Key[i-1]=Temp;                      
						end
                    else
					   	if Value [Key[i]] >  Value [Key[i-1]] then
						 SortFlag=true;  
						 Temp= Key[i];                     
						 Key[i]=Key[i-1];
						 Key[i-1]=Temp;                      
						end

					end
          end
   
    end
 
  return Key;
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message, message1, message2)
  
    if cookie >= HISTORY_LOADING_ID then
        local i
        local ID = 0

        for i = 1, Count, 1 do
          
                ID = ID + 1
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i]  = false
                end
            
        end

        local FLAG = false
        local Number = 0

        for i = 1, Count, 1 do
            
                if loading[i]  then
                    FLAG = true
                    Number = Number + 1
                end
            
        end

        if FLAG then
            core.host:execute("setStatus", "Loading " .. (Count - Number) .. " / " .. Count  )
        else
            core.host:execute("setStatus", "Loaded")
            for i = 0, Source[1] :size() - 1 do
                instance:addViewBar(Source[1] :date(i)) 
            end
        end

        return core.ASYNC_REDRAW 
    end
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

   local FLAG = false 

        for i = 1, Count, 1 do
            
                if loading[i]  then
                    FLAG = true 
                end
            
        end
	if FLAG then
	return;
	end
	 

    top, bottom = context:top(), context:bottom()
    left, right = context:left(), context:right()

    xGap = (right - left) / (1+1)

	
	if Highest then
	yGap = (bottom - top) / (High+1)
	else
    yGap = (bottom - top) / (#Index+1)	
	end

    if xGap > 250 then
        xGap = 250
    end
    
	if Highest then 
        for j = 1, math.min(High, #Index) , 1 do
            Calculate(context,j)
        end
	else
	        for j = 1,   #Index  , 1 do
            Calculate(context,j)
            end
	end
	
   
end


 

function Calculate(context, j )
    
    local i=1;
	
    y1 = top + (j-1) * yGap
    y2 = top + (j) * yGap 

    x1 = right  -(i + 1) * xGap
    x2 = right - (i) * xGap

    iwidth = ((xGap / 10) / 100) * Size
    iheight = (yGap / 100) * Size

    context:createFont(7, "Arial", iwidth, iheight, 0)

   

    if i == 1 then
        width, height = context:measureText(7,  Pair[Index[j]], 0) 
		 context:drawText(7, Pair[Index[j]], Color, -1, x1 + xGap,y1 + yGap, x2 + xGap, y2 + yGap, context.CENTER)
    end
	
    
	
            
			context:drawText(7, tostring(Value[Index[j]]), Color, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER) 
         
		   
 

end