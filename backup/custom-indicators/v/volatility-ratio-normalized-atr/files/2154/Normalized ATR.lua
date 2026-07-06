-- Id: 766
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1126

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Normalized ATR");
    indicator:description("Normalized ATR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "Period", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local tr = nil;
local trFirst = nil;

-- Streams block
local ATR = nil;

-- Routine

 function Prepare(nameOnly)   
 
    n = instance.parameters.N;
    source = instance.source;
 
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);


    if   (nameOnly) then
        return;
    end 

    tr = instance:addInternalStream(source:first() + 1, 0);
    first = tr:first() + n;
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first)
    ATR:setPrecision(math.max(2, instance.source:getPrecision()));
	ATR:setWidth(instance.parameters.width);
    ATR:setStyle(instance.parameters.style);
    trFirst = tr:first();
	
	ATR:addLevel(0);
	
end

function getTrueRange(period)
    local hl = math.abs(source.high[period] - source.low[period]);
    local hc = math.abs(source.high[period] - source.close[period - 1]);
    local lc = math.abs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
function Update(period)
    if period >= trFirst then
        tr[period] = getTrueRange(period);
    end
    if period >= first then
	   ATR[period] = 100*((mathex.avg(tr, period-n+1, period))/source.close[period]);
    end
end




