// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69897

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
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int fpPeriod = 60; // Period
input double fpNumArrayStDevs = 2; // ArrayStDevs

string IndicatorObjPrefix;

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

double RelVol[], FOM[], x_aMove[], x_vByM[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("relvolfom");
   IndicatorShortName("Relative Volume + FOM");

   IndicatorBuffers(4);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, RelVol);
   SetIndexLabel(id, "RelVol");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, FOM);
   SetIndexLabel(id, "FOM");
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, x_aMove);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, x_vByM);
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
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
      ArrayInitialize(RelVol, EMPTY_VALUE);
      ArrayInitialize(x_aMove, EMPTY_VALUE);
      ArrayInitialize(x_vByM, EMPTY_VALUE);
      ArrayInitialize(FOM, EMPTY_VALUE);
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

   int toSkip = fpPeriod;
   for (int pos = rates_total - 1 - toSkip; pos >= 0; --pos)
   {
      double x_av = ArrayAverage(tick_volume, fpPeriod, pos);
      double x_sd = ArrayStDev(tick_volume, fpPeriod, pos) * fpNumArrayStDevs;
      RelVol[pos] = (tick_volume[pos] - x_av) / x_sd;
      x_aMove[pos] = (close[pos] - close[pos + 1]) / close[pos + 1];
      
      int highestIndex = ArrayMaximum(x_aMove, pos, fpPeriod);
      double x_theMax = x_aMove[highestIndex];
      int lowestIndex = ArrayMinimum(x_aMove, pos, fpPeriod);
      double x_theMin = x_aMove[lowestIndex];
      double x_theMove = x_theMax > x_theMin ? 1 + ((x_aMove[pos] - x_theMin) * (10 - 1)) / (x_theMax - x_theMin) : 0;
      if (pos >= rates_total - toSkip * 2 - 1)
      {
         continue;
      }
          
      highestIndex = ArrayMaximum(RelVol, pos, fpPeriod);
      double x_theMaxV = RelVol[highestIndex];
      lowestIndex = ArrayMinimum(RelVol, pos, fpPeriod);
      double x_theMinV = RelVol[lowestIndex];
      double x_theVol = x_theMaxV > x_theMinV ? 1 + ((RelVol[pos] - x_theMinV) * (10 - 1)) / (x_theMaxV - x_theMinV) : 0;
      x_vByM[pos] = x_theMove == 0 ? 0 : x_theVol / x_theMove;
      double x_avF = ArrayAverage(x_vByM, fpPeriod, pos);
      double x_sdF = ArrayStDev(x_vByM, fpPeriod, pos);
      FOM[pos] = x_sdF == 0 ? 0 : (x_vByM[pos] - x_avF) / x_sdF;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}

double ArrayAverage(const long& data[], int length, int pos)
{
   double sum = 0;
   for (int i = 0; i < length; i++)
   {
      sum += data[pos + i];
   }
   return sum / length;
}

double ArrayStDev(const double& data[], int Per, int pos)
{
   return MathSqrt(ArrayVariance(data, Per, pos));
}

double ArrayVariance(const double& data[], int Per, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < Per; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * Per - sum * sum) / (Per * (Per - 1));
}

double ArrayAverage(const double& data[], int length, int pos)
{
   double sum = 0;
   for (int i = 0; i < length; i++)
   {
      sum += data[pos + i];
   }
   return sum / length;
}

double ArrayStDev(const long& data[], int Per, int pos)
{
   return MathSqrt(ArrayVariance(data, Per, pos));
}

double ArrayVariance(const long& data[], int Per, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < Per; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * Per - sum * sum) / (Per * (Per - 1));
}
