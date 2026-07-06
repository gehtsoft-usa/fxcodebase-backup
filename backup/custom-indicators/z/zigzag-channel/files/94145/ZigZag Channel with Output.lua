-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60727


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag Channel");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
 
	indicator.parameters:addInteger("Period", "Period", "Period", 1);
	
	indicator.parameters:addGroup("Zig Zag Line Style");	
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addColor("UpColor", "Up Line color", "Up Line color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownColor", "Down Line color", "Down Line color", core.rgb(255, 0, 0));   	
	 indicator.parameters:addInteger("Width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LEVEL_STYLE);
	

   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;
local Period;
-- Streams block
local ZigC;
local ZagC;
local out;
local HighMap = nil;
local LowMap = nil;
local TextBuff=nil;
local AverageBuff=nil;
local pipSize;
local Flag;
local format;
local Top, Bottom;
local Width, UpColor,DownColor,Style;
-- Routine
function Prepare(nameOnly) 
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
	Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	Width = instance.parameters.Width;
	UpColor = instance.parameters.UpColor;
	DownColor = instance.parameters.DownColor;
	Style = instance.parameters.Style;
	
	 format = "%." .. 1 .. "f";

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ", " .. Period.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
    out:setWidth(instance.parameters.widthZigZag);
    out:setStyle(instance.parameters.styleZigZag);
	
	 Top = instance:addStream("Top", core.Line, name, "Top", UpColor, first);
    Top:setWidth(Width);
    Top:setStyle(Style);
	
	Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", DownColor, first);
    Bottom:setWidth(Width);
    Bottom:setStyle(Style);
	
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;

    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
	Flag=  instance:addInternalStream(0, 0);   
    pipSize=source:pipSize();

end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local peak_count = 0;

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = out:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

local lastperiod = -1;

function DeleteLabels(startBar, endBar)
 local i;
 for i=startBar,endBar,1 do
 -- TextBuff:setNoData(i);
 -- AverageBuff:setNoData(i);
  Flag[i]=0;
 end
 return;
end

function TextFormat(bars, pips)
 return "" .. math.abs(bars)+1 .. " bars, " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10 .. " pips";
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;
   Flag[period]=0;
	
	
    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1;
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0;
                    end
                end
            end
        end
        if source.low[period] == val then
            LowMap[period] = val;
        else
            LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0;
                    end
                end
            end
        end

        if source.high[period] == val then
            HighMap[period] = val;
        else
            HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(-4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end

        start = Depth;
        i = GetPeak(-3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = Peak[i];
            searchMode = SearchMode[i];
            start = i;
        end

        peak_count = peak_count - 3;

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC);
                            out:setColor(prev_peak, ZigC);
                            DeleteLabels(prev_peak+1, i);
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
							Flag[i]=-1;
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            out:setColor(prev_peak, ZagC);
                            DeleteLabels(prev_peak+1, i);
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
							Flag[i]=-1;
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    out:setColor(last_peak_i, ZagC);
                    DeleteLabels(last_peak_i+1, i);
                    --TextBuff:set(i, HighMap[i], TextFormat(i-last_peak_i, HighMap[i]-last_peak));
					Flag[i]=1;
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC);
                        out:setColor(prev_peak, ZagC);
                        DeleteLabels(prev_peak+1, i);
                       -- TextBuff:set(i, HighMap[i], TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak]));
						Flag[i]=1;
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        out:setColor(last_peak_i, ZigC);
                        DeleteLabels(last_peak_i+1, i);
                       -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
						Flag[i]=-1;
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        out:setColor(last_peak_i, ZagC);
                        DeleteLabels(last_peak_i+1, i);
                       -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
						Flag[i]=-1;
                    end
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
	
	
	--  context:createPen (1, context:convertPenStyle (Style ), Width , UpColor );   
   --context:createPen (2, context:convertPenStyle (Style ), Width , DownColor);       
 
    if period < source:size()-2 then
	return;
	end
	
	local iFirst =  first ;
    local iLast = source:size()-2 ;
      
 
	local Up={};
    local Down={};
	local Total=0;	
			
	
	    for i=  iLast,iFirst, -1 do
	   
					if  (Flag[i]== 1 or Flag[i]== -1)  then
					
					Total =Total +1;
					     if   Total > Period then
							  if Flag[i]== 1 then
							   Up[table.getn(Up) +1]= i;
							  end
							  
							   if Flag[i]== -1 then
								 Down[table.getn(Down )+1]= i;
							  end
						  end
					 
					end
					
			if Total == Period+4 then
			break;
			end
         end			
	
	   Lines (Up, Down);
	   
	   
	   
	   
end


function GetYofABCLine(X, a, c)
   return a * X + c;
end


function Lines (Up, Down)


if Up == nil
or Down==nil 
or table.getn(Up)  < 2
or  table.getn(Down)  < 2
then
return;
end


local  tx1=Up[1];	   
local tx2 =Up[2];	
local bx1 =Down[1];	   
local bx2 =Down[2];	

local ty1= source.high[Up[1]];	
local ty2= source.high[Up[2]];	

local  by1= source.low[Down[1]];	
local  by2=  source.low[Down[2]];	



local a1, c1= math2d.lineEquation (tx1, ty1, tx2, ty2);
local a2, c2= math2d.lineEquation (bx1, by1, bx2, by2);

 
 local Y1= GetYofABCLine(source:size()-1, a1, c1);
 local Y2= GetYofABCLine(source:size()-1, a2, c2);
 
 
	core.drawLine (Top, core.range(tx2, source:size()-1), ty2, tx2, Y1, source:size()-1, UpColor)
    core.drawLine (Bottom, core.range(bx2, source:size()-1), by2, bx2, Y2, source:size()-1, DownColor)	
	
	for period =tx2-1, first , -1 do
	if Top[period]~= nil then
	Top[period]= nil;
	else
	break;
	end
	
	end
	
	for period =bx2-1, first , -1 do
	if Bottom[period]~= nil then
	Bottom[period]= nil;
	else
	break;
	end
	
	end
	

end 
 
 
