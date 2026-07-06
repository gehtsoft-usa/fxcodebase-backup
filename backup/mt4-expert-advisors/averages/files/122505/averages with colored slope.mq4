// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67050
 

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property strict

enum AveragesMethod
{
   SMA = MODE_SMA, // SMA
   EMA = MODE_EMA, // EMA
   SMMA = MODE_SMMA, // SMMA
   LWMA = MODE_LWMA, // LWMA
   WMA,
   SineWMA,
   TriMA,
   LSMA,
   HMA,
   ZeroLagEMA,
   DEMA,
   T3MA,
   ITrend,
   Median,
   GeoMean,
   REMA,
   ILRS,
   IE2,
   TriMAgen,
   JSmooth
};

input int Length = 20;
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price type
input AveragesMethod Method = SMA; // Method
input color clr_up = Green; // Color up
input color clr_dn = Red; // Color down

double wma_k;

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

// Colored stream v3.1

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};

class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         ArrayInitialize(_streams[i].Stream, EMPTY_VALUE);
      }
      ArrayInitialize(_data, EMPTY_VALUE);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id + 0, lineType, lineStyle, width, clr);
      SetIndexBuffer(id + 0, _streams[size].Stream);
      if (label != "")
         SetIndexLabel(id + 0, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif

ColoredStream* aa;

int init()
{
   aa = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma_k = 1. / Length;
   IndicatorShortName("Averages");
   IndicatorBuffers(3);
   IndicatorDigits(Digits);
   int id = 0;
   id = aa.RegisterStream(id, clr_up, "MA Up");
   id = aa.RegisterStream(id, clr_dn, "MA Down");
   id = aa.RegisterInternalStream(id);
   switch (Method)
   {
      case SMA:
      case EMA:
      case SMMA:
      case LWMA:
      case WMA:
         break;
      case SineWMA:
         {
            double temp = iCustom(NULL, 0, "SineWMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'SineWMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=63064");
               return INIT_FAILED;
            }
         }
         break;
      case TriMA:
         {
            double temp = iCustom(NULL, 0, "TriMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'TriMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59627");
               return INIT_FAILED;
            }
         }
         break;
      case LSMA:
         {
            double temp = iCustom(NULL, 0, "LSMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'LSMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59628");
               return INIT_FAILED;
            }
         }
         break;
      case HMA:
         {
            double temp = iCustom(NULL, 0, "HMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'HMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59630");
               return INIT_FAILED;
            }
         }
         break;
      case ZeroLagEMA:
         {
            double temp = iCustom(NULL, 0, "ZeroLagEMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ZeroLagEMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59634");
               return INIT_FAILED;
            }
         }
         break;
      case DEMA:
         {
            double temp = iCustom(NULL, 0, "DEMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'DEMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20396");
               return INIT_FAILED;
            }
         }
         break;
      case T3MA:
         {
            double temp = iCustom(NULL, 0, "T3_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'T3_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=63063");
               return INIT_FAILED;
            }
         }
         break;
      case ITrend:
         {
            double temp = iCustom(NULL, 0, "ITrendMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ITrendMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59635");
               return INIT_FAILED;
            }
         }
         break;
      case Median:
         {
            double temp = iCustom(NULL, 0, "MedianMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'MedianMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20876");
               return INIT_FAILED;
            }
         }
         break;
      case GeoMean:
         {
            double temp = iCustom(NULL, 0, "GeoMin_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'GeoMin_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20877");
               return INIT_FAILED;
            }
         }
         break;
      case REMA:
         {
            double temp = iCustom(NULL, 0, "REMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'REMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59636");
               return INIT_FAILED;
            }
         }
         break;
      case ILRS:
         {
            double temp = iCustom(NULL, 0, "ILRS_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ILRS_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59963");
               return INIT_FAILED;
            }
         }
         break;
      case IE2:
         {
            double temp = iCustom(NULL, 0, "IE2_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'IE2_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59964");
               return INIT_FAILED;
            }
         }
         break;
      case TriMAgen:
         {
            double temp = iCustom(NULL, 0, "TriMAgen", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'TriMAgen' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59965");
               return INIT_FAILED;
            }
         }
         break;
      case JSmooth:
         {
            double temp = iCustom(NULL, 0, "JSmooth_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'JSmooth_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59966");
               return INIT_FAILED;
            }
         }
         break;
   }

   return(0);
}

int deinit()
{
   delete aa;
   aa = NULL;
   return(0);
}

double GetValue(int pos)
{
   switch (Method)
   {
      case SMA:
         return iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
      case EMA:
         return iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
      case SMMA:
         return iMA(NULL, 0, Length, 0, MODE_SMMA, Price, pos);
      case LWMA:
         return iMA(NULL, 0, Length, 0, MODE_LWMA, Price, pos);
      case WMA:
         if (pos == Bars - 2)
         {
            return iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
         }
         return (iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - aa._data[pos + 1]) * wma_k + aa._data[pos + 1];
      case SineWMA:
         return iCustom(NULL, 0, "SineWMA", Length, Price, 0, pos);
      case TriMA:
         return iCustom(NULL, 0, "TriMA", Length, Price, 0, pos);
      case LSMA:
         return iCustom(NULL, 0, "LSMA", Length, Price, 0, pos);
      case HMA:
         return iCustom(NULL, 0, "HMA", Length, Price, 0, pos);
      case ZeroLagEMA:
         return iCustom(NULL, 0, "ZeroLagEMA", Length, Price, 0, pos);
      case DEMA:
         return iCustom(NULL, 0, "DEMA", Length, Price, 0, pos);
      case T3MA:
         return iCustom(NULL, 0, "T3MA", Length, Price, 0, pos);
      case ITrend:
         return iCustom(NULL, 0, "ITrendMA", Length, Price, 0, pos);
      case Median:
         return iCustom(NULL, 0, "MedianMA", Length, Price, 0, pos);
      case GeoMean:
         return iCustom(NULL, 0, "GeoMin_MA", Length, Price, 0, pos);
      case REMA:
         return iCustom(NULL, 0, "REMA", Length, Price, 0, pos);
      case ILRS:
         return iCustom(NULL, 0, "ILRS_MA", Length, Price, 0, pos);
      case IE2:
         return iCustom(NULL, 0, "IE2_MA", Length, Price, 0, pos);
      case TriMAgen:
         return iCustom(NULL, 0, "TriMAgen", Length, Price, 0, pos);
      case JSmooth:
         return iCustom(NULL, 0, "JSmooth_MA", Length, Price, 0, pos);
   }
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
      aa.Init(EMPTY_VALUE);
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
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0; --pos)
   {
      double val = GetValue(pos);
      aa.Set(val, pos, aa._data[pos + 1] <= val ? 0 : 1);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
