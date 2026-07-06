-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36111
-- Id: 9073

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("The20s indicator");
    indicator:description("The20s indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("Variation", "Variation", "", false);
    indicator.parameters:addDouble("StopLevel", "Stop level", "", 0.2);
    indicator.parameters:addInteger("Range", "Range", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Variation;
local StopLevel;
local Range;
local PriceRange;
local UP=nil;
local DN=nil;
local PRange;

function Prepare(nameOnly)
    source = instance.source;
    Variation=instance.parameters.Variation;
    StopLevel=instance.parameters.StopLevel;
    Range=instance.parameters.Range;
    PRange=Range*source:pipSize();
    first = source:first()+5;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.StopLevel .. ", " .. instance.parameters.Range .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PriceRange = instance:addInternalStream(first, 0);
    UP = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.DotSize);
    DN:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    PriceRange[period]=source.high[period]-source.low[period];
    local LastBarsRange=PriceRange[period-1];
    local Top20=source.high[period-1]-LastBarsRange*StopLevel;
    local Bottom20=source.low[period-1]+LastBarsRange*StopLevel;
    if Variation then
     if PriceRange[period-4]>LastBarsRange and PriceRange[period-3]>LastBarsRange and PriceRange[period-2]>LastBarsRange and source.high[period-2]>source.high[period-1] and source.low[period-2]<source.low[period-1] then
      if source.open[period]<=Bottom20 then
       DN[period]=source.low[period];
      elseif source.open[period]>=Top20 then
       UP[period]=source.high[period];
      end
     end
    else
     if source.open[period-1]>=Top20 and source.close[period-1]<=Bottom20 and source.low[period]<=source.low[period-1]+PRange then
      DN[period]=source.low[period];
     elseif source.open[period-1]<=Bottom20 and source.close[period-1]>=Top20 and source.high[period]>=source.high[period-1]+PRange then
      UP[period]=source.high[period];
     end
    end
   end 
end

