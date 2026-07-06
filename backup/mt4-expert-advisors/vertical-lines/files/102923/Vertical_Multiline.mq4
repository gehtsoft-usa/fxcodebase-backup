// Id: 14957
//+------------------------------------------------------------------+
//|                                           Vertical_Multiline.mq4 |
//|                               Copyright � 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern string Periods="1,3,5,7,12";
extern color Line_Color=Green;
extern int Line_Width=3;

int ArrPeriods[1000];
int CountPeriods;

void ParsePeriods()
{
 CountPeriods=0;
 string Str=StringTrimLeft(StringTrimRight(Periods))+",";
 int Pos;
 while (Str!="")
 {
  Pos=StringFind(Str, ",");
  ArrPeriods[CountPeriods]=StrToInteger(StringSubstr(Str, 0, Pos));
  Str=StringSubstr(Str, Pos+1, 0);
  CountPeriods++;
 }
 return;
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
 IndicatorName = GenerateIndicatorName("Vertical Multiline");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 IndicatorDigits(Digits);
 
 ParsePeriods();

 return(0);
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

 return(0);
}

void CheckLine(string ON, int index)
{
 if (ObjectFind(0, IndicatorObjPrefix + ON)<0)
 {
  ObjectCreate(0, IndicatorObjPrefix + ON, OBJ_VLINE, 0, Time[index], 0);
  ObjectSet(IndicatorObjPrefix + ON, OBJPROP_COLOR, Line_Color);
  ObjectSet(IndicatorObjPrefix + ON, OBJPROP_WIDTH, Line_Width);
 }
 else
 {
  int _Time;
  _Time=ObjectGet(IndicatorObjPrefix + ON, OBJPROP_TIME1);
  if (Time[index]!=_Time)
  {
   ObjectSet(IndicatorObjPrefix + ON, OBJPROP_TIME1, Time[index]);
   ObjectSet(IndicatorObjPrefix + ON, OBJPROP_COLOR, Line_Color);
   ObjectSet(IndicatorObjPrefix + ON, OBJPROP_WIDTH, Line_Width);
  }
 }

 return;
}

int start()
{
 int i;
 string ObjName;
 for (i=0;i<CountPeriods;i++)
 {
  ObjName="VML"+i;
  CheckLine(ObjName, ArrPeriods[i]);
 }

 return(0);
}

