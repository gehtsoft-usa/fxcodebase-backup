//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73911

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_label1 "Long"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Short"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

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
input PriceType source = PriceClose; // Source
input int per1 = 27; // Fast period
input double mult1 = 1.6; // Fast range
input int per2 = 55; // Slow period
input double mult2 = 2; // Slow range
input int bars_limit = 100000; // Bars limit
double filt[], upward[], downward[], CondIni[];
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
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};



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
class smoothrngStream
{
   int t;
   double m;
   IStream* x;
   CustomStream* ema1Source;
   IStream* ema1;
   CustomStream* ema2Source;
   IStream* ema2;
public:
   smoothrngStream(int t, double m, IStream* x)
   {
      int wper = t * 2 - 1;
      ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, t);
      ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, wper);
      this.t = t;
      this.m = m;
      this.x = x;
      x.AddRef();
   }
   ~smoothrngStream()
   {
      x.Release();
      ema1Source.Release();
      ema1.Release();
      ema2Source.Release();
      ema2.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double xValue;
      if (!x.GetValue(period, xValue))
      {
         return false;
      }
      double xValue_1;
      if (!x.GetValue(period + 1, xValue_1))
      {
         return false;
      }
      ema1Source.SetValue(period, MathAbs(xValue - xValue_1));
      double ema1Value;
      if (!ema1.GetValue(period, ema1Value))
      {
         return false;
      }
      double avrng = ema1Value;
      ema2Source.SetValue(period, avrng);
      double ema2Value;
      if (!ema2.GetValue(period, ema2Value))
      {
         return false;
      }
      double smoothrng = ema2Value * m;
      __out1 = smoothrng;
      return true;
   }
};
class rngfiltStream
{
   IStream* x;
   IStream* r;
   CustomStream* rngfilt;
public:
   rngfiltStream(IStream* x, IStream* r)
   {
      this.x = x;
      x.AddRef();
      this.r = r;
      r.AddRef();
      rngfilt = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~rngfiltStream()
   {
      x.Release();
      r.Release();
      rngfilt.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double xValue;
      if (!x.GetValue(period, xValue))
      {
         return false;
      }
      rngfilt.SetValue(period, xValue);
      double rngfiltValue_1;
      if (!rngfilt.GetValue(period + 1, rngfiltValue_1))
      {
         return false;
      }
      double rValue;
      if (!r.GetValue(period, rValue))
      {
         return false;
      }
      rngfilt.SetValue(period, ((xValue > nzfloat(rngfiltValue_1)) ? ((xValue - rValue < nzfloat(rngfiltValue_1)) ? nzfloat(rngfiltValue_1) : xValue - rValue) : ((xValue + rValue > nzfloat(rngfiltValue_1)) ? nzfloat(rngfiltValue_1) : xValue + rValue)));
      double rngfiltValue;
      if (!rngfilt.GetValue(period, rngfiltValue))
      {
         return false;
      }
      __out1 = rngfiltValue;
      return true;
   }
};
double nzfloat(double val, double replacement = 0)
{
   return val == EMPTY_VALUE ? replacement : val;
}

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

// Simple price stream v1.0

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
SimplePriceStream* sourceInputstream;
CustomStream* smoothrngFunc1param3;
smoothrngStream* smoothrngFunc1;
CustomStream* smoothrngFunc2param3;
smoothrngStream* smoothrngFunc2;
CustomStream* rngfiltFunc3param1;
CustomStream* rngfiltFunc3param2;
rngfiltStream* rngfiltFunc3;
double plot1[];
double plot2[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Twin Range Filter");
   IndicatorShortName("Twin Range Filter");
   IndicatorBuffers(6);
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id++, 233);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id++, 234);
   SetIndexBuffer(id++, filt);
   SetIndexBuffer(id++, upward);
   SetIndexBuffer(id++, downward);
   SetIndexBuffer(id++, CondIni);
   sourceInputstream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, source);
   smoothrngFunc1param3 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   smoothrngFunc1 = new smoothrngStream(per1, mult1, smoothrngFunc1param3);
   smoothrngFunc2param3 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   smoothrngFunc2 = new smoothrngStream(per2, mult2, smoothrngFunc2param3);
   rngfiltFunc3param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rngfiltFunc3param2 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rngfiltFunc3 = new rngfiltStream(rngfiltFunc3param1, rngfiltFunc3param2);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   sourceInputstream.Release();
   smoothrngFunc1param3.Release();
   delete smoothrngFunc1;
   smoothrngFunc2param3.Release();
   delete smoothrngFunc2;
   rngfiltFunc3param1.Release();
   rngfiltFunc3param2.Release();
   delete rngfiltFunc3;
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
      ArrayInitialize(filt, EMPTY_VALUE);
      ArrayInitialize(upward, EMPTY_VALUE);
      ArrayInitialize(downward, EMPTY_VALUE);
      ArrayInitialize(CondIni, EMPTY_VALUE);
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
      double sourceInputstreamValue;
      if (!sourceInputstream.GetValue(pos, sourceInputstreamValue))
      {
         continue;
      }
      smoothrngFunc1param3.SetValue(pos, sourceInputstreamValue);
      double smoothrngFunc1Value;
      if (!smoothrngFunc1.GetValue(pos, smoothrngFunc1Value))
      {
         continue;
      }
      double smrng1 = smoothrngFunc1Value;
      smoothrngFunc2param3.SetValue(pos, sourceInputstreamValue);
      double smoothrngFunc2Value;
      if (!smoothrngFunc2.GetValue(pos, smoothrngFunc2Value))
      {
         continue;
      }
      double smrng2 = smoothrngFunc2Value;
      double smrng = (smrng1 + smrng2) / 2;
      rngfiltFunc3param1.SetValue(pos, sourceInputstreamValue);
      rngfiltFunc3param2.SetValue(pos, smrng);
      double rngfiltFunc3Value;
      if (!rngfiltFunc3.GetValue(pos, rngfiltFunc3Value))
      {
         continue;
      }
      filt[pos] = rngfiltFunc3Value;
      upward[pos] = ((filt[pos] > filt[pos + 1]) ? nzfloat(upward[pos + 1]) + 1 : ((filt[pos] < filt[pos + 1]) ? 0 : nzfloat(upward[pos + 1])));
      downward[pos] = ((filt[pos] < filt[pos + 1]) ? nzfloat(downward[pos + 1]) + 1 : ((filt[pos] > filt[pos + 1]) ? 0 : nzfloat(downward[pos + 1])));
      double hband = filt[pos] + smrng;
      double lband = filt[pos] - smrng;
      double longCond = (bool)(EMPTY_VALUE);
      double shortCond = (bool)(EMPTY_VALUE);
      double sourceInputstreamValue_1;
      if (!sourceInputstream.GetValue(pos + 1, sourceInputstreamValue_1))
      {
         continue;
      }
      longCond = ((sourceInputstreamValue > filt[pos]) && ((sourceInputstreamValue > sourceInputstreamValue_1) && ((upward[pos] > 0) || ((sourceInputstreamValue > filt[pos]) && ((sourceInputstreamValue < sourceInputstreamValue_1) && (upward[pos] > 0))))));
      shortCond = ((sourceInputstreamValue < filt[pos]) && ((sourceInputstreamValue < sourceInputstreamValue_1) && ((downward[pos] > 0) || ((sourceInputstreamValue < filt[pos]) && ((sourceInputstreamValue > sourceInputstreamValue_1) && (downward[pos] > 0))))));
      CondIni[pos] = (longCond ? 1 : (shortCond ? (-1) : CondIni[pos + 1]));
      bool _long = (longCond && (CondIni[pos + 1] == (-1)));
      bool _short = (shortCond && (CondIni[pos + 1] == 1));
      if (_long)
         plot1[pos] = low[pos];
      if (_short)
         plot2[pos] = high[pos];
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
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+