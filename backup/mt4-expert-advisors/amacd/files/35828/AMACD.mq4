// Id: 6867
//+------------------------------------------------------------------+
//|                                                        AMACD.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Red

extern int BeforeShort=6;
extern int BeforeLong=13;
extern int ForwardShort=6;
extern int ForwardLong=13;
extern int SignalLength=5;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double MACD[], Signal[], HistogramUp[], HistogramDn[];

int init()
  {
       double temp = iCustom(NULL, 0, "AMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'AMA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("AMACD");
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
 int limit=Bars-2-MathMax(BeforeLong, BeforeShort);
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MACD[pos]=iCustom(NULL, 0, "AMA", BeforeShort, ForwardShort, Price, 0, pos)-iCustom(NULL, 0, "AMA", BeforeLong, ForwardLong, Price, 0, pos);
  pos--;
 } 
 
 pos=limit;
 double Hist;
 while (pos>=0)
 {
  Signal[pos]=iMAOnArray(MACD, 0, SignalLength, 0, MODE_SMA, pos);
  Hist=MACD[pos]-Signal[pos];
  if (Hist>=HistogramUp[pos+1]+HistogramDn[pos+1])
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

