-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3987

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

function Init()
    indicator:name("Bigger timeframe Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	  indicator.parameters:addInteger("DOJI", "Max. Doji Body Lengt", "In Pips", 10, 1, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for UP", "Color for UP", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Color for DOWN", "Color for DOWN", core.rgb(255,0,0));
	 indicator.parameters:addColor("DOJI_Color", "Color for Doji", "Color for DOJI", core.rgb(128,128,128));
    
    indicator.parameters:addInteger("Transparency", "Transparency", "", 70,0,100);
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local day_offset;
local week_offset;
local extent;
local up;
local down;
local hHigh;
local hLow;
local lHigh;
local lLow;
local hUP=nil;
local hDN=nil;
local lUP=nil;
local lDN=nil;
local dummy;
local FIRST=true;
local DOJI;
function Prepare(nameOnly)
    DOJI=instance.parameters.DOJI; 
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
    extent = 20;

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

    local name = profile:id() .. "(" .. source:name() .. "," .. BS.. "," .. DOJI .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
	hHigh=instance:addInternalStream(0, 0);
   	hLow=instance:addInternalStream(0, 0);
	lHigh=instance:addInternalStream(0, 0);
   	lLow=instance:addInternalStream(0, 0);
	
    hUP=instance:addInternalStream(0, 0);
    hDN=instance:addInternalStream(0, 0);
    lUP=instance:addInternalStream(0, 0);
    lDN=instance:addInternalStream(0, 0);
	
	dummy=instance:addInternalStream(0, 0);
  
    instance:createChannelGroup("UpGroup","Up" , hUP, hDN, instance.parameters.UP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup","Dn" , lUP, lDN, instance.parameters.DOWN, 100-instance.parameters.Transparency);
	
	instance:createChannelGroup("UpWick","UpWick" , hHigh, hLow, instance.parameters.UP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnWick","DnWick" , lHigh, lLow, instance.parameters.DOWN, 100-instance.parameters.Transparency);
	
end

local FLAG=nil;
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
        dummy:setBookmark(1, period);
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(from * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
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
        dummy:setBookmark(1, period);
        if loading then
            return ;
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(bf_candle * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
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
        dummy:setBookmark(1, period);
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
    p = core.findDate(bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
		
	
	if bf_candle == source:date(period) then
	  FLAG = period;	
     FIRST = false
    elseif FIRST or period < FLAG then
	FLAG = period;
	end	
	
	if FLAG== nil then
	return;
	end
	
	if  FLAG ==  period then
		if bf_data.open[p]>bf_data.close[p] then
		  lUP[period]=bf_data.open[p];
		  lDN[period]=bf_data.close[p];
		  lHigh[period]=bf_data.high[p];
		  lLow[period]=bf_data.low[p];		
		else
		 hUP[period]=bf_data.close[p];
		 hDN[period]=bf_data.open[p];
		 hHigh[period]=bf_data.high[p];
		 hLow[period]=bf_data.low[p];
		end
	else
	
	    if bf_data.open[p]>bf_data.close[p] then
		core.drawLine (lUP, core.range(FLAG, period), bf_data.open[p], FLAG, bf_data.open[p], period);
		core.drawLine (lDN, core.range(FLAG, period), bf_data.close[p], FLAG, bf_data.close[p], period);
		core.drawLine (lHigh, core.range(FLAG, period), bf_data.high[p], FLAG, bf_data.high[p], period);
		core.drawLine (lLow, core.range(FLAG, period), bf_data.low[p], FLAG, bf_data.low[p], period);		
		else
		core.drawLine (hUP, core.range(FLAG, period), bf_data.close[p], FLAG, bf_data.close[p], period);
		core.drawLine (hDN, core.range(FLAG, period), bf_data.open[p], FLAG, bf_data.open[p], period);
		core.drawLine (hHigh, core.range(FLAG, period), bf_data.high[p], FLAG, bf_data.high[p], period);
		core.drawLine (hLow, core.range(FLAG, period), bf_data.low[p], FLAG, bf_data.low[p], period);
		end
	
	end
	
	local loop;
	
	if DOJI >  math.abs(bf_data.close[p] - bf_data.open[p] ) / source:pipSize() then
			 for loop =FLAG, period, 1  do
			lUP:setColor(loop, instance.parameters.DOJI_Color);
			lHigh:setColor(loop, instance.parameters.DOJI_Color);
			lHigh:setColor(loop, instance.parameters.DOJI_Color);
			lLow:setColor(loop, instance.parameters.DOJI_Color);
			
			hUP:setColor(loop, instance.parameters.DOJI_Color);
			hHigh:setColor(loop, instance.parameters.DOJI_Color);
			hHigh:setColor(loop, instance.parameters.DOJI_Color);
			hLow:setColor(loop, instance.parameters.DOJI_Color);
			end
	else
	
	 
	 for loop =FLAG, period, 1  do
	    if bf_data.open[p]< bf_data.close[p] then
		hUP:setColor(loop, instance.parameters.UP);
		hHigh:setColor(loop, instance.parameters.UP);
		hHigh:setColor(loop, instance.parameters.UP);
		hLow:setColor(loop, instance.parameters.UP);		
		else
		lUP:setColor(loop, instance.parameters.DOWN);
		lHigh:setColor(loop, instance.parameters.DOWN);
		lHigh:setColor(loop, instance.parameters.DOWN);
		lLow:setColor(loop, instance.parameters.DOWN);
		end
	 end
	
    end	
	
	if bf_candle == source:date(period) then	
	    lUP:setBreak (period, true);
		lDN:setBreak (period, true);
		lHigh:setBreak (period, true);
		lLow:setBreak (period, true);
		hUP:setBreak (period, true);
		hDN:setBreak (period, true);
		hHigh:setBreak (period, true);
		hLow:setBreak (period, true);
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = lHigh:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
