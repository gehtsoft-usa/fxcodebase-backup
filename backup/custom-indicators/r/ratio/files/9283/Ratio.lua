-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3810

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
    indicator:name("Ratio");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Prices");
    indicator.parameters:addString("Src", "The source stream", "", "close");
    indicator.parameters:addStringAlternative("Src", "open", "", "open");
    indicator.parameters:addStringAlternative("Src", "high", "", "high");
    indicator.parameters:addStringAlternative("Src", "low", "", "low");
    indicator.parameters:addStringAlternative("Src", "close", "", "close");
    indicator.parameters:addStringAlternative("Src", "median", "", "median");
    indicator.parameters:addStringAlternative("Src", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Src", "weighted", "", "weighted");
	
    indicator.parameters:addString("INST", "The instrument to compare with", "", "");
    indicator.parameters:setFlag("INST", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Dst", "The  stream to compare width", "", "close");
    indicator.parameters:addStringAlternative("Dst", "open", "", "open");
    indicator.parameters:addStringAlternative("Dst", "high", "", "high");
    indicator.parameters:addStringAlternative("Dst", "low", "", "low");
    indicator.parameters:addStringAlternative("Dst", "close", "", "close");
    indicator.parameters:addStringAlternative("Dst", "median", "", "median");
    indicator.parameters:addStringAlternative("Dst", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Dst", "weighted", "", "weighted");
	
	indicator.parameters:addBoolean("Inverse", "Inverse", "", false);
    
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
   

end

local source;                             -- the indicator source
local other;                              -- the additional data stream
local other_stream;
local loading;                            -- flag indicating the other data stream is being loaded
local instrument;                         -- the instrument to be loaded

local price_src, price_dst, price_first;  -- prices
local output, output_first;               -- output stream
local Inverse;

function Prepare(onlyName)
    source = instance.source;   
    price_first = source:first();
 
    Inverse = instance.parameters.Inverse;
    instrument = instance.parameters.INST;

    local name;
    name = profile:id() .. "(" .. source:name() .. "." .. instance.parameters.Src .. "," .. instrument .. "." .. instance.parameters.Dst  .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    price_src = source[instance.parameters.Src];
    price_dst = instance:addInternalStream(price_first, 0);   

    output_first =source:first();

    output = instance:addStream("C", core.Line, name, "C", instance.parameters.clr, output_first);
    output:setWidth(instance.parameters.width);
    output:setStyle(instance.parameters.style);
    output:setPrecision(2);
   
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
        other_stream = other[instance.parameters.Dst];
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
        price_dst[period] = other_stream[other_period];
        
    else
        if price_dst:hasData(period - 1) then
            price_dst[period] = price_dst[period - 1]
        end
    end


    if period >= output_first then   
        if Inverse	then
		output[period] = price_dst[period]/ price_src[period]; 
		else
        output[period] = price_src[period]/price_dst[period];      
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

