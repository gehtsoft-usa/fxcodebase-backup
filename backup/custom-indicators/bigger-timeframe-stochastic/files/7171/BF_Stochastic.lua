-- Id: 2763
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3078

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
    indicator:name("Bigger timeframe Stochastic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K","Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MT", "", "MT");
    
    indicator.parameters:addString("MVAT_D","The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "", "EMA");
	
	
		
    indicator.parameters:addString("BS", "Time frame to calculate stochastic", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
   
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("Kwidth", "K Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Kstyle", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addInteger("Dwidth", "D Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "D Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Dstyle", core.FLAG_LEVEL_STYLE);	
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;


local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local Stochastic;
local SK, SD;
local day_offset;
local week_offset;
local extent;

 function Prepare(nameOnly)   
 
    

  
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
	
	
    k = instance.parameters.K;   
    sd = instance.parameters.SD;
    d = instance.parameters.D;
	
	 averageTypeK = instance.parameters.MVAT_K;
   averageTypeD = instance.parameters.MVAT_D;
	
    extent = ( k + sd + d) * 2;
	
	
	
	  local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. k .. "," .. sd .. "," .. d .. ", " .. averageTypeK  .."," .. averageTypeD ..")";
    instance:name(name);
	
	  if   (nameOnly) then
        return;
    end
	

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

  
	
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, 0);
	SK:setWidth(instance.parameters.Kwidth);
	SK:setStyle(instance.parameters.Kstyle);
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, 0);
	SD:setWidth(instance.parameters.Dwidth);
	SD:setStyle(instance.parameters.Dstyle);
	
	SK:setPrecision(math.max(2, instance.source:getPrecision()));
	SD:setPrecision(math.max(2, instance.source:getPrecision()));
	
    SK:addLevel(20);
    SK:addLevel(50);
    SK:addLevel(80);

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
        SK:setBookmark(1, period);
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
        Stochastic = core.indicators:create("STOCHASTIC", bf_data, k, sd, d, averageTypeK, averageTypeD);
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        SK:setBookmark(1, period);
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
        SK:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    Stochastic:update(mode);
    local p;
    p = core.findDate (bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    if Stochastic:getStream(0):hasData(p) then
        SK[period] = Stochastic:getStream(0)[p];
    end
    if Stochastic:getStream(1):hasData(p) then
        SD[period] = Stochastic:getStream(1)[p];
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = SK:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
