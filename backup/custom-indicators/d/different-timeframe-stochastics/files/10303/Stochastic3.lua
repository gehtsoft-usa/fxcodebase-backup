-- Id: 3804
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4110

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
	
    indicator.parameters:addString("BS1", "Time frame to calculate stochastic 1", "", "H1");
    indicator.parameters:setFlag("BS1", core.FLAG_PERIODS);
    indicator.parameters:addString("BS2", "Time frame to calculate stochastic 2", "", "H4");
    indicator.parameters:setFlag("BS2", core.FLAG_PERIODS);
    indicator.parameters:addString("BS3", "Time frame to calculate stochastic 3", "", "H8");
    indicator.parameters:setFlag("BS3", core.FLAG_PERIODS);
   
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrRes", "Color Result", "Color Result", core.rgb(255, 255, 0));
	
    indicator.parameters:addInteger("width", "Stochastic lines Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Stochastic line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	
    indicator.parameters:addInteger("widthRes", "Result lines Width", "", 3, 1, 5);
    indicator.parameters:addInteger("styleRes", "Result line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRes", core.FLAG_LEVEL_STYLE);	
end

local source;                   -- the source
local bf_data1 = nil;    
local bf_data2 = nil;    
local bf_data3 = nil;    

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;


local BS1;
local BS2;
local BS3;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local Stochastic1=nil;
local Stochastic2=nil;
local Stochastic3=nil;
local day_offset;
local week_offset;
local extent;
local Buff1=nil;
local Buff2=nil;
local Buff3=nil;
local BuffRes=nil;
local streams = {}

function Prepare(nameOnly)
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS1 = instance.parameters.BS1;
    BS2 = instance.parameters.BS2;
    BS3 = instance.parameters.BS3;
	
	
    k = instance.parameters.K;   
    sd = instance.parameters.SD;
    d = instance.parameters.D;
	
   averageTypeK = instance.parameters.MVAT_K;
   averageTypeD = instance.parameters.MVAT_D;
	
    extent = ( k + sd + d) * 2;
    
    CheckBarSize(BS1);
    CheckBarSize(BS2);
    CheckBarSize(BS3);

    local name = profile:id() .. "(" .. source:name() .. "," .. k .. "," .. sd .. "," .. d .. ", " .. averageTypeK  .."," .. averageTypeD .. "," .. BS1 .. "," .. BS2 .. "," .. BS3 ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".St1", "St1", instance.parameters.clr1, 0);
    Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".St2", "St2", instance.parameters.clr2, 0);
    Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".St3", "St3", instance.parameters.clr3, 0);
    Buff3:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffRes = instance:addStream("BuffRes", core.Line, name .. ".Result", "Result", instance.parameters.clrRes, 0);
    BuffRes:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff1:setWidth(instance.parameters.width);
    Buff1:setStyle(instance.parameters.style);
    Buff2:setWidth(instance.parameters.width);
    Buff2:setStyle(instance.parameters.style);
    Buff3:setWidth(instance.parameters.width);
    Buff3:setStyle(instance.parameters.style);
    BuffRes:setWidth(instance.parameters.widthRes);
    BuffRes:setStyle(instance.parameters.styleRes);
    BuffRes:addLevel(20);
    BuffRes:addLevel(80);
end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

function CheckBarSize(TF)
    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
end

function getPriceStream(stream)
    local s = instance.parameters.S;
    return stream;
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
        p = core.findDate (stream.data, candle, true);
        return p, stream.loading;
    else
        return period;
    end
end

function setBookmark(period)
    local bm;
    bm = Buff1:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    Buff1:setBookmark(1, bm);

end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400;
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
    period = Buff1:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end

 

-- the function which is called to calculate the period
function Update(period, mode)
 local stream;
 local p, loading;
 if Stochastic1==nil then
  stream = registerStream(1, BS1, extent);
  Stochastic1 = core.indicators:create("STOCHASTIC", getPriceStream(stream), k, sd, d, averageTypeK, averageTypeD);
 end
 if Stochastic2==nil then
  stream = registerStream(2, BS2, extent);
  Stochastic2 = core.indicators:create("STOCHASTIC", getPriceStream(stream), k, sd, d, averageTypeK, averageTypeD);
 end
 if Stochastic3==nil then
  stream = registerStream(3, BS3, extent);
  Stochastic3 = core.indicators:create("STOCHASTIC", getPriceStream(stream), k, sd, d, averageTypeK, averageTypeD);
 end
 
 local Sum=0;
 local Count=0;
 p, loading = getPeriod(1, period);
 if p ~= -1 then
  Stochastic1:update(mode);
  if Stochastic1.K:hasData(p) then
   Buff1[period]=Stochastic1.K[p];
   Sum=Sum+Buff1[period];
   Count=Count+1;
  end
 end 
 
 p, loading = getPeriod(2, period);
 if p ~= -1 then
  Stochastic2:update(mode);
  if Stochastic2.K:hasData(p) then
   Buff2[period]=Stochastic2.K[p];
   Sum=Sum+Buff2[period];
   Count=Count+1;
  end
 end 
 
 p, loading = getPeriod(3, period);
 if p ~= -1 then
  Stochastic3:update(mode);
  if Stochastic3.K:hasData(p) then
   Buff3[period]=Stochastic3.K[p];
   Sum=Sum+Buff3[period];
   Count=Count+1;
  end
 end 
 
 if Count~=0 then
  BuffRes[period]=Sum/Count;
 end


end


