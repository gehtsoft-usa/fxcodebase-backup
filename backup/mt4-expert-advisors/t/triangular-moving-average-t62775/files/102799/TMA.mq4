//+------------------------------------------------------------------+
//|                                                          TMA.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TMA[];
double WMA[];
int len;

int init()
{
 IndicatorShortName("TMA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,WMA);
 
 len=MathFloor(Length/2)+1;

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
  WMA[pos]=iMA(NULL, 0, len, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  TMA[pos]=iMAOnArray(WMA, 0, len, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

