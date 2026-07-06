// Id: 10990
//+------------------------------------------------------------------+
//|                                               SymbolX_Candle.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2

extern string Instrument="EUR";
extern int MaxBars=100;
extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;
extern int CandleWidth=3;
extern bool Reverse=false;

string Symb;
int Weight;

string Symbols[6];
double Weights[6];

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
 string ObjName=IndicatorObjPrefix + ""+T;
 color CandleColor;
 if (C>=O) CandleColor=Bullish; else CandleColor=Bearish;
 Window=WindowFind("SymbolX index");
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
 
 return;
}  


int init()
  {
   IndicatorName = GenerateIndicatorName("SymbolX index");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,PrH);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,PrL);
   
   Symbols[0]="EURUSD";
   Symbols[1]="USDJPY";
   Symbols[2]="GBPUSD";
   Symbols[3]="USDCAD";
   Symbols[4]="USDSEK";
   Symbols[5]="USDCHF";
   
   Weights[0]=-0.576;
   Weights[1]=0.136;
   Weights[2]=-0.119;
   Weights[3]=0.091;
   Weights[4]=0.042;
   Weights[5]=0.036;

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   return(0);
  }
  
double SymbolCoeff(int Number, int pos, int Price)
{
 string Symb=Symbols[Number];
 datetime T=Time[pos];
 int bar=iBarShift(Symb, 0, T, false);
 double PriceV=iMA(Symb, 0, 1, 0, MODE_SMA, Price, bar);
 double Power=Weights[Number];
 double Coeff=MathPow(PriceV,Power);
 return (Coeff);
}  

void FindSymbol()
{
 Symb="";
 string S;
 if (StringTrimLeft(StringTrimRight(Instrument))=="USD")
 {
  Symb="USD";
  Weight=0;
  return;
 }
 S=StringTrimLeft(StringTrimRight(Instrument))+"USD";
 if (MarketInfo(S, MODE_BID)>0)
 {
  Symb=S;
  Weight=1;
  return;
 }
 S="USD"+StringTrimLeft(StringTrimRight(Instrument));
 if (MarketInfo(S, MODE_BID)>0)
 {
  Symb=S;
  Weight=-1;
  return;
 }
 return;
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 double xO, xC;
 int limit=Bars-2;
 int bar;
 double Price;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMin(limit, MaxBars);
 pos=limit;
 FindSymbol();
 if (Symb=="") return;
 
 while(pos>=0)
 {
  xO=50.14348112;
  xC=50.14348112;
  xO=xO*SymbolCoeff(0, pos, PRICE_OPEN);
  xO=xO*SymbolCoeff(1, pos, PRICE_OPEN);
  xO=xO*SymbolCoeff(2, pos, PRICE_OPEN);
  xO=xO*SymbolCoeff(3, pos, PRICE_OPEN);
  xO=xO*SymbolCoeff(4, pos, PRICE_OPEN);
  xO=xO*SymbolCoeff(5, pos, PRICE_OPEN);

  xC=xC*SymbolCoeff(0, pos, PRICE_CLOSE);
  xC=xC*SymbolCoeff(1, pos, PRICE_CLOSE);
  xC=xC*SymbolCoeff(2, pos, PRICE_CLOSE);
  xC=xC*SymbolCoeff(3, pos, PRICE_CLOSE);
  xC=xC*SymbolCoeff(4, pos, PRICE_CLOSE);
  xC=xC*SymbolCoeff(5, pos, PRICE_CLOSE);
  
  bar=iBarShift(Symb, 0, Time[pos], false);
  Price=iClose(Symb, 0, bar);
  xO=xO*MathPow(Price, Weight);
  xC=xC*MathPow(Price, Weight);
  
  if (Reverse)
  {
   xC=1/xC;
   xO=1/xO;
  }
  PrH[pos]=xC;
  PrL[pos]=xO;
  DrawCandle(Time[pos],xO,xC);
  pos--;
 } 

 return(0);
}



