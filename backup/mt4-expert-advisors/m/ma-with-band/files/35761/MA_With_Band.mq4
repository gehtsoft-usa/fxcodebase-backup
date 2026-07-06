//+------------------------------------------------------------------+
//|                                                 MA_With_Band.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 Cyan
#property indicator_color6 Magenta

extern int Method=0;
extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Band_Length=15;
extern double Band_Deviation=2;

double MA[], Upper[], Lower[];
double LowerCloudBuff[], UpperCloudBuff[], MiddleCloudBuff[];

int init()
  {
   IndicatorShortName("MA with Band");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,LowerCloudBuff);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UpperCloudBuff);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,MiddleCloudBuff);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Lower);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MA);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Upper);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Upper[pos]=iBandsOnArray(MA, 0, Band_Length, Band_Deviation, 0, MODE_UPPER, pos);
  Lower[pos]=iBandsOnArray(MA, 0, Band_Length, Band_Deviation, 0, MODE_LOWER, pos);
  LowerCloudBuff[pos]=Lower[pos];
  MiddleCloudBuff[pos]=MA[pos];
  UpperCloudBuff[pos]=Upper[pos];
  pos--;
 } 

 return(0);
}

