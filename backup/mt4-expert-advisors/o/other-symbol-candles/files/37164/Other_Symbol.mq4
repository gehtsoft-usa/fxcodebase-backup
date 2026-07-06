//+------------------------------------------------------------------+
//|                                                 Other_Symbol.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2

extern string OtherSymbol="GBPUSD";
extern int MaxBars=100;
extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;
extern int CandleWidth=3;

int Window;

double PrH[], PrL[];

void DrawCandle(datetime T, double O, double H, double L, double C)
{
 Window=WindowFind(IndicatorName);
 if (Window==-1) return;
 string ObjName=IndicatorObjPrefix + ""+Window+T;
 color CandleColor;
 if (C>=O) CandleColor=Bullish; else CandleColor=Bearish;
 if (ObjectFind(ObjName+"B")!=-1)
 {
  ObjectSet(ObjName+"B", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"B", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"B", OBJPROP_PRICE1, O);
  ObjectSet(ObjName+"B", OBJPROP_PRICE2, C);
 }
 else
 {
  ObjectCreate(ObjName+"B", OBJ_TREND, Window, T, O, T, C);
 } 
 ObjectSet(ObjName+"B", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"B", OBJPROP_RAY, false);
 ObjectSet(ObjName+"B", OBJPROP_WIDTH, CandleWidth);
 
 if (ObjectFind(ObjName+"S")!=-1)
 {
  ObjectSet(ObjName+"S", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"S", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"S", OBJPROP_PRICE1, L);
  ObjectSet(ObjName+"S", OBJPROP_PRICE2, H);
 }
 else
 {
  ObjectCreate(ObjName+"S", OBJ_TREND, Window, T, L, T, H);
 } 
 ObjectSet(ObjName+"S", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"S", OBJPROP_RAY, false);
 ObjectSet(ObjName+"S", OBJPROP_WIDTH, 1);

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
    IndicatorName = GenerateIndicatorName("Other symbol chart ("+OtherSymbol+")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
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
  bar=iBarShift(OtherSymbol, 0, Time[pos], true);
  if (bar!=-1)
  {
   O=iOpen(OtherSymbol, 0, bar);
   H=iHigh(OtherSymbol, 0, bar);
   L=iLow(OtherSymbol, 0, bar);
   C=iClose(OtherSymbol, 0, bar);
   PrH[pos]=H;
   PrL[pos]=L;
   DrawCandle(Time[pos],O,H,L,C);
  }
  else
  {
   DrawCandle(Time[pos],EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE);
  } 
  pos--;
 } 

 return(0);
}

