-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24837
-- Id: 7747

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
    indicator:name("EUR Index");
    indicator:description("Calculates the EUR index in on the base of EURUSD, EURGBP, EURJPY, EURSEK, EURCHF instruments. You must be subscribed for all these instruments!!!");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("BL", "BAR/LINE", "" , "LINE");
    indicator.parameters:addStringAlternative("BL", "LINE", "" , "LINE");
	indicator.parameters:addStringAlternative("BL", "BAR", "" , "BAR");	
    
    indicator.parameters:addBoolean("Reverse", "Reverse", "", false);

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 0, 0));
end

local source;
local barSize;
local loading = false;
local offset;
local weekoffset;
local BL;

local close
local open;
local high;
local low;

-- indexes for the instruments in the data table

local p={}; 
 p[0] = "EUR/USD";
 p[1] = "EUR/GBP";
 p[2] = "EUR/JPY";
 p[3] = "EUR/SEK";
 p[4] = "EUR/CHF"

local Weights={};

   Weights[0]=0.3155;
   Weights[1]=0.3056;
   Weights[2]=0.1891;
   Weights[3]=0.0785;
   Weights[4]=0.1113;
local Sign={};
    Sign[0]=1.0000;
   Sign[1]=1.0000;
   Sign[2]=1.0000;
   Sign[3]=1.0000;
   Sign[4]=1.0000;
 
local first = nil;
local last = nil;
-- data table
local data = {};



-- add a new item into the data table
-- index        - is the index of the item in the table
-- instrument   - the instrument name
-- weight       - the weigth of the instrument
function AddCollectionItem(index)
    local t, coll, from, to, tmp;
    t = {};
    t.instrument = p[index];
    t.data = nil;
    t.loading = false;
    t.weight = Weights[index]*Sign[index];
    t.rqfrom = nil;
    t.rqto = nil;
    data[index] = t;

    if first == nil or first > index then
        first = index;
    end
    if last == nil or last < index then
        last = index;
    end
end

-- initialize the collection of the instruments
function InitCollection()
    -- sum of absolute values of the weights must be 1. negative sign is for the
    -- instrument which has USD as counter currency.
     AddCollectionItem(0);
     AddCollectionItem(1)
     AddCollectionItem(2)
     AddCollectionItem(3)
     AddCollectionItem(4)
 
end

-- prepare the indicator
function Prepare(nameOnly)
    BL = instance.parameters.BL;   
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	for i= 0, 4, 1  do
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", p[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  p[i] );    	
	end
	

    InitCollection();

    local name = profile:id();
    if instance.parameters.Reverse then
     name=name .. "(reverse)";
    end
    instance:name(name);
    if nameOnly then
        return;
    end
	
	
	if BL == "BAR" then
	close = instance:addStream("close", core.Line, "", "", core.rgb(128, 128, 128), 0);	
    open = instance:addStream("open", core.Line, "", "", core.rgb(128, 128, 128), 0);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, "", "", core.rgb(128, 128, 128), 0);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, "", "", core.rgb(128, 128, 128), 0);   
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("OHLC", "OHLC", open, high, low, close);	
	else
	close = instance:addStream("USDX", core.Line, "USDX", "", core.rgb(128, 128, 128), 0);	
	end
    close:setPrecision(math.max(2, instance.source:getPrecision()));
	
   --close = instance:addStream("X", core.Line, name .. ".X", "X", instance.parameters.clrIndex, 0);
end

local p = {};
local w = {};

local popen = {};
local pclose = {};
local phigh = {};
local plow = {};

-- get the price of the specified instrument


function GetPrice(index, date)
    local t;

    local from, to, tmp;

    t = data[index];

    assert(t ~= nil, "internal error!");

    if t.data == nil then
        -- data is not loaded yet at all
        if source:isAlive() then
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        from = source:date(source:first());
        t.data = host:execute("getHistory", index, t.instrument, barSize, from, to, source:isBid());
        t.rqfrom = from;
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0, 0, 0, 0;
    elseif date < t.rqfrom then
        -- requested date is before the first item of the collection
        -- we have ever requested
        from = date;
        to = t.data:date(0);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqfrom = from;
        t.loading = true;
        loading = true;
        return 0, 0, 0, 0, 0;
    elseif not(source:isAlive()) and date > t.rqto then
        -- requested date is after the last item of the collection
        -- we have ever requested
        to = date;
        from = t.data:date(t.data:size() - 1);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0, 0, 0, 0;
    end

    local p;
    p = core.findDate (t.data, date, false);
    if p < 0 then
        return 0, 0, 0, 0, 0;
    end
    return t.data.open[p],t.data.high[p],t.data.low[p],t.data.close[p], t.weight;
end


local lastdate = nil;

-- the function which is called to calculate the period
function Update(period, mode)

    if loading or period <= source:first() then
        return ;
    end

    -- do not calculate for the floating candle
    period = period - 1;

    if lastdate ~= nil and source:date(period) == lastdate then
        return ;
    end

    lastdate = source:date(period);

    local i,  absent,  o,h,l,c, b;
	local x={};
    absent = false;
    for i = first, last, 1 do
         o, h, l, c, b = GetPrice(i, lastdate);
        if a == 0 then
            absent = true;
        end
		
        pclose[i] = c;
        popen[i] = o;
		phigh[i] = h;
		plow[i] = l;	
		
        w[i] = b;
    end

    if loading then
        close:setBookmark(1, period);
        return ;
    end

    if absent then
        if close:hasData(period - 1) then
            close[period] = close[period - 1];
        end
    else
         x[1] = 34.38805726;  x[2] = 34.38805726;  x[3] = 34.38805726;  x[4] = 34.38805726;
        for i = first, last, 1 do
             if BL == "BAR" then
			    x[4] = x[4] * math.pow(pclose[i], w[i]);
				x[1] = x[1] * math.pow(popen[i], w[i]);
				x[2] = x[2] * math.pow(phigh[i], w[i]);
				x[3] = x[3] * math.pow(plow[i], w[i]);
			else
				x[4] = x[4] * math.pow(pclose[i], w[i]);
			end	
        end
		
		
		
		  if BL == "BAR" then
		  
		          if instance.parameters.Reverse then
				   close[period] =1/x[4];
				   open[period] = 1/x[1];
				   high[period] = 1/x[2];
				   low[period] = 1/x[3];
                   else
				    close[period] = x[4];
				   open[period] = x[1];
				   high[period] = x[2];
				   low[period] = x[3];
                   end				   
		  else
		  
				   if instance.parameters.Reverse then
				 close[period]=1/x[4];
				else 
				 close[period] = x[4];
				end 
		 
		  end
		  
		  
       
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
            if BL == "BAR" then
			open[period] = close[period - 1];
			 high[period] = close[period - 1];
			low[period] = close[period - 1];		 
			close[period] = close[period - 1];
			 else
			 close[period] = close[period - 1];
			 end
    end
end

function AsyncOperationFinished(cookie)

    local t;
    t = data[cookie];
    t.loading = false;
    for i = first, last, 1 do
        if data[i].loading then
            return ;
        end
    end
    loading = false;

    local period;
    period = close:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end
 