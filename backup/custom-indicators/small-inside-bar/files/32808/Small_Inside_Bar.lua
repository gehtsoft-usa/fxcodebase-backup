-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18178
-- Id: 6529

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Small inside bar indicator");
    indicator:description("Small inside bar indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Direction", "Direction", "", "Both");
    indicator.parameters:addStringAlternative("Direction", "Bullish", "", "Bullish");
    indicator.parameters:addStringAlternative("Direction", "Bearish", "", "Bearish");
    indicator.parameters:addStringAlternative("Direction", "Both", "", "Both");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BullishClr", "Bullish Color", "Bullish Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("BearishClr", "Bearish Color", "Bearish Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 2, 1, 5);
end

local first;
local source = nil;
local Direction;
local Bullish=nil;
local Bearish=nil;

function Prepare(nameOnly)
    source = instance.source;
    Direction=instance.parameters.Direction;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Direction .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Bullish = instance:addStream("Bullish", core.Dot, name .. ".Bullish", "Bullish", instance.parameters.BullishClr, first);
    Bearish = instance:addStream("Bearish", core.Dot, name .. ".Bearish", "Bearish", instance.parameters.BearishClr, first);
    Bullish:setWidth(instance.parameters.DotSize);
    Bearish:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    local Ratio;
    local BullFl=false;
    local BearFl=false;
    if source.high[period]-source.low[period]==0 then
     Ratio=10;
    else
     Ratio=(source.high[period-1]-source.low[period-1])/(source.high[period]-source.low[period]);
    end
    if source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] and Ratio>2 then
     if source.close[period]>source.open[period] and source.high[period]<source.median[period-1] and source.close[period-1]<source.open[period-1] then
      BullFl=true;
     end 
     if source.close[period]<source.open[period] and source.low[period]<source.median[period-1] and source.close[period-1]>source.open[period-1] then
      BearFl=true;
     end 
    end
    if BullFl then
     Bullish[period]=source.low[period];
    else
     Bullish[period]=nil;
    end 
    if BearFl then
     Bearish[period]=source.high[period]; 
    else
     Bearish[period]=nil; 
    end
   end 
end

