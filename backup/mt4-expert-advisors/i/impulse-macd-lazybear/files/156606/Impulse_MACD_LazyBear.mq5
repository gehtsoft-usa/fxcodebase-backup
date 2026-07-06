//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75189

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 13
#property indicator_plots 6
#property indicator_label1 "MidLine"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Gray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "ImpulseMACD"
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "ImpulseHisto"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_label4 "ImpulseHisto"
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
#property indicator_label5 "ImpulseMACDCDSignal"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Maroon
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_type6 DRAW_COLOR_CANDLES

// Pine-script like safe operations
// v1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

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

//AOnStream v2.0
class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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
};
// Float stream v1.1

class FloatStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif


//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
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


// EMA on stream v1.1

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 2.0 / (_length + 1.0);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current[0];
      _buffer[bufferIndex] = (1 - _k) * last + _k * current[0];
      val = _buffer[bufferIndex];
      return true;
   }
};
// Candles stream v.1.0
class CandleStreams
{
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   double ColorIndex[];
   color colors[];
   int streamIndex;
public:
   CandleStreams(int streamIndex)
   {
      this.streamIndex = streamIndex;
   }
   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
      ArrayInitialize(ColorIndex, 0);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
      ColorIndex[index] = 0;
   }
   
   void AddColor(color clr)
   {
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = clr;
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, OpenStream, INDICATOR_DATA);
      SetIndexBuffer(id + 1, HighStream, INDICATOR_DATA);
      SetIndexBuffer(id + 2, LowStream, INDICATOR_DATA);
      SetIndexBuffer(id + 3, CloseStream, INDICATOR_DATA);
      SetIndexBuffer(id + 4, ColorIndex, INDICATOR_COLOR_INDEX);
      int size = ArraySize(colors);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size);
      for (int i = 0; i < size; ++i)
      {
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, i, colors[i]);
      }
      return id + 5;
   }
   
   void Set(const int index, const double open, const double high, const double low, const double close, color clr)
   {
      if (clr == (color)EMPTY_VALUE)
      {
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
      ColorIndex[index] = FindColor(clr);
   }
   
   void SetOffset(int offset)
   {
   }
private:
   int FindColor(color clr)
   {
      int size = ArraySize(colors);
      for (int i = 0; i < size; ++i)
      {
         if (colors[i] == clr)
         {
            return i;
         }
      }
      return 0;
   }
};
input int param1 = 34;
input int param2 = 9;
input bool param3 = false; // Enable bar colors
input int bars_limit = 1000; // Bars limit
int lengthMA;
int lengthSignal;
class calc_smma_fS_iStream
{
   IStream* src;
   int len;
   double smma[];
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   bool _initialized;
public:
   calc_smma_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, len);
   }
   ~calc_smma_fS_iStream()
   {
      src.Release();
      sma1Source.Release();
      sma1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, smma, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ArrayInitialize(smma, EMPTY_VALUE);
         sma1Source.Init();
         _initialized = true;
      }
      if (pos - 1 < 0) { return false; }
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      sma1Source.SetValue(pos, srcValue[0]);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { return false; }
      smma[pos] = (((smma[pos - 1]) == EMPTY_VALUE) ? sma1Value[0] : SafeDivide((SafePlus(SafeMultiply(smma[pos - 1], (len - 1)), srcValue[0])), len));
      __out1 = smma[pos];
      return true;
   }
};
FloatStream* calc_smma_fS_i1_param1;
calc_smma_fS_iStream* calc_smma_fS_i1;
FloatStream* calc_smma_fS_i2_param1;
calc_smma_fS_iStream* calc_smma_fS_i2;
class calc_zlema_fS_iStream
{
   IStream* src;
   int length;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   bool _initialized;
public:
   calc_zlema_fS_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, length);
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, length);
   }
   ~calc_zlema_fS_iStream()
   {
      src.Release();
      ema1Source.Release();
      ema1.Release();
      ema2Source.Release();
      ema2.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema1Source.Init();
         ema2Source.Init();
         _initialized = true;
      }
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      ema1Source.SetValue(pos, srcValue[0]);
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
      double ema1 = ema1Value[0];
      ema2Source.SetValue(pos, ema1);
      double ema2Value[1];
      if (!ema2.GetValues(pos, 1, ema2Value)) { ema2Value[0] = EMPTY_VALUE; }
      double ema2 = ema2Value[0];
      double d = SafeMinus(ema1, ema2);
      __out1 = SafePlus(ema1, d);
      return true;
   }
};
FloatStream* calc_zlema_fS_i3_param1;
calc_zlema_fS_iStream* calc_zlema_fS_i3;
FloatStream* sma2Source;
SmaOnStream* sma2;
double plot1[];
double plot2[];
double plot_color2[];
int GetPlot2Color(color clr)
{
   if (clr == Lime) { return 0; }
   if (clr == Green) { return 1; }
   if (clr == Red) { return 2; }
   if (clr == Orange) { return 3; }
   return 0;
}
double plot3[];
double plot3_dn[];
double plot5[];
bool ebc;
CandleStreams* barcolor1;

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

void OnInit()
{
   int id = 0;
   lengthMA = param1;
   lengthSignal = param2;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, lengthSignal);
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0, Lime);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 1, Green);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 2, Red);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 3, Orange);
   id += 1;
   SetIndexBuffer(id++, plot_color2, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(id++, plot3, INDICATOR_DATA);
   SetIndexBuffer(id++, plot3_dn, INDICATOR_DATA);
   SetIndexBuffer(id++, plot5, INDICATOR_DATA);
   ebc = param3;
   barcolor1 = new CandleStreams(5);
   barcolor1.AddColor(Lime);
   barcolor1.AddColor(Green);
   barcolor1.AddColor(Red);
   barcolor1.AddColor(Orange);
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix("IMACD_LB");
   IndicatorSetString(INDICATOR_SHORTNAME, "Impulse MACD [LazyBear]");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   calc_smma_fS_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   calc_smma_fS_i1 = new calc_smma_fS_iStream(calc_smma_fS_i1_param1, lengthMA);
   id = calc_smma_fS_i1.Init(id);
   calc_smma_fS_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   calc_smma_fS_i2 = new calc_smma_fS_iStream(calc_smma_fS_i2_param1, lengthMA);
   id = calc_smma_fS_i2.Init(id);
   calc_zlema_fS_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   calc_zlema_fS_i3 = new calc_zlema_fS_iStream(calc_zlema_fS_i3_param1, lengthMA);
   id = calc_zlema_fS_i3.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   calc_smma_fS_i1_param1.Release();
   delete calc_smma_fS_i1;
   calc_smma_fS_i2_param1.Release();
   delete calc_smma_fS_i2;
   calc_zlema_fS_i3_param1.Release();
   delete calc_zlema_fS_i3;
   sma2Source.Release();
   sma2.Release();
   delete barcolor1;
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
      calc_smma_fS_i1_param1.Init();
      calc_smma_fS_i1.Clear();
      calc_smma_fS_i2_param1.Init();
      calc_smma_fS_i2.Clear();
      calc_zlema_fS_i3_param1.Init();
      calc_zlema_fS_i3.Clear();
      sma2Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot_color2, 0);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot3_dn, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      barcolor1.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double src = SafeDivide((high[pos] + low[pos] + close[pos]), 3);
      calc_smma_fS_i1_param1.SetValue(pos, high[pos]);
      double calc_smma_fS_i1Value;
      if (!calc_smma_fS_i1.GetValue(pos, calc_smma_fS_i1Value)) { calc_smma_fS_i1Value = EMPTY_VALUE; }
      double hi = calc_smma_fS_i1Value;
      calc_smma_fS_i2_param1.SetValue(pos, low[pos]);
      double calc_smma_fS_i2Value;
      if (!calc_smma_fS_i2.GetValue(pos, calc_smma_fS_i2Value)) { calc_smma_fS_i2Value = EMPTY_VALUE; }
      double lo = calc_smma_fS_i2Value;
      calc_zlema_fS_i3_param1.SetValue(pos, src);
      double calc_zlema_fS_i3Value;
      if (!calc_zlema_fS_i3.GetValue(pos, calc_zlema_fS_i3Value)) { calc_zlema_fS_i3Value = EMPTY_VALUE; }
      double mi = calc_zlema_fS_i3Value;
      double md = ((SafeGreater(mi, hi)) ? (SafeMinus(mi, hi)) : ((SafeLess(mi, lo)) ? (SafeMinus(mi, lo)) : 0));
      sma2Source.SetValue(pos, md);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      double sb = sma2Value[0];
      double sh = SafeMinus(md, sb);
      color mdc = (SafeGreater(src, mi) ? (SafeGreater(src, hi) ? Lime : Green) : (SafeLess(src, lo) ? Red : Orange));
      plot1[pos] = 0;
      plot2[pos] = md;
      plot_color2[pos] = GetPlot2Color(mdc);
      plot3[pos] = sh;
      plot3_dn[pos] = 0;
      plot5[pos] = sb;
      barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], (ebc ? mdc : EMPTY_VALUE));
   }
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 