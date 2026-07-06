// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69632

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
#property version   "1.0"
#property strict

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 2

enum ModeType
{
   ModeHighLow, // High/Low
   ModeClose // Close
};

input int atr_period = 20; // ATR Period
input double Factor = 2; // Factor
input ModeType Mode = ModeHighLow; // Trailing Stop Mode
input double Distance = 0; // Distance (in Pips)
input color up_color = Green; // Up color
input color down_color = Red; // Down color

// Colored stream v3.0

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};

// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
// Instrument info v.1.6
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
};
#define AStream_IMP
#endif

class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
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

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

ColoredStream* stream;

int init()
{
   IndicatorName = GenerateIndicatorName("ATR Trailing Stop");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);
   
   stream = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int id = stream.RegisterStream(0, up_color, "Up");
   id = stream.RegisterStream(id, down_color, "Down");
   id = stream.RegisterInternalStream(id);

   return 0;
}

int deinit()
{
   stream.Release();
   stream = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double CurrUp, PrevUp, CurrDn, PrevDn, LvlUp, LvlDn, PriceHLorC;
int Dir;

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      double atrValue = iATR(_Symbol, _Period, atr_period, i);
      double atrValue1 = iATR(_Symbol, _Period, atr_period, i + 1);
      if (i == Bars - 1 - minBars)
      {
         CurrUp = Close[i] - atrValue * Factor;
         PrevUp = Close[i + 1] - atrValue1 * Factor;
         CurrDn = Close[i] + atrValue * Factor;
         PrevDn = Close[i + 1] + atrValue1 * Factor;

         if (CurrUp > PrevUp)
            Dir = 1;
         LvlUp = CurrUp;
         if (CurrDn < PrevDn)
            Dir = -1;
         LvlDn = CurrDn;
      }
      else
      {
         CurrUp = Close[i] - atrValue * Factor;
         CurrDn = Close[i] + atrValue * Factor;
      }
      double trailingStopv = EMPTY_VALUE; 
      if (Dir == 1)
      {
         if (CurrUp > LvlUp)
         {
            trailingStopv = CurrUp - Distance;
            LvlUp = CurrUp;
         }
         else
         {
            trailingStopv = LvlUp - Distance;
         }
         if (Mode == ModeClose)
            PriceHLorC = Close[i];
         else
            PriceHLorC = Low[i];

         if (PriceHLorC < trailingStopv)
         {
            Dir = -1;
            LvlDn = DBL_MAX;
         }
      }

      if (Dir == -1)
      {
         if (CurrDn < LvlDn)
         {
            trailingStopv = CurrDn + Distance;
            LvlDn = CurrDn;
         }
         else
            trailingStopv = LvlDn + Distance;

         if (Mode == ModeClose)
            PriceHLorC = Close[i];
         else
            PriceHLorC = High[i];

         if (PriceHLorC > trailingStopv)
         {
            Dir = 1;
            LvlUp = -DBL_MAX;
         }
      }

      if (Close[i] > trailingStopv)
      {
         stream.Set(trailingStopv, i, 1);
      }
      else
      {
         stream.Set(trailingStopv, i, 0);
      }
   }
   return 0;
}
