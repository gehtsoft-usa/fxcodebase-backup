-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11787
-- Id: 5567

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
    indicator:name("Day of week candles indicator");
    indicator:description("Day of week candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MoClr", "Monday Color", "Monday Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TuClr", "Tuesday Color", "Tuesday Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("WeClr", "Wednesday Color", "Wednesday Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("ThClr", "Thursday Color", "Thursday Color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("FrClr", "Friday Color", "Friday Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SaClr", "Saturday Color", "Saturday Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("SuClr", "Sunday Color", "Sunday Color", core.rgb(128, 255, 55));
end

local first;
local source = nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CCI color candle", "", open, high, low, close);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    
    local D=source:date(period);
    local wday=core.dateToTable(D).wday;
    if wday==1 then
     open:setColor(period,instance.parameters.SuClr)
    elseif wday==2 then
     open:setColor(period,instance.parameters.MoClr)
    elseif wday==3 then
     open:setColor(period,instance.parameters.TuClr)
    elseif wday==4 then
     open:setColor(period,instance.parameters.WeClr)
    elseif wday==5 then
     open:setColor(period,instance.parameters.ThClr)
    elseif wday==6 then
     open:setColor(period,instance.parameters.FrClr)
    else
     open:setColor(period,instance.parameters.SaClr)
    end
 
end

