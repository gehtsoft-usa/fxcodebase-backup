-- Id: 4050

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3608

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
    indicator:name("Bigger timeframe D oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("BS", "Time frame to calculate DNC", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 13);
    indicator.parameters:addInteger("D_Period", "D_Period", "", 8);
    indicator.parameters:addInteger("CCI_Period", "CCI_Period", "", 8);
    indicator.parameters:addDouble("CCI_Coeff", "CCI_Coeff", "", 0.4);
    indicator.parameters:addInteger("Smooth", "Smooth", "", 4);	
	
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
end



local first = 0;
local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local day_offset;
local week_offset;
local extent;
local dummy=nil;


local RSI_Period;
local D_Period;
local CCI_Period;
local CCI_Coeff;
local Smooth;
local RSI;
local CCI;
local Buff1=nil;
local Buff2=nil;

local Indicator;


function Prepare(nameOnly)
    source = instance.source;
    host = core.host; 
	
    BS = instance.parameters.BS;
    source = instance.source;
	
	RSI_Period=instance.parameters.RSI_Period;
    D_Period=instance.parameters.D_Period;
    CCI_Period=instance.parameters.CCI_Period;
    CCI_Coeff=instance.parameters.CCI_Coeff;
    Smooth=instance.parameters.Smooth;
   
	

    local name = profile:id() .. "(" .. source:name() .. "," .. RSI_Period .. "," .. D_Period.. "," .. CCI_Period.. "," .. CCI_Coeff .. "," .. Smooth .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	assert(core.indicators:findIndicator("D_OSCILLATOR") ~= nil, "Please, download and install D_Oscillator.lua indicator");
	
	dummy=instance:addInternalStream (0,0);
	
	local first, DATA;
	DATA = core.indicators:create("D_OSCILLATOR", source, RSI_Period , D_Period , CCI_Period, CCI_Coeff, Smooth);
	first = DATA.DATA:first();
    extent = first;
	
	

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

	
	
	
	Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr1, first);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr2, first);
	
	
	Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff2:setPrecision(math.max(2, instance.source:getPrecision()));

	

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
        Indicator = core.indicators:create("D_OSCILLATOR", bf_data, RSI_Period , D_Period , CCI_Period, CCI_Coeff, Smooth);
		

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

    Indicator:update(mode);
    local p;
    p = core.findDate(bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    if Indicator:getStream(0):hasData(p) then
        Buff1[period] = Indicator:getStream(0)[p];
    end
    if Indicator:getStream(1):hasData(p) then
        Buff2[period] = Indicator:getStream(1)[p];
    end
   
   
   
   
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = dummy:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
