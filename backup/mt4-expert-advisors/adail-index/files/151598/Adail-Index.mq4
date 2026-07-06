//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73918

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
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_type1 DRAW_LINE
#property indicator_color1 0xF0E68C
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 0xF0E68C
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "OSCDI"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x00FF00
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "I20/8"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0xFF0000
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "I3/8"
#property indicator_type5 DRAW_LINE
#property indicator_color5 0xFBEFEF
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_type6 DRAW_LINE
#property indicator_color6 0x00FFFF
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_type7 DRAW_LINE
#property indicator_color7 0xFFFF00
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_levelcolor 0xFFFF00
#property indicator_level1 0
#property indicator_level2 3
#property indicator_level3 5
#property indicator_level4 10
#property indicator_level5 (-3)
#property indicator_level6 (-5)
#property indicator_level7 (-10)
#property indicator_label8 "HE"
#property indicator_type8 DRAW_LINE
#property indicator_color8 0x2f00ff
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "HN"
#property indicator_type9 DRAW_LINE
#property indicator_color9 0x00FFFF
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "LE"
#property indicator_type10 DRAW_LINE
#property indicator_color10 0xff0080
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "LN"
#property indicator_type11 DRAW_LINE
#property indicator_color11 0xFFFF00
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1

input int bars_limit = 100000; // Bars limit
double osc[], d208[];

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

SimplePriceStream* ta_sma1Source;
IStream* ta_sma1;
SimplePriceStream* ta_sma2Source;
IStream* ta_sma2;
SimplePriceStream* ta_sma3Source;
IStream* ta_sma3;
SimplePriceStream* ta_sma4Source;
IStream* ta_sma4;
SimplePriceStream* ta_sma5Source;
IStream* ta_sma5;
SimplePriceStream* ta_stdev1Source;
IStream* ta_stdev1;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double band1;
double band2;
double band3;
double band4;
double band5;
double band6;
double plot8[];
double plot9[];
double plot10[];
double plot11[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Adail-Index (versão DELTA)");
   IndicatorShortName("Adail-Index");
   IndicatorBuffers(13);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, plot9);
   SetIndexBuffer(id++, plot10);
   SetIndexBuffer(id++, plot11);
   SetIndexBuffer(id++, osc);
   SetIndexBuffer(id++, d208);
   ta_sma1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_sma1 = new SmaOnStream(ta_sma1Source, 1);
   ta_sma2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_sma2 = new SmaOnStream(ta_sma2Source, 3);
   ta_sma3Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_sma3 = new SmaOnStream(ta_sma3Source, 8);
   ta_sma4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_sma4 = new SmaOnStream(ta_sma4Source, 20);
   ta_sma5Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceOpen);
   ta_sma5 = new SmaOnStream(ta_sma5Source, 1);
   ta_stdev1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_stdev1 = new StDevStream(ta_stdev1Source, 8);
   band1 = 3;
   band2 = 5;
   band3 = 10;
   band4 = (-3);
   band5 = (-5);
   band6 = (-10);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ta_sma1Source.Release();
   ta_sma1.Release();
   ta_sma2Source.Release();
   ta_sma2.Release();
   ta_sma3Source.Release();
   ta_sma3.Release();
   ta_sma4Source.Release();
   ta_sma4.Release();
   ta_sma5Source.Release();
   ta_sma5.Release();
   ta_stdev1Source.Release();
   ta_stdev1.Release();
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
      ArrayInitialize(osc, EMPTY_VALUE);
      ArrayInitialize(d208, EMPTY_VALUE);
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
      double ta_sma1Value;
      if (!ta_sma1.GetValue(pos, ta_sma1Value))
      {
         continue;
      }
      double SMA1 = ta_sma1Value;
      double ta_sma2Value;
      if (!ta_sma2.GetValue(pos, ta_sma2Value))
      {
         continue;
      }
      double SMA3 = ta_sma2Value;
      double ta_sma3Value;
      if (!ta_sma3.GetValue(pos, ta_sma3Value))
      {
         continue;
      }
      double SMA8 = ta_sma3Value;
      double ta_sma4Value;
      if (!ta_sma4.GetValue(pos, ta_sma4Value))
      {
         continue;
      }
      double SMA20 = ta_sma4Value;
      double ta_sma5Value;
      if (!ta_sma5.GetValue(pos, ta_sma5Value))
      {
         continue;
      }
      double SMA1O = ta_sma5Value;
      double d38 = ((SMA3 - SMA8) / SMA8) * 100;
      d208[pos] = ((SMA20 - SMA8) / SMA8) * 100;
      double d18 = ((SMA1 - SMA8) / SMA8) * 100;
      double dO18 = ((SMA1O - SMA8) / SMA8) * 100;
      osc[pos] = d38 - d208[pos];
      double ta_stdev1Value;
      if (!ta_stdev1.GetValue(pos, ta_stdev1Value))
      {
         continue;
      }
      double dp8 = ta_stdev1Value;
      int srs = ((2 * dp8) / SMA8) * 100;
      int sri = (((-2) * dp8) / SMA8) * 100;
      double sr1 = plot1[pos] = srs;
      double sr2 = plot2[pos] = sri;
      plot3[pos] = osc[pos];
      plot4[pos] = d208[pos];
      plot5[pos] = d38;
      plot6[pos] = d18;
      plot7[pos] = dO18;
0;
      bool _high = (((((((d18 > 0)) && ((dO18 < 0))) && ((d18 > d38))) && ((d18 > d208[pos]))) && ((dO18 < d38))) && ((dO18 < d208[pos])));
      bool _highespecial = (((((d18 > 0)) && ((dO18 < 0))) && ((d18 > d38))) && ((dO18 < d38)));
      bool _low = (((((((d18 < 0)) && ((dO18 > 0))) && ((d18 < d38))) && ((d18 < d208[pos]))) && ((dO18 > d38))) && ((dO18 > d208[pos])));
      bool _lowespecial = (((((d18 < 0)) && ((dO18 > 0))) && ((d18 < d38))) && ((dO18 > d38)));
      color needles_colors = (_high ? 0x00FFFF : (_low ? 0xFFFF00 : (_highespecial ? 0x2f00ff : (_lowespecial ? 0xff0080 : EMPTY_VALUE))));
      plot8[pos] = (_highespecial ? 0 : EMPTY_VALUE);
      plot9[pos] = (_high ? 0 : EMPTY_VALUE);
      plot10[pos] = (_lowespecial ? 0 : EMPTY_VALUE);
      plot11[pos] = (_low ? 0 : EMPTY_VALUE);
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