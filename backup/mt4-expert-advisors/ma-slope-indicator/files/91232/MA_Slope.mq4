//+------------------------------------------------------------------+
//|                                                     MA_Slope.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=50;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern double Slope=0;
extern int Slope_Length=1;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double MA_Slope[], MA_Slope_UP[], MA_Slope_DN[];

int init()
{
 IndicatorShortName("MA Slope indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA_Slope);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA_Slope_UP);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MA_Slope_DN);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Slope_Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Sl;
 pos=limit;
 while(pos>=0)
 {
  MA_Slope[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  Sl=(MA_Slope[pos]-iMA(NULL, 0, Length, 0, Method, Price, pos+Slope_Length))/Point;
  if (Sl>Slope)
  {
   MA_Slope_UP[pos]=MA_Slope[pos];
   MA_Slope_UP[pos+1]=MA_Slope[pos+1];
  }
  else
  {
   if (Sl<-Slope)
   {
    MA_Slope_DN[pos]=MA_Slope[pos];
    MA_Slope_DN[pos+1]=MA_Slope[pos+1];
   }
  }
  pos--;
 } 
 return(0);
}

