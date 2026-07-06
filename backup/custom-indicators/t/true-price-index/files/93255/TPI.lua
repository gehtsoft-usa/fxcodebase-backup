-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60466
-- Id: 11386

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
    indicator:name("True Price Index ");
    indicator:description("True Price Index ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Up", "Color of Up Candle", "Color of Up", core.COLOR_UPCANDLE );
    indicator.parameters:addColor("Down", "Color of Down Candle", "Color of Down", core.COLOR_DOWNCANDLE );
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Up, Down;
-- Streams block
local Open = nil;
local High = nil;
local Low = nil;
local Close = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Open = instance:addStream("Open", core.Line, name .. ".Open", "Open",Up, first);
    Open:setPrecision(math.max(2, instance.source:getPrecision()));
        High = instance:addStream("High", core.Line, name .. ".High", "High", Up, first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
        Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", Up, first);
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
        Close = instance:addStream("Close", core.Line, name .. ".Close", "Close", Up, first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
		 instance:createCandleGroup("TPI", "", Open, High, Low, Close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period <first or not  source:hasData(period) then
	return;
	end
	
	local Length = source.high[period]-source.low[period];
	
	if source.close[period]<  source.open[period] then
	Length=- Length;	
	end
	
        Open[period] = Close[period-1];    
        Close[period] = Open[period]+ Length;  
		
		
		High[period] = math.max(Open[period], Close[period]);
        Low[period] =  math.min(Open[period], Close[period]);
end

