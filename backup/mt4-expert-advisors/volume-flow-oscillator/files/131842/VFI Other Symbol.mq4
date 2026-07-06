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

input int Length=130;
input double Coeff=0.2;
input double VCoeff=2.5;
input int Smoothing_Length=3;
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

double VFI[];

int init()
{
   IndicatorShortName("Volume Flow oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VFI);

   double temp = iCustom(NULL, 0, "VFI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'VFI' indicator");
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
      double value = iCustom(symbol, tf, "VFI", Length, Coeff, VCoeff, Smoothing_Length, 0, pos);
      VFI[i] = value;
   }
      
   return(0);
}

