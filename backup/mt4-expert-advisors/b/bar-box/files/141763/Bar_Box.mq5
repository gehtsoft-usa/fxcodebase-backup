// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71145

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

//#property indicator_separate_window
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input ENUM_TIMEFRAMES tf = PERIOD_D1; // Timeframe
input int count = 5; // How many boxes
input color box_color = Red; // Box color

input int bars_limit = 1000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double out[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("barbox");
   IndicatorSetString(INDICATOR_SHORTNAME, "Bar Box");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(out, EMPTY_VALUE);
   }
   for (int i = 0; i < count; ++i)
   {
      string id = IndicatorObjPrefix + IntegerToString(i);
      if (ObjectFind(0, id) == -1)
      {
         if (ObjectCreate(0, id, OBJ_RECTANGLE, 0, iTime(_Symbol, tf, i), iHigh(_Symbol, tf, i), iTime(_Symbol, tf, i + 1), iLow(_Symbol, tf, i)))
         {
            ObjectSetInteger(0, id, OBJPROP_COLOR, box_color);
            ObjectSetInteger(0, id, OBJPROP_FILL, false);
         }
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, 0, iTime(_Symbol, tf, i));
      ObjectSetDouble(0, id, OBJPROP_PRICE, 0, iHigh(_Symbol, tf, i));
      ObjectSetInteger(0, id, OBJPROP_TIME, 1, iTime(_Symbol, tf, i + 1));
      ObjectSetDouble(0, id, OBJPROP_PRICE, 1, iLow(_Symbol, tf, i));
   }
   return rates_total;
}