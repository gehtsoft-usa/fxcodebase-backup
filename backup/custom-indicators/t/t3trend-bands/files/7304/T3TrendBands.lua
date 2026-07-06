-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3128
-- Id: 2831

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
    indicator:name("T3TrendBands indicator");
    indicator:description("T3TrendBands indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BandBars", "Count of bars for band", "", 28);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 3.5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local BandBars;
local Deviation;
local SmoothPrice;
local SmoothRange;
local BuffTUP=nil;
local BuffMUP=nil;
local BuffBUP=nil;
local BuffTDN=nil;
local BuffMDN=nil;
local BuffBDN=nil;

function Prepare(nameOnly)
    source = instance.source;
    BandBars=instance.parameters.BandBars;
    Deviation=instance.parameters.Deviation;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BandBars .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SmoothPrice = instance:addInternalStream(first, 0);
    SmoothRange = instance:addInternalStream(first, 0);
    BuffTUP = instance:addStream("BuffTUP", core.Dot, name .. ".Top", "Top", instance.parameters.UPclr, first);
    BuffMUP = instance:addStream("BuffMUP", core.Dot, name .. ".Middle", "Middle", instance.parameters.UPclr, first);
    BuffBUP = instance:addStream("BuffBUP", core.Dot, name .. ".Bottom", "Bottom", instance.parameters.UPclr, first);
    BuffTDN = instance:addStream("BuffTDN", core.Dot, name .. ".Top", "Top", instance.parameters.DNclr, first);
    BuffMDN = instance:addStream("BuffMDN", core.Dot, name .. ".Middle", "Middle", instance.parameters.DNclr, first);
    BuffBDN = instance:addStream("BuffBDN", core.Dot, name .. ".Bottom", "Bottom", instance.parameters.DNclr, first);
end

function Update(period, mode)
   if period==first then
    SmoothPrice[period]=source.close[period-1];
    SmoothRange[period]=source.high[period-1]-source.low[period-1];
   elseif period>first then
    SmoothPrice[period]=(SmoothPrice[period-1]*(BandBars-1)+source.close[period-1])/BandBars;
    SmoothRange[period]=(SmoothRange[period-1]*(BandBars-1)+source.high[period-1]-source.low[period-1])/BandBars;
    if SmoothPrice[period]>SmoothPrice[period-1] then
     BuffTUP[period]=SmoothPrice[period]+SmoothRange[period]*Deviation;
     BuffMUP[period]=SmoothPrice[period];
     BuffBUP[period]=SmoothPrice[period]-SmoothRange[period]*Deviation;
    else
     BuffTDN[period]=SmoothPrice[period]+SmoothRange[period]*Deviation;
     BuffMDN[period]=SmoothPrice[period];
     BuffBDN[period]=SmoothPrice[period]-SmoothRange[period]*Deviation;
    end
   end
end

