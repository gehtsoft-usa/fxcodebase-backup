// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71333

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Up"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Down"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

input string maType = "EMA"; // MA Type
input int maPeriod = 10; // MA Period
input ENUM_MA_METHOD ma_method = MODE_SMA; // Smoothing method
input string trendType = "Flexible"; // Trend Type
input bool showRange = true; // Show Ranges
input bool extend = false; // Extend Line
input int atrPeriod = 100; // ATR Period
input double atrMulti = 1; // ATR Multiplier
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[];
double upTrend[], upRange[], downTrend[], downRange[], up[], down[], upLine[], downLine[];

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

// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
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
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open, close;
               if (!_source.GetOpenClose(period, open, close))
               {
                  return false;
               }
               val = (open + close) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close + open) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               if (open > close)
                  val = (high + close) / 2.0;
               else
                  val = (low + close) / 2.0;
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
// Average true range stream v1.0

// True range stream v1.0



#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         return false;
      }
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));

      val = MathMax(lc, MathMax(hl, hc));
      return true;
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

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe);
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
IStream* atr1;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("T|R");
   IndicatorShortName("Trends & Ranges");
   IndicatorBuffers(11);
   SetIndexBuffer(0, plot1);
   SetIndexBuffer(1, plot2);
   SetIndexBuffer(2, plot3);
   SetIndexBuffer(3, upTrend);
   SetIndexBuffer(4, upRange);
   SetIndexBuffer(5, downTrend);
   SetIndexBuffer(6, downRange);
   SetIndexBuffer(7, up);
   SetIndexBuffer(8, down);
   SetIndexBuffer(9, upLine);
   SetIndexBuffer(10, downLine);
   atr1 = new ATRStream(_Symbol, (ENUM_TIMEFRAMES)_Period, atrPeriod);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   atr1.Release();
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
      ArrayInitialize(upTrend, EMPTY_VALUE);
      ArrayInitialize(upRange, EMPTY_VALUE);
      ArrayInitialize(downTrend, EMPTY_VALUE);
      ArrayInitialize(downRange, EMPTY_VALUE);
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(down, EMPTY_VALUE);
      ArrayInitialize(upLine, EMPTY_VALUE);
      ArrayInitialize(downLine, EMPTY_VALUE);
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
      double maHigh = iMA(_Symbol, _Period, maPeriod, 0, ma_method, PRICE_HIGH, pos);
      double maLow = iMA(_Symbol, _Period, maPeriod, 0, ma_method, PRICE_LOW, pos);
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value))
      {
         continue;
      }
      double atr = atr1Value * atrMulti;
      double minLow = maLow - atr;
      upTrend[pos] = EMPTY_VALUE;
      upTrend[pos] = ((trendType == "Flexible") ? minLow : (((close[pos + 1] > upTrend[pos + 1]) ? MathMax(minLow, upTrend[pos + 1]) : minLow)));
      double minHigh = maHigh - atr;
      upRange[pos] = EMPTY_VALUE;
      upRange[pos] = ((trendType == "Flexible") ? minHigh : (((close[pos + 1] > upRange[pos + 1]) ? MathMax(minHigh, upRange[pos + 1]) : minHigh)));
      double plusHigh = maHigh + atr;
      downTrend[pos] = EMPTY_VALUE;
      downTrend[pos] = ((trendType == "Flexible") ? plusHigh : (((close[pos + 1] < downTrend[pos + 1]) ? MathMin(plusHigh, downTrend[pos + 1]) : plusHigh)));
      double plusLow = maLow + atr;
      downRange[pos] = EMPTY_VALUE;
      downRange[pos] = ((trendType == "Flexible") ? plusLow : (((close[pos + 1] < downRange[pos + 1]) ? MathMin(plusLow, downRange[pos + 1]) : plusLow)));
      up[pos] = (((up[pos] != 1) && (close[pos] > ((showRange ? downRange[pos] : downTrend[pos])))) ? 1 : (((up[pos] == 1) && (close[pos] < upTrend[pos])) ? (-1) : up[pos]));
      down[pos] = (((down[pos] != 1) && (close[pos] < ((showRange ? upRange[pos] : upTrend[pos])))) ? 1 : (((down[pos] == 1) && (close[pos] > downTrend[pos])) ? (-1) : down[pos]));

      double plotSource = plot1[pos] = close[pos];
      bool startUp = ((up[pos] != up[pos + 1]) && (up[pos] == 1));
      double plotUp = plot2[pos] = ((up[pos] == 1) ? upTrend[pos] : EMPTY_VALUE);

      bool startDown = ((down[pos] != down[pos + 1]) && (down[pos] == 1));
      double plotDown = plot3[pos] = ((down[pos] == 1) ? downTrend[pos] : EMPTY_VALUE);

      plot1[pos] = close[pos];
      plot2[pos] = up[pos] == 1 ? upTrend[pos] : EMPTY_VALUE;
      plot3[pos] = down[pos] == 1 ? downTrend[pos] : EMPTY_VALUE;
      
      if (extend && up[pos] == 1)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + "upValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, time[pos + 1], upTrend[pos], time[pos], upTrend[pos]))
            {
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Yellow);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, upTrend[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, upTrend[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, time[pos + 1]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, time[pos]);
      }
      if (extend && down[pos] == 1)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + "downValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, time[pos + 1], downTrend[pos], time[pos], downTrend[pos]))
            {
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, downTrend[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, downTrend[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, time[pos + 1]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, time[pos]);
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
