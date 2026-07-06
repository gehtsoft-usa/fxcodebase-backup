-- Id: 9078
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36114

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Day&Time indicator");
    indicator:description("Day&Time indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Day", "Day", "", "2");
    indicator.parameters:addStringAlternative("Day", "Sunday", "", "1");
    indicator.parameters:addStringAlternative("Day", "Monday", "", "2");
    indicator.parameters:addStringAlternative("Day", "Tuesday", "", "3");
    indicator.parameters:addStringAlternative("Day", "Wednesday", "", "4");
    indicator.parameters:addStringAlternative("Day", "Thursday", "", "5");
    indicator.parameters:addStringAlternative("Day", "Friday", "", "6");
    indicator.parameters:addStringAlternative("Day", "Saturday", "", "7");
    indicator.parameters:addInteger("Hour", "Hour", "", 11);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

local first;
local source = nil;
local Day;
local Hour;
local Up=nil;
local Dn=nil;

function Prepare(nameOnly)
    source = instance.source;
    Day=tonumber(instance.parameters.Day);
    Hour=instance.parameters.Hour;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Day .. ", " .. instance.parameters.Hour .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Up = instance:createTextOutput("Up", "Up", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    Dn = instance:createTextOutput("Dn", "Dn", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
end

function Update(period, mode)
   if period>first then
    local t=core.dateToTable(source:date(period));
    local t2=core.dateToTable(source:date(period-1));
    if t.wday==Day and t.hour==Hour and t2.hour~=Hour then
     t.hour=0;
     t.min=0;
     t.sec=0;
     local prevDay=core.tableToDate(t)-1;
     local prevDayBar=core.findDate(source, prevDay, false);
     local prevDayOpen=source.open[prevDayBar];
     if source.close[period-1]<prevDayOpen then
      Up:set(period, source.low[period], "\225");
     elseif source.close[period-1]>prevDayOpen then
      Dn:set(period, source.high[period], "\226");
     end
    end
   end 
end

