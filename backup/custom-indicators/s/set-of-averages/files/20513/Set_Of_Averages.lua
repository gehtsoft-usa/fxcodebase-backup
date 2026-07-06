
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9568

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

function Init()
    indicator:name("Set_Of_Averages indicator");
    indicator:description("Set_Of_Averages indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addString("Periods", "Periods", "", "15,20,45,67,75");
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("Signal Style");
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Method;
local ColorMode;
local Count;
local Periods={};
local Inds={};
local Buffs={};
local font;
local Size;
local MIN,MAX;
local UpTrendColor, DownTrendColor;
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

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Prepare(nameOnly)
    PreparePeriods();
    source = instance.source;
    Method=instance.parameters.Method;
    ColorMode=instance.parameters.ColorMode;
	Size=instance.parameters.Size;
	DownTrendColor=instance.parameters.DownTrendColor;
	UpTrendColor=instance.parameters.UpTrendColor;
	
	MIN = instance:addInternalStream(0, 0);
	MAX = instance:addInternalStream(0, 0);
	
		
	  font = core.host:execute("createFont", "Wingdings", Size, false, false);
    first = source:first();
    local i;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Periods .. ")";
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    for i=1,Count,1 do
     local Ind=core.indicators:create("AVERAGES", source, Method, Periods[i], false);
	  first = math.max(first,Ind.DATA:first());
     Inds[i]=Ind;
     local Buff=instance:addStream("MA" .. i, core.Line, name .. ".MA" .. i, "MA" .. i, instance.parameters.MainClr, first);
     Buff:setWidth(instance.parameters.widthLinReg);
     Buff:setStyle(instance.parameters.styleLinReg);
     Buffs[i]=Buff;
    end
    
end

function Update(period, mode)
   if (period>first) then
    local i;
    for i=1,Count,1 do
     Inds[i]:update(mode);
     Buffs[i][period]=Inds[i].DATA[period];
	 
	 
	 if i==1 then
	 MIN[period]=Buffs[i][period]; 
	 MAX[period]=Buffs[i][period]; 
	 else
	  MIN[period]=math.min( MIN[period] , Buffs[i][period]); 
	 MAX[period]=math.max( MIN[period] , Buffs[i][period]); 
	 end
	 
     if ColorMode then
      if Buffs[i][period]<Buffs[i][period-1] then
       Buffs[i]:setColor(period,instance.parameters.DNclr)
      else
       Buffs[i]:setColor(period,instance.parameters.UPclr)
      end
     end
    end
   end 
   
   
  core.host:execute ("removeLabel", source:serial(period)); 
  
   if source[period] > MAX[period] 
   and source[period-1] <= MAX[period-1] 
   then
   core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, MAX[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\108");
   elseif source[period] < MIN[period]
   and source[period-1]  >= MIN[period-1]
   then
   core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, MIN[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\108");		
   end
end

