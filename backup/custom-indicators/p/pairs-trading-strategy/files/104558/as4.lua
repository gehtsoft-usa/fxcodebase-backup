
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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

function Init()
    indicator:name("Two Instrument Cointegration improve");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	


    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "", "MVA Period", 10, 2, 1000);
     indicator.parameters:addInteger("EMA_Period", "EMA Period", "", 10, 2, 1000);
	 indicator.parameters:addDouble("Value", "Value", "", 0, 0, 1000000);
	 
		
	Parameters (1  );
	Parameters (2  );
	

	
	indicator.parameters:addGroup("First Line Style");
	indicator.parameters:addColor("first", "First Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("second", "second Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("firstwidth", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("firststyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("firststyle", core.FLAG_LEVEL_STYLE);

	
end

function Parameters (id )
--function Parameters (id , FRAME)
   
	indicator.parameters:addGroup(id..". Line Instrument");
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
    --indicator.parameters:addString("B"..id, "MA Time frame", "", FRAME);
    --indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end



local out;
local source;
local day_offset, week_offset;
local dummy;
local stream=nil;
local host;
local Period;
local first;
local  loading;

local FLAG = false;
local AL=nil;
local ul=nil;
local dl=nil;
local EMAS=nil;
local INSTRUMENT={};
local EMA_Period;
local Value;
function Prepare(nameOnly)

   Period=instance.parameters.Period;
   EMA_Period=instance.parameters.EMA_Period; 
   Value=instance.parameters.Value;
    source = instance.source;
	first= source:first()+Period	;
	
    host = core.host;	
	
   
    local name =  profile:id()  ;
	
	local i;

	for i = 1 , 2 , 1 do    
	
	  
	       INSTRUMENT[i] = instance.parameters:getString ("INSTRUMENT"..i);
	   
	  
      name = name..", ("  .. INSTRUMENT[i]    ..", "..  Period .. ")";      
	end	
	
	instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	

    dummy = instance:addInternalStream(0, 0);
	
	out = instance:addStream("out1", core.Line, ".out", "out", instance.parameters.first, first);

   
    out:setWidth(instance.parameters.firstwidth);
    out:setStyle(instance.parameters.firststyle);
    out:setPrecision(2);
	
    EMAS = core.indicators:create("EMA", out, EMA_Period);
    firstPeriodSIGNAL = EMAS.DATA:first();
    AL = instance:addStream("AL1", core.Line, ".AL", "AL", instance.parameters.second, first);
    AL:setWidth(instance.parameters.firstwidth);
    AL:setStyle(instance.parameters.firststyle);
    AL:setPrecision(2);
    
    ul = instance:addStream("ul1", core.Line, ".ul", "ul", instance.parameters.second, first);
    ul:setWidth(instance.parameters.firstwidth);
    ul:setStyle(instance.parameters.firststyle);
    ul:setPrecision(2);
    
    dl = instance:addStream("dl1", core.Line, ".dl", "dl", instance.parameters.second, first);
    dl:setWidth(instance.parameters.firstwidth);
    dl:setStyle(instance.parameters.firststyle);
    dl:setPrecision(2);

	 FLAG = false;
	 stream = nil;
	loading =false;
	 

end


function Update(period, mode)




local curr_date = source:date(period);

 local i;
 	local p={};	 
 
		  if loading then
		return;
		end			
		

						 if stream ~= nil then
	                        for i = 1 , 2 , 1 do
							
							    if stream[i].close:hasData(stream[i].close:first()) then
													   if  curr_date < stream[i]:date(stream[i]:first()) then
															local from = source:date(source:first());     -- load from the oldest data we have in source
															local to = stream[i]:date(stream[i]:first());     -- to the oldest data we have in other instrument
															
															
															loading = true;
															core.host:execute("extendHistory", 1, stream[i], from, to);
															return ;
														end	 
								end					
							end							
		              end
 



	
	
					if stream == nil then
					
                     stream={};
                   			
						  
						  for i = 1 , 2 , 1 do						    
							stream[i] = registerStream(i, source:barSize (), Period);												
					
						  end
						
					end
					
	
	

   	 p[1] =  core.findDate(stream[1].close, curr_date, true);
	 p[2] =  core.findDate(stream[2].close, curr_date, true);		
					
	 		
	

	local S1=nil;
		local S2=nil;	
	       local meanx=nil;
               local meany=nil;
 if  p[1] < stream[1]:first() + Period+1
 or p[2]< stream[2]:first()+ Period+1
 or not  stream[1]:hasData( p[1])
 or not stream[2]:hasData(p[2])
  or not  stream[1]:hasData( p[1]-Period)
 or not stream[2]:hasData(p[2]-Period)
 then
 return;
 end
					
		
		   
	
		
	   
       
		
        S1 = mathex.stdev(stream[1].close, p[1] - Period + 1, p[1]);	
        S2 = mathex.stdev(stream[2].close, p[2] - Period + 1, p[2]);
			
		meany=mathex.avg(stream[1].close, p[1] - Period + 1, p[1]);
        meanx=mathex.avg(stream[2].close, p[2] - Period + 1, p[2]);

		if S1~= nil and S2~= nil then
		local Corelation= mathex.correl (stream[1].close, stream[2].close,  p[1]-Period+1,  p[1], p[2]-Period+1 , p[2]);
		local Ratio = Corelation * (S1/S2);
		
        local intercept= meany-Ratio*meanx;
        
        out[period]= stream[1].close[period]-(intercept+Ratio*stream[2].close[period]);
       
        EMAS:update(mode);
        if (period >= firstPeriodSIGNAL) then
        AL[period] = EMAS.DATA[period];
        ul[period]=EMAS.DATA[period]+Value;
        dl[period]=EMAS.DATA[period]-Value;
		end
      end
				
end	
			


local streams = {}

function getPriceStream(stream, i)
    local s = instance.parameters:getString ("S"..i);
    if s == "open" then
        return stream.open;
    elseif s == "high" then
        return stream.high;
    elseif s == "low" then
        return stream.low;
    elseif s == "close" then
        return stream.close;
    elseif s == "median" then
        return stream.median;
    elseif s == "typical" then
        return stream.typical;
    elseif s == "weighted" then
        return stream.weighted;
    else
        return source.close;
    end
end

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
        stream.data = host:execute("getHistory", id, INSTRUMENT[id], barSize, from, to, source:isBid());
        setBookmark(0);
   
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
        p = findDateFast(stream.data, candle, true);
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

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end




















