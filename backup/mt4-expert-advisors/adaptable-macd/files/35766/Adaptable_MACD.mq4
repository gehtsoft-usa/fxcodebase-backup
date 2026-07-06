//+------------------------------------------------------------------+
//|                                               Adaptable_MACD.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Red

extern int ShortMA=12;
extern int LongMA=26;
extern int SignalPeriod=9;
extern int ShortMethod=0;
extern int LongMethod=0;
extern int SignalMethod=0;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern bool AbsoluteValue=true;

double MACD[], Signal[], HistogramUp[], HistogramDn[];

int init()
  {
   IndicatorShortName("Adaptable MACD");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MACD);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,HistogramUp);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,HistogramDn);

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
 double MA_L, MA_S;
 while(pos>=0)
 {
  MA_L=iMA(NULL, 0, LongMA, 0, LongMethod, Price, pos);
  MA_S=iMA(NULL, 0, ShortMA, 0, ShortMethod, Price, pos);
  if (AbsoluteValue)
  {
   MACD[pos]=MA_S-MA_L;
  }
  else
  {
   if (MA_L!=0) MACD[pos]=(MA_S-MA_L)/MA_L;
  }
  pos--;
 } 
 
 pos=limit;
 double Hist;
 while (pos>=0)
 {
  Signal[pos]=iMAOnArray(MACD, 0, SignalPeriod, 0, SignalMethod, pos);
  Hist=MACD[pos]-Signal[pos];
  if (Hist>HistogramUp[pos+1]+HistogramDn[pos+1])
  {
   HistogramUp[pos]=Hist;
   HistogramDn[pos]=0;
  }
  else
  {
   HistogramUp[pos]=0;
   HistogramDn[pos]=Hist;
  }
  pos--;
 }

 return(0);
}

