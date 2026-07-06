// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70653

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
#property indicator_buffers 0
#property indicator_plots 0

input double max_distance = 2; // Max distance, pips
input color resistance_color = Red; // Resistance color
input color support_color = Green; // Support color

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
   IndicatorObjPrefix = GenerateIndicatorPrefix("sri");
   IndicatorSetString(INDICATOR_SHORTNAME, "Support/resistance indicator");
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
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digit = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = digit == 3 || digit == 5 ? 10 : 1;
   double pipSize = point * mult;

   double resistance_high = high[rates_total - 1];
   double resistance_low = high[rates_total - 1];
   double resistance_summ = high[rates_total - 1];
   for (int pos = rates_total - 2; pos > 0; ++pos)
   {
      if ((high[pos] - resistance_low) / pipSize > max_distance || (resistance_high - high[pos]) / pipSize > max_distance)
      {
         double resistance = resistance_summ / (rates_total - pos - 1);
         string id = IndicatorObjPrefix + "res";
         if (ObjectFind(0, id) == -1)
         {
            if (ObjectCreate(0, id, OBJ_TREND, 0, time[pos], resistance, time[rates_total - 1], resistance))
            {
               ObjectSetInteger(0, id, OBJPROP_COLOR, resistance_color);
               ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
            }
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 0, resistance);
         ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[rates_total - 1]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 1, resistance);
         break;
      }
      resistance_high = MathMax(resistance_high, high[pos]);
      resistance_low = MathMin(resistance_low, high[pos]);
      resistance_summ += high[pos];
   }

   double support_high = low[rates_total - 1];
   double support_low = low[rates_total - 1];
   double support_summ = low[rates_total - 1];
   for (int pos = rates_total - 2; pos > 0; ++pos)
   {
      if ((low[pos] - support_low) / pipSize > max_distance || (support_high - low[pos]) / pipSize > max_distance)
      {
         double support = support_summ / (rates_total - pos - 1);
         string id = IndicatorObjPrefix + "sup";
         if (ObjectFind(0, id) == -1)
         {
            if (ObjectCreate(0, id, OBJ_TREND, 0, time[pos], support, time[rates_total - 1], support))
            {
               ObjectSetInteger(0, id, OBJPROP_COLOR, support_color);
               ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
            }
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 0, support);
         ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[rates_total - 1]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 1, support);
         break;
      }
      support_high = MathMax(support_high, low[pos]);
      support_low = MathMin(support_low, low[pos]);
      support_summ += low[pos];
   }
   return rates_total;
}