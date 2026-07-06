// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71528

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

#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots 1
#property indicator_label1 "Range index"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_level1 40
#property indicator_level2 10

input int length = 9; // Length
input int chop_max_val = 40; // Trend threshold (max value)
input int chop_min_val = 10; // Exhausted trend threshold (min value)
input int atr_length = 14; // ATR Filter Period
input int low_lookback = 14; // ATR Filter Low Lookback Period
input bool use_normalized = true; // Used normalized true range for ATR Filter?
input int stddev_length = 14; // Standard Deviation - Length
input ENUM_MA_METHOD stddev_mean_type = MODE_SMA; // Standard Deviation - Mean calculation method
input int bars_limit = 1000; // Bars limit
double plot1[], plot1Color[];
double tr[], atr_val[], atr_val2[], stddev[], range_index[], stddev_a[];

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

// ABaseStream v1.1
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};
class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
#endif

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public ABaseStream
{
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period - i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period - i + 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};
#endif


// IndicatorOutputStream v3.0

#ifndef IndicatorOutputStream_IMP
#define IndicatorOutputStream_IMP

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};
#endif


//AOnStream v2.0
class AOnStream : public IStream
{
protected:
   IStream *_source;
   int _references;
public:
   AOnStream(IStream *source)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
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

   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};

// Sum on stream v1.0

class SumOnStream : public AOnStream
{
   double _buffer[];
   int _length;
public:
   SumOnStream(IStream *source, int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current[1];
         if (!_source.GetSeriesValues(period + i, 1, current))
         {
            return false;
         }
         sum += current[0];
      }
      int bufferIndex = totalBars - 1 - period;
      _buffer[bufferIndex] = sum;
      val = _buffer[bufferIndex];
      return true;
   }
};


// Lowest low stream v1.0

class LowestLowStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      val = _values[0];

      for (int i = 1; i < _loopback; ++i)
      {
         val = MathMin(val, _values[i]);
      }
      return true;
   }
};


// Highest high stream v1.0

class HighestHighStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      val = _values[0];

      for (int i = 1; i < _loopback; ++i)
      {
         val = MathMax(val, _values[i]);
      }
      return true;
   }
};


//RmaOnStream v2.1
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price[0]) / _length;
      }
      val = _buffer[index];
      return true;
   }
};

IStream* tr1;
IStream* sum2;
IndicatorOutputStream* lowest3Source;
IStream* lowest3;
IndicatorOutputStream* highest4Source;
IStream* highest4;
IStream* tr5;
IndicatorOutputStream* rma6Source;
IStream* rma6;
IndicatorOutputStream* lowest7Source;
IStream* lowest7;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Range index");
   IndicatorSetString(INDICATOR_SHORTNAME, "BERLIN Range Index v1.1b | Panel color version");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int id = 0;
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(id,PLOT_COLOR_INDEXES,4);
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,0,Gray);   //Zeroth index -> Blue
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,1,Yellow);
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,2,Orange);
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,3,Red);
   ++id;
   SetIndexBuffer(id++, plot1Color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(id++, atr_val, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, stddev, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, range_index, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, atr_val2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, stddev_a, INDICATOR_CALCULATIONS);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum2 = new SumOnStream(tr1, length);
   lowest3Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = lowest3Source.RegisterInternalStream(id);
   lowest3 = new LowestLowStream(lowest3Source, length);
   highest4Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = highest4Source.RegisterInternalStream(id);
   highest4 = new HighestHighStream(highest4Source, length);
   tr5 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma6Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rma6Source.RegisterInternalStream(id);
   rma6 = new RmaOnStream(rma6Source, atr_length);
   lowest7Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = lowest7Source.RegisterInternalStream(id);
   lowest7 = new LowestLowStream(lowest7Source, low_lookback);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   tr1.Release();
   sum2.Release();
   lowest3Source.Release();
   lowest3.Release();
   highest4Source.Release();
   highest4.Release();
   tr5.Release();
   rma6Source.Release();
   rma6.Release();
   lowest7Source.Release();
   lowest7.Release();
}

#include <MovingAverages.mqh>
void MAOnArray(const int rates_total, const int prev_calculated, int sourceFirst, ENUM_MA_METHOD method, int period, double& in[], double& out[])
{
   if (period == 1)
   {
      for (int pos = sourceFirst; pos < rates_total; ++pos)
      {
         out[pos] = in[pos];
      }
      return;
   }
   int weightsum;
   switch (method)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out, weightsum);
         break;
   }
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(tr, EMPTY_VALUE);
      ArrayInitialize(atr_val, EMPTY_VALUE);
      ArrayInitialize(atr_val2, EMPTY_VALUE);
      ArrayInitialize(stddev, EMPTY_VALUE);
      ArrayInitialize(range_index, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;

      double tr5Value[1];
      if (!tr5.GetSeriesValues(oldPos, 1, tr5Value))
      {
         continue;
      }
      rma6Source._data[pos] = (use_normalized ? MathMax(MathMax(tr5Value[0], high[pos] - close[pos]), close[pos] - low[pos]) / close[pos] : tr5Value[0]);
      double rma6Value[1];
      if (!rma6.GetSeriesValues(oldPos, 1, rma6Value))
      {
         continue;
      }
      atr_val[pos] = rma6Value[0];
      atr_val2[pos] = MathPow(atr_val[pos], 2);
   }
   MAOnArray(rates_total, prev_calculated,  rates_total - bars_limit + stddev_length, stddev_mean_type, stddev_length, atr_val2, stddev_a);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double sum2Value[1];
      if (!sum2.GetSeriesValues(oldPos, 1, sum2Value))
      {
         continue;
      }
      double str = sum2Value[0];
      lowest3Source._data[pos] = ((low[pos] <= close[pos - 1]) ? low[pos] : close[pos - 1]);
      double lowest3Value[1];
      if (!lowest3.GetSeriesValues(oldPos, 1, lowest3Value))
      {
         continue;
      }
      double ltl = lowest3Value[0];
      highest4Source._data[pos] = ((high[pos] >= close[pos - 1]) ? high[pos] : close[pos - 1]);
      double highest4Value[1];
      if (!highest4.GetSeriesValues(oldPos, 1, highest4Value))
      {
         continue;
      }
      double hth = highest4Value[0];
      double height = hth - ltl;
      double chop = height == 0 ? 0 : 100 * (MathLog10(str / height) / MathLog10(length));
      double sum = 0;
      for (int i = 0; i < stddev_length; ++i)
      {
         if (atr_val[pos - i] == EMPTY_VALUE)
         {
            continue;
         }
         sum += atr_val[pos - i];
      }
      double stddev_b = MathPow(sum, 2) / MathPow(stddev_length, 2);
      stddev[pos] = MathSqrt(MathAbs(stddev_a[pos] - stddev_b));
      lowest7Source._data[pos] = stddev[pos];
      double lowest7Value[1];
      if (!lowest7.GetSeriesValues(oldPos, 1, lowest7Value))
      {
         continue;
      }
      double stddev_lo = lowest7Value[0];
      double stddev_factor = stddev[pos] == 0 ? 0 : stddev_lo / stddev[pos];
      range_index[pos] = chop * stddev_factor;
      bool chop_condition = (range_index[pos] > chop_max_val);
      bool trend_condition = ((range_index[pos - 1] > chop_min_val) && ((range_index[pos] < chop_max_val) && (range_index[pos] > chop_min_val)));
      bool strong_trend_condition = (range_index[pos] < chop_min_val);
      bool weakening_trend_condition = ((range_index[pos - 1] < chop_min_val) && (range_index[pos] > chop_min_val));

      plot1Color[pos] = (chop_condition ? 0 : (trend_condition ? 1 : (strong_trend_condition ? 2 : (weakening_trend_condition ? 3 : 0))));
      plot1[pos] = range_index[pos];
   }
   return rates_total;
}
