//+------------------------------------------------------------------+
//|                                                           VC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;

double Top[], Bottom[];
double T[], B[];

int init()
{
 IndicatorShortName("Volatility Channel");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,T);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,B);

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
 double TypicalPr;
 pos=limit;
 while(pos>=0)
 {
  TypicalPr=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos);
  T[pos]=2.*TypicalPr-High[pos];
  B[pos]=2.*TypicalPr-Low[pos];

  pos--;
 } 
 
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Max=T[ArrayMaximum(T, Length, pos)];
  Min=B[ArrayMinimum(B, Length, pos)];
  
  Top[pos]=MathMax(Max, T[pos]);
  Bottom[pos]=MathMin(Min, B[pos]);

  pos--;
 }
   
 return(0);
}

