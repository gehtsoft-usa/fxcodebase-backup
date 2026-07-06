//+------------------------------------------------------------------+
//|                                                    EMA_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Blue

extern int Fast_Length=21;
extern int Slow_Length=34;
extern int Fast_Method=1;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern int Slow_Method=1;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA

double FH[], FL[], SH[], SL[];

int init()
{
 IndicatorShortName("MA Trend indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FH);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,FL);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,SH);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,SL);

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
  FH[pos]=iMA(NULL, 0, Fast_Length, 0, Fast_Method, PRICE_HIGH, pos);
  FL[pos]=iMA(NULL, 0, Fast_Length, 0, Fast_Method, PRICE_LOW, pos);
  SH[pos]=iMA(NULL, 0, Slow_Length, 0, Slow_Method, PRICE_HIGH, pos);
  SL[pos]=iMA(NULL, 0, Slow_Length, 0, Slow_Method, PRICE_LOW, pos);

  pos--;
 } 
 return(0);
}

