// Id: 7091
//+------------------------------------------------------------------+
//|                                             Synthetic_Symbol.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2

extern string Symbol1="";
extern double Weight1=1;
extern string Symbol2="";
extern double Weight2=1;
extern string Symbol3="";
extern double Weight3=1;
extern string Symbol4="";
extern double Weight4=1;
extern string Symbol5="";
extern double Weight5=1;
extern string Symbol6="";
extern double Weight6=1;
extern string Symbol7="";
extern double Weight7=1;
extern string Symbol8="";
extern double Weight8=1;
extern string Symbol9="";
extern double Weight9=1;
extern string Symbol10="";
extern double Weight10=1;
extern int MaxBars=100;
extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;
extern int CandleWidth=3;

double SynthSymbol[];
string Symbols[];
double Weights[];
int Window;
double PrH[], PrL[];

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


void DrawCandle(datetime T, double O, double C)
{
 Window=WindowFind("Synthetic Symbol");
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
 return;
}  

void AddSymbol(string S, double W)
{
 string S_=StringTrimLeft(StringTrimRight(S));
 if (S_!="" && W!=0)
 {
  if (MarketInfo(S_,MODE_DIGITS)>0)
  {
   int ArrSize=ArraySize(Symbols);
   ArrayResize(Symbols,ArrSize+1);
   ArrayResize(Weights,ArrSize+1);
   Symbols[ArrSize]=S_;
   Weights[ArrSize]=W;
  }
  else
  {
   Print("Symbol ",S_," is absent in the market watch!");
  } 
 }
 return;
}

void FillSymbols()
{
 AddSymbol(Symbol1, Weight1);
 AddSymbol(Symbol2, Weight2);
 AddSymbol(Symbol3, Weight3);
 AddSymbol(Symbol4, Weight4);
 AddSymbol(Symbol5, Weight5);
 AddSymbol(Symbol6, Weight6);
 AddSymbol(Symbol7, Weight7);
 AddSymbol(Symbol8, Weight8);
 AddSymbol(Symbol9, Weight9);
 AddSymbol(Symbol10, Weight10);
}

int init()
  {
    IndicatorName = GenerateIndicatorName("Synthetic Symbol");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,PrH);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,PrL);
   FillSymbols();

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
double SymbolCoeff(int i, int pos, int Price)
{
 if (i>=ArraySize(Symbols))
 {
  return (1.);
 }
 else
 {
  string Symb=Symbols[i];
  datetime T=Time[pos];
  int bar=iBarShift(Symb, 0, T, false);
  double PriceV=iMA(Symb, 0, 1, 0, MODE_SMA, Price, bar);
  double Power=Weights[i];
  double Coeff=MathPow(PriceV,Power);
  return (Coeff);
 }
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 double xO, xC;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  xO=1;
  xC=1;
  for (i=0;i<10;i++)
  {
   xO=xO*SymbolCoeff(i, pos, PRICE_OPEN);
   xC=xC*SymbolCoeff(i, pos, PRICE_CLOSE);
  }
  PrH[pos]=xO;
  PrL[pos]=xC;
  DrawCandle(Time[pos],xO,xC);
  pos--;
 } 

 return(0);
}

