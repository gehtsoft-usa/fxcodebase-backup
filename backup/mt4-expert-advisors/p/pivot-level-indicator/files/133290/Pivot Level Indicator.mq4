// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69755

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
#property indicator_color1 Red

input bool inverse_1 = false; // Inverse symbol 1
input string symbol_1 = "EURUSD"; // Symbol 1
input bool inverse_2 = false; // Inverse symbol 2
input string symbol_2 = "EURCHF"; // Symbol 2
input bool inverse_3 = false; // Inverse symbol 3
input string symbol_3 = "GBPUSD"; // Symbol 3

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

double out[];

int init()
{
   IndicatorName = GenerateIndicatorName("Pivot Level Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "PLI");

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      int index1 = iBarShift(symbol_1, _Period, Time[i]);
      int index2 = iBarShift(symbol_2, _Period, Time[i]);
      int index3 = iBarShift(symbol_3, _Period, Time[i]);
      if (index1 < 0 || index2 < 0 || index3 < 0)
      {
         return 0;
      }
      double price1 = inverse_1 ? 1.0 / iClose(symbol_1, _Period, index1) : iClose(symbol_1, _Period, index1);
      double price2 = inverse_2 ? 1.0 / iClose(symbol_2, _Period, index2) : iClose(symbol_2, _Period, index2);
      double price3 = inverse_3 ? 1.0 / iClose(symbol_3, _Period, index3) : iClose(symbol_3, _Period, index3);
	  
	  
	  
	  
      out[i] = price1 - (price2 + price3);
   }
   return 0;
}
