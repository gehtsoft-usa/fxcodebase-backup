// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70236

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

input int Period = 20;
input double Q1 = 0.8;
input double Q2 = 0.4;

#define PI 3.14159265358979323846

class Quotient
{
   int _lpPeriod;
   double _k;
   double a1;
   double b1;
   double c3;
   double c1;
   double HP[];
   double Filt[];
   double Pk[];
public:
   Quotient(int LPPeriod, double K)
   {
      _lpPeriod = LPPeriod;
      _k = K;
      a1 = MathExp(-1.414 * PI / _lpPeriod);
      b1 = 2 * a1 * MathCos(1.414 * PI / _lpPeriod);
      c3 = -a1 * a1;
      c1 = 1 - b1 - c3;
   }

   void Init()
   {
      ArrayInitialize(HP, 0);
      ArrayInitialize(Filt, 0);
      ArrayInitialize(Pk, 0);
   }

   int RegisterStreams(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, HP);
      SetIndexEmptyValue(id, 0);
      ++id;
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Filt);
      SetIndexEmptyValue(id, 0);
      ++id;
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Pk);
      SetIndexEmptyValue(id, 0);
      ++id;
      return id;
   }

   double Calc(int pos)
   {
      HP[pos] = MathPow(1 - alpha1 / 2, 2) * (Close[pos] - 2 * Close[pos + 1] + Close[pos + 2]) + 2 * (1 - alpha1) * HP[pos + 1] - MathPow(1 - alpha1, 2) * HP[pos + 2];
      Filt[pos] = c1 * (HP[pos] + HP[pos + 1]) / 2 + b1 * Filt[pos + 1] + c3 * Filt[pos + 2];
      if (MathAbs(Filt[pos]) > 0.991 * Pk[pos + 1])
      {
         Pk[pos] = MathAbs(Filt[pos]);
      }
      else
      {
         Pk[pos] = 0.991 * Pk[pos + 1];
      }
      double X = Pk[pos] == 0 ? 0 : Filt[pos] / Pk[pos];

      return (X + _k) / (_k * X + 1);
   }
};

#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Aqua

string IndicatorObjPrefix;
double alpha1;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

double out1[], out2[];
Quotient* quotient1;
Quotient* quotient2;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("eeot");
   IndicatorShortName("Ehlers Early Onset Trend");
   double angle = 0.707 * 2 * PI / 100;
   alpha1 = (MathCos(angle) + MathSin(angle) - 1) / MathCos(angle);

   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out2);
   int id = 2;
   quotient1 = new Quotient(Period, Q1);
   quotient2 = new Quotient(Period, Q2);
   id = quotient1.RegisterStreams(id);
   id = quotient2.RegisterStreams(id);

   return INIT_SUCCEEDED;
}

int deinit()
{
   delete quotient1;
   quotient1 = NULL;
   delete quotient2;
   quotient2 = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
      quotient1.Init();
      quotient2.Init();
      ArrayInitialize(out1, EMPTY_VALUE);
      ArrayInitialize(out2, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 2;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      out1[pos] = quotient1.Calc(pos);
      out2[pos] = quotient2.Calc(pos);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
