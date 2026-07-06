-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65353

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
    indicator:name("Tarzan's spread ratio indicator");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("First Price Stream");   
    indicator.parameters:addString("instrument1","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("instrument1", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("type1", "Price Type","", true);
    indicator.parameters:setFlag("type1", core.FLAG_BIDASK);

    indicator.parameters:addGroup("Second Price Stream");   
    indicator.parameters:addString("instrument2","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("instrument2", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("type2", "Price Type","", true);
    indicator.parameters:setFlag("type2", core.FLAG_BIDASK);

    indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addString("stream_type", "Stream Type", "", "close");
    indicator.parameters:addStringAlternative("stream_type", "open", "", "open");
    indicator.parameters:addStringAlternative("stream_type", "high", "", "high");
    indicator.parameters:addStringAlternative("stream_type", "low", "", "low");
    indicator.parameters:addStringAlternative("stream_type", "close", "", "close");
    indicator.parameters:addStringAlternative("stream_type", "median", "", "median");
    indicator.parameters:addStringAlternative("stream_type", "typical", "", "typical");
    indicator.parameters:addStringAlternative("stream_type", "weighted", "", "weighted");

  	indicator.parameters:addString("TF", "Time frame", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("smalen", "SMA Length", "", 6, 1, 10000);

    indicator.parameters:addString("spreadType", "Spread Type", "", "/");
    indicator.parameters:addStringAlternative("spreadType", "+", "", "+");
    indicator.parameters:addStringAlternative("spreadType", "-", "", "-");
    indicator.parameters:addStringAlternative("spreadType", "/", "", "/");
    indicator.parameters:addStringAlternative("spreadType", "*", "", "*");
     
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);   
end

local source;
local price_stream1={};
local price_stream2 ={};
local loading_stream1, loading_stream2;
local instrument1, instrument2;
local period;
local output;
local FLAG=true;
local Indicator={};
local price_dst1, price_dst2;
local spread_type;

function Prepare(onlyName)
    source = instance.source;   
    price_first = source:first();
    period=instance.parameters.TF;
    instrument1 = instance.parameters.instrument1;
    instrument2 = instance.parameters.instrument2;
    spread_type = instance.parameters.spreadType;

    local name;
    name = profile:id() .. "(" .. instance.parameters.instrument1 .."." .. period .. instance.parameters.spreadType .. instance.parameters.instrument2 .. "." .. period .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
        
    output_first =source:first();	
    output = instance:addStream("C", core.Line, name, "C", instance.parameters.clr, output_first);
    output:setWidth(instance.parameters.width);
    output:setStyle(instance.parameters.style);
    output:setPrecision(2);
    
    price_stream1.stream = nil;
    price_stream2.stream = nil;
    price_stream1.dest_stream = instance:addInternalStream(price_first, 0);
    price_stream2.dest_stream = instance:addInternalStream(price_first, 0);
    
    FLAG = true;
end

function Update(period, mode)
    local from, to;

    if period < price_first then
        return ;
    end

    if price_stream1.stream == nil then
        loadPriceStream(price_stream1, instrument1, 1);
    end
    
    if price_stream2.stream == nil then
        loadPriceStream(price_stream2, instrument2, 2);
    end
      
    if price_stream1.loading == true or price_stream2.loading == true then
        return ;
    end

    local curr_date = source:date(period);
    
    extendPriceStream(price_stream1, curr_date, 1)   
    extendPriceStream(price_stream2, curr_date, 2)
    
    fillDestinationStream(price_stream1, curr_date, period);
    fillDestinationStream(price_stream2, curr_date, period);
	
	if FLAG then
		FLAG = false;
		local smalen = instance.parameters.smalen;
		Indicator["STREAM1"] =   core.indicators:create("MVA", price_stream1.dest_stream, smalen);
		Indicator["STREAM2"] =   core.indicators:create("MVA", price_stream2.dest_stream, smalen);
    end

    Indicator["STREAM1"]:update(mode);
    Indicator["STREAM2"]:update(mode);
		 
	if period >= output_first then 	   
        if (spread_type =="+") then
            output[period] = Indicator["STREAM1"].DATA[period] + Indicator["STREAM2"].DATA[period];
        elseif (spread_type =="-") then
            output[period] = Indicator["STREAM1"].DATA[period] - Indicator["STREAM2"].DATA[period];
        elseif (spread_type =="/") then
            output[period] = Indicator["STREAM1"].DATA[period] / Indicator["STREAM2"].DATA[period];
        elseif (spread_type =="*") then
            output[period] = Indicator["STREAM1"].DATA[period] *  Indicator["STREAM2"].DATA[period];
        end 
    end    
end

function loadPriceStream(price_stream, instrument, cookieID)

    from = source:date(source:first());   -- oldest data to load
    if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
        to = 0;
    else
        to = source:date(source:size() - 1);
    end
    price_stream.load_from = from;
    price_stream.loading = true;
    price_stream.stream = core.host:execute("getHistory", cookieID, instrument, period, from, to, source:isBid());
end

function extendPriceStream(priceStream, curr_date, cookieID)

    local from;
    local to;
    if curr_date < priceStream.load_from then
        -- if the data we are trying to get is oldest than previously loaded
        -- the extend the history to the oldest data we can request
        from = source:date(source:first());     -- load from the oldest data we have in source
        if priceStream.stream:size() > priceStream.stream:first() then
            to = priceStream.stream:date(priceStream.stream:first());     -- to the oldest data we have in other instrument
        else
            to =  priceStream.load_from;
        end
        priceStream.load_from = from;
        priceStream.loading = true;
        core.host:execute("extendHistory", cookieID,  priceStream.stream, from, to);
        return ;
    end
end

function fillDestinationStream(price_stream, curr_date, period)
    
    local other_period = core.findDate(price_stream.stream, curr_date, true);

    if other_period ~= -1 then
        price_stream.dest_stream[period] = price_stream.stream[instance.parameters.stream_type][other_period];       
    else
        if price_stream.dest_stream:hasData(period - 1) then
            price_stream.dest_stream[period] = price_stream.dest_stream[period - 1]
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        price_stream1.loading = false;
        -- update the indicator output when loading is finished
        instance:updateFrom(price_first);
        return ;
    end
    
    if cookie == 2 then
        price_stream2.loading = false;
        -- update the indicator output when loading is finished
        instance:updateFrom(price_first);
        return ;
    end
end

