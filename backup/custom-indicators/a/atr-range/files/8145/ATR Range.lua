
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3415

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
    indicator:name("ATR Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("ATR Calculation");
    indicator.parameters:addInteger("atrPeriod", "ATR Periods", "", 100);
	indicator.parameters:addInteger("mFactor", "Multiple Factor", "", 65);
	
	
    indicator.parameters:addString("timeFrame", "ATR Time Frame", "", "D1");
    indicator.parameters:setFlag("timeFrame", core.FLAG_PERIODS);	

    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local ATR;
local atrPeriod;
local mFactor;
local timeFrame;

local day_offset;
local week_offset;

local dummy;
local host;
local i=1;
local MAX, MIN;

-- Streams block
local stream = nil;
local color;

local streams = {}
local font;
local size;
local Size;
-- Routine
function Prepare(nameOnly)  
    source = instance.source;
    first = source:first();
	host = core.host;

	color=instance.parameters.color;
	atrPeriod=instance.parameters.atrPeriod;
	mFactor=instance.parameters.mFactor;
	timeFrame=instance.parameters.timeFrame;
	Size=instance.parameters.Size;
	
	
	--mFactor =  mFactor/100;
	
	
	
    local name = profile:id() .. "(" .. source:name() ..", " .. timeFrame.. ", ".. mFactor .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

	dummy = instance:addInternalStream(0, 0);	
	
	
	 font = core.host:execute("createFont", "Courier", Size, true, false);
	 size  = source:getPrecision ();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	

	    if period < source:size()-1 then
		return;
		end;	
	
		if ATR == nil then		
			stream = registerStream(1, timeFrame, atrPeriod);
			ATR = core.indicators:create("ATR", stream, atrPeriod);	
		end	
	
		ATR:update(mode);
		
		if not ATR.DATA:hasData(ATR.DATA:size()-1)  and not ATR.DATA:hasData(ATR.DATA:size()-2)then
			return;
		end					
				
		MAX = stream.open[stream:size()-1] +  (ATR.DATA[ATR.DATA:size()-1] *  mFactor);
		MIN = stream.open[stream:size()-1] -  (ATR.DATA[ATR.DATA:size()-1] * mFactor); 		
	
		core.host:execute ("drawLine", 1,  source:date(first), MAX, source:date(period), MAX, color);	
        core.host:execute ("drawLine", 2, source:date(first), MIN, source:date(period), MIN, color);	
		
		 core.host:execute("drawLabel1", 3, source:date(period), core.CR_CHART, MAX, core.CR_CHART, core.H_Right, core.V_Center,
                          font, color,  tostring(mFactor*100) .. ", " .. string.format("%." .. size .. "f",  MAX));
		  core.host:execute("drawLabel1", 4, source:date(period), core.CR_CHART, MIN, core.CR_CHART, core.H_Right, core.V_Center,
                          font, color,  tostring(-mFactor*100)..  ", " ..string.format("%." .. size .. "f",  MIN));				  

      	
		
             
	
		
    end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);      
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