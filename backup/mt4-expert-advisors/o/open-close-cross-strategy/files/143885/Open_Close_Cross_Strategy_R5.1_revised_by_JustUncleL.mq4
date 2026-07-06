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
#property indicator_buffers 2
#property indicator_label1 "Close Series"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Open Series"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1


#ifndef MATypes_IMP
#define MATypes_IMP

enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   //ma_hull,    // Hull moving average
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo,     // Smoother,
   ma_zltema, // Zero lag TEMA
   ma_rma, // RMA
   ma_wma, // WMA
};

#endif
input MATypes basisType = ma_sma; // MA Type: 
input int basisLen = 8; // MA Period
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], trend[];

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
// Averages stream factory v1.0





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
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
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



// TEMA on stream v1.0

#ifndef TemaOnStream_IMP
#define TemaOnStream_IMP

class TemaOnStream : public AStreamBase
{
   EMAOnStream *_ema1;
   EMAOnStream *_ema2;
   EMAOnStream *_ema3;
public:
   TemaOnStream(IStream *source, const int length)
   {
      _ema1 = new EMAOnStream(source, length);
      _ema2 = new EMAOnStream(_ema1, length);
      _ema3 = new EMAOnStream(_ema2, length);
   }

   ~TemaOnStream()
   {
      delete _ema3;
      delete _ema2;
      delete _ema1;
   }

   int Size()
   {
      return _ema3.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double ema1, ema2, ema3;
      if (!_ema1.GetValue(period + 1, ema1) || !_ema2.GetValue(period, ema2) || !_ema3.GetValue(period, ema3))
         return false;
         
      val = ema3 + 3.0 * (ema1 - ema2);
      return true;
   }
};

#endif


// LWMA on stream v1.0

#ifndef LwmaOnStream_IMP
#define LwmaOnStream_IMP

class LwmaOnStream : public AOnStream
{
   int _length;
public:
   LwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      double sumw = _length;
      double sum = _length * price;
      for(int i = 1; i < _length; i++)
      {
         double weight = _length - i;
         sumw += weight;
         if (!_source.GetValue(period + i, price))
            return false;
         sum += weight * price;
      }
      val = sum / sumw;
      return true;
   }
};

#endif


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


// WMA on stream v1.1

#ifndef WMAOnStream_IMP
#define WMAOnStream_IMP

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
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

      _buffer[bufferIndex] = (current - last) * _k + last;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// Zero lag TEMA on stream v1.0




#ifndef ZeroLagTEMAOnStream_IMP
#define ZeroLagTEMAOnStream_IMP

class ZeroLagTEMAOnStream : public AStreamBase
{
   TemaOnStream *_tema1;
   TemaOnStream *_tema2;
public:
   ZeroLagTEMAOnStream(IStream *source, const int length)
   {
      _tema1 = new TemaOnStream(source, length);
      _tema2 = new TemaOnStream(_tema1, length);
   }

   ~ZeroLagTEMAOnStream()
   {
      delete _tema2;
      delete _tema1;
   }

   int Size()
   {
      return _tema2.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double tema1, tema2;
      if (!_tema1.GetValue(period, tema1) || !_tema2.GetValue(period, tema2))
         return false;

      val = (2.0 * tema1 - tema2);
      return true;
   }
};

#endif


// Zero lag MA on stream v1.0

#ifndef ZeroLagMAOnStream_IMP
#define ZeroLagMAOnStream_IMP

class ZeroLagMAOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   double _alpha;
public:
   ZeroLagMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _alpha = 2.0 / (1.0 + _length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - 1)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      int shift = (int)((_length - 1.0) / 2.0);
      double prevPrice;
      if (period < shift || !_source.GetValue(period - shift, prevPrice))
      {
         _buffer[bufferIndex] = price;
         return true;
      }

      _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (2.0 * price - prevPrice - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

#endif

#ifndef AveragesStreamFactory_IMP
#define AveragesStreamFactory_IMP

// Averages v. 1.1

class AveragesStreamFactory
{
public:
   static IStream *Create(IStream *source, const int length, const MATypes type)
   {
      switch (type)
      {
         case ma_sma:
            return new SmaOnStream(source, length);
         case ma_wma:
            return new WMAOnStream(source, length);
         case ma_ema:
            return new EMAOnStream(source, length);
         //case 2  : return(iDsema(price,length,r,instanceNo));
         // case 3  : return(iDema(price,length,r,instanceNo));
         case ma_tema:
            return new TemaOnStream(source, length);
         // case 5  : return(iSmma(price,length,r,instanceNo));
         case ma_lwma:
            return new LwmaOnStream(source, length);
         // case 7  : return(iLwmp(price,length,r,instanceNo));
         // case 8  : return(iAlex(price,length,r,instanceNo));
         case ma_vwma:
            return new VwmaOnStream(source, length);
         // case 10 : return(iHull(price,length,r,instanceNo));
         // case 11 : return(iTma(price,length,r,instanceNo));
         // case 12 : return(iSineWMA(price,(int)length,r,instanceNo));
         // case 13 : return(iLinr(price,length,r,instanceNo));
         // case 14 : return(iIe2(price,length,r,instanceNo));
         // case 15 : return(iNonLagMa(price,length,r,instanceNo));
         case ma_zlma:
            return new ZeroLagMAOnStream(source, length);
         case ma_rma:
            return new RmaOnStream(source, length);
         case ma_zltema:
            return new ZeroLagTEMAOnStream(source, length);
         // case 17 : return(iLeader(price,length,r,instanceNo));
         // case 18 : return(iSsm(price,length,r,instanceNo));
         // case 19 : return(iSmooth(price,(int)length,r,instanceNo));
         // default : return(0);
      }
      return NULL;
   }
};

#endif
SimplePriceStream* sma1Source;
IStream* sma1;
SimplePriceStream* sma2Source;
IStream* sma2;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("OCC Strategy R5.1");
   IndicatorShortName("Open Close Cross Strategy R5.1 revised by JustUncleL");
   IndicatorBuffers(3);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id++, trend);
   sma1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   sma1 = AveragesStreamFactory::Create(sma1Source, basisLen, basisType);
   sma2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceOpen);
   sma2 = AveragesStreamFactory::Create(sma2Source, basisLen, basisType);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(trend, EMPTY_VALUE);
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
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value))
      {
         continue;
      }
      double closeSeries = sma1Value;
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value))
      {
         continue;
      }
      double openSeries = sma2Value;
      double closeSeriesAlt = closeSeries;
      double openSeriesAlt = openSeries;

      plot1[pos] = closeSeriesAlt;
      plot2[pos] = openSeriesAlt;
 
      trend[pos] = closeSeriesAlt > openSeriesAlt ? 1 : -1;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
