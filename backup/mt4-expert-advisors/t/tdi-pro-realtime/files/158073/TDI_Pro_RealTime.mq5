//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75566

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
#property indicator_buffers 8
#property indicator_plots 8
#property indicator_label1 "VB High"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Market Base Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Yellow
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "VB Low"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "RSI Price Line"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Trade Signal Line"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Red
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_type6 DRAW_LINE
#property indicator_color6 Gray
#property indicator_style6 STYLE_DOT
#property indicator_width6 1
#property indicator_type7 DRAW_LINE
#property indicator_color7 Gray
#property indicator_style7 STYLE_DOT
#property indicator_width7 1
#property indicator_type8 DRAW_LINE
#property indicator_color8 Gray
#property indicator_style8 STYLE_DOT
#property indicator_width8 1

enum PriceType
{
   PriceClose = PRICE_CLOSE, // Close
   PriceOpen = PRICE_OPEN, // Open
   PriceHigh = PRICE_HIGH, // High
   PriceLow = PRICE_LOW, // Low
   PriceMedian = PRICE_MEDIAN, // Median
   PriceTypical = PRICE_TYPICAL, // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody, // Median (body)
   PriceAverage, // Average
   PriceTrendBiased, // Trend biased
   PriceVolume, // Volume
};
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0

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
// AStream v1.1

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
// IBarStream v1.0



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

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif


// Price stream v3.1

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      int pos = Size() - 1 - period;
      return GetValues(pos, count, values);
   }

   virtual bool GetValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PriceClose:
               if (!_source.GetClose(period - i, val))
               {
                  return false;
               }
               break;
            case PriceOpen:
               if (!_source.GetOpen(period - i, val))
               {
                  return false;
               }
               break;
            case PriceHigh:
               if (!_source.GetHigh(period - i, val))
               {
                  return false;
               }
               break;
            case PriceLow:
               if (!_source.GetLow(period - i, val))
               {
                  return false;
               }
               break;
            case PriceMedian:
               {
                  double high, low;
                  if (!_source.GetHighLow(period - i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PriceTypical:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PriceWeighted:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period - i, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period - i, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period - i, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         }
         values[i] = val;
      }
      return true;
   }
};

#endif
// Bar stream v2.0



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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos)
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
      if (size <= oldPos + count - 1)
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
      if (size <= oldPos + count - 1)
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

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
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
#ifndef ChangeStream_IMPL
#define ChangeStream_IMPL


// Boolean Stream v.1.1

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
};

#endif
#ifndef BoolToFloatStream_IMPL
#define BoolToFloatStream_IMPL



// Bool to float stream v1.0

class BoolToFloatStream : public AFloatStream
{
   IBoolStream* stream;
public:
   BoolToFloatStream(IBoolStream* stream)
   {
      this.stream = stream;
      stream.AddRef();
   }
   ~BoolToFloatStream()
   {
      stream.Release();
   }

   void Init()
   {
   }

   virtual int Size()
   {
      return stream.Size();
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      bool values[];
      ArrayResize(values, count);
      if (!stream.GetValues(period, count, values))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = values[i] ? 1 : 0;
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};

#endif

//ChangeStream v1.2
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      int size = Size();
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }
};

class ChangeStreamFactory
{
public:
   static IStream* Create(IStream* stream, int period = 1)
   {
      return new ChangeStream(stream, period);
   }
   
   static IStream* Create(IBoolStream* stream, int period = 1)
   {
      BoolToFloatStream* wrapper = new BoolToFloatStream(stream);
      ChangeStream* change = new ChangeStream(wrapper, period);
      wrapper.Release();
      return change;
   }
};

#endif 


// RSI stream v1.2

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSISimpleStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSISimpleStream(IStream* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      return false;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (totalBars == 0)
      {
         return false;
      }
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff[1];
      if (period == 0 || _pos[period - 1] == EMPTY_VALUE)
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValues(period - i, 1, diff))
            {
               return false;
            }
            if (diff[0] >= 0)
            {
               sump = sump + diff[0];
            }
            else
            {
               sumn = sumn - diff[0];
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValues(period, 1, diff))
         {
            return false;
         }
         if (diff[0] > 0)
         {
            sump = diff[0];
         }
         else
         {
            sumn = -diff[0];
         }
         positive = (_pos[period - 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period - 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};

class PineScriptRSIUpDownStream : public AStreamBase
{
   IStream* _up;
   IStream* _down;
public:
   PineScriptRSIUpDownStream(IStream* up, IStream* down)
   {
      _up = up;
      _up.AddRef();
      _down = down;
      _down.AddRef();
   }
   ~PineScriptRSIUpDownStream()
   {
      _up.Release();
      _down.Release();
   }
   
   virtual int Size()
   {
      return _up.Size();
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   
   bool GetValue(const int period, double &val)
   {
      double up[1];
      double down[1];
      if (!_up.GetValues(period, 1, up) || !_down.GetValues(period, 1, down))
      {
         return false;
      }
      if (down[0] == 0)
      {
         val = 0;
         return true;
      }
      double rs = up[0] / down[0];
      val = 100 - 100.0 / (1.0 + rs);
      return true;
   }
};

class RSIStream : public AStreamBase
{
   IStream* _impl;
public:
   RSIStream(IStream* stream, int period)
   {
      _impl = new RSISimpleStream(stream, period);
   }

   RSIStream(IStream* up, IStream* down)
   {
      _impl = new PineScriptRSIUpDownStream(up, down);
   }

   ~RSIStream()
   {
      _impl.Release();
   }
   
   virtual int Size()
   {
      return _impl.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return _impl.GetValues(period, count, val);
   }
};

#endif

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

input PriceType param1 = PriceClose;
input int param2 = 10;
input int param3 = 34;
input int param4 = 2;
input int param5 = 7;
input int bars_limit = 1000; // Bars limit
IStream* param1Stream;
IStream* RSI_Price;
int RSI_Period;
FloatStream* rsi1X;
RSIStream* rsi1;
int Volatility_Band;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* stdev2Source;
StDevStream* stdev2;
int RSI_Price_Line;
int Trade_Signal_Line;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* sma3Source;
SmaOnStream* sma3;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];

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
   param1Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param1);
   RSI_Price = param1Stream;
   RSI_Period = param2;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, RSI_Period);
   Volatility_Band = param3;
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, Volatility_Band);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, Volatility_Band);
   stdev2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev2 = new StDevStream(stdev2Source, Volatility_Band);
   RSI_Price_Line = param4;
   Trade_Signal_Line = param5;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, RSI_Price_Line);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, Trade_Signal_Line);
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   SetIndexBuffer(id++, plot2, INDICATOR_DATA);
   SetIndexBuffer(id++, plot3, INDICATOR_DATA);
   SetIndexBuffer(id++, plot4, INDICATOR_DATA);
   SetIndexBuffer(id++, plot5, INDICATOR_DATA);
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, Gray);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(6, PLOT_LINE_STYLE, STYLE_DOT);
   ++id;
   SetIndexBuffer(id, plot7, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, Gray);
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(7, PLOT_LINE_STYLE, STYLE_DOT);
   ++id;
   SetIndexBuffer(id, plot8, INDICATOR_DATA);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, Gray);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(8, PLOT_LINE_STYLE, STYLE_DOT);
   ++id;
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "TDI Pro RealTime");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   param1Stream.Release();
   rsi1X.Release();
   rsi1.Release();
   sma1Source.Release();
   sma1.Release();
   stdev1Source.Release();
   stdev1.Release();
   stdev2Source.Release();
   stdev2.Release();
   sma2Source.Release();
   sma2.Release();
   sma3Source.Release();
   sma3.Release();
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
      rsi1X.Init();
      sma1Source.Init();
      stdev1Source.Init();
      stdev2Source.Init();
      sma2Source.Init();
      sma3Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, 50);
      ArrayInitialize(plot7, 68);
      ArrayInitialize(plot8, 32);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double RSI_PriceValue[1];
      if (!RSI_Price.GetValues(pos, 1, RSI_PriceValue)) { RSI_PriceValue[0] = EMPTY_VALUE; }
      rsi1X.SetValue(pos, RSI_PriceValue[0]);
      double rsi1Value[1];
      if (!rsi1.GetValues(pos, 1, rsi1Value)) { rsi1Value[0] = EMPTY_VALUE; }
      double RSIBuf = rsi1Value[0];
      sma1Source.SetValue(pos, RSIBuf);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      double MA = sma1Value[0];
      stdev1Source.SetValue(pos, RSIBuf);
      double stdev1Value[1];
      if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
      double UpZone = SafePlus(MA, (SafeMultiply(1.6185, stdev1Value[0])));
      stdev2Source.SetValue(pos, RSIBuf);
      double stdev2Value[1];
      if (!stdev2.GetValues(pos, 1, stdev2Value)) { stdev2Value[0] = EMPTY_VALUE; }
      double DnZone = SafeMinus(MA, (SafeMultiply(1.6185, stdev2Value[0])));
      double MdZone = SafeDivide((SafePlus(UpZone, DnZone)), 2);
      sma2Source.SetValue(pos, RSIBuf);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      double MaBuf = sma2Value[0];
      sma3Source.SetValue(pos, RSIBuf);
      double sma3Value[1];
      if (!sma3.GetValues(pos, 1, sma3Value)) { sma3Value[0] = EMPTY_VALUE; }
      double MbBuf = sma3Value[0];
      plot1[pos] = UpZone;
      plot2[pos] = MdZone;
      plot3[pos] = DnZone;
      plot4[pos] = MaBuf;
      plot5[pos] = MbBuf;
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75566

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