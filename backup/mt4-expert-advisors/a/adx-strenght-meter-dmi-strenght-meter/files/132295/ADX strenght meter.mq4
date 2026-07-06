// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69581

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

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

input int period = 14; // Period
input string Pairs = "EURUSD,EURJPY,USDJPY,GBPUSD";

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

int init()
{
   IndicatorName = GenerateIndicatorName("ADX Strength Meter");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   string list[];
   StringSplit(Pairs, ',', list);
   string res = "";
   for (int i = 0; i < ArraySize(list); ++i)
   {
      string item = list[i];
      double adxValue = iADX(item, _Period, period, PRICE_CLOSE, MODE_MAIN, 0);
      res += item + ": " + DoubleToString(adxValue, 1) + "; ";
   }
   Comment(res);
   return 0;
}
