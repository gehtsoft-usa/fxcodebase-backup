//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73800

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
#property indicator_buffers 19
#property indicator_label1 "Bollinger Bands Mid"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Bollinger Bands Upper Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Lime
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Bollinger Bands Lower Line"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Lime
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "mahi5"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "mahi10"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Yellow
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "malo5"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Fuchsia
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "malo10"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Black
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "ema50"
#property indicator_type8 DRAW_LINE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "ema800"
#property indicator_type9 DRAW_LINE
#property indicator_color9 Purple
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_type10 DRAW_ARROW
#property indicator_color10 Red
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_type11 DRAW_ARROW
#property indicator_color11 Green
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_type12 DRAW_ARROW
#property indicator_color12 Red
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_type13 DRAW_ARROW
#property indicator_color13 Green
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_type14 DRAW_ARROW
#property indicator_color14 Red
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_type15 DRAW_ARROW
#property indicator_color15 Green
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_type16 DRAW_ARROW
#property indicator_color16 Red
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_type17 DRAW_ARROW
#property indicator_color17 Green
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_type18 DRAW_ARROW
#property indicator_color18 Red
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1
#property indicator_type19 DRAW_ARROW
#property indicator_color19 Green
#property indicator_style19 STYLE_SOLID
#property indicator_width19 1

input bool plot_signal_ret = false; // Plot Signal RET
input bool plot_signal_ext = false; // Plot Signal EXT
input bool plot_signal_csa = false; // Plot Signal CSAK
input bool plot_signal_mmt = false; // Plot Signal MMT
input bool plot_signal_ali = false; // Plot Alien Candle
input int bars_limit = 100000; // Bars limit

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


// StDev stream v1.2

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(IStream* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }
   
   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < _period; i++)
      {
         double __data;
         if (!_source.GetValue(period + i, __data))
            return false;
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
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
int BBlength;
int BBmult;
SimplePriceStream* sma1Source;
IStream* sma1;
SimplePriceStream* sma2Source;
IStream* sma2;
SimplePriceStream* stdev1Source;
IStream* stdev1;
SimplePriceStream* wma1Source;
IStream* wma1;
SimplePriceStream* wma2Source;
IStream* wma2;
SimplePriceStream* wma3Source;
IStream* wma3;
SimplePriceStream* wma4Source;
IStream* wma4;
SimplePriceStream* wma5Source;
IStream* wma5;
SimplePriceStream* wma6Source;
IStream* wma6;
SimplePriceStream* ema1Source;
IStream* ema1;
SimplePriceStream* ema2Source;
IStream* ema2;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
SimplePriceStream* ema3Source;
IStream* ema3;
double plot9[];
SimplePriceStream* ema4Source;
IStream* ema4;
double plot10[];
double plot11[];
double plot12[];
double plot13[];
double plot14[];
double plot15[];
double plot16[];
double plot17[];
double plot18[];
double plot19[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("BBMACSA");
   IndicatorShortName("BBMA");
   IndicatorBuffers(19);
   int id = 0;
   SetIndexBuffer(id, plot10);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot11);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot12);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot13);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot14);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot15);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot16);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot17);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot18);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot19);
   SetIndexArrow(id++, 161);
   BBlength = 20;
   BBmult = 2;
   sma1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   sma1 = new SmaOnStream(sma1Source, 20);
   sma2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   sma2 = new SmaOnStream(sma2Source, 20);
   stdev1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   stdev1 = new StDevStream(stdev1Source, BBlength);
   wma1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   wma1 = new WMAOnStream(wma1Source, 5);
   wma2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   wma2 = new WMAOnStream(wma2Source, 10);
   wma3Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   wma3 = new WMAOnStream(wma3Source, 5);
   wma4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   wma4 = new WMAOnStream(wma4Source, 10);
   wma5Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   wma5 = new WMAOnStream(wma5Source, 5);
   wma6Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   wma6 = new WMAOnStream(wma6Source, 5);
   ema1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ema1 = new EMAOnStream(ema1Source, 50);
   ema2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ema2 = new EMAOnStream(ema2Source, 800);
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   ema3Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ema3 = new EMAOnStream(ema3Source, 50);
   SetIndexBuffer(id++, plot9);
   ema4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ema4 = new EMAOnStream(ema4Source, 800);
   SetIndexBuffer(id++, plot10);
   SetIndexBuffer(id++, plot11);
   SetIndexBuffer(id++, plot12);
   SetIndexBuffer(id++, plot13);
   SetIndexBuffer(id++, plot14);
   SetIndexBuffer(id++, plot15);
   SetIndexBuffer(id++, plot16);
   SetIndexBuffer(id++, plot17);
   SetIndexBuffer(id++, plot18);
   SetIndexBuffer(id++, plot19);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
   stdev1Source.Release();
   stdev1.Release();
   wma1Source.Release();
   wma1.Release();
   wma2Source.Release();
   wma2.Release();
   wma3Source.Release();
   wma3.Release();
   wma4Source.Release();
   wma4.Release();
   wma5Source.Release();
   wma5.Release();
   wma6Source.Release();
   wma6.Release();
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   ema4Source.Release();
   ema4.Release();
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
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ArrayInitialize(plot14, EMPTY_VALUE);
      ArrayInitialize(plot15, EMPTY_VALUE);
      ArrayInitialize(plot16, EMPTY_VALUE);
      ArrayInitialize(plot17, EMPTY_VALUE);
      ArrayInitialize(plot18, EMPTY_VALUE);
      ArrayInitialize(plot19, EMPTY_VALUE);
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
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value))
      {
         continue;
      }
      double midBB = sma1Value;
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value))
      {
         continue;
      }
      double midBB_p = sma2Value;
      double stdev1Value;
      if (!stdev1.GetValue(pos, stdev1Value))
      {
         continue;
      }
      int BBdev = BBmult * stdev1Value;
      double topBB = midBB + BBdev;
      double lowBB = midBB - BBdev;
      double topBB_p = midBB_p + BBdev;
      double lowBB_p = midBB_p - BBdev;
      double wma1Value;
      if (!wma1.GetValue(pos, wma1Value))
      {
         continue;
      }
      double mahi5 = wma1Value;
      double wma2Value;
      if (!wma2.GetValue(pos, wma2Value))
      {
         continue;
      }
      double mahi10 = wma2Value;
      double wma3Value;
      if (!wma3.GetValue(pos, wma3Value))
      {
         continue;
      }
      double malo5 = wma3Value;
      double wma4Value;
      if (!wma4.GetValue(pos, wma4Value))
      {
         continue;
      }
      double malo10 = wma4Value;
      double wma5Value;
      if (!wma5.GetValue(pos, wma5Value))
      {
         continue;
      }
      double mahi5_p = wma5Value;
      double wma6Value;
      if (!wma6.GetValue(pos, wma6Value))
      {
         continue;
      }
      double malo5_p = wma6Value;
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value))
      {
         continue;
      }
      double ema50 = ema1Value;
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value))
      {
         continue;
      }
      double ema800 = ema2Value;
      double p_midBB = plot1[pos] = midBB;
      double p_topBB = plot2[pos] = topBB;
      double p_lowBB = plot3[pos] = lowBB;
      double p_mahi5 = plot4[pos] = mahi5;
      double p_mahi10 = plot5[pos] = mahi10;
      double p_malo5 = plot6[pos] = malo5;
      double p_malo10 = plot7[pos] = malo10;
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value))
      {
         continue;
      }
      double p_ema50 = plot8[pos] = ema3Value;
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value))
      {
         continue;
      }
      double p_ema800 = plot9[pos] = ema4Value;
      bool reject_mahi = ((((((high[pos] > mahi5)) && ((close[pos] < mahi5))) && ((close[pos] < mahi10))) && ((close[pos] < midBB))) && ((mahi5 < midBB)));
      plot10[pos] = (reject_mahi && plot_signal_ret);
      bool reject_malo = ((((((low[pos] < malo5)) && ((close[pos] > malo5))) && ((close[pos] > malo10))) && ((close[pos] > midBB))) && ((malo5 > midBB)));
      plot11[pos] = (reject_malo && plot_signal_ret);
      bool csak_sell = (((((open[pos] > midBB)) && ((close[pos] < midBB))) && ((close[pos] < malo5))) && ((close[pos] < malo10)));
      plot12[pos] = (csak_sell && plot_signal_csa);
      bool csak_buy = (((((open[pos] < midBB)) && ((close[pos] > midBB))) && ((close[pos] > mahi5))) && ((close[pos] > mahi10)));
      plot13[pos] = (csak_buy && plot_signal_csa);
      bool csaa = (((close[pos] < malo10)) || ((close[pos] > mahi10)));
      bool ext_sell = (((close[pos] < topBB)) && ((mahi5 > topBB)));
      plot14[pos] = (ext_sell && plot_signal_ext);
      bool ext_buy = (((close[pos] > lowBB)) && ((malo5 < lowBB)));
      plot15[pos] = (ext_buy && plot_signal_ext);
      bool mmt_sell = (((close[pos] < lowBB)) && ((open[pos] > lowBB)));
      plot16[pos] = (mmt_sell && plot_signal_mmt);
      bool mmt_buy = (((close[pos] > topBB)) && ((open[pos] < topBB)));
      plot17[pos] = (mmt_buy && plot_signal_mmt);
      bool ali_sell = (((open[pos] < lowBB)) && ((close[pos] < lowBB)));
      plot18[pos] = (ali_sell && plot_signal_ali);
      bool ali_buy = (((open[pos] > topBB)) && ((close[pos] > topBB)));
      plot19[pos] = (ali_buy && plot_signal_ali);
      bool signal_reentry = (reject_mahi || reject_malo);
      bool signal_csak = (csak_sell || csak_buy);
      bool signal_extreme = (ext_sell || ext_buy);
      bool signal_csm = (mmt_sell || mmt_buy);
      bool signal_alien = (ali_sell || ali_buy);
      bool signal_mahi = (close[pos] > mahi5);
      bool signal_malo = (close[pos] < malo5);
      bool signal_csaa = csaa;
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