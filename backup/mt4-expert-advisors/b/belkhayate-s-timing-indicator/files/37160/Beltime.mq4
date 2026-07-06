// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=145708#p145708

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property indicator_separate_window
#property indicator_buffers 2

extern int N=5;
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
   IndicatorName = GenerateIndicatorName("Belkayate timing indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,PrH);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,PrL);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DrawCandle(datetime T, double O, double H, double L, double C)
{
 string ObjName=IndicatorObjPrefix+T;
 double MaxBody=MathMax(O, C);
 double MinBody=MathMin(O, C);
 color CandleColor;
 if (C>=O) CandleColor=Bullish; else CandleColor=Bearish;
 Window=WindowFind(IndicatorName);
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
 double MaH, MaL;
 double avg1, avg2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMin(limit, MaxBars);
 pos=limit;
 while(pos>=0)
 {
  MaH=iMA(NULL, 0, N, 0, MODE_SMA, PRICE_HIGH, pos);
  MaL=iMA(NULL, 0, N, 0, MODE_SMA, PRICE_LOW, pos);
  avg1=(MaH+MaL)/2;
  avg2=(MaH-MaL)/5;
  O=(Open[pos]-avg1)/avg2;
  H=(High[pos]-avg1)/avg2;
  L=(Low[pos]-avg1)/avg2;
  C=(Close[pos]-avg1)/avg2;
  DrawCandle(Time[pos],O,H,L,C);
  PrH[pos]=H;
  PrL[pos]=L;
  pos--;
 } 

 return(0);
}


