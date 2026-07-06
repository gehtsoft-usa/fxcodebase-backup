-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71257

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

-- Indicator profile initialization routine
function Init()
    indicator:name("ZIG BAR COUNT")
    indicator:description(" ")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
	
	 indicator.parameters:addDouble("Zone", "Confirmation Zone (in pips)", "", 10)
	
    indicator.parameters:addInteger(
        "Depth",
        "Depth",
        "the minimal amount of bars where there will not be the second maximum",
        12
    )
    indicator.parameters:addInteger(
        "Deviation",
        "Deviation",
        "Distance in pips to eliminate the second maximum in the last Depth periods",
        5
    )
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

   indicator.parameters:addInteger("Steps", "Steps", "Steps", 20)

    indicator.parameters:addGroup("Zig Zag Line Style")
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Zone Style")
    indicator.parameters:addColor("up_color", "Up Line Color", "Line Color", core.rgb(255, 0, 0)) 
	indicator.parameters:addColor("down_color", "Down Line Color", "Line Color", core.rgb(0, 255, 0)) 
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Label Style")
	indicator.parameters:addInteger("Size", "Font Size", "Font Size",20)
	 indicator.parameters:addColor("Font_Color", "Font Color", "Font Color", core.COLOR_LABEL ) 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local first
local source = nil
--local Period
-- Streams block
local ZigC
local ZagC
local out
local HighMap = nil
local LowMap = nil
local TextBuff = nil
local AverageBuff = nil
local pipSize
local Flag
local format

local  Color;

local UpDown; 
local Total;
local Steps;
local transparency;
local Zone;
local Last;
local Size;
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep

    source = instance.source
    first = source:first()
	
	
	Zone = instance.parameters.Zone*source:pipSize();
    Size= instance.parameters.Size;
    
	
	Steps = instance.parameters.Steps;

    format = "%." .. 1 .. "f"

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep   .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)
    ZigC = instance.parameters.Zig_color
    ZagC = instance.parameters.Zag_color

    HighMap = instance:addInternalStream(0, 0)
    LowMap = instance:addInternalStream(0, 0)
    SearchMode = instance:addInternalStream(0, 0)
    Peak = instance:addInternalStream(0, 0)
    Flag = instance:addInternalStream(0, 0)
    pipSize = source:pipSize()

    instance:ownerDrawn(true)
end

local searchBoth = 0
local searchPeak = 1
local searchLawn = -1
local lastlow = nil
local lashhigh = nil

-- optimization hint
local peak_count = 0

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1
    out:setBookmark(peak_count, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

function GetPeak(offset)
    local peak
    peak = peak_count + offset
    if peak < 1 then
        return -1
    end
    peak = out:getBookmark(peak)
    if peak < 0 then
        return -1
    end
    return peak
end

local lastperiod = -1

function DeleteLabels(startBar, endBar)
    local i
    for i = startBar, endBar, 1 do
        -- TextBuff:setNoData(i);
        -- AverageBuff:setNoData(i);
        Flag[i] = 0
    end
    return
end

function TextFormat(bars, pips)
    return "" .. math.abs(bars) + 1 .. " bars, " .. math.floor(math.abs(pips) / pipSize * 10 + 0.5) / 10 .. " pips"
end
 
	
function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1
    Flag[period] = 0

    if period == lastperiod then
        return
    end

    if period < lastperiod or period <= first then
        lastlow = nil
        lasthigh = nil
        peak_count = 0
    end

    lastperiod = period

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1
        local val
        local i
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period)
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lastlow = val
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0
                    end
                end
            end
        end
        if source.low[period] == val then
            LowMap[period] = val
        else
            LowMap[period] = 0
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period)
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lasthigh = val
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0
                    end
                end
            end
        end

        if source.high[period] == val then
            HighMap[period] = val
        else
            HighMap[period] = 0
        end

        local start
        local last_peak
        local last_peak_i
        local prev_peak
        local searchMode = searchBoth

        i = GetPeak(-4)
        if i == -1 then
            prev_peak = nil
        else
            prev_peak = i
        end

        start = Depth
        i = GetPeak(-3)
        if i == -1 then
            last_peak_i = nil
            last_peak = nil
        else
            last_peak_i = i
            last_peak = Peak[i]
            searchMode = SearchMode[i]
            start = i
        end

        peak_count = peak_count - 3

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = HighMap[i]
                    searchMode = searchLawn
                    RegisterPeak(i, searchMode, last_peak)
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = LowMap[i]
                    searchMode = searchPeak
                    RegisterPeak(i, searchMode, last_peak)
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC)
                            out:setColor(prev_peak, ZigC)
                            DeleteLabels(prev_peak + 1, i)
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
                            Flag[i] = -1
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC)
                            out:setColor(prev_peak, ZagC)
                            DeleteLabels(prev_peak + 1, i)
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
                            Flag[i] = -1
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak)
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC)
                    out:setColor(last_peak_i, ZagC)
                    DeleteLabels(last_peak_i + 1, i)
                    --TextBuff:set(i, HighMap[i], TextFormat(i-last_peak_i, HighMap[i]-last_peak));
                    Flag[i] = 1
                    prev_peak = last_peak_i
                    last_peak = HighMap[i]
                    last_peak_i = i
                    searchMode = searchLawn
                    RegisterPeak(i, searchMode, last_peak)
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC)
                        out:setColor(prev_peak, ZagC)
                        DeleteLabels(prev_peak + 1, i)
                        -- TextBuff:set(i, HighMap[i], TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak]));
                        Flag[i] = 1
                    end
                    ReplaceLastPeak(i, searchMode, last_peak)
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC)
                        out:setColor(last_peak_i, ZigC)
                        DeleteLabels(last_peak_i + 1, i)
                        -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
                        Flag[i] = -1
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC)
                        out:setColor(last_peak_i, ZagC)
                        DeleteLabels(last_peak_i + 1, i)
                        -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
                        Flag[i] = -1
                    end
                    prev_peak = last_peak_i
                    last_peak = LowMap[i]
                    last_peak_i = i
                    searchMode = searchPeak
                    RegisterPeak(i, searchMode, last_peak)
                end
            end
        end
    end
 	
 
	
	
end



local Init = true
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

    if Init then
        context:createPen (1, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.up_color)
		 context:createPen (3, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.down_color)
        context:createFont (2, "Courier", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		Init = false
    end
	

     local iFirst = first
    local iLast = source:size() - 2

 
	UpDown = {};
    Total = 0

    for i = iLast, iFirst, -1 do
  
           
           
                if Flag[i] == 1 
				or Flag[i] == -1 
				then				
				Total = Total + 1				
				UpDown[table.getn(UpDown) + 1] = i
                end
				
			 

        if Total > Steps then
            break
        end
    end 
	

	
	local Color;
 
	
	
	if table.getn(UpDown)  < 2
	then
	return;
	end 
	
	
    Last=0;
    
	for i= table.getn(UpDown),2, -1  do
	
 
 
	
	if  out[UpDown[i-2]]  ~= nil 
	and out[UpDown[i]]  ~= nil 
	then
        
		
		if UpDown[i] > Last then
		
			if source.high[UpDown[i]]== out[UpDown[i]]
			and  (out[UpDown[i]]+Zone)>=  (out[UpDown[i-2]])
			then 
			Next (i,context ); 
			end
		 
		
			if source.low[UpDown[i]]== out[UpDown[i]]
			and  (out[UpDown[i]]+Zone)<=  (out[UpDown[i-2]])
			then 
			Next (i,context); 
			end
		end
	
    end	
		 
	
 
	end
	
	
	 

    
end


function Next (i,context)
local InternalLast= nil;
local A=0;


		if source.high[UpDown[i]]== out[UpDown[i]] 
		then 
		
		A=1;

			for period= UpDown[i], source:size()-1 ,1 do
				if source.high[period]>= (source.high[UpDown[i]] +Zone) 
				
				then
				InternalLast=period;
				break;
				end			
			end		
			
			if InternalLast~= nil then	
			for period= UpDown[i-1], source:size()-1 ,1 do
			
				if  source.low[period]  <= (source.low[UpDown[i-1]] -Zone)  then
				InternalLast=math.min(InternalLast, period);
				break;
				end
			end
			end
		 
		end
		
		
		if source.low[UpDown[i]]== out[UpDown[i]]
		then 
		A=-1;
	       	
			for period= UpDown[i], source:size()-1 ,1 do
			
			   if source.low[period]<= (source.low[UpDown[i]] -Zone ) 
				then
				InternalLast=period;
				break;
				end
				
			end	
			
		
			if InternalLast~= nil then	
			for period= UpDown[i-1], source:size()-1 ,1 do
			
				if source.high[period]>= (source.high[UpDown[i-1]] +Zone)   then
				InternalLast=math.min(InternalLast, period);
				break;
				end
			end
			end
			
		end
	
	if InternalLast== nil then
	return;
	end	
	
	
	x1, x, x = context:positionOfBar (UpDown[i]);
	 x2, x, x = context:positionOfBar (InternalLast);		
  
    visible, y= context:pointOfPrice (out[UpDown[i]]);
	context:drawLine (1, x1, y, x2, y);
	
	visible, y= context:pointOfPrice (out[UpDown[i]]+Zone);
	context:drawLine (1, x1, y, x2, y);

		
	
    local text=tostring(InternalLast-UpDown[i]);
    width, height = context:measureText (2, text, 0)
	
	if A==1 then
    context:drawText (2, text, instance.parameters.Font_Color, -1, x1-width/2, y-height, x1+width/2, y, 0)
	else
	context:drawText (2, text, instance.parameters.Font_Color, -1, x1-width/2, y, x1+width/2, y+height, 0)
	end
	
	Last=InternalLast;
	
	
	visible, y= context:pointOfPrice (out[UpDown[i-1]]);
	context:drawLine (3, x1, y, x2, y);
    
	visible, y= context:pointOfPrice (out[UpDown[i-1]]-Zone);
	context:drawLine (3, x1, y, x2, y);
end


	    


 