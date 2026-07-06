// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70243
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
#property indicator_buffers 8

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

// Candles stream v.1.3
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

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

CandleStreams* upcandles;
CandleStreams* downcandles;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("vwapo");
   IndicatorShortName("VWAP Oscillator");

   IndicatorBuffers(8);
   upcandles = new CandleStreams();
   int id = upcandles.RegisterStreams(0, Green);
   downcandles = new CandleStreams();
   downcandles.RegisterStreams(id, Red);

   return INIT_SUCCEEDED;
}

int deinit()
{
   delete upcandles;
   upcandles = NULL;
   delete downcandles;
   downcandles = NULL;
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
      upcandles.Init();
      downcandles.Init();
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

   int toSkip = 0;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      int htfStartIndex = iBarShift(_Symbol, tf, time[pos]);
      if (htfStartIndex < 0)
      {
         continue;
      }
      int startIndex = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, iTime(_Symbol, tf, htfStartIndex));
      if (startIndex < 0)
      {
         continue;
      }
      double vwapValue = 0, volumesSum = 0;
      for (int i = pos; i <= startIndex; i++)
      {
         vwapValue += close[i] * tick_volume[i];
         volumesSum += tick_volume[i];
      }
      vwapValue = volumesSum == 0 ? 0 : vwapValue / volumesSum;
      double vwapSTD = 0;
      for (int i = pos; i <= startIndex; i++)
      {
         vwapSTD += MathPow(close[i] - vwapValue, 2);
      }
      vwapSTD = startIndex - pos + 1 == 0 ? 0 : MathSqrt(vwapSTD / (startIndex - pos + 1));

      double c = vwapSTD == 0 ? 0 : (close[pos] - vwapValue) / vwapSTD;
      double o = vwapSTD == 0 ? 0 : (open[pos] - vwapValue) / vwapSTD;
      double h = vwapSTD == 0 ? 0 : (high[pos] - vwapValue) / vwapSTD;
      double l = vwapSTD == 0 ? 0 : (low[pos] - vwapValue) / vwapSTD;
      if (close[pos] > open[pos])
      {
         upcandles.Set(pos, o, h, l, c);
      }
      else
      {
         downcandles.Set(pos, o, h, l, c);
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
