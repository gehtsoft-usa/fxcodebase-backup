// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70605

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
//#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Green
#property indicator_color6 Green
#property indicator_color7 Orange
#property indicator_color8 Blue
#property indicator_color9 Red
#property indicator_color10 Red

// ----------- SEQUENTIAL
input bool showSequential = true; // Show Sequential
input ENUM_APPLIED_PRICE supportSource = PRICE_LOW; // Suppport & Resistance source
input ENUM_APPLIED_PRICE resistanceSource = PRICE_HIGH; // Suppport & Resistance source
input ENUM_MA_METHOD trendMaType = MODE_SMA; // Trend MA type
input ENUM_APPLIED_PRICE trendMaSource = PRICE_CLOSE; // Trend MA source
input int trendMaLength = 55; // Trend MA length
input int entryMaLength = 21; // Entry MA length
input ENUM_APPLIED_PRICE entryMaSource = PRICE_CLOSE; // Entry MA source
input ENUM_MA_METHOD entryMaType = MODE_SMA; // Entry MA type
input int bars_limit = 100000; // Bars limit

double GetPrice(const double &open[], const double &high[], const double &low[], const double &close[], int pos, ENUM_APPLIED_PRICE price)
{
   switch (price)
   {
      case PRICE_CLOSE:
         return close[pos];
      case PRICE_HIGH:
         return high[pos];
      case PRICE_LOW:
         return low[pos];
      case PRICE_OPEN:
         return open[pos];
   }
   return close[pos];
}

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

double resistanceTop[];
double resistanceBottom[];
double stopZoneTop1[];
double stopZoneTop2[];
double stopZoneBottom1[];
double stopZoneBottom2[];
double trendMovingAverage[];
double entryMovingAverage[];
double entryMovingAverage_stop1[];
double entryMovingAverage_stop2[];
double sellSetup[];
double buySetup[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("is");
   IndicatorShortName("Indicator Sniper");

   IndicatorBuffers(12);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, resistanceTop);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, resistanceBottom);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, stopZoneTop1);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, stopZoneTop2);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, stopZoneBottom1);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, stopZoneBottom2);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, trendMovingAverage);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, entryMovingAverage);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, entryMovingAverage_stop1);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, entryMovingAverage_stop2);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, sellSetup);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, buySetup);
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
      ArrayInitialize(resistanceTop, EMPTY_VALUE);
      ArrayInitialize(resistanceBottom, EMPTY_VALUE);
      ArrayInitialize(stopZoneTop1, EMPTY_VALUE);
      ArrayInitialize(stopZoneTop2, EMPTY_VALUE);
      ArrayInitialize(stopZoneBottom1, EMPTY_VALUE);
      ArrayInitialize(stopZoneBottom2, EMPTY_VALUE);
      ArrayInitialize(trendMovingAverage, EMPTY_VALUE);
      ArrayInitialize(entryMovingAverage, EMPTY_VALUE);
      ArrayInitialize(entryMovingAverage_stop1, EMPTY_VALUE);
      ArrayInitialize(entryMovingAverage_stop2, EMPTY_VALUE);
      ArrayInitialize(buySetup, EMPTY_VALUE);
      ArrayInitialize(sellSetup, EMPTY_VALUE);
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

   int toSkip = 21;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double atr = iATR(_Symbol, _Period, 14, pos);
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, 21, pos);
      if (highestIndex == pos)
      {
         resistanceTop[pos] = GetPrice(open, high, low, close, pos, resistanceSource);
      }
      else
      {
         resistanceTop[pos] = resistanceTop[pos + 1];
      }
      stopZoneTop1[pos] = atr + resistanceTop[pos];
      stopZoneTop2[pos] = 2 * atr + resistanceTop[pos];
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, 21, pos);
      if (lowestIndex == pos)
      {
         resistanceBottom[pos] = GetPrice(open, high, low, close, pos, supportSource);
      }
      else
      {
         resistanceBottom[pos] = resistanceBottom[pos + 1];
      }
      stopZoneBottom1[pos] = resistanceBottom[pos] - atr;
      stopZoneBottom2[pos] = resistanceBottom[pos] - 2 * atr;

      trendMovingAverage[pos] = iMA(_Symbol, _Period, trendMaLength, 0, trendMaType, trendMaSource, pos);
      entryMovingAverage[pos] = iMA(_Symbol, _Period, entryMaLength, 0, entryMaType, entryMaSource, pos);
      entryMovingAverage_stop1[pos] = entryMovingAverage[pos] + atr;
      entryMovingAverage_stop2[pos] = entryMovingAverage[pos] - atr;
      if (showSequential)
      {
         sellSetup[pos] = (close[pos] < close[pos + 4]) ? sellSetup[pos + 1] == 9 ? 1 : sellSetup[pos + 1] + 1 : 0;
         bool sellPerfected = (close[pos] < close[pos + 1] && close[pos] < close[pos + 2]);
         buySetup[pos] = (close[pos] > close[pos + 4]) ? buySetup[pos + 1] == 9 ? 1 : buySetup[pos + 1] + 1 : 0;
         bool buyPerfected = (close[pos] > close[pos + 1] && close[pos] > close[pos + 2]);
         int setupCount = MathMax(sellSetup[pos], buySetup[pos]);
         color setupCountColor = sellSetup[pos] > 7 && sellPerfected ? Yellow : sellSetup[pos] > 0 ? Red : buySetup[pos] > 7 && buyPerfected ? Yellow : Green;

         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(time[pos]);
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TEXT, 0, time[pos], high[pos]))
            {
               continue;
            }
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 21);
            ObjectSetInteger(0, id, OBJPROP_COLOR, setupCountColor);
            ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, time[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE1, high[pos]);
         ObjectSetString(0, id, OBJPROP_TEXT, IntegerToString(setupCount));
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
