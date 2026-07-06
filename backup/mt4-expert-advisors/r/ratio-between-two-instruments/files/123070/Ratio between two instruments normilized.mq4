// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67214

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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT

input string SecondSymbol = "USDJPY";
input bool Inverse = true;
input int period = 14; // Normalization Period

#property indicator_label1 "Ratio between two instruments"

double Ratio_data[], Ratio[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try ++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("Ratio between two instruments");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   IndicatorDigits(Digits);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Ratio);
   SetIndexLabel(0, "Ratio");
   SetIndexDrawBegin(0, 0);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, Ratio_data);

   return (0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

int start()
{
   RefreshRates();

   if (Bars <= 1)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);

   int toSkip = 0;
   for (int pos = Bars - 1 - MathMax(ExtCountedBars, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      if (iClose(SecondSymbol, Period(), pos) != 0)
      {
         if (Inverse)
         {
            Ratio_data[pos] = (Close[pos] / iClose(SecondSymbol, Period(), pos));
         }
         else
         {
            Ratio_data[pos] = (iClose(SecondSymbol, Period(), pos) / Close[pos]);
         }
      }
      else
      {
         Ratio_data[pos] = 0.0;
      }
      if (pos > Bars - 1 - period)
      {
         continue;
      }
      int highestIndex = ArrayMaximum(Ratio_data, period, pos);
      double highest = Ratio_data[highestIndex];
      int lowestIndex = ArrayMinimum(Ratio_data, period, pos);
      double lowest = Ratio_data[lowestIndex];
      Ratio[pos] = (highest - lowest) == 0 ? 0 : ((Ratio_data[pos] - lowest) / (highest - lowest)) * 10;
   }

   return (0);
}

double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}