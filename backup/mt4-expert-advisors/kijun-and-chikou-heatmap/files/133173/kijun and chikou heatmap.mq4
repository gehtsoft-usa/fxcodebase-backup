// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69731

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
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_minimum 0
#property indicator_maximum 1

input int tenkan_sen = 9; // Tenkan sen
input int kijun_sen = 26; // Kijun sen
input int senkoi_span_b = 52; // Senkoi span b

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

double out1[], out2[], out3[];
int init()
{
   IndicatorName = GenerateIndicatorName("kijun and chikou");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, out1);
   SetIndexLabel(0, "K>C");

   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, out2);
   SetIndexLabel(1, "K<C");

   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, out3);
   SetIndexLabel(2, "K=C");

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
      out1[i] = EMPTY_VALUE;
      out2[i] = EMPTY_VALUE;
      out3[i] = EMPTY_VALUE;
      double kijun = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_KIJUNSEN, i);
      double chikou = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_CHIKOUSPAN, i);
      if (kijun > chikou)
      {
         out1[i] = 1;
      }
      else if (kijun < chikou)
      {
         out2[i] = 1;
      }
      else
      {
         out3[i] = 1;
      }
   }
   return 0;
}
