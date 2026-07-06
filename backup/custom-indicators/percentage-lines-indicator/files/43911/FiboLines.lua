-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25535
-- Id: 7844

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
    indicator:name("Fibo lines indicator");
    indicator:description("Fibo lines indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("UpLevels", "UpLevels", "", "1.0023,1.0038,1.005,1.0068");
    indicator.parameters:addString("DnLevels", "DnLevels", "", "0.9977,0.9962,0.995,0.9932");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Cclr", "Central color", "Central color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Uclr", "Upper color", "Upper color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lclr", "Lower color", "Lower color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local UpLevels={};
local DnLevels={};
local LastDay;

function Prepare(nameOnly)
    source = instance.source;
    local Count;
    UpLevels, Count = core.parseCsv(instance.parameters.UpLevels, ",");
    UpLevels.Count = Count;
    DnLevels, Count = core.parseCsv(instance.parameters.DnLevels, ",");
    DnLevels.Count = Count;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LastDay=nil;
 
end

function DrawLevels(Levels, CLevel, clr, C)
 local i;
 local last=source:size()-1;
 local Level;
 for i=0,Levels.Count-1,1 do
  Level=CLevel*Levels[i];
  core.host:execute ("drawLine", C*(i+1), source:date(first), Level, source:date(last), Level, clr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
 end
 return;
end

function Update(period, mode)
   if (period==source:size()-1) then
     local TDay=core.dateToTable(source:date(period));
     local CurrDay=TDay.day;
     if CurrDay~=LastDay then
      TDay.hour, TDay.min, TDay.sec = 0, 0, 0;
      local DayBegin=core.findDate(source, core.tableToDate(TDay), false);
      if DayBegin~=-1 then
       local CLevel=source.open[DayBegin];
       core.host:execute ("drawLine", 0, source:date(first), CLevel, source:date(period), CLevel, instance.parameters.Cclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
       DrawLevels(UpLevels, CLevel, instance.parameters.Uclr, 1);
       DrawLevels(DnLevels, CLevel, instance.parameters.Lclr, -1);
       LastDay=CurrDay;
      end
     end
   end 
end

