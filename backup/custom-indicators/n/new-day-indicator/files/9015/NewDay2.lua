--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("New day indicator");
    indicator:description("New day indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TimeShift", "TimeShift in hours", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("FontSize", "Size of font", "Size of font", 10);
end

local first;
local source = nil;
local Buff;
local TimeShift;

function Prepare()
    source = instance.source;
    TimeShift=instance.parameters.TimeShift;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    Buff=instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clr, first);
end

function Update(period, mode)
   if (period>first) then
    local T1=core.dateToTable(source:date(period)+TimeShift/24);
    local T2=core.dateToTable(source:date(period-1)+TimeShift/24);
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

