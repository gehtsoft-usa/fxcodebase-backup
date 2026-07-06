//+------------------------------------------------------------------+
//|                                                         EURX.mq4 |
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
extern bool Reverse=false;

double EURX[];

string Symbols[5];
double Weights[5];
double Sign[5];

int init()
  {
   IndicatorShortName("EUR index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,EURX);
   
   Symbols[0]="EURUSD";
   Symbols[1]="EURGBP";
   Symbols[2]="EURJPY"; 
   Symbols[3]="EURSEK";
   Symbols[4]="EURCHF";
   
   Weights[0]=0.3155;
   Weights[1]=0.3056;
   Weights[2]=0.1891;
   Weights[3]=0.0785;
   Weights[4]=0.1113;
   
   Sign[0]=1.0000;
   Sign[1]=1.0000;
   Sign[2]=1.0000;
   Sign[3]=1.0000;
   Sign[4]=1.0000;

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
 double PriceV=iMA(Symb, 0, 1, 0, MODE_SMA, Price, bar);
 double Power=Weights[Number]*Sign[Number];
 double Coeff=MathPow(PriceV,Power);
 return (Coeff);
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 double x;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  x=34.38805726;
  x=x*SymbolCoeff(0, pos);
  x=x*SymbolCoeff(1, pos);
  x=x*SymbolCoeff(2, pos);
  x=x*SymbolCoeff(3, pos);
  x=x*SymbolCoeff(4, pos);
  if (Reverse) EURX[pos]=1/x; else EURX[pos]=x;
  pos--;
 } 

 return(0);
}


