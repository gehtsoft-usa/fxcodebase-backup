-- Id: 2787
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3093

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Correlation between prices");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Prices");
    indicator.parameters:addInteger("N", "Number of bars", "", 14, 5, 100);
    indicator.parameters:addString("Src", "The source stream", "", "close");
    indicator.parameters:addStringAlternative("Src", "open", "", "open");
    indicator.parameters:addStringAlternative("Src", "high", "", "high");
    indicator.parameters:addStringAlternative("Src", "low", "", "low");
    indicator.parameters:addStringAlternative("Src", "close", "", "close");
    indicator.parameters:addStringAlternative("Src", "median", "", "median");
    indicator.parameters:addStringAlternative("Src", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Src", "weighted", "", "weighted");
    indicator.parameters:addString("INST", "The instrument to compare with", "", "EUR/JPY");
    indicator.parameters:setFlag("INST", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("Dst", "The  stream to compare width", "", "close");
    indicator.parameters:addStringAlternative("Dst", "open", "", "open");
    indicator.parameters:addStringAlternative("Dst", "high", "", "high");
    indicator.parameters:addStringAlternative("Dst", "low", "", "low");
    indicator.parameters:addStringAlternative("Dst", "close", "", "close");
    indicator.parameters:addStringAlternative("Dst", "median", "", "median");
    indicator.parameters:addStringAlternative("Dst", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Dst", "weighted", "", "weighted");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrP", "Postive Fill Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrN", "Negative Fill Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("T", "Fill Transparency (%)", "", 70, 0, 100);
    indicator.parameters:addGroup("Levels");
    indicator.parameters:addColor("clrL", "Level Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("widthL", "Level Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Level Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LEVEL_STYLE);

end

local source;                             -- the indicator source
local other;                              -- the additional data stream
local other_stream;
local loading;                            -- flag indicating the other data stream is being loaded
local load_from;                          -- the date/time the data was loaded the last time from
local instrument;                         -- the instrument to be loaded

local price_src, price_dst, price_first;  -- prices
local roc_src, roc_dst, roc_first;        -- rate of change
local output, output_first;               -- output stream

local f1, f2;                             -- fill streams
local clrP, clrN;                         -- positive and negative colors

local N;

function Prepare(onlyName)
    source = instance.source;
    N = instance.parameters.N;
    price_first = source:first();

    instrument = instance.parameters.INST;

    local name;
    name = profile:id() .. "(" .. source:name() .. "." .. instance.parameters.Src .. "," .. instrument .. "." .. instance.parameters.Dst .. "," .. instance.parameters.N .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    price_src = source[instance.parameters.Src];
    price_dst = instance:addInternalStream(price_first, 0);

    roc_first = price_first + 1;
    roc_src = instance:addInternalStream(roc_first, 0);
    roc_dst = instance:addInternalStream(roc_first, 0);

    output_first = roc_first + N;

    output = instance:addStream("C", core.Line, name, "C", instance.parameters.clr, output_first);
    output:setWidth(instance.parameters.width);
    output:setStyle(instance.parameters.style);
    output:setPrecision(2);

    output:addLevel(-1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    output:addLevel(0, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    output:addLevel(1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);

    clrP = instance.parameters.clrP;
    clrN = instance.parameters.clrN;
    f1 = instance:addInternalStream(output_first, 0);
    f2 = instance:addInternalStream(output_first, 0);
    instance:createChannelGroup("H", "H", f1, f2, clrP, 100 - instance.parameters.T);
end

function Update(period, mode)
    local from, to;

    if period < price_first then
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
	
	if other~= nil then
        other_stream = other[instance.parameters.Dst];
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
        price_dst[period] = other_stream[other_period];
        if not(price_dst:hasData(period - 1)) and period > price_first then
            for i = price_first, period - 1, 1 do
                price_dst[i] = other_stream[other_period];
                if i > price_first then
                    roc_dst[i] = 0;
                end
            end
        end
    else
        if price_dst:hasData(period - 1) then
            price_dst[period] = price_dst[period - 1]
        end
    end

    if period >= roc_first then
        roc_src[period] = (price_src[period] - price_src[period - 1]) * 100 / price_src[period - 1];
        if price_dst:hasData(period - 1) then
            roc_dst[period] = (price_dst[period] - price_dst[period - 1]) * 100 / price_dst[period - 1];
        end
    end

    if period >= output_first then
        local from = period - N + 1;
        output[period] = mathex.correl(roc_src, roc_dst, from, period, from, period);
        f1[period] = output[period];
        f2[period] = 0;
        if f1[period] > 0 then
            f1:setColor(period, clrP);
        else
            f1:setColor(period, clrN);
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loading = false;
        -- update the indicator output when loading is finished
        instance:updateFrom(price_first);
        return ;
    end
end

