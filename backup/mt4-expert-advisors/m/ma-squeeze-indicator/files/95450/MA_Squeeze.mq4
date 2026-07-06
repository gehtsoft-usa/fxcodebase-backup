//+------------------------------------------------------------------+
//|                                                   MA_Squeeze.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue

extern int MA1_Length=5;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA1_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted 
extern int MA2_Length=21;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted 
extern bool ATR_Enable=true;
extern int ATR_Length=50;
extern double ATR_Coeff=0.4;
extern int Threshold_Pips=15;                           

double MA1[], MA2[], Sq1[], Sq2[];

int init()
{
 IndicatorShortName("MA Squeeze indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Sq1);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Sq2);

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
 double ATR, Delta;
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMA(NULL, 0, MA1_Length, 0, MA1_Method, MA1_Price, pos);
  MA2[pos]=iMA(NULL, 0, MA2_Length, 0, MA2_Method, MA2_Price, pos);
  
  if (ATR_Enable)
  {
   ATR=iATR(NULL, 0, ATR_Length, pos);
   Delta=ATR*ATR_Coeff;
  }
  else
  {
   Delta=Threshold_Pips*Point;
  }
  
  if (MathAbs(MA1[pos]-MA2[pos])<Delta)
  {
   Sq1[pos]=MA2[pos]+Delta;
   Sq2[pos]=MA2[pos]-Delta;
  }
  else
  {
   Sq1[pos]=EMPTY_VALUE;
   Sq2[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

