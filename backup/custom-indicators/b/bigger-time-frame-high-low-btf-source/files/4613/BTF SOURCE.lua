-- Id: 1692
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bigger Time Frame Source");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Bigger Time Frame");
	indicator.parameters:addString("BS", "Time frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("Options");
    indicator.parameters:addBoolean("HL", "Show B.T.F. High Low Value", "", true); 
	
	indicator.parameters:addString("Method", "Method", "Method" , "Current");
    indicator.parameters:addStringAlternative("Method", "Current", "Current" , "Current");
    indicator.parameters:addStringAlternative("Method", "Previous", "Previous" , "Previous");
	
	indicator.parameters:addGroup("Style");
	  
	indicator.parameters:addInteger("widthout", "Close Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleout", "Close Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleout", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("out", "Close Line Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("widthlow", "Low Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylelow", "Low Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylelow", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("low", "Low Line Color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("widthhigh", "High Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylehigh", "High Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylehigh", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("high", "High Line Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("widthopen", "Open Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleopen", "Open Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleopen", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("open", "Open Line Color", "", core.rgb(128, 128, 128));
  
   end


local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local DATA;
local OUT, HIGH, LOW, OPEN;
local HL;

local day_offset;
local week_offset;
local Method;
function Prepare()
    source = instance.source;
    host = core.host;
	Method=instance.parameters.Method;
	      
		
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
	HL = instance.parameters.HL;
	
    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

    local  name = profile:id() .. "(" .. source:name() ..")";
    instance:name(name);
   
    OUT = instance:addStream("CLOSE", core.Line, name .. ".OUT", "OUT", instance.parameters.out, 0);
	OUT:setWidth(instance.parameters.widthout);
	OUT:setStyle(instance.parameters.styleout);
	
	if HL then 
	HIGH = instance:addStream("HIGH", core.Line, name .. ".HIGH", "HIGH", instance.parameters.high, 0);
	HIGH:setWidth(instance.parameters.widthhigh);
	HIGH:setStyle(instance.parameters.stylehigh);
	
	LOW = instance:addStream("LOW", core.Line, name .. ".LOW", "LOW", instance.parameters.low, 0);
	LOW:setWidth(instance.parameters.widthlow);
	LOW:setStyle(instance.parameters.stylelow);
	
	OPEN = instance:addStream("OPEN", core.Line, name .. ".OPEN", "OPEN", instance.parameters.open, 0);
	OPEN:setWidth(instance.parameters.widthopen);
	OPEN:setStyle(instance.parameters.styleopen);
	else
	
	HIGH = instance:addInternalStream(0, 0);
	LOW = instance:addInternalStream(0, 0);
	OPEN = instance:addInternalStream(0, 0);
	end
	
end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local bf_candle;
    bf_candle = core.getcandle(BS, source:date(period), day_offset, week_offset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and bf_candle >= loadingFrom and (loadingTo == 0 or bf_candle <= loadingTo) then
        return ;
    end

    -- if the period is before the source start
    -- the do nothing
    if period < source:first() then
        return ;
    end

    -- if data is not loaded yet at all
    -- load the data
    if bf_data == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;

        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), day_offset, week_offset);
        end

        from = core.getcandle(BS, source:date(source:first()), day_offset, week_offset);
        OUT:setBookmark(1, period);
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(from * 86400 - (bf_length * (1)) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * (1)) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = to;
        bf_data = host:execute("getHistory", 1, source:instrument(), BS, loadingFrom, to, source:isBid());
		return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        OUT:setBookmark(1, period);
        if loading then
            return ;
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(bf_candle * 86400 - (bf_length * (1) ) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * (1)) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = bf_data:date(0);
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and bf_candle > bf_data:date(bf_data:size() - 1)) then
        OUT:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

	   local p;
	  p = core.findDate (bf_data, bf_candle, true);
 
		 if p == -1 or p== nil  then
			return ;
		end
		
		
    
 
	
	if Method ~= "Current" and (p-1) <  bf_data.close:first () then  
	return;
    elseif Method ~= "Current" then
    p=p-1;	
	end
	 
        OUT[period] = bf_data.close[p];
		HIGH[period] = bf_data.high[p];
		LOW[period] = bf_data.low[p];
	    OPEN[period] = bf_data.open[p];
		
		if OUT[period] ~= OUT[period-1] 
		or HIGH[period] ~= HIGH[period-1] 
		or LOW[period] ~= LOW[period-1] 
		or OPEN[period] ~= OPEN[period-1] 
		then
		Flag= true;
		else
		Flag= false;
		end
		
		OUT:setBreak (period, Flag);
		HIGH:setBreak (period, Flag);
		LOW:setBreak (period, Flag);
		OPEN:setBreak (period, Flag);
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = OUT:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end