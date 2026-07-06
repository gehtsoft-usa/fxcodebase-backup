//+------------------------------------------------------------------+
//|                                                  ZeroLagMACD.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int FastPeriod=12;
extern int SlowPeriod=24;
extern int SignalPeriod=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double MACD[], Signal[], Histogram[];
double FastMA[], SlowMA[], SignalMA[];

int init()
  {
   IndicatorShortName("Zero lag MACD");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MACD);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Histogram);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,FastMA);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,SlowMA);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,SignalMA);

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
  FastMA[pos]=iMA(NULL, 0, FastPeriod, 0, MODE_EMA, Price, pos);
  SlowMA[pos]=iMA(NULL, 0, SlowPeriod, 0, MODE_EMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MACD[pos]=(2*FastMA[pos]-iMAOnArray(FastMA, 0, FastPeriod, 0, MODE_EMA, pos)-2*SlowMA[pos]+iMAOnArray(SlowMA, 0, SlowPeriod, 0, MODE_EMA, pos))/Point;
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  SignalMA[pos]=iMAOnArray(MACD, 0, SignalPeriod, 0, MODE_EMA, pos);
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=2*SignalMA[pos]-iMAOnArray(SignalMA, 0, SignalPeriod, 0, MODE_EMA, pos);
  Histogram[pos]=MACD[pos]-Signal[pos];
  pos--;
 }  

 return(0);
}

