// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70500

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
#property indicator_plots 1
#property indicator_type1  DRAW_LINE
#property indicator_color1 Yellow
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "ROC"

input int Length = 20;
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Applied price
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

double ROC[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("roc");
   IndicatorSetString(INDICATOR_SHORTNAME, "Rate of Change");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, ROC, INDICATOR_DATA);
   ++id;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

double GetPrice(const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                int pos)
{
   switch (Price)
   {
      case PRICE_CLOSE:
         return close[pos];
      case PRICE_OPEN:
         return open[pos];
      case PRICE_HIGH:
         return high[pos];
      case PRICE_LOW:
         return low[pos];
      case PRICE_MEDIAN:
         return (high[pos] + low[pos]) / 2.0;
      case PRICE_TYPICAL:
         return (high[pos] + low[pos] + close[pos]) / 3.0;
      case PRICE_WEIGHTED:
         return (high[pos] + low[pos] + close[pos] * 2) / 4.0;
   }
   return 0;
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
      ArrayInitialize(ROC, EMPTY_VALUE);
   }
   int first = Length;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      double pr = GetPrice(open, high, low, close, pos - Length);
      if (pr != 0)
      {
         double currPrice = GetPrice(open, high, low, close, pos);
         ROC[pos] = (currPrice / pr - 1) * 100;
      } 
   }
   return rates_total;
}