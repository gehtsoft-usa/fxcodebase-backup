// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=143213

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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 14
#property indicator_plots 5
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
input string force_root = ""; // Override Product
input bool is_includeoptions = false; // Include Options
input int bars_limit = 1000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[];
double diff[], oi[], M[], K[], HPI[];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

// ABaseStream v1.1
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};
class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
#endif
// IBarStream v1.0



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

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif

// PriceStream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public IStream
{
   ENUM_APPLIED_PRICE _price;
   IBarStream* _source;
   int _references;
public:
   PriceStream(IBarStream* source, const ENUM_APPLIED_PRICE __price)
   {
      _source = source;
      _source.AddRef();
      _price = __price;
      _references = 1;
   }

   ~PriceStream()
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

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PRICE_CLOSE:
               if (!_source.GetClose(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_OPEN:
               if (!_source.GetOpen(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_HIGH:
               if (!_source.GetHigh(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_LOW:
               if (!_source.GetLow(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_MEDIAN:
               {
                  double high, low;
                  if (!_source.GetHighLow(period + i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PRICE_TYPICAL:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PRICE_WEIGHTED:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         }
         values[i] = val;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = Size();
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

class SimplePriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   SimplePriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

#endif


// IndicatorOutputStream v3.0

#ifndef IndicatorOutputStream_IMP
#define IndicatorOutputStream_IMP

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};
#endif
// Lowest low stream v1.0



//AOnStream v2.0
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

   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};

class LowestLowStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      ArrayResize(_values, loopback);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      val = _values[0];

      for (int i = 1; i < _loopback; ++i)
      {
         val = MathMin(val, _values[i]);
      }
      return true;
   }
};
// Highest high stream v1.0



class HighestHighStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      ArrayResize(_values, loopback);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      val = _values[0];

      for (int i = 1; i < _loopback; ++i)
      {
         val = MathMax(val, _values[i]);
      }
      return true;
   }
};


// WMA on stream v1.0

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

   virtual bool GetSeriesValue(const int period, double &val)
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
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current[0];

      _buffer[bufferIndex] = (current[0] - last) * _k + last;
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
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HPI");
   IndicatorSetString(INDICATOR_SHORTNAME, "Herrick Payoff Index");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(0, plot1, INDICATOR_DATA);
   SetIndexBuffer(1, plot2, INDICATOR_DATA);
   SetIndexBuffer(2, plot3, INDICATOR_DATA);
   SetIndexBuffer(3, plot4, INDICATOR_DATA);
   SetIndexBuffer(4, plot5, INDICATOR_DATA);
   SetIndexBuffer(5, diff, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, oi, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, M, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, K, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, HPI, INDICATOR_CALCULATIONS);
   lowest1Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source.RegisterInternalStream(10);
   lowest1 = new LowestLowStream(lowest1Source, 100);
   highest2Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest2Source.RegisterInternalStream(11);
   highest2 = new HighestHighStream(highest2Source, 100);
   lowest3Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest3Source.RegisterInternalStream(12);
   lowest3 = new LowestLowStream(lowest3Source, 100);
   wma4Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma4Source.RegisterInternalStream(13);
   wma4 = new WMAOnStream(wma4Source, wmaperiod);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   lowest1Source.Release();
   lowest1.Release();
   highest2Source.Release();
   highest2.Release();
   lowest3Source.Release();
   lowest3.Release();
   wma4Source.Release();
   wma4.Release();
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
      ArrayInitialize(HPI, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      bool is_inversed = ((_Symbol == "USDCAD") ? true : ((_Symbol == "USDCAD") ? true : ((_Symbol == "USDCHF") ? true : ((_Symbol == "USDCZK") ? true : ((_Symbol == "USDHUF") ? true : ((_Symbol == "USDILS") ? true : ((_Symbol == "USDJPY") ? true : ((_Symbol == "USDMXN") ? true : ((_Symbol == "USDNOK") ? true : ((_Symbol == "USDPLN") ? true : ((_Symbol == "USDRUB") ? true : ((_Symbol == "USDSEK") ? true : ((_Symbol == "USDZAR") ? true : false)))))))))))));
      oi[pos] = iClose(oi_symbol, PERIOD_D1, oldPos);
      double commercial_long_total = iClose(commercial_long_total_symbol, PERIOD_W1, oldPos);
      double commercial_short_total = iClose(commercial_short_total_symbol, PERIOD_W1, oldPos);
      double long_total = iClose(long_total_symbol, PERIOD_W1, oldPos);
      double short_total = iClose(short_total_symbol, PERIOD_W1, oldPos);
      double commercial_long = (is_inversed ? commercial_short_total : commercial_long_total);
      double commercial_short = (is_inversed ? commercial_long_total : commercial_short_total);
      double _long = (is_inversed ? short_total : long_total);
      double _short = (is_inversed ? long_total : short_total);
      diff[pos] = commercial_long - commercial_short;
      double cdiff = diff[pos] - diff[pos - 1];
      double cI = MathAbs(cdiff);
      double cG = MathMax(diff[pos], diff[pos - 1]);
      double diff2 = _long - _short;
      double openinterestdiff = oi[pos] - oi[pos - 1];
      double I = MathAbs(openinterestdiff);
      double G = MathMax(oi[pos], oi[pos - 1]);
      int S = multiplyingfactor;
      int C = valueofonecentmove;
      double V = tick_volume[pos];
      M[pos] = (high[pos] + low[pos]) / 2;
      double My = M[pos - 1];
      double K1 = G == 0 ? 0 : (C * V * (M[pos] - My)) * (1 + ((2 * I) / (G)));
      double K2 = G == 0 ? 0 : (C * V * (M[pos] - My)) * (1 - ((2 * I) / (G)));
      K[pos] = ((M[pos] > My) ? K1 : K2);
      double Ky = K[pos - 1];
      HPI[pos] = ((Ky + (K[pos] - Ky)) * S) / 100000;
      lowest1Source._data[oldPos] = HPI[pos];
      double lowest1Value[1];
      if (!lowest1.GetSeriesValues(oldPos, 1, lowest1Value))
      {
         continue;
      }
      highest2Source._data[oldPos] = HPI[pos];
      double highest2Value[1];
      if (!highest2.GetSeriesValues(oldPos, 1, highest2Value))
      {
         continue;
      }
      lowest3Source._data[oldPos] = HPI[pos];
      double lowest3Value[1];
      if (!lowest3.GetSeriesValues(oldPos, 1, lowest3Value))
      {
         continue;
      }
      double HPI_Index = (highest2Value[0] - lowest3Value[0]) == 0 ? 0 : 100 * (HPI[pos] - lowest1Value[0]) / (highest2Value[0] - lowest3Value[0]);
      wma4Source._data[oldPos] = HPI[pos];
      double wma4Value[1];
      if (!wma4.GetSeriesValues(oldPos, 1, wma4Value))
      {
         continue;
      }
      double wma = wma4Value[0];
      plot1[pos] = HPI[pos];
      plot2[pos] = HPI_Index;
      plot3[pos] = wma;
      plot4[pos] = diff[pos];
      plot5[pos] = diff2;

   }
   return rates_total;
}
