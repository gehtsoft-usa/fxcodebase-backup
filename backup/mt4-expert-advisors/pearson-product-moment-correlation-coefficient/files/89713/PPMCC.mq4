//+------------------------------------------------------------------+
//|                                                        PPMCC.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_maximum 1
#property indicator_minimum -1

extern int Length=50;
extern string SymbolX="EURUSD";
extern int PriceX=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern string SymbolY="USDJPY";
extern int PriceY=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  


double PPMCC[];
double C[], D[], AB[];

int init()
{
 IndicatorShortName("Pearson product-moment correlation coefficient");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PPMCC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,C);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,D);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,AB);

 return(0);
}

int deinit()
{

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
 double Avg1, Avg2;
 double A, B;
 int index1, index2;
 pos=limit;
 while(pos>=0)
 {
  index1=iBarShift(SymbolX, 0, Time[pos], false);
  index2=iBarShift(SymbolY, 0, Time[pos], false);
  if (index1!=-1 && index2!=-1)
  {
   Avg1=iMA(SymbolX, 0, Length, 0, MODE_SMA, PriceX, index1);
   Avg2=iMA(SymbolY, 0, Length, 0, MODE_SMA, PriceY, index2);
   A=iMA(SymbolX, 0, 1, 0, MODE_SMA, PriceX, index1)-Avg1;
   B=iMA(SymbolY, 0, 1, 0, MODE_SMA, PriceY, index1)-Avg2;
   AB[pos]=A*B;
   C[pos]=A*A;
   D[pos]=B*B;
  } 
  pos--;
 } 
 
 double Numerator, DenominatorC, DenominatorD, Denominator;
 pos=limit;
 while(pos>=0)
 {
  Numerator=iMAOnArray(AB, 0, Length, 0, MODE_SMA, pos);
  DenominatorC=iMAOnArray(C, 0, Length, 0, MODE_SMA, pos);
  DenominatorD=iMAOnArray(D, 0, Length, 0, MODE_SMA, pos);
  Denominator=MathSqrt(DenominatorC*DenominatorD);
  if (Denominator!=0)
  PPMCC[pos]=Numerator/Denominator;
  pos--;
 }  
 return(0);
}

