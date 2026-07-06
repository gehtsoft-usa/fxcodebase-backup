-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36113
-- Id: 9077

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
    indicator:name("Gap finder indicator");
    indicator:description("Gap finder indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MinGapSize", "Min. gap size (in pips)", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP gap color", "UP gap color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("DNclr", "DN gap color", "DN gap color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local MinGapSize;
local UpGap=nil;
local DnGap=nil;

function Prepare(nameOnly)
    source = instance.source;
    MinGapSize=instance.parameters.MinGapSize*source:pipSize();
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinGapSize .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpGap = instance:createTextOutput ("UpGap", "UpGap", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.UPclr, 0);
    DnGap = instance:createTextOutput ("DnGap", "DnGap", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.DNclr, 0);
end

function Update(period, mode)
   if period>first then
    if source.low[period]-source.high[period-1]>=MinGapSize then
     UpGap:set(period, source.low[period], "\225");
    else
     UpGap:setNoData(period);
    end
   if source.low[period-1]-source.high[period]>=MinGapSize then
    DnGap:set(period, source.high[period], "\226");
   else
    DnGap:setNoData(period);
   end
   end 
end

