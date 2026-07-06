// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71416


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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+


#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_label1 "HPI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "HPI Index-Turn off all others"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Aqua
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "HPI Weighted Moving Average"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Orange
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Commercials Net-Position"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Non-Commercials Net-Position"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_level1 0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASH

input string oi_symbol = "EURUSD"; // QUANDL:CFTC | 0
input string commercial_long_total_symbol = "EURUSD"; // QUANDL:CFTC | 4
input string commercial_short_total_symbol = "EURUSD"; // QUANDL:CFTC | 5
input string long_total_symbol = "EURUSD"; // QUANDL:CFTC | 1
input string short_total_symbol = "EURUSD"; // QUANDL:CFTC | 2
input int valueofonecentmove = 100;
input int multiplyingfactor = 10;
input int wmaperiod = 21;
input bool is_includeoptions = false; // Include Options
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[];
double diff[], oi[], M[], K[];

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


// IndicatorOutputStream v3.0
class IndicatorOutputStream : public AStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, _data);
      SetIndexLabel(id, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, _data);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValue(const int period, double& val)
   {
      if (_data[period] == EMPTY_VALUE)
         return false;
      val = _data[period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
// Lowest low stream v1.1



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

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
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

// Highest high stream v1.1

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
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
IndicatorOutputStream* lowest1Source;
IStream* lowest1;
IndicatorOutputStream* highest2Source;
IStream* highest2;
IndicatorOutputStream* lowest3Source;
IStream* lowest3;
IndicatorOutputStream* wma4Source;
IStream* wma4;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HPI");
   IndicatorShortName("Herrick Payoff Index");
   IndicatorBuffers(13);
   SetIndexBuffer(0, plot1);
   SetIndexBuffer(1, plot2);
   SetIndexBuffer(2, plot3);
   SetIndexBuffer(3, plot4);
   SetIndexBuffer(4, plot5);
   SetIndexBuffer(5, diff);
   SetIndexBuffer(6, oi);
   SetIndexBuffer(7, M);
   SetIndexBuffer(8, K);
   lowest1Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source.RegisterInternalStream(9);
   lowest1 = new LowestLowStream(lowest1Source, 100);
   highest2Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest2Source.RegisterInternalStream(10);
   highest2 = new HighestHighStream(highest2Source, 100);
   lowest3Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest3Source.RegisterInternalStream(11);
   lowest3 = new LowestLowStream(lowest3Source, 100);
   wma4Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma4Source.RegisterInternalStream(12);
   wma4 = new WMAOnStream(wma4Source, wmaperiod);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   lowest1Source.Release();
   lowest1.Release();
   highest2Source.Release();
   highest2.Release();
   lowest3Source.Release();
   lowest3.Release();
   wma4Source.Release();
   wma4.Release();
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
      ArrayInitialize(diff, EMPTY_VALUE);
      ArrayInitialize(oi, EMPTY_VALUE);
      ArrayInitialize(M, EMPTY_VALUE);
      ArrayInitialize(K, EMPTY_VALUE);
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
   int toSkip = 1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      bool is_inversed = ((_Symbol == "USDCAD") ? true : ((_Symbol == "USDCAD") ? true : ((_Symbol == "USDCHF") ? true : ((_Symbol == "USDCZK") ? true : ((_Symbol == "USDHUF") ? true : ((_Symbol == "USDILS") ? true : ((_Symbol == "USDJPY") ? true : ((_Symbol == "USDMXN") ? true : ((_Symbol == "USDNOK") ? true : ((_Symbol == "USDPLN") ? true : ((_Symbol == "USDRUB") ? true : ((_Symbol == "USDSEK") ? true : ((_Symbol == "USDZAR") ? true : false)))))))))))));
      oi[pos] = iClose(oi_symbol, PERIOD_D1, pos);
      double commercial_long_total = iClose(commercial_long_total_symbol, PERIOD_W1, pos);
      double commercial_short_total = iClose(commercial_short_total_symbol, PERIOD_W1, pos);
      double long_total = iClose(long_total_symbol, PERIOD_W1, pos);
      double short_total = iClose(short_total_symbol, PERIOD_W1, pos);
      double commercial_long = (is_inversed ? commercial_short_total : commercial_long_total);
      double commercial_short = (is_inversed ? commercial_long_total : commercial_short_total);
      double long_ = (is_inversed ? short_total : long_total);
      double short_ = (is_inversed ? long_total : short_total);
      diff[pos] = commercial_long - commercial_short;
      double cdiff = diff[pos] - diff[pos + 1];
      double cI = MathAbs(cdiff);
      double cG = MathMax(diff[pos], diff[pos + 1]);
      double diff2 = long_ - short_;
      double openinterestdiff = oi[pos] - oi[pos + 1];
      double I = MathAbs(openinterestdiff);
      double G = MathMax(oi[pos], oi[pos + 1]);
      int S = multiplyingfactor;
      int C = valueofonecentmove;
      double V = tick_volume[pos];
      M[pos] = (high[pos] + low[pos]) / 2;
      double My = M[pos + 1];
      double K1 = G == 0 ? 0 : (C * V * (M[pos] - My)) * (1 + ((2 * I) / (G)));
      double K2 = G == 0 ? 0 : (C * V * (M[pos] - My)) * (1 - ((2 * I) / (G)));
      K[pos] = ((M[pos] > My) ? K1 : K2);
      double Ky = K[pos + 1];
      lowest1Source._data[pos] = ((Ky + (K[pos] - Ky)) * S) / 100000;
      highest2Source._data[pos] = lowest1Source._data[pos];
      lowest3Source._data[pos] = lowest1Source._data[pos];
      double lowest1Value;
      if (!lowest1.GetValue(pos, lowest1Value))
      {
         continue;
      }
      double highest2Value;
      if (!highest2.GetValue(pos, highest2Value))
      {
         continue;
      }
      double lowest3Value;
      if (!lowest3.GetValue(pos, lowest3Value))
      {
         continue;
      }
      double HPI_Index = (highest2Value - lowest3Value) == 0 ? 0 : 100 * (lowest1Source._data[pos] - lowest1Value) / (highest2Value - lowest3Value);
      wma4Source._data[pos] = lowest1Source._data[pos];
      double wma4Value;
      if (!wma4.GetValue(pos, wma4Value))
      {
         continue;
      }
      double wma = wma4Value;
      plot1[pos] = lowest1Source._data[pos];
      plot2[pos] = HPI_Index;
      plot3[pos] = wma;
      plot4[pos] = diff[pos];
      plot5[pos] = diff2;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
