// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67145

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.5"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property  indicator_width1  2
#property  indicator_width2  2
input int Length=60;
input ENUM_MA_METHOD method = MODE_SMA; // Smoothing method
input bool Combined=true;
input bool Relative=false;
input bool invert = false; // Invert?
input int bars_limit = 1000; // Bars limit
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double Positive[], Negative[];
double APos[], ANeg[];

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
ColoredStream* Cumulative;

int init()
{
   IndicatorShortName("Cumulative Volume");
   IndicatorDigits(Digits);
   IndicatorBuffers(7);
   if (Combined)
   {
      int id = 0;
      Cumulative = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = Cumulative.RegisterStream(id, Green);
      id = Cumulative.RegisterStream(id, Red);
      SetIndexBuffer(id++,Positive);
      SetIndexBuffer(id++,Negative);
      SetIndexBuffer(id++,APos);
      SetIndexBuffer(id++,ANeg);
      id = Cumulative.RegisterInternalStream(id);
   }
   else
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(0,Positive);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Negative);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,APos);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,ANeg);
   }
   return(0);
}

int deinit()
{
   Cumulative.Release();
   Cumulative = NULL;
   return(0);
}

int start()
{
   if(Bars<=Length) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   for (int pos = MathMin(bars_limit, limit); pos >= 0; --pos)
   {
      if (_Period == timeframe || timeframe == PERIOD_CURRENT)
      {
         if (Close[pos] > Close[pos + 1])
         {
            APos[pos] = Volume[pos] / 100;
            ANeg[pos] = 0;
         }
         else
         {
            APos[pos] = 0;
            ANeg[pos] = Volume[pos] / 100;
         }
         double p = iMAOnArray(APos, 0, Length, 0, method, pos) * Length;
         double n = iMAOnArray(ANeg, 0, Length, 0, method, pos) * Length;
         if (pos > Bars - 1 - Length)
            continue;
         double SVolume = 0.;
         for (int i = 0; i < Length; i++)
         {
            SVolume = SVolume + Volume[pos + i];
         }
         SVolume = SVolume / 100;
         if (Combined)
         {
            double cumulative = 0;
            if (Relative)
               cumulative = (p - n) * 1000 / SVolume;
            else
               cumulative = p - n;
            if (invert && cumulative != 0)
            {
               cumulative = 1.0 / cumulative;
            }
            Cumulative.Set(cumulative, pos, cumulative >= 0 ? 0 : 1);
         }
         else
         {
            if (Relative)
            {
               Positive[pos] = p * 1000 / SVolume;
               Negative[pos] = -n * 1000 / SVolume;
            }
            else
            {
               Positive[pos] = p;
               Negative[pos] = -n;
            }
            if (invert)
            {
               if (Positive[pos] != 0)
               {
                  Positive[pos] = 1.0 / Positive[pos];
               }
               if (Negative[pos] != 0)
               {
                  Negative[pos] = 1.0 / Negative[pos];
               }
            }
         }
      }
      else
      {
         int index = iBarShift(_Symbol, timeframe, Time[pos]);
         if (index < 0)
            continue;
         if (Combined)
         {
            double cumulative = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative, 0, index);
            Cumulative.Set(cumulative, pos, cumulative >= 0 ? 0 : 1);
         }
         else
         {
            Positive[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative, 0, index);
            Negative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative,1, index);
         }
      }
   }
   
   return(0);
}

