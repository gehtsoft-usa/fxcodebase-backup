
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23668

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
    indicator:name("ZigZag with counter_v9");
    indicator:description("ZigZag with counts of Bars, Pips, Ticks Volumes, Swing %, Fibonacci Levels and Highest/Lowest prices");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Depth", "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
   
    indicator.parameters:addGroup("Displaying for information");
    indicator.parameters:addColor("Text_color_Top", "Top Label Text color", "Top Label Text color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Text_color_Bottom", "Bottom Label Text color", "Bottom Label Text color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TextSize", "Text size", "Text size of the label", 9);
    indicator.parameters:addDouble("V_Shift", "Vertical Label shift", "Vertical Label shift relative to the price", 0.0);
    indicator.parameters:addBoolean("LabelBars", "Bars Counting", "Select true to see the number of bars in the label and false to not see them", true);
    indicator.parameters:addBoolean("LabelPips", "Pips Counting", "Select true to see the number of pips in the label and false to not see them", true);
    indicator.parameters:addBoolean("LabelVols", "Volumes Counting", "Select true to see the volumes of ticks in the label and false to not see them", true);
    indicator.parameters:addBoolean("LabelSwing", "Swing % Calculation", "Select true to see the swing percentage in the label and false to not see it", true);
    indicator.parameters:addBoolean("LabelHLp", "Highest/Lowest Prices", "Select true to see the highest / lowest prices in the label and false to not see them", true);
    indicator.parameters:addBoolean("LabelFibo", "Fibonacci Levels", "Select true to see the Fibonacci levels in the label and false to not see them", true);

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
local TextBuff= nil;
local pipSize;
local TF_Bar = nil;
--local VolSize;		-- for counting ticks volumes : NB : the volumes are calculated with the volume of the previous candle, as the number of bars

-- Below : TODO : modify the position of labels, as for m1, m5, m30 the label is more detached from the peaks, but for TF H1, H2, H3, H4, H6, H8, the label recovers of 1 line the peak, for D1, W1, M1 it is the same but with 2 or 3 lines

local TopPos = nil;			--2;		--1;		-- to place a line from the top of candle to better seeing for function Update()
local BottomPos = nil;			--2;		--1;	-- to place a line from the bottom of candle to better seeing for function Update()
local V_Shift;

--TF_Bar = source:barSize();

-- Managing the displaying information
local DisplayBars;
local DisplayPips;
local DisplayVols;
local DisplaySwng;
local DisplayHLp;
local DisplayFibo;
local PricePrecision;

-- Routine
function Prepare(nameOnly)
	Depth = instance.parameters.Depth;
	Deviation = instance.parameters.Deviation;
	Backstep = instance.parameters.Backstep;
	source = instance.source;
	first = source:first();
	PricePrecision = source:getPrecision();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
	out:setWidth(instance.parameters.widthZigZag);
	out:setStyle(instance.parameters.styleZigZag);
	ZigC = instance.parameters.Zig_color;
	ZagC = instance.parameters.Zag_color;	

	HighMap		= instance:addInternalStream(0, 0);
	LowMap 	= instance:addInternalStream(0, 0);
	SearchMode 	= instance:addInternalStream(0, 0);
	Peak 		= instance:addInternalStream(0, 0);

	TF_Bar = source:barSize();
	  
	TextBuff_Top 	= instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Top, instance.parameters.Text_color_Top, first);
	TextBuff_Bottom 	= instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Bottom, instance.parameters.Text_color_Bottom, first);

	pipSize=source:pipSize();
	
	V_Shift = instance.parameters.V_Shift*pipSize;
	
	DisplayBars	= instance.parameters.LabelBars;
	DisplayPips	= instance.parameters.LabelPips;
	DisplayVols	= instance.parameters.LabelVols;
	DisplaySwng	= instance.parameters.LabelSwing;
	DisplayHLp	= instance.parameters.LabelHLp;
	DisplayFibo	= instance.parameters.LabelFibo;
	
	assert(not(DisplayBars==false and DisplayPips==false and DisplayVols==false and DisplaySwng==false and DisplayHLp==false and DisplayFibo==false), "At least one information must be turned on");

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
		TextBuff_Top:setNoData(i);
		TextBuff_Bottom:setNoData(i);
	end
	return;
end

function TextFormat(bars, pips, pips2, tickvol, percent1, HLprice)	-- called by lines at end of code
	-- Modified for printing text with "RETURN" & "NEW LINE" in accordance with the LUA Language ; with also TopPos and BottomPos (see function Update() below) 
	-- percent1 is the percentage returned by the following calculation : Pips / Current Close Price
	
	-- Formatting labels to be displayed
	local TextLabel = "";

	if DisplayBars then TextLabel 	= TextLabel .. "Bars: " .. math.abs(bars)+1; end
	if DisplayPips then TextLabel 	= TextLabel .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10; end
	if DisplayVols then TextLabel 	= TextLabel .. "\r\n" .. "Vols: ".. tickvol; end
	if DisplaySwng then TextLabel	= TextLabel .. "\r\n" .. percent1 .. " %"; end
	if DisplayHLp then TextLabel 	= TextLabel .. "\r\n" .. HLprice; end
	
	if DisplayFibo then
		if math.abs(pips)>math.abs(pips2) then
			--return "Bars: " .. math.abs(bars)+1 .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10 .. "\r\n" .. "Vols: ".. tickvol .. "\r\n" .. percent1 .. " %" .. "\r\n" .. HLprice;
			return TextLabel;
		else
			--return "Bars: " .. math.abs(bars)+1 .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10 .. "\r\n" .. "Vols: ".. tickvol .. "\r\n" .. percent1 .. " %" .. "\r\n" .. HLprice .. "\r\n" .. "Fibo: " .. math.floor(math.abs(pips/pips2)*1000+0.5)/1000;
			return TextLabel .. "\r\n" .. "Fibo: " .. math.floor(math.abs(pips/pips2)*1000+0.5)/1000;
		end
	else
		return TextLabel;
	end
end

function RegisterTicksVolume(from, period)
	return mathex.sum(source.volume, from, period);
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;
    
    local TicksVolume = source.volume[period]
    
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
        local pp_peak;

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
						pp_peak=GetPeak(-2);
						--TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i), "- " .. string.format("%.4f", (Peak[prev_peak]-LowMap[i])/Peak[prev_peak]*100)));	
						TextBuff_Bottom:set(i, LowMap[i]-V_Shift, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i), "- " .. string.format("%.4f", (Peak[prev_peak]-LowMap[i])/Peak[prev_peak]*100), "Lowest = " .. string.format("%5." .. PricePrecision .. "f", LowMap[i])));	
					else
						core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
						out:setColor(prev_peak, ZagC);
						DeleteLabels(prev_peak+1, i);
						pp_peak=GetPeak(-2);
						--TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i), "- " .. string.format("%.4f", (Peak[prev_peak]-LowMap[i])/Peak[prev_peak]*100)));
						TextBuff_Bottom:set(i, LowMap[i]-V_Shift, TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i], LowMap[pp_peak]-Peak[prev_peak], RegisterTicksVolume(prev_peak, i), "- " .. string.format("%.4f", (Peak[prev_peak]-LowMap[i])/Peak[prev_peak]*100), "Lowest = " .. string.format("%5." .. PricePrecision .. "f", LowMap[i])));
					end
				end
				ReplaceLastPeak(i, searchMode, last_peak);
			end
			if HighMap[i] ~= 0 and LowMap[i] == 0 then
				core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
				out:setColor(last_peak_i, ZagC);
				DeleteLabels(last_peak_i+1, i);
				pp_peak=GetPeak(-1);
				--TextBuff:set(i, HighMap[i]+TopPos, TextFormat(i-last_peak_i, HighMap[i]-last_peak, Peak[last_peak_i]-HighMap[pp_peak], RegisterTicksVolume(last_peak_i, i), "+ " .. string.format("%.4f", ((HighMap[i] / last_peak)-1)*100)));
				TextBuff_Top:set(i, HighMap[i]+V_Shift, TextFormat(i-last_peak_i, HighMap[i]-last_peak, Peak[last_peak_i]-HighMap[pp_peak], RegisterTicksVolume(last_peak_i, i), "+ " .. string.format("%.4f", ((HighMap[i] / last_peak)-1)*100), "Highest = " .. string.format("%5." .. PricePrecision .. "f", HighMap[i])));
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
						pp_peak=GetPeak(-2);
						--TextBuff:set(i, HighMap[i]+TopPos, TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak], Peak[prev_peak]-HighMap[pp_peak], RegisterTicksVolume(prev_peak, i), "+ " .. string.format("%.4f", ((HighMap[i] / Peak[prev_peak])-1)*100)));
						TextBuff_Top:set(i, HighMap[i]+V_Shift, TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak], Peak[prev_peak]-HighMap[pp_peak], RegisterTicksVolume(prev_peak, i), "+ " .. string.format("%.4f", ((HighMap[i] / Peak[prev_peak])-1)*100), "Highest = " .. string.format("%5." .. PricePrecision .. "f", HighMap[i])));
					end
					ReplaceLastPeak(i, searchMode, last_peak);
				end
				if LowMap[i] ~= 0 and HighMap[i] == 0 then
					if  last_peak > LowMap[i] then
						core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
						out:setColor(last_peak_i, ZigC);
						DeleteLabels(last_peak_i+1, i);
						pp_peak=GetPeak(-1);
						--TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i), "- " .. string.format("%.4f", (last_peak-LowMap[i])/last_peak*100)));
						TextBuff_Bottom:set(i, LowMap[i]-V_Shift, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i), "- " .. string.format("%.4f", (last_peak-LowMap[i])/last_peak*100), "Lowest = " .. string.format("%5." .. PricePrecision .. "f", LowMap[i])));
					else
						core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
						out:setColor(last_peak_i, ZagC);
						DeleteLabels(last_peak_i+1, i);
						pp_peak=GetPeak(-1);
						--TextBuff:set(i, LowMap[i]-BottomPos, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i), "- " .. string.format("%.4f", (last_peak-LowMap[i])/last_peak*100)));
						TextBuff_Bottom:set(i, LowMap[i]-V_Shift, TextFormat(i-last_peak_i, last_peak-LowMap[i], LowMap[pp_peak]-Peak[last_peak_i], RegisterTicksVolume(last_peak_i, i), "- " .. string.format("%.4f", (last_peak-LowMap[i])/last_peak*100), "Lowest = " .. string.format("%5." .. PricePrecision .. "f", LowMap[i])));
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
end


