//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=68690&start=20

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_label1 "TTM Squeeze - Momentum"
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

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
class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
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
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

//True range stream v1.1

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
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

// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      IStream* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
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

   bool GetValues(const int period, const int count, double &val[])
   {
      return _avg.GetValues(period, count, val);
   }
   
   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int oldPos = Size() - period - 1;
      return GetValues(oldPos, count, val);
   }

};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif
// Float stream v2.0

class FloatStream : public AFloatStream
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

// Pine-script like safe operations
// v1.2

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

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
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
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}


// StDev stream v1.2

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(IStream* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      double __data[];
      ArrayResize(__data, _period);
      if (!_source.GetSeriesValues(period, _period, __data))
      {
         return false;
      }
      for (int i = 0; i < _period; i++)
      {
         sum += __data[i];
         ssum += MathPow(__data[i], 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
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
// Colored plor v1.0
#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      int colorsCount = ArraySize(initColors);
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = GetColorOnly(clr);
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, values, INDICATOR_DATA);
      int colorsCount = ArraySize(initColors);
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      id += 1;
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   double Set(int pos, double value, uint clr)
   {
      int transp = GetTranparency(clr);
      buffer[pos] = value;
      values[pos] = value;
      colors[pos] = FindColorIndex(clr);
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return EMPTY_VALUE;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return EMPTY_VALUE;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return EMPTY_VALUE;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
      return value;
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      color searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      return -1;
   }
};
input int param1 = 20;
input double param2 = 2;
input int param3 = 20;
input int param4 = 20;
input double param5 = 2;
input int param6 = 12; // Momemtum Period
input int param7 = 5; // Momentum EMA Period
input int bars_limit = 1000; // Bars limit
int BB_Length;
double BB_Deviation;
int Keltner_Length;
int Keltner_Smooth_Length;
double Keltner_Deviation;
int momPeriod;
int momEMA;
ATRStream* atr1;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* ema1Source;
EMAOnStream* ema1;
ColoredPlot* plot1;

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
   BB_Length = param1;
   BB_Deviation = param2;
   Keltner_Length = param3;
   Keltner_Smooth_Length = param4;
   Keltner_Deviation = param5;
   momPeriod = param6;
   momEMA = param7;
   atr1 = new ATRStream(Keltner_Smooth_Length);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, Keltner_Length);
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, BB_Length);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, BB_Length);
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, momEMA);
   plot1 = new ColoredPlot(0);
   plot1.AddColor(Blue);
   plot1.AddColor(Orange);
   plot1.AddColor(Aqua);
   plot1.AddColor(Maroon);
   plot1.SetOffset(0);
   id = plot1.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "TTMS logicgate");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   id = plot1.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   atr1.Release();
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
   stdev1Source.Release();
   stdev1.Release();
   ema1Source.Release();
   ema1.Release();
   delete plot1;
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
      sma1Source.Init();
      sma2Source.Init();
      stdev1Source.Init();
      ema1Source.Init();
      plot1.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double atr1Value[1];
      if (!atr1.GetValues(pos, 1, atr1Value)) { atr1Value[0] = EMPTY_VALUE; }
      double ATR = atr1Value[0];
      sma1Source.SetValue(pos, close[pos]);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      double MA = sma1Value[0];
      double H = SafePlus(MA, SafeMultiply(ATR, Keltner_Deviation));
      double L = SafeMinus(MA, SafeMultiply(ATR, Keltner_Deviation));
      sma2Source.SetValue(pos, close[pos]);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      double ML = sma2Value[0];
      stdev1Source.SetValue(pos, close[pos]);
      double stdev1Value[1];
      if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
      double D = stdev1Value[0];
      double TL = SafePlus(ML, SafeMultiply(BB_Deviation, D));
      double BL = SafeMinus(ML, SafeMultiply(BB_Deviation, D));
      if (pos - momPeriod < 0) { continue; }
      double momHist = SafeMinus(close[pos], close[pos - momPeriod]);
      ema1Source.SetValue(pos, momHist);
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
      double momHistVal = ema1Value[0];
      int buy = SafeGreater(TL, H) && SafeGreater(momHistVal, 0);
      int sell = SafeLess(TL, H) && SafeLess(momHistVal, 0);
      double plot1Value = plot1.Set(pos, momHistVal, (buy ? Blue : (sell ? Orange : (SafeGreater(momHistVal, 0) ? Aqua : Maroon))));
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=68690&start=20

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 