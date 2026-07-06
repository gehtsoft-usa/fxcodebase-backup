// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71909

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


#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_label1 "Band_3"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Black
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Band_2"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Black
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Band_1"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Black
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Band_0"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Black
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Trend Type Oscillator"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

input bool useAtr = true; // Use ATR to detect Sideways Movements
input int atrLen = 14; // ATR Length
input string atrMaType = "SMA"; // ATR Moving Average Type
input int atrMaLen = 20; // ATR MA Length
input bool useAdx = true; // Use ADX to detect Sideways Movements
input int adxLen = 14; // ADX Smoothing
input int diLen = 14; // DI Length
input int adxLim = 25; // ADX Limit
input int smooth = 3; // Smoothing Factor
input int lag = 8; // Lag
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[];
string CreateTextObject(string id, datetime x, double y, string text, color clr)
{
   ResetLastError();
   string labelId = IndicatorObjPrefix + id;
   if (ObjectFind(0, labelId) == -1 && ObjectCreate(0, labelId, OBJ_TEXT, 0, x, y))
   {
      ObjectSetString(0, labelId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, labelId, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, labelId, OBJPROP_COLOR, clr);
   }
   ObjectSetInteger(0, labelId, OBJPROP_TIME, x);
   ObjectSetDouble(0, labelId, OBJPROP_PRICE1, y);
   ObjectSetString(0, labelId, OBJPROP_TEXT, text);
   return labelId;
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

// Average true range stream v2.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
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
IStream* atr1;
CustomStream* ema2Source;
IStream* ema2;
CustomStream* sma3Source;
IStream* sma3;
SimplePriceStream* change4Source;
IStream* change4;
SimplePriceStream* change5Source;
IStream* change5;
IStream* tr6;
IStream* rma7;
CustomStream* rma8Source;
IStream* rma8;
CustomStream* fixnan9X;
IStream* fixnan9;
CustomStream* rma10Source;
IStream* rma10;
CustomStream* fixnan11X;
IStream* fixnan11;
CustomStream* rma12Source;
IStream* rma12;
CustomStream* sma13Source;
IStream* sma13;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Trend Type Indicator by BobRivera990");
   IndicatorShortName("Trend Type Indicator by BobRivera990");
   IndicatorBuffers(5);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   atr1 = new ATRStream(_Symbol, (ENUM_TIMEFRAMES)_Period, atrLen);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, atrMaLen);
   sma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, atrMaLen);
   change4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   change4 = new ChangeStream(change4Source, 1);
   change5Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   change5 = new ChangeStream(change5Source, 1);
   tr6 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma7 = new RmaOnStream(tr6, diLen);
   rma8Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma8 = new RmaOnStream(rma8Source, diLen);
   fixnan9X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan9 = new FixnanStream(fixnan9X);
   rma10Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma10 = new RmaOnStream(rma10Source, diLen);
   fixnan11X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan11 = new FixnanStream(fixnan11X);
   rma12Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma12 = new RmaOnStream(rma12Source, adxLen);
   sma13Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma13 = new SmaOnStream(sma13Source, smooth);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   atr1.Release();
   ema2Source.Release();
   ema2.Release();
   sma3Source.Release();
   sma3.Release();
   change4Source.Release();
   change4.Release();
   change5Source.Release();
   change5.Release();
   tr6.Release();
   rma7.Release();
   rma8Source.Release();
   rma8.Release();
   fixnan9X.Release();
   fixnan9.Release();
   rma10Source.Release();
   rma10.Release();
   fixnan11X.Release();
   fixnan11.Release();
   rma12Source.Release();
   rma12.Release();
   sma13Source.Release();
   sma13.Release();
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
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value))
      {
         continue;
      }
      double atr = atr1Value;
      ema2Source.SetValue(pos, atr);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value))
      {
         continue;
      }
      sma3Source.SetValue(pos, atr);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value))
      {
         continue;
      }
      double atrMa = ((atrMaType == "EMA") ? ema2Value : sma3Value);
      double change4Value;
      if (!change4.GetValue(pos, change4Value))
      {
         continue;
      }
      double up = change4Value;
      double change5Value;
      if (!change5.GetValue(pos, change5Value))
      {
         continue;
      }
      double down = (-change5Value);
      double plusDM = ((up) == EMPTY_VALUE ? EMPTY_VALUE : ((((up > down) && (up > 0)) ? up : 0)));
      double minusDM = ((down) == EMPTY_VALUE ? EMPTY_VALUE : ((((down > up) && (down > 0)) ? down : 0)));
      double rma7Value;
      if (!rma7.GetValue(pos, rma7Value))
      {
         continue;
      }
      double trur = rma7Value;
      rma8Source.SetValue(pos, plusDM);
      double rma8Value;
      if (!rma8.GetValue(pos, rma8Value))
      {
         continue;
      }
      fixnan9X.SetValue(pos, 100 * rma8Value / trur);
      double fixnan9Value;
      if (!fixnan9.GetValue(pos, fixnan9Value))
      {
         continue;
      }
      double plus = fixnan9Value;
      rma10Source.SetValue(pos, minusDM);
      double rma10Value;
      if (!rma10.GetValue(pos, rma10Value))
      {
         continue;
      }
      fixnan11X.SetValue(pos, 100 * rma10Value / trur);
      double fixnan11Value;
      if (!fixnan11.GetValue(pos, fixnan11Value))
      {
         continue;
      }
      double minus = fixnan11Value;
      double sum = plus + minus;
      rma12Source.SetValue(pos, MathAbs(plus - minus) / (((sum == 0) ? 1 : sum)));
      double rma12Value;
      if (!rma12.GetValue(pos, rma12Value))
      {
         continue;
      }
      int adx = 100 * rma12Value;
      bool cndNa = (((((atr) == EMPTY_VALUE || (adx) == EMPTY_VALUE) || (plus) == EMPTY_VALUE) || (minus) == EMPTY_VALUE) || (atrMaLen) == EMPTY_VALUE);
      bool cndSidwayss1 = (useAtr && (atr <= atrMa));
      bool cndSidwayss2 = (useAdx && (adx <= adxLim));
      bool cndSidways = (cndSidwayss1 || cndSidwayss2);
      bool cndUp = (plus > minus);
      bool cndDown = (minus >= plus);
      int trendType = (cndNa ? EMPTY_VALUE : (cndSidways ? 0 : (cndUp ? 2 : (-2))));
      sma13Source.SetValue(pos, trendType);
      double sma13Value;
      if (!sma13.GetValue(pos, sma13Value))
      {
         continue;
      }
      double smoothType = ((trendType) == EMPTY_VALUE ? EMPTY_VALUE : MathRound(sma13Value / 2) * 2);
      color colGreen30 = Green;
      color colGreen90 = Green;
      color colGray = Gray;
      color colWhite90 = White;
      color colRed30 = Red;
      color colRed90 = Red;
      double band3 = plot1[pos] = 3;
      double band2 = plot2[pos] = 1;
      double band1 = plot3[pos] = (-1);
      double band0 = plot4[pos] = (-3);
      string lblUp = EMPTY_VALUE;
      ObjectDelete(lblUp);
      lblUp = CreateTextObject("label_1_id", time[pos], 2, "UP", Black);
      string lblSideways = EMPTY_VALUE;
      ObjectDelete(lblSideways);
      lblSideways = CreateTextObject("label_2_id", time[pos], 0, "SIDEWAYS", Black);
      string lblDown = EMPTY_VALUE;
      ObjectDelete(lblDown);
      lblDown = CreateTextObject("label_3_id", time[pos], (-2), "DOWN", Black);
      string lblCurrentType = EMPTY_VALUE;
      ObjectDelete(lblCurrentType);
      lblCurrentType = CreateTextObject("label_4_id", time[pos], smoothType, "", Blue);
      color trendCol = ((smoothType == 2) ? colGreen30 : ((smoothType == 0) ? colGray : colRed30));
      plot5[pos + lag] = smoothType;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
