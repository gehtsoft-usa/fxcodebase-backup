//+------------------------------------------------------------------+
//|                                              MACD_Flat_Trend.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int MACD_Fast=12;
extern int MACD_Slow=26;
extern int MACD_Signal=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted

double UP[], DN[], FL[];
double MACD[];

int init()
{
 IndicatorShortName("MACD Flat Trend");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,FL);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MACD);

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
 double SMA, FMA;
 pos=limit;
 while(pos>=0)
 {
  SMA=iMA(NULL, 0, MACD_Slow, 0, MODE_EMA, Price, pos);
  FMA=iMA(NULL, 0, MACD_Fast, 0, MODE_EMA, Price, pos);
  
  MACD[pos]=FMA-SMA;

  pos--;
 } 
 
 double Signal;
 pos=limit;
 while(pos>=0)
 {
  Signal=iMAOnArray(MACD, 0, MACD_Signal, 0, MODE_SMA, pos);
  
  UP[pos]=0.;
  DN[pos]=0.;
  FL[pos]=0.;
  
  if (Signal<MACD[pos] && MACD[pos]>0.)
  {
   UP[pos]=1000.;
  }
  else
  {
   if (Signal>MACD[pos] && MACD[pos]<0.)
   {
    DN[pos]=1000.;
   }
   else
   {
    FL[pos]=1000.;
   }
  }
  
  pos--;
 }
   
 return(0);
}

