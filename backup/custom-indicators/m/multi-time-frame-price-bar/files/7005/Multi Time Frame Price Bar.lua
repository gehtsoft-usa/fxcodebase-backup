-- Id: 2720
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3021

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

local TIMEFRAMES={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4","H6", "H8", "D1", "W1", "M1"};

function Init()
    indicator:name("Multi Time Frame Price Bar");
    indicator:description("Multi Time Frame Price Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
		indicator.parameters:addString("Type", "Type", "", "Relativ");
	 indicator.parameters:addStringAlternative("Type", "Relativ", "", "Relativ");	
    indicator.parameters:addStringAlternative("Type", "Absolute", "", "Absolute");
   
   
    indicator.parameters:addGroup("Show Time Frame");
    local i;
    for i= 1, 13, 1 do	
	indicator.parameters:addBoolean("ON"..i, TIMEFRAMES[i], "", true);
	end

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local ON = nil;
local HN = nil;
local LN = nil;
local CN = nil;
local OP = nil;
local HP = nil;
local LP = nil;
local CP = nil;

local Type;

local ONOFF={};

local day_offset, week_offset;
local dummy;
local stream;
local host;

-- Routine
 function Prepare(nameOnly)     
    source = instance.source;
    first = source:first();
	Type=instance.parameters.Type; 

    local i;
    for i= 1, 13, 1 do	 
	ONOFF[i]=instance.parameters:getBoolean ("ON"..i);
    end	
	
	 host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    OP = instance:addStream("OP", core.Line, name .. ".OP", "Open", core.rgb(0, 255, 0), first);
    OP:setPrecision(math.max(2, instance.source:getPrecision()));
    HP = instance:addStream("HP", core.Line, name .. ".HP", "High", core.rgb(0, 255, 0), first);
    HP:setPrecision(math.max(2, instance.source:getPrecision()));
    LP = instance:addStream("LP", core.Line, name .. ".LP", "Low", core.rgb(0, 255, 0), first);
    LP:setPrecision(math.max(2, instance.source:getPrecision()));
    CP = instance:addStream("CP", core.Line, name .. ".CP", "Close", core.rgb(0, 255, 0), first);
    CP:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("", "", OP, HP, LP, CP);
	
    ON = instance:addStream("ON", core.Line, name .. ".ON", "Open", core.rgb(255, 0, 0), first);
    ON:setPrecision(math.max(2, instance.source:getPrecision()));
    HN = instance:addStream("HN", core.Line, name .. ".HN", "High", core.rgb(255, 0, 0), first);
    HN:setPrecision(math.max(2, instance.source:getPrecision()));
    LN = instance:addStream("LN", core.Line, name .. ".LN", "Low", core.rgb(255, 0, 0), first);
    LN:setPrecision(math.max(2, instance.source:getPrecision()));
    CN = instance:addStream("CN", core.Line, name .. ".CN", "Close", core.rgb(255, 0, 0), first);
    CN:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("", "", ON, HN, LN, CN);
	
	
	
	 dummy = instance:addInternalStream(0, 0);
end

local Lock=nil;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first+ 14 or not source:hasData(period) then
	return;
	end
	
	
	                    ON[period-14] = nil;
						HN[period-14] = nil;
						LN[period-14] = nil;
						CN[period-14] = nil;
						
						 OP[period-14] = nil;
						HP[period-14] = nil;
						LP[period-14] = nil;
						CP[period-14] = nil;
	
	if period ~=  source:size()-1 then
	return;
	end
		
			local i;
			local max=0;
			
			if stream == nil then  
			
			stream={};
			
				for i = 1, 13 , 1 do	

                    if ONOFF[i] then				
						stream[i] = registerStream(i, TIMEFRAMES[i],0);			  
					end
				end		
			end
			
			
			
			for i = 1, 13 , 1 do	
			
			if ONOFF[i] then
			if stream[i]:hasData(stream[i]:size()-1) then
		  	
			
			
					
					if Type == "Relativ" then 
									
									local  BarH = stream[i].high[stream[i]:size()-1]-stream[i].open[stream[i]:size()-1];
									local  BarL = stream[i].low[stream[i]:size()-1]-stream[i].open[stream[i]:size()-1];
									local  BarC = stream[i].close[stream[i]:size()-1]-stream[i].open[stream[i]:size()-1];
								 
								 
								    
								
									  if stream[i].close[stream[i]:size()-1]> stream[i].open[stream[i]:size()-1] then
									  
									   if max < BarH then
										max= BarH;
										end 
									  
										OP[period-i] = 0;
										HP[period-i] = BarH;
										LP[period-i] = 0;
										CP[period-i] = BarC;
										
										ON[period-i] = 0;
										HN[period-i] = 0;
										LN[period-i] = BarL;
										CN[period-i] = BarC;
									  else
									  
									    if max < BarH then
										max= BarH;
										end
									  
									  
										
										ON[period-i] = 0;
										HN[period-i] = 0;
										LN[period-i] = BarL;
										CN[period-i] = BarC;
										
										 OP[period-i] = 0;
										HP[period-i] = BarH;
										LP[period-i] = 0;
										CP[period-i] = BarC;
										
									  end
					  
					  else           
					  
					                     if max < stream[i].high[stream[i]:size()-1] then
										max= stream[i].high[stream[i]:size()-1];
										end
					  
					                    OP[period-i] = stream[i].open[stream[i]:size()-1];
										HP[period-i] = stream[i].high[stream[i]:size()-1];
										LP[period-i] = stream[i].low[stream[i]:size()-1];
										CP[period-i] = stream[i].close[stream[i]:size()-1];
										
										
					  end			    
					 end 
					 
					 
					
		end
     end
	 
	                 for i = 1, 13 , 1 do
					 if ONOFF[i] then
					 core.host:execute ("drawLabel", i,source:date(period-i)	,max, TIMEFRAMES[i]);
					 end
					 end
end
local streams = {};

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent)
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, core.now(), 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    -- the size of the source
    if barSize == source:barSize() then
        stream.data = source;
        stream.barSize = barSize;
        stream.external = false;
        stream.length = length;
        stream.loading = false;
        stream.extent = extent;
        stream.loading = false;
    else
        stream.data = nil;
        stream.barSize = barSize;
        stream.external = true;
        stream.length = length;
        stream.loading = false;
        stream.extent = extent;
        local from, dataFrom
        from, dataFrom = getFrom(barSize, length, extent);
        if (source:isAlive()) then
            to = 0;
        else
            t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
        end
        stream.loading = true;
        stream.loadingFrom = from;
        stream.dataFrom = dataFrom;
        stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, source:isBid());
        setBookmark(0);
    end
    streams[id] = stream;
    return stream.data;
end

function getPeriod(id, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local candle, from, dataFrom, to;
    if stream.external then
        candle = core.getcandle(stream.barSize, source:date(period), day_offset, week_offset);
        if candle < stream.dataFrom then
            setBookmark(period);
            if stream.loading then
                return -1, true;
            end
            from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
            stream.loading = true;
            stream.loadingFrom = from;
            stream.dataFrom = dataFrom;
            host:execute("extendHistory", id, stream.data, from, stream.data:date(0));
            return -1, true;
        end

        if (not(source:isAlive()) and candle > stream.data:date(stream.data:size() - 1)) then
            setBookmark(period);
            if stream.loading then
                return -1, true;
            end
            stream.loading = true;
            from = bf_data:date(bf_data:size() - 1);
            to = candle;
            host:execute("extendHistory", id, stream.data, from, to);
        end

        local p;
        p = core.findDate (stream.data, candle, true);
        return p, stream.loading;
    else
        return period;
    end
end

function setBookmark(period)
    local bm;
    bm = dummy:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    dummy:setBookmark(1, bm);

end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - 2 * length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - 2 * length * extent + 0.5) / 86400;
    end
    return loadFrom, from;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;
    local stream = streams[cookie];
    if stream == nil then
        return ;
    end
    stream.loading = false;
    period = dummy:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
