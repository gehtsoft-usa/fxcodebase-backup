//+------------------------------------------------------------------+
//|                                                    Blau_MACD.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Blau_MACD[];
double MACD[];

int init()
{
 IndicatorShortName("William Blau MACD");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Blau_MACD);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MACD);

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
  MACD[pos]=iMA(NULL, 0, Smooth_Length2, 0, MODE_EMA, Price, pos)-iMA(NULL, 0, Smooth_Length1, 0, MODE_EMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Blau_MACD[pos]=iMAOnArray(MACD, 0, Smooth_Length3, 0, MODE_EMA, pos);
  pos--;
 }  

 return(0);
}

