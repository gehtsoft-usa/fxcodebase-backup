-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70552

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
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("Weekly Overview")
	indicator:description("Weekly Overview")
	indicator:requiredSource(core.Bar)
	indicator:type(core.View)

	indicator.parameters:addGroup("Calculation")
	
	 indicator.parameters:addString("TF", "Time frame", "", "W1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addDouble("Exuberance_Multiple", "Exuberance Multiple", "", 1);
	indicator.parameters:addInteger("Cutoff", "Cutoff Level", "", 0);

	
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector","Multiple currency pair");
	indicator.parameters:addStringAlternative(
		"Type",
		"Multiple currency pair",
		"Multiple currency pair",
		"Multiple currency pair"
	)
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "All currency pair")

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
	
	
	indicator.parameters:addString("Base", "Base", "Base" , "All");
    indicator.parameters:addStringAlternative("Base", "All", "All" , "All");	
    indicator.parameters:addStringAlternative("Base", "USD", "USD" , "USD");
	
    indicator.parameters:addStringAlternative("Base", "EUR", "EUR" , "EUR");
	indicator.parameters:addStringAlternative("Base", "JPY", "JPY" , "JPY");
    indicator.parameters:addStringAlternative("Base", "GBP", "GBP" , "GBP");
	indicator.parameters:addStringAlternative("Base", "CHF", "CHF" , "CHF");
	
	indicator.parameters:addStringAlternative("Base", "AUD", "AUD" , "AUD");
	indicator.parameters:addStringAlternative("Base", "NZD", "NZD" , "NZD");
	indicator.parameters:addStringAlternative("Base", "CAD", "CAD" , "CAD");
	

	for i = 1, 20, 1 do
		indicator.parameters:addGroup(i .. ". Currency Pair ")
		Add(i)
	end

 

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("UpColor", "Up Color", "Label Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Down Color", "Label Color", core.rgb(255, 0, 0))
	indicator.parameters:addColor("NeutralColor", "Neutral Color", "Neutral Color", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Exuberance_Color", "Exuberance Color", "Exuberance Color", core.rgb(0, 0, 255))
 
--	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false)
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100)
	--indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 60, 0, 100)
end

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
end


function Add(id)
	local Init = {
		"NGAS",
		"UKOil",
		"USOil",
		"SOYF",
		"WHEATF",
		"CORNF",
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


function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


local InstrumentType;
local Cutoff;
local TF;  
local Color
local Source = {};
local transparency
local loading = {}
local source
local Pair = {}
local Count
local Type
local Dodaj = {}
local Point = {}
local UpColor, DownColor, NeutralColor
local Min={};
local Max={};
local Exuberance={};
local Delta={};
local Exuberance_Multiple;
local Base;
local pauto =  "(%a%a%a)/(%a%a%a)";
local Weight={};
function Prepare(nameOnly)
	local name = profile:id()
	instance:name(name)
	if (nameOnly) then
		return
	end
	instance:initView("Weekly Overview", 2, 0.01, true, true)

	Exuberance_Multiple = instance.parameters.Exuberance_Multiple
	Mode = instance.parameters.Mode
	TF = instance.parameters.TF
	Cutoff= instance.parameters.Cutoff;
	InstrumentType = instance.parameters.InstrumentType;		
	Base= instance.parameters.Base;
	
	Type = instance.parameters.Type
	
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor
	NeutralColor = instance.parameters.NeutralColor
 
	source = instance.source


			
		
		
	if Type == "Multiple currency pair" then
		Count = 0
		for i = 1, 20, 1 do
		    crncy1, crncy2 = string.match( instance.parameters:getString("Pair" .. i), pauto); 
			Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
			if Dodaj[i]
			and (core.host:findTable("offers"):find("Instrument",instance.parameters:getString("Pair" .. i)).InstrumentType == InstrumentType or InstrumentType== 0 )			
            and ( Base == "All" or  crncy1 ==Base    or  crncy2 ==Base )                 			
			then
				Count = Count + 1
				Pair[Count] = instance.parameters:getString("Pair" .. i)
				Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
			end
		end
	elseif Type == "All currency pair" then
		Pair, Count, Point = getInstrumentList()
	
	end

 
 

	local ID = 0
	Color = instance.parameters.Color

	for i = 1, Count, 1 do
	 

		 
			ID = ID + 1

			Source[i] = core.host:execute("getHistory1", 20000 + ID, Pair[i], TF , 60, 0, true)
			           
					   


	
			loading[i]  = true

		    Exuberance[i] = {};
		    Delta[i] = {};
	end
	open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
   
	instance:ownerDrawn(true)
	core.host:execute("setTimer", 1, 1)
end

function getInstrumentList()
    local list = {}
    local point = {}

    local count = 0
    local row, enum
	

 

    enum = core.host:findTable("offers"):enumerator()
    row = enum:next()
    while row ~= nil do
	    if  row.InstrumentType == InstrumentType or InstrumentType== 0 then
		
		crncy1, crncy2 = string.match(row.Instrument, pauto);
		if Base == "All" or  crncy1 ==Base    or  crncy2 ==Base then  				  
			count = count + 1
			list[count] = row.Instrument
			point[count] = row.PointSize
			end
		end
        row = enum:next()
    end

    return list, count, point
end


function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

local added = false;
function AsyncOperationFinished(cookie)
	if not added then
		instance:addViewBar(core.host:execute("getServerTime"));
		core.host:trace("test");
		added = true;
	end
	local i
	local ID = 0
	for i = 1, Count, 1 do
		 
			ID = ID + 1
			if cookie == (20000 + ID) then
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
	
	local period;

 	if not FLAG and cookie == 1 then
		for i = 1, Count, 1 do
	   
		    period= Source[i]:size() - 1;
			
			if period > 53 then
		    local min, max, minpos, maxpos= mathex.minmax (Source[i], period-53, period);
			
			Min[i]=minpos;
			Max[i]=maxpos;
			
			
			 for j= 1, 53, 1 do
			 
			 period= Source[i].close:size() - 1-53+j;
			 
					 if   math.abs(Source[i].close[period]- Source[i].open[period])>  (Exuberance_Multiple *math.abs(Source[i].close[period-1]- Source[i].open[period-1])) then
					 Exuberance[i][period]=1;
					 else
					 Exuberance[i][period]=0;
					 end
					 
					Value=  math.abs(Source[i].close[period]- Source[i].open[period])/  ( math.abs(Source[i].close[period-1]- Source[i].open[period-1]))
					 
					
					
					 Delta[i][j]=  round(Value, 0);
				
				     
				
					 
             end			 
			
			else
			Min[i]=nil;
			Max[i]=nil; 
			end
		end
	end 

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (Count  - Number) .. " / " .. Count  )
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)




end

local init = false
local iwidth, iheight;
function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Loading = false

	for i = 1, Count, 1 do
		 
			if loading[i]  then
				Loading = true
			end
		 
	end

	if Loading then
		return
	end
	
	top, bottom = context:top(), context:bottom()
	left, right = context:left(), context:right()

	xGap = (right - left) / (60)
	yGap = (bottom - top) / (Count + 2)
	

	if not init then
		 
		context:createSolidBrush(1, UpColor);
		context:createSolidBrush(2, DownColor);
		context:createSolidBrush(3, NeutralColor);
		
		context:createPen (11, context.SOLID, 2, UpColor)
		context:createPen (12, context.SOLID, 2, DownColor)
		context:createPen (13, context.SOLID, 2, NeutralColor)
        
		
		context:createPen (10, context.SOLID, 2, instance.parameters.Exuberance_Color)
	

		transparency = context:convertTransparency(instance.parameters.transparency)

		init = true
	end
	
 

	context:createFont(7, "Arial", xGap/3, yGap/3, context.ITALIC)
	

	

	for i = 1, Count, 1 do
		   
		   
		    for j= 1, 53, 1 do
			Calculate(context, i,j )
		    end
	end
end

function Calculate(context, i ,j )


    

     local period= Source[i].close:size() - 1-53+j;

	if  not Source[i].close:hasData(period)
	or Min[i]== nil
	or Max[i]==nil
 	then
		return;
	end
 
    
	local Shift=xGap*6;

	y1 = top + (i-1) * yGap 
	y2 = top +  i * yGap 

	x1 = left + (j - 1) * xGap
	x2 = left + j * xGap


    if j == 1 then
	width, height = context:measureText(7, Pair[i], 0)
	context:drawText(7, Pair[i], Color, -1, x1, y1, x2+Shift, y2, 0)
		
	end	
 
	


	if i == Count then
		width, height = context:measureText(7, j, 0)
		context:drawText(7, j, Color, -1, x1+Shift, y1+yGap, x2+Shift, y2+yGap, 0)
	end
	
       		
		if Exuberance[i][period] == 1 then
		Edge=10;
		else
		Edge=-1;
		end
 
 
 
        if Source[i].close[period]> Source[i].open[period] then
		context:drawRectangle(Edge, 1, x1+Shift, y1, x2+Shift, y2-yGap/2, transparency)
		elseif Source[i].close[period]< Source[i].open[period] then
		context:drawRectangle(Edge, 2, x1+Shift, y1, x2+Shift, y2-yGap/2, transparency)
		else
		context:drawRectangle(Edge, 3, x1+Shift, y1, x2+Shift, y2-yGap/2, transparency)
		end
		

        if Min[i]== period then			
		 	width, height = context:measureText(7, "B", 0)
			context:drawText(7, "B", Color, -1, x1+Shift, y1 , x2+Shift,  y2-yGap/2, 0)		
		elseif Max[i]== period then
			width, height = context:measureText(7, "T", 0)
			context:drawText(7, "T", Color, -1, x1+Shift, y1 , x2+Shift,  y2-yGap/2, 0)		
		end
		
       
 
        	-- if Delta[i][j] >= 10 then					 
				 
			if Delta[i][j] > 10 then			
			 width, height = context:measureText(7, "X", 0)
			context:drawText(7,   "X", Color, -1,  x1+Shift, y2-yGap/2 , x2+Shift,  y2 , 0)	
			elseif Delta[i][j] > Cutoff then					 
            width, height = context:measureText(7, tostring(Delta[i][j]), 0)
			context:drawText(7,   tostring(Delta[i][j]), Color, -1,  x1+Shift, y2-yGap/2 , x2+Shift,  y2 , 0)		
            end
end
