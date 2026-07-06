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
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Center=50;
extern int Price=5;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

double MFI[];

int init()
{
   IndicatorShortName("Money flow index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MFI);
   SetLevelValue(0, Center);

   double temp = iCustom(NULL, 0, "MFI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'MFI' indicator");
      return INIT_FAILED;
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      int pos = iBarShift(symbol, tf, Time[i]);
      if (pos < 0)
      {
         continue;
      }
      double value = iCustom(symbol, tf, "MFI", Length, Center, Price, 0, pos);
      MFI[i] = value;
   }
      
   return(0);
}

