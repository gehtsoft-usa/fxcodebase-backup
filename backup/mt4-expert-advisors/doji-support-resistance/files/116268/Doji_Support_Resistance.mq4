// Id: 19852
//+------------------------------------------------------------------+
//|                                      Doji_Support_Resistance.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 0

#define IndName "Doji_SR"

extern int Length=100;
extern double Delta=0.;
extern color Zone_Color=Yellow;
extern color SR_Color=Green;

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
    IndicatorName = GenerateIndicatorName("Doji_Support_Resistance");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 IndicatorDigits(Digits);

 return(0);
}

void DeleteRect()
{
 long current_chart_id=ChartID();

 int i;
 int OCount=ObjectsTotal(current_chart_id, EMPTY);
 string ObjName;
 for (i=OCount; i>=0; i--)
 {
  ObjName=ObjectName(i);
  if (ObjectType(ObjName)==OBJ_RECTANGLE || ObjectType(ObjName)==OBJ_TREND)
  {
   if (StringFind(ObjName, IndName)>-1)
   {
    ObjectDelete(current_chart_id, ObjName);
   } 
  }
 }

 return;
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 
 return(0);
}

void DrawRect(int index)
{
 long current_chart_id=ChartID();
 
 double H=High[index];
 double L=Low[index];
 double C=Close[index];
 
 datetime T1=Time[index];
 datetime T2=Time[index-Length];
 
 string ObjName=IndicatorObjPrefix + IndName+"_"+T1;
 
 if (ObjectFind(current_chart_id, ObjName)<0)
 {
  ObjectCreate(current_chart_id, ObjName, OBJ_RECTANGLE, 0, T1, H, T2, L);
  ObjectSet(ObjName, OBJPROP_COLOR, Zone_Color);
 } 

 if (ObjectFind(current_chart_id, ObjName+"_SR")<0)
 {
  ObjectCreate(current_chart_id, ObjName+"_SR", OBJ_TREND, 0, T1, C, T2, C);
  ObjectSet(ObjName+"_SR", OBJPROP_COLOR, SR_Color);
  ObjectSet(ObjName+"_SR", OBJPROP_RAY_RIGHT, false);
 } 
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
 int pos;
 double Range;
 pos=limit;
 while(pos>=1)
 {
  Range=Delta*(High[pos]-Low[pos])/100.;
  
  if (MathAbs(Open[pos]-Close[pos])<=Range)
  {
   DrawRect(pos);
  }

  pos--;
 } 
 return(0);
}

