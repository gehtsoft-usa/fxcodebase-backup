-- Id: 5148
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8627

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
    indicator:name("BTF Price");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;


-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	
	
    first =  source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	



    if (not (nameOnly)) then	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("ZONE", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
    end	

   
	
	 open[period]=source.open[period];
	close[period]=source.close[period];
	high[period]=source.high[period];
	low[period]=source.low[period];

    
	
end

