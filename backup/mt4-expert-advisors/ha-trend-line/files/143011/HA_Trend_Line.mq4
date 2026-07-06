// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71379

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

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
HABarStream* ha;

double out[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HA Trend Line");
   IndicatorShortName("HA Trend Line");

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Trend Line");

   ha = new HABarStream(_Symbol, (ENUM_TIMEFRAMES)_Period);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ha.Release();
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
      ArrayInitialize(out, EMPTY_VALUE);
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

   ha.Refresh();
   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double o, c, h, l;
      if (!ha.GetValues(pos, o, h, l, c))
      {
         continue;
      }
      out[pos] = o < c ? h : l;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
