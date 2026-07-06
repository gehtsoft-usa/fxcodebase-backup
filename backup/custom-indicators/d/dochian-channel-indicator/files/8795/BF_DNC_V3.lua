
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20

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
    indicator:name("Bigger timeframe DNC");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	
	  indicator.parameters:addString("BS", "Time frame to calculate DNC", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);    
	 indicator.parameters:addString("MD", "Show Close or High/Low", "", "Close");
    indicator.parameters:addStringAlternative("MD", "Close", "", "Close");
    indicator.parameters:addStringAlternative("MD", "High/Low", "", "HighLow");
	
	indicator.parameters:addGroup("Selector");
	
	  indicator.parameters:addString("SHL", "Show High/Low lines", "Show High/Low lines", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "Both lines", "", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "High only", "", "High"); 
    indicator.parameters:addStringAlternative("SHL", "Low only", "", "Low"); 
	
	indicator.parameters:addBoolean("SM", "Show middle line", "", true);  
	indicator.parameters:addBoolean("SUB", "Show Sub Levels", "", false);
	indicator.parameters:addBoolean("AC", "Analyze the current period", "", true);  
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDU", "Up Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDU", "Up Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDU", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDN", "Down Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDN", "Down Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDN", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthDM", "Middle Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDM", "Middle Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDM", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clrSUB", "Color of the Sub Level lines", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthSUB", "Sub Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSUB", "Sub Level Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSUB", core.FLAG_LINE_STYLE);

end



local first = 0;
local n = 0;
local ac;
local sm;
local MODE=nil;
local SUB;
local low, high;


local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local day_offset;
local week_offset;
local extent;
local dn=nil;
local du=nil;
local dm=nil;

local SHL;

function Prepare(nameOnly) 
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

	SHL = instance.parameters.SHL;
	 
    BS = instance.parameters.BS;
	
	 SUB = instance.parameters.SUB;
    source = instance.source;
    n = instance.parameters.N;
	MODE=instance.parameters.MD; 
    ac =instance.parameters.AC;
    sm = instance.parameters.SM;
	
	
	 local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    
    extent = n+1;

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

   
    dn = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  0);
	dn:setWidth(instance.parameters.widthDU);
    dn:setStyle(instance.parameters.styleDU);
    du = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  0);
	du:setWidth(instance.parameters.widthDN);
    du:setStyle(instance.parameters.styleDN);
    if sm then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  0);
		dm:setWidth(instance.parameters.widthDM);
        dm:setStyle(instance.parameters.styleDM);
    end
	
	if SUB then
	high = instance:addStream("high", core.Line, name .. ".DMU", "S", instance.parameters.clrSUB,  first)
	    high:setWidth(instance.parameters.widthSUB);
        high:setStyle(instance.parameters.styleSUB);
	low = instance:addStream("low", core.Line, name .. ".DMD", "S", instance.parameters.clrSUB,  first)
	    low:setWidth(instance.parameters.widthSUB);
        low:setStyle(instance.parameters.styleSUB);
	end

	assert(core.indicators:findIndicator("DNC_V3") ~= nil, "Please, download and install DNC_V3.LUA indicator");

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
        dn:setBookmark(1, period);
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
        DNC = core.indicators:create("DNC_V3", bf_data, n, MODE,SHL , true, true, ac );
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        dn:setBookmark(1, period);
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
        dn:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    DNC:update(mode);
    local p;
    p = core.findDate(bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    if DNC:getStream(0):hasData(p) then
        dn[period] = DNC:getStream(0)[p];
    end
    if DNC:getStream(1):hasData(p) then
        du[period] = DNC:getStream(1)[p];
    end
    if sm then
     if DNC:getStream(2):hasData(p) then
         dm[period] = DNC:getStream(2)[p];
     end
    end 
    
	if SUB then
	
	if DNC:getStream(3):hasData(p) then
	   high[period] = DNC:getStream(3)[p];
	end
	
	if DNC:getStream(4):hasData(p) then
	   low[period] = DNC:getStream(4)[p];
	end	
	
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = dn:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
