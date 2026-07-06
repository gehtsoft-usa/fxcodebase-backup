-- Id: 14083

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62167

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Zig Zag Range Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
	indicator.parameters:addString("Type", "Calculation Type", "", "ZigZag");
    indicator.parameters:addStringAlternative("Type", "ZigZag", "", "ZigZag");
    indicator.parameters:addStringAlternative("Type", "Price", "", "Price");
 
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil; 
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
local Range;
local Type;
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep; 
	Type = instance.parameters.Type;
    source = instance.source;
    first = source:first();
	
	 format = "%." .. 1 .. "f";

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Range = instance:addStream("Range", core.Bar, name, "Range", instance.parameters.Zig_color, first); 
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
	out=   instance:addInternalStream(0, 0); 
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
	
	 local P2, P1= Calculate(period);
	 
	 if P1== false or P2== false then
	 return;
	 end
	 
	 
	 if Type == "ZigZag" then
	 Last=P2;
	 else
	 Last = period;
	 end
	
		 for period = P1, Last, 1 do
		      if Type =="ZigZag" then
		   	  Range[period]=(out[period] -out[P1])/source:pipSize();
			  else
			   Range[period]=(source.close[period] -out[P1])/source:pipSize();
              end			  
			  
			  if Range[period] > 0 then
			  Range:setColor(period, ZigC);
			  else
			  Range:setColor(period, ZagC);
			  end
		 end
 
    
end
 



function Calculate(period)
 
 
local Return1= false;
local Return2= false;

for i = period, first, -1 do	 

	if (Flag[i]== 1 or Flag[i]== -1) then
	     if Return1 == false then
		 Return1=i;	
		 else 
		  Return2=i;
		 end
		 
		if Return1 ~= false and Return2 ~= false then
		break;
		end	
	end		
 
end 

    
		return Return1, Return2;


end
