-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71325

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
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |     
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Period Overview")
    indicator:description("Period Overview")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)
	
    indicator.parameters:addGroup("Filter") 	
	 indicator.parameters:addBoolean("Reversal", "Reversal Only", "", true)
	indicator.parameters:addBoolean("Sort", "Sort", "", true)
    indicator.parameters:addBoolean("Inverse", "Inverse Sort", "", false) 	
	indicator.parameters:addBoolean("CutOff", "CutOff", "", true)
    indicator.parameters:addInteger("CutOffValue", "CutOff Value", "", 50, 0,100)
    indicator.parameters:addGroup("Calculation") 
    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false)
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK)
	
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
	
	indicator.parameters:addString("TF" , "Time Frame ", "","D1");
    indicator.parameters:setFlag("TF" , core.FLAG_PERIODS);
	

        indicator.parameters:addInteger("Period", "ATR Period", "Period", 14)
    indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 5)
	
    indicator.parameters:addString("Method", "Method", "Method" , "ATR");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "ATR", "ATR" , "ATR");

	
    indicator.parameters:addGroup("Instruments")	
	for i= 1 , 20, 1 do
	Add(i);
	end

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
    indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255)) 

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
local ATR={}; 
local Size
local transparency
local loading ={};  
local source  
local Up, Down, Neutral
local minusX, minusY  
local Instrument; 
local LookBack; 
--local Status = {}
local Year;
local HISTORY_LOADING_ID = 1000
local dayoffset, weekoffset;
local CurrentData;
local Method;
local Point={}
local Pair={};
local Dodaj={};
local TF;
local Count;
local LocalCount;
local Period;
local Reversal;
local Index={};
local MaxValue;
local CutOffValue, CutOff,Sort,Inverse;
local CaclulateValue;
local InstrumentType;
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
 
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral 
	
	TF=instance.parameters.TF;
	Type=instance.parameters.Type;
	Period=instance.parameters.Period; 
  
  
    Instrument = instance.parameters.Instrument;
    LookBack = instance.parameters.LookBack;
	Method= instance.parameters.Method;
    Reversal= instance.parameters.Reversal;
    CutOffValue= instance.parameters.CutOffValue;
	CutOff= instance.parameters.CutOff;
	Sort= instance.parameters.Sort;
    Inverse= instance.parameters.Inverse;
	InstrumentType= instance.parameters.InstrumentType;
	
 if Type == "MultipleCurrencyPair" then
        Count = 0
        for i = 1, 20, 1 do
            Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
            if Dodaj[i] 
			and (core.host:findTable("offers"):find("Instrument",instance.parameters:getString("Pair" .. i)).InstrumentType == InstrumentType or InstrumentType== 0 )
			then
                Count = Count + 1
                Pair[Count] = instance.parameters:getString("Pair" .. i)
                Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
            end
        end
    elseif Type == "AllCurrencyPair" then
        Pair, Count, Point = getInstrumentList()
    end

  
    local ID = 0
 
        for i = 1, Count, 1 do
          
          
                ID = ID + 1
                Source[i]  =
                    core.host:execute(
                    "getHistory",
                    HISTORY_LOADING_ID + ID,
                    Pair[i],
                    TF ,
                    0,
                    0,
                    instance.parameters.bidask
                )
                loading[i]  = true
                ATR[i]  = core.indicators:create("ATR", Source[i] , Period)
            end
        
    
       
   -- local date = core.dateToTable(core.now() );
   -- Year= date.year; 
   -- Month= date.month;       
  --  CurrentData= core.datetime (Year, Month, 28, 1, 1, 1);	
	
    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView("Period Overview", 0, 1, instance.parameters.bidask, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
	
	
    core.host:execute ("setTimer", 1, 5);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function getInstrumentList()
    local list = {}
    local point = {}

    local count = 0
    local row, enum

    enum = core.host:findTable("offers"):enumerator()
    row = enum:next()
    while row ~= nil do
	
	    if  row.InstrumentType == InstrumentType or InstrumentType== 0   then
        count = count + 1
        list[count] = row.Instrument
        point[count] = row.PointSize
		end
        row = enum:next()
    end

    return list, count, point
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
                for i = 1, Count, 1 do
           
                    ATR[i]:update(core.UpdateLast) 
            
                end
            end
        end

        return core.ASYNC_REDRAW
    
	end
	if cookie == 999 or cookie == 1 then
       local Loading = false
	   
	    Index={};
		local IndexIndex=0; 
		local MaxValue=0;
		
					for i = 1, Count, 1 do
					
					 ATR[i]:update(core.UpdateLast) 
					 local p =  Source[i]:size()-1;           
							   
								
								 if Reversal then
								      if p> 1 then
											  if (Source[i].close[p]  < Source[i].open[p] and Source[i].close[p-1]  > Source[i].open[p-1] )
											  or (Source[i].close[p]  > Source[i].open[p] and Source[i].close[p-1]  < Source[i].open[p-1] )
											  then
											  IndexIndex=IndexIndex+1;
											   Index[IndexIndex]=i;
											   end
										end	    
									else
									Index[i]=i;
									end
									
						
					 end
					
					
						 if CutOff then	
										CaclulateValue={}  ;
										for i = 1, #Index, 1 do
										
										
										 
												 
												
												 local p =  Source[Index[i]]:size()-1;    
													if Method== "Pips" then
													CaclulateValue[Index[i]] = (Source[Index[i]].close[p]  - Source[Index[i]].open[p])/Point[Index[i]]; 	
													elseif Method== "Percentage" then
													CaclulateValue[Index[i]] = (Source[Index[i]].close[p]  - Source[Index[i]].open[p])/(Source[Index[i]].open[p] /100); 
													else
													CaclulateValue[Index[i]] = (Source[Index[i]].close[p]  - Source[Index[i]].open[p])/(ATR[Index[i]].DATA[p] ); 	
													end
													
													MaxValue=math.max(MaxValue,math.abs(CaclulateValue[Index[i]]));
													
											end	             
							 
						
					
								  local IndexIndex=0;
								   local SecondIndex={};
									  for i = 1, #Index, 1 do
									  if math.abs(CaclulateValue[Index[i]]) > (MaxValue/100)*CutOffValue then
									  IndexIndex=IndexIndex+1;
									  SecondIndex[IndexIndex]=Index[i]
									  end	
									  end
							  Index=SecondIndex;
					 
				   end
				   
				   if Sort then
				     local SecondIndex={};
					 
				      SecondIndex= BubbleSortKey(Index , #Index );
					  Index=SecondIndex;
					  
					 
				   end
    end
	
 
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
						if CaclulateValue [Key[i]] <  CaclulateValue [Key[i-1]] then
						 SortFlag=true;  
						 Temp= Key[i];                     
						 Key[i]=Key[i-1];
						 Key[i-1]=Temp;                      
						end
                    else
					   	if CaclulateValue [Key[i]] >  CaclulateValue [Key[i-1]] then
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

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    --shoudn't be called
end

local init = false
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
	
	
    if not init then
        context:createPen(11, context.SOLID, 1, Up)
        context:createSolidBrush(12, Up)

        context:createPen(21, context.SOLID, 1, Down)
        context:createSolidBrush(22, Down)

        init = true
    end

    top, bottom = context:top(), context:bottom()
    left, right = context:left(), context:right()

    xGap = (right - left) / (LookBack+1)
    yGap = (bottom - top) / (#Index+1)

    if xGap > 250 then
        xGap = 250
    end
    
    for i = 1, LookBack, 1 do
        for j = 1, #Index , 1 do
            Calculate(context, i, j)
        end
    end
end


 

function Calculate(context, i, j)
   
   
  -- local Date= core.datetime (Year-i+1, j, 1, 1, 1, 1);	  
 --  local Candle = core.getcandle("M1", Date, dayoffset, weekoffset); 
   local p =  Source[Index[j]]:size()-1 -i+1;
  
    y1 = top + (j-1) * yGap
    y2 = top + (j) * yGap 

    x1 = right  -(i + 1) * xGap
    x2 = right - (i) * xGap

    iwidth = ((xGap / 10) / 100) * Size
    iheight = (yGap / 100) * Size

    context:createFont(7, "Arial", iwidth, iheight, 0)

    if j == 1 then
        width, height = context:measureText(7, tostring( -i+1  .."."  ), context.CENTER)
        context:drawText(7, tostring( -i+1 .."."), Color, -1, x1  , y1,  x2  , y2, context.CENTER, 0)
    end

    if i == 1 then
        width, height = context:measureText(7,  Pair[Index[j]], 0) 
		 context:drawText(7, Pair[Index[j]], Color, -1, x1 + xGap,y1 + yGap, x2 + xGap, y2 + yGap, context.CENTER)
    end
	
    if Method== "Pips" then
	Value = (Source[Index[j]].close[p]  - Source[Index[j]].open[p])/Point[Index[i]]; 	
	elseif Method== "Percentage" then
    Value = (Source[Index[j]].close[p]  - Source[Index[j]].open[p])/(Source[Index[j]].open[p] /100); 
	else
    Value = (Source[Index[j]].close[p]  - Source[Index[j]].open[p])/(ATR[Index[j]].DATA[p] ); 	
	end
	
    Value= string.format("%." .. 2 .. "f", Value);
	
    if p> 0 and  Source[Index[j]].close:hasData(p)   then
		   if  Source[Index[j]].close[p]  > Source[Index[j]].open[p]  then
			context:drawText(7, Value, Up, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
		   elseif  Source[Index[j]].close[p]  < Source[Index[j]].open[p]  then
			context:drawText(7, Value, Down, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
			else
			context:drawText(7, Value, Neutral, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
	 
		   end
    end

end