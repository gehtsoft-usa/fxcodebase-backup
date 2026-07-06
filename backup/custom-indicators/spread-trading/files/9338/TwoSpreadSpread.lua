-- Id: 3513
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2073


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
function Init()

    indicator:name("TwoSpreadSpread");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator:setTag("group", "Currency Indexes");	
	
	indicator.parameters:addGroup("Type of Spread");
	 indicator.parameters:addString("Type", "Single Spread", "", "ONE");
    indicator.parameters:addStringAlternative("Type", "Single Spread", "", "ONE");
    indicator.parameters:addStringAlternative("Type", "Second Spread", "", "TWO");
	
	
	indicator.parameters:addGroup("First Pair");
	indicator.parameters:addBoolean("InverseFirst", "Inverse First Spread", "", false);
	indicator.parameters:addString("p1", "Instrumet", "", "");
    indicator.parameters:setFlag("p1", core.FLAG_INSTRUMENTS );	
	
	indicator.parameters:addString("p2", "Instrumet", "", "");
    indicator.parameters:setFlag("p2", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addGroup("Second Pair");
	indicator.parameters:addBoolean("InverseSecond", "Inverse Second Spread", "", false);
	indicator.parameters:addString("p3", "Instrumet", "", "");
    indicator.parameters:setFlag("p3", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("p4", "Instrumet", "", "");
    indicator.parameters:setFlag("p4", core.FLAG_INSTRUMENTS );

	indicator.parameters:addGroup("Cumulative"); 
	indicator.parameters:addBoolean("Inverse", "Inverse Cumulative Spread", "", false);

	indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("color1", "First Pair Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Second Pair Color", "", core.rgb(255,0 , 0));
	indicator.parameters:addColor("color3", "Third Pair Color", "", core.rgb(0,0 , 255));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local Type;

local last;
local data;
local instrument;
local dummy = nil;
local day_offset, week_offset;

local p1, p2, p3, p4;

local out1, out2, out3
local stream1,stream2, stream3,stream4;

local Inverse;
local  InverseFirst;
local  InverseSecond;



-- Routine
function Prepare(nameOnly) 
    source = instance.source;
    first = source:first();
    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

	p1 = instance.parameters.p1;
	p2  = instance.parameters.p2;	
	p3 = instance.parameters.p3;
	p4  = instance.parameters.p4;
	
	Type= instance.parameters.Type;
	
	 Inverse= instance.parameters.Inverse;
	InverseFirst= instance.parameters.InverseFirst;
	InverseSecond= instance.parameters.InverseSecond;

    local name;
	if Type == "ONE" then
	name= profile:id() .." (".. p1..", " ..p2..", ".. "Single Spread" ..")";
	else
	name= profile:id() .." (".. p1..", " ..p2.. ", "..p3..", " ..p4..", ".. "Second Spread" ..")";
	end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    instrument=source:instrument();
	
	if Type == "ONE" then
	out1 = instance:addStream("out1", core.Line, "", "Spread", instance.parameters.color1, first);
    out1:setPrecision(math.max(2, instance.source:getPrecision()));
    else
	out1 = instance:addStream("out1", core.Line, "", "Spread", instance.parameters.color1, first);
	out1:setPrecision(math.max(2, instance.source:getPrecision()));
	out2 = instance:addStream("out2", core.Line, "", "Spread", instance.parameters.color2, first);
    out2:setPrecision(math.max(2, instance.source:getPrecision()));
	out3 = instance:addStream("out3", core.Line, "", "Spread", instance.parameters.color3, first);
    out3:setPrecision(math.max(2, instance.source:getPrecision()));
	end	

    dummy = instance:addInternalStream(0, 0);   -- the stream for bookmarking
end

-- Indicator calculation routine

local init = true;
function Update(period,mode)

local i,j;


    if period < first  or not source:hasData(period) then 
	return;
	end
       
	   if period == source:size()-1 then
	       
		 if last ~= source:size()-1  then
            last=source:size()-1;
	
	        local size=source:barSize();
	          
          
            if Type == "ONE" then
			stream1=registerStream(0, size, 0, p1);  
			stream2=registerStream(1, size, 0, p2);		
            else
            stream1=registerStream(0, size, 0, p1);  
			stream2=registerStream(1, size, 0, p2);	    			
            stream3=registerStream(2, size, 0, p3);  
			stream4=registerStream(3, size, 0, p4);				
			end
			
		end
			
			
			
					for j=1, period,1 do
					   
					   
					     if Type == "ONE" then
					          if   stream1:hasData(j)  and  stream2:hasData(j) then
							  
									   if InverseFirst then
									    out1[j]=stream2.close[j]-stream1.close[j];
									   else
									   out1[j]=stream1.close[j]-stream2.close[j];
									   end
							  end		
						else	  
						
						      if   stream1:hasData(j)  and  stream2:hasData(j) then
							  
									   if InverseFirst then
									    out1[j]=stream2.close[j]-stream1.close[j];
									   else
									   out1[j]=stream1.close[j]-stream2.close[j];
									   end
							  end		
							  
							  if   stream3:hasData(j)  and  stream4:hasData(j) then
									  if InverseSecond then
										 out2[j]=stream4.close[j]-stream3.close[j];
									   else
									   out2[j]=stream3.close[j]-stream4.close[j];
									   end
							  end		
							  
							   if   stream1:hasData(j)  and  stream2:hasData(j) and stream3:hasData(j)  and  stream4:hasData(j) then
									   if Inverse then
									   out3[j]= out2[j]- out1[j];
									   else
									   out3[j]= out1[j]- out2[j];
									   end
							  end
						end	  
					end
			
			
        end
    
	   
end

local streams = {}

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent, instrument )
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, 0, 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    stream.data = nil;
    stream.barSize = barSize;
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
    stream.dataFrom = from;
    stream.data = host:execute("getHistory", id, instrument, barSize, from, to, source:isBid());
    setBookmark(0);

    streams[id] = stream;
    return stream.data;
end

function getDate(id, candle, precise, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local from, dataFrom, to;
    if candle < stream.dataFrom then
        setBookmark(period);
        if stream.loading then
            return -1, true;
        end
        from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
        stream.loading = true;
        stream.loadingFrom = from;
        stream.dataFrom = from;
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
    p = findDateFast(stream.data, candle, precise);
    return p, stream.loading;
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


-- find the date in the stream using binary search algo.
function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

    if max < 1 then
        return -1;
    end

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
        if datesec == periodsec then
            return mid;
        elseif datesec > periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end
        if min > max then
            if precise then
                return -1;
            else
                return min - 1;
            end
        end
    end
end


