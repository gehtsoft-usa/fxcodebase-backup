// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67344

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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_label1 "CCI 1"
#property indicator_color1 Red
#property indicator_label1 "CCI 2"

extern double Constant_1 = 0.015; // Constant 1
extern int SmoothingPeriod_1 = 20; // Smoothing period 1
extern int DevLength_1 = 14; // Deviation length 1
input bool show_second = true; // Show second
extern double Constant_2 = 0.030; // Constant 2
extern int SmoothingPeriod_2 = 40; // Smoothing period 2
extern int DevLength_2 = 28; // Deviation length 2

double out1[];
double out2[];

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

// Instrument info v.1.2
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
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

// Stream v.1.1
interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
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
};

class PriceStream : public AStream
{
   ENUM_APPLIED_PRICE _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :AStream(symbol, timeframe)
   {
      _price = price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PRICE_CLOSE:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PRICE_OPEN:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PRICE_HIGH:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PRICE_LOW:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PRICE_MEDIAN:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PRICE_TYPICAL:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PRICE_WEIGHTED:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
      }
      val +=_shift * _instrument.GetPipSize();
      return true;
   }
};
// Averages v. 1.0
enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   ma_lwma,    // Linear weighted moving average - LWMA
   ma_vwma,    // Volume weighted moving average - VWMA
};

class AveragesStreamFactory
{
public:
   static IStream *Create(IStream *source, const int length, const MATypes type)
   {
      switch (type)
      {
         case ma_sma:
            return new SmaOnStream(source, length);
         case ma_ema:
            return new EmaOnStream(source, length);
         case ma_lwma:
            return new LwmaOnStream(source, length);
         case ma_vwma:
            return new VwmaOnStream(source, length);
      }
      return NULL;
   }
};

class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
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

class LwmaOnStream : public IStream
{
   IStream *_source;
   int _length;
public:
   LwmaOnStream(IStream *source, const int length)
   {
      _source = source;
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

class VwmaOnStream : public IStream
{
   IStream *_source;
   int _length;
public:
   VwmaOnStream(IStream *source, const int length)
   {
      _source = source;
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

class EmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   double _alpha;
public:
   EmaOnStream(IStream *source, const int length)
   {
      _source = source;
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
      _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (price - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

class MeanDevStream : public IStream
{
   IStream *_source;
   int _length;
   IStream *_avg;
public:
   MeanDevStream(IStream *source, const int length, const MATypes maType)
   {
      _source = source;
      _length = length;
      _avg = AveragesStreamFactory::Create(_source, _length, maType);
   }

   ~MeanDevStream()
   {
      delete _avg;
   }

   bool GetValue(const int period, double &val)
   {
      double avg;
      if (!_avg.GetValue(period, avg))
         return false;
      double summ = 0;
      for (int i = 0; i < _length; i++)
      {
         double price;
         if (!_source.GetValue(period + i, price))
            return false;
         summ += MathAbs(price - avg);
      }
      val = summ / _length;
      return true;
   }
};

IStream *priceSource_1;
IStream *smoothing_1;
IStream *meanDev_1;
IStream *priceSource_2;
IStream *smoothing_2;
IStream *meanDev_2;

int init()
{
   IndicatorName = GenerateIndicatorName("CCI Mod x2");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out2);

   priceSource_1 = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PRICE_TYPICAL);
   smoothing_1 = new VwmaOnStream(priceSource_1, SmoothingPeriod_1);
   meanDev_1 = new MeanDevStream(priceSource_1, DevLength_1, ma_vwma);
   priceSource_2 = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PRICE_TYPICAL);
   smoothing_2 = new VwmaOnStream(priceSource_2, SmoothingPeriod_2);
   meanDev_2 = new MeanDevStream(priceSource_2, DevLength_2, ma_vwma);
   
   return(0);
}

int deinit()
{
   delete priceSource_1;
   delete smoothing_1;
   delete meanDev_1;
   delete priceSource_2;
   delete smoothing_2;
   delete meanDev_2;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      double priceValue;
      double maValue;
      double meanDevValue;
      if (priceSource_1.GetValue(pos, priceValue) && smoothing_1.GetValue(pos, maValue) && meanDev_1.GetValue(pos, meanDevValue))
      {
         out1[pos] = (priceValue - maValue) / (Constant_1 * meanDevValue);
      }
      if (show_second && priceSource_2.GetValue(pos, priceValue) && smoothing_2.GetValue(pos, maValue) && meanDev_2.GetValue(pos, meanDevValue))
      {
         out2[pos] = (priceValue - maValue) / (Constant_2 * meanDevValue);
      }
      pos--;
   } 
   return 0;
}

