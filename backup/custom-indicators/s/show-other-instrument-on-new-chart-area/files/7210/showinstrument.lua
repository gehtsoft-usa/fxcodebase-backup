-- Id: 2790
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3094

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Show another instrument in the new area");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("INST", "The instrument to load", "", "");
    indicator.parameters:setFlag("INST", core.FLAG_INSTRUMENTS);
end

local source;           -- the indicator source
local other;            -- the additional data stream
local loading;          -- flag indicating the other data stream is being loaded
local load_from;        -- the date/time the data was loaded the last time from
local instrument;       -- the instrument to be loaded
local o, h, l, c, v;    -- the indicator output stream;
local first;

function Prepare(onlyName)
    source = instance.source;
    first = source:first();

    instrument = instance.parameters.INST;

    local name;
    name = profile:id() .. "(" .. instrument .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    assert(core.host:execute("isTableFilled", "offers"), "You must be logged in to use this indicator");
    local row = core.host:findTable("offers"):find("Instrument", instrument);
    assert(row ~= nil, "You must be subscribed for the chosen instrument");
    local precision = row.Digits;

    name = instrument .. "(" .. source:barSize() .. ",";
    if source:isBid() then
        name = name .. "bid" .. ")";
    else
        name = name .. "ask" .. ")";
    end

    o = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first);
    o:setPrecision(precision);
    
    h = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first);
    h:setPrecision(precision);
    
    l = instance:addStream("low", core.Line, name .. ".low", "low", core.rgb(0, 0, 0), first);
    l:setPrecision(precision);
    
    c = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first);
    c:setPrecision(precision);

    if source:supportsVolume() then
        v = instance:addStream("volume", core.Line, name .. ".volume", "volume", core.rgb(0, 0, 0), first);
    v:setPrecision(math.max(2, instance.source:getPrecision()));
        instance:createCandleGroup (instrument, instrument, o, h, l, c, v);
    else
        v = nil;
        instance:createCandleGroup (instrument, instrument, o, h, l, c);
    end
end

function Update(period, mode)
    local from, to;

    if period < first then
        return ;
    end

    if other == nil then
        -- if the data is not loaded yet at all
        -- load the data
        from = source:date(source:first());   -- oldest data to load
        if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        load_from = from;
        loading = true;
        other = core.host:execute("getHistory", 1, instrument, source:barSize(), from, to, source:isBid());
        return ;
    end

    if loading then
        return ;
    end

    local curr_date = source:date(period);
    if curr_date < load_from then
        -- if the data we are trying to get is oldest than previously loaded
        -- the extend the history to the oldest data we can request
        from = source:date(source:first());     -- load from the oldest data we have in source
        if other:size() > other:first() then
            to = other:date(other:first());     -- to the oldest data we have in other instrument
        else
            to = load_from;
        end
        load_from = from;
        loading = true;
        core.host:execute("extendHistory", 1, other, from, to);
        return ;
    end

    -- the date is in the loaded range
    -- try to find it
    local other_period = core.findDate(other, curr_date, true);

    if other_period ~= -1 then
        o[period] = other.open[other_period];
        h[period] = other.high[other_period];
        l[period] = other.low[other_period];
        c[period] = other.close[other_period];
        if v ~= nil then
            v[period] = other.volume[other_period];
        end

        if not(c:hasData(period - 1)) and period > first then
            for i = first, period - 1, 1 do
                o[i] = o[period];
                h[i] = o[period];
                l[i] = o[period];
                c[i] = o[period];
                if v ~= nil then
                    v[i] = 0;
                end
            end
        end
    else
        if c:hasData(period - 1) then
            o[period] = c[period - 1];
            h[period] = c[period - 1];
            l[period] = c[period - 1];
            c[period] = c[period - 1];
            if v ~= nil then
                v[period] = v[period - 1];
            end
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loading = false;
        -- update the indicator output when loading is finished
        instance:updateFrom(first);
        return ;
    end
end

