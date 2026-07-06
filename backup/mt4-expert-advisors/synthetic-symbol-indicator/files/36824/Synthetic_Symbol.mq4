//+------------------------------------------------------------------+
//|                                             Synthetic_Symbol.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
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

double SynthSymbol[];
string Symbols[];
double Weights[];

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
   IndicatorShortName("Synthetic Symbol");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,SynthSymbol);
   FillSymbols();

   return(0);
  }

int deinit()
  {

   return(0);
  }
  
double SymbolCoeff(int i, int pos)
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
 double x;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  x=1;
  for (i=0;i<10;i++)
  {
   x=x*SymbolCoeff(i, pos);
  }
  SynthSymbol[pos]=x;
  pos--;
 } 

 return(0);
}

