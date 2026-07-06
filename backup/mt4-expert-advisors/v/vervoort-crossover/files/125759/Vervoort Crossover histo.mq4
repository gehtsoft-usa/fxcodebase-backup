// Id: 24696
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68340

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
#property version   "1.1"
#property strict
//#property copyright "© mladen, 2018"
//#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1  "Crossover state"
#property indicator_color1  clrMediumSeaGreen
#property indicator_color2  clrOrangeRed
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1

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
};
input int   inpPeriod1 = 55;           // Fast tema period
input PriceType inpPrice1  = PriceTypical;   // Fast tema price
input int   inpPeriod2 = 55;           // Slow tema period
input PriceType inpPrice2  = PriceAverage; // Slow tema price
double val1[], val2[], valf[], vals[];

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

// Instrument info v.1.3
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
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

// Stream v.1.2
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
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType price)
      :AStream(symbol, timeframe)
   {
      _price = price;
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
      }
      val +=_shift * _instrument.GetPipSize();
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
      
      if (period > totalBars - 1 || period < 0)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (bufferIndex == 0)
         _buffer[bufferIndex] = price;
      else
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (price - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

class TemaOnStream : public IStream
{
   EmaOnStream *_ema1;
   EmaOnStream *_ema2;
   EmaOnStream *_ema3;
public:
   TemaOnStream(IStream *source, const int length)
   {
      _ema1 = new EmaOnStream(source, length);
      _ema2 = new EmaOnStream(_ema1, length);
      _ema3 = new EmaOnStream(_ema2, length);
   }

   ~TemaOnStream()
   {
      delete _ema3;
      delete _ema2;
      delete _ema1;
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

class ZeroLagTEMAOnStream : public IStream
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

   bool GetValue(const int period, double &val)
   {
      double tema1, tema2;
      if (!_tema1.GetValue(period, tema1) || !_tema2.GetValue(period, tema2))
         return false;

      val = (2.0 * tema1 - tema2);
      return true;
   }
};

ZeroLagTEMAOnStream *fastTema;
ZeroLagTEMAOnStream *slowTema;
IStream *fastSource;
IStream *slowSource;

int OnInit()
{
   IndicatorName = GenerateIndicatorName("Vervoort crossover");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);
   SetIndexBuffer(0, val1);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1, val2);
   SetIndexStyle(1, DRAW_HISTOGRAM);

   SetIndexBuffer(2, valf);
   SetIndexBuffer(3, vals);
   fastSource = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, inpPrice1);
   slowSource = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, inpPrice2);
   fastTema = new ZeroLagTEMAOnStream(fastSource, inpPeriod1);
   slowTema = new ZeroLagTEMAOnStream(slowSource, inpPeriod2);

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete fastTema;
   delete slowTema;
   delete fastSource;
   delete slowSource;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int start()
{
   if (Bars <= 1) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return(-1);
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int i = limit;
   while (i >= 0)
   {
      double valfVal, valsVal;
      if (!fastTema.GetValue(i, valfVal) || !slowTema.GetValue(i, valsVal))
      {
         --i;
         continue;
      }
      valf[i] = valfVal;
      vals[i] = valsVal;
      if (valf[i] > vals[i])
      {
         val2[i] = 1;
         val1[i] = EMPTY_VALUE;
      }
      else if (valf[i] < vals[i])
      {
         val1[i] = 1;
         val2[i] = EMPTY_VALUE;
      }
      else if (i < Bars - 1)
      {
         val1[i] = val1[i + 1];
         val2[i] = val2[i + 1];
      }
      --i;
   }
   return(i);
}
