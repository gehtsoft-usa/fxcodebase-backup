// More information about this indicator can be found at:
// http://fxcodebase.com/


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern bool Use_Modified_Algorithm=false;
extern ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
extern string CurrentSybmol = "EURUSD";


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
  VC=iMA(CurrentSybmol, Timeframe, Length, 0, Method, PRICE_MEDIAN, iBarShift(CurrentSybmol, Timeframe, Time[pos], false));
  ATR=iATR(CurrentSybmol, Timeframe, Length, iBarShift(CurrentSybmol, Timeframe, Time[pos], false));
  
  if (ATR!=0.)
  {
   if (Use_Modified_Algorithm)
   {
    CVI[pos]=(iClose(CurrentSybmol, Timeframe, iBarShift(CurrentSybmol, Timeframe, Time[pos]))-VC)/(ATR*SqrtLength);
   }
   else
   {
    CVI[pos]=(iClose(CurrentSybmol, Timeframe, iBarShift(CurrentSybmol, Timeframe, Time[pos]))-VC)/ATR;
   } 
  }

  pos--;
 } 
 return(0);
}

