//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74714

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
#property indicator_chart_window
#property indicator_buffers 0

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

// True range stream v2.2

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         if (_handleNa)
         {
            val = CalcFirst(pos);
            return true;
         }
         return false;
      }
      double h = iHigh(_symbol, _timeframe, period);
      double l = iLow(_symbol, _timeframe, period);
      double c1 = iClose(_symbol, _timeframe, period + 1);
      double hl = MathAbs(h - l);
      double hc = MathAbs(h - c1);
      double lc = MathAbs(l - c1);

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
private:
   double CalcFirst(int pos)
   {
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));

      return MathMax(lc, MathMax(hl, hc));
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

// Average true range stream v2.1

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

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
   }
};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Stream base v1.0



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
// Pivot high stream v1.3


// Simple price stream v1.2

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
// Array v1.1
// Array interface v1.0

// int array interface v1.1

class IIntArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual void Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual IIntArray* Slice(int from, int to) = 0;
   virtual IIntArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
};
// Line array interface v1.1
// Line object v1.2

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   color _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window)
   {
      _refs = 1;
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }

   void SetXY1(int x, double y)
   {
      _x1 = x;
      _y1 = y;
   }
   static void SetXY1(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY1(x, y);
   }
   
   void SetXY2(int x, double y)
   {
      _x2 = x;
      _y2 = y;
   }
   static void SetXY2(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY2(x, y);
   }

   void SetX1(int x) { _x1 = x; }
   static void SetX1(Line* line, int x) { if (line == NULL) { return; } line.SetX1(x); }
   void SetX2(int x) { _x2 = x; }
   static void SetX2(Line* line, int x) { if (line == NULL) { return; } line.SetX2(x); }
   void SetY1(double y) { _y1 = y; }
   static void SetY1(Line* line, double y) { if (line == NULL) { return; } line.SetY1(y); }
   void SetY2(double y) { _y2 = y; }
   static void SetY2(Line* line, double y) { if (line == NULL) { return; } line.SetY2(y); }

   int GetX1() { return _x1; }
   static int GetX1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
};

class ILineArray
{
public:
   virtual void Unshift(Line* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Line* value) = 0;
   virtual Line* Pop() = 0;
   virtual Line* Get(int index) = 0;
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
   virtual Line* Shift() = 0;
   virtual Line* Remove(int index) = 0;
};
// float array interface v1.1

class IFloatArray
{
public:
   virtual void Unshift(double value) = 0;
   virtual int Size() = 0;
   virtual void Push(double value) = 0;
   virtual double Pop() = 0;
   virtual double Get(int index) = 0;
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
   virtual double Shift() = 0;
   virtual double Remove(int index) = 0;
};


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.2

// Collection of lines v1.1

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL



class LinesCollection
{
   string _id;
   Line* _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int _max;
public:
   static Line* Get(Line* line, int index)
   {
      if (line == NULL)
      {
         return NULL;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new LinesCollection("");
         }
      }
      else
      {
      
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(line))
      {
         return;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(line);
   }

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped());
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      line.Release();
      return line;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   int Count()
   {
      return ArraySize(_array);
   }

   Line* GetFirst()
   {
      return _array[0];
   }

   Line* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }
   
   int FindIndex(Line* line)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == line)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Line* line)
   {
      int index = FindIndex(line);
      if (index == -1)
      {
         return false;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   
   void Add(Line* line)
   {
      int index = FindIndex(line);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if (line != NULL)
      {
         line.AddRef();
      }
   }

   void RedrawLines()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(LinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LinesCollection* LinesCollection::_collections[];
LinesCollection* LinesCollection::_all;
int LinesCollection::_max = 50;
#endif

class LineArray : public ILineArray
{
   Line* _array[];
   int _defaultSize;
   Line* _defaultValue;
public:
   LineArray(int size, Line* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~LineArray()
   {
      Clear();
   }

   ILineArray* Clear()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            LinesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Line* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(Line* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Line* Pop()
   {
      int size = ArraySize(_array);
      Line* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Line* Shift()
   {
      return Remove(0);
   }

   Line* Get(int index)
   {
      return _array[index];
   }
   
   ILineArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Line* Remove(int index)
   {
      int size = ArraySize(_array);
      Line* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
};
#endif
// Int array v1.2


class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IIntArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Shift()
   {
      return Remove(0);
   }

   int Get(int index)
   {
      return _array[index];
   }
   
   IIntArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
// Float array v1.2


class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IFloatArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(_array);
      double value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   double Get(int index)
   {
      return _array[index];
   }

   double Shift()
   {
      return Remove(0);
   }
   
   IFloatArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   double Remove(int index)
   {
      int size = ArraySize(_array);
      double value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v1.3
// Box array interface v1.0
#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.3

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   color _bgcolor;
   color _borderColor;
   ENUM_TIMEFRAMES _timeframe;
   string _extend;

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window)
   {
      _refs = 1;
      _textColor = White;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static Box* Copy(Box* box) { if (box == NULL) { return NULL; } return box.Copy(); }
   Box* Copy()
   {
      Box* copy = new Box(_left, _top, _right, _bottom, _id, _collectionId, _window);
      copy.SetBgColor(_bgcolor);
      copy.SetBorderColor(_borderColor);
      copy.SetExtend(_extend);
      copy.SetText(_text);
      copy.SetTextHAlign(_textHAlign);
      copy.SetTextVAlign(_textVAlign);
      copy.SetTextSize(_textSize);
      copy.SetTextColor(_textColor);
      return copy;
   }

   static double GetTop(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }
   double GetTop() { return _top; }
   static double GetBottom(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }
   double GetBottom() { return _bottom; }
   static int GetLeft(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetRight(); }
   int GetRight() { return _right; }

   static void SetTop(Box* box, double value) { if (box == NULL) { return; } box.SetTop(value); }
   void SetTop(double value) { _top = value; }
   static void SetBottom(Box* box, double value) { if (box == NULL) { return; } box.SetBottom(value); }
   void SetBottom(double value) { _bottom = value; }
   static void SetLeft(Box* box, int value) { if (box == NULL) { return; } box.SetLeft(value); }
   void SetLeft(int value) { _left = value; }
   static void SetRight(Box* box, int value) { if (box == NULL) { return; } box.SetRight(value); }
   void SetRight(int value) { _right = value; }

   static void SetBgColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

   static void SetText(Box* box, string text) { if (box == NULL) { return; } box.SetText(text); }
   Box* SetText(string text) { _text = text; return &this; }
   static void SetTextHAlign(Box* box, string halign) { if (box == NULL) { return; } box.SetTextHAlign(halign); }
   Box* SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void SetTextVAlign(Box* box, string valign) { if (box == NULL) { return; } box.SetTextVAlign(valign); }
   Box* SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void SetTextSize(Box* box, string size) { if (box == NULL) { return; } box.SetTextSize(size); }
   Box* SetTextSize(string size) { _textSize = size; return &this; }
   static void SetTextColor(Box* box, color clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(color clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int pos1 = 0;
      if (_extend == "left" || _extend == "both")
      {
         pos1 = iBars(_Symbol, _timeframe) - 1;
      }
      else
      {
         pos1 = iBars(_Symbol, _timeframe) - _left - 1;
      }
      datetime left = iTime(_Symbol, _timeframe, MathMax(0, pos1));
      int pos2 = 0;
      if (_extend == "right" || _extend == "both")
      {
         pos2 = 0;
      }
      else
      {
         pos2 = iBars(_Symbol, _timeframe) - _right - 1;
      }
      datetime right = iTime(_Symbol, _timeframe, MathMax(0, pos2));
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _bgcolor);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, right);
   }
};

#endif

class IBoxArray
{
public:
   virtual void Unshift(Box* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Box* value) = 0;
   virtual Box* Pop() = 0;
   virtual Box* Get(int index) = 0;
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
   virtual Box* Shift() = 0;
   virtual Box* Remove(int index) = 0;
};
// Collection of boxes v1.1

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL



class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   string GetId()
   {
      return _id;
   }

   int Count()
   {
      return ArraySize(_array);
   }

   Box* GetFirst()
   {
      return _array[0];
   }

   Box* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }

   static Box* Get(Box* box, int index)
   {
      if (box == NULL)
      {
         return NULL;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new BoxesCollection("");
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Box* box)
   {
      if (box == NULL)
      {
         return;
      }
      if (!_all.RemoveItem(box))
      {
         return;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - left - 1);
      string boxId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Box* box = new Box(left, top, right, bottom, boxId, id, WindowOnDropped());
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      return box;
   }
   
   static void SetMaxBoxes(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawBoxs();
      }
   }
private:
   int FindIndex(Box* box)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == box)
         {
            return i;
         }
      }
      return -1;
   }

   bool RemoveItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return false;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   void DeleteItem(Box* box)
   {
      if (RemoveItem(box))
      {
         box.Release();
      }
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
   }

   void RedrawBoxs()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(BoxesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static BoxesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
BoxesCollection* BoxesCollection::_collections[];
BoxesCollection* BoxesCollection::_all;
int BoxesCollection::_max = 50;
#endif

class BoxArray : public IBoxArray
{
   Box* _array[];
   int _defaultSize;
   Box* _defaultValue;
public:
   BoxArray(int size, Box* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~BoxArray()
   {
      Clear();
   }

   IBoxArray* Clear()
   {
      int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            BoxesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Box* Pop()
   {
      int size = ArraySize(_array);
      Box* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Box* Shift()
   {
      return Remove(0);
   }

   Box* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   IBoxArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Box* Remove(int index)
   {
      int size = ArraySize(_array);
      Box* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
};
#endif

class Array
{
public:
   static void Unshift(IIntArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IFloatArray* array, double value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IBoxArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }

   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static Box* Pop(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static Box* Get(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Line* Remove(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }

   static int Max(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static double Max(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static int Min(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   static double Min(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }

   static int Sum(IIntArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      int sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(IFloatArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      double sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
};


// Float array stream v1.0

#ifndef FloatArrayStream_IMPL
#define FloatArrayStream_IMPL

// Abstract implementation for IFloatArrayStream v1.0

#ifndef AFloatArrayStream_IMPL
#define AFloatArrayStream_IMPL

// Float array stream v1.0


interface IFloatArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, IFloatArray* &val) = 0;
};

class AFloatArrayStream : public IFloatArrayStream
{
   int _refs;   
public:
   AFloatArrayStream()
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


class FloatArrayStream : public AFloatArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IFloatArray* _stream[];
public:
   FloatArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, IFloatArray* value)
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

   bool GetValue(const int period, IFloatArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
// Integer array stream v1.0

#ifndef IntArrayStream_IMPL
#define IntArrayStream_IMPL

// Abstract implementation for IIntArrayStream v1.0

#ifndef IIntArrayStream_IMPL
#define IIntArrayStream_IMPL

// Float array stream v1.0


interface IIntArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, IIntArray* &val) = 0;
};

class AIntArrayStream : public IIntArrayStream
{
   int _refs;   
public:
   AIntArrayStream()
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


class IntArrayStream : public AIntArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IIntArray* _stream[];
public:
   IntArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, IIntArray* value)
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

   bool GetValue(const int period, IIntArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL
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
// Collection of labels v1.1

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.2

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
public:
   Label(int x, double y, string labelId, string collectionId, int window)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   string GetId()
   {
      return _labelId;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   int GetX()
   {
      return _x;
   }
   static int GetX(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetX();
   }

   double GetY()
   {
      return _y;
   }
   static double GetY(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetY();
   }
   void SetX(int x)
   {
      _x = x;
   }
   static void SetX(Label* label, int x)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetX(x);
   }
   void SetY(double y)
   {
      _y = y;
   }
   static void SetY(Label* label, double y)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetY(y);
   }

   Label* SetSize(string size)
   {
      _size = size;
      return &this;
   }
   static void SetSize(Label* label, string size)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetSize(size);
   }

   Label* SetYLoc(string yloc)
   {
      _yloc = yloc;
      return &this;
   }
   static void SetYLoc(Label* label, string yloc)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetYLoc(yloc);
   }
   
   Label* SetColor(color clr)
   {
      _color = clr;
      return &this;
   }
   
   Label* SetTextColor(color clr)
   {
      _textColor = clr;
      return &this;
   }
   
   static void SetStyle(Label* label, string style)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetStyle(style);
   }
   Label* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetText(Label* label, string text)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetText(text);
   }
   Label* SetText(string text)
   {
      _text = text;
      StringReplace(_text, "\n", " ");
      if (_text == "")
      {
         _font = "Wingdings";
      }
      else
      {
         _font = "Arial";
      }
      return &this;
   }

   void Redraw()
   {
      string usedText = _text;
      if (usedText == "")
      {
         if (_style == "up")
         {
            usedText = "\217";
         }
         else if (_style == "down")
         {
            usedText = "\218";
         }
      }
      ResetLastError();
      int pos = iBars(_Symbol, _timeframe) - _x - 1;
      datetime x = iTime(_Symbol, _timeframe, pos);
      double y = getY(pos);
      
      if (ObjectFind(0, _labelId) == -1 
         && ObjectCreate(0, _labelId, OBJ_TEXT, _window, x, y))
      {
         ObjectSetString(0, _labelId, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
   int GetAnchor()
   {
      if (_yloc == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_yloc == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   int getFontSize()
   {
      if (_size == "tiny")
      {
         return 8;
      }
      if (_size == "small")
      {
         return 10;
      }
      if (_size == "large")
      {
         return 14;
      }
      if (_size == "huge")
      {
         return 16;
      }
      return 12;
   }
   double getY(int pos)
   {
      if (_yloc == "abovebar")
      {
         return iHigh(_Symbol, _timeframe, pos);
      }
      if (_yloc == "belowbar")
      {
         return iLow(_Symbol, _timeframe, pos);
      }
      return _y;
   }
};
#endif

class LabelsCollection
{
   string _id;
   Label* _labels[];
   static LabelsCollection* _collections[];
   static LabelsCollection* _all;
   static int _maxLabels;
public:
   LabelsCollection(string id)
   {
      _id = id;
   }
   
   ~LabelsCollection()
   {
      ClearLabels();
   }
   
   void ClearLabels()
   {
      for (int i = 0; i < ArraySize(_labels); ++i)
      {
         delete _labels[i];
      }
      ArrayResize(_labels, 0);
   }
   
   string GetId()
   {
      return _id;
   }
   
   int Count()
   {
      return ArraySize(_labels);
   }
   
   Label* GetFirst()
   {
      return _labels[0];
   }
   
   Label* GetByIndex(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[size - 1 - index];
   }

   static Label* Get(Label* label, int index)
   {
      if (label == NULL)
      {
         return NULL;
      }
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }
   
   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new LabelsCollection("");
      }
      else
      {
         _all.ClearLabels();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Label* label)
   {
      if (label == NULL)
      {
         return;
      }
      _all.RemoveLabel(label);
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLabel(label);
   }

   static Label* Create(string id, int x, double y, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, WindowOnDropped());
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      if (_all.Count() > _maxLabels)
      {
         Delete(_all.GetFirst());
      }
      return label;
   }

   static void SetMaxLabels(int max)
   {
      _maxLabels = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   int FindIndex(Label* label)
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         if (_labels[i] == label)
         {
            return i;
         }
      }
      return -1;
   }
   void RemoveLabel(Label* label)
   {
      int index = FindIndex(label);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_labels);
      for (int i = index + 1; i < size; ++i)
      {
         _labels[i - 1] = _labels[i];
      }
      ArrayResize(_labels, size - 1);
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      delete label;
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
   }

   void RedrawLabels()
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         _labels[i].Redraw();
      }
   }

   static void AddCollection(LabelsCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LabelsCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LabelsCollection* LabelsCollection::_collections[];
LabelsCollection* LabelsCollection::_all;
int LabelsCollection::_maxLabels = 50;
#endif
// Box array stream v1.0

#ifndef BoxArrayStream_IMPL
#define BoxArrayStream_IMPL

// Abstract implementation for IBoxArrayStream v1.0

#ifndef ABoxArrayStream_IMPL
#define ABoxArrayStream_IMPL

// Box array stream v1.0


interface IBoxArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, IBoxArray* &val) = 0;
};

class ABoxArrayStream : public IBoxArrayStream
{
   int _refs;   
public:
   ABoxArrayStream()
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


class BoxArrayStream : public ABoxArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IBoxArray* _stream[];
public:
   BoxArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, IBoxArray* value)
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

   bool GetValue(const int period, IBoxArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
// Box stream v1.0

#ifndef BoxStream_IMPL
#define BoxStream_IMPL

// Abstract implementation for IBoxStream v1.0

#ifndef ABoxStream_IMPL
#define ABoxStream_IMPL

// Box array stream v1.0


interface IBoxStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, Box* &val) = 0;
};

class ABoxStream : public IBoxStream
{
   int _refs;   
public:
   ABoxStream()
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


class BoxStream : public ABoxStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   Box* _stream[];
public:
   BoxStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, Box* value)
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

   bool GetValue(const int period, Box* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif





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

input int param1 = 10; // Swing High/Low Length
input int param2 = 20; // History To Keep
input double param3 = 2.5; // Supply/Demand Box Width
input bool param4 = false; // Show Zig Zag
input bool param5 = false; // Show Price Action Labels
input color param6 = 0xEDEDED; // Supply
input color param7 = White; // Outline
input color param8 = 0xFFFF00; // Demand
input color param9 = White; // Outline
input color param10 = White; // BOS Label
input color param11 = White; // POI Label
input color param12 = Black; // Price Action Label
input color param13 = 0x000000; // Zig Zag
input int bars_limit = 100000; // Bars limit
int swing_length;
int history_of_demand_to_keep;
double box_width;
bool show_zigzag;
bool show_price_action_labels;
color supply_color;
color supply_outline_color;
color demand_color;
color demand_outline_color;
color bos_label_color;
color poi_label_color;
color swing_type_color;
color zigzag_color;
ATRStream* atr1;
FloatStream* highestpivot1Source;
FloatStream* lowestpivot1Source;
IFloatArray* swing_high_values;
IFloatArray* __array1;
IFloatArray* swing_low_values;
IFloatArray* __array2;
IIntArray* swing_high_bns;
IIntArray* __array3;
IIntArray* swing_low_bns;
IIntArray* __array4;
IBoxArray* current_supply_box;
IBoxArray* __array5;
IBoxArray* current_demand_box;
IBoxArray* __array6;
IBoxArray* current_supply_poi;
IBoxArray* __array7;
IBoxArray* current_demand_poi;
IBoxArray* __array8;
IBoxArray* supply_bos;
IBoxArray* __array9;
IBoxArray* demand_bos;
IBoxArray* __array10;
class f_array_add_pop_faS_fSStream
{
   IFloatArrayStream* array;
   IStream* new_value_to_add;
   bool _initialized;
public:
   f_array_add_pop_faS_fSStream(IFloatArrayStream* array, IStream* new_value_to_add)
   {
      _initialized = false;
      this.array = array;
      array.AddRef();
      this.new_value_to_add = new_value_to_add;
      new_value_to_add.AddRef();
   }
   ~f_array_add_pop_faS_fSStream()
   {
      array.Release();
      new_value_to_add.Release();
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
      IFloatArray* arrayValue;
      if (!array.GetValue(pos, arrayValue)) { arrayValue = NULL; }
      double new_value_to_addValue;
      if (!new_value_to_add.GetValue(pos, new_value_to_addValue)) { new_value_to_addValue = EMPTY_VALUE; }
      Array::Unshift(arrayValue, new_value_to_addValue);
      __out1 = Array::Pop(arrayValue);
      return true;
   }
};
FloatArrayStream* f_array_add_pop_faS_fS1_param1;
FloatStream* f_array_add_pop_faS_fS1_param2;
f_array_add_pop_faS_fSStream* f_array_add_pop_faS_fS1;
class f_array_add_pop_iaS_iSStream
{
   IIntArrayStream* array;
   IIntStream* new_value_to_add;
   bool _initialized;
public:
   f_array_add_pop_iaS_iSStream(IIntArrayStream* array, IIntStream* new_value_to_add)
   {
      _initialized = false;
      this.array = array;
      array.AddRef();
      this.new_value_to_add = new_value_to_add;
      new_value_to_add.AddRef();
   }
   ~f_array_add_pop_iaS_iSStream()
   {
      array.Release();
      new_value_to_add.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int &__out1)
   {
      IIntArray* arrayValue;
      if (!array.GetValue(pos, arrayValue)) { arrayValue = NULL; }
      int new_value_to_addValue;
      if (!new_value_to_add.GetValue(pos, new_value_to_addValue)) { new_value_to_addValue = EMPTY_VALUE; }
      Array::Unshift(arrayValue, new_value_to_addValue);
      __out1 = Array::Pop(arrayValue);
      return true;
   }
};
IntArrayStream* f_array_add_pop_iaS_iS2_param1;
IntStream* f_array_add_pop_iaS_iS2_param2;
f_array_add_pop_iaS_iSStream* f_array_add_pop_iaS_iS2;
class f_sh_sl_labels_faS_iStream
{
   IFloatArrayStream* array;
   int swing_type;
   bool _initialized;
public:
   f_sh_sl_labels_faS_iStream(IFloatArrayStream* array, int swing_type)
   {
      _initialized = false;
      this.array = array;
      array.AddRef();
      this.swing_type = swing_type;
   }
   ~f_sh_sl_labels_faS_iStream()
   {
      array.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Label* &__out1)
   {
      string label_text = NULL;
      if ((swing_type == 1))
      {
         IFloatArray* arrayValue;
         if (!array.GetValue(pos, arrayValue)) { arrayValue = NULL; }
         if (SafeGE(Array::Get(arrayValue, 0), Array::Get(arrayValue, 1)))
         {
            label_text = "HH";
         }
         else
         {
            label_text = "LH";
         }
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) - swing_length, Array::Get(arrayValue, 0), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(swing_type_color).SetText(label_text).SetTextColor(swing_type_color).SetStyle("down").SetSize("tiny").SetYLoc("price");
      }
      else if ((swing_type == (-1)))
      {
         IFloatArray* arrayValue;
         if (!array.GetValue(pos, arrayValue)) { arrayValue = NULL; }
         if (SafeGE(Array::Get(arrayValue, 0), Array::Get(arrayValue, 1)))
         {
            label_text = "HL";
         }
         else
         {
            label_text = "LL";
         }
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) - swing_length, Array::Get(arrayValue, 0), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(swing_type_color).SetText(label_text).SetTextColor(swing_type_color).SetStyle("up").SetSize("tiny").SetYLoc("price");
      }
      return true;
   }
};
FloatArrayStream* f_sh_sl_labels_faS_i3_param1;
f_sh_sl_labels_faS_iStream* f_sh_sl_labels_faS_i3;
class f_check_overlapping_fS_bxaS_fSStream
{
   IStream* new_poi;
   IBoxArrayStream* box_array;
   IStream* atr;
   bool _initialized;
public:
   f_check_overlapping_fS_bxaS_fSStream(IStream* new_poi, IBoxArrayStream* box_array, IStream* atr)
   {
      _initialized = false;
      this.new_poi = new_poi;
      new_poi.AddRef();
      this.box_array = box_array;
      box_array.AddRef();
      this.atr = atr;
      atr.AddRef();
   }
   ~f_check_overlapping_fS_bxaS_fSStream()
   {
      new_poi.Release();
      box_array.Release();
      atr.Release();
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
      double atrValue;
      if (!atr.GetValue(pos, atrValue)) { atrValue = EMPTY_VALUE; }
      double atr_threshold = SafeMultiply(atrValue, 2);
      bool okay_to_draw = true;
      IBoxArray* box_arrayValue;
      if (!box_array.GetValue(pos, box_arrayValue)) { box_arrayValue = NULL; }
      int for1_from = 0;
      int for1_to = SafeMinus(Array::Size(box_arrayValue), 1);
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         double top = Box::GetTop(Array::Get(box_arrayValue, i));
         Print(top);
         double bottom = Box::GetBottom(Array::Get(box_arrayValue, i));
         double poi = SafeDivide((SafePlus(top, bottom)), 2);
         double upper_boundary = SafePlus(poi, atr_threshold);
         double lower_boundary = SafeMinus(poi, atr_threshold);
         double new_poiValue;
         if (!new_poi.GetValue(pos, new_poiValue)) { new_poiValue = EMPTY_VALUE; }
         if (SafeGE(new_poiValue, lower_boundary) && SafeLE(new_poiValue, upper_boundary))
         {
            okay_to_draw = false;
            break;
         }
         else
         {
            okay_to_draw = true;
         }
      }
      __out1 = okay_to_draw;
      return true;
   }
};
class f_array_add_pop_bxaS_bxSStream
{
   IBoxArrayStream* array;
   IBoxStream* new_value_to_add;
   bool _initialized;
public:
   f_array_add_pop_bxaS_bxSStream(IBoxArrayStream* array, IBoxStream* new_value_to_add)
   {
      _initialized = false;
      this.array = array;
      array.AddRef();
      this.new_value_to_add = new_value_to_add;
      new_value_to_add.AddRef();
   }
   ~f_array_add_pop_bxaS_bxSStream()
   {
      array.Release();
      new_value_to_add.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Box* &__out1)
   {
      IBoxArray* arrayValue;
      if (!array.GetValue(pos, arrayValue)) { arrayValue = NULL; }
      Box* new_value_to_addValue;
      if (!new_value_to_add.GetValue(pos, new_value_to_addValue)) { new_value_to_addValue = NULL; }
      Array::Unshift(arrayValue, new_value_to_addValue);
      __out1 = Array::Pop(arrayValue);
      return true;
   }
};
class f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream
{
   IFloatArrayStream* value_array;
   IIntArrayStream* bn_array;
   IBoxArrayStream* box_array;
   IBoxArrayStream* label_array;
   int box_type;
   IStream* atr;
   double box_top[];
   double box_bottom[];
   double poi[];
   FloatStream* f_check_overlapping_fS_bxaS_fS4_param1;
   BoxArrayStream* f_check_overlapping_fS_bxaS_fS4_param2;
   FloatStream* f_check_overlapping_fS_bxaS_fS4_param3;
   f_check_overlapping_fS_bxaS_fSStream* f_check_overlapping_fS_bxaS_fS4;
   BoxArrayStream* f_array_add_pop_bxaS_bxS5_param1;
   BoxStream* f_array_add_pop_bxaS_bxS5_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS5;
   BoxArrayStream* f_array_add_pop_bxaS_bxS6_param1;
   BoxStream* f_array_add_pop_bxaS_bxS6_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS6;
   BoxArrayStream* f_array_add_pop_bxaS_bxS7_param1;
   BoxStream* f_array_add_pop_bxaS_bxS7_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS7;
   BoxArrayStream* f_array_add_pop_bxaS_bxS8_param1;
   BoxStream* f_array_add_pop_bxaS_bxS8_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS8;
   bool _initialized;
public:
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream(IFloatArrayStream* value_array, IIntArrayStream* bn_array, IBoxArrayStream* box_array, IBoxArrayStream* label_array, int box_type, IStream* atr)
   {
      _initialized = false;
      this.value_array = value_array;
      value_array.AddRef();
      this.bn_array = bn_array;
      bn_array.AddRef();
      this.box_array = box_array;
      box_array.AddRef();
      this.label_array = label_array;
      label_array.AddRef();
      this.box_type = box_type;
      this.atr = atr;
      atr.AddRef();
   }
   ~f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream()
   {
      value_array.Release();
      bn_array.Release();
      box_array.Release();
      label_array.Release();
      atr.Release();
      f_check_overlapping_fS_bxaS_fS4_param1.Release();
      f_check_overlapping_fS_bxaS_fS4_param2.Release();
      f_check_overlapping_fS_bxaS_fS4_param3.Release();
      delete f_check_overlapping_fS_bxaS_fS4;
      f_array_add_pop_bxaS_bxS5_param1.Release();
      f_array_add_pop_bxaS_bxS5_param2.Release();
      delete f_array_add_pop_bxaS_bxS5;
      f_array_add_pop_bxaS_bxS6_param1.Release();
      f_array_add_pop_bxaS_bxS6_param2.Release();
      delete f_array_add_pop_bxaS_bxS6;
      f_array_add_pop_bxaS_bxS7_param1.Release();
      f_array_add_pop_bxaS_bxS7_param2.Release();
      delete f_array_add_pop_bxaS_bxS7;
      f_array_add_pop_bxaS_bxS8_param1.Release();
      f_array_add_pop_bxaS_bxS8_param2.Release();
      delete f_array_add_pop_bxaS_bxS8;
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, box_top);
      SetIndexBuffer(id++, box_bottom);
      SetIndexBuffer(id++, poi);
      f_check_overlapping_fS_bxaS_fS4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_check_overlapping_fS_bxaS_fS4_param2 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_check_overlapping_fS_bxaS_fS4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_check_overlapping_fS_bxaS_fS4 = new f_check_overlapping_fS_bxaS_fSStream(f_check_overlapping_fS_bxaS_fS4_param1, f_check_overlapping_fS_bxaS_fS4_param2, f_check_overlapping_fS_bxaS_fS4_param3);
      id = f_check_overlapping_fS_bxaS_fS4.Init(id);
      f_array_add_pop_bxaS_bxS5_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS5_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS5 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS5_param1, f_array_add_pop_bxaS_bxS5_param2);
      id = f_array_add_pop_bxaS_bxS5.Init(id);
      f_array_add_pop_bxaS_bxS6_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS6_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS6 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS6_param1, f_array_add_pop_bxaS_bxS6_param2);
      id = f_array_add_pop_bxaS_bxS6.Init(id);
      f_array_add_pop_bxaS_bxS7_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS7_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS7 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS7_param1, f_array_add_pop_bxaS_bxS7_param2);
      id = f_array_add_pop_bxaS_bxS7.Init(id);
      f_array_add_pop_bxaS_bxS8_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS8_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS8 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS8_param1, f_array_add_pop_bxaS_bxS8_param2);
      id = f_array_add_pop_bxaS_bxS8.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Box* &__out1)
   {
      if (!_initialized)
      {
         ArrayInitialize(box_top, 0.00);
         ArrayInitialize(box_bottom, 0.00);
         ArrayInitialize(poi, 0.00);
         f_check_overlapping_fS_bxaS_fS4_param1.Init();
         f_check_overlapping_fS_bxaS_fS4_param2.Init();
         f_check_overlapping_fS_bxaS_fS4_param3.Init();
         f_check_overlapping_fS_bxaS_fS4.Clear();
         f_array_add_pop_bxaS_bxS5_param1.Init();
         f_array_add_pop_bxaS_bxS5_param2.Init();
         f_array_add_pop_bxaS_bxS5.Clear();
         f_array_add_pop_bxaS_bxS6_param1.Init();
         f_array_add_pop_bxaS_bxS6_param2.Init();
         f_array_add_pop_bxaS_bxS6.Clear();
         f_array_add_pop_bxaS_bxS7_param1.Init();
         f_array_add_pop_bxaS_bxS7_param2.Init();
         f_array_add_pop_bxaS_bxS7.Clear();
         f_array_add_pop_bxaS_bxS8_param1.Init();
         f_array_add_pop_bxaS_bxS8_param2.Init();
         f_array_add_pop_bxaS_bxS8.Clear();
         _initialized = true;
      }
      box_top[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? box_top[pos + 1] : 0.00;
      box_bottom[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? box_bottom[pos + 1] : 0.00;
      poi[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? poi[pos + 1] : 0.00;
      double atrValue;
      if (!atr.GetValue(pos, atrValue)) { atrValue = EMPTY_VALUE; }
      double atr_buffer = SafeMultiply(atrValue, (SafeDivide(box_width, 10)));
      IIntArray* bn_arrayValue;
      if (!bn_array.GetValue(pos, bn_arrayValue)) { bn_arrayValue = NULL; }
      int box_left = Array::Get(bn_arrayValue, 0);
      int box_right = ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos);
      if ((box_type == 1))
      {
         IFloatArray* value_arrayValue;
         if (!value_array.GetValue(pos, value_arrayValue)) { value_arrayValue = NULL; }
         box_top[pos] = Array::Get(value_arrayValue, 0);
         box_bottom[pos] = SafeMinus(box_top[pos], atr_buffer);
         poi[pos] = SafeDivide((box_top[pos] + box_bottom[pos]), 2);
      }
      else if ((box_type == (-1)))
      {
         IFloatArray* value_arrayValue;
         if (!value_array.GetValue(pos, value_arrayValue)) { value_arrayValue = NULL; }
         box_bottom[pos] = Array::Get(value_arrayValue, 0);
         box_top[pos] = SafePlus(box_bottom[pos], atr_buffer);
         poi[pos] = SafeDivide((box_top[pos] + box_bottom[pos]), 2);
      }
      IBoxArray* box_arrayValue;
      if (!box_array.GetValue(pos, box_arrayValue)) { box_arrayValue = NULL; }
      f_check_overlapping_fS_bxaS_fS4_param1.SetValue(pos, poi[pos]);
      f_check_overlapping_fS_bxaS_fS4_param2.SetValue(pos, box_arrayValue);
      f_check_overlapping_fS_bxaS_fS4_param3.SetValue(pos, atrValue);
      bool f_check_overlapping_fS_bxaS_fS4Value;
      if (!f_check_overlapping_fS_bxaS_fS4.GetValue(pos, f_check_overlapping_fS_bxaS_fS4Value)) { f_check_overlapping_fS_bxaS_fS4Value = EMPTY_VALUE; }
      bool okay_to_draw = f_check_overlapping_fS_bxaS_fS4Value;
      if ((box_type == 1) && okay_to_draw)
      {
         BoxesCollection::Delete(Array::Get(box_arrayValue, SafeMinus(Array::Size(box_arrayValue), 1)));
         f_array_add_pop_bxaS_bxS5_param1.SetValue(pos, box_arrayValue);
         f_array_add_pop_bxaS_bxS5_param2.SetValue(pos, BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", box_left, box_top[pos], box_right, box_bottom[pos], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))
            .SetBgColor(supply_color)
            .SetBorderColor(supply_outline_color)
            .SetExtend("right")
            .SetText("SUPPLY")
            .SetTextColor(poi_label_color)
            .SetTextHAlign("center")
            .SetTextVAlign("center")
            .SetTextSize("small"));
         Box* f_array_add_pop_bxaS_bxS5Value;
         if (!f_array_add_pop_bxaS_bxS5.GetValue(pos, f_array_add_pop_bxaS_bxS5Value)) { f_array_add_pop_bxaS_bxS5Value = NULL; }
         f_array_add_pop_bxaS_bxS5Value;
         IBoxArray* label_arrayValue;
         if (!label_array.GetValue(pos, label_arrayValue)) { label_arrayValue = NULL; }
         BoxesCollection::Delete(Array::Get(label_arrayValue, SafeMinus(Array::Size(label_arrayValue), 1)));
         f_array_add_pop_bxaS_bxS6_param1.SetValue(pos, label_arrayValue);
         f_array_add_pop_bxaS_bxS6_param2.SetValue(pos, BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", box_left, poi[pos], box_right, poi[pos], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))
            .SetBgColor(poi_label_color)
            .SetBorderColor(poi_label_color)
            .SetExtend("right")
            .SetText("POI")
            .SetTextColor(poi_label_color)
            .SetTextHAlign("left")
            .SetTextVAlign("center")
            .SetTextSize("small"));
         Box* f_array_add_pop_bxaS_bxS6Value;
         if (!f_array_add_pop_bxaS_bxS6.GetValue(pos, f_array_add_pop_bxaS_bxS6Value)) { f_array_add_pop_bxaS_bxS6Value = NULL; }
         __out1 = f_array_add_pop_bxaS_bxS6Value;
      }
      else if ((box_type == (-1)) && okay_to_draw)
      {
         BoxesCollection::Delete(Array::Get(box_arrayValue, SafeMinus(Array::Size(box_arrayValue), 1)));
         f_array_add_pop_bxaS_bxS7_param1.SetValue(pos, box_arrayValue);
         f_array_add_pop_bxaS_bxS7_param2.SetValue(pos, BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", box_left, box_top[pos], box_right, box_bottom[pos], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))
            .SetBgColor(demand_color)
            .SetBorderColor(demand_outline_color)
            .SetExtend("right")
            .SetText("DEMAND")
            .SetTextColor(poi_label_color)
            .SetTextHAlign("center")
            .SetTextVAlign("center")
            .SetTextSize("small"));
         Box* f_array_add_pop_bxaS_bxS7Value;
         if (!f_array_add_pop_bxaS_bxS7.GetValue(pos, f_array_add_pop_bxaS_bxS7Value)) { f_array_add_pop_bxaS_bxS7Value = NULL; }
         f_array_add_pop_bxaS_bxS7Value;
         IBoxArray* label_arrayValue;
         if (!label_array.GetValue(pos, label_arrayValue)) { label_arrayValue = NULL; }
         BoxesCollection::Delete(Array::Get(label_arrayValue, SafeMinus(Array::Size(label_arrayValue), 1)));
         f_array_add_pop_bxaS_bxS8_param1.SetValue(pos, label_arrayValue);
         f_array_add_pop_bxaS_bxS8_param2.SetValue(pos, BoxesCollection::Create(IndicatorObjPrefix + "box_4_id", box_left, poi[pos], box_right, poi[pos], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))
            .SetBgColor(poi_label_color)
            .SetBorderColor(poi_label_color)
            .SetExtend("right")
            .SetText("POI")
            .SetTextColor(poi_label_color)
            .SetTextHAlign("left")
            .SetTextVAlign("center")
            .SetTextSize("small"));
         Box* f_array_add_pop_bxaS_bxS8Value;
         if (!f_array_add_pop_bxaS_bxS8.GetValue(pos, f_array_add_pop_bxaS_bxS8Value)) { f_array_add_pop_bxaS_bxS8Value = NULL; }
         __out1 = f_array_add_pop_bxaS_bxS8Value;
      }
      return true;
   }
};
FloatArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1;
IntArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2;
BoxArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3;
BoxArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4;
FloatStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6;
f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9;
FloatArrayStream* f_array_add_pop_faS_fS10_param1;
FloatStream* f_array_add_pop_faS_fS10_param2;
f_array_add_pop_faS_fSStream* f_array_add_pop_faS_fS10;
IntArrayStream* f_array_add_pop_iaS_iS11_param1;
IntStream* f_array_add_pop_iaS_iS11_param2;
f_array_add_pop_iaS_iSStream* f_array_add_pop_iaS_iS11;
FloatArrayStream* f_sh_sl_labels_faS_i12_param1;
f_sh_sl_labels_faS_iStream* f_sh_sl_labels_faS_i12;
FloatArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1;
IntArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2;
BoxArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3;
BoxArrayStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4;
FloatStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6;
f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13;
class f_sd_to_bos_bxaS_bxaS_bxaS_iStream
{
   IBoxArrayStream* box_array;
   IBoxArrayStream* bos_array;
   IBoxArrayStream* label_array;
   int zone_type;
   BoxArrayStream* f_array_add_pop_bxaS_bxS14_param1;
   BoxStream* f_array_add_pop_bxaS_bxS14_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS14;
   BoxArrayStream* f_array_add_pop_bxaS_bxS15_param1;
   BoxStream* f_array_add_pop_bxaS_bxS15_param2;
   f_array_add_pop_bxaS_bxSStream* f_array_add_pop_bxaS_bxS15;
   bool _initialized;
public:
   f_sd_to_bos_bxaS_bxaS_bxaS_iStream(IBoxArrayStream* box_array, IBoxArrayStream* bos_array, IBoxArrayStream* label_array, int zone_type)
   {
      _initialized = false;
      this.box_array = box_array;
      box_array.AddRef();
      this.bos_array = bos_array;
      bos_array.AddRef();
      this.label_array = label_array;
      label_array.AddRef();
      this.zone_type = zone_type;
   }
   ~f_sd_to_bos_bxaS_bxaS_bxaS_iStream()
   {
      box_array.Release();
      bos_array.Release();
      label_array.Release();
      f_array_add_pop_bxaS_bxS14_param1.Release();
      f_array_add_pop_bxaS_bxS14_param2.Release();
      delete f_array_add_pop_bxaS_bxS14;
      f_array_add_pop_bxaS_bxS15_param1.Release();
      f_array_add_pop_bxaS_bxS15_param2.Release();
      delete f_array_add_pop_bxaS_bxS15;
   }
   int Init(int id)
   {
      f_array_add_pop_bxaS_bxS14_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS14_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS14 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS14_param1, f_array_add_pop_bxaS_bxS14_param2);
      id = f_array_add_pop_bxaS_bxS14.Init(id);
      f_array_add_pop_bxaS_bxS15_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS15_param2 = new BoxStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      f_array_add_pop_bxaS_bxS15 = new f_array_add_pop_bxaS_bxSStream(f_array_add_pop_bxaS_bxS15_param1, f_array_add_pop_bxaS_bxS15_param2);
      id = f_array_add_pop_bxaS_bxS15.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos)
   {
      if (!_initialized)
      {
         f_array_add_pop_bxaS_bxS14_param1.Init();
         f_array_add_pop_bxaS_bxS14_param2.Init();
         f_array_add_pop_bxaS_bxS14.Clear();
         f_array_add_pop_bxaS_bxS15_param1.Init();
         f_array_add_pop_bxaS_bxS15_param2.Init();
         f_array_add_pop_bxaS_bxS15.Clear();
         _initialized = true;
      }
      if ((zone_type == 1))
      {
         IBoxArray* box_arrayValue;
         if (!box_array.GetValue(pos, box_arrayValue)) { box_arrayValue = NULL; }
         int for2_from = 0;
         int for2_to = SafeMinus(Array::Size(box_arrayValue), 1);
         bool for2_forward = for2_from <= for2_to;
         int for2_step = 1 * (for2_forward ? 1 : -1);
         if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { return false; }
         for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
         {
            double level_to_break = Box::GetTop(Array::Get(box_arrayValue, i));
            if (SafeGE(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), level_to_break))
            {
               Box* copied_box = Box::Copy(Array::Get(box_arrayValue, i));
               IBoxArray* bos_arrayValue;
               if (!bos_array.GetValue(pos, bos_arrayValue)) { bos_arrayValue = NULL; }
               f_array_add_pop_bxaS_bxS14_param1.SetValue(pos, bos_arrayValue);
               f_array_add_pop_bxaS_bxS14_param2.SetValue(pos, copied_box);
               Box* f_array_add_pop_bxaS_bxS14Value;
               if (!f_array_add_pop_bxaS_bxS14.GetValue(pos, f_array_add_pop_bxaS_bxS14Value)) { f_array_add_pop_bxaS_bxS14Value = NULL; }
               f_array_add_pop_bxaS_bxS14Value;
               double mid = SafeDivide((SafePlus(Box::GetTop(Array::Get(box_arrayValue, i)), Box::GetBottom(Array::Get(box_arrayValue, i)))), 2);
               Box::SetTop(Array::Get(bos_arrayValue, 0), mid);
               Box::SetBottom(Array::Get(bos_arrayValue, 0), mid);
               Box::SetExtend(Array::Get(bos_arrayValue, 0), "none");
               Box::SetRight(Array::Get(bos_arrayValue, 0), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos));
               Box::SetText(Array::Get(bos_arrayValue, 0), "BOS");
               Box::SetTextColor(Array::Get(bos_arrayValue, 0), bos_label_color);
               Box::SetTextSize(Array::Get(bos_arrayValue, 0), "small");
               Box::SetTextHAlign(Array::Get(bos_arrayValue, 0), "center");
               Box::SetTextVAlign(Array::Get(bos_arrayValue, 0), "center");
               BoxesCollection::Delete(Array::Get(box_arrayValue, i));
               IBoxArray* label_arrayValue;
               if (!label_array.GetValue(pos, label_arrayValue)) { label_arrayValue = NULL; }
               BoxesCollection::Delete(Array::Get(label_arrayValue, i));
            }
         }
      }
      if ((zone_type == (-1)))
      {
         IBoxArray* box_arrayValue;
         if (!box_array.GetValue(pos, box_arrayValue)) { box_arrayValue = NULL; }
         int for3_from = 0;
         int for3_to = SafeMinus(Array::Size(box_arrayValue), 1);
         bool for3_forward = for3_from <= for3_to;
         int for3_step = 1 * (for3_forward ? 1 : -1);
         if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { return false; }
         for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
         {
            double level_to_break = Box::GetBottom(Array::Get(box_arrayValue, i));
            if (SafeLE(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), level_to_break))
            {
               Box* copied_box = Box::Copy(Array::Get(box_arrayValue, i));
               IBoxArray* bos_arrayValue;
               if (!bos_array.GetValue(pos, bos_arrayValue)) { bos_arrayValue = NULL; }
               f_array_add_pop_bxaS_bxS15_param1.SetValue(pos, bos_arrayValue);
               f_array_add_pop_bxaS_bxS15_param2.SetValue(pos, copied_box);
               Box* f_array_add_pop_bxaS_bxS15Value;
               if (!f_array_add_pop_bxaS_bxS15.GetValue(pos, f_array_add_pop_bxaS_bxS15Value)) { f_array_add_pop_bxaS_bxS15Value = NULL; }
               f_array_add_pop_bxaS_bxS15Value;
               double mid = SafeDivide((SafePlus(Box::GetTop(Array::Get(box_arrayValue, i)), Box::GetBottom(Array::Get(box_arrayValue, i)))), 2);
               Box::SetTop(Array::Get(bos_arrayValue, 0), mid);
               Box::SetBottom(Array::Get(bos_arrayValue, 0), mid);
               Box::SetExtend(Array::Get(bos_arrayValue, 0), "none");
               Box::SetRight(Array::Get(bos_arrayValue, 0), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos));
               Box::SetText(Array::Get(bos_arrayValue, 0), "BOS");
               Box::SetTextColor(Array::Get(bos_arrayValue, 0), bos_label_color);
               Box::SetTextSize(Array::Get(bos_arrayValue, 0), "small");
               Box::SetTextHAlign(Array::Get(bos_arrayValue, 0), "center");
               Box::SetTextVAlign(Array::Get(bos_arrayValue, 0), "center");
               BoxesCollection::Delete(Array::Get(box_arrayValue, i));
               IBoxArray* label_arrayValue;
               if (!label_array.GetValue(pos, label_arrayValue)) { label_arrayValue = NULL; }
               BoxesCollection::Delete(Array::Get(label_arrayValue, i));
            }
         }
      }
      return true;
   }
};
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1;
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2;
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3;
f_sd_to_bos_bxaS_bxaS_bxaS_iStream* f_sd_to_bos_bxaS_bxaS_bxaS_i16;
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1;
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2;
BoxArrayStream* f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3;
f_sd_to_bos_bxaS_bxaS_bxaS_iStream* f_sd_to_bos_bxaS_bxaS_bxaS_i17;
class f_extend_box_endpoint_bxaSStream
{
   IBoxArrayStream* box_array;
   bool _initialized;
public:
   f_extend_box_endpoint_bxaSStream(IBoxArrayStream* box_array)
   {
      _initialized = false;
      this.box_array = box_array;
      box_array.AddRef();
   }
   ~f_extend_box_endpoint_bxaSStream()
   {
      box_array.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos)
   {
      IBoxArray* box_arrayValue;
      if (!box_array.GetValue(pos, box_arrayValue)) { box_arrayValue = NULL; }
      int for4_from = 0;
      int for4_to = SafeMinus(Array::Size(box_arrayValue), 1);
      bool for4_forward = for4_from <= for4_to;
      int for4_step = 1 * (for4_forward ? 1 : -1);
      if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { return false; }
      for (int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
      {
         Box::SetRight(Array::Get(box_arrayValue, i), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) + 100);
      }
      return true;
   }
};
BoxArrayStream* f_extend_box_endpoint_bxaS18_param1;
f_extend_box_endpoint_bxaSStream* f_extend_box_endpoint_bxaS18;
BoxArrayStream* f_extend_box_endpoint_bxaS19_param1;
f_extend_box_endpoint_bxaSStream* f_extend_box_endpoint_bxaS19;
double h;
FloatStream* highest1Source;
double l;
FloatStream* lowest1Source;
double dirUp[];
double lastLow;
double lastHigh[];
double timeLow[];
double timeHigh[];
Line* li;
class f_isMin_iStream
{
   int len;
   bool _initialized;
public:
   f_isMin_iStream(int len)
   {
      _initialized = false;
      this.len = len;
   }
   ~f_isMin_iStream()
   {
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
      if (pos + len > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = (l == iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + len));
      return true;
   }
};
f_isMin_iStream* f_isMin_i20;
class f_drawLineStream
{
   bool _initialized;
public:
   f_drawLineStream()
   {
      _initialized = false;
   }
   ~f_drawLineStream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Line* &__out1)
   {
      color _li_color = (show_zigzag ? zigzag_color : 0xffffff);
      __out1 = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", timeHigh[pos] - swing_length, lastHigh[pos], timeLow[pos] - swing_length, lastLow, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(_li_color).SetWidth(2).SetStyle("solid");
      return true;
   }
};
f_drawLineStream* f_drawLine21;
class f_isMax_iStream
{
   int len;
   bool _initialized;
public:
   f_isMax_iStream(int len)
   {
      _initialized = false;
      this.len = len;
   }
   ~f_isMax_iStream()
   {
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
      if (pos + len > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = (h == iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + len));
      return true;
   }
};
f_isMax_iStream* f_isMax_i22;
f_drawLineStream* f_drawLine23;
f_isMax_iStream* f_isMax_i24;
f_drawLineStream* f_drawLine25;
f_isMin_iStream* f_isMin_i26;
f_drawLineStream* f_drawLine27;
f_isMax_iStream* f_isMax_i28;
f_drawLineStream* f_drawLine29;

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
   IndicatorBuffers(10);
   int id = 0;
   swing_length = param1;
   history_of_demand_to_keep = param2;
   box_width = param3;
   show_zigzag = param4;
   show_price_action_labels = param5;
   supply_color = param6;
   supply_outline_color = param7;
   demand_color = param8;
   demand_outline_color = param9;
   bos_label_color = param10;
   poi_label_color = param11;
   swing_type_color = param12;
   zigzag_color = param13;
   atr1 = new ATRStream(50);
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   LabelsCollection::SetMaxLabels(500);
   BoxesCollection::SetMaxBoxes(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("FluidTrades - SMC Lite ");
   __array1 = new FloatArray(5, 0.00);
   __array2 = new FloatArray(5, 0.00);
   __array3 = new IntArray(5, 0);
   __array4 = new IntArray(5, 0);
   __array5 = new BoxArray(history_of_demand_to_keep, NULL);
   __array6 = new BoxArray(history_of_demand_to_keep, NULL);
   __array7 = new BoxArray(history_of_demand_to_keep, NULL);
   __array8 = new BoxArray(history_of_demand_to_keep, NULL);
   __array9 = new BoxArray(5, NULL);
   __array10 = new BoxArray(5, NULL);
   f_array_add_pop_faS_fS1_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_faS_fS1_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_faS_fS1 = new f_array_add_pop_faS_fSStream(f_array_add_pop_faS_fS1_param1, f_array_add_pop_faS_fS1_param2);
   id = f_array_add_pop_faS_fS1.Init(id);
   f_array_add_pop_iaS_iS2_param1 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_iaS_iS2_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_iaS_iS2 = new f_array_add_pop_iaS_iSStream(f_array_add_pop_iaS_iS2_param1, f_array_add_pop_iaS_iS2_param2);
   id = f_array_add_pop_iaS_iS2.Init(id);
   f_sh_sl_labels_faS_i3_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sh_sl_labels_faS_i3 = new f_sh_sl_labels_faS_iStream(f_sh_sl_labels_faS_i3_param1, 1);
   id = f_sh_sl_labels_faS_i3.Init(id);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9 = new f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream(f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4, 1, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6);
   id = f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9.Init(id);
   f_array_add_pop_faS_fS10_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_faS_fS10_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_faS_fS10 = new f_array_add_pop_faS_fSStream(f_array_add_pop_faS_fS10_param1, f_array_add_pop_faS_fS10_param2);
   id = f_array_add_pop_faS_fS10.Init(id);
   f_array_add_pop_iaS_iS11_param1 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_iaS_iS11_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_array_add_pop_iaS_iS11 = new f_array_add_pop_iaS_iSStream(f_array_add_pop_iaS_iS11_param1, f_array_add_pop_iaS_iS11_param2);
   id = f_array_add_pop_iaS_iS11.Init(id);
   f_sh_sl_labels_faS_i12_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sh_sl_labels_faS_i12 = new f_sh_sl_labels_faS_iStream(f_sh_sl_labels_faS_i12_param1, (-1));
   id = f_sh_sl_labels_faS_i12.Init(id);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13 = new f_supply_demand_faS_iaS_bxaS_bxaS_i_fSStream(f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4, (-1), f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6);
   id = f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13.Init(id);
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i16 = new f_sd_to_bos_bxaS_bxaS_bxaS_iStream(f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1, f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2, f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3, 1);
   id = f_sd_to_bos_bxaS_bxaS_bxaS_i16.Init(id);
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_sd_to_bos_bxaS_bxaS_bxaS_i17 = new f_sd_to_bos_bxaS_bxaS_bxaS_iStream(f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1, f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2, f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3, (-1));
   id = f_sd_to_bos_bxaS_bxaS_bxaS_i17.Init(id);
   f_extend_box_endpoint_bxaS18_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_extend_box_endpoint_bxaS18 = new f_extend_box_endpoint_bxaSStream(f_extend_box_endpoint_bxaS18_param1);
   id = f_extend_box_endpoint_bxaS18.Init(id);
   f_extend_box_endpoint_bxaS19_param1 = new BoxArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_extend_box_endpoint_bxaS19 = new f_extend_box_endpoint_bxaSStream(f_extend_box_endpoint_bxaS19_param1);
   id = f_extend_box_endpoint_bxaS19.Init(id);
   SetIndexBuffer(id++, dirUp);
   SetIndexBuffer(id++, lastHigh);
   SetIndexBuffer(id++, timeLow);
   SetIndexBuffer(id++, timeHigh);
   f_isMin_i20 = new f_isMin_iStream(swing_length);
   id = f_isMin_i20.Init(id);
   f_drawLine21 = new f_drawLineStream();
   id = f_drawLine21.Init(id);
   f_isMax_i22 = new f_isMax_iStream(swing_length);
   id = f_isMax_i22.Init(id);
   f_drawLine23 = new f_drawLineStream();
   id = f_drawLine23.Init(id);
   f_isMax_i24 = new f_isMax_iStream(swing_length);
   id = f_isMax_i24.Init(id);
   f_drawLine25 = new f_drawLineStream();
   id = f_drawLine25.Init(id);
   f_isMin_i26 = new f_isMin_iStream(swing_length);
   id = f_isMin_i26.Init(id);
   f_drawLine27 = new f_drawLineStream();
   id = f_drawLine27.Init(id);
   f_isMax_i28 = new f_isMax_iStream(swing_length);
   id = f_isMax_i28.Init(id);
   f_drawLine29 = new f_drawLineStream();
   id = f_drawLine29.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   atr1.Release();
   highestpivot1Source.Release();
   lowestpivot1Source.Release();
   delete __array1;
   delete __array2;
   delete __array3;
   delete __array4;
   delete __array5;
   delete __array6;
   delete __array7;
   delete __array8;
   delete __array9;
   delete __array10;
   f_array_add_pop_faS_fS1_param1.Release();
   f_array_add_pop_faS_fS1_param2.Release();
   delete f_array_add_pop_faS_fS1;
   f_array_add_pop_iaS_iS2_param1.Release();
   f_array_add_pop_iaS_iS2_param2.Release();
   delete f_array_add_pop_iaS_iS2;
   f_sh_sl_labels_faS_i3_param1.Release();
   delete f_sh_sl_labels_faS_i3;
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6.Release();
   delete f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9;
   f_array_add_pop_faS_fS10_param1.Release();
   f_array_add_pop_faS_fS10_param2.Release();
   delete f_array_add_pop_faS_fS10;
   f_array_add_pop_iaS_iS11_param1.Release();
   f_array_add_pop_iaS_iS11_param2.Release();
   delete f_array_add_pop_iaS_iS11;
   f_sh_sl_labels_faS_i12_param1.Release();
   delete f_sh_sl_labels_faS_i12;
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4.Release();
   f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6.Release();
   delete f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13;
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1.Release();
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2.Release();
   f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3.Release();
   delete f_sd_to_bos_bxaS_bxaS_bxaS_i16;
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1.Release();
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2.Release();
   f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3.Release();
   delete f_sd_to_bos_bxaS_bxaS_bxaS_i17;
   f_extend_box_endpoint_bxaS18_param1.Release();
   delete f_extend_box_endpoint_bxaS18;
   f_extend_box_endpoint_bxaS19_param1.Release();
   delete f_extend_box_endpoint_bxaS19;
   highest1Source.Release();
   lowest1Source.Release();
   delete f_isMin_i20;
   delete f_drawLine21;
   delete f_isMax_i22;
   delete f_drawLine23;
   delete f_isMax_i24;
   delete f_drawLine25;
   delete f_isMin_i26;
   delete f_drawLine27;
   delete f_isMax_i28;
   delete f_drawLine29;
   LabelsCollection::Clear(true);
   BoxesCollection::Clear(true);
   LinesCollection::Clear(true);
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
      LabelsCollection::Clear();
      BoxesCollection::Clear();
      LinesCollection::Clear();
      highestpivot1Source.Init();
      lowestpivot1Source.Init();
      swing_high_values = __array1.Clear();
      swing_low_values = __array2.Clear();
      swing_high_bns = __array3.Clear();
      swing_low_bns = __array4.Clear();
      current_supply_box = __array5.Clear();
      current_demand_box = __array6.Clear();
      current_supply_poi = __array7.Clear();
      current_demand_poi = __array8.Clear();
      supply_bos = __array9.Clear();
      demand_bos = __array10.Clear();
      f_array_add_pop_faS_fS1_param1.Init();
      f_array_add_pop_faS_fS1_param2.Init();
      f_array_add_pop_faS_fS1.Clear();
      f_array_add_pop_iaS_iS2_param1.Init();
      f_array_add_pop_iaS_iS2_param2.Init();
      f_array_add_pop_iaS_iS2.Clear();
      f_sh_sl_labels_faS_i3_param1.Init();
      f_sh_sl_labels_faS_i3.Clear();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9.Clear();
      f_array_add_pop_faS_fS10_param1.Init();
      f_array_add_pop_faS_fS10_param2.Init();
      f_array_add_pop_faS_fS10.Clear();
      f_array_add_pop_iaS_iS11_param1.Init();
      f_array_add_pop_iaS_iS11_param2.Init();
      f_array_add_pop_iaS_iS11.Clear();
      f_sh_sl_labels_faS_i12_param1.Init();
      f_sh_sl_labels_faS_i12.Clear();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6.Init();
      f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13.Clear();
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i16.Clear();
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3.Init();
      f_sd_to_bos_bxaS_bxaS_bxaS_i17.Clear();
      f_extend_box_endpoint_bxaS18_param1.Init();
      f_extend_box_endpoint_bxaS18.Clear();
      f_extend_box_endpoint_bxaS19_param1.Init();
      f_extend_box_endpoint_bxaS19.Clear();
      highest1Source.Init();
      lowest1Source.Init();
      ArrayInitialize(dirUp, false);
      ArrayInitialize(lastHigh, 0.0);
      ArrayInitialize(timeLow, (rates_total - 1));
      ArrayInitialize(timeHigh, (rates_total - 1));
      li = NULL;
      f_isMin_i20.Clear();
      f_drawLine21.Clear();
      f_isMax_i22.Clear();
      f_drawLine23.Clear();
      f_isMax_i24.Clear();
      f_drawLine25.Clear();
      f_isMin_i26.Clear();
      f_drawLine27.Clear();
      f_isMax_i28.Clear();
      f_drawLine29.Clear();
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
      dirUp[pos] = pos < (rates_total - 1) ? dirUp[pos + 1] : false;
      lastHigh[pos] = pos < (rates_total - 1) ? lastHigh[pos + 1] : 0.0;
      timeLow[pos] = pos < (rates_total - 1) ? timeLow[pos + 1] : ((rates_total - 1) - pos);
      timeHigh[pos] = pos < (rates_total - 1) ? timeHigh[pos + 1] : ((rates_total - 1) - pos);
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value)) { atr1Value = EMPTY_VALUE; }
      double atr = atr1Value;
      highestpivot1Source.SetValue(pos, high[pos]);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, highestpivot1Source, swing_length, swing_length)) { highestpivot1Value = EMPTY_VALUE; }
      double swing_high = highestpivot1Value;
      lowestpivot1Source.SetValue(pos, low[pos]);
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, lowestpivot1Source, swing_length, swing_length)) { lowestpivot1Value = EMPTY_VALUE; }
      double swing_low = lowestpivot1Value;
      if (!((swing_high) == EMPTY_VALUE))
      {
         f_array_add_pop_faS_fS1_param1.SetValue(pos, swing_high_values);
         f_array_add_pop_faS_fS1_param2.SetValue(pos, swing_high);
         double f_array_add_pop_faS_fS1Value;
         if (!f_array_add_pop_faS_fS1.GetValue(pos, f_array_add_pop_faS_fS1Value)) { f_array_add_pop_faS_fS1Value = EMPTY_VALUE; }
         f_array_add_pop_faS_fS1Value;
         f_array_add_pop_iaS_iS2_param1.SetValue(pos, swing_high_bns);
         f_array_add_pop_iaS_iS2_param2.SetValue(pos, ((rates_total - 1) - pos));
         int f_array_add_pop_iaS_iS2Value;
         if (!f_array_add_pop_iaS_iS2.GetValue(pos, f_array_add_pop_iaS_iS2Value)) { f_array_add_pop_iaS_iS2Value = EMPTY_VALUE; }
         f_array_add_pop_iaS_iS2Value;
         if (show_price_action_labels)
         {
            f_sh_sl_labels_faS_i3_param1.SetValue(pos, swing_high_values);
            Label* f_sh_sl_labels_faS_i3Value;
            if (!f_sh_sl_labels_faS_i3.GetValue(pos, f_sh_sl_labels_faS_i3Value)) { f_sh_sl_labels_faS_i3Value = NULL; }
            f_sh_sl_labels_faS_i3Value;
         }
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param1.SetValue(pos, swing_high_values);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param2.SetValue(pos, swing_high_bns);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param3.SetValue(pos, current_supply_box);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param4.SetValue(pos, current_supply_poi);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9_param6.SetValue(pos, atr);
         Box* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9Value;
         if (!f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9.GetValue(pos, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9Value)) { f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9Value = NULL; }
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS9Value;
      }
      else if (!((swing_low) == EMPTY_VALUE))
      {
         f_array_add_pop_faS_fS10_param1.SetValue(pos, swing_low_values);
         f_array_add_pop_faS_fS10_param2.SetValue(pos, swing_low);
         double f_array_add_pop_faS_fS10Value;
         if (!f_array_add_pop_faS_fS10.GetValue(pos, f_array_add_pop_faS_fS10Value)) { f_array_add_pop_faS_fS10Value = EMPTY_VALUE; }
         f_array_add_pop_faS_fS10Value;
         f_array_add_pop_iaS_iS11_param1.SetValue(pos, swing_low_bns);
         f_array_add_pop_iaS_iS11_param2.SetValue(pos, ((rates_total - 1) - pos));
         int f_array_add_pop_iaS_iS11Value;
         if (!f_array_add_pop_iaS_iS11.GetValue(pos, f_array_add_pop_iaS_iS11Value)) { f_array_add_pop_iaS_iS11Value = EMPTY_VALUE; }
         f_array_add_pop_iaS_iS11Value;
         if (show_price_action_labels)
         {
            f_sh_sl_labels_faS_i12_param1.SetValue(pos, swing_low_values);
            Label* f_sh_sl_labels_faS_i12Value;
            if (!f_sh_sl_labels_faS_i12.GetValue(pos, f_sh_sl_labels_faS_i12Value)) { f_sh_sl_labels_faS_i12Value = NULL; }
            f_sh_sl_labels_faS_i12Value;
         }
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param1.SetValue(pos, swing_low_values);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param2.SetValue(pos, swing_low_bns);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param3.SetValue(pos, current_demand_box);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param4.SetValue(pos, current_demand_poi);
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13_param6.SetValue(pos, atr);
         Box* f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13Value;
         if (!f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13.GetValue(pos, f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13Value)) { f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13Value = NULL; }
         f_supply_demand_faS_iaS_bxaS_bxaS_i_fS13Value;
      }
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param1.SetValue(pos, current_supply_box);
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param2.SetValue(pos, supply_bos);
      f_sd_to_bos_bxaS_bxaS_bxaS_i16_param3.SetValue(pos, current_supply_poi);
      if (!f_sd_to_bos_bxaS_bxaS_bxaS_i16.GetValue(pos)) { }
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param1.SetValue(pos, current_demand_box);
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param2.SetValue(pos, demand_bos);
      f_sd_to_bos_bxaS_bxaS_bxaS_i17_param3.SetValue(pos, current_demand_poi);
      if (!f_sd_to_bos_bxaS_bxaS_bxaS_i17.GetValue(pos)) { }
      f_extend_box_endpoint_bxaS18_param1.SetValue(pos, current_supply_box);
      if (!f_extend_box_endpoint_bxaS18.GetValue(pos)) { }
      f_extend_box_endpoint_bxaS19_param1.SetValue(pos, current_demand_box);
      if (!f_extend_box_endpoint_bxaS19.GetValue(pos)) { }
      highest1Source.SetValue(pos, high[pos]);
      double highest1Value;
      if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, swing_length * 2 + 1)) { highest1Value = EMPTY_VALUE; }
      h = highest1Value;
      lowest1Source.SetValue(pos, low[pos]);
      double lowest1Value;
      if (!LowestLowStream::GetValue(pos, lowest1Value, lowest1Source, swing_length * 2 + 1)) { lowest1Value = EMPTY_VALUE; }
      l = lowest1Value;
      lastLow = high[pos] * 100;
      if (dirUp[pos])
      {
         bool f_isMin_i20Value;
         if (!f_isMin_i20.GetValue(pos, f_isMin_i20Value)) { f_isMin_i20Value = EMPTY_VALUE; }
         if (pos + swing_length > (rates_total - 1)) { continue; }
         if (f_isMin_i20Value && (low[pos + swing_length] < lastLow))
         {
            if (pos + swing_length > (rates_total - 1)) { continue; }
            lastLow = low[pos + swing_length];
            timeLow[pos] = ((rates_total - 1) - pos);
            LinesCollection::Delete(li);
            Line* f_drawLine21Value;
            if (!f_drawLine21.GetValue(pos, f_drawLine21Value)) { f_drawLine21Value = NULL; }
            li = f_drawLine21Value;
            li;
         }
         bool f_isMax_i22Value;
         if (!f_isMax_i22.GetValue(pos, f_isMax_i22Value)) { f_isMax_i22Value = EMPTY_VALUE; }
         if (pos + swing_length > (rates_total - 1)) { continue; }
         if (f_isMax_i22Value && (high[pos + swing_length] > lastLow))
         {
            if (pos + swing_length > (rates_total - 1)) { continue; }
            lastHigh[pos] = high[pos + swing_length];
            timeHigh[pos] = ((rates_total - 1) - pos);
            dirUp[pos] = false;
            Line* f_drawLine23Value;
            if (!f_drawLine23.GetValue(pos, f_drawLine23Value)) { f_drawLine23Value = NULL; }
            li = f_drawLine23Value;
            li;
         }
      }
      if (!dirUp[pos])
      {
         bool f_isMax_i24Value;
         if (!f_isMax_i24.GetValue(pos, f_isMax_i24Value)) { f_isMax_i24Value = EMPTY_VALUE; }
         if (pos + swing_length > (rates_total - 1)) { continue; }
         if (f_isMax_i24Value && (high[pos + swing_length] > lastHigh[pos]))
         {
            if (pos + swing_length > (rates_total - 1)) { continue; }
            lastHigh[pos] = high[pos + swing_length];
            timeHigh[pos] = ((rates_total - 1) - pos);
            LinesCollection::Delete(li);
            Line* f_drawLine25Value;
            if (!f_drawLine25.GetValue(pos, f_drawLine25Value)) { f_drawLine25Value = NULL; }
            li = f_drawLine25Value;
            li;
         }
         bool f_isMin_i26Value;
         if (!f_isMin_i26.GetValue(pos, f_isMin_i26Value)) { f_isMin_i26Value = EMPTY_VALUE; }
         if (pos + swing_length > (rates_total - 1)) { continue; }
         if (f_isMin_i26Value && (low[pos + swing_length] < lastHigh[pos]))
         {
            if (pos + swing_length > (rates_total - 1)) { continue; }
            lastLow = low[pos + swing_length];
            timeLow[pos] = ((rates_total - 1) - pos);
            dirUp[pos] = true;
            Line* f_drawLine27Value;
            if (!f_drawLine27.GetValue(pos, f_drawLine27Value)) { f_drawLine27Value = NULL; }
            li = f_drawLine27Value;
            bool f_isMax_i28Value;
            if (!f_isMax_i28.GetValue(pos, f_isMax_i28Value)) { f_isMax_i28Value = EMPTY_VALUE; }
            if (pos + swing_length > (rates_total - 1)) { continue; }
            if (f_isMax_i28Value && (high[pos + swing_length] > lastLow))
            {
               if (pos + swing_length > (rates_total - 1)) { continue; }
               lastHigh[pos] = high[pos + swing_length];
               timeHigh[pos] = ((rates_total - 1) - pos);
               dirUp[pos] = false;
               Line* f_drawLine29Value;
               if (!f_drawLine29.GetValue(pos, f_drawLine29Value)) { f_drawLine29Value = NULL; }
               li = f_drawLine29Value;
               li;
            }
         }
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LabelsCollection::Redraw();
   BoxesCollection::Redraw();
   LinesCollection::Redraw();
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