-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4037

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
    indicator:name("HLC Bar");
    indicator:description("HLC (High-Low-Close");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
	indicator:setTag("replaceSource", "t");
end

local source = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first() + 1;

    local name = profile:id()  .. "(" .. source:name() .. ")";

    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("HLC", "HLC", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first then
        if source.close[period-1] <= source.close[period] then
            open[period]    = source.close[period]-source:pipSize();
        else
            open[period]    = source.close[period]+source:pipSize();
        end
        close[period]   = source.close[period];
        high[period]    = source.high[period];
        low[period]     = source.low[period];
    end
end





