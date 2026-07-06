
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65156

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
    indicator:name("Pivot filter/confirmation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("pivot_bars", "Number of pivot bars", "", 5, 1, 10000);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Line color", "Color of Line", core.rgb(255, 255, 255));
end

local source;
local pivot_bars;
local High, Low;

function Prepare(nameOnly)
    source = instance.source;
    pivot_bars = instance.parameters.pivot_bars;

    local name = profile:id() .. "(" .. pivot_bars .. ")"
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end

    High = instance:addStream("High", core.Dot, "High", "High", instance.parameters.Color, 0, 0)
    Low = instance:addStream("Low", core.Dot, "Low", "Low", instance.parameters.Color, 0, 0)
end

function CalcHigh(period)
    if period <= pivot_bars then
        return nil;
    end
    local max, pos = mathex.max(source.high, core.rangeTo(period, pivot_bars));
    if pos == period - math.floor(pivot_bars / 2) then
        return max;
    end
    return nil;
end

function CalcLow(period)
    if period <= pivot_bars then
        return nil;
    end
    local min, pos = mathex.min(source.low, core.rangeTo(period, pivot_bars));
    if pos == period - math.floor(pivot_bars / 2) then
        return min;
    end
    return nil;
end

function Update(period, mode)
    High[period] = CalcHigh(period);
    Low[period] = CalcLow(period);
end
