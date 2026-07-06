// Id: 24695
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

// Trading arrows template v.1.1

//1. Implement int GetDirection(
//2. place your parameters here

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"
#property indicator_label3 "EXIT BUY"
#property indicator_label4 "EXIT SELL"

#property indicator_label5  "Fast TEMA"
#property indicator_color5  clrMediumSeaGreen
#property indicator_label6  "Fast TEMA"
#property indicator_color6  clrOrangeRed
#property indicator_label7  "Slow TEMA"
#property indicator_color7  clrMediumSeaGreen
#property indicator_label8  "Slow TEMA"
#property indicator_color8  clrOrangeRed

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

double buy[], sell[], exit_buy[], exit_sell[], trend[], valf1[], valf2[], vals1[], vals2[];

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

int init()
{
   IndicatorName = GenerateIndicatorName("Vervoort Crossover extended");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(9);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   SetIndexStyle(2, DRAW_ARROW, 0, 2);
   SetIndexArrow(2, 217);
   SetIndexBuffer(2, exit_buy);
   SetIndexStyle(3, DRAW_ARROW, 0, 2);
   SetIndexArrow(3, 218);
   SetIndexBuffer(3, exit_sell);
   SetIndexBuffer(4, valf1);
   SetIndexBuffer(5, valf2);
   SetIndexBuffer(6, vals1);
   SetIndexBuffer(7, vals2);
   SetIndexBuffer(8, trend);
   fastSource = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, inpPrice1);
   slowSource = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, inpPrice2);
   fastTema = new ZeroLagTEMAOnStream(fastSource, inpPeriod1);
   slowTema = new ZeroLagTEMAOnStream(slowSource, inpPeriod2);
   
   return(0);
}

int deinit()
{
   delete fastTema;
   delete slowTema;
   delete fastSource;
   delete slowSource;

   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

int GetDirection(const int period)
{
   if (period >= Bars - 1)
      return 0;
   if (trend[period] == 1 && trend[period + 1] != 1)
      return ENTER_BUY_SIGNAL;
   if (trend[period] == 2 && trend[period + 1] != 2)
      return ENTER_SELL_SIGNAL;
   return 0;
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
      double valf, vals;
      if (!fastTema.GetValue(i, valf) || !slowTema.GetValue(i, vals))
      {
         --i;
         continue;
      }
      if (valf > vals)
         trend[i] = 1;
      else if (valf < vals)
         trend[i] = 2;
      else if (i < Bars - 1)
         trend[i] = trend[i + 1];
      if (trend[i] == 1)
      {
         valf1[i] = valf;
         vals1[i] = vals;
         valf2[i] = EMPTY_VALUE;
         vals2[i] = EMPTY_VALUE;
         if (i < Bars - 1 && trend[i + 1] != 1)
         {
            valf1[i + 1] = valf2[i + 1];
            vals1[i + 1] = vals2[i + 1];
         }
      }
      else
      {
         valf2[i] = valf;
         vals2[i] = vals;
         valf1[i] = EMPTY_VALUE;
         vals1[i] = EMPTY_VALUE;
         if (i < Bars - 1 && trend[i + 1] != 2)
         {
            valf2[i + 1] = valf1[i + 1];
            vals2[i + 1] = vals1[i + 1];
         }
      }
      int direction = GetDirection(i);
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            buy[i] = Low[i];
            sell[i] = EMPTY_VALUE;
            exit_sell[i] = EMPTY_VALUE;
            exit_buy[i] = EMPTY_VALUE;
            break;
         case ENTER_SELL_SIGNAL:
            buy[i] = EMPTY_VALUE;
            sell[i] = High[i];
            exit_sell[i] = EMPTY_VALUE;
            exit_buy[i] = EMPTY_VALUE;
            break;
         case EXIT_BUY_SIGNAL:
            buy[i] = EMPTY_VALUE;
            sell[i] = EMPTY_VALUE;
            exit_sell[i] = EMPTY_VALUE;
            exit_buy[i] = Low[i];
            break;
         case EXIT_SELL_SIGNAL:
            buy[i] = EMPTY_VALUE;
            sell[i] = EMPTY_VALUE;
            exit_sell[i] = High[i];
            exit_buy[i] = EMPTY_VALUE;
            break;
      }
      --i;
   }
   return(i);
}

