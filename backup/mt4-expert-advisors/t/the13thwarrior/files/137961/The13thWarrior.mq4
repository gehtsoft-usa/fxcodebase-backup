// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70495

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
#property indicator_buffers 11
input color Top_color = Green; // Top Color
input color Bottom_color = Red; // Bottom Color

double alpha = 255;
double myDIn = 5;
double myOBVn = 5;
double myBBn = 8;

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

CandleStreams Top;
CandleStreams Bottom;

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

// HA bar steam v2.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

// IBarStream v2.1

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual bool FindDatePeriod(const datetime date, int& period) = 0;

   virtual bool GetOpen(const int period, double &open) = 0;
   virtual bool GetHigh(const int period, double &high) = 0;
   virtual bool GetLow(const int period, double &low) = 0;
   virtual bool GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;
   virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual void Refresh() = 0;
};
#endif

#ifndef HABarStream_IMP
#define HABarStream_IMP

class HABarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _open[];
   double _high[];
   double _low[];
   double _close[];
   int _lastCalculated;
   int _references;
public:
   HABarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _lastCalculated = 0;
      _references = 1;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      val = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh()
   {
      int totalBars = Size();
      if (ArrayRange(_open, 0) != totalBars)
      {
         ArrayResize(_open, totalBars);
         ArrayResize(_high, totalBars);
         ArrayResize(_low, totalBars);
         ArrayResize(_close, totalBars);
      }
      for (int i = MathMax(0, _lastCalculated - 1); i < totalBars; ++i)
      {
         double open = iOpen(_symbol, _timeframe, totalBars - 1 - i);
         double high = iHigh(_symbol, _timeframe, totalBars - 1 - i);
         double low = iLow(_symbol, _timeframe, totalBars - 1 - i);
         double close = iClose(_symbol, _timeframe, totalBars - 1 - i);
         _open[i] = i == 0 ? (open + close) / 2 : (_open[i - 1] + _close[i - 1]) / 2;
         _close[i] = (open + high + low + close) / 4;
         _high[i] = fmax(high, fmax(_open[i], _close[i]));
         _low[i] = fmin(low,fmin(_open[i], _close[i]));
      }
      _lastCalculated = totalBars;
   }
};

#endif

double myOBV[], myBBav[], myBBup[], myBBdown[];
HABarStream* ha;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("t13w");
   IndicatorShortName("The 13th Warrior");
   IndicatorDigits(Digits);
   IndicatorBuffers(12);

   int id = Top.RegisterStreams(0, Top_color);
   id = Bottom.RegisterStreams(id, Bottom_color);
   ha = new HABarStream(_Symbol, (ENUM_TIMEFRAMES)_Period);

   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, Blue);
   SetIndexBuffer(id, myBBav);
   SetIndexLabel(id, "BB");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, Gray);
   SetIndexBuffer(id, myBBup);
   SetIndexLabel(id, "BB Up");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, Gray);
   SetIndexBuffer(id, myBBdown);
   SetIndexLabel(id, "BB Down");
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, myOBV);
   ++id;
   
   return 0;
}

int deinit()
{
   delete ha;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   ha.Refresh();
   int counted_bars = IndicatorCounted();
   int minBars = myBBn;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      myOBV[pos] = iCustom(_Symbol, _Period, "OBV_Mod", 0, 0, pos);
      double myAV = iMAOnArray(myOBV, 0, myOBVn, 0, MODE_SMA, pos);

      Top.Clear(pos);
      Bottom.Clear(pos);
      double haclose, haopen;
      if (!ha.GetOpenClose(pos, haopen, haclose))
      {
         continue;
      }
      if (myOBV[pos] > myAV && haclose > haopen)
         Top.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      else if (myOBV[pos] < myAV && haclose < haopen)
         Bottom.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);

      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < myBBn; ++i)
      {
         double close;
         if (ha.GetClose(pos + i, close))
         {
            sum += close;
            ssum += MathPow(close, 2);
         }
      }
      double stdev = MathSqrt((ssum * myBBn - sum * sum) / (myBBn * (myBBn - 1)));
      myBBav[pos] = sum / myBBn;
      myBBup[pos] = myBBav[pos] + stdev;
      myBBdown[pos] = myBBav[pos] - stdev;
   }
   return 0;
}
