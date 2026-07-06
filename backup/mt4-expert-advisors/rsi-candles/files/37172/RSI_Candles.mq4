//+------------------------------------------------------------------+
//|                                                  RSI_Candles.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2

#define IndName "RSI Candles"

extern int Length=14;
extern int MaxBars=100;
extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;
extern int CandleWidth=3;

double PrH[], PrL[];

int Window;

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
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndName = IndicatorName;

   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,PrH);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,PrL);

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

void DrawCandle(datetime T, double O, double H, double L, double C)
{
 string ObjName=IndicatorObjPrefix + ""+T;
 double MaxBody=MathMax(O, C);
 double MinBody=MathMin(O, C);
 color CandleColor;
 if (C>=O) CandleColor=Bullish; else CandleColor=Bearish;
 Window=WindowFind(IndName);
 if (Window==-1) return;
 if (ObjectFind(ObjName+"R")!=-1)
 {
  ObjectSet(ObjName+"R", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"R", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"R", OBJPROP_PRICE1, O);
  ObjectSet(ObjName+"R", OBJPROP_PRICE2, C);
 }
 else
 {
  ObjectCreate(ObjName+"R", OBJ_TREND, Window, T, O, T, C);
 } 
 ObjectSet(ObjName+"R", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"R", OBJPROP_RAY, false);
 ObjectSet(ObjName+"R", OBJPROP_WIDTH, CandleWidth);
 
 if (ObjectFind(ObjName+"H")!=-1)
 {
  ObjectSet(ObjName+"H", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"H", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"H", OBJPROP_PRICE1, MaxBody);
  ObjectSet(ObjName+"H", OBJPROP_PRICE2, H);
 }
 else
 {
  ObjectCreate(ObjName+"H", OBJ_TREND, Window, T, MaxBody, T, H);
 } 
 ObjectSet(ObjName+"H", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"H", OBJPROP_RAY, false);
 ObjectSet(ObjName+"H", OBJPROP_WIDTH, 1);

 if (ObjectFind(ObjName+"L")!=-1)
 {
  ObjectSet(ObjName+"L", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"L", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"L", OBJPROP_PRICE1, MinBody);
  ObjectSet(ObjName+"L", OBJPROP_PRICE2, L);
 }
 else
 {
  ObjectCreate(ObjName+"L", OBJ_TREND, Window, T, MinBody, T, L);
 } 
 ObjectSet(ObjName+"L", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"L", OBJPROP_RAY, false);
 ObjectSet(ObjName+"L", OBJPROP_WIDTH, 1);
 return;
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 int bar;
 double O, H, L, C;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMin(limit, MaxBars);
 pos=limit;
 while(pos>=0)
 {
  O=iRSI(NULL, 0, Length, PRICE_OPEN, pos);
  H=iRSI(NULL, 0, Length, PRICE_HIGH, pos);
  L=iRSI(NULL, 0, Length, PRICE_LOW, pos);
  C=iRSI(NULL, 0, Length, PRICE_CLOSE, pos);
  DrawCandle(Time[pos],O,H,L,C);
  PrH[pos]=H;
  PrL[pos]=L;
  pos--;
 } 

 return(0);
}


