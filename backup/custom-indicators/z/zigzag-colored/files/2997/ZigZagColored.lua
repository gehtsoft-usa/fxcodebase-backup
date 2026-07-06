-- Id: 1808
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1534

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("ZigZag");
    indicator:description("Helps to determine the most important price changes and turns.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "The minimum number of periods used to draw one ZigZag line", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 3);
    
	 indicator.parameters:addBoolean("Label", "Show Swing Size", "", false);
	 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("FontSize", "Label Size", "", 10);
	indicator.parameters:addColor("Zig_color", "Up Swing Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Zag_color", "Down Swing Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Label_Color", "Label Color", "", core.rgb(0, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;
local Label_Color;
local  font1;
local Count=1;
local first;
local source = nil;

-- Streams block
local Zig=nil;
local Zag=nil;
local HighMap = nil;
local LowMap = nil;

local Label;
local FontSize;
local TEMP=nil;



local dummy;
-- Routine
function Prepare(nameOnly)
    FontSize= instance.parameters.FontSize;
    Label= instance.parameters.Label;
	Label_Color= instance.parameters.Label_Color;
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	font1 = core.host:execute("createFont", "Arial",  FontSize, true, false);
    Zig = instance:addStream("Zig", core.Line, name, "Up", instance.parameters.Zig_color, first);
	Zig:setWidth(instance.parameters.width);
    Zig:setStyle(instance.parameters.style);
	Zag = instance:addStream("Zag", core.Line, name, "Down", instance.parameters.Zag_color, first);
	Zag:setWidth(instance.parameters.width);
    Zag:setStyle(instance.parameters.style);
	HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
	
	dummy = instance:addInternalStream(0, 0);
	Count=1;
	 TEMP=nil;
end

function ReleaseInstance()
    core.host:execute("deleteFont", font1);      
	  
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local peak_count = 0;

local NOW=nil;
	local LAST=nil;

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    dummy:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
	
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    dummy:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
	

end

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = dummy:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

local lastperiod = -1;

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

    if period >= Depth then
        -- fill high/low maps
        local range = core.rangeTo(period, Depth);
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = core.min(source.low, range);
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
        val = core.max(source.high, range);
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
                        
						    core.drawLine(Zig, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i);						
							if  Peak[prev_peak] > LowMap[i] then
							core.drawLine(Zag, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i);							
							end
							 TEMP=i;
							
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                           core.drawLine(Zig, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i);
						   
						 TEMP=i;
						   local Loop;
						   for Loop = last_peak_i+1, i-1,1 do
							Zag[Loop]=nil;
						
				           end 
					
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
					
					         core.drawLine(Zig, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i);		                   				
						       TEMP=i;
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then				
				
				    core.drawLine(Zig, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i);
				
				    if  last_peak > LowMap[i] then
				     core.drawLine(Zag, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i);	
					
					end
					
					 TEMP=i;
					
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
	
	if period == source:size()-2 then
	
	 core.host:execute("removeAll"); 
	
		for i= first, period, 1 do
		DRAW (i);
		end
	end
 	
end

function DRAW (period)

    
    period= period -1;
	
	
	
	local SIDE;
	
	local FLAG=false;
	
	if not Zig:hasData(period)or not Zig:hasData(period-1)  then
	return;
	end
	
	if Zig[period-1]< Zig[period] and  Zig[period] > Zig[period+1] then
	LAST= NOW;
	NOW= period;
	FLAG= true;
	SIDE = true;
	end
	
	if Zig[period-1]> Zig[period] and  Zig[period] < Zig[period+1] then
	LAST= NOW;
	NOW= period;
	FLAG= true;
	SIDE = false;
	end
	
	local TF;
	
		if Zig[period-1]< Zig[period] and   Zig[period+1] == nil then
	TEMP  = period;
	TF= true;
	end
	
	if Zig[period-1]> Zig[period] and  Zig[period+1] == nil then
	TEMP  = period;
	TF= false;
	end
	
	
	if   Label and peak_count > 1  and LAST ~= nil   and TEMP ~= nil and Zig[period]~= nil  then
	
	                     
						   
	                        Number = math.abs(Zig[TEMP] - Zig[NOW]); 						 
							 if Number ~= 0 then
							if   TF then 
							core.host:execute("drawLabel1",  source:serial(TEMP), source:date(TEMP), core.CR_CHART,Zig[TEMP]+Number/10, core.CR_CHART, core.H_Right, core.V_Top,
                            font1, Label_Color  ,  tostring(round(source:getPrecision (),(Number/source:pipSize() ))));
							else
							core.host:execute("drawLabel1",  source:serial(TEMP), source:date(TEMP), core.CR_CHART,Zig[TEMP]-Number/10, core.CR_CHART, core.H_Right, core.V_Bottom,
                            font1, Label_Color  ,  tostring(round(source:getPrecision (),(Number/source:pipSize() ))));
							end
							end
							
							
	end
	

                           	if Label and peak_count > 1  and FLAG and LAST ~= nil then
							
							 
							
							 Number = math.abs(Zig[NOW] - Zig[LAST]); 
							 
							 if SIDE  then
							 core.host:execute("drawLabel1",  source:serial(NOW), source:date(NOW), core.CR_CHART,Zig[NOW]+Number/10, core.CR_CHART, core.H_Right, core.V_Top,
                             font1, Label_Color  ,  tostring(round(source:getPrecision (),(Number/source:pipSize() ))));
							 else
							 core.host:execute("drawLabel1", source:serial(NOW), source:date(NOW), core.CR_CHART,Zig[NOW]-Number/10, core.CR_CHART, core.H_Right, core.V_Bottom,
                             font1, Label_Color  ,  tostring(round(source:getPrecision (),(Number/source:pipSize() ))));
							 end
																	
							  
							end
							
end

 

function round( idp,num)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

