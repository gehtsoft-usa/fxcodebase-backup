// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71491

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
#property indicator_chart_window
#property indicator_buffers 0

input bool offset = false; // Repaint or not?
input int mindivcount = 2; // Minimum Div Count to Display
input int lbR = 1; // Pivot Lookback Right
input int lbL = 3; // Pivot Lookback Left
input int rangeUpper = 60; // Max of Lookback Range
input int rangeLower = 1; // Min of Lookback Range
input bool plotBull = true; // Plot Bullish
input bool plotHiddenBull = true; // Plot Hidden Bullish
input bool plotBear = true; // Plot Bearish
input bool plotHiddenBear = true; // Plot Hidden Bearish
input bool calcmacd = true; // MACD
input bool calcmacda = true; // MACD Histogram
input bool calcrsi = true; // RSI
input bool calcstoc = true; // Stochastic
input bool calccci = true; // CCI
input bool calcmom = true; // Momentum
input bool calcobv = true; // OBV
input bool calcdi = true; // Diosc
input bool calcvwmacd = true; // VWmacd
input bool calccmf = true; // Chaikin Money Flow
input int bars_limit = 100000; // Bars limit
double sma_src[], _osc[];

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

// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
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
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open, close;
               if (!_source.GetOpenClose(period, open, close))
               {
                  return false;
               }
               val = (open + close) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close + open) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               if (open > close)
                  val = (high + close) / 2.0;
               else
                  val = (low + close) / 2.0;
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

class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period);
               if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                  val = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};
#endif


//AOnStream v1.0

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

   virtual int Size()
   {
      return _source.Size();
   }
};


// RSI stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
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

// RSI stream v1.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSIStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSIStream(IStream* stream, int period)
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
      if (period == totalBars - 1 || _pos[period + 1])
      {
         for (int i = 0; i < _period; ++i)
         {
            double diff;
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
         double diff;
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

#endif



// IndicatorOutputStream v3.0
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
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, _data);
      SetIndexLabel(id, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, _data);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValue(const int period, double& val)
   {
      if (_data[period] == EMPTY_VALUE)
         return false;
      val = _data[period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif


//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

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

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price) / _length;
      }
      val = _buffer[index];
      return true;
   }
};

#endif
// Fix NAN stream v1.0



class FixnanStream : public AOnStream
{
   int _maxLookback;
public:
   FixnanStream(IStream *source)
      :AOnStream(source)
   {
      _maxLookback = 1000;
   }

   bool GetValue(const int period, double &val)
   {
      for (int i = 0; i < _maxLookback; ++i)
      {
         if (_source.GetValue(period + i, val))
         {
            return true;
         }
      }

      return false;
   }
};


#ifndef VwmaOnStream_IMP
#define VwmaOnStream_IMP

class VwmaOnStream : public AOnStream
{
   int _length;
public:
   VwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = Volume[period];
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

#endif
// Value when stream v2.1

#ifndef ValueWhenStream_IMP
#define ValueWhenStream_IMP


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

class ValueWhenStream : public AStreamBase
{
   ICondition* _condition;
   IStream* _source;
   int _periods[];
   double _values[];
   int _shift;
public:
   double _data[];

   ValueWhenStream(ICondition* condition, IStream* source, int shift)
   {
      _shift = shift;
      _condition = condition;
      _condition.AddRef();
      _source = source;
      _source.AddRef();
   }

   ~ValueWhenStream()
   {
      _source.Release();
      _condition.Release();
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _data);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _data);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   void Update(const int period, datetime date)
   {
      double val;
      if (_condition.IsPass(period, 0) && _source.GetValue(period, val))
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
            _data[period] = _values[size - 1 - _shift];
         }
      }
      else if (_source.Size() - 1 > period)
      {
         _data[period] = _data[period + 1];
      }
   }

   bool GetValue(const int period, double &val)
   {
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _data[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _data);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _data);
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
            _data[period] = _values[size - 1 - _shift];
         }
      }
      else if (iBars(_symbol, _timeframe) - 1 > period)
      {
         _data[period] = _data[period + 1];
      }
      return _data[period];
   }

   bool GetValue(const int period, double &val)
   {
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif
class AConditionBase : public ICondition
{
   int _references;
   string _conditionName;
public:
   AConditionBase(string name = "")
   {
      _conditionName = name;
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      if (_conditionName == "" || _conditionName == NULL)
      {
         return "";
      }
      return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
   }
};
class TroughCondition : public AConditionBase
{
   IStream* _source;
   int _left;
   int _right;
public:
   TroughCondition(IStream* source, int left, int right)
   {
      _source = source;
      _source.AddRef();
      _left = left;
      _right = right;
   }

   ~TroughCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double centerValue;
      if (!_source.GetValue(period + _right, centerValue))
         return false;

      for (int i = 0; i < _left; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _right + i + 1, leftValue) || leftValue < centerValue)
            return false;
      }
      for (int i = 0; i < _right; ++i)
      {
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue < centerValue)
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Trough: " + (result ? "true" : "false");
   }
};

class PeakCondition : public AConditionBase
{
   IStream* _source;
   int _left;
   int _right;
public:
   PeakCondition(IStream* source, int left, int right)
   {
      _source = source;
      _source.AddRef();
      _left = left;
      _right = right;
   }

   ~PeakCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double centerValue;
      if (!_source.GetValue(period + _right, centerValue))
         return false;

      for (int i = 0; i < _left; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _right + i + 1, leftValue) || leftValue > centerValue)
            return false;
      }
      for (int i = 0; i < _right; ++i)
      {
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue > centerValue)
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Peak: " + (result ? "true" : "false");
   }
};

class HiddenBearishDivergenceCondition : public AConditionBase
{
   ICondition* _priceCondition;
   ICondition* _indiCondition;
   SimplePriceStream* _price;
   IStream* _data;
   int _right;
public:
   HiddenBearishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe, int left, int right)
      :AConditionBase("Hidden bearish divergence")
   {
      _right = right;
      _data = stream;
      _data.AddRef();
      _indiCondition = new PeakCondition(stream, left, right);
      _price = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _priceCondition = new PeakCondition(_price, left, right);
   }

   ~HiddenBearishDivergenceCondition()
   {
      _data.Release();
      _price.Release();
      delete _priceCondition;
      delete _indiCondition;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!(_indiCondition.IsPass(period, date) && _priceCondition.IsPass(period, date)))
      {
         return false;
      }
      double peaks, peaks_h;
      if (!_data.GetValue(period + _right, peaks) || !_price.GetValue(period + _right, peaks_h))
      {
         return false;
      }
      for (int i = period + 1; i < 1000; ++i)
      {
         if (_indiCondition.IsPass(i, 0) && _priceCondition.IsPass(i, 0))
         {
            double peaks_prev, peaks_h_prev;
            return _data.GetValue(i + _right, peaks_prev) 
               && _price.GetValue(i + _right, peaks_h_prev)
               && peaks > peaks_prev && peaks_h < peaks_h_prev;
         }
      }
      return false;
   }
};

class HiddenBullishDivergenceCondition : public AConditionBase
{
   ICondition* _priceCondition;
   ICondition* _indiCondition;
   SimplePriceStream* _price;
   IStream* _data;
   int _right;
public:
   HiddenBullishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe, int left, int right)
      :AConditionBase("Hidden bullish divergence")
   {
      _right = right;
      _data = stream;
      _data.AddRef();
      _indiCondition = new TroughCondition(stream, left, right);
      _price = new SimplePriceStream(symbol, timeframe, PriceLow);
      _priceCondition = new TroughCondition(_price, left, right);
   }

   ~HiddenBullishDivergenceCondition()
   {
      _data.Release();
      _price.Release();
      delete _priceCondition;
      delete _indiCondition;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!(_indiCondition.IsPass(period, date) && _priceCondition.IsPass(period, date)))
      {
         return false;
      }
      double trough, trough_l;
      if (!_data.GetValue(period + _right, trough) || !_price.GetValue(period + _right, trough_l))
      {
         return false;
      }
      for (int i = period + 1; i < 1000; ++i)
      {
         if (_indiCondition.IsPass(i, 0) && _priceCondition.IsPass(i, 0))
         {
            double trough_prev, trough_l_prev;
            return _data.GetValue(i + _right, trough_prev) 
               && _price.GetValue(i + _right, trough_l_prev)
               && trough < trough_prev && trough_l > trough_l_prev;
         }
      }
      return false;
   }
};

class RegularBearishDivergenceCondition : public AConditionBase
{
   ICondition* _priceCondition;
   ICondition* _indiCondition;
   SimplePriceStream* _price;
   IStream* _data;
   int _right;
public:
   RegularBearishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe, int left, int right)
      :AConditionBase("Regular bearish divergence")
   {
      _right = right;
      _data = stream;
      _data.AddRef();
      _indiCondition = new PeakCondition(stream, left, right);
      _price = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _priceCondition = new PeakCondition(_price, left, right);
   }

   ~RegularBearishDivergenceCondition()
   {
      _data.Release();
      _price.Release();
      delete _priceCondition;
      delete _indiCondition;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!(_indiCondition.IsPass(period, date) && _priceCondition.IsPass(period, date)))
      {
         return false;
      }
      double peaks, peaks_h;
      if (!_data.GetValue(period + _right, peaks) || !_price.GetValue(period + _right, peaks_h))
      {
         return false;
      }
      for (int i = period + 1; i < 1000; ++i)
      {
         if (_indiCondition.IsPass(i, 0) && _priceCondition.IsPass(i, 0))
         {
            double peaks_prev, peaks_h_prev;
            return _data.GetValue(i + _right, peaks_prev) 
               && _price.GetValue(i + _right, peaks_h_prev)
               && peaks < peaks_prev && peaks_h > peaks_h_prev;
         }
      }
      return false;
   }
};

class RegularBullishDivergenceCondition : public AConditionBase
{
   ICondition* _priceCondition;
   ICondition* _indiCondition;
   SimplePriceStream* _price;
   IStream* _data;
   int _right;
public:
   RegularBullishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe, int left, int right)
      :AConditionBase("Regular bullish divergence")
   {
      _right = right;
      _data = stream;
      _data.AddRef();
      _indiCondition = new TroughCondition(stream, left, right);
      _price = new SimplePriceStream(symbol, timeframe, PriceLow);
      _priceCondition = new TroughCondition(_price, left, right);
   }

   ~RegularBullishDivergenceCondition()
   {
      _data.Release();
      _price.Release();
      delete _priceCondition;
      delete _indiCondition;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!(_indiCondition.IsPass(period, date) && _priceCondition.IsPass(period, date)))
      {
         return false;
      }
      double trough, trough_l;
      if (!_data.GetValue(period + _right, trough) || !_price.GetValue(period + _right, trough_l))
      {
         return false;
      }
      for (int i = period + 1; i < 1000; ++i)
      {
         if (_indiCondition.IsPass(i, 0) && _priceCondition.IsPass(i, 0))
         {
            double trough_prev, trough_l_prev;
            return _data.GetValue(i + _right, trough_prev) 
               && _price.GetValue(i + _right, trough_l_prev)
               && trough > trough_prev && trough_l < trough_l_prev;
         }
      }
      return false;
   }
};

class TrueRangeStream : public AStream
{
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         return false;
      }
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
};

IStream* rsi1;
IStream* highStreamChange;
IStream* lowStreamChange;
IndicatorOutputStream* obvX;
IndicatorOutputStream* sma9Source;
IStream* sma9;
TrueRangeStream* rma12Source;
IStream* rma12;
IndicatorOutputStream* rma13Source;
IStream* rma13;
IndicatorOutputStream* fixnan14X;
IStream* fixnan14;
IStream* vwma15;
IStream* vwma16;
IndicatorOutputStream* sma17Source;
SimplePriceStream* sma18Source;
IStream* sma17;
IStream* sma18;
IndicatorOutputStream* macd;
IndicatorOutputStream* deltamacd;
IndicatorOutputStream* moment;
IndicatorOutputStream* cmf;
IndicatorOutputStream* cci;
IndicatorOutputStream* vwmacd;
CumOnStream* obv;
IndicatorOutputStream* stk;
class Conditions
{
   RegularBearishDivergenceCondition* bearCond[];
   RegularBullishDivergenceCondition* bullCond[];
   HiddenBearishDivergenceCondition* hidBearCond[];
   HiddenBullishDivergenceCondition* hidBullCond[];
public:
   void Add(IStream* stream)
   {
      int size = ArraySize(bearCond);
      ArrayResize(bearCond, size + 1);
      ArrayResize(bullCond, size + 1);
      ArrayResize(hidBearCond, size + 1);
      ArrayResize(hidBullCond, size + 1);
      bearCond[size] = new RegularBearishDivergenceCondition(stream, _Symbol, (ENUM_TIMEFRAMES)_Period, lbL, lbR);
      bullCond[size] = new RegularBullishDivergenceCondition(stream, _Symbol, (ENUM_TIMEFRAMES)_Period, lbL, lbR);
      hidBearCond[size] = new HiddenBearishDivergenceCondition(stream, _Symbol, (ENUM_TIMEFRAMES)_Period, lbL, lbR);
      hidBullCond[size] = new HiddenBullishDivergenceCondition(stream, _Symbol, (ENUM_TIMEFRAMES)_Period, lbL, lbR);
   }
   int CountBear(int period, datetime dt)
   {
      int count = 0;
      for (int i = 0; i < ArraySize(bearCond); ++i)
      {
         if (bearCond[i].IsPass(period, dt))
         {
            ++count;
         }
      }
      return count;
   }
   int CountBull(int period, datetime dt)
   {
      int count = 0;
      for (int i = 0; i < ArraySize(bearCond); ++i)
      {
         if (bullCond[i].IsPass(period, dt))
         {
            ++count;
         }
      }
      return count;
   }
   int CountHidBear(int period, datetime dt)
   {
      int count = 0;
      for (int i = 0; i < ArraySize(bearCond); ++i)
      {
         if (hidBearCond[i].IsPass(period, dt))
         {
            ++count;
         }
      }
      return count;
   }
   int CountHidBull(int period, datetime dt)
   {
      int count = 0;
      for (int i = 0; i < ArraySize(bearCond); ++i)
      {
         if (hidBullCond[i].IsPass(period, dt))
         {
            ++count;
         }
      }
      return count;
   }
   ~Conditions()
   {
      for (int i = 0; i < ArraySize(bearCond); ++i)
      {
         bearCond[i].Release();
         bullCond[i].Release();
         hidBearCond[i].Release();
         hidBullCond[i].Release();
      }
   }
};
SimplePriceStream* closeStream;
SimplePriceStream* highStream;
SimplePriceStream* lowStream;
Conditions conditions;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Multiple divergences rework NON-REPAINT by PeterO");
   IndicatorBuffers(24);
   int id = 0;
   SetIndexBuffer(id++, sma_src);
   SetIndexBuffer(id++, _osc);
   closeStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   highStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   lowStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   highStreamChange = new ChangeStream(highStream, 1);
   lowStreamChange = new ChangeStream(lowStream, 1);
   if (calcrsi)
   {
      rsi1 = new RSIStream(closeStream, 14);
      conditions.Add(rsi1);
   }
   if (calcmacd)
   {
      macd = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = macd.RegisterInternalStream(id);
      conditions.Add(macd);
   }
   if (calcmacda)
   {
      deltamacd = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = deltamacd.RegisterInternalStream(id);
      conditions.Add(deltamacd);
   }
   if (calcmom)
   {
      moment = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = moment.RegisterInternalStream(id);
      conditions.Add(moment);
   }
   if (calccci)
   {
      cci = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = cci.RegisterInternalStream(id);
      conditions.Add(cci);
   }
   if (calcobv)
   {
      obvX = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = obvX.RegisterInternalStream(id);
      obv = new CumOnStream(obvX);
      conditions.Add(obv);
   }
   if (calcstoc)
   {
      stk = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = stk.RegisterInternalStream(id);
      conditions.Add(stk);
   }
   if (calcvwmacd)
   {
      vwmacd = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = vwmacd.RegisterInternalStream(id);
      conditions.Add(vwmacd);
   }
   if (calccmf)
   {
      cmf = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = cmf.RegisterInternalStream(id);
      conditions.Add(cmf);
   }

   rma12Source = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma12 = new RmaOnStream(rma12Source, 14);
   rma13Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rma13Source.RegisterInternalStream(id);
   rma13 = new RmaOnStream(rma13Source, 14);
   if (calcdi)
   {
      fixnan14X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = fixnan14X.RegisterInternalStream(id);
      fixnan14 = new FixnanStream(fixnan14X);
      conditions.Add(fixnan14);
   }
   
   vwma15 = new VwmaOnStream(closeStream, 12);
   vwma16 = new VwmaOnStream(closeStream, 26);
   sma17Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = sma17Source.RegisterInternalStream(id);
   sma17 = new SmaOnStream(sma17Source, 21);
   sma18Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceVolume);
   sma18 = new SmaOnStream(sma18Source, 21);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
   if (cmf != NULL)
      cmf.Release();
   if (vwmacd != NULL)
      vwmacd.Release();
   if (macd != NULL)
      macd.Release();
   if (deltamacd != NULL)
      deltamacd.Release();
   if (cci != NULL)
      cci.Release();
   if (moment != NULL)
      moment.Release();
   if (obv != NULL)
      obv.Release();
   if (stk != NULL)
      stk.Release();
   if (rsi1 != NULL)
      rsi1.Release();
   if (highStreamChange != NULL)
      highStreamChange.Release();
   if (lowStreamChange != NULL)
      lowStreamChange.Release();
   if (obvX != NULL)
      obvX.Release();
   if (rma12Source != NULL)
      rma12Source.Release();
   if (rma12 != NULL)
      rma12.Release();
   if (rma13Source != NULL)
      rma13Source.Release();
   if (rma13 != NULL)
      rma13.Release();
   if (fixnan14X != NULL)
      fixnan14X.Release();
   if (fixnan14 != NULL)
      fixnan14.Release();
   if (vwma15 != NULL)
      vwma15.Release();
   if (vwma16 != NULL)
      vwma16.Release();
   if (sma17Source != NULL)
      sma17Source.Release();
   if (sma17 != NULL)
      sma17.Release();
   if (sma18Source != NULL)
      sma18Source.Release();
   if (sma18 != NULL)
      sma18.Release();
   return 0;
}     

void create(datetime dt, double price, string textId, string text, color clr)
{
   ResetLastError();
   string id = IndicatorObjPrefix + textId + TimeToString(dt);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TEXT, 0, dt, price))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, dt);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
   ObjectSetString(0, id, OBJPROP_TEXT, "1");
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
      ArrayInitialize(sma_src, EMPTY_VALUE);
      ArrayInitialize(_osc, EMPTY_VALUE);
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
      double macd2MACDValue = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, pos);
      if (macd != NULL)
         macd._data[pos] = macd2MACDValue;
      if (deltamacd != NULL)
         deltamacd._data[pos] = macd2MACDValue - iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, pos);
      if (moment != NULL)
         moment._data[pos] = iMomentum(_Symbol, _Period, 10, PRICE_CLOSE, pos);
      if (stk != NULL)
         stk._data[pos] = iStochastic(_Symbol, _Period, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, pos);
      sma17Source._data[pos] = (high[pos] - low[pos]) == 0 ? 0 : ((close[pos] - low[pos])) / (high[pos] - low[pos]) * tick_volume[pos];
      if (cci != NULL)
         cci._data[pos] = iCCI(_Symbol, _Period, 10, PRICE_CLOSE, pos);
      double highStreamChangeValue;
      if (!highStreamChange.GetValue(pos, highStreamChangeValue))
      {
         continue;
      }
      double lowStreamChangeValue;
      if (!lowStreamChange.GetValue(pos, lowStreamChangeValue))
      {
         continue;
      }
      if (obvX != NULL)
         obvX._data[pos] = ((highStreamChangeValue > 0) ? tick_volume[pos] : ((lowStreamChangeValue < 0) ? (-tick_volume[pos]) : 0));

      if (fixnan14X != NULL)
      {
         rma13Source._data[pos] = highStreamChangeValue - ((-lowStreamChangeValue));
         double trur;
         if (!rma12.GetValue(pos, trur))
         {
            continue;
         }
         double rma13Value;
         if (!rma13.GetValue(pos, rma13Value))
         {
            continue;
         }
         fixnan14X._data[pos] = 100 * rma13Value / trur;
      }
      
      if (vwmacd != NULL)
      {
         double maFast;
         if (!vwma15.GetValue(pos, maFast))
         {
            continue;
         }
         double maSlow;
         if (!vwma16.GetValue(pos, maSlow))
         {
            continue;
         }
         vwmacd._data[pos] = maFast - maSlow;
      }

      if (cmf != NULL)
      {
         double sma17Value;
         if (!sma17.GetValue(pos, sma17Value))
         {
            continue;
         }
         double sma18Value;
         if (!sma18.GetValue(pos, sma18Value))
         {
            continue;
         }
         cmf._data[pos] = sma17Value / sma18Value;
      }

      int negdivergence = conditions.CountBear(pos, time[pos]);
      int posdivergence = conditions.CountBull(pos, time[pos]);
      int negdivergencehidden = conditions.CountHidBear(pos, time[pos]);
      int posdivergencehidden = conditions.CountHidBull(pos, time[pos]);
      if (posdivergence >= 1 && mindivcount <= posdivergence)
      {
         create(time[pos + lbR], low[pos + lbR], "rbl", IntegerToString(posdivergence), Teal);
      }
      if ((posdivergence > 8) && (mindivcount < 11))
      {
         create(time[pos + lbR], low[pos + lbR], "rbl", "8+", Teal);
      }
      if (negdivergence >= 1 && mindivcount <= negdivergence)
      {
         create(time[pos + lbR], low[pos + lbR], "rbr", IntegerToString(negdivergence), Red);
      }
      if ((negdivergence > 8) && (mindivcount < 11))
      {
         create(time[pos + lbR], low[pos + lbR], "rbr", "8+", Red);
      }
      if (posdivergencehidden >= 1 && mindivcount <= posdivergencehidden)
      {
         create(time[pos + lbR], low[pos + lbR], "hbl", IntegerToString(posdivergencehidden), Green);
      } 
      if ((posdivergencehidden > 8) && (mindivcount < 11))
      {
         create(time[pos + lbR], low[pos + lbR], "hbl", "8+", Green);
      }
      if (negdivergencehidden >= 1 && mindivcount <= negdivergencehidden)
      {
         create(time[pos + lbR], low[pos + lbR], "hbr", IntegerToString(negdivergencehidden), Orange);
      }
      if ((negdivergencehidden > 8) && (mindivcount < 11))
      {
         create(time[pos + lbR], low[pos + lbR], "hbr", "8+", Orange);
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
