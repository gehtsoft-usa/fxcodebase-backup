//+------------------------------------------------------------------+
//|                                                         CMVI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#include <Candles.mqh>

#property indicator_separate_window
#property indicator_buffers 2

#define IndName "CMVI"

extern int Length=5;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern color UpColor=Blue;
extern color DnColor=Red;
extern int MaxBars=200;
extern int CandleWidth=3;

double H[], L[];

int Window;

int init()
{
 IndicatorShortName(IndName);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(0,H);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,L);

 return(0);
}

int deinit()
{
 Window=WindowFind(IndName);
 CandlesDeleteAll(Window);
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
 double MA;
 double ATR;
 double O, C;
 limit=MathMin(limit, MaxBars);
 pos=limit;
 Window=WindowFind(IndName);
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, PRICE_MEDIAN, pos);
  ATR=iATR(NULL, 0, Length, pos);
  if (ATR!=0)
  {
   C=(Close[pos]-MA)/ATR;
   H[pos]=(High[pos]-MA)/ATR;
   L[pos]=(Low[pos]-MA)/ATR;
   O=(Open[pos]-MA)/ATR;
   if (C>=O)
   {
    CandleDraw(Window, Time[pos], O, H[pos], L[pos], C, UpColor, CandleWidth);
   }
   else
   {
    CandleDraw(Window, Time[pos], O, H[pos], L[pos], C, DnColor, CandleWidth);
   } 
  } 
  pos--;
 } 
 return(0);
}

