// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72125

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_label1 "Zero line"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x888888
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Volume"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 0x65D25B
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "A/D Volume"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 0x92df8b
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "A/D moving average"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x4477ff
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Volume moving average"
#property indicator_type5 DRAW_LINE
#property indicator_color5 0xff9900
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Dummy"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

input int height = 100; // Height in % (useful if overlayed on the main chart)
input bool base_enable = false; // Baseline chart
input string aggregation = "smoothed MA"; // Aggregation
input int len = 14; // Moving average length
input bool price_enable = false; // Show money volume (price x volume)
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[];
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
class maStream
{
   IStream* s;
   CustomStream* sma1Source;
   IStream* sma1;
   CustomStream* rma1Source;
   IStream* rma1;
public:
   maStream(IStream* s)
   {
      sma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, len);
      rma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rma1 = new RmaOnStream(rma1Source, len);
      this.s = s;
      s.AddRef();
   }
   ~maStream()
   {
      s.Release();
      sma1Source.Release();
      sma1.Release();
      rma1Source.Release();
      rma1.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      if ((aggregation != "disable"))
      {
         double out;
         if ((aggregation == "simple MA"))
         {
            double sValue;
            if (!s.GetValue(period, sValue))
            {
               return false;
            }
            sma1Source.SetValue(period, sValue);
            double sma1Value;
            if (!sma1.GetValue(period, sma1Value))
            {
               return false;
            }
            out = sma1Value;
         }
         else
         {
            double sValue;
            if (!s.GetValue(period, sValue))
            {
               return false;
            }
            rma1Source.SetValue(period, sValue);
            double rma1Value;
            if (!rma1.GetValue(period, rma1Value))
            {
               return false;
            }
            out = rma1Value;
         };
         __out1 = out;
      }
      else
      {
         __out1 = EMPTY_VALUE;
      }
      return true;
   }
};
double nzfloat(double val, double replacement = 0)
{
   return val == EMPTY_VALUE ? replacement : val;
}
double Sign(double val)
{
   if (val == 0)
   {
      return 0;
   }
   return val > 0 ? 1 : -1;
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

// True range stream v2.1

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
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));

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
IStream* tr1;
// Simple price stream v1.0

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


// Change stream v1.0

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
SimplePriceStream* change1Source;
IStream* change1;
CustomStream* cum1X;
IStream* cum1;
CustomStream* maFunc1param1;
maStream* maFunc1;
CustomStream* cum2X;
IStream* cum2;
CustomStream* maFunc2param1;
maStream* maFunc2;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ADV [cI8DH]");
   IndicatorShortName("Accumulation/Distribution Volume (ADV) [cI8DH]");
   IndicatorBuffers(6);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   change1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   change1 = new ChangeStream(change1Source, 1);
   cum1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum1 = new CumOnStream(cum1X);
   maFunc1param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   maFunc1 = new maStream(maFunc1param1);
   cum2X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum2 = new CumOnStream(cum2X);
   maFunc2param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   maFunc2 = new maStream(maFunc2param1);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   tr1.Release();
   change1Source.Release();
   change1.Release();
   cum1X.Release();
   cum1.Release();
   maFunc1param1.Release();
   delete maFunc1;
   cum2X.Release();
   cum2.Release();
   maFunc2param1.Release();
   delete maFunc2;
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
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
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
      double change1Value;
      if (!change1.GetValue(pos, change1Value))
      {
         continue;
      }
      double ch = change1Value;
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value))
      {
         continue;
      }
      double AD_ratio = nzfloat(ch / tr1Value);
      double base;
      if (base_enable)
      {
         base = Sign(AD_ratio);
      }
      else
      {
         base = 1;
      }
      double vol;
      if (price_enable)
      {
         vol = tick_volume[pos] * (high[pos] + low[pos] + close[pos]) / 3;
      }
      else
      {
         vol = tick_volume[pos];
      }
      double base_price_vol = base * vol;
      double base_AD = base_price_vol * MathAbs(AD_ratio);
      double MA_base_price_vol;
      if ((aggregation == "cumulative"))
      {
         cum1X.SetValue(pos, Sign(AD_ratio) * vol);
         double cum1Value;
         if (!cum1.GetValue(pos, cum1Value))
         {
            continue;
         }
         MA_base_price_vol = cum1Value;
      }
      else
      {
         maFunc1param1.SetValue(pos, base_price_vol);
         double maFunc1Value;
         if (!maFunc1.GetValue(pos, maFunc1Value))
         {
            continue;
         }
         MA_base_price_vol = maFunc1Value;
      }
      double MA_AD;
      if ((aggregation == "cumulative"))
      {
         cum2X.SetValue(pos, AD_ratio * vol);
         double cum2Value;
         if (!cum2.GetValue(pos, cum2Value))
         {
            continue;
         }
         MA_AD = cum2Value;
      }
      else
      {
         maFunc2param1.SetValue(pos, base_AD);
         double maFunc2Value;
         if (!maFunc2.GetValue(pos, maFunc2Value))
         {
            continue;
         }
         MA_AD = maFunc2Value;
      }
      plot1[pos] = ((aggregation == "cumulative") ? EMPTY_VALUE : 0);
      plot2[pos] = ((aggregation == "cumulative") ? EMPTY_VALUE : base_price_vol);
      plot3[pos] = ((aggregation == "cumulative") ? EMPTY_VALUE : base_AD);
      plot4[pos] = MA_AD;
      plot5[pos] = MA_base_price_vol;
      plot6[pos] = (((height == 100) || (aggregation == "cumulative")) ? EMPTY_VALUE : (100.0 / height) * base_price_vol);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
