// Id: 11896
//+------------------------------------------------------------------+
//|                                                  Trend_Angle.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

#define Pi 3.1415926

extern int Length=14;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern color TrendColor=Yellow; 
extern int Font_Size=10;                      

double TA[];

string ObjName;

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
 IndicatorName = GenerateIndicatorName("Trend Angle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TA);
 ObjName=IndicatorObjPrefix + "Trend_Angle"+Length+Method+Price;

 return(0);
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  TA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  
  pos--;
 } 
 
 double Price1, Price2;
 datetime Time1, Time2;
 Price1=TA[1];
 Price2=TA[0];
 Time1=Time[1];
 Time2=Time[0];
 if (ObjectFind(0, ObjName)==-1)
 {
  ObjectCreate(0, ObjName, OBJ_TREND, 0, Time1, Price1, Time2, Price2);
 }
 else
 {
  if (ObjectGet(ObjName, OBJPROP_TIME1)!=Time1)
  {
   ObjectSet(ObjName, OBJPROP_TIME1, Time1);
  }
  if (ObjectGet(ObjName, OBJPROP_TIME2)!=Time2)
  {
   ObjectSet(ObjName, OBJPROP_TIME2, Time2);
  }
  if (ObjectGet(ObjName, OBJPROP_PRICE1)!=Price1)
  {
   ObjectSet(ObjName, OBJPROP_PRICE1, Price1);
  }
  if (ObjectGet(ObjName, OBJPROP_PRICE2)!=Price2)
  {
   ObjectSet(ObjName, OBJPROP_PRICE2, Price2);
  }
 }
 if (ObjectGet(ObjName, OBJPROP_COLOR)!=TrendColor)
 {
  ObjectSet(ObjName, OBJPROP_COLOR, TrendColor);
 }
 
 double Angle;
 string AngleStr;
 int x1, x2, y1, y2;
 ChartTimePriceToXY(0, 0, Time[10], 10.*Price1-9.*Price2, x1, y1);
 ChartTimePriceToXY(0, 0, Time2, Price2, x2, y2);
 Angle=90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi;
 AngleStr=DoubleToString(Angle, 2);
 
 if (ObjectFind(0, ObjName+"T")==-1)
 {
  ObjectCreate(0, ObjName+"T", OBJ_TEXT, 0, Time2, Price2);
 }
 else
 {
  if (ObjectGet(ObjName+"T", OBJPROP_TIME1)!=Time2)
  {
   ObjectSet(ObjName+"T", OBJPROP_TIME1, Time2);
  }
  if (ObjectGet(ObjName+"T", OBJPROP_PRICE1)!=Price2)
  {
   ObjectSet(ObjName+"T", OBJPROP_PRICE1, Price2);
  }
 } 
 ObjectSetText(ObjName+"T", AngleStr, Font_Size, NULL, TrendColor);
 
 return(0);
}

