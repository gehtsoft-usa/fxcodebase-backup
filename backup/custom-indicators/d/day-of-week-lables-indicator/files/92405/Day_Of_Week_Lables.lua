--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=24023 


function Init()
    indicator:name("Day of week lables indicator");
    indicator:description("Day of week lables indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "00:00");
    indicator.parameters:addString("MondayName", "Monday name", "", "Monday");
    indicator.parameters:addString("TuesdayName", "Tuesday name", "", "Tuesday");
    indicator.parameters:addString("WednesdayName", "Wednesday name", "", "Wednesday");
    indicator.parameters:addString("ThursdayName", "Thursday name", "", "Thursday");
    indicator.parameters:addString("FridayName", "Friday name", "", "Friday");
    indicator.parameters:addString("SaturdayName", "Saturday name", "", "Saturday");
    indicator.parameters:addString("SundayName", "Sunday name", "", "Sunday");
    indicator.parameters:addString("JanuaryName", "January name", "", "January");
    indicator.parameters:addString("FebruaryName", "February name", "", "February");
    indicator.parameters:addString("MarchName", "March name", "", "March");
    indicator.parameters:addString("AprilName", "April name", "", "April");
    indicator.parameters:addString("MayName", "May name", "", "May");
    indicator.parameters:addString("JuneName", "June name", "", "June");
    indicator.parameters:addString("JulyName", "July name", "", "July");
    indicator.parameters:addString("AugustName", "August name", "", "August");
    indicator.parameters:addString("SeptemberName", "September name", "", "September");
    indicator.parameters:addString("OctoberName", "October name", "", "October");
    indicator.parameters:addString("NovemberName", "November name", "", "November");
    indicator.parameters:addString("DecemberName", "December name", "", "December");
    indicator.parameters:addBoolean("ShowDayLabels", "Show day labels", "", true);
    indicator.parameters:addBoolean("ShowMonthLabels", "Show Month labels", "", true);
    indicator.parameters:addBoolean("ShowYear", "Show Year", "", true);
	
   indicator.parameters:addGroup("Style");
   
     indicator.parameters:addColor("Color", "Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FontSize", "Day label font size", "Day label font size", 10);
	
   Day(2, "Monday");
   Day(3, "Tuesday");
   Day(4, "Wednesday");
   Day(5, "Thursday");
   Day(6, "Friday");
   Day(7, "Saturday");
   Day(1, "Sunday");

    indicator.parameters:addColor("MLineClr", "Month line Color", "Month line Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MwidthLinReg", "Month line width", "Month line width", 2, 1, 5);
    indicator.parameters:addInteger("MstyleLinReg", "Month line style", "Month line style", core.LINE_DASH);
    indicator.parameters:setFlag("MstyleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MLableClr", "Month lable Color", "Month lable Color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("MFontSize", "Month label font size", "Month label font size", 15);
end

function Day(name, Label)

    indicator.parameters:addColor("Label"..name, Label.."label  Color", "Day lable Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Color"..name, Label.. " line Color", "Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width"..name, Label.." line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style"..name, Label.." line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..name, core.FLAG_LINE_STYLE);

end

local Color;
local first;
local source = nil;
local BeginT;
--local font, fontM;
local ShowDayLabels, ShowMonthLabels, ShowYear;

function Prepare()
    source = instance.source;
	Color=instance.parameters.Color;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    local BeginTime=instance.parameters.BeginTime;
    ShowDayLabels=instance.parameters.ShowDayLabels;
    ShowMonthLabels=instance.parameters.ShowMonthLabels;
    ShowYear=instance.parameters.ShowYear;
    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
	
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
  fontM = core.host:execute("createFont", "Arial", instance.parameters.MFontSize, true, false);
	
	  instance:setLabelColor(Color);
    instance:ownerDrawn(true);
end

function NameOfDay(DayNum)
 if DayNum==1 then
  return instance.parameters.SundayName;
 elseif DayNum==2 then
  return instance.parameters.MondayName;
 elseif DayNum==3 then
  return instance.parameters.TuesdayName;
 elseif DayNum==4 then
  return instance.parameters.WednesdayName;
 elseif DayNum==5 then
  return instance.parameters.ThursdayName;
 elseif DayNum==6 then
  return instance.parameters.FridayName;
 else
  return instance.parameters.SaturdayName;
 end 
end

function NameOfMonth(MonthNum, Year)
 local MonthName;
 if MonthNum==1 then
  MonthName=instance.parameters.JanuaryName;
 elseif MonthNum==2 then
  MonthName=instance.parameters.FebruaryName;
 elseif MonthNum==3 then
  MonthName=instance.parameters.MarchName;
 elseif MonthNum==4 then
  MonthName=instance.parameters.AprilName;
 elseif MonthNum==5 then
  MonthName=instance.parameters.MayName;
 elseif MonthNum==6 then
  MonthName=instance.parameters.JuneName;
 elseif MonthNum==7 then
  MonthName=instance.parameters.JulyName;
 elseif MonthNum==8 then
  MonthName=instance.parameters.AugustName;
 elseif MonthNum==9 then
  MonthName=instance.parameters.SeptemberName;
 elseif MonthNum==10 then
  MonthName=instance.parameters.OctoberName;
 elseif MonthNum==11 then
  MonthName=instance.parameters.NovemberName;
 else
  MonthName=instance.parameters.DecemberName;
 end 
 if ShowYear then
  return MonthName .. " " .. Year;
 else
  return MonthName;
 end
end

function DayNumber(period)
 local D=source:date(period);
 local T=core.dateToTable(D);
 local wday=T.wday;
 local CandleTime=60*T.hour+T.min;
 if CandleTime<BeginT then
  wday=wday-1;
  if wday<1 then
   wday=7;
  end
 end
 return wday;
end

function MonthNumber(period)
 local D=source:date(period);
 local T=core.dateToTable(D);
 local month=T.month;
 local year=T.year;
 local CandleTime=60*T.hour+T.min;
 if CandleTime<BeginT and T.day==1 then
  month=month-1;
  if month<1 then
   month=12;
  end
 end
 return month, year;
end

function Update(period, mode)

end


function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end
	
	if source== nil then
	return;
	end
	
local First, Last;	
First=  math.max(context:firstBar (), first);
Last  =math.min(context:lastBar (),source:size() );
local Max=mathex.max(source.high, First, Last)*2;
	
local period;
for period= First, Last, 1 do

   if (period>first) then
    if ShowDayLabels then
     local DN=DayNumber(period);
     local DN2=DayNumber(period-1);
     if DN2~=DN then
     core.host:execute("drawLine", period, source:date(period), 0, source:date(period), Max, instance.parameters:getDouble("Color"..DN)  , instance.parameters:getInteger("style"..DN) ,  instance.parameters:getInteger("width"..DN));
    core.host:execute("drawLabel1", 2*period, source:date(period), core.CR_CHART, 0, core.CR_CENTER, 0, 0, font, instance.parameters:getInteger("Label"..DN) , NameOfDay(DN));
     
	
	 end
    end 
    if ShowMonthLabels then
      local MN, Y=MonthNumber(period);
      local MN2=MonthNumber(period-1);
      if MN2~=MN then
       core.host:execute("drawLine", period, source:date(period), 0, source:date(period), Max, instance.parameters.MLineClr, instance.parameters.MstyleLinReg, instance.parameters.MwidthLinReg);
       core.host:execute("drawLabel1", 2*period+1, source:date(period), core.CR_CHART, 0, core.CR_TOP, 0, 0, fontM, instance.parameters.MLableClr, NameOfMonth(MN, Y));
      end
    end 
   end 
end

end

