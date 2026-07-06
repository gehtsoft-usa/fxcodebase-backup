// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=68302

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

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 3
#property indicator_color1 Green,Red
#property indicator_type1  DRAW_COLOR_LINE
#property indicator_color2 Snow
#property indicator_color3 DeepSkyBlue,Blue,Red,Maroon 
#property indicator_type3  DRAW_COLOR_HISTOGRAM
#include <MovingAverages.mqh>

input int FastEMA=12;
input int SlowEMA=26;
input int SignalEMA=9;
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price type
input ENUM_MA_METHOD MA_Type = MODE_EMA; // Smoothing method
input bool Show_MACD = true;	
input bool Show_Signal = true;		 	 
input bool Show_Histogram = true;		 

double MACD[], Signal[], Histogram[];
double Histogram_color[];
double MACD_color[];

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
int ma_fast;
int ma_slow;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("macdci");
   IndicatorSetString(INDICATOR_SHORTNAME, "MACD Custom Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, MACD, Show_MACD ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   SetIndexBuffer(1, MACD_color, INDICATOR_COLOR_INDEX);

   SetIndexBuffer(2, Signal, Show_Signal ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, Histogram, Show_Histogram ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, Histogram_color, INDICATOR_COLOR_INDEX);

   ma_fast = iMA(_Symbol, _Period, FastEMA, 0, MA_Type, Price);
   ma_slow = iMA(_Symbol, _Period, SlowEMA, 0, MA_Type, Price);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(ma_fast);
   IndicatorRelease(ma_slow);
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
   int first = MathMax(ma_fast, ma_slow);
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double fast[1];
      if (CopyBuffer(ma_fast, 0, oldPos, 1, fast) != 1)
      {
         continue;
      }
      double slow[1];
      if (CopyBuffer(ma_slow, 0, oldPos, 1, slow) != 1)
      {
         continue;
      }
      MACD[pos] = fast[0] - slow[0];
   }
   int weightsum;
   switch (MA_Type)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, first, SignalEMA, MACD, Signal);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, first, SignalEMA, MACD, Signal);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, first, SignalEMA, MACD, Signal);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, first, SignalEMA, MACD, Signal, weightsum);
         break;
   }
   first += SignalEMA;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      MACD_color[pos] = MACD[pos] > Signal[pos] ? 0 : 1;
      Histogram[pos] = MACD[pos] - Signal[pos];
      if (Histogram[pos] > 0)
      {
         Histogram_color[pos] = Histogram[pos] > Histogram[pos - 1] ? 0 : 1;
      }
      else
      {
         Histogram_color[pos] = Histogram[pos] > Histogram[pos - 1] ? 2 : 3;
      }
   }
   return rates_total;
}