//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74713

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

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_label1 "RSI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0xFF6229
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Middle Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0x867B78
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_label3 "Overbought"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x867B78
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label4 "Oversold"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x867B78
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
#property indicator_label5 "Regular Bullish"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Green
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_label6 "Regular Bullish"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 2
#property indicator_label7 "Regular Bullish Label"
#property indicator_type7 DRAW_ARROW
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Hidden Bullish"
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 2
#property indicator_label9 "Hidden Bullish"
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 2
#property indicator_label10 "Hidden Bullish Label"
#property indicator_type10 DRAW_ARROW
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Regular Bearish"
#property indicator_type11 DRAW_LINE
#property indicator_color11 Red
#property indicator_style11 STYLE_SOLID
#property indicator_width11 2
#property indicator_label12 "Regular Bearish"
#property indicator_type12 DRAW_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 2
#property indicator_label13 "Regular Bearish Label"
#property indicator_type13 DRAW_ARROW
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Hidden Bearish"
#property indicator_type14 DRAW_LINE
#property indicator_style14 STYLE_SOLID
#property indicator_width14 2
#property indicator_label15 "Hidden Bearish"
#property indicator_type15 DRAW_LINE
#property indicator_style15 STYLE_SOLID
#property indicator_width15 2
#property indicator_label16 "Hidden Bearish Label"
#property indicator_type16 DRAW_ARROW
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
// Pivot low stream v1.3



class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   
   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Pivot high stream v1.3


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


class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Pine-script like safe operations
// v.1.2

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
// Custom boolean stream v1.0

#ifndef BoolStream_IMPL
#define BoolStream_IMPL

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

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   bool _stream[];
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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

   void SetValue(const int period, bool value)
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

   bool GetValue(const int period, bool &val)
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
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

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


// Counts number of bars since last condition.
// v1.01

class BarsSinceStreamV2 : public AIntStream
{
   IBoolStream* _condition;
   int _bars[];
public:
   BarsSinceStreamV2(IBoolStream* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStreamV2()
   {
      _condition.Release();
   }

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      if (ArraySize(_bars) < size)
      {
         ArrayResize(_bars, size);
      }
      int index = size - period - 1;
      if (_bars[index] == 0)
      {
         FillHistory(period);
      }
      val = _bars[index];
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex < size; ++periodIndex)
      {
         int index = size - periodIndex - 1;
         bool val;
         if (!_condition.GetValue(periodIndex, val) || !val)
         {
            if (_bars[index] == 0)
            {
               continue;
            }
         }
         else
         {
            _bars[index] = 0;
         }
         for (int ii = index + 1; ii <= size - period - 1; ++ii)
         {
            _bars[ii] = _bars[ii - 1] + 1;
         }
         return;
      }
   }
};
#endif


// Colored stream v4.1

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
   int RegisterStream(int id, color clr, int transparency)
   {
      return RegisterStream(id, clr, "", transparency == 100 ? DRAW_NONE : DRAW_LINE, STYLE_SOLID, 1);
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
//Signaler v2.2
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void Alert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};

input int param1 = 14; // RSI Period
input PriceType param2 = PriceClose; // RSI Source
input int param3 = 5; // Pivot Lookback Right
input int param4 = 5; // Pivot Lookback Left
input int param5 = 60; // Max of Lookback Range
input int param6 = 5; // Min of Lookback Range
input bool param7 = true; // Plot Bullish
input bool param8 = false; // Plot Hidden Bullish
input bool param9 = true; // Plot Bearish
input bool param10 = false; // Plot Hidden Bearish
input int bars_limit = 100000; // Bars limit
int len;
IStream* param2Stream;
IStream* src;
int lbR;
int lbL;
int rangeUpper;
int rangeLower;
bool plotBull;
bool plotHiddenBull;
bool plotBear;
bool plotHiddenBear;
color bearColor;
color bullColor;
FloatStream* rsi1X;
RSIStream* rsi1;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
FloatStream* lowestpivot1Source;
FloatStream* highestpivot1Source;
double osc[];
ValueWhenSimpleStream* valuewhen1;
class _inRange_bSStream
{
   IBoolStream* cond;
   BoolStream* barssince1Condition;
   BarsSinceStreamV2* barssince1;
   bool _initialized;
public:
   _inRange_bSStream(IBoolStream* cond)
   {
      _initialized = false;
      this.cond = cond;
      cond.AddRef();
      barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      barssince1 = new BarsSinceStreamV2(barssince1Condition);
   }
   ~_inRange_bSStream()
   {
      cond.Release();
      barssince1Condition.Release();
      barssince1.Release();
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
      if (!_initialized)
      {
         barssince1Condition.Init();
         _initialized = true;
      }
      bool condValue;
      if (!cond.GetValue(pos, condValue)) { condValue = EMPTY_VALUE; }
      barssince1Condition.SetValue(pos, (condValue == true));
      int barssince1Value;
      if (!barssince1.GetValue(pos, barssince1Value)) { barssince1Value = EMPTY_VALUE; }
      int bars = barssince1Value;
      __out1 = SafeLE(rangeLower, bars) && SafeLE(bars, rangeUpper);
      return true;
   }
};
double plFound[];
BoolStream* _inRange_bS1_param1;
_inRange_bSStream* _inRange_bS1;
ValueWhenSimpleStream* valuewhen2;
ColoredStream* plot5;
double plot7[];
ValueWhenSimpleStream* valuewhen3;
BoolStream* _inRange_bS2_param1;
_inRange_bSStream* _inRange_bS2;
ValueWhenSimpleStream* valuewhen4;
ColoredStream* plot8;
double plot10[];
ValueWhenSimpleStream* valuewhen5;
double phFound[];
BoolStream* _inRange_bS3_param1;
_inRange_bSStream* _inRange_bS3;
ValueWhenSimpleStream* valuewhen6;
ColoredStream* plot11;
double plot13[];
ValueWhenSimpleStream* valuewhen7;
BoolStream* _inRange_bS4_param1;
_inRange_bSStream* _inRange_bS4;
ValueWhenSimpleStream* valuewhen8;
ColoredStream* plot14;
double plot16[];
Signaler* _signaler;

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
   IndicatorBuffers(31);
   int id = 0;
   len = param1;
   param2Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param2);
   src = param2Stream;
   lbR = param3;
   lbL = param4;
   rangeUpper = param5;
   rangeLower = param6;
   plotBull = param7;
   plotHiddenBull = param8;
   plotBear = param9;
   plotHiddenBear = param10;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, len);
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   plot5 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot5.RegisterStream(id, Green, 0);
   id = plot5.RegisterStream(id, White, 100);
   SetIndexBuffer(id, plot7);
   SetIndexShift(id, (-lbR));
   SetIndexArrow(id, 241);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, bullColor);
   plot8 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot8.RegisterStream(id, Green, 0);
   id = plot8.RegisterStream(id, White, 100);
   SetIndexBuffer(id, plot10);
   SetIndexShift(id, (-lbR));
   SetIndexArrow(id, 241);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, bullColor);
   plot11 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot11.RegisterStream(id, Red, 0);
   id = plot11.RegisterStream(id, White, 100);
   SetIndexBuffer(id, plot13);
   SetIndexShift(id, (-lbR));
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, bearColor);
   plot14 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot14.RegisterStream(id, Red, 0);
   id = plot14.RegisterStream(id, White, 100);
   SetIndexBuffer(id, plot16);
   SetIndexShift(id, (-lbR));
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, bearColor);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("RSI Divergence Indicator");
   SetIndexBuffer(id++, osc);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, plFound);
   _inRange_bS1_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS1 = new _inRange_bSStream(_inRange_bS1_param1);
   id = _inRange_bS1.Init(id);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen2.RegisterInternalStream(id);
   id = plot5.RegisterInternalStream(id);
   valuewhen3 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen3.RegisterInternalStream(id);
   _inRange_bS2_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS2 = new _inRange_bSStream(_inRange_bS2_param1);
   id = _inRange_bS2.Init(id);
   valuewhen4 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen4.RegisterInternalStream(id);
   id = plot8.RegisterInternalStream(id);
   valuewhen5 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen5.RegisterInternalStream(id);
   SetIndexBuffer(id++, phFound);
   _inRange_bS3_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS3 = new _inRange_bSStream(_inRange_bS3_param1);
   id = _inRange_bS3.Init(id);
   valuewhen6 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen6.RegisterInternalStream(id);
   id = plot11.RegisterInternalStream(id);
   valuewhen7 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen7.RegisterInternalStream(id);
   _inRange_bS4_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS4 = new _inRange_bSStream(_inRange_bS4_param1);
   id = _inRange_bS4.Init(id);
   valuewhen8 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen8.RegisterInternalStream(id);
   id = plot14.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param2Stream.Release();
   rsi1X.Release();
   rsi1.Release();
   lowestpivot1Source.Release();
   highestpivot1Source.Release();
   valuewhen1.Release();
   _inRange_bS1_param1.Release();
   delete _inRange_bS1;
   valuewhen2.Release();
   delete plot5;
   valuewhen3.Release();
   _inRange_bS2_param1.Release();
   delete _inRange_bS2;
   valuewhen4.Release();
   delete plot8;
   valuewhen5.Release();
   _inRange_bS3_param1.Release();
   delete _inRange_bS3;
   valuewhen6.Release();
   delete plot11;
   valuewhen7.Release();
   _inRange_bS4_param1.Release();
   delete _inRange_bS4;
   valuewhen8.Release();
   delete plot14;
   delete _signaler;
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, 50);
      ArrayInitialize(plot3, 70);
      ArrayInitialize(plot4, 30);
      lowestpivot1Source.Init();
      highestpivot1Source.Init();
      ArrayInitialize(osc, EMPTY_VALUE);
      ArrayInitialize(plFound, EMPTY_VALUE);
      _inRange_bS1_param1.Init();
      _inRange_bS1.Clear();
      plot5.Init(EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      _inRange_bS2_param1.Init();
      _inRange_bS2.Clear();
      plot8.Init(EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(phFound, EMPTY_VALUE);
      _inRange_bS3_param1.Init();
      _inRange_bS3.Clear();
      plot11.Init(EMPTY_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      _inRange_bS4_param1.Init();
      _inRange_bS4.Clear();
      plot14.Init(EMPTY_VALUE);
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
      bearColor = Red;
      bullColor = Green;
      color hiddenBullColor = Green;
      color hiddenBearColor = Red;
      color textColor = White;
      color noneColor = White;
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      rsi1X.SetValue(pos, srcValue);
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value)) { rsi1Value = EMPTY_VALUE; }
      osc[pos] = rsi1Value;
      plot1[pos] = osc[pos];
      double obLevel = plot3[pos];
      double osLevel = plot4[pos];
      lowestpivot1Source.SetValue(pos, osc[pos]);
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, lowestpivot1Source, lbL, lbR)) { lowestpivot1Value = EMPTY_VALUE; }
      plFound[pos] = (((lowestpivot1Value) == EMPTY_VALUE) ? false : true);
      highestpivot1Source.SetValue(pos, osc[pos]);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, highestpivot1Source, lbL, lbR)) { highestpivot1Value = EMPTY_VALUE; }
      phFound[pos] = (((highestpivot1Value) == EMPTY_VALUE) ? false : true);
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      _inRange_bS1_param1.SetValue(pos, plFound[pos + 1]);
      bool _inRange_bS1Value;
      if (!_inRange_bS1.GetValue(pos, _inRange_bS1Value)) { _inRange_bS1Value = EMPTY_VALUE; }
      bool oscHL = SafeGreater(osc[pos + lbR], valuewhen1.Update(pos, time[pos], plFound[pos], osc[pos + lbR])) && _inRange_bS1Value;
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      bool priceLL = SafeLess(low[pos + lbR], valuewhen2.Update(pos, time[pos], plFound[pos], low[pos + lbR]));
      bool bullCondAlert = priceLL && oscHL && plFound[pos];
      bool bullCond = plotBull && bullCondAlert;
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot5.SetByColor((plFound[pos] ? osc[pos + lbR] : EMPTY_VALUE), pos, ((bullCond ? bullColor : noneColor)));
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot7[pos] = (bullCond ? osc[pos + lbR] : EMPTY_VALUE);
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      _inRange_bS2_param1.SetValue(pos, plFound[pos + 1]);
      bool _inRange_bS2Value;
      if (!_inRange_bS2.GetValue(pos, _inRange_bS2Value)) { _inRange_bS2Value = EMPTY_VALUE; }
      bool oscLL = SafeLess(osc[pos + lbR], valuewhen3.Update(pos, time[pos], plFound[pos], osc[pos + lbR])) && _inRange_bS2Value;
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      bool priceHL = SafeGreater(low[pos + lbR], valuewhen4.Update(pos, time[pos], plFound[pos], low[pos + lbR]));
      bool hiddenBullCondAlert = priceHL && oscLL && plFound[pos];
      bool hiddenBullCond = plotHiddenBull && hiddenBullCondAlert;
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot8.SetByColor((plFound[pos] ? osc[pos + lbR] : EMPTY_VALUE), pos, ((hiddenBullCond ? hiddenBullColor : noneColor)));
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot10[pos] = (hiddenBullCond ? osc[pos + lbR] : EMPTY_VALUE);
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      _inRange_bS3_param1.SetValue(pos, phFound[pos + 1]);
      bool _inRange_bS3Value;
      if (!_inRange_bS3.GetValue(pos, _inRange_bS3Value)) { _inRange_bS3Value = EMPTY_VALUE; }
      bool oscLH = SafeLess(osc[pos + lbR], valuewhen5.Update(pos, time[pos], phFound[pos], osc[pos + lbR])) && _inRange_bS3Value;
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      bool priceHH = SafeGreater(high[pos + lbR], valuewhen6.Update(pos, time[pos], phFound[pos], high[pos + lbR]));
      bool bearCondAlert = priceHH && oscLH && phFound[pos];
      bool bearCond = plotBear && bearCondAlert;
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot11.SetByColor((phFound[pos] ? osc[pos + lbR] : EMPTY_VALUE), pos, ((bearCond ? bearColor : noneColor)));
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot13[pos] = (bearCond ? osc[pos + lbR] : EMPTY_VALUE);
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      _inRange_bS4_param1.SetValue(pos, phFound[pos + 1]);
      bool _inRange_bS4Value;
      if (!_inRange_bS4.GetValue(pos, _inRange_bS4Value)) { _inRange_bS4Value = EMPTY_VALUE; }
      bool oscHH = SafeGreater(osc[pos + lbR], valuewhen7.Update(pos, time[pos], phFound[pos], osc[pos + lbR])) && _inRange_bS4Value;
      if (pos + lbR > (rates_total - 1)) { continue; }
      if (pos + lbR > (rates_total - 1)) { continue; }
      bool priceLH = SafeLess(high[pos + lbR], valuewhen8.Update(pos, time[pos], phFound[pos], high[pos + lbR]));
      bool hiddenBearCondAlert = priceLH && oscHH && phFound[pos];
      bool hiddenBearCond = plotHiddenBear && hiddenBearCondAlert;
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot14.SetByColor((phFound[pos] ? osc[pos + lbR] : EMPTY_VALUE), pos, ((hiddenBearCond ? hiddenBearColor : noneColor)));
      if (pos + lbR > (rates_total - 1)) { continue; }
      plot16[pos] = (hiddenBearCond ? osc[pos + lbR] : EMPTY_VALUE);
      if (bullCondAlert) { _signaler.SendNotifications("Regular Bullish Divergence", "Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (hiddenBullCondAlert) { _signaler.SendNotifications("Hidden Bullish Divergence", "Found a new Hidden Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (bearCondAlert) { _signaler.SendNotifications("Regular Bearish Divergence", "Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (hiddenBearCondAlert) { _signaler.SendNotifications("Hidden Bearisn Divergence", "Found a new Hidden Bearisn Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
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