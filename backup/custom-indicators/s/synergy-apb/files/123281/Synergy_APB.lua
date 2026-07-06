-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67253

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Synergy APB")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
	
	 indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0))
end

local source = nil
local open = nil
local close = nil
local high = nil
local low = nil

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    source = instance.source;

    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), 0)
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), 0)
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), 0)
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), 0)
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
    close[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4.0;
    close[period] = (close[period] + source.close[period]) / 2.0;

    open[period] = open[period];
    if period > 0 then 
        open[period] = (open[period - 1] + (close[period - 1])) / 2.0;
    end
    high[period] = math.max(source.high[period], math.max(open[period], close[period]));
    low[period] = math.min(source.low[period], math.min(open[period], close[period]));
end
