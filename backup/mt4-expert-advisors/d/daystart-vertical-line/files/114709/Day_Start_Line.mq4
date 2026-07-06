// Id: 18981
//+------------------------------------------------------------------+
//|                                               Day_Start_Line.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern int Start_Hour=17; // Hour at start of which the line must be drawn
extern color Line_Color=Red;
extern int Line_Width=3;

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
    IndicatorName = GenerateIndicatorName("Day start line");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

 return(0);
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

 return(0);
}

void DrawLine(int index, string ObjName)
{
 long current_chart_id=ChartID(); 
 if (ObjectFind(current_chart_id, ObjName)==-1)
 {
  ObjectCreate(current_chart_id, ObjName, OBJ_VLINE, 0, Time[index], 0);
 }
 else
 {
  ObjectSet(ObjName, OBJPROP_TIME1, Time[index]);
 }
 ObjectSet(ObjName, OBJPROP_COLOR, Line_Color);
 ObjectSet(ObjName, OBJPROP_WIDTH, Line_Width);
 
 return;
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 string ObjName;
 pos=limit;
 while(pos>=0)
 {
  if (TimeHour(Time[pos])==Start_Hour && TimeMinute(Time[pos])==0)
  {
   ObjName=IndicatorObjPrefix + "DSL_"+Time[pos];
   DrawLine(pos, ObjName);
  }

  pos--;
 } 
 return(0);
}

