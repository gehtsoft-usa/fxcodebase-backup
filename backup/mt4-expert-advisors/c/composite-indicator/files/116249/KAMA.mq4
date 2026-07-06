//+------------------------------------------------------------------+
//|                                                         KAMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double KAMA[];
double Pr[], Abs[];

int init()
{
 IndicatorShortName("Kaufman Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,KAMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Abs);
 
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
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Abs[pos]=MathAbs(Pr[pos]-Pr[pos+1]);
  pos--;
 } 
 
 double er, sc;
 pos=limit;
 while(pos>=0)
 {
  er=iMAOnArray(Abs, 0, Length, 0, MODE_SMA, pos)*Length;
  if (er!=0)
  {
   er=MathAbs(Pr[pos]-Pr[pos+Length-1])/er;
  }
  sc=er*0.6015+0.0645;
  sc=sc*sc;
  KAMA[pos]=KAMA[pos+1]+sc*(Pr[pos]-KAMA[pos+1]);
  pos--;
 }  
 
 return(0);
}

