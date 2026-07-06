-- Id: 6716

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19743

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Lower Time Frame RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	T={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "RSI Period", "", 14);
	
	indicator.parameters:addGroup("Selector");	
	
	local i;
	indicator.parameters:addInteger("Number", "Select Time Frame", "", 1);
	for i = 1, 13 ,  1 do 	
	indicator.parameters:addIntegerAlternative("Number", T[i], "", i);
	end

	

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));

	
	indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 30, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "",  1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Period;
local Indicator=nil;
local Type;

local streams = {} ;
local day_offset, week_offset;
local dummy;
local host;
local Source={};
local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local Number;

function Prepare(nameOnly)     
    Period= instance.parameters.Period;
	Type= instance.parameters.Type;
	source = instance.source;
	first = source:first();
	
	host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	 dummy = instance:addInternalStream(0, 0);
	 
	local i;
	
		Number= instance.parameters.Number;
		

	 
	 
	Indicator= nil;
	Source=nil;
	
    local name = profile:id() .. "(" .. source:name() ..", "..Period .. ")";
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);    
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
	
	high:setPrecision(math.max(2, instance.source:getPrecision()));
	low:setPrecision(math.max(2, instance.source:getPrecision()));
	open:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
	
    instance:createCandleGroup("STF", "STF", open, high, low, close);
	
	open:addLevel(0);
    open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    open:addLevel(100);
		
end



-- Indicator calculation routine
function Update(period, mode)
	
	                            open[period] = 0;
								close[period] = 0;
								high[period] = 0;
								low[period] = 0;
	
	
	   local i, p, loading;	
	
    if Indicator == nil then
        

		
            Source = registerStream(Number, TF[Number],  0, source:instrument ());
            Indicator = core.indicators:create("RSI", Source.close, Period); 
          		
		
    end

					Indicator:update(mode);
					
					
						p, loading = getPeriod( Number, period);		
			
				
				if  p~= -1 then
					
					
							if Indicator.DATA:hasData(p) then 
							
							  if  Indicator.DATA[p]~= nil  and Indicator.DATA[p]~= 0 then
										
											if high[period]== 0   or   low[period]== 0  then	
														
												high[period] = Indicator.DATA[p];
												low[period] = Indicator.DATA[p];
												
												
											else
											   
													if  Indicator.DATA[p] > high[period] then
													high[period] = Indicator.DATA[p];
													end
													if  Indicator.DATA[p] < low[period] then
													low[period] = Indicator.DATA[p];
													end													
												
												
											end							
								
								end
							
							end
							
				end
				
   
   
        p, loading = getPeriod( Number, period-1);	
		
		
			if  p~= -1 then					
					
				if Indicator.DATA:hasData(p) then 				
				 open[period] = Indicator.DATA[p];    
				end
   
            end
			
			
		if (period + 1) < ( source:size()-1 ) then	
		 p, loading = getPeriod( Number, period+1);	
		
		
			if  p~= -1 then					
					
				if Indicator.DATA:hasData(p) then 				
				 close[period] = Indicator.DATA[p];     
				end
   
            end	
		end	
		  
       if close[period] > open[period] then	    
		 open:setColor(period, instance.parameters.Up);
	   else	         
         open:setColor(period, instance.parameters.Dn);					 
	   end  

		
 end
 
 
 
-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent, pair)
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, core.now(), 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    -- the size of the source
    if barSize == source:barSize() and source:instrument() == pair then
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
        stream.data = host:execute("getHistory", id, pair, barSize, from, to, source:isBid());
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
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400;
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


