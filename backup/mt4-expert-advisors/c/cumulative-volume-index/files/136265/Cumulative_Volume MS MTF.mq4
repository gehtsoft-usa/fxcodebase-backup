// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67145

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrMagenta
#property indicator_color2 Green
#property  indicator_width1  2
#property  indicator_width2  2
input int Length=60;
input ENUM_MA_METHOD method = MODE_SMA; // Smoothing method
input bool Combined=true;
input bool Relative=false;
input bool invert = false; // Invert?
input int bars_limit = 1000; // Bars limit
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];

int init()
{
   double temp = iCustom(NULL, 0, "Cumulative_Volume", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Cumulative_Volume' indicator");
      return INIT_FAILED;
   }
   IndicatorShortName("Cumulative Volume");
   IndicatorDigits(Digits);
   if (Combined)
   {
      SetIndexStyle(2,DRAW_LINE);
      SetIndexBuffer(0,Cumulative);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexBuffer(1,Positive);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,Negative);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,APos);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,ANeg);
   }
   else
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(0,Positive);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Negative);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,APos);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,ANeg);
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=Length) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   for (int pos = MathMin(bars_limit, limit); pos >= 0; --pos)
   {
      int index = iBarShift(symbol, timeframe, Time[pos]);
      if (index < 0)
         continue;
      if (Combined)
         Cumulative[pos] = iCustom(symbol, timeframe, "Cumulative_Volume", Length, method, Combined, Relative, invert, bars_limit, 0, index);
      else
      {
         Positive[pos] = iCustom(symbol, timeframe, "Cumulative_Volume", Length, method, Combined, Relative, invert, bars_limit, 0, index);
         Negative[pos] = iCustom(symbol, timeframe, "Cumulative_Volume", Length, method, Combined, Relative, invert, bars_limit, 1, index);
      }
   }
   
   return(0);
}

