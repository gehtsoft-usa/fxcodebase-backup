//+------------------------------------------------------------------+
//|                                                         DEMA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red

extern int Length=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DEMA[], EMA[];

int init()
  {
   IndicatorShortName("Double exponential moving average");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,DEMA);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,EMA);

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
  EMA[pos]=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
  pos--;
 }
 
 pos=limit;
 while (pos>=0) 
 {
  DEMA[pos]=2*EMA[pos]-iMAOnArray(EMA, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }

 return(0);
}

