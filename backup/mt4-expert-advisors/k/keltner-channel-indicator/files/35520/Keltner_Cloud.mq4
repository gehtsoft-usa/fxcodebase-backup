//+------------------------------------------------------------------+
//|                                                Keltner_Cloud.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 6
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Yellow
#property indicator_color5 Cyan
#property indicator_color6 Magenta

extern int NM=50;               // Number of the periods to smooth the center line
extern int NB=50;               // Number of periods to smooth deviation
extern double F=1;              // Factor which is used to apply the deviation
extern int SRC=0;               // The center line source
                                // 0 - Close
                                // 1 - Open
                                // 2 - High
                                // 3 - Low
                                // 4 - Median, (High+Low)/2
                                // 5 - Typical, (High+Low+Close)/3
                                // 6 - Weighted, (High+Low+Close+Close)/4
                                
extern int Method=0;            // The center line smoothing method
                                // 0 - Simple
                                // 1 - Exponential
                                // 2 - Smoothed
                                // 3 - Linear weighted

double UpperCloudBuff[], MiddleCloudBuff[], LowerCloudBuff[], UpperBuff[], MiddleBuff[], LowerBuff[];

int init()
  {
   IndicatorShortName("Keltner with color zones");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,LowerCloudBuff);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UpperCloudBuff);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,MiddleCloudBuff);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LowerBuff);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MiddleBuff);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,UpperBuff);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   double v;
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    MiddleBuff[pos]=iMA(NULL, 0, NM, 0, Method, SRC, pos);
    MiddleCloudBuff[pos]=MiddleBuff[pos];
    v=iATR(NULL, 0, NB, pos);
    UpperBuff[pos]=MiddleBuff[pos]+v*F;
    UpperCloudBuff[pos]=UpperBuff[pos];
    LowerBuff[pos]=MiddleBuff[pos]-v*F;
    LowerCloudBuff[pos]=LowerBuff[pos];
    pos--;
   } 
   return(0);
  }

