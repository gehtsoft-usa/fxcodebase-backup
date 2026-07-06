//+------------------------------------------------------------------+
//|                                                      SymbolX.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string Instrument="EUR";

double SymbolX[];
string Symb;
int Weight;

string Symbols[6];
double Weights[6];

int init()
  {
   IndicatorShortName(Instrument+" index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,SymbolX);
   
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

   return(0);
  }
  
double SymbolCoeff(int Number, int pos)
{
 string Symb=Symbols[Number];
 datetime T=Time[pos];
 int bar=iBarShift(Symb, 0, T, false);
 double Price=iClose(Symb, 0, bar);
 double Power=Weights[Number];
 double Coeff=MathPow(Price,Power);
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
 double x;
 double Price;
 int bar;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 FindSymbol();
 if (Symb=="") return;
 
 while(pos>=0)
 {
  x=50.14348112;
  x=x*SymbolCoeff(0, pos);
  x=x*SymbolCoeff(1, pos);
  x=x*SymbolCoeff(2, pos);
  x=x*SymbolCoeff(3, pos);
  x=x*SymbolCoeff(4, pos);
  x=x*SymbolCoeff(5, pos);
  
  bar=iBarShift(Symb, 0, Time[pos], false);
  Price=iClose(Symb, 0, bar);
  SymbolX[pos]=x*MathPow(Price, Weight);
  
  pos--;
 } 

 return(0);
}


