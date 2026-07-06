-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9701
-- Id: 5903

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
    indicator:name("Cross VAMA indicator");
    indicator:description("Cross VAMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TypeCrosses", "Type of crosses", "", "both");
    indicator.parameters:addStringAlternative("TypeCrosses", "both", "", "both");
    indicator.parameters:addStringAlternative("TypeCrosses", "above", "", "above");
    indicator.parameters:addStringAlternative("TypeCrosses", "below", "", "below");
    indicator.parameters:addInteger("Number", "Number", "Number", 1);

    indicator.parameters:addString("Periods", "Periods", "", "15,20,45,67,75");
    indicator.parameters:addString("Type", "Type", "", "C");
    indicator.parameters:addStringAlternative("Type", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type", "WEIGHTED", "", "W");
    indicator.parameters:addString("Mode", "Mode", "", "indicator");
    indicator.parameters:addStringAlternative("Mode", "indicator", "", "indicator");
    indicator.parameters:addStringAlternative("Mode", "strategy", "", "strategy");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MAclr", "MA color", "MA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 128, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local sourceT;
local Type;
local Count;
local TypeCrosses;
local Number;
local Periods={};
local Inds={};
local MAs={};
local Buff=nil;
local OneSide;

function PreparePeriods()
 local PeriodStr=instance.parameters.Periods .. '.'; 
 local Length=string.len(PeriodStr);
 local i;
 local TempStr='';
 local Char;
 Count=0;
 for i=1,Length,1 do
  Char=string.sub(PeriodStr,i,i);
  if Char=="1" or Char=="2" or Char=="3" or Char=="4" or Char=="5" or Char=="6" or Char=="7" or Char=="8" or Char=="9" or Char=="0" then
   TempStr=TempStr .. Char;
  else
   if TempStr~='' then
    local Num=tonumber(TempStr);
    if Num~=0 then
     Count=Count+1;
     Periods[Count]=Num;
    end 
    TempStr='';
   end
  end
 end
end

function Prepare(nameOnly)
    PreparePeriods();
    source = instance.source;
    Type=instance.parameters.Type;
    if Type=="O" then
     sourceT=source.open;
    elseif Type=="H" then
     sourceT=source.high;
    elseif Type=="L" then
     sourceT=source.low;
    elseif Type=="C" then
     sourceT=source.close;
    elseif Type=="M" then
     sourceT=source.median;
    elseif Type=="T" then
     sourceT=source.typical;
    else
     sourceT=source.weighted;
    end 
    TypeCrosses=instance.parameters.TypeCrosses;
    Number=instance.parameters.Number;
	
	assert(core.indicators:findIndicator("VAMA") ~= nil, "Please, download and install VAMA.LUA indicator");    
    first = source:first();
    OneSide=instance:addInternalStream(first, 0);
    local i;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Type .. ", " .. instance.parameters.Periods .. ", " .. instance.parameters.TypeCrosses .. ", " .. instance.parameters.Number .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    for i=1,Count,1 do
     local Ind=core.indicators:create("VAMA", source, Periods[i], Type);
     Inds[i]=Ind;
     local MA=instance:addStream("MA" .. i, core.Line, name .. ".MA" .. i, "MA" .. i, instance.parameters.MAclr, first);
     MA:setWidth(instance.parameters.widthLinReg);
     MA:setStyle(instance.parameters.styleLinReg);
     MAs[i]=MA;
	 first = math.max(first, Ind.DATA:first());
    end
    Buff=instance:addStream("Crosses", core.Dot, name .. ".Crosses", "Crosses", instance.parameters.UPclr, first);
    Buff:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
    local i;
    local AllAbove=true;
    local AllBelow=true;
    for i=1,Count,1 do
     Inds[i]:update(mode);
     MAs[i][period]=Inds[i].DATA[period];
     if Inds[i].DATA[period]>=sourceT[period] then
      AllBelow=false;
     end
     if Inds[i].DATA[period]<=sourceT[period] then
      AllAbove=false;
     end
    end
    if AllBelow then
     OneSide[period]=1;
    elseif AllAbove then
     OneSide[period]=-1;
    else
     OneSide[period]=0;
    end
    local Above=true;
    local Below=true;
    for i=0,Number-1,1 do
     if OneSide[period-i]~=1 then
      Above=false;
     end
     if OneSide[period-i]~=-1 then
      Below=false;
     end
    end
    
    if TypeCrosses~="below" and Above and OneSide[period-Number]~=1 then
     if instance.parameters.Mode=="indicator" then
      Buff[period]=sourceT[period];
     else
      Buff[period]=1;
     end  
     Buff:setColor(period,instance.parameters.UPclr);
    elseif TypeCrosses~="above" and Below and OneSide[period-Number]~=-1 then
     if instance.parameters.Mode=="indicator" then
      Buff[period]=sourceT[period];
     else
      Buff[period]=-1;
     end 
     Buff:setColor(period,instance.parameters.DNclr);
    end
 
end

