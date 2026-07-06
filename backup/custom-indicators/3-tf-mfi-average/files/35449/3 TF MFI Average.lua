-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20165
-- Id: 6777

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
    indicator:name("3 TF MFI Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

    
	
	Parameters (1 , "H1");
	Parameters (2 , "H8");
	Parameters (3 , "D1");	    
	
	indicator.parameters:addGroup("Line Style");
	
	indicator.parameters:addInteger("widthFirst", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 0));
	
	 indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
    
	
	
end


function Parameters (id , FRAME )  	     
	indicator.parameters:addGroup(id..".  Time Frame");
	indicator.parameters:addInteger("PERIOD"..id, "Period", "",14, 2, 1000);
	 indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);	
	
end


local source;
local day_offset, week_offset;
local dummy;
local stream=nil;
local host;
local first;

local Position;

local indicator;
local Average;

function Prepare(nameOnly) 
	
   
	source = instance.source;
	first= source:first();
    host = core.host;
	
	 local name =  profile:id() .. ","  .. instance.source:name() ;
	
	 local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
       

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");  

    assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator");	
	
	
    dummy = instance:addInternalStream(0, 0);
	local i;
	for i= 1, 3, 1 do
        s1, e1 = core.getcandle(instance.parameters:getString ("B"..i), core.now(), 0, 0);
        assert ((e - s) <= (e1 - s1), i..". Time Frame  must be bigger than the chart time frame!");
        name = name..", (" ..instance.parameters:getString ("PERIOD"..i)  ..", ".. instance.parameters:getString ("B"..i) .. ")";      
	end
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Average = instance:addStream("Average", core.Line, name .. ".Average", "Average", instance.parameters.Color, first);
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
	Average:addLevel(0);
    Average:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Average:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Average:addLevel(100);
	
	 stream = nil;
end


function Update(period,mode)

     if not source:hasData(period) or period< first  then 
     return;
     end
  
	local i;
	local PERIOD;
	
	local Sum=0;
		
	if stream == nil then	
	indicator= {}; 
	stream= {};
		for i = 1, 3 , 1 do	 
			stream[i] = registerStream(i, instance.parameters:getString ("B"..i),10);
			indicator[i] = core.indicators:create("MFI", stream[i], instance.parameters:getInteger ("PERIOD"..i));			
		end
	end		
			
	
	
		for i = 1, 3, 1  do
		  
		    indicator[i]:update(mode);
						
			PERIOD= getPeriod(i, period); 
			if PERIOD== -1 then			
			Sum= nil
			break;
			end
			if indicator[i].DATA:hasData(PERIOD) then
			Sum= Sum+  indicator[i].DATA[PERIOD];
			else
			Sum= nil
			break;
			end
			 
	    end
	 if Sum ~= nil then
	Average[period] =  Sum/3;
    end	
	

	
end


local streams = {}


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
        p = core.findDate(stream.data, candle, true);
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

