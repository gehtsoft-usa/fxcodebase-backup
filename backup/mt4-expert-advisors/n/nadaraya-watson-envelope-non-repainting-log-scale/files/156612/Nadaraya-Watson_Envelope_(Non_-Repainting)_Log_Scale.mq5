//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75192

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

#property indicator_chart_window
#property indicator_buffers 19
#property indicator_plots 12
#property indicator_label1 "Upper Boundary: Far (Custom)"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Upper Boundary: Average (Custom)"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Upper Boundary: Near (Custom)"
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Custom Estimation"
#property indicator_type4 DRAW_COLOR_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Custom Estimation"
#property indicator_type5 DRAW_COLOR_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Lower Boundary: Near (Custom)"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Lower Boundary: Average (Custom)"
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Lower Boundary: Far (Custom)"
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_type9 DRAW_FILLING
#property indicator_width9 1
#property indicator_type10 DRAW_FILLING
#property indicator_width10 1
#property indicator_type11 DRAW_FILLING
#property indicator_width11 1
#property indicator_type12 DRAW_FILLING
#property indicator_width12 1

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

//RmaOnStream v2.3
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

      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_buffer, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
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

// Colored fill v1.0

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void AddColor(color clr)
   {
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((color)clr);
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, color clr)
   {
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
#endif
input int param1 = 8; // Lookback Window (Custom)
input double param2 = 8.; // Relative Weighting (Custom)
input int param3 = 25; // Start Regression at Bar (Custom)
input int param4 = 60; // ATR Length (Custom)
input double param5 = 1.5; // Near ATR Factor (Custom)
input double param6 = 2.0; // Far ATR Factor (Custom)
input int bars_limit = 1000; // Bars limit
int customLookbackWindow;
double customRelativeWeighting;
int customStartRegressionBar;
class customKernel_fS_i_f_iStream
{
   IStream* x;
   int h;
   double alpha;
   int x_0;
   bool _initialized;
public:
   customKernel_fS_i_f_iStream(IStream* x, int h, double alpha, int x_0)
   {
      _initialized = false;
      this.x = x;
      x.AddRef();
      this.h = h;
      this.alpha = alpha;
      this.x_0 = x_0;
   }
   ~customKernel_fS_i_f_iStream()
   {
      x.Release();
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
      double sumWeights = 0.0;
      double sumXWeights = 0.0;
      int for1_from = 0;
      int for1_to = h;
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         double weight = SafeMathPow(SafePlus(1, (SafeDivide(MathPow((x_0 - i), 2), (2 * alpha * h * h)))), (-alpha));
         sumWeights = SafePlus(sumWeights, weight);
         double xValue_i[1];
         if (!x.GetValues(pos - i, 1, xValue_i)) { xValue_i[0] = EMPTY_VALUE; }
         sumXWeights = SafePlus(sumXWeights, SafeMultiply(weight, xValue_i[0]));
      }
      __out1 = SafeDivide(sumXWeights, sumWeights);
      return true;
   }
};
FloatStream* customKernel_fS_i_f_i1_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i1;
FloatStream* customKernel_fS_i_f_i2_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i2;
FloatStream* customKernel_fS_i_f_i3_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i3;
int customATRLength;
class customATR_i_fS_fS_fSStream
{
   int length;
   IStream* _high;
   IStream* _low;
   IStream* _close;
   FloatStream* rma1Source;
   RmaOnStream* rma1;
   bool _initialized;
public:
   customATR_i_fS_fS_fSStream(int length, IStream* _high, IStream* _low, IStream* _close)
   {
      _initialized = false;
      this.length = length;
      this._high = _high;
      _high.AddRef();
      this._low = _low;
      _low.AddRef();
      this._close = _close;
      _close.AddRef();
      rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rma1 = new RmaOnStream(rma1Source, length);
   }
   ~customATR_i_fS_fS_fSStream()
   {
      _high.Release();
      _low.Release();
      _close.Release();
      rma1Source.Release();
      rma1.Release();
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
         rma1Source.Init();
         _initialized = true;
      }
      double _highValue_1[1];
      if (!_high.GetValues(pos - 1, 1, _highValue_1)) { _highValue_1[0] = EMPTY_VALUE; }
      double _highValue[1];
      if (!_high.GetValues(pos, 1, _highValue)) { _highValue[0] = EMPTY_VALUE; }
      double _lowValue[1];
      if (!_low.GetValues(pos, 1, _lowValue)) { _lowValue[0] = EMPTY_VALUE; }
      double _closeValue_1[1];
      if (!_close.GetValues(pos - 1, 1, _closeValue_1)) { _closeValue_1[0] = EMPTY_VALUE; }
      double trueRange = (((_highValue_1[0]) == EMPTY_VALUE) ? SafeMinus(MathLog(_highValue[0]), MathLog(_lowValue[0])) : SafeMathMax(SafeMathMax(SafeMinus(MathLog(_highValue[0]), MathLog(_lowValue[0])), SafeMathAbs(SafeMinus(MathLog(_highValue[0]), MathLog(_closeValue_1[0])))), SafeMathAbs(SafeMinus(MathLog(_lowValue[0]), MathLog(_closeValue_1[0])))));
      rma1Source.SetValue(pos, trueRange);
      double rma1Value[1];
      if (!rma1.GetValues(pos, 1, rma1Value)) { rma1Value[0] = EMPTY_VALUE; }
      __out1 = rma1Value[0];
      return true;
   }
};
FloatStream* customATR_i_fS_fS_fS4_param2;
FloatStream* customATR_i_fS_fS_fS4_param3;
FloatStream* customATR_i_fS_fS_fS4_param4;
customATR_i_fS_fS_fSStream* customATR_i_fS_fS_fS4;
double customNearATRFactor;
double customFarATRFactor;
class getEnvelopeBounds_fS_f_f_fSStream
{
   IStream* _atr;
   double _nearFactor;
   double _farFactor;
   IStream* _envelope;
   bool _initialized;
public:
   getEnvelopeBounds_fS_f_f_fSStream(IStream* _atr, double _nearFactor, double _farFactor, IStream* _envelope)
   {
      _initialized = false;
      this._atr = _atr;
      _atr.AddRef();
      this._nearFactor = _nearFactor;
      this._farFactor = _farFactor;
      this._envelope = _envelope;
      _envelope.AddRef();
   }
   ~getEnvelopeBounds_fS_f_f_fSStream()
   {
      _atr.Release();
      _envelope.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2, double &__out3, double &__out4, double &__out5, double &__out6)
   {
      double _envelopeValue[1];
      if (!_envelope.GetValues(pos, 1, _envelopeValue)) { _envelopeValue[0] = EMPTY_VALUE; }
      double _atrValue[1];
      if (!_atr.GetValues(pos, 1, _atrValue)) { _atrValue[0] = EMPTY_VALUE; }
      double _upperFar = _envelopeValue[0] + _farFactor * _atrValue[0];
      double _upperNear = _envelopeValue[0] + _nearFactor * _atrValue[0];
      double _lowerNear = _envelopeValue[0] - _nearFactor * _atrValue[0];
      double _lowerFar = _envelopeValue[0] - _farFactor * _atrValue[0];
      double _upperAvg = SafeDivide((_upperFar + _upperNear), 2);
      double _lowerAvg = SafeDivide((_lowerFar + _lowerNear), 2);
      __out1 = _upperNear;
      __out2 = _upperFar;
      __out3 = _upperAvg;
      __out4 = _lowerNear;
      __out5 = _lowerFar;
      __out6 = _lowerAvg;
      return true;
   }
};
FloatStream* getEnvelopeBounds_fS_f_f_fS5_param1;
FloatStream* getEnvelopeBounds_fS_f_f_fS5_param4;
getEnvelopeBounds_fS_f_f_fSStream* getEnvelopeBounds_fS_f_f_fS5;
double plot1[];
double plot2[];
double plot3[];
double customEnvelope[];
double plot4[];
double plot_color4[];
int GetPlot4Color(color clr)
{
   if (clr == Teal) { return 0; }
   if (clr == Red) { return 1; }
   return 0;
}
double plot5[];
double plot_color5[];
int GetPlot5Color(color clr)
{
   if (clr == Teal) { return 0; }
   if (clr == Red) { return 1; }
   return 0;
}
double plot6[];
double plot7[];
double plot8[];
ColoredFill* fill9;
ColoredFill* fill10;
ColoredFill* fill11;
ColoredFill* fill12;

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
   customLookbackWindow = param1;
   customRelativeWeighting = param2;
   customStartRegressionBar = param3;
   customATRLength = param4;
   customNearATRFactor = param5;
   customFarATRFactor = param6;
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Red);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Red);
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Red);
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_COLOR_INDEXES, 2);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0, Teal);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 1, Red);
   id += 1;
   SetIndexBuffer(id++, plot_color4, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(id, plot5, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_COLOR_INDEXES, 2);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0, Teal);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 1, Red);
   id += 1;
   SetIndexBuffer(id++, plot_color5, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Teal);
   SetIndexBuffer(id, plot7, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Teal);
   SetIndexBuffer(id, plot8, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Teal);
   fill9 = new ColoredFill(8);
   fill9.AddColor(Red);
   id = fill9.RegisterStreams(id);
   fill10 = new ColoredFill(9);
   fill10.AddColor(Red);
   id = fill10.RegisterStreams(id);
   fill11 = new ColoredFill(10);
   fill11.AddColor(Teal);
   id = fill11.RegisterStreams(id);
   fill12 = new ColoredFill(11);
   fill12.AddColor(Teal);
   id = fill12.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix("NW Envelope");
   IndicatorSetString(INDICATOR_SHORTNAME, "Nadaraya-Watson Envelope (Non -Repainting) Log Scale");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   customKernel_fS_i_f_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i1 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i1_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i1.Init(id);
   customKernel_fS_i_f_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i2 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i2_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i2.Init(id);
   customKernel_fS_i_f_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i3 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i3_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i3.Init(id);
   customATR_i_fS_fS_fS4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4 = new customATR_i_fS_fS_fSStream(customATRLength, customATR_i_fS_fS_fS4_param2, customATR_i_fS_fS_fS4_param3, customATR_i_fS_fS_fS4_param4);
   id = customATR_i_fS_fS_fS4.Init(id);
   getEnvelopeBounds_fS_f_f_fS5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getEnvelopeBounds_fS_f_f_fS5_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getEnvelopeBounds_fS_f_f_fS5 = new getEnvelopeBounds_fS_f_f_fSStream(getEnvelopeBounds_fS_f_f_fS5_param1, customNearATRFactor, customFarATRFactor, getEnvelopeBounds_fS_f_f_fS5_param4);
   id = getEnvelopeBounds_fS_f_f_fS5.Init(id);
   SetIndexBuffer(id++, customEnvelope, INDICATOR_CALCULATIONS);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   customKernel_fS_i_f_i1_param1.Release();
   delete customKernel_fS_i_f_i1;
   customKernel_fS_i_f_i2_param1.Release();
   delete customKernel_fS_i_f_i2;
   customKernel_fS_i_f_i3_param1.Release();
   delete customKernel_fS_i_f_i3;
   customATR_i_fS_fS_fS4_param2.Release();
   customATR_i_fS_fS_fS4_param3.Release();
   customATR_i_fS_fS_fS4_param4.Release();
   delete customATR_i_fS_fS_fS4;
   getEnvelopeBounds_fS_f_f_fS5_param1.Release();
   getEnvelopeBounds_fS_f_f_fS5_param4.Release();
   delete getEnvelopeBounds_fS_f_f_fS5;
   delete fill9;
   delete fill10;
   delete fill11;
   delete fill12;
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
      customKernel_fS_i_f_i1_param1.Init();
      customKernel_fS_i_f_i1.Clear();
      customKernel_fS_i_f_i2_param1.Init();
      customKernel_fS_i_f_i2.Clear();
      customKernel_fS_i_f_i3_param1.Init();
      customKernel_fS_i_f_i3.Clear();
      customATR_i_fS_fS_fS4_param2.Init();
      customATR_i_fS_fS_fS4_param3.Init();
      customATR_i_fS_fS_fS4_param4.Init();
      customATR_i_fS_fS_fS4.Clear();
      getEnvelopeBounds_fS_f_f_fS5_param1.Init();
      getEnvelopeBounds_fS_f_f_fS5_param4.Init();
      getEnvelopeBounds_fS_f_f_fS5.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(customEnvelope, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot_color4, 0);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot_color5, 0);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      fill9.Init();
      fill10.Init();
      fill11.Init();
      fill12.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      customKernel_fS_i_f_i1_param1.SetValue(pos, MathLog(close[pos]));
      double customKernel_fS_i_f_i1Value;
      if (!customKernel_fS_i_f_i1.GetValue(pos, customKernel_fS_i_f_i1Value)) { customKernel_fS_i_f_i1Value = EMPTY_VALUE; }
      double customEnvelopeClose = SafeMathExp(customKernel_fS_i_f_i1Value);
      customKernel_fS_i_f_i2_param1.SetValue(pos, MathLog(high[pos]));
      double customKernel_fS_i_f_i2Value;
      if (!customKernel_fS_i_f_i2.GetValue(pos, customKernel_fS_i_f_i2Value)) { customKernel_fS_i_f_i2Value = EMPTY_VALUE; }
      double customEnvelopeHigh = SafeMathExp(customKernel_fS_i_f_i2Value);
      customKernel_fS_i_f_i3_param1.SetValue(pos, MathLog(low[pos]));
      double customKernel_fS_i_f_i3Value;
      if (!customKernel_fS_i_f_i3.GetValue(pos, customKernel_fS_i_f_i3Value)) { customKernel_fS_i_f_i3Value = EMPTY_VALUE; }
      double customEnvelopeLow = SafeMathExp(customKernel_fS_i_f_i3Value);
      customEnvelope[pos] = customEnvelopeClose;
      customATR_i_fS_fS_fS4_param2.SetValue(pos, customEnvelopeHigh);
      customATR_i_fS_fS_fS4_param3.SetValue(pos, customEnvelopeLow);
      customATR_i_fS_fS_fS4_param4.SetValue(pos, customEnvelopeClose);
      double customATR_i_fS_fS_fS4Value;
      if (!customATR_i_fS_fS_fS4.GetValue(pos, customATR_i_fS_fS_fS4Value)) { customATR_i_fS_fS_fS4Value = EMPTY_VALUE; }
      double customATR = customATR_i_fS_fS_fS4Value;
      getEnvelopeBounds_fS_f_f_fS5_param1.SetValue(pos, customATR);
      getEnvelopeBounds_fS_f_f_fS5_param4.SetValue(pos, SafeLog(customEnvelopeClose));
      double getEnvelopeBounds_fS_f_f_fS5Value1;
      double getEnvelopeBounds_fS_f_f_fS5Value2;
      double getEnvelopeBounds_fS_f_f_fS5Value3;
      double getEnvelopeBounds_fS_f_f_fS5Value4;
      double getEnvelopeBounds_fS_f_f_fS5Value5;
      double getEnvelopeBounds_fS_f_f_fS5Value6;
      if (!getEnvelopeBounds_fS_f_f_fS5.GetValue(pos, getEnvelopeBounds_fS_f_f_fS5Value1, getEnvelopeBounds_fS_f_f_fS5Value2, getEnvelopeBounds_fS_f_f_fS5Value3, getEnvelopeBounds_fS_f_f_fS5Value4, getEnvelopeBounds_fS_f_f_fS5Value5, getEnvelopeBounds_fS_f_f_fS5Value6)) { getEnvelopeBounds_fS_f_f_fS5Value1 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value2 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value3 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value4 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value5 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value6 = EMPTY_VALUE; }
      double customUpperNear = getEnvelopeBounds_fS_f_f_fS5Value1;
      double customUpperFar = getEnvelopeBounds_fS_f_f_fS5Value2;
      double customUpperAvg = getEnvelopeBounds_fS_f_f_fS5Value3;
      double customLowerNear = getEnvelopeBounds_fS_f_f_fS5Value4;
      double customLowerFar = getEnvelopeBounds_fS_f_f_fS5Value5;
      double customLowerAvg = getEnvelopeBounds_fS_f_f_fS5Value6;
      color customUpperBoundaryColorFar = Red;
      color customUpperBoundaryColorNear = Red;
      color customBullishEstimatorColor = Teal;
      color customBearishEstimatorColor = Red;
      color customLowerBoundaryColorNear = Teal;
      color customLowerBoundaryColorFar = Teal;
      color plot1_color = customUpperBoundaryColorFar;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = SafeMathExp(customUpperFar); }
      else { plot1[pos] = EMPTY_VALUE; }
      double customUpperBoundaryFar = plot1[pos];
      color plot2_color = customUpperBoundaryColorNear;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = SafeMathExp(customUpperAvg); }
      else { plot2[pos] = EMPTY_VALUE; }
      double customUpperBoundaryAvg = plot2[pos];
      color plot3_color = customUpperBoundaryColorNear;
      if (plot3_color != EMPTY_VALUE) { plot3[pos] = SafeMathExp(customUpperNear); }
      else { plot3[pos] = EMPTY_VALUE; }
      double customUpperBoundaryNear = plot3[pos];
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
plot4[pos] = customEnvelopeClose;
      plot_color4[pos] = GetPlot4Color((SafeGreater(customEnvelope[pos], customEnvelope[pos - 1]) ? customBullishEstimatorColor : customBearishEstimatorColor));
      double customEstimationPlot = plot5[pos] = customEnvelopeClose;
      plot_color5[pos] = GetPlot5Color((SafeGreater(customEnvelope[pos], customEnvelope[pos - 1]) ? customBullishEstimatorColor : customBearishEstimatorColor));
;
      color plot6_color = customLowerBoundaryColorNear;
      if (plot6_color != EMPTY_VALUE) { plot6[pos] = SafeMathExp(customLowerNear); }
      else { plot6[pos] = EMPTY_VALUE; }
      double customLowerBoundaryNear = plot6[pos];
      color plot7_color = customLowerBoundaryColorNear;
      if (plot7_color != EMPTY_VALUE) { plot7[pos] = SafeMathExp(customLowerAvg); }
      else { plot7[pos] = EMPTY_VALUE; }
      double customLowerBoundaryAvg = plot7[pos];
      color plot8_color = customLowerBoundaryColorFar;
      if (plot8_color != EMPTY_VALUE) { plot8[pos] = SafeMathExp(customLowerFar); }
      else { plot8[pos] = EMPTY_VALUE; }
      double customLowerBoundaryFar = plot8[pos];
      fill9.Set(pos, customUpperBoundaryFar, customUpperBoundaryAvg, customUpperBoundaryColorFar);
      fill10.Set(pos, customUpperBoundaryNear, customUpperBoundaryAvg, customUpperBoundaryColorNear);
      fill11.Set(pos, customLowerBoundaryNear, customLowerBoundaryAvg, customLowerBoundaryColorNear);
      fill12.Set(pos, customLowerBoundaryFar, customLowerBoundaryAvg, customLowerBoundaryColorFar);
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