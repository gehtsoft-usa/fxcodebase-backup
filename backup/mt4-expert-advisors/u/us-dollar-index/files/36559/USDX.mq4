//+------------------------------------------------------------------+
//|                                                         USDX.mq4 |
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

double USDX[];

string Symbols[6];
double Weights[6];

int init()
  {
   IndicatorShortName("USD index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,USDX);
   
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
 double PriceV=iMA(Symb, 0, 1, 0, MODE_SMA, Price, bar);
 double Power=Weights[Number];
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
  x=50.14348112;
  x=x*SymbolCoeff(0, pos);
  x=x*SymbolCoeff(1, pos);
  x=x*SymbolCoeff(2, pos);
  x=x*SymbolCoeff(3, pos);
  x=x*SymbolCoeff(4, pos);
  x=x*SymbolCoeff(5, pos);
  if (Reverse) USDX[pos]=1/x; else USDX[pos]=x;
  pos--;
 } 

 return(0);
}


