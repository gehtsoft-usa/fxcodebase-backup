//+------------------------------------------------------------------+
//|                                                           PC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double PC[];
double Raw[];

int init()
{
 IndicatorShortName("Price Cycle oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Raw[pos]=Close[pos]-Low[pos];
  pos--;
 } 
 
 double MA, ATR;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(Raw, 0, Length, 0, Method, pos);
  ATR=iATR(NULL, 0, Length, pos);
  if (ATR!=0.)
  {
   PC[pos]=100.*MA/ATR;
  } 
  pos--;
 }
   
 return(0);
}

