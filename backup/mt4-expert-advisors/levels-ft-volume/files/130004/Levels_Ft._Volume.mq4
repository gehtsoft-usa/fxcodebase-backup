

// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69172

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 7

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};


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
};
#define AStream_IMP
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

class PriceStream : public AStream
{
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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
// Value when stream v1.0

#ifndef ValueWhenStream_IMP
#define ValueWhenStream_IMP

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
public:
   double _stream[];

   ValueWhenStream(ICondition* condition, IStream* source)
   {
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

   void Update(const int period)
   {
      double val;
      if (_condition.IsPass(period, 0) && _source.GetValue(period, val))
      {
         _stream[period] = val;
      }
      else
      {
         if (Bars - 1 != period)
         {
            _stream[period] = _stream[period + 1];
         }
      }
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif
// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP



class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   int _references;
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
   }

   ~SmaOnStream()
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
// Abstract condition v1.1



#ifndef ACondition_IMP
#define ACondition_IMP

class ACondition : public ICondition
{
   int _references;
public:
   ACondition()
   {
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
      return "";
   }
};

#endif

PriceStream* volumeStream;
PriceStream* source;
SmaOnStream* smaVolume9;
ValueWhenStream* lvl1;
ValueWhenStream* lvl2;
ValueWhenStream* lvl3;
ValueWhenStream* lvl4;
ValueWhenStream* lvl5;
ValueWhenStream* lvl6;
ValueWhenStream* lvl7;

class MainCondition : public ACondition
{
   int _len;
   SmaOnStream* _stream;
public:
   MainCondition(int len)
   {
      _len = len;
      _stream = new SmaOnStream(volumeStream, len);
   }

   ~MainCondition()
   {
      _stream.Release();
   }
   
   virtual bool IsPass(const int period, const datetime date)
   {
      double vol2, vol;
      if (!_stream.GetValue(period, vol2) || !smaVolume9.GetValue(period, vol))
      {
         return false;
      }
      return vol > vol2;
   }
};

int init()
{
   IndicatorName = GenerateIndicatorName("Levels Ft. Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   volumeStream = new PriceStream(_Symbol, timeframe, PriceVolume);
   smaVolume9 = new SmaOnStream(volumeStream, 9);
   source = new PriceStream(_Symbol, timeframe, PriceTypical);

   IndicatorBuffers(7);
   int id = 0;

   ICondition* conditioin1 = new MainCondition(21);
   lvl1 = new ValueWhenStream(conditioin1, source);
   id = lvl1.RegisterStream(id, Red, 1, STYLE_SOLID, "21");
   conditioin1.Release();

   ICondition* conditioin2 = new MainCondition(64);
   lvl2 = new ValueWhenStream(conditioin2, source);
   id = lvl2.RegisterStream(id, Red, 1, STYLE_SOLID, "64");
   conditioin2.Release();

   ICondition* conditioin3 = new MainCondition(128);
   lvl3 = new ValueWhenStream(conditioin3, source);
   id = lvl3.RegisterStream(id, Red, 1, STYLE_SOLID, "128");
   conditioin3.Release();

   ICondition* conditioin4 = new MainCondition(256);
   lvl4 = new ValueWhenStream(conditioin4, source);
   id = lvl4.RegisterStream(id, Red, 1, STYLE_SOLID, "256");
   conditioin4.Release();

   ICondition* conditioin5 = new MainCondition(512);
   lvl5 = new ValueWhenStream(conditioin5, source);
   id = lvl5.RegisterStream(id, Red, 1, STYLE_SOLID, "512");
   conditioin5.Release();

   ICondition* conditioin6 = new MainCondition(1024);
   lvl6 = new ValueWhenStream(conditioin6, source);
   id = lvl6.RegisterStream(id, Red, 1, STYLE_SOLID, "1024");
   conditioin6.Release();

   ICondition* conditioin7 = new MainCondition(2048);
   lvl7 = new ValueWhenStream(conditioin7, source);
   id = lvl7.RegisterStream(id, Red, 1, STYLE_SOLID, "2048");
   conditioin7.Release();

   return 0;
}

int deinit()
{
   source.Release();
   smaVolume9.Release();
   volumeStream.Release();
   lvl1.Release();
   lvl2.Release();
   lvl3.Release();
   lvl4.Release();
   lvl5.Release();
   lvl6.Release();
   lvl7.Release();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      lvl1.Update(i);
      lvl2.Update(i);
      lvl3.Update(i);
      lvl4.Update(i);
      lvl5.Update(i);
      lvl6.Update(i);
      lvl7.Update(i);
   }
   return 0;
}
