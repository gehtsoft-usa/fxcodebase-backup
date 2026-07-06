-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3663

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("New day indicator");
    indicator:description("New day indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("FontSize", "Size of font", "Size of font", 10);
end

local first;
local source = nil;
local Buff;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff=instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clr, first);
end

function Update(period, mode)
   if (period>first) then
    local T1=core.dateToTable(source:date(period));
    local T2=core.dateToTable(source:date(period-1));
    if T1.day~=T2.day then
     local DayName;
     if T1.wday==1 then
      DayName="Su";
     elseif T1.wday==2 then
      DayName="Mo";
     elseif T1.wday==3 then
      DayName="Tu";
     elseif T1.wday==4 then
      DayName="We";
     elseif T1.wday==5 then
      DayName="Th";
     elseif T1.wday==6 then
      DayName="Fr";
     else
      DayName="Sa";
     end 
     Buff:set(period, source.high[period], DayName);
    end
   end 
end

