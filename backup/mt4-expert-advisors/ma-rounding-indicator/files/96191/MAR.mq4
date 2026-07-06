//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=8;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern double Round=130;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double MAR[];
double MA[], MovAle[];
double MaRo;

int init()
{
 IndicatorShortName("MA Rounding");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MAR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MovAle);
 
 MaRo=Round*Point;

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
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  
  if (MA[pos]>MA[pos+1]+MaRo || MA[pos]<MA[pos+1]-MaRo || MA[pos]>MAR[pos+1]+MaRo || MA[pos]<MAR[pos+1]-MaRo || (MA[pos]>MAR[pos+1] && MovAle[pos+1]==1.) || (MA[pos]<MAR[pos+1] && MovAle[pos+1]==-1.))
  {
   MAR[pos]=MA[pos];
  }
  else
  {
   MAR[pos]=MAR[pos+1];
  }
  
  if (MAR[pos]<MAR[pos+1])
  {
   MovAle[pos]=-1.;
  }
  else
  {
   if (MAR[pos]>MAR[pos+1])
   {
    MovAle[pos]=1.;
   }
   else
   {
    MovAle[pos]=MovAle[pos+1];
   }
  }

  pos--;
 } 
 return(0);
}

