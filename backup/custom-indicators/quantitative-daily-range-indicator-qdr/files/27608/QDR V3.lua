--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Quantitative Daily Range Indicator v3");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
	  indicator.parameters:addGroup("Calculation");	 
	  indicator.parameters:addDouble("SD", "Standard deviation", "", 0.5, 0, 1);
	  indicator.parameters:addDouble("P", "DT", "", 1);
	   indicator.parameters:addBoolean("Current", "Use Current Period", "", false);
	  
	  
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Lines color", "", core.rgb(0,255,0));
    indicator.parameters:addColor("Dn", "Down Lines color", "", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("UW", "Up Lines width", "", 1, 1, 5);
    indicator.parameters:addInteger("US", "Up Lines style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("US", core.FLAG_LINE_STYLE);
   
    indicator.parameters:addInteger("DW", "Down Lines width", "", 1, 1, 5);
    indicator.parameters:addInteger("DS", "Down Lines style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("DS", core.FLAG_LINE_STYLE);
	
	
end

local SD;
local Current;
local ArrowSize;
local font;
local source;

local day_offset, week_offset;
local dummy;
local stream=nil;
local host;
local first;
local E, P, T;
local ID;
local l;
local DV;
local Price={};
function Prepare()    
     SD=instance.parameters.SD;
    ArrowSize=instance.parameters.ArrowSize;
   P=instance.parameters.P;
   Current=instance.parameters.Current;
	
    local name =  profile:id() .. ", "  .. instance.source:name()  .. ","    ..  SD .. ","    ..  P;
	
    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");		
    local s, e;

    s, e = core.getcandle("D1", core.now(), 0);
    l = e - s; 


    assert(source:barSize() ~= "t1", "Indicator not working on Tick Data");
	
    dummy = instance:addInternalStream(0, 0);
	
	name = name .. ")";
	instance:name(name);
 
    E = P/252;	
	T = E/4;

   
	stream=nil;
end


function Update(period)

	 if  period <  source:size()-1 then	
	return;
	end
	
	
		
			if stream == nil then
			stream = {};							
					stream[1] = registerStream(1, "D1", 2, true);	
                --  stream[2] = registerStream(2, "D1", 2, false);	 					
			end
		
		
		if not stream[1].close:hasData ( stream[1].close:size()-1  )
		or stream[1].close:size()-1 <1
		then
        return;
       end		
		
        local u, v;
	
		   
			u = 1 +  (SD*(T^0.5));
            v = 1 - (SD*(T^0.5));			
			
		local PERIOD;	
		if Current then
		PERIOD = stream[1].close:size()-1;
        else
		PERIOD = stream[1].close:size()-2;
        end		
			
		local LAST = 	stream[1].close[PERIOD];
			
		local U1 = LAST * u;
		local U2 = U1*u;
		local U3 = U2*u;
		local U4 = U3*u;	
		
		LAST = 	stream[1].close[PERIOD];
		
        local L1 = LAST * v;
		local L2 = L1*v
		local L3 = L2*v
		local L4 = L3*v	 	

        old, new = core.getcandle("D1", source:date(period), day_offset, week_offset);
	   
	
        local id=0;
          id = id+1;
		 core.host:execute("drawLine", id, old , U1, new, U1, instance.parameters.Up, instance.parameters.US,  instance.parameters.UW);
		 id = id+1;
        core.host:execute("drawLabel", id,   old , U1, "U1"  );
		 id = id+1;
		 core.host:execute("drawLabel", id,   new , U1, string.format("%." .. 4 .. "f",  U1 )  );

         id = id+1;
		 core.host:execute("drawLine", id, old , U2, new, U2, instance.parameters.Up, instance.parameters.US,  instance.parameters.UW);
		  id = id+1;
		core.host:execute("drawLabel", id,   old , U2, "U2"  );
		 id = id+1;
		core.host:execute("drawLabel", id,   new , U2, string.format("%." .. 4 .. "f",  U2 )  );
	
	
	     id = id+1;
		 core.host:execute("drawLine", id, old , U3, new, U3, instance.parameters.Up, instance.parameters.US,  instance.parameters.UW);
		  id = id+1;
		  core.host:execute("drawLabel", id,   old , U3, "U3");
		   id = id+1;
		  core.host:execute("drawLabel", id,   new , U3, string.format("%." .. 4 .. "f",  U3 )  );
		
		 id = id+1;
		 core.host:execute("drawLine", id, old , U4, new, U4, instance.parameters.Up, instance.parameters.US,  instance.parameters.UW);
		  id = id+1;
		  core.host:execute("drawLabel", id,   old , U4, "U4");
		   id = id+1;
		  core.host:execute("drawLabel", id,   new , U4, string.format("%." .. 4 .. "f",  U4 )  );
		
		
		 id = id+1;
		 core.host:execute("drawLine", id, old , L1, new, L1, instance.parameters.Dn, instance.parameters.DS,  instance.parameters.DW);
		  id = id+1;
		 core.host:execute("drawLabel", id,   old , L1, "L1");
		  id = id+1;
		 core.host:execute("drawLabel", id,   new , L1, string.format("%." .. 4 .. "f",  L1 )  );
		
		
		 id = id+1;
		 core.host:execute("drawLine", id, old , L2, new, L2, instance.parameters.Dn, instance.parameters.DS,  instance.parameters.DW);		
		  id = id+1;
		 core.host:execute("drawLabel", id,   old , L2, "L2");
		  id = id+1;
		 core.host:execute("drawLabel", id,   new , L2, string.format("%." .. 4 .. "f",  L2 )  );
		
		
		 id = id+1;
		 core.host:execute("drawLine", id, old , L3, new, L3, instance.parameters.Dn, instance.parameters.DS,  instance.parameters.DW);
		  id = id+1;
		 core.host:execute("drawLabel", id,   old , L3, "L3");
		  id = id+1;
		 core.host:execute("drawLabel", id,   new , L3, string.format("%." .. 4 .. "f",  L3 )  );
		
		 id = id+1;
		 core.host:execute("drawLine", id, old , L4, new, L4, instance.parameters.Dn, instance.parameters.DS,  instance.parameters.DW);
		  id = id+1;
		 core.host:execute("drawLabel", id,   old , L4, "L4");
		  id = id+1;
	    core.host:execute("drawLabel", id,   new , L4, string.format("%." .. 4 .. "f",  L4 )  );
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
    
end

local streams = {}


-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent,bidask)
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
        stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, bidask);
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