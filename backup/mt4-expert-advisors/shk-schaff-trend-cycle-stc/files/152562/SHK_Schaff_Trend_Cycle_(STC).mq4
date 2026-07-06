//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74157

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1 "STC"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

input int EEEEEE = 12; // Length
input int BBBB = 26; // FastLength
input int BBBBB = 50; // SlowLength
input double AAA = 0.5;
input int bars_limit = 100000; // Bars limit
double mAAAAA[];
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
class AAAAStream
{
   int BBBB;
   int BBBBB;
   IStream* BBB;
   CustomStream* ta_ema1Source;
   IStream* ta_ema1;
   CustomStream* ta_ema2Source;
   IStream* ta_ema2;
public:
   AAAAStream(int BBBB, int BBBBB, IStream* BBB)
   {
      ta_ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_ema1 = new EMAOnStream(ta_ema1Source, BBBB);
      ta_ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_ema2 = new EMAOnStream(ta_ema2Source, BBBBB);
      this.BBBB = BBBB;
      this.BBBBB = BBBBB;
      this.BBB = BBB;
      BBB.AddRef();
   }
   ~AAAAStream()
   {
      BBB.Release();
      ta_ema1Source.Release();
      ta_ema1.Release();
      ta_ema2Source.Release();
      ta_ema2.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double BBBValue;
      if (!BBB.GetValue(period, BBBValue))
      {
         return false;
      }
      ta_ema1Source.SetValue(period, BBBValue);
      double ta_ema1Value;
      if (!ta_ema1.GetValue(period, ta_ema1Value))
      {
         return false;
      }
      double fastMA = ta_ema1Value;
      ta_ema2Source.SetValue(period, BBBValue);
      double ta_ema2Value;
      if (!ta_ema2.GetValue(period, ta_ema2Value))
      {
         return false;
      }
      double slowMA = ta_ema2Value;
      double AAAA = fastMA - slowMA;
      __out1 = AAAA;
      return true;
   }
};


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
// Simple price stream v1.2

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


// Lowest low stream v1.3

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }
};




// Highest high stream v1.3

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }
};
// Custom variable v1.0

class CustomVariable
{
   double _buffer[];
   int _lastIndex;
   int _rates_total;
public:
   CustomVariable()
   {
      _lastIndex = -1;
   }

   void Init(int period, int rates_total, double defaultValue)
   {
      _rates_total = rates_total;
      int pos = rates_total - period - 1;

      int size = ArraySize(_buffer);
      if (size != rates_total)
      {
         ArrayResize(_buffer, rates_total);
      }
      if (_lastIndex == -1)
      {
         for (int i = 0; i <= pos; ++i)
         {
            _buffer[i] = defaultValue;
         }
         _lastIndex = pos;
         return;
      }
      for (int i = _lastIndex + 1; i <= pos; ++i)
      {
         _buffer[i] = _buffer[i - 1];
      }
      _lastIndex = pos;
   }

   void SetValue(int period, double value)
   {
      int pos = _rates_total - period - 1;
      _buffer[pos] = value;
      _lastIndex = pos;
   }

   double Get(int period)
   {
      int pos = _rates_total - period - 1;
      return _buffer[pos];
   }
};

class AAAAAStream
{
   int EEEEEE;
   int BBBB;
   int BBBBB;
   CustomStream* ta_lowest1Source;
   IStream* ta_lowest1;
   CustomStream* ta_highest2Source;
   IStream* ta_highest2;
   CustomStream* ta_lowest3Source;
   IStream* ta_lowest3;
   CustomStream* ta_highest4Source;
   IStream* ta_highest4;
   CustomVariable* CCCCC;
   CustomVariable* DDD;
   CustomVariable* DDDDDD;
   CustomVariable* EEEEE;
   SimplePriceStream* AAAAFunc1param3;
   AAAAStream* AAAAFunc1;
public:
   AAAAAStream(int EEEEEE, int BBBB, int BBBBB)
   {

      CCCCC = new CustomVariable();
      DDD = new CustomVariable();
      DDDDDD = new CustomVariable();
      EEEEE = new CustomVariable();
      AAAAFunc1param3 = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
      AAAAFunc1 = new AAAAStream(BBBB, BBBBB, AAAAFunc1param3);
      this.EEEEEE = EEEEEE;
      this.BBBB = BBBB;
      this.BBBBB = BBBBB;
      ta_lowest1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_lowest1 = new LowestLowStream(ta_lowest1Source, EEEEEE);
      ta_highest2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_highest2 = new HighestHighStream(ta_highest2Source, EEEEEE);
      ta_lowest3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_lowest3 = new LowestLowStream(ta_lowest3Source, EEEEEE);
      ta_highest4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_highest4 = new HighestHighStream(ta_highest4Source, EEEEEE);
   }
   ~AAAAAStream()
   {
      ta_lowest1Source.Release();
      ta_lowest1.Release();
      ta_highest2Source.Release();
      ta_highest2.Release();
      ta_lowest3Source.Release();
      ta_lowest3.Release();
      ta_highest4Source.Release();
      ta_highest4.Release();
      delete CCCCC;
      delete DDD;
      delete DDDDDD;
      delete EEEEE;
      AAAAFunc1param3.Release();
      delete AAAAFunc1;
   }
   bool GetValue(const int period, double &__out1)
   {
      CCCCC.Init(period, iBars(_Symbol, (ENUM_TIMEFRAMES)_Period), 0.0);
      DDD.Init(period, iBars(_Symbol, (ENUM_TIMEFRAMES)_Period), 0.0);
      DDDDDD.Init(period, iBars(_Symbol, (ENUM_TIMEFRAMES)_Period), 0.0);
      EEEEE.Init(period, iBars(_Symbol, (ENUM_TIMEFRAMES)_Period), 0.0);
      double AAAAFunc1Value;
      if (!AAAAFunc1.GetValue(period, AAAAFunc1Value))
      {
         return false;
      }
      double BBBBBB = AAAAFunc1Value;
      ta_lowest1Source.SetValue(period, BBBBBB);
      double ta_lowest1Value;
      if (!ta_lowest1.GetValue(period, ta_lowest1Value))
      {
         return false;
      }
      double CCC = ta_lowest1Value;
      ta_highest2Source.SetValue(period, BBBBBB);
      double ta_highest2Value;
      if (!ta_highest2.GetValue(period, ta_highest2Value))
      {
         return false;
      }
      double CCCC = ta_highest2Value - CCC;
      CCCCC.SetValue(period, ((CCCC > 0) ? (BBBBBB - CCC) / CCCC * 100 : nzfloat(CCCCC.Get(period))));
      DDD.SetValue(period, ((DDD.Get(period)) == EMPTY_VALUE ? CCCCC.Get(period) : DDD.Get(period) + AAA * (CCCCC.Get(period) - DDD.Get(period))));
      ta_lowest3Source.SetValue(period, DDD.Get(period));
      double ta_lowest3Value;
      if (!ta_lowest3.GetValue(period, ta_lowest3Value))
      {
         return false;
      }
      double DDDD = ta_lowest3Value;
      ta_highest4Source.SetValue(period, DDD.Get(period));
      double ta_highest4Value;
      if (!ta_highest4.GetValue(period, ta_highest4Value))
      {
         return false;
      }
      double DDDDD = ta_highest4Value - DDDD;
      DDDDDD.SetValue(period, ((DDDDD > 0) ? (DDD.Get(period) - DDDD) / DDDDD * 100 : nzfloat(DDDDDD.Get(period))));
      EEEEE.SetValue(period, ((EEEEE.Get(period)) == EMPTY_VALUE ? DDDDDD.Get(period) : EEEEE.Get(period) + AAA * (DDDDDD.Get(period) - EEEEE.Get(period))));
      __out1 = EEEEE.Get(period);
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

AAAAAStream* AAAAAFunc1;
double plot1[];
double plot2[];
double plot3[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("STC");
   IndicatorShortName("[SHK] Schaff Trend Cycle (STC)");
   IndicatorBuffers(4);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, mAAAAA);
   AAAAAFunc1 = new AAAAAStream(EEEEEE, BBBB, BBBBB);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete AAAAAFunc1;
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
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(mAAAAA, EMPTY_VALUE);
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
      double AAAAAFunc1Value;
      if (!AAAAAFunc1.GetValue(pos, AAAAAFunc1Value))
      {
         continue;
      }
      mAAAAA[pos] = AAAAAFunc1Value;
      color mColor = ((mAAAAA[pos] > mAAAAA[pos + 1]) ? Green : Red);
      if ((((mAAAAA[pos + 3] <= mAAAAA[pos + 2]) && (mAAAAA[pos + 2] > mAAAAA[pos + 1])) && (mAAAAA[pos] > 75)))
      {
;
      }
      if ((((mAAAAA[pos + 3] >= mAAAAA[pos + 2]) && (mAAAAA[pos + 2] < mAAAAA[pos + 1])) && (mAAAAA[pos] < 25)))
      {
;
      }
      plot1[pos] = mAAAAA[pos];
      double ul = plot2[pos] = 25;
      double ll = plot3[pos] = 75;
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
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+