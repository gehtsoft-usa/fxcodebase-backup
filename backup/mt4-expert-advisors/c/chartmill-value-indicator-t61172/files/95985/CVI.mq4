//+------------------------------------------------------------------+
//|                                                          CVI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern bool Use_Modified_Algorithm=false;

double CVI[];
double SqrtLength;

int init()
{
 IndicatorShortName("Chartmill Value Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CVI);
 
 SqrtLength=MathSqrt(Length);

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
 double VC, ATR;
 pos=limit;
 while(pos>=0)
 {
  VC=iMA(NULL, 0, Length, 0, Method, PRICE_MEDIAN, pos);
  ATR=iATR(NULL, 0, Length, pos);
  
  if (ATR!=0.)
  {
   if (Use_Modified_Algorithm)
   {
    CVI[pos]=(Close[pos]-VC)/(ATR*SqrtLength);
   }
   else
   {
    CVI[pos]=(Close[pos]-VC)/ATR;
   } 
  }

  pos--;
 } 
 return(0);
}

