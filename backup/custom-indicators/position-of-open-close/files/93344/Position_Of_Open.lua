-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60486
-- Id: 11417

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
    indicator:name("Position of Open indicator");
    indicator:description("Position of Open indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("MinPos", "Min. position, from Low to High, %", "", 75, 0, 100);
    indicator.parameters:addDouble("MaxPos", "Max. position, from Low to High, %", "", 100, 0, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));    
    indicator.parameters:addColor("clrDefaultUp", "Default UP bar color", "Default UP bar color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDefaultDn", "Default DN bar color", "Default DN bar color", core.COLOR_DOWNCANDLE);
end

local first;
local source = nil;
local MinPos;
local MaxPos;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)
    source = instance.source;
    MinPos=instance.parameters.MinPos/100;
    MaxPos=instance.parameters.MaxPos/100;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinPos .. ", " .. instance.parameters.MaxPos .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    instance:setLabelColor(instance.parameters.clr);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("PositionOfClose", "", open, high, low, close);
end

function Update(period, mode)
   if period>=first then
     open[period]=source.open[period];
     close[period]=source.close[period];
     high[period]=source.high[period];
     low[period]=source.low[period];
     local Range=high[period]-low[period];
     local Min=low[period]+Range*MinPos;
     local Max=low[period]+Range*MaxPos;
     
     if open[period]>=Min and open[period]<=Max then
      open:setColor(period, instance.parameters.clr);
     elseif close[period]>=open[period] then
      open:setColor(period, instance.parameters.clrDefaultUp);
     else
      open:setColor(period, instance.parameters.clrDefaultDn);
     end
   end 
end

