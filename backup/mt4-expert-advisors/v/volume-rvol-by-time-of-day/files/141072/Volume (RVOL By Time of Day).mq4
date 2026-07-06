// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70976

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 13

input string type = "Stocks"; // Market
input int lookback = 15; // Lookback Period
input double alertPercent = 0; // Alert At RVOL %
input string barColorOption = "Price"; // Color Scheme
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

// Colored stream v3.2

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
         ArrayInitialize(_streams[i].Stream, defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
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
      SetIndexStyle(id, lineType, lineStyle, width, clr);
      SetIndexBuffer(id, _streams[size].Stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      if (label != "")
         SetIndexLabel(id, label);
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

ColoredStream* volumeBars;
double avgVolume[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Volume+");
   IndicatorShortName("Volume (RVOL By Time of Day)");
   IndicatorBuffers(14);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, Purple);
   SetIndexBuffer(id, avgVolume);
   SetIndexLabel(id, "Average Line");
   ++id;

   volumeBars = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = volumeBars.RegisterStream(id, Gray);
   id = volumeBars.RegisterStream(id, 0x00005000);
   id = volumeBars.RegisterStream(id, 0x00007000);
   id = volumeBars.RegisterStream(id, 0x00009900);
   id = volumeBars.RegisterStream(id, 0x0000dd00);
   id = volumeBars.RegisterStream(id, 0x0000ff00);
   id = volumeBars.RegisterStream(id, 0x00ff1d00);
   id = volumeBars.RegisterStream(id, Orange);
   id = volumeBars.RegisterStream(id, Green);
   id = volumeBars.RegisterStream(id, Teal);
   id = volumeBars.RegisterStream(id, 0x005cbcb3);
   id = volumeBars.RegisterStream(id, 0x00f37e7c);
   id = volumeBars.RegisterInternalStream(id);

   return INIT_SUCCEEDED;
}

int deinit()
{
   delete volumeBars;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int toSkip = lookback * 288;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double totalVolume = 0;
      for (int i = 1; i <= lookback; ++i)
      {
         if (type == "Forex")
         {
            totalVolume += (_Period == PERIOD_M1 ? 0 : 
               _Period == PERIOD_M5 ? tick_volume[pos + i * 288] : 
               _Period == PERIOD_M15 ? tick_volume[pos + i * 96] :
               _Period == PERIOD_M30 ? tick_volume[pos + i * 48] : 
               _Period == PERIOD_H1 ? tick_volume[pos + i * 24] : 
               _Period == PERIOD_H4 ? tick_volume[pos + i * 6] : 
               _Period == PERIOD_D1 ? tick_volume[pos + i * 5] : 
               _Period == PERIOD_W1 ? tick_volume[pos + i * 4] : 0);
         }
         if (type == "Crypto")
         {
            totalVolume += (_Period == PERIOD_M1 ? 0 : 
               _Period == PERIOD_M5 ? tick_volume[pos + i * 288] : 
               _Period == PERIOD_M15 ? tick_volume[pos + i * 96] : 
               _Period == PERIOD_M30 ? tick_volume[pos + i * 48] : 
               _Period == PERIOD_H1 ? tick_volume[pos + i * 24] : 
               _Period == PERIOD_H4 ? tick_volume[pos + i * 6] : 
               _Period == PERIOD_D1 ? tick_volume[pos + i * 7] : 
               _Period == PERIOD_W1 ? tick_volume[pos + i * 4] : 0);
         }
         if (type == "Stocks")
         {
            totalVolume += (_Period == PERIOD_M1 ? 0 : 
               _Period == PERIOD_M5 ? tick_volume[pos + i * 78] : 
               _Period == PERIOD_M15 ? tick_volume[pos + i * 26] : 
               _Period == PERIOD_M30 ? tick_volume[pos + i * 13] : 
               _Period == PERIOD_H1 ? tick_volume[pos + i * 7] : 
               _Period == PERIOD_H4 ? tick_volume[pos + i * 2] : 
               _Period == PERIOD_D1 ? tick_volume[pos + i * 5] : 
               _Period == PERIOD_W1 ? tick_volume[pos + i * 4] : 0);
         }
         if (type == "TSX Stocks")
         {
            totalVolume += (_Period == PERIOD_M1 ? 0 : 
               _Period == PERIOD_M5 ? tick_volume[pos + i * 79] : 
               _Period == PERIOD_M15 ? tick_volume[pos + i * 27] : 
               _Period == PERIOD_M30 ? tick_volume[pos + i * 14] : 
               _Period == PERIOD_H1 ? tick_volume[pos + i * 7] : 
               _Period == PERIOD_H4 ? tick_volume[pos + i * 2] : 
               _Period == PERIOD_D1 ? tick_volume[pos + i * 5] : 
               _Period == PERIOD_W1 ? tick_volume[pos + i * 4] : 0);
         }
         if (type == "Futures")
         {
            totalVolume += (_Period == PERIOD_M1 ? 0 : 
               _Period == PERIOD_M5 ? tick_volume[pos + i * 273] : 
               _Period == PERIOD_M15 ? tick_volume[pos + i * 92] : 
               _Period == PERIOD_M30 ? tick_volume[pos + i * 46] : 
               _Period == PERIOD_H1 ? tick_volume[pos + i * 23] : 
               _Period == PERIOD_H4 ? tick_volume[pos + i * 6] : 
               _Period == PERIOD_D1 ? tick_volume[pos + i * 4] : 
               _Period == PERIOD_W1 ? tick_volume[pos + i * 4] : 0);
         }
      }  
      avgVolume[pos] = totalVolume / lookback;
      double volumePercent = avgVolume[pos] == 0 ? 0 : tick_volume[pos] / avgVolume[pos];
      bool alert = alertPercent == 0.0 && tick_volume[pos] > avgVolume[pos] && _Period != PERIOD_M1 || alertPercent != 0.0 && volumePercent >= alertPercent;
      int barColor = 0;
      // Heatmap Color Scheme
      if (barColorOption == "Heatmap" && volumePercent >= 0.25)
         barColor = 1;
      if (barColorOption == "Heatmap" && volumePercent >= 0.50)
         barColor = 2;
      if (barColorOption == "Heatmap" && volumePercent >= 0.75)
         barColor = 3;
      if (barColorOption == "Heatmap" && volumePercent >= 1)
         barColor = 4;
      if (barColorOption == "Heatmap" && volumePercent >= 2)
         barColor = 5;
         
      // Traffic Light Color Scheme
      if (barColorOption == "Traffic" && volumePercent >= 1.00)
         barColor = 6;
      if (barColorOption == "Traffic" && volumePercent >= 1.50)
         barColor = 7;
      if (barColorOption == "Traffic" && volumePercent >= 2.0)
         barColor = 8;
      if (barColorOption == "Traffic" && volumePercent >= 3.0)
         barColor = 5;

      // Trigger Color Scheme
      if (barColorOption == "Trigger")
         barColor = alert ? 9 : 0;

      // Colored Scheme
      if (barColorOption == "Price" && close[pos] >= open[pos])
         barColor = 10;
      if (barColorOption == "Price" && close[pos] < open[pos])
         barColor = 11;
      if (alertPercent != 0.0 && volumePercent >= alertPercent)
         barColor = 9;

      volumeBars.Set(tick_volume[pos], pos, barColor);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(volume, tickVolumeSeries);
   return rates_total;
}
