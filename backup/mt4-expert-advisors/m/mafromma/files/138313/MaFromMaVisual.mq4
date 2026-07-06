// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70541

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#include <Canvas\iCanvas.mqh> //https://www.mql5.com/ru/code/22164

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

enum PriceType
{
   PriceClose = PRICE_CLOSE,       // Close
   PriceOpen = PRICE_OPEN,         // Open
   PriceHigh = PRICE_HIGH,         // High
   PriceLow = PRICE_LOW,           // Low
   PriceMedian = PRICE_MEDIAN,     // Median
   PriceTypical = PRICE_TYPICAL,   // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody,                // Median (body)
   PriceAverage,                   // Average
   PriceTrendBiased,               // Trend biased
   PriceVolume,                    // Volume
};

enum MATypes
{
   ma_sma, // Simple moving average - SMA
   ma_ema, // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   ma_tema, // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma, // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma, // Volume weighted moving average - VWMA
   //ma_hull,    // Hull moving average
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   ma_zlma, // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo,     // Smoother,
   ma_zltema, // Zero lag TEMA
   ma_rma     // RMA
};

input int per = 5;                  // initial MA period
input int per2 = 10;                // MA period, which is taken from the initial MA
input int Nr = 5;                    // how many times to apply?
input PriceType price = PriceClose; // Price
input MATypes method = ma_sma;      // Method
input int InpShift = 0;             // Indicator's shift

input int bars_limit = 200; // Bars limit

// Averages stream factory v1.0

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
       : AOnStream(source)
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
         for (int i = 0; i < _length; i++)
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
       : AOnStream(source)
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
      for (int i = 1; i < _length; i++)
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
       : AOnStream(source)
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
       : AOnStream(source)
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
       : AOnStream(source)
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
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

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

class PriceStream : public AStream
{
   PriceType _price;

public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
       : AStream(symbol, timeframe)
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

IStream *stream;
double mama[];
int Per1, Per2;
int line=0;
uchar tr=0;
int N,xp1,xp2,xN,xS, Shift;

int init()
{
   Shift=InpShift;
   Per1 = per;
   Per2 = per2;
   delete Canvas;
   Canvas = new iCanvas(0, 0, 0, "iCanvas", 0, 120);
   IndicatorObjPrefix = GenerateIndicatorPrefix("mafma");
   IndicatorShortName("MA From MA");

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, mama);
   SetIndexLabel(0, "MA on MA");
   SetIndexShift(0, InpShift);
   xp1=int(MathLog(per)/MathLog(1.017));
   xp2=int(MathLog(per2)/MathLog(1.017));
   N=Nr;
   xN=N*4;

   CreateStreams(per, per2, N);

   return INIT_SUCCEEDED;
}

void CreateStreams(int period1, int period2, int _N)
{
   pre_per1 = period1;
   pre_per2 = period2;
   pre_N = _N;
   if (stream != NULL)
   {
      stream.Release();
   }
   stream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, price);
   IStream *ma = AveragesStreamFactory::Create(stream, period1, method);
   stream.Release();
   stream = ma;
   for (int i = 0; i < _N; ++i)
   {
      ma = AveragesStreamFactory::Create(stream, period2, method);
      stream.Release();
      stream = ma;
   }
}

int deinit()
{
   stream.Release();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

bool recalc;

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
   if (prev_calculated <= 0 || prev_calculated > rates_total || recalc)
   {
      ArrayInitialize(mama, EMPTY_VALUE);
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
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(recalc ? 0 : prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double val;
      if (stream.GetValue(pos, val))
      {
         mama[pos] = val;
      }
   }
   recalc = false;

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   static string pre_sparam = sparam;
   if (id == CHARTEVENT_MOUSE_MOVE && line == 0)
   {
      DrawSetup();
   }
   if (sparam == "0" && pre_sparam != "0")
   {
      line = 0;
      ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   }
   int S = W.Width / 2 - 199;
   if (tr > 253 && pre_sparam == "0" && sparam == "1")
   {
      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      if (Delta(S + xp1, 30) < 50)
         line = 1;
      else if (Delta(S + xp2, 50) < 50)
         line = 2;
      else if (Delta(S + xN, 70) < 50)
         line = 3;
      else if (Delta(S + xS, 90) < 50)
         line = 4;
      else
         line = 0;
   }
   if (line == 1)
   {
      xp1 = W.MouseX - S;
      if (xp1 < 1)
         xp1 = 1;
      if (xp1 > 399)
         xp1 = 399;
      Per1 = 1 + (int)pow(1.017, xp1);
      DrawSetup();
   }
   else if (line == 2)
   {
      xp2 = W.MouseX - S;
      if (xp2 < 1)
         xp2 = 1;
      if (xp2 > 399)
         xp2 = 399;
      Per2 = 1 + (int)pow(1.017, xp2);
      DrawSetup();
   }
   else if (line == 3)
   {
      xN = W.MouseX - S;
      if (xN < 1)
         xN = 1;
      if (xN > 399)
         xN = 399;
      N = xN / 4;
      DrawSetup();
   }
   else if (line == 4)
   {
      xS = W.MouseX - S;
      if (xS < 0)
         xS = 0;
      if (xS > 399)
         xS = 399;
      Shift = -xS * 2;
      DrawSetup();
   }
   pre_sparam = sparam;
}
int n;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int pre_per1;
int pre_per2;
int pre_N;
void DrawSetup()
{
   static int pre_shift = Shift;
   static int pre_tr = -1;
   int C = W.Width / 2;
   int h = W.MouseY - 70;
   int w = fabs(W.MouseX - C);
   int t = 255;
   if (w < 207)
      t = int(255 * (1 - (h - 30) / 100.0));
   else
      t = int(255 * (1 - (w - 207) / 50.0));
   if (t > 255)
      t = 255;
   tr = (uchar)t;
   if (h > 130 || w > 257)
   {
      if (tr != 0)
      {
         Canvas.Erase();
         Canvas.Update();
         tr = 0;
      }
      return;
   }
   if (N != pre_N || Per1 != pre_per1 || Per2 != pre_per2)
   {
      n = Per1 + (Per2 - 1) * N;
      if (pre_shift != Shift)
      {
         SetIndexShift(0, Shift);
         pre_shift = Shift;
      }
      else
      {
         IndicatorSetString(INDICATOR_SHORTNAME, "MaFromMa(" + string(Per1) + "," + string(Per2) + "," + string(N) + " times,real period-" + string(n) + ")");
         CreateStreams(Per1, Per2, N);
         pre_per1 = Per1;
         pre_per2 = Per2;
         pre_N = N;
         recalc = true;
      }
   }
   else if (pre_tr == tr && line == 0)
      return;
   pre_tr = tr;
   uint clrLine = ColorToARGB(0xFF808080, tr);
   uint clrCir = ColorToARGB(0xFFDD8080, tr);
   Canvas.Erase();
   Canvas.TextPosX = C - 260;
   Canvas.TextPosY = 17;
   Canvas.StepTextLine = 20;
   Canvas.CurentFont("Century Gothic", 18, 20, ~W.Color, tr / 255.0);
   Canvas.Comm("Period 1");
   Canvas.Comm("Period 2");
   Canvas.Comm("N");
   Canvas.Comm("Shift");
   Canvas.FillRectangle(C - 199, 30, C + 200, 30, clrLine);
   Canvas.FillRectangle(C - 199, 50, C + 200, 50, clrLine);
   Canvas.FillRectangle(C - 199, 70, C + 200, 70, clrLine);
   Canvas.FillRectangle(C - 199, 90, C + 200, 90, clrLine);
   Canvas.FillCircle(C - 199 + xp1, 30, 7, clrCir);
   Canvas.FillCircle(C - 199 + xp2, 50, 7, clrCir);
   Canvas.FillCircle(C - 199 + xN, 70, 7, clrCir);
   Canvas.FillCircle(C - 199 + xS, 90, 7, clrCir);
   Canvas.TextPosY = 12;
   Canvas.TextPosX = C - 190 + xp1;
   Canvas.Comm(string(Per1));
   Canvas.TextPosX = C - 190 + xp2;
   Canvas.Comm(string(Per2));
   Canvas.TextPosX = C - 190 + xN;
   Canvas.Comm(string(N));
   Canvas.TextPosX = C - 190 + xS;
   Canvas.Comm(string(Shift));
   Canvas.TextPosY = 100;
   Canvas.TextPosX = C - 100;
   Canvas.Comm("Real period = " + string(n));
   Canvas.Update();
}
//+------------------------------------------------------------------+

int Delta(int x, int y) { return (x - W.MouseX) * (x - W.MouseX) + (y - W.MouseY) * (y - W.MouseY); }
//+------------------------------------------------------------------+
