//+------------------------------------------------------------------+
//|                                                        VolMA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int RSI_Volume_Period=20;
extern int MA_Period=50;
extern int Price=0;
extern int Method=0;

double VolMA[];
double Vol[];

int init()
  {
   IndicatorShortName("VolMA");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VolMA);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int i, counted=IndicatorCounted();
   if (counted>0) counted--;
   int limit=Bars-counted;
   ArrayResize(Vol, Bars);
   ArraySetAsSeries(Vol, true); 
   ArrayCopy(Vol, Volume);
   
   for (i=0;i<limit;i++)
   {
    double PeriodMA=iRSIOnArray(Vol, 0, RSI_Volume_Period, i)*MA_Period/100;
    PeriodMA=MathMax(PeriodMA,1);
    VolMA[i]=iMA(NULL, 0, PeriodMA, 0, Method, Price, i);
   }

   return(0);
  }

