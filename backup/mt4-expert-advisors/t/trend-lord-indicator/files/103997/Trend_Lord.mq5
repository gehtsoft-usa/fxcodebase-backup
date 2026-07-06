// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=62982

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
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_color1 Green
#property indicator_color2 Red

input int Length = 50; // Length
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price type

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

double TL[], TL_Dn[];
double Array2[];

int SqLength;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("tl");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trend Lord");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, TL, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   ++id;
   SetIndexBuffer(id, TL_Dn, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   ++id;

   SetIndexBuffer(id++, Array2, INDICATOR_CALCULATIONS);
 
   SqLength = MathSqrt(0. + Length);
   MA = iMA(_Symbol, _Period, Length, 0, MODE_LWMA, Price);
   Array1 = iMA(_Symbol, _Period, SqLength, 0, MODE_LWMA, MA);
}

int MA, Array1;

void OnDeinit(const int reason)
{
   IndicatorRelease(MA);
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
      ArrayInitialize(TL, EMPTY_VALUE);
      ArrayInitialize(TL_Dn, EMPTY_VALUE);
      ArrayInitialize(Array2, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      Array2[pos] = Array2[pos - 1];
      double array1[2];
      if (CopyBuffer(Array1, 0, oldPos, 2, array1) != 2)
      {
         continue;
      }
      if (array1[0] > array1[1])
      {
         Array2[pos] = 1.;
      }
      else if (array1[0] < array1[1])
      {
         Array2[pos] = -1.;
      }
      if (Array2[pos] > 0.)
      {
         TL[pos] = array1[0];
         TL_Dn[pos] = 0.;
         if (Array2[pos - 1] < 0.)
         {
            TL[pos - 1] = array1[1];
            TL_Dn[pos - 1] = 0.;
         }
      }
      else if (Array2[pos] < 0.)
      {
         TL[pos] = 0.;
         TL_Dn[pos] = array1[0];
         if (Array2[pos - 1] > 0.)
         {
            TL[pos - 1] = 0.;
            TL_Dn[pos - 1] = array1[1];
         }
      }
   }
   return rates_total;
}