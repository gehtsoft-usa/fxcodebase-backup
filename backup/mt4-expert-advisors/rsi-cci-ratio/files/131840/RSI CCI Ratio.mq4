// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69516

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

input int Period1 = 14; // CCI Period
input int Period2 = 14; // RSI Period
input bool Reverse = false; // Reverse

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double Oscillator[];

int init()
{
   IndicatorName = GenerateIndicatorName("RSI CCI Ratio");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Oscillator);
   SetIndexLabel(0, "Oscillator");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double cciValue = iCCI(_Symbol, _Period, Period1, PRICE_CLOSE, i);
      double rsiValue = iRSI(_Symbol, _Period, Period2, PRICE_CLOSE, i);
      if (Reverse)
      {
         if (rsiValue != 0)
         {
            Oscillator[i] = cciValue / rsiValue;
         }
      }
      else
      {
         if (cciValue)
         {
            Oscillator[i] = rsiValue / cciValue;
         }
      }
   }
   return 0;
}
