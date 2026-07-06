//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74618

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_label1 "H F"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Maroon
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "H F"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "H F"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Silver
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "L F"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "L F"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "L F"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Silver
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "H D"
#property indicator_type7 DRAW_ARROW
#property indicator_color7 Maroon
#property indicator_style7 STYLE_SOLID
#property indicator_width7 3
#property indicator_label8 "H D"
#property indicator_type8 DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 3
#property indicator_label9 "H D"
#property indicator_type9 DRAW_ARROW
#property indicator_color9 Silver
#property indicator_style9 STYLE_SOLID
#property indicator_width9 3
#property indicator_label10 "L D"
#property indicator_type10 DRAW_ARROW
#property indicator_color10 Green
#property indicator_style10 STYLE_SOLID
#property indicator_width10 3
#property indicator_label11 "L D"
#property indicator_type11 DRAW_ARROW
#property indicator_style11 STYLE_SOLID
#property indicator_width11 3
#property indicator_label12 "L D"
#property indicator_type12 DRAW_ARROW
#property indicator_color12 Silver
#property indicator_style12 STYLE_SOLID
#property indicator_width12 3
#property indicator_label13 "+RBD"
#property indicator_type13 DRAW_ARROW
#property indicator_color13 Maroon
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "+HBD"
#property indicator_type14 DRAW_ARROW
#property indicator_color14 Maroon
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "-RBD"
#property indicator_type15 DRAW_ARROW
#property indicator_color15 Green
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "-HBD"
#property indicator_type16 DRAW_ARROW
#property indicator_color16 Green
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1

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

// Stream base v1.0

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

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
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
};
#endif

// Instrument info v.1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
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

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#define AStream_IMP
#endif
// IBarStream v2.1



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


// Price stream v2.0

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

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};


#endif
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
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
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
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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


// Float stream v2.3

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
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
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


//Base implementation of stream based on another stream 
//v1.1

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
      if (_source != NULL)
      {
         _source.AddRef();
      }
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

   virtual int Size()
   {
      return _source.Size();
   }
};
// Change stream v1.1

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

// v1.0
// Wraps IIntStream and provides IStream

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL
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
// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, int &val) = 0;
};

#endif

class IntToFloatStreamWrapper : public AFloatStream
{
   IIntStream* _source;
public:
   IntToFloatStreamWrapper(IIntStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~IntToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      int intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(IIntStream* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double src1, src2;
      if (!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
      {
         return false;
      }
      val = src1 - src2;
      return true;
   }
};

#endif


// RSI stream v1.1

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
   
   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff;
      if (period == totalBars - 1 || _pos[period + 1])
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValue(period + i, diff))
            {
               return false;
            }
            if (diff >= 0)
            {
               sump = sump + diff;
            }
            else
            {
               sumn = sumn - diff;
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValue(period, diff))
         {
            return false;
         }
         if (diff > 0)
         {
            sump = diff;
         }
         else
         {
            sumn = -diff;
         }
         positive = (_pos[period + 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period + 1] * (_period - 1) + sumn) / _period;
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

   virtual bool GetValue(const int period, double &val)
   {
      double up;
      double down;
      if (!_up.GetValue(period, up) || !_down.GetValue(period, down))
      {
         return false;
      }
      if (down == 0)
      {
         val = 0;
         return true;
      }
      double rs = up / down;
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

   virtual bool GetValue(const int period, double &val)
   {
      return _impl.GetValue(period, val);
   }
};

#endif


// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current_;
            if (!_source.GetValue(period + i, current_))
               return false;

           summ += current_;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// Pine-script like safe operations
// v.1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
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
      return (bool)EMPTY_VALUE;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left <= right;
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


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
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
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif


// Simple price stream v1.2



class SimplePriceStream : public AStream
{
   PriceType _price;
   int _periodShift;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price, int periodShift = 0)
      :AStream(symbol, timeframe)
   {
      _price = __price;
      _periodShift = periodShift;
   }

   bool GetValue(const int period, double &val)
   {
      ResetLastError();
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) + iOpen(_symbol, _timeframe, period + _periodShift)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period + _periodShift);
               if (iOpen(_symbol, _timeframe, period + _periodShift) > iClose(_symbol, _timeframe, period + _periodShift))
                  val = (iHigh(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period + _periodShift);
            break;
      }
      if (GetLastError() != ERR_NO_ERROR)
      {
         return false;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


// Highest high stream v1.5

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _loopback = loopback;
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return HighestHighStream::GetValue(period, val, _source, _loopback);
   }
};




// Lowest low stream v1.5

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _loopback = loopback;
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return LowestLowStream::GetValue(period, val, _source, _loopback);
   }
};

// Stochastics on stream v1.0

class StochOnStream : public AStreamBase
{
   IStream* _closeStream;
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
   int _period;
public:
   StochOnStream(IStream* closeStream, IStream* highStream, IStream* lowStream, int period)
      :AStreamBase()
   {
      _period = period;
      _closeStream = closeStream;
      _closeStream.AddRef();
      _highest = new HighestHighStream(highStream, period);
      _lowest = new LowestLowStream(lowStream, period);
   }

   ~StochOnStream()
   {
      _closeStream.Release();
      _highest.Release();
      _lowest.Release();
   }
   
   virtual int Size()
   {
      return _closeStream.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double close;
      if (!_closeStream.GetValue(period, close))
      {
         return false;
      }
      double lowest;
      if (!_lowest.GetValue(period, lowest))
      {
         return false;
      }
      double highest;
      if (!_highest.GetValue(period, highest))
      {
         return false;
      }
      double diff = (highest - lowest);
      val = diff == 0 ? 0 : 100 * (close - lowest) / diff;
      return true;
   }
};



// Cumulative on stream v1.0

#ifndef CumOnStream_IMP
#define CumOnStream_IMP

class CumOnStream : public AOnStream
{
   double _buffer[];
public:
   CumOnStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);

      double current;
      if (!_source.GetValue(period, current))
         return false;
      
      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - 1 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current;
      }
      else 
      {
         _buffer[bufferIndex] = current;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif






// Difference between two streams v1.0

class TwoStreamDifferenceStream : public AStreamBase
{
   IStream* _first;
   IStream* _second;
public:
   TwoStreamDifferenceStream(IStream* first, IStream* second)
      :AStreamBase()
   {
      _first = first;
      _first.AddRef();
      _second = second;
      _second.AddRef();
   }
   ~TwoStreamDifferenceStream()
   {
      _first.Release();
      _second.Release();
   }

   virtual int Size()
   {
      return _first.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double first;
      double second;
      if (!_first.GetValue(period, first) || !_second.GetValue(period, second))
      {
         return false;
      }
      val = first - second;
      return true;
   }
};


//AbsStream v1.0
class AbsStream : public AOnStream
{
public:
   AbsStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
      {
         return false;
      }
      val = MathAbs(price);
      return true;
   }
};



// Sum on stream v1.2


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

   bool GetValue(const int period, double &val)
   {
      //period is an index for time series (0 = latest)
      int totalBars = Bars;
      int range = ArrayRange(_buffer, 0);
      if (range != totalBars)
      {
         ArrayResize(_buffer, totalBars);
         for (int i = range; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
         
      int bufferIndex = totalBars - 1 - period;
      if (bufferIndex > 0 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         if (GetValueBuffered(period, val, bufferIndex))
         {
            _buffer[bufferIndex] = val;
            return true;
         }
         return false;
      }

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current;
         if (!_source.GetValue(period + i, current))
         {
            return false;
         }
         sum += current;
      }
      _buffer[bufferIndex] = sum;
      val = _buffer[bufferIndex];
      return true;
   }
   
private:
   bool GetValueBuffered(const int period, double &val, int bufferIndex)
   {
      double toSubstruct;
      if (!_source.GetValue(period + _length, toSubstruct))
      {
         return false;
      }
      double toAdd;
      if (!_source.GetValue(period, toAdd))
      {
         return false;
      }
      
      val = _buffer[bufferIndex - 1] + toAdd - toSubstruct;
      return true;
   }
};

// CCI on stream v1.0

class CCIOnStream : public AOnStream
{
   double _length;
   TwoStreamDifferenceStream* _diff;
   SumOnStream* _sum;
   double _mul;
public:
   CCIOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      SmaOnStream* mov = new SmaOnStream(source, length);
      _mul = 0.015 / length;
      _diff = new TwoStreamDifferenceStream(source, mov);
      mov.Release();
      AbsStream* diffAbs = new AbsStream(_diff);
      _sum = new SumOnStream(diffAbs, length);
      diffAbs.Release();
   }

   ~CCIOnStream()
   {
      _diff.Release();
      _sum.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double diff = 0;
      if (!_sum.GetValue(period, sum) || !_diff.GetValue(period, diff))
      {
         return false;
      }
      sum *= _mul;
      val = diff / sum;
      return true;
   }
};


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
   
   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < _period; i++)
      {
         double __data;
         if (!_source.GetValue(period + i, __data))
            return false;
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL


class AIntStream : public IIntStream
{
   int _refs;   
public:
   AIntStream()
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

class IntStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _stream[];
public:
   IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, int value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, int &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
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

// Stream returns rising flag. Similar to ta.rising in PineScript v1.1
// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, bool &val) = 0;
};

#endif

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
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

class RisingStream : public ABoolStream
{
   IStream* _source;
   int _length;
public:
   RisingStream(IStream* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
   }
   ~RisingStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, bool &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double prev;
      if (!_source.GetValue(period + _length, prev))
      {
         return false;
      }
      val = prev < current;
      return true;
   }
};
// Stream returns falling flag. Similar to ta.falling in PineScript v1.0


class FallingStream : public ABoolStream
{
   IStream* _source;
   int _length;
public:
   FallingStream(IStream* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
   }
   ~FallingStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, bool &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double prev;
      if (!_source.GetValue(period + _length, prev))
      {
         return false;
      }
      val = prev > current;
      return true;
   }
};
// Value when stream (condition as a parameter) v1.0


// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _stream[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   double Update(const int period, datetime date, bool condition, double val)
   {
      if (condition)
      {
         int size = ArraySize(_periods);
         if (size == 0 || _periods[size - 1] != date)
         {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
         }
         else
         {
            _values[size - 1] = val;
         }
         if (size > _shift)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
      }
      else if (iBars(_symbol, _timeframe) - 1 > period)
      {
         _stream[period] = _stream[period + 1];
      }
      return _stream[period];
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};
#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)

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

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}


// Colored stream v4.0

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class IColoredStreamData
{
public:
   virtual void Init(double defaultValue) = 0;
   virtual int Register(int id) = 0;
   virtual double GetValue(int pos) = 0;
   virtual color GetColor() = 0;
   virtual void Set(int period, double value, double prevValue) = 0;
   virtual void Clear(int period) = 0;
};

class InternalStream
{
public:
   double _stream[];
};

class LineColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   string _label;
   int _lineType;
   ENUM_LINE_STYLE _lineStyle;
   int _width;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   InternalStream* _internalStream;
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width, InternalStream* internalStream)
   {
      _internalStream = internalStream;
      _symbol = symbol;
      _timeframe = timeframe;
      _color = clr;
      _label = label;
      _lineType = lineType;
      _lineStyle = lineStyle;
      _width = width;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexStyle(id, _lineType, _lineStyle, _width, _color);
      if (_label != "")
         SetIndexLabel(id, _label);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      if (value == EMPTY_VALUE)
      {
         _stream[period] = EMPTY_VALUE;
         return;
      }
      int size = iBars(_symbol, _timeframe);
      int nextNonEmpty = FindNextNonempty(period, size);
      int count = nextNonEmpty - period + 1;
      double startPoint = _internalStream._stream[nextNonEmpty];
      double diff = startPoint - value;
      for (int i = nextNonEmpty; i >= period; --i)
      {
         _stream[i] = value - double(period - i) / count * diff;
      }
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
private:
   int FindNextNonempty(int period, int size)
   {
      for (int i = period + 1; i < size; ++i)
      {
         if (_internalStream._stream[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return period;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width, InternalStream* internalStream)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
   }
   ~HistogramColoredStreamData()
   {
      delete _up;
      delete _down;
   }
   void Init(double defaultValue)
   {
      _up.Init(defaultValue);
      _down.Init(defaultValue);
   }

   int Register(int id)
   {
      id = _up.Register(id);
      return _down.Register(id);
   }

   double GetValue(int pos)
   {
      return _up.GetValue(pos);
   }

   color GetColor()
   {
      return _up.GetColor();
   }

   void Set(int period, double value, double prevValue)
   {
      _up.Set(period, value, prevValue);
      _down.Set(period, 0, 0);
   }

   void Clear(int period)
   {
      _up.Clear(period);
      _down.Clear(period);
   }
};

class ArrowColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   int _arrow;
public:
   ArrowColoredStreamData(int arrow, color clr)
   {
      _arrow = arrow;
      _color = clr;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexArrow(id, _arrow);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      _stream[period] = value;
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
};

class ColoredStream : public AStream
{
   IColoredStreamData* _streams[];
   InternalStream* _internal;
public:
   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _internal = new InternalStream();
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      delete _internal;
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_internal._stream, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _internal._stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }
   
   int RegisterArrowStream(int id, color clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, clr);
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, clr, label, lineType, lineStyle, width, _internal);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, color clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, clr, label, width, _internal);
      return _streams[size].Register(id);
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetValue(period) != EMPTY_VALUE)
            return i;
      }
      return -1;
   }
   
   double SetByColor(double value, int period, color clr)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetColor() == clr)
         {
            Set(value, period, i);
            return value;
         }
      }
      _internal._stream[period] = value;
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _internal._stream[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _internal._stream[period + 1];
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Set(period, value, prevValue);
         }
         else
         {
            _streams[i].Clear(period);
         }
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _internal._stream[period];
      return _internal._stream[period] != EMPTY_VALUE;
   }
};

#endif
input string param1 = "BB %B";
input bool param2 = true; // Show Labels
input bool param3 = false; // Show Channel
input bool param4 = true; // Show Hidden Divergence
input bool param5 = true; // Show Regular Divergence
input bool param6 = false; // Use EMA Trend direction for Trend Acc Volume
input int param7 = 20; // Length for Method (except MACD):
input PriceType param8 = PriceClose; // MACD Source:
input int param9 = 12; // MACD Fast:
input int param10 = 26; // MACD Slow:
input int param11 = 9; // MACD Smooth Signal:
input int bars_limit = 100000; // Bars limit
string method;
bool SHOW_LABEL;
bool SHOW_CHANNEL;
bool uHid;
bool uReg;
bool uTVAma;
int rsi_smooth;
IStream* param8Stream;
IStream* macd_src;
int macd_fast;
int macd_slow;
int macd_smooth;
FloatStream* rsi1X;
RSIStream* rsi1;
FloatStream* rsi2X;
RSIStream* rsi2;
class f_macd_fS_i_i_iStream
{
   IStream* _src;
   int _fast;
   int _slow;
   int _smooth;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   bool _initialized;
public:
   f_macd_fS_i_i_iStream(IStream* _src, int _fast, int _slow, int _smooth)
   {
      _initialized = false;
      this._src = _src;
      _src.AddRef();
      this._fast = _fast;
      this._slow = _slow;
      this._smooth = _smooth;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, _fast);
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, _slow);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, _smooth);
   }
   ~f_macd_fS_i_i_iStream()
   {
      _src.Release();
      sma1Source.Release();
      sma1.Release();
      sma2Source.Release();
      sma2.Release();
      ema1Source.Release();
      ema1.Release();
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
         sma1Source.Init();
         sma2Source.Init();
         ema1Source.Init();
         _initialized = true;
      }
      double _srcValue;
      if (!_src.GetValue(pos, _srcValue)) { _srcValue = EMPTY_VALUE; }
      sma1Source.SetValue(pos, _srcValue);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double _fast_ma = sma1Value;
      sma2Source.SetValue(pos, _srcValue);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double _slow_ma = sma2Value;
      double _macd = SafeMinus(_fast_ma, _slow_ma);
      ema1Source.SetValue(pos, _macd);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double _signal = ema1Value;
      double _hist = SafeMinus(_macd, _signal);
      __out1 = _hist;
      return true;
   }
};
FloatStream* f_macd_fS_i_i_i1_param1;
f_macd_fS_i_i_iStream* f_macd_fS_i_i_i1;
FloatStream* f_macd_fS_i_i_i2_param1;
f_macd_fS_i_i_iStream* f_macd_fS_i_i_i2;
FloatStream* stoch1Source;
FloatStream* stoch1High;
FloatStream* stoch1Low;
StochOnStream* stoch1;
FloatStream* stoch2Source;
FloatStream* stoch2High;
FloatStream* stoch2Low;
StochOnStream* stoch2;
FloatStream* sma3Source;
SmaOnStream* sma3;
FloatStream* sma4Source;
SmaOnStream* sma4;
class f_accdist_iStream
{
   int _smooth;
   FloatStream* sma5Source;
   SmaOnStream* sma5;
   FloatStream* cum1X;
   CumOnStream* cum1;
   bool _initialized;
public:
   f_accdist_iStream(int _smooth)
   {
      _initialized = false;
      this._smooth = _smooth;
      cum1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      cum1 = new CumOnStream(cum1X);
      sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma5 = new SmaOnStream(sma5Source, _smooth);
   }
   ~f_accdist_iStream()
   {
      sma5Source.Release();
      sma5.Release();
      cum1X.Release();
      cum1.Release();
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
         cum1X.Init();
         sma5Source.Init();
         _initialized = true;
      }
      cum1X.SetValue(pos, (((iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) == iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) == iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)) || (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) == iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))) ? 0 : (SafeDivide((2 * iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) - iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) - iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)), (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) - iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)))) * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)));
      double cum1Value;
      if (!cum1.GetValue(pos, cum1Value)) { cum1Value = EMPTY_VALUE; }
      sma5Source.SetValue(pos, cum1Value);
      double sma5Value;
      if (!sma5.GetValue(pos, sma5Value)) { sma5Value = EMPTY_VALUE; }
      double _return = sma5Value;
      __out1 = _return;
      return true;
   }
};
f_accdist_iStream* f_accdist_i3;
f_accdist_iStream* f_accdist_i4;
class f_fisher_fS_iStream
{
   IStream* _src;
   int _window;
   FloatStream* highest1Source;
   FloatStream* lowest1Source;
   double _value0[];
   double _fisher[];
   bool _initialized;
public:
   f_fisher_fS_iStream(IStream* _src, int _window)
   {
      _initialized = false;
      this._src = _src;
      _src.AddRef();
      this._window = _window;
      highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~f_fisher_fS_iStream()
   {
      _src.Release();
      highest1Source.Release();
      lowest1Source.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, _value0);
      SetIndexBuffer(id++, _fisher);
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
         highest1Source.Init();
         lowest1Source.Init();
         ArrayInitialize(_value0, 0.0);
         ArrayInitialize(_fisher, 0.0);
         _initialized = true;
      }
      double _srcValue;
      if (!_src.GetValue(pos, _srcValue)) { _srcValue = EMPTY_VALUE; }
      highest1Source.SetValue(pos, _srcValue);
      double highest1Value;
      if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, _window)) { highest1Value = EMPTY_VALUE; }
      double _h = highest1Value;
      lowest1Source.SetValue(pos, _srcValue);
      double lowest1Value;
      if (!LowestLowStream::GetValue(pos, lowest1Value, lowest1Source, _window)) { lowest1Value = EMPTY_VALUE; }
      double _l = lowest1Value;
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      _value0[pos] = SafePlus(SafeMultiply(.66, (SafeMinus(SafeDivide((SafeMinus(_srcValue, _l)), SafeMathMax(SafeMinus(_h, _l), .001)), .5))), SafeMultiply(.67, Nz(_value0[pos + 1])));
      double _value1 = ((_value0[pos] > .99) ? .999 : ((_value0[pos] < (-.99)) ? (-.999) : _value0[pos]));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      _fisher[pos] = SafePlus(SafeMultiply(.5, SafeLog(SafeDivide((1 + _value1), MathMax(1 - _value1, .001)))), SafeMultiply(.5, Nz(_fisher[pos + 1])));
      __out1 = _fisher[pos];
      return true;
   }
};
FloatStream* f_fisher_fS_i5_param1;
f_fisher_fS_iStream* f_fisher_fS_i5;
FloatStream* f_fisher_fS_i6_param1;
f_fisher_fS_iStream* f_fisher_fS_i6;
FloatStream* cci1Source;
CCIOnStream* cci1;
FloatStream* cci2Source;
CCIOnStream* cci2;
class pcBB_fS_iStream
{
   IStream* p;
   int l;
   FloatStream* sma6Source;
   SmaOnStream* sma6;
   FloatStream* stdev1Source;
   StDevStream* stdev1;
   bool _initialized;
public:
   pcBB_fS_iStream(IStream* p, int l)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
      this.l = l;
      sma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma6 = new SmaOnStream(sma6Source, l);
      stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stdev1 = new StDevStream(stdev1Source, l);
   }
   ~pcBB_fS_iStream()
   {
      p.Release();
      sma6Source.Release();
      sma6.Release();
      stdev1Source.Release();
      stdev1.Release();
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
         sma6Source.Init();
         stdev1Source.Init();
         _initialized = true;
      }
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      sma6Source.SetValue(pos, pValue);
      double sma6Value;
      if (!sma6.GetValue(pos, sma6Value)) { sma6Value = EMPTY_VALUE; }
      double basis = sma6Value;
      stdev1Source.SetValue(pos, pValue);
      double stdev1Value;
      if (!stdev1.GetValue(pos, stdev1Value)) { stdev1Value = EMPTY_VALUE; }
      double dev = SafeMultiply(0.1, stdev1Value);
      double upper = SafePlus(basis, dev);
      double lower = SafeMinus(basis, dev);
      double pcBB = SafeDivide((SafeMinus(pValue, lower)), (SafeMinus(upper, lower)));
      __out1 = pcBB;
      return true;
   }
};
FloatStream* pcBB_fS_i7_param1;
pcBB_fS_iStream* pcBB_fS_i7;
FloatStream* pcBB_fS_i8_param1;
pcBB_fS_iStream* pcBB_fS_i8;
class irma_fS_iSStream
{
   IStream* p;
   IIntStream* l;
   double irma[];
   bool _initialized;
public:
   irma_fS_iSStream(IStream* p, IIntStream* l)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
      this.l = l;
      l.AddRef();
   }
   ~irma_fS_iSStream()
   {
      p.Release();
      l.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, irma);
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
         ArrayInitialize(irma, 0.0);
         _initialized = true;
      }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      int lValue;
      if (!l.GetValue(pos, lValue)) { lValue = EMPTY_VALUE; }
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      irma[pos] = SafeDivide((SafePlus(SafeMultiply(Nz(irma[pos + 1]), (lValue - 1)), pValue)), lValue);
      __out1 = irma[pos];
      return true;
   }
};
class irsi_fS_iSStream
{
   IStream* p;
   IIntStream* l;
   FloatStream* change1Source;
   ChangeStream* change1;
   FloatStream* irma_fS_iS9_param1;
   IntStream* irma_fS_iS9_param2;
   irma_fS_iSStream* irma_fS_iS9;
   FloatStream* change2Source;
   ChangeStream* change2;
   FloatStream* irma_fS_iS10_param1;
   IntStream* irma_fS_iS10_param2;
   irma_fS_iSStream* irma_fS_iS10;
   bool _initialized;
public:
   irsi_fS_iSStream(IStream* p, IIntStream* l)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
      this.l = l;
      l.AddRef();
      change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change1 = new ChangeStream(change1Source, 1);
      change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change2 = new ChangeStream(change2Source, 1);
   }
   ~irsi_fS_iSStream()
   {
      p.Release();
      l.Release();
      change1Source.Release();
      change1.Release();
      irma_fS_iS9_param1.Release();
      irma_fS_iS9_param2.Release();
      delete irma_fS_iS9;
      change2Source.Release();
      change2.Release();
      irma_fS_iS10_param1.Release();
      irma_fS_iS10_param2.Release();
      delete irma_fS_iS10;
   }
   int Init(int id)
   {
      irma_fS_iS9_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irma_fS_iS9_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irma_fS_iS9 = new irma_fS_iSStream(irma_fS_iS9_param1, irma_fS_iS9_param2);
      id = irma_fS_iS9.Init(id);
      irma_fS_iS10_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irma_fS_iS10_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irma_fS_iS10 = new irma_fS_iSStream(irma_fS_iS10_param1, irma_fS_iS10_param2);
      id = irma_fS_iS10.Init(id);
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
         change1Source.Init();
         irma_fS_iS9_param1.Init();
         irma_fS_iS9_param2.Init();
         irma_fS_iS9.Clear();
         change2Source.Init();
         irma_fS_iS10_param1.Init();
         irma_fS_iS10_param2.Init();
         irma_fS_iS10.Clear();
         _initialized = true;
      }
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      change1Source.SetValue(pos, pValue);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      int lValue;
      if (!l.GetValue(pos, lValue)) { lValue = EMPTY_VALUE; }
      irma_fS_iS9_param1.SetValue(pos, SafeMathMax(change1Value, 0));
      irma_fS_iS9_param2.SetValue(pos, lValue);
      double irma_fS_iS9Value;
      if (!irma_fS_iS9.GetValue(pos, irma_fS_iS9Value)) { irma_fS_iS9Value = EMPTY_VALUE; }
      double up = irma_fS_iS9Value;
      change2Source.SetValue(pos, pValue);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
      irma_fS_iS10_param1.SetValue(pos, (-SafeMathMin(change2Value, 0)));
      irma_fS_iS10_param2.SetValue(pos, lValue);
      double irma_fS_iS10Value;
      if (!irma_fS_iS10.GetValue(pos, irma_fS_iS10Value)) { irma_fS_iS10Value = EMPTY_VALUE; }
      double down = irma_fS_iS10Value;
      double irsi = ((down == 0) ? 100 : ((up == 0) ? 0 : SafeMinus(100, (SafeDivide(100, (SafePlus(1, SafeDivide(up, down))))))));
      __out1 = irsi;
      return true;
   }
};
class idealRSI_fSStream
{
   IStream* p;
   double Period[];
   double smooth[];
   double dDeTrend[];
   double I1[];
   double Q1[];
   double I2[];
   double Q2[];
   double Re[];
   double Im[];
   double SmoothPeriod[];
   FloatStream* irsi_fS_iS11_param1;
   IntStream* irsi_fS_iS11_param2;
   irsi_fS_iSStream* irsi_fS_iS11;
   bool _initialized;
public:
   idealRSI_fSStream(IStream* p)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
   }
   ~idealRSI_fSStream()
   {
      p.Release();
      irsi_fS_iS11_param1.Release();
      irsi_fS_iS11_param2.Release();
      delete irsi_fS_iS11;
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, Period);
      SetIndexBuffer(id++, smooth);
      SetIndexBuffer(id++, dDeTrend);
      SetIndexBuffer(id++, I1);
      SetIndexBuffer(id++, Q1);
      SetIndexBuffer(id++, I2);
      SetIndexBuffer(id++, Q2);
      SetIndexBuffer(id++, Re);
      SetIndexBuffer(id++, Im);
      SetIndexBuffer(id++, SmoothPeriod);
      irsi_fS_iS11_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irsi_fS_iS11_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      irsi_fS_iS11 = new irsi_fS_iSStream(irsi_fS_iS11_param1, irsi_fS_iS11_param2);
      id = irsi_fS_iS11.Init(id);
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
         ArrayInitialize(Period, 0.0);
         ArrayInitialize(smooth, EMPTY_VALUE);
         ArrayInitialize(dDeTrend, EMPTY_VALUE);
         ArrayInitialize(I1, EMPTY_VALUE);
         ArrayInitialize(Q1, EMPTY_VALUE);
         ArrayInitialize(I2, 0.0);
         ArrayInitialize(Q2, 0.0);
         ArrayInitialize(Re, 0.0);
         ArrayInitialize(Im, 0.0);
         ArrayInitialize(SmoothPeriod, 0.0);
         irsi_fS_iS11_param1.Init();
         irsi_fS_iS11_param2.Init();
         irsi_fS_iS11.Clear();
         _initialized = true;
      }
      double C1 = 0.0962;
      double C2 = 0.5769;
      double Df = 0.5;
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double C3 = (SafePlus(SafeMultiply(Nz(Period[pos + 1]), 0.075), 0.54));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 3 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 3 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      smooth[pos] = SafeDivide(((SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)), 2) * 4.0) + (SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1)), 2) * 3.0) + (SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 2) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 2)), 2) * 2.0) + (SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 3) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 3)), 2))), 10.0);
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 4 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 6 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      dDeTrend[pos] = SafeMultiply((SafeMinus(SafePlus(smooth[pos] * C1, SafeMinus(SafeMultiply(Nz(smooth[pos + 2]), C2), SafeMultiply(Nz(smooth[pos + 4]), C2))), SafeMultiply(Nz(smooth[pos + 6]), C1))), C3);
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 4 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 6 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      Q1[pos] = SafeMultiply((SafeMinus(SafePlus(SafeMultiply(dDeTrend[pos], C1), SafeMinus(SafeMultiply(Nz(dDeTrend[pos + 2]), C2), SafeMultiply(Nz(dDeTrend[pos + 4]), C2))), SafeMultiply(Nz(dDeTrend[pos + 6]), C1))), C3);
      if (pos + 3 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      I1[pos] = Nz(dDeTrend[pos + 3]);
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 4 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 6 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double jI = SafeMultiply((SafeMinus(SafePlus(SafeMultiply(I1[pos], C1), SafeMinus(SafeMultiply(Nz(I1[pos + 2]), C2), SafeMultiply(Nz(I1[pos + 4]), C2))), SafeMultiply(Nz(I1[pos + 6]), C1))), C3);
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 4 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 6 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double jQ = SafeMultiply((SafeMinus(SafePlus(SafeMultiply(Q1[pos], C1), SafeMinus(SafeMultiply(Nz(Q1[pos + 2]), C2), SafeMultiply(Nz(Q1[pos + 4]), C2))), SafeMultiply(Nz(Q1[pos + 6]), C1))), C3);
      double I2_ = SafeMinus(I1[pos], jQ);
      double Q2_ = SafePlus(Q1[pos], jI);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      I2[pos] = SafePlus(SafeMultiply(0.2, I2_), SafeMultiply(0.8, Nz(I2[pos + 1])));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      Q2[pos] = SafePlus(SafeMultiply(0.2, Q2_), SafeMultiply(0.8, Nz(Q2[pos + 1])));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double Re_ = SafePlus(SafeMultiply(I2[pos], Nz(I2[pos + 1])), SafeMultiply(Q2[pos], Nz(Q2[pos + 1])));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double Im_ = SafeMinus(SafeMultiply(I2[pos], Nz(Q2[pos + 1])), SafeMultiply(Q2[pos], Nz(I2[pos + 1])));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      Re[pos] = SafePlus(SafeMultiply(0.2, Re_), SafeMultiply(0.8, Nz(Re[pos + 1])));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      Im[pos] = SafePlus(SafeMultiply(0.2, Im_), SafeMultiply(0.8, Nz(Im[pos + 1])));
      double dp_ = ((Re[pos] != 0) && (Im[pos] != 0) ? SafeDivide(6.28318, MathArctan(SafeDivide(Im[pos], Re[pos]))) : 0);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double II = Nz(Period[pos + 1]);
      double dp = SafeMathMax(SafeMathMax(SafeMathMin(SafeMathMin(dp_, SafeMultiply(1.5, II)), 50), SafeMultiply(0.6667, II)), 6);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      Period[pos] = SafePlus(SafeMultiply(dp, 0.2), SafeMultiply(Nz(Period[pos + 1]), 0.8));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SmoothPeriod[pos] = SafePlus(0.33 * Period[pos], SafeMultiply(Nz(SmoothPeriod[pos + 1]), 0.67));
      int rsiLen = MathRound((SmoothPeriod[pos] * Df) - 1);
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      irsi_fS_iS11_param1.SetValue(pos, pValue);
      irsi_fS_iS11_param2.SetValue(pos, rsiLen);
      double irsi_fS_iS11Value;
      if (!irsi_fS_iS11.GetValue(pos, irsi_fS_iS11Value)) { irsi_fS_iS11Value = EMPTY_VALUE; }
      double idealRSI = irsi_fS_iS11Value;
      __out1 = idealRSI;
      return true;
   }
};
FloatStream* idealRSI_fS12_param1;
idealRSI_fSStream* idealRSI_fS12;
FloatStream* idealRSI_fS13_param1;
idealRSI_fSStream* idealRSI_fS13;
class forceIndex_fS_iStream
{
   IStream* p;
   int l;
   bool _initialized;
public:
   forceIndex_fS_iStream(IStream* p, int l)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
      this.l = l;
   }
   ~forceIndex_fS_iStream()
   {
      p.Release();
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
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      double pValue_1;
      if (!p.GetValue(pos + 1, pValue_1)) { pValue_1 = EMPTY_VALUE; }
      double f = (pValue - pValue_1) * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos);
      __out1 = f;
      return true;
   }
};
FloatStream* forceIndex_fS_i14_param1;
forceIndex_fS_iStream* forceIndex_fS_i14;
FloatStream* forceIndex_fS_i15_param1;
forceIndex_fS_iStream* forceIndex_fS_i15;
class TVA_fS_iStream
{
   IStream* p;
   int l;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   FloatStream* rising1Source;
   RisingStream* rising1;
   FloatStream* falling1Source;
   FallingStream* falling1;
   double direction[];
   double tva[];
   bool _initialized;
public:
   TVA_fS_iStream(IStream* p, int l)
   {
      _initialized = false;
      this.p = p;
      p.AddRef();
      this.l = l;
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, l);
      rising1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rising1 = new RisingStream(rising1Source, 3);
      falling1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      falling1 = new FallingStream(falling1Source, 3);
   }
   ~TVA_fS_iStream()
   {
      p.Release();
      ema2Source.Release();
      ema2.Release();
      rising1Source.Release();
      rising1.Release();
      falling1Source.Release();
      falling1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, direction);
      SetIndexBuffer(id++, tva);
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
         ema2Source.Init();
         rising1Source.Init();
         falling1Source.Init();
         ArrayInitialize(direction, 0);
         ArrayInitialize(tva, 0.0);
         _initialized = true;
      }
      double pValue;
      if (!p.GetValue(pos, pValue)) { pValue = EMPTY_VALUE; }
      ema2Source.SetValue(pos, pValue);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      double ma1 = ema2Value;
      rising1Source.SetValue(pos, ma1);
      bool rising1Value;
      if (!rising1.GetValue(pos, rising1Value)) { rising1Value = EMPTY_VALUE; }
      falling1Source.SetValue(pos, ma1);
      bool falling1Value;
      if (!falling1.GetValue(pos, falling1Value)) { falling1Value = EMPTY_VALUE; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      direction[pos] = (uTVAma ? ((rising1Value ? 1 : (falling1Value ? (-1) : Nz(direction[pos + 1])))) : ((((iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) < iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))) ? 1 : ((iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) > iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)) ? (-1) : Nz(direction[pos + 1])))));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      tva[pos] = ((direction[pos] > 0) ? ((SafeGE(Nz(tva[pos + 1]), 0) ? SafePlus(Nz(tva[pos + 1]), iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)) : iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))) : ((direction[pos] < 0) ? ((SafeLE(Nz(tva[pos + 1]), 0) ? SafeMinus(Nz(tva[pos + 1]), iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)) : (-iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)))) : Nz(tva[pos + 1])));
      __out1 = tva[pos];
      return true;
   }
};
FloatStream* TVA_fS_i16_param1;
TVA_fS_iStream* TVA_fS_i16;
FloatStream* TVA_fS_i17_param1;
TVA_fS_iStream* TVA_fS_i17;
class f_top_fractal_fSStream
{
   IStream* _src;
   bool _initialized;
public:
   f_top_fractal_fSStream(IStream* _src)
   {
      _initialized = false;
      this._src = _src;
      _src.AddRef();
   }
   ~f_top_fractal_fSStream()
   {
      _src.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, bool &__out1)
   {
      double _srcValue_4;
      if (!_src.GetValue(pos + 4, _srcValue_4)) { _srcValue_4 = EMPTY_VALUE; }
      double _srcValue_2;
      if (!_src.GetValue(pos + 2, _srcValue_2)) { _srcValue_2 = EMPTY_VALUE; }
      double _srcValue_3;
      if (!_src.GetValue(pos + 3, _srcValue_3)) { _srcValue_3 = EMPTY_VALUE; }
      double _srcValue_1;
      if (!_src.GetValue(pos + 1, _srcValue_1)) { _srcValue_1 = EMPTY_VALUE; }
      double _srcValue_0;
      if (!_src.GetValue(pos + 0, _srcValue_0)) { _srcValue_0 = EMPTY_VALUE; }
      __out1 = (_srcValue_4 < _srcValue_2) && (_srcValue_3 < _srcValue_2) && (_srcValue_2 > _srcValue_1) && (_srcValue_2 > _srcValue_0);
      return true;
   }
};
class f_bot_fractal_fSStream
{
   IStream* _src;
   bool _initialized;
public:
   f_bot_fractal_fSStream(IStream* _src)
   {
      _initialized = false;
      this._src = _src;
      _src.AddRef();
   }
   ~f_bot_fractal_fSStream()
   {
      _src.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, bool &__out1)
   {
      double _srcValue_4;
      if (!_src.GetValue(pos + 4, _srcValue_4)) { _srcValue_4 = EMPTY_VALUE; }
      double _srcValue_2;
      if (!_src.GetValue(pos + 2, _srcValue_2)) { _srcValue_2 = EMPTY_VALUE; }
      double _srcValue_3;
      if (!_src.GetValue(pos + 3, _srcValue_3)) { _srcValue_3 = EMPTY_VALUE; }
      double _srcValue_1;
      if (!_src.GetValue(pos + 1, _srcValue_1)) { _srcValue_1 = EMPTY_VALUE; }
      double _srcValue_0;
      if (!_src.GetValue(pos + 0, _srcValue_0)) { _srcValue_0 = EMPTY_VALUE; }
      __out1 = (_srcValue_4 > _srcValue_2) && (_srcValue_3 > _srcValue_2) && (_srcValue_2 < _srcValue_1) && (_srcValue_2 < _srcValue_0);
      return true;
   }
};
class f_fractalize_fSStream
{
   IStream* _src;
   FloatStream* f_top_fractal_fS18_param1;
   f_top_fractal_fSStream* f_top_fractal_fS18;
   FloatStream* f_bot_fractal_fS19_param1;
   f_bot_fractal_fSStream* f_bot_fractal_fS19;
   bool _initialized;
public:
   f_fractalize_fSStream(IStream* _src)
   {
      _initialized = false;
      this._src = _src;
      _src.AddRef();
   }
   ~f_fractalize_fSStream()
   {
      _src.Release();
      f_top_fractal_fS18_param1.Release();
      delete f_top_fractal_fS18;
      f_bot_fractal_fS19_param1.Release();
      delete f_bot_fractal_fS19;
   }
   int Init(int id)
   {
      f_top_fractal_fS18_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_top_fractal_fS18 = new f_top_fractal_fSStream(f_top_fractal_fS18_param1);
      id = f_top_fractal_fS18.Init(id);
      f_bot_fractal_fS19_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_bot_fractal_fS19 = new f_bot_fractal_fSStream(f_bot_fractal_fS19_param1);
      id = f_bot_fractal_fS19.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int &__out1)
   {
      if (!_initialized)
      {
         f_top_fractal_fS18_param1.Init();
         f_top_fractal_fS18.Clear();
         f_bot_fractal_fS19_param1.Init();
         f_bot_fractal_fS19.Clear();
         _initialized = true;
      }
      double _srcValue;
      if (!_src.GetValue(pos, _srcValue)) { _srcValue = EMPTY_VALUE; }
      f_top_fractal_fS18_param1.SetValue(pos, _srcValue);
      bool f_top_fractal_fS18Value;
      if (!f_top_fractal_fS18.GetValue(pos, f_top_fractal_fS18Value)) { f_top_fractal_fS18Value = EMPTY_VALUE; }
      f_bot_fractal_fS19_param1.SetValue(pos, _srcValue);
      bool f_bot_fractal_fS19Value;
      if (!f_bot_fractal_fS19.GetValue(pos, f_bot_fractal_fS19Value)) { f_bot_fractal_fS19Value = EMPTY_VALUE; }
      __out1 = (f_top_fractal_fS18Value ? 1 : (f_bot_fractal_fS19Value ? (-1) : 0));
      return true;
   }
};
FloatStream* f_fractalize_fS20_param1;
f_fractalize_fSStream* f_fractalize_fS20;
double oscilator_high[];
FloatStream* f_fractalize_fS21_param1;
f_fractalize_fSStream* f_fractalize_fS21;
double oscilator_low[];
ValueWhenSimpleStream* valuewhen1;
double methodReturnedValue1[];
ValueWhenSimpleStream* valuewhen2;
double methodReturnedValue2[];
ValueWhenSimpleStream* valuewhen3;
double methodReturnedValue3[];
ValueWhenSimpleStream* valuewhen4;
double methodReturnedValue4[];
ColoredStream* plot1;
ColoredStream* plot4;
ColoredStream* plot7;
ColoredStream* plot10;
double plot13[];
double plot14[];
double plot15[];
double plot16[];

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

int init()
{
   IndicatorBuffers(62);
   int id = 0;
   method = param1;
   SHOW_LABEL = param2;
   SHOW_CHANNEL = param3;
   uHid = param4;
   uReg = param5;
   uTVAma = param6;
   rsi_smooth = param7;
   param8Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param8);
   macd_src = param8Stream;
   macd_fast = param9;
   macd_slow = param10;
   macd_smooth = param11;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, rsi_smooth);
   rsi2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi2 = new RSIStream(rsi2X, rsi_smooth);
   stoch1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1High = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1Low = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1 = new StochOnStream(stoch1Source, stoch1High, stoch1Low, rsi_smooth);
   stoch2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2High = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2Low = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2 = new StochOnStream(stoch2Source, stoch2High, stoch2Low, rsi_smooth);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, rsi_smooth);
   sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, rsi_smooth);
   cci1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cci1 = new CCIOnStream(cci1Source, rsi_smooth);
   cci2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cci2 = new CCIOnStream(cci2Source, rsi_smooth);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterStream(id, Maroon);
   id = plot1.RegisterStream(id, EMPTY_VALUE);
   id = plot1.RegisterStream(id, Silver);
   plot4 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot4.RegisterStream(id, Green);
   id = plot4.RegisterStream(id, EMPTY_VALUE);
   id = plot4.RegisterStream(id, Silver);
   plot7 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot7.RegisterArrowStream(id, Maroon, 161);
   id = plot7.RegisterArrowStream(id, EMPTY_VALUE, 161);
   id = plot7.RegisterArrowStream(id, Silver, 161);
   plot10 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot10.RegisterArrowStream(id, Green, 161);
   id = plot10.RegisterArrowStream(id, EMPTY_VALUE, 161);
   id = plot10.RegisterArrowStream(id, Silver, 161);
   SetIndexBuffer(id, plot13);
   SetIndexShift(id, (-2));
   SetIndexArrow(id++, 242);
   SetIndexBuffer(id, plot14);
   SetIndexShift(id, (-2));
   SetIndexArrow(id++, 242);
   SetIndexBuffer(id, plot15);
   SetIndexShift(id, (-2));
   SetIndexArrow(id++, 241);
   SetIndexBuffer(id, plot16);
   SetIndexShift(id, (-2));
   SetIndexArrow(id++, 241);
   IndicatorObjPrefix = GenerateIndicatorPrefix("PDDR");
   IndicatorShortName("Price Divergence Detector V3.2 revised by JustUncleL");
   f_macd_fS_i_i_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_macd_fS_i_i_i1 = new f_macd_fS_i_i_iStream(f_macd_fS_i_i_i1_param1, macd_fast, macd_slow, macd_smooth);
   id = f_macd_fS_i_i_i1.Init(id);
   f_macd_fS_i_i_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_macd_fS_i_i_i2 = new f_macd_fS_i_i_iStream(f_macd_fS_i_i_i2_param1, macd_fast, macd_slow, macd_smooth);
   id = f_macd_fS_i_i_i2.Init(id);
   f_accdist_i3 = new f_accdist_iStream(rsi_smooth);
   id = f_accdist_i3.Init(id);
   f_accdist_i4 = new f_accdist_iStream(rsi_smooth);
   id = f_accdist_i4.Init(id);
   f_fisher_fS_i5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_fisher_fS_i5 = new f_fisher_fS_iStream(f_fisher_fS_i5_param1, rsi_smooth);
   id = f_fisher_fS_i5.Init(id);
   f_fisher_fS_i6_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_fisher_fS_i6 = new f_fisher_fS_iStream(f_fisher_fS_i6_param1, rsi_smooth);
   id = f_fisher_fS_i6.Init(id);
   pcBB_fS_i7_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pcBB_fS_i7 = new pcBB_fS_iStream(pcBB_fS_i7_param1, rsi_smooth);
   id = pcBB_fS_i7.Init(id);
   pcBB_fS_i8_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pcBB_fS_i8 = new pcBB_fS_iStream(pcBB_fS_i8_param1, rsi_smooth);
   id = pcBB_fS_i8.Init(id);
   idealRSI_fS12_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   idealRSI_fS12 = new idealRSI_fSStream(idealRSI_fS12_param1);
   id = idealRSI_fS12.Init(id);
   idealRSI_fS13_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   idealRSI_fS13 = new idealRSI_fSStream(idealRSI_fS13_param1);
   id = idealRSI_fS13.Init(id);
   forceIndex_fS_i14_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   forceIndex_fS_i14 = new forceIndex_fS_iStream(forceIndex_fS_i14_param1, rsi_smooth);
   id = forceIndex_fS_i14.Init(id);
   forceIndex_fS_i15_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   forceIndex_fS_i15 = new forceIndex_fS_iStream(forceIndex_fS_i15_param1, rsi_smooth);
   id = forceIndex_fS_i15.Init(id);
   TVA_fS_i16_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   TVA_fS_i16 = new TVA_fS_iStream(TVA_fS_i16_param1, rsi_smooth);
   id = TVA_fS_i16.Init(id);
   TVA_fS_i17_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   TVA_fS_i17 = new TVA_fS_iStream(TVA_fS_i17_param1, rsi_smooth);
   id = TVA_fS_i17.Init(id);
   f_fractalize_fS20_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_fractalize_fS20 = new f_fractalize_fSStream(f_fractalize_fS20_param1);
   id = f_fractalize_fS20.Init(id);
   SetIndexBuffer(id++, oscilator_high);
   f_fractalize_fS21_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_fractalize_fS21 = new f_fractalize_fSStream(f_fractalize_fS21_param1);
   id = f_fractalize_fS21.Init(id);
   SetIndexBuffer(id++, oscilator_low);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, methodReturnedValue1);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen2.RegisterInternalStream(id);
   SetIndexBuffer(id++, methodReturnedValue2);
   valuewhen3 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen3.RegisterInternalStream(id);
   SetIndexBuffer(id++, methodReturnedValue3);
   valuewhen4 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen4.RegisterInternalStream(id);
   SetIndexBuffer(id++, methodReturnedValue4);
   id = plot1.RegisterInternalStream(id);
   id = plot4.RegisterInternalStream(id);
   id = plot7.RegisterInternalStream(id);
   id = plot10.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param8Stream.Release();
   rsi1X.Release();
   rsi1.Release();
   rsi2X.Release();
   rsi2.Release();
   f_macd_fS_i_i_i1_param1.Release();
   delete f_macd_fS_i_i_i1;
   f_macd_fS_i_i_i2_param1.Release();
   delete f_macd_fS_i_i_i2;
   stoch1Source.Release();
   stoch1High.Release();
   stoch1Low.Release();
   stoch1.Release();
   stoch2Source.Release();
   stoch2High.Release();
   stoch2Low.Release();
   stoch2.Release();
   sma3Source.Release();
   sma3.Release();
   sma4Source.Release();
   sma4.Release();
   delete f_accdist_i3;
   delete f_accdist_i4;
   f_fisher_fS_i5_param1.Release();
   delete f_fisher_fS_i5;
   f_fisher_fS_i6_param1.Release();
   delete f_fisher_fS_i6;
   cci1Source.Release();
   cci1.Release();
   cci2Source.Release();
   cci2.Release();
   pcBB_fS_i7_param1.Release();
   delete pcBB_fS_i7;
   pcBB_fS_i8_param1.Release();
   delete pcBB_fS_i8;
   idealRSI_fS12_param1.Release();
   delete idealRSI_fS12;
   idealRSI_fS13_param1.Release();
   delete idealRSI_fS13;
   forceIndex_fS_i14_param1.Release();
   delete forceIndex_fS_i14;
   forceIndex_fS_i15_param1.Release();
   delete forceIndex_fS_i15;
   TVA_fS_i16_param1.Release();
   delete TVA_fS_i16;
   TVA_fS_i17_param1.Release();
   delete TVA_fS_i17;
   f_fractalize_fS20_param1.Release();
   delete f_fractalize_fS20;
   f_fractalize_fS21_param1.Release();
   delete f_fractalize_fS21;
   valuewhen1.Release();
   valuewhen2.Release();
   valuewhen3.Release();
   valuewhen4.Release();
   delete plot1;
   delete plot4;
   delete plot7;
   delete plot10;
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
      rsi1X.Init();
      rsi2X.Init();
      f_macd_fS_i_i_i1_param1.Init();
      f_macd_fS_i_i_i1.Clear();
      f_macd_fS_i_i_i2_param1.Init();
      f_macd_fS_i_i_i2.Clear();
      stoch1Source.Init();
      stoch1High.Init();
      stoch1Low.Init();
      stoch2Source.Init();
      stoch2High.Init();
      stoch2Low.Init();
      sma3Source.Init();
      sma4Source.Init();
      f_accdist_i3.Clear();
      f_accdist_i4.Clear();
      f_fisher_fS_i5_param1.Init();
      f_fisher_fS_i5.Clear();
      f_fisher_fS_i6_param1.Init();
      f_fisher_fS_i6.Clear();
      cci1Source.Init();
      cci2Source.Init();
      pcBB_fS_i7_param1.Init();
      pcBB_fS_i7.Clear();
      pcBB_fS_i8_param1.Init();
      pcBB_fS_i8.Clear();
      idealRSI_fS12_param1.Init();
      idealRSI_fS12.Clear();
      idealRSI_fS13_param1.Init();
      idealRSI_fS13.Clear();
      forceIndex_fS_i14_param1.Init();
      forceIndex_fS_i14.Clear();
      forceIndex_fS_i15_param1.Init();
      forceIndex_fS_i15.Clear();
      TVA_fS_i16_param1.Init();
      TVA_fS_i16.Clear();
      TVA_fS_i17_param1.Init();
      TVA_fS_i17.Clear();
      f_fractalize_fS20_param1.Init();
      f_fractalize_fS20.Clear();
      ArrayInitialize(oscilator_high, EMPTY_VALUE);
      f_fractalize_fS21_param1.Init();
      f_fractalize_fS21.Clear();
      ArrayInitialize(oscilator_low, EMPTY_VALUE);
      ArrayInitialize(methodReturnedValue1, EMPTY_VALUE);
      ArrayInitialize(methodReturnedValue2, EMPTY_VALUE);
      ArrayInitialize(methodReturnedValue3, EMPTY_VALUE);
      ArrayInitialize(methodReturnedValue4, EMPTY_VALUE);
      plot1.Init(EMPTY_VALUE);
      plot4.Init(EMPTY_VALUE);
      plot7.Init(EMPTY_VALUE);
      plot10.Init(EMPTY_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ArrayInitialize(plot14, EMPTY_VALUE);
      ArrayInitialize(plot15, EMPTY_VALUE);
      ArrayInitialize(plot16, EMPTY_VALUE);
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
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double high_src = high[pos];
      double low_src = low[pos];
      if ((method == "RSI"))
      {
         rsi1X.SetValue(pos, high_src);
         double rsi1Value;
         if (!rsi1.GetValue(pos, rsi1Value)) { rsi1Value = EMPTY_VALUE; }
         oscilator_high[pos] = rsi1Value;
         rsi2X.SetValue(pos, low_src);
         double rsi2Value;
         if (!rsi2.GetValue(pos, rsi2Value)) { rsi2Value = EMPTY_VALUE; }
         oscilator_low[pos] = rsi2Value;
      }
      if ((method == "MACD"))
      {
         double macd_srcValue;
         if (!macd_src.GetValue(pos, macd_srcValue)) { macd_srcValue = EMPTY_VALUE; }
         f_macd_fS_i_i_i1_param1.SetValue(pos, macd_srcValue);
         double f_macd_fS_i_i_i1Value;
         if (!f_macd_fS_i_i_i1.GetValue(pos, f_macd_fS_i_i_i1Value)) { f_macd_fS_i_i_i1Value = EMPTY_VALUE; }
         oscilator_high[pos] = f_macd_fS_i_i_i1Value;
         f_macd_fS_i_i_i2_param1.SetValue(pos, macd_srcValue);
         double f_macd_fS_i_i_i2Value;
         if (!f_macd_fS_i_i_i2.GetValue(pos, f_macd_fS_i_i_i2Value)) { f_macd_fS_i_i_i2Value = EMPTY_VALUE; }
         oscilator_low[pos] = f_macd_fS_i_i_i2Value;
      }
      if ((method == "Stochastic"))
      {
         stoch1Source.SetValue(pos, close[pos]);
         stoch1High.SetValue(pos, high[pos]);
         stoch1Low.SetValue(pos, low[pos]);
         double stoch1Value;
         if (!stoch1.GetValue(pos, stoch1Value)) { stoch1Value = EMPTY_VALUE; }
         oscilator_high[pos] = stoch1Value;
         stoch2Source.SetValue(pos, close[pos]);
         stoch2High.SetValue(pos, high[pos]);
         stoch2Low.SetValue(pos, low[pos]);
         double stoch2Value;
         if (!stoch2.GetValue(pos, stoch2Value)) { stoch2Value = EMPTY_VALUE; }
         oscilator_low[pos] = stoch2Value;
      }
      if ((method == "Volume"))
      {
         sma3Source.SetValue(pos, tick_volume[pos]);
         double sma3Value;
         if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
         oscilator_high[pos] = sma3Value;
         sma4Source.SetValue(pos, tick_volume[pos]);
         double sma4Value;
         if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
         oscilator_low[pos] = sma4Value;
      }
      if ((method == "Accumulation/Distribution"))
      {
         double f_accdist_i3Value;
         if (!f_accdist_i3.GetValue(pos, f_accdist_i3Value)) { f_accdist_i3Value = EMPTY_VALUE; }
         oscilator_high[pos] = f_accdist_i3Value;
         double f_accdist_i4Value;
         if (!f_accdist_i4.GetValue(pos, f_accdist_i4Value)) { f_accdist_i4Value = EMPTY_VALUE; }
         oscilator_low[pos] = f_accdist_i4Value;
      }
      if ((method == "Fisher Transform"))
      {
         f_fisher_fS_i5_param1.SetValue(pos, high_src);
         double f_fisher_fS_i5Value;
         if (!f_fisher_fS_i5.GetValue(pos, f_fisher_fS_i5Value)) { f_fisher_fS_i5Value = EMPTY_VALUE; }
         oscilator_high[pos] = f_fisher_fS_i5Value;
         f_fisher_fS_i6_param1.SetValue(pos, low_src);
         double f_fisher_fS_i6Value;
         if (!f_fisher_fS_i6.GetValue(pos, f_fisher_fS_i6Value)) { f_fisher_fS_i6Value = EMPTY_VALUE; }
         oscilator_low[pos] = f_fisher_fS_i6Value;
      }
      if ((method == "CCI"))
      {
         cci1Source.SetValue(pos, high_src);
         double cci1Value;
         if (!cci1.GetValue(pos, cci1Value)) { cci1Value = EMPTY_VALUE; }
         oscilator_high[pos] = cci1Value;
         cci2Source.SetValue(pos, low_src);
         double cci2Value;
         if (!cci2.GetValue(pos, cci2Value)) { cci2Value = EMPTY_VALUE; }
         oscilator_low[pos] = cci2Value;
      }
      if ((method == "BB %B"))
      {
         pcBB_fS_i7_param1.SetValue(pos, high_src);
         double pcBB_fS_i7Value;
         if (!pcBB_fS_i7.GetValue(pos, pcBB_fS_i7Value)) { pcBB_fS_i7Value = EMPTY_VALUE; }
         oscilator_high[pos] = pcBB_fS_i7Value;
         pcBB_fS_i8_param1.SetValue(pos, low_src);
         double pcBB_fS_i8Value;
         if (!pcBB_fS_i8.GetValue(pos, pcBB_fS_i8Value)) { pcBB_fS_i8Value = EMPTY_VALUE; }
         oscilator_low[pos] = pcBB_fS_i8Value;
      }
      if ((method == "Ideal RSI"))
      {
         idealRSI_fS12_param1.SetValue(pos, high_src);
         double idealRSI_fS12Value;
         if (!idealRSI_fS12.GetValue(pos, idealRSI_fS12Value)) { idealRSI_fS12Value = EMPTY_VALUE; }
         oscilator_high[pos] = idealRSI_fS12Value;
         idealRSI_fS13_param1.SetValue(pos, low_src);
         double idealRSI_fS13Value;
         if (!idealRSI_fS13.GetValue(pos, idealRSI_fS13Value)) { idealRSI_fS13Value = EMPTY_VALUE; }
         oscilator_low[pos] = idealRSI_fS13Value;
      }
      if ((method == "Elders Force Index"))
      {
         forceIndex_fS_i14_param1.SetValue(pos, high_src);
         double forceIndex_fS_i14Value;
         if (!forceIndex_fS_i14.GetValue(pos, forceIndex_fS_i14Value)) { forceIndex_fS_i14Value = EMPTY_VALUE; }
         oscilator_high[pos] = forceIndex_fS_i14Value;
         forceIndex_fS_i15_param1.SetValue(pos, low_src);
         double forceIndex_fS_i15Value;
         if (!forceIndex_fS_i15.GetValue(pos, forceIndex_fS_i15Value)) { forceIndex_fS_i15Value = EMPTY_VALUE; }
         oscilator_low[pos] = forceIndex_fS_i15Value;
      }
      if ((method == "Trend Acc Volume"))
      {
         TVA_fS_i16_param1.SetValue(pos, high_src);
         double TVA_fS_i16Value;
         if (!TVA_fS_i16.GetValue(pos, TVA_fS_i16Value)) { TVA_fS_i16Value = EMPTY_VALUE; }
         oscilator_high[pos] = TVA_fS_i16Value;
         TVA_fS_i17_param1.SetValue(pos, low_src);
         double TVA_fS_i17Value;
         if (!TVA_fS_i17.GetValue(pos, TVA_fS_i17Value)) { TVA_fS_i17Value = EMPTY_VALUE; }
         oscilator_low[pos] = TVA_fS_i17Value;
      }
      f_fractalize_fS20_param1.SetValue(pos, oscilator_high[pos]);
      int f_fractalize_fS20Value;
      if (!f_fractalize_fS20.GetValue(pos, f_fractalize_fS20Value)) { f_fractalize_fS20Value = EMPTY_VALUE; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      double fractal_top = (SafeGreater(f_fractalize_fS20Value, 0) ? oscilator_high[pos + 2] : EMPTY_VALUE);
      f_fractalize_fS21_param1.SetValue(pos, oscilator_low[pos]);
      int f_fractalize_fS21Value;
      if (!f_fractalize_fS21.GetValue(pos, f_fractalize_fS21Value)) { f_fractalize_fS21Value = EMPTY_VALUE; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      double fractal_bot = (SafeLess(f_fractalize_fS21Value, 0) ? oscilator_low[pos + 2] : EMPTY_VALUE);
      if (pos + 2 > (rates_total - 1)) { continue; }
      methodReturnedValue1[pos] = valuewhen1.Update(pos, time[pos], fractal_top, oscilator_high[pos + 2]);
      if (pos + 2 > (rates_total - 1)) { continue; }
      double high_prev = methodReturnedValue1[pos + 2];
      if (pos + 2 > (rates_total - 1)) { continue; }
      methodReturnedValue2[pos] = valuewhen2.Update(pos, time[pos], fractal_top, high[pos + 2]);
      if (pos + 2 > (rates_total - 1)) { continue; }
      double high_price = methodReturnedValue2[pos + 2];
      if (pos + 2 > (rates_total - 1)) { continue; }
      methodReturnedValue3[pos] = valuewhen3.Update(pos, time[pos], fractal_bot, oscilator_low[pos + 2]);
      if (pos + 2 > (rates_total - 1)) { continue; }
      double low_prev = methodReturnedValue3[pos + 2];
      if (pos + 2 > (rates_total - 1)) { continue; }
      methodReturnedValue4[pos] = valuewhen4.Update(pos, time[pos], fractal_bot, low[pos + 2]);
      if (pos + 2 > (rates_total - 1)) { continue; }
      double low_price = methodReturnedValue4[pos + 2];
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool regular_bearish_div = NumberToBool(fractal_top) && SafeGreater(high[pos + 2], high_price) && SafeLess(oscilator_high[pos + 2], high_prev);
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool hidden_bearish_div = NumberToBool(fractal_top) && SafeLess(high[pos + 2], high_price) && SafeGreater(oscilator_high[pos + 2], high_prev);
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool regular_bullish_div = NumberToBool(fractal_bot) && SafeLess(low[pos + 2], low_price) && SafeGreater(oscilator_low[pos + 2], low_prev);
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool hidden_bullish_div = NumberToBool(fractal_bot) && SafeGreater(low[pos + 2], low_price) && SafeLess(oscilator_low[pos + 2], low_prev);
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot1.SetByColor((NumberToBool(fractal_top) ? high[pos + 2] : EMPTY_VALUE), pos, (((regular_bearish_div && uReg) || (hidden_bearish_div && uHid)) ? Maroon : (!SHOW_CHANNEL ? EMPTY_VALUE : Silver)));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot4.SetByColor((NumberToBool(fractal_bot) ? low[pos + 2] : EMPTY_VALUE), pos, (((regular_bullish_div && uReg) || (hidden_bullish_div && uHid)) ? Green : (!SHOW_CHANNEL ? EMPTY_VALUE : Silver)));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot7.SetByColor((NumberToBool(fractal_top) ? high[pos + 2] : EMPTY_VALUE), pos, (((regular_bearish_div && uReg) || (hidden_bearish_div && uHid)) ? Maroon : (!SHOW_CHANNEL ? EMPTY_VALUE : Silver)));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot10.SetByColor((NumberToBool(fractal_bot) ? low[pos + 2] : EMPTY_VALUE), pos, (((regular_bullish_div && uReg) || (hidden_bullish_div && uHid)) ? Green : (!SHOW_CHANNEL ? EMPTY_VALUE : Silver)));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot13[pos] = ((!SHOW_LABEL || !uReg) ? EMPTY_VALUE : (regular_bearish_div ? high[pos + 2] : EMPTY_VALUE));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot14[pos] = ((!SHOW_LABEL || !uHid) ? EMPTY_VALUE : (hidden_bearish_div ? high[pos + 2] : EMPTY_VALUE));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot15[pos] = ((!SHOW_LABEL || !uReg) ? EMPTY_VALUE : (regular_bullish_div ? low[pos + 2] : EMPTY_VALUE));
      if (pos + 2 > (rates_total - 1)) { continue; }
      plot16[pos] = ((!SHOW_LABEL || !uHid) ? EMPTY_VALUE : (hidden_bullish_div ? low[pos + 2] : EMPTY_VALUE));
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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