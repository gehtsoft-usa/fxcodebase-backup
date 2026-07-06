// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70704

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

input int PREDICT = 0;
input int LENGTH = 7;

#property strict
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int bars_limit = 100000; // Bars limit

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

double FLAG[];
int IRLOWBAR, LOWBAR, OFFSET, IRHIGHBAR, HIGHBAR;
double IRLOW, IRHIGH;
double PLOT1[];
double PLOT3[];
double IRPNTS[500];
double ZEROBAL, ZEROBAL1, ZEROBAL2;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("zb");
   IndicatorShortName("Zero Balance");

   IndicatorBuffers(3);

   int id = 0;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, PLOT1);
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, PLOT3);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, FLAG);
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
      ArrayInitialize(FLAG, 0);
      ArrayInitialize(PLOT1, EMPTY_VALUE);
      ArrayInitialize(PLOT3, EMPTY_VALUE);
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

   int toSkip = LENGTH + 1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      FLAG[pos] = FLAG[pos + 1];

      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, LENGTH, pos + 1);
      double highest = iHigh(_Symbol, _Period, highestIndex);
      if (high[pos] > highest && FLAG[pos] == 0)
      {
         FLAG[pos] = 1;
         IRLOWBAR = rates_total;
         LOWBAR = iLowest(_Symbol, _Period, MODE_LOW, rates_total - IRHIGHBAR + OFFSET, pos);
         IRLOW = iLow(_Symbol, _Period, LOWBAR);
         OFFSET = LOWBAR;
         for (int i = LOWBAR; i >= pos; --i)
         {
            PLOT1[i] = IRLOW;
         }
      }
      else
      {
         int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, LENGTH, pos + 1);
         double lowest = iLow(_Symbol, _Period, lowestIndex);
         if (low[pos] < lowest && FLAG[pos] == 1)
         {
            FLAG[pos] = 0;
            IRHIGHBAR = rates_total;
            HIGHBAR = iHighest(_Symbol, _Period, MODE_HIGH, rates_total - IRLOWBAR + OFFSET, pos);
            IRHIGH = iHigh(_Symbol, _Period, HIGHBAR);
            OFFSET = HIGHBAR;
            for (int i = HIGHBAR; i >= pos; --i)
            {
               PLOT1[i] = IRHIGH;
            }
         }
      }

      if (FLAG[pos] != FLAG[pos + 1])
      {
         for (int VALUE1 = 0; VALUE1 < LENGTH; ++VALUE1)
         {
            IRPNTS[VALUE1] = IRPNTS[VALUE1 + 1];
         }
         if (FLAG[pos] == 2)
         {
            IRPNTS[LENGTH] = IRLOW;
         }
         else
         {
            IRPNTS[LENGTH] = IRHIGH;
         }
         if (IRPNTS[0] != 0)
         {
            ZEROBAL = IRPNTS[5] + IRPNTS[4] - IRPNTS[2];
            ZEROBAL1 = IRPNTS[6] + IRPNTS[5] - IRPNTS[3];
            ZEROBAL2 = IRPNTS[7] + IRPNTS[6] - IRPNTS[4];
            if (PREDICT == 0)
            {
               PLOT3[OFFSET] = ZEROBAL;
            }
            if (PREDICT == 1)
            {
               PLOT3[OFFSET] = ZEROBAL1;
            }
            if (PREDICT == 2)
            {
               PLOT3[OFFSET] = ZEROBAL2;
            }
         }
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
