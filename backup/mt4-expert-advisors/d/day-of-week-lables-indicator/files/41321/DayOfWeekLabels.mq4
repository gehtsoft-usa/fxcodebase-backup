// Id: 7578
//+------------------------------------------------------------------+
//|                                              DayOfWeekLabels.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern string BeginTime="00:00";
extern string MondayName="Monday";
extern string TuesdayName="Tuesday";
extern string WednesdayName="Wednesday";
extern string ThursdayName="Thursday";
extern string FridayName="Friday";
extern string SaturdayName="Saturday";
extern string SundayName="Sunday";
extern string JanuaryName="January";
extern string FebruaryName="February";
extern string MarchName="March";
extern string AprilName="April";
extern string MayName="May";
extern string JuneName="June";
extern string JulyName="July";
extern string AugustName="August";
extern string SeptemberName="September";
extern string OctoberName="October";
extern string NovemberName="November";
extern string DecemberName="December";
extern bool ShowDayLabels=true;
extern bool ShowMonthLabels=true;
extern bool ShowYear=true;

extern color DayLineColor=Green;
extern int DayLineWidth=2;
extern color DayLabelColor=Yellow;
extern int DayFontSize=10;
extern color MonthLineColor=Red;
extern int MonthLineWidth=3;
extern color MonthLabelColor=LightYellow;
extern int MonthFontSize=15;

int BeginMinutes;
string MondayNameH, TuesdayNameH, WednesdayNameH, ThursdayNameH, FridayNameH, SaturdayNameH, SundayNameH;
string JanuaryNameH, FebruaryNameH, MarchNameH, AprilNameH, MayNameH, JuneNameH, JulyNameH, AugustNameH, SeptemberNameH, OctoberNameH, NovemberNameH, DecemberNameH;

string GetHole(int Length)
{
 int i;
 string Hole="";
 for (i=1;i<=2*Length;i++)
 {
  Hole=StringConcatenate(Hole," ");
 }
 return (Hole);
}

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
    IndicatorName = GenerateIndicatorName("DayOfWeekLabels");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 int Pos=StringFind(BeginTime, ":");
 int BeginH=StrToDouble(StringSubstr(BeginTime,0,Pos-1));
 int BeginM=StrToDouble(StringSubstr(BeginTime,Pos+1));
 BeginMinutes=60*BeginH+BeginM;
 MondayNameH=StringConcatenate(MondayName, GetHole(StringLen(MondayName)));
 TuesdayNameH=StringConcatenate(TuesdayName, GetHole(StringLen(TuesdayName)));
 WednesdayNameH=StringConcatenate(WednesdayName, GetHole(StringLen(WednesdayName)));
 ThursdayNameH=StringConcatenate(ThursdayName, GetHole(StringLen(ThursdayName)));
 FridayNameH=StringConcatenate(FridayName, GetHole(StringLen(FridayName)));
 SaturdayNameH=StringConcatenate(SaturdayName, GetHole(StringLen(SaturdayName)));
 SundayNameH=StringConcatenate(SundayName, GetHole(StringLen(SundayName)));
 JanuaryNameH=StringConcatenate(JanuaryName, GetHole(StringLen(JanuaryName)));
 FebruaryNameH=StringConcatenate(FebruaryName, GetHole(StringLen(FebruaryName)));
 MarchNameH=StringConcatenate(MarchName, GetHole(StringLen(MarchName)));
 AprilNameH=StringConcatenate(AprilName, GetHole(StringLen(AprilName)));
 MayNameH=StringConcatenate(MayName, GetHole(StringLen(MayName)));
 JuneNameH=StringConcatenate(JuneName, GetHole(StringLen(JuneName)));
 JulyNameH=StringConcatenate(JulyName, GetHole(StringLen(JulyName)));
 AugustNameH=StringConcatenate(AugustName, GetHole(StringLen(AugustName)));
 SeptemberNameH=StringConcatenate(SeptemberName, GetHole(StringLen(SeptemberName)));
 OctoberNameH=StringConcatenate(OctoberName, GetHole(StringLen(OctoberName)));
 NovemberNameH=StringConcatenate(NovemberName, GetHole(StringLen(NovemberName)));
 DecemberNameH=StringConcatenate(DecemberName, GetHole(StringLen(DecemberName)));
 return(0);
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 return(0);
}

int DayNumber(int bar)
{
 int DN=TimeDayOfWeek(Time[bar]);
 int Minutes=60*TimeHour(Time[bar])+TimeMinute(Time[bar]);
 if (Minutes<BeginMinutes) DN--;
 if (DN<0) DN=6;
 return (DN);
}

int MonthNumber(int bar)
{
 int MN=TimeMonth(Time[bar]);
 int Minutes=60*TimeHour(Time[bar])+TimeMinute(Time[bar]);
 if (Minutes<BeginMinutes && TimeDay(Time[bar])==1) MN--;
 if (MN<1) MN=12;
 return (MN);
}

string NameOfDay(int DayNum)
{
 if (DayNum==0) return (SundayNameH);
 if (DayNum==1) return (MondayNameH);
 if (DayNum==2) return (TuesdayNameH);
 if (DayNum==3) return (WednesdayNameH);
 if (DayNum==4) return (ThursdayNameH);
 if (DayNum==5) return (FridayNameH);
 return (SaturdayName);
}

string NameOfMonth(int MonthNum, int YearNum)
{
 string MonthName;
 if (MonthNum==1) MonthName=JanuaryNameH;
 if (MonthNum==2) MonthName=FebruaryNameH;
 if (MonthNum==3) MonthName=MarchNameH;
 if (MonthNum==4) MonthName=AprilNameH;
 if (MonthNum==5) MonthName=MayNameH;
 if (MonthNum==6) MonthName=JuneNameH;
 if (MonthNum==7) MonthName=JulyNameH;
 if (MonthNum==8) MonthName=AugustNameH;
 if (MonthNum==9) MonthName=SeptemberNameH;
 if (MonthNum==10) MonthName=OctoberNameH;
 if (MonthNum==11) MonthName=NovemberNameH;
 if (MonthNum==12) MonthName=DecemberNameH;
 if (ShowYear)
 {
  return (YearNum+" "+MonthName);
 }
 else
 {
  return (MonthName);
 }
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 int DN, DN2;
 int MN, MN2, Y;
 string Obj_Name;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (ShowDayLabels)
  {
   DN=DayNumber(pos);
   DN2=DayNumber(pos+1);
   if (DN!=DN2)
   {
    Obj_Name= IndicatorObjPrefix + Time[pos];
    ObjectCreate(Obj_Name+"L", OBJ_VLINE, 0, Time[pos], 0);
    ObjectSet(Obj_Name+"L", OBJPROP_COLOR, DayLineColor);
    ObjectSet(Obj_Name+"L", OBJPROP_WIDTH, DayLineWidth);
    ObjectCreate(Obj_Name+"T", OBJ_TEXT, 0, Time[pos], Low[pos]);
    ObjectSetText(Obj_Name+"T", NameOfDay(DN), DayFontSize, "Arial", DayLabelColor);
    ObjectSet(Obj_Name+"T", OBJPROP_ANGLE, 90);
   }
  }
  if (ShowMonthLabels) 
  {
   MN=MonthNumber(pos);
   MN2=MonthNumber(pos+1);
   Y=TimeYear(Time[pos]);
   if (MN!=MN2)
   {
    Obj_Name=IndicatorObjPrefix + Time[pos];
    ObjectCreate(Obj_Name+"LM", OBJ_VLINE, 0, Time[pos], 0);
    ObjectSet(Obj_Name+"LM", OBJPROP_COLOR, MonthLineColor);
    ObjectSet(Obj_Name+"LM", OBJPROP_WIDTH, MonthLineWidth);
    ObjectCreate(Obj_Name+"TM", OBJ_TEXT, 0, Time[pos], Low[pos]);
    ObjectSetText(Obj_Name+"TM", NameOfMonth(MN, Y), MonthFontSize, "Arial", MonthLabelColor);
    ObjectSet(Obj_Name+"TM", OBJPROP_ANGLE, 90);
   }
  }
  pos--;
 } 

 return(0);
}

