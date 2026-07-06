//+------------------------------------------------------------------+
//|                                               Unsmoothed_RSI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double U_RSI[];
double Pos[], Neg[];

int init()
{
 IndicatorShortName("Unsmoothed RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,U_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pos);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Neg);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Diff;
 pos=limit;
 while(pos>=0)
 {
  Diff=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  if (Diff>0)
  {
   Pos[pos]=Diff;
   Neg[pos]=0;
  }
  else
  {
   Pos[pos]=0;
   Neg[pos]=-Diff;
  }
  pos--;
 } 
 
 double P, N;
 pos=limit;
 while(pos>=0)
 {
  P=iMAOnArray(Pos, 0, Length, 0, MODE_SMA, pos);
  N=iMAOnArray(Neg, 0, Length, 0, MODE_SMA, pos);
  if (N==0)
  {
   U_RSI[pos]=0;
  }
  else
  {
   U_RSI[pos]=100-(100/(1+P/N));
  }
  pos--;
 }  
 return(0);
}

