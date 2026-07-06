// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71632

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
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+

#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 2
#property indicator_label1 "VI +"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x2962FF
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "VI -"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0xE91E63
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

input int period_ = 14; // Length
input int bars_limit = 1000; // Bars limit
double plot1[], plot2[];

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

// AStream v1.1
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
class AStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~AStream()
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

// IndicatorOutputStream v3.1

#ifndef IndicatorOutputStream_IMP
#define IndicatorOutputStream_IMP

class IndicatorOutputStream : public AStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
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
IndicatorOutputStream* math_sum1Source;
IStream* math_sum1;
IndicatorOutputStream* math_sum2Source;
IStream* math_sum2;


//True range stream v1.0

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         if ((period + i + 1 == size) && _handleNa)
         {
            double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
            double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));

            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
         }
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};

//SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};

// Average true range stream v2.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return _avg.GetSeriesValues(period, count, val);
   }
};
#endif
IStream* ta_atr3;
IndicatorOutputStream* math_sum4Source;
IStream* math_sum4;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("VI");
   IndicatorSetString(INDICATOR_SHORTNAME, "Vortex Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int id = 0;
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   SetIndexBuffer(id++, plot2, INDICATOR_DATA);
   math_sum1Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = math_sum1Source.RegisterInternalStream(id);
   math_sum1 = new SumOnStream(math_sum1Source, period_);
   math_sum2Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = math_sum2Source.RegisterInternalStream(id);
   math_sum2 = new SumOnStream(math_sum2Source, period_);
   ta_atr3 = new ATRStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   math_sum4Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = math_sum4Source.RegisterInternalStream(id);
   math_sum4 = new SumOnStream(math_sum4Source, period_);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   math_sum1Source.Release();
   math_sum1.Release();
   math_sum2Source.Release();
   math_sum2.Release();
   ta_atr3.Release();
   math_sum4.Release();
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
      ArrayInitialize(plot2, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      math_sum1Source._data[pos] = MathAbs(high[pos] - low[pos - 1]);
      double math_sum1Value[1];
      if (!math_sum1.GetSeriesValues(oldPos, 1, math_sum1Value))
      {
         continue;
      }
      double VMP = math_sum1Value[0];
      math_sum2Source._data[pos] = MathAbs(low[pos] - high[pos - 1]);
      double math_sum2Value[1];
      if (!math_sum2.GetSeriesValues(oldPos, 1, math_sum2Value))
      {
         continue;
      }
      double VMM = math_sum2Value[0];
      double ta_atr3Value[1];
      if (!ta_atr3.GetSeriesValues(oldPos, 1, ta_atr3Value))
      {
         continue;
      }
      math_sum4Source._data[pos] = ta_atr3Value[0];
      double math_sum4Value[1];
      if (!math_sum4.GetSeriesValues(oldPos, 1, math_sum4Value))
      {
         continue;
      }
      double STR = math_sum4Value[0];
      double VIP = VMP / STR;
      double VIM = VMM / STR;
      plot1[pos] = VIP;
      plot2[pos] = VIM;
   }
   return rates_total;
}
