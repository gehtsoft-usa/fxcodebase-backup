-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13974
-- Id: 5906

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Heikin-Ashi Chart with Colouring");
    indicator:description("Helps to identify trends and trend changes more easily.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");
	
	 indicator.parameters:addColor("UP", "Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DN", "Down Trend ", "", core.rgb(255, 0, 0));
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

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low" .. ".low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup(name, "HA", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first then
        if (period == first) then
            open[period] = (source.open[period - 1] + source.close[period - 1]) / 2;
        else
            open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        close[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
        high[period] = math.max(open[period], close[period], source.high[period]);
        low[period] = math.min(open[period], close[period], source.low[period]);
		
		if open[period]<  close[period] then
		open:setColor(period, instance.parameters.UP);
		else
		open:setColor(period, instance.parameters.DN);
		end
    end	
end
