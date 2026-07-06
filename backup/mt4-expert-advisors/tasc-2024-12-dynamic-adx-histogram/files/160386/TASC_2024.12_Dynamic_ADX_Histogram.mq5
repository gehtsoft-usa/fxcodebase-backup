//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76278
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots 6
#property indicator_label1 "ADXO"
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "High Threshold"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Low Threshold"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Zero"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "-Low Threshold"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "-High Threshold"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

// Date/time Stream v.1.0

#ifndef TIStream_IMPL
#define TIStream_IMPL

template <typename T>
interface TIStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
};

#endif

//AOnStream v3.0
class AStreamBase : public TIStream<double>
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

//AOnStream v3.0
class AOnStream : public AStreamBase
{
protected:
   TIStream<double> *_source;
public:
   AOnStream(TIStream<double> *source)
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

// IBarStream v2.0



#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public TIStream<double>
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

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif
// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL


template <typename T>
class TAStream : public TIStream<T>
{
   int _refs;   
public:
   TAStream()
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


// True range on stream v1.0

#ifndef TrueRangeOnStream_IMP
#define TrueRangeOnStream_IMP

class TrueRangeOnStream : public TAStream<double>
{
   IBarStream* _source;
public:
   TrueRangeOnStream(IBarStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~TrueRangeOnStream()
   {
      _source.Release();
   }

   bool GetSeriesValues(const int period, int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   bool GetValues(const int period, int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double h, l, c1;
         if (!_source.GetHigh(period - i, h) || !_source.GetLow(period - i, l) || !_source.GetClose(period - i - 1, c1))
         {
            return false;
         }
         double hl = MathAbs(h - l);
         double hc = MathAbs(h - c1);
         double lc = MathAbs(l - c1);
   
         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
   
   int Size()
   {
      return _source.Size();
   }
};
#endif


// EMA on stream v2.0

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(TIStream<double> *source, const int length)
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
// CustomStream v2.0

class StreamBuffer
{
public:
   double _data[];

   void EnsureSize(int size)
   {
      int currentSize = ArrayRange(_data, 0);
      if (currentSize != size) 
      {
         ArrayResize(_data, size);
         for (int i = currentSize; i < size; ++i)
         {
            _data[i] = EMPTY_VALUE;
         }
      }
   }
};

class CustomStream : public AStreamBase
{
   StreamBuffer _data;
   TIStream<double> *_source;
public:
   CustomStream(TIStream<double>* base)
   {
      _source = base;
      _source.AddRef();
   }
   ~CustomStream()
   {
      _source.Release();
   }

   virtual int Size()
   {
      return _source.Size();
   }

   virtual void SetValue(int period, double value)
   {
      _data.EnsureSize(Size());
      _data._data[period] = value;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      _data.EnsureSize(size);
      for (int i = 0; i < count; ++i)
      {
         double value = _data._data[size - 1 - period + i];
         if (value == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      _data.EnsureSize(Size());
      int bars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};


//RmaOnStream v3.0
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(TIStream<double> *source, const int length)
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

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = alpha * price[0] + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
      return true;
   }
};

// Bar stream v2.1



#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }
   
   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1 || oldPos < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1 || oldPos < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif

// DMI stream v1.0

#ifndef DMIStream_IMP
#define DMIStream_IMP

class DMIOnStream : TIStream<double>
{
protected:
   IBarStream *_source;
   int _references;
   TrueRangeOnStream* tr;
   CustomStream* avgPlusDM;
   CustomStream* avgMinusDM;
   EMAOnStream* SmoothedDirectionalMovementPlus;
   EMAOnStream* SmoothedDirectionalMovementMinus;
   CustomStream* rmaSource;
   RmaOnStream* rma;
public:
   DMIOnStream(string symbol, ENUM_TIMEFRAMES timeframe, int diLength, int adxSmoothing)
   {
      _source = new BarStream(symbol, timeframe);
      Init(diLength, adxSmoothing);
   }
   
   DMIOnStream(IBarStream* stream, int diLength, int adxSmoothing)
   {
      _source = stream;
      _source.AddRef();
      Init(diLength, adxSmoothing);
   }
   
   void Init(int diLength, int adxSmoothing)
   {
      _references = 1;
      if (_source != NULL)
      {
         _source.AddRef();
         tr = new TrueRangeOnStream(_source);
         avgPlusDM = new CustomStream(tr);
         avgMinusDM = new CustomStream(tr);
         SmoothedDirectionalMovementPlus = new EMAOnStream(avgPlusDM, diLength);
         SmoothedDirectionalMovementMinus = new EMAOnStream(avgMinusDM, diLength);
         rmaSource = new CustomStream(tr);
         rma = new RmaOnStream(rmaSource, adxSmoothing);
      }
   }

   ~DMIOnStream()
   {
      _source.Release();
      tr.Release();
      avgPlusDM.Release();
      avgMinusDM.Release();
      SmoothedDirectionalMovementPlus.Release();
      SmoothedDirectionalMovementMinus.Release();
      rmaSource.Release();
      rma.Release();
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

   virtual int Size()
   {
      return _source.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      return false;
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return false;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return false;
   }
   
   virtual bool GetValues(const int period, const int count, double &ADX[], double& DIPlus[], double& DIMinus[])
   {
      int totalBars = _source.Size();
      for (int i = 0; i < count; ++i)
      {
         double h, h1;
         if (!_source.GetHigh(period - i, h) || !_source.GetHigh(period - i - 1, h1))
         {
            return false;
         }
         double l, l1;
         if (!_source.GetLow(period - i, l) || !_source.GetLow(period - i - 1, l1))
         {
            return false;
         }
         double DirectionalMovementPlus = MathAbs(h - h1);
         double DirectionalMovementMinus = MathAbs(l - l1);
         if (DirectionalMovementPlus == DirectionalMovementMinus)
         {
            DirectionalMovementPlus = 0;
            DirectionalMovementMinus = 0;
         }
         else if (DirectionalMovementPlus < DirectionalMovementMinus)
         {
            DirectionalMovementPlus = 0;
         }
         else if (DirectionalMovementMinus < DirectionalMovementPlus)
         {
            DirectionalMovementMinus = 0;
         }
         double TR[1];
         if (!tr.GetValues(period - i, 1, TR))
         {
            return false;
         }
         avgPlusDM.SetValue(period - i, TR[0] == 0 ? 0 : 100 * DirectionalMovementPlus / TR[0]);
         avgMinusDM.SetValue(period - i, TR[0] == 0 ? 0 : 100 * DirectionalMovementMinus / TR[0]);
        
         double dip[1];
         double dim[1];
         if (!SmoothedDirectionalMovementPlus.GetValues(period - i, 1, dip) || !SmoothedDirectionalMovementMinus.GetValues(period - i, 1, dim))
         {
            return false;
         }
         
         double DX = (MathAbs(dip[0] - dim[0]) / (dip[0] + dim[0])) * 100;
         rmaSource.SetValue(period - i, DX);
         double adx[1];
         if (!rma.GetValues(period - i, 1, adx))
         {
            return false;
         }
         ADX[i] = adx[0];
         DIPlus[i] = dip[0];
         DIMinus[i] = dim[0];
      }
      return true;
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
      return INT_MIN;
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
      return INT_MIN;
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
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public TIStream<double>
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
// Float stream v2.1

class FloatStream : public AFloatStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
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
         if (val[i] == _emptyValue)
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
            _stream[i] = _emptyValue;
         }
      }
   }
};

#endif

//SMAOnStream v5.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(TIStream<double> *source, const int length)
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

class PineScriptTime
{
public:
   static int Day(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day;
   }
   static int Hour(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.hour;
   }
   static int Year(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.year;
   }
   static int DayOfWeek(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day_of_week;
   }
   static int Sunday()
   {
      return 0;
   }
   static int Monday()
   {
      return 1;
   }
   static int Tuesday()
   {
      return 2;
   }
   static int Wednesday()
   {
      return 3;
   }
   static int Thursday()
   {
      return 4;
   }
   static int Friday()
   {
      return 5;
   }
   static int Saturday()
   {
      return 6;
   }
};
// Colored plor v1.0


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
input int param1 = 10; // ADX Length
input double param2 = 15; // Low Threshold
input double param3 = 40; // High Threshold
input int param4 = 1; // DMI Smoothing Length
input color param5 = 0xffff00; // gu
input color param6 = 0x8b8b00; // 
input color param7 = 0x00ff09; // 
input color param8 = 0x008004; // 
input color param9 = 0x383838; // gn
input color param10 = 0x000000; // 
input color param11 = 0x000068; // gd
input color param12 = 0x0000ff; // 
input color param13 = 0x1f005c; // 
input color param14 = 0xaa00ff; // 
input int bars_limit = 1000; // Bars limit
string title;
string stitle;
int ADX_Length;
double ADX_THLo;
double ADX_THHi;
int ADX_Smooth;
string gu;
string gn;
string gd;
uint col_OBUp;
uint col_OBWUp;
uint col_Up;
uint col_WUp;
uint col_NUp;
uint col_Ndn;
uint col_Wdn;
uint col_dn;
uint col_OSWdn;
uint col_OSdn;
DMIOnStream* dmi1;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* sma2Source;
SmaOnStream* sma2;
double DIA[];
double DIA_DEFAULT_VALUE;
ColoredPlot* plot1;
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];

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
   ADX_Length = param1;
   ADX_THLo = param2;
   ADX_THHi = param3;
   ADX_Smooth = param4;
   col_OBUp = param5;
   col_OBWUp = param6;
   col_Up = param7;
   col_WUp = param8;
   col_NUp = param9;
   col_Ndn = param10;
   col_Wdn = param11;
   col_dn = param12;
   col_OSWdn = param13;
   col_OSdn = param14;
   dmi1 = new DMIOnStream(_Symbol, (ENUM_TIMEFRAMES)_Period, ADX_Length, ADX_Length);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, ADX_Smooth);
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, ADX_Smooth);
   int id = 0;
   plot1 = new ColoredPlot(0);
   plot1.AddColor((uint)(INT_MAX));
   plot1.AddColor(col_NUp);
   plot1.AddColor(col_Ndn);
   plot1.AddColor(col_OBUp);
   plot1.AddColor(col_OBWUp);
   plot1.AddColor(col_Up);
   plot1.AddColor(col_WUp);
   plot1.AddColor(col_OSdn);
   plot1.AddColor(col_OSWdn);
   plot1.AddColor(col_dn);
   plot1.AddColor(col_Wdn);
   plot1.SetOffset(0);
   id = plot1.RegisterStreams(id);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   SetIndexBuffer(id, plot5, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   IndicatorObjPrefix = GenerateIndicatorPrefix(stitle);
   IndicatorSetString(INDICATOR_SHORTNAME, title);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, DIA, INDICATOR_CALCULATIONS);
   id = plot1.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   dmi1.Release();
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
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
      DIA_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(DIA, DIA_DEFAULT_VALUE);
      plot1.Init();
      ArrayInitialize(plot2, ADX_THHi);
      ArrayInitialize(plot3, ADX_THLo);
      ArrayInitialize(plot4, 0);
      ArrayInitialize(plot5, (-ADX_THLo));
      ArrayInitialize(plot6, (-ADX_THHi));
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      title = "TASC 2024.12 Dynamic ADX Histogram";
      stitle = "DADX";
      gu = "Colors, Up:";
      gn = "Neutral:";
      gd = "Down:";
      double dmi1Value1[1];
      double dmi1Value2[1];
      double dmi1Value3[1];
      if (!dmi1.GetValues(pos, 1, dmi1Value1, dmi1Value2, dmi1Value3)) { dmi1Value1[0] = EMPTY_VALUE; dmi1Value2[0] = EMPTY_VALUE; dmi1Value3[0] = EMPTY_VALUE; }
      double DIP = dmi1Value1[0];
      double DIN = dmi1Value2[0];
      SetStream(DIA, pos, dmi1Value3[0], DIA_DEFAULT_VALUE);
      double NADX = InvertSign(DIA[pos]);
      sma1Source.SetValue(pos, DIP);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      double SP = sma1Value[0];
      sma2Source.SetValue(pos, DIN);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      double SM = sma2Value[0];
      double NET = SafeMinus(SP, SM);
      if (pos - 1 < 0) { continue; }
      int isDIAup = SafeGreater(DIA[pos], DIA[pos - 1]);
      if (pos - 1 < 0) { continue; }
      int isDIAdn = SafeLess(DIA[pos], DIA[pos - 1]);
      uint col = (uint)(INT_MAX);
      if (isDIAup)
      {
         col = col_NUp;
      }
      if (isDIAdn)
      {
         col = col_Ndn;
      }
      double osc = EMPTY_VALUE;
      if (SafeGE(NET, 0))
      {
         if (SafeGE(DIA[pos], ADX_THHi))
         {
            if (isDIAup)
            {
               col = col_OBUp;
            }
            if (isDIAdn)
            {
               col = col_OBWUp;
            }
         }
         if (SafeGE(DIA[pos], ADX_THLo) && SafeLE(DIA[pos], ADX_THHi))
         {
            if (isDIAup)
            {
               col = col_Up;
            }
            if (isDIAdn)
            {
               col = col_WUp;
            }
         }
         osc = DIA[pos];
      }
      else if (SafeLess(NET, 0))
      {
         if (SafeGE(DIA[pos], ADX_THHi))
         {
            if (isDIAup)
            {
               col = col_OSdn;
            }
            if (isDIAdn)
            {
               col = col_OSWdn;
            }
         }
         if (SafeGE(DIA[pos], ADX_THLo) && SafeLE(DIA[pos], ADX_THHi))
         {
            if (isDIAup)
            {
               col = col_dn;
            }
            if (isDIAdn)
            {
               col = col_Wdn;
            }
         }
         osc = NADX;
      }
      double plot1Value = plot1.Set(pos, osc, col);
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76278
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+