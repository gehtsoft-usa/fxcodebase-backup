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

input int Number = 10; // Number of MAs
input int Length = 2; // MA Period
input ENUM_MA_METHOD MA_Method = MODE_SMA; // MA Method
input int Length2 = 2; // MA Period 2
input int Length3 = 2; // MA Period 3
input ENUM_MA_METHOD MA_Method1 = MODE_SMA; // MA Method 1
input ENUM_MA_METHOD MA_Method2 = MODE_SMA; // MA Method 2

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

double out[], ema1[], ema2[], temp[], ma1[], ma2[], ma3[], temp2[], tema[];

int init()
{
   IndicatorName = GenerateIndicatorName("Averaged Rainbow");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(9);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "AR");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, ema1);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, ema2);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, temp);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, ma1);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, ma2);

   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, ma3);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, temp2);

   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, tema);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double StDev(double& Data[], int pos, int Per)
{return(MathSqrt(Variance(Data, pos, Per)));
}
double Variance(double& Data[], int pos, int Per)
{
   double sum, ssum;
   for (int i = pos; i < pos + Per; i++)
   {  
      sum += Data[i];
      ssum += MathPow(Data[i],2);
   }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      double val = 0;
      double summ = 0;
      for (int i = 0; i < Number; ++i)
      {
         val += (Number - i) * iMA(_Symbol, _Period, Length * (i + 1), 0, MA_Method, PRICE_CLOSE, pos);
         summ += Number - i;
      }
      temp[pos] = val / summ;
      ema1[pos] = iMAOnArray(temp, 0, Length2, 0, MA_Method1, pos);
      ema2[pos] = iMAOnArray(ema1, 0, Length2, 0, MA_Method2, pos);
      double diff = ema1[pos] - ema2[pos];
      temp2[pos] = (ema1[pos] + diff);
      ma1[pos] = iMAOnArray(temp2, 0, Length2, 0, MA_Method2, pos);
      ma2[pos] = iMAOnArray(ma1, 0, Length2, 0, MA_Method2, pos);
      ma3[pos] = iMAOnArray(ma2, 0, Length2, 0, MA_Method2, pos);
      tema[pos] = 3 * ma1[pos] - 3 * ma2[pos] + ma3[pos];
      
      double Dev = StDev(tema, pos, Length3);
      double wma = iMA(_Symbol, _Period, Length3, 0, MODE_LWMA, PRICE_CLOSE, pos);
      out[pos] = 100 * (tema[pos] + 2 * Dev - wma) / (4 * Dev);
   }
   return 0;
}
