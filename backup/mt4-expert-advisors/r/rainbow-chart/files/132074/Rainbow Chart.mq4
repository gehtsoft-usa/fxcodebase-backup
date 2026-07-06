// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69549

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
#property indicator_buffers 256
#property indicator_color1 Red

input int Number = 10; // Number of MAs
input int Length = 2; // MA Period
input ENUM_MA_METHOD MA_Method = MODE_SMA; // MA Method
input color From = Red; // From color
input color To = Green; // To color

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

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP

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

class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif

CustomStream* streams[];

uchar GetRed(color clr)
{
   return clr - (clr >> 8 << 8);
}
uchar GetGreen(color clr)
{
   return clr >> 8 - (clr >> 16 << 16);
}
uchar GetBlue(color clr)
{
   return clr >> 16 - (clr >> 24 << 24);
}

int init()
{
   IndicatorName = GenerateIndicatorName("Rainbow chart");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(256);

   int size = ArraySize(streams);
   ArrayResize(streams, size + Number);
   int redFrom = GetRed(From);
   int greenFrom = GetGreen(From);
   int blueFrom = GetBlue(From);
   int redTo = GetRed(To);
   int greenTo = GetGreen(To);
   int blueTo = GetBlue(To);
   int redStep = (redTo - redFrom) / Number;
   int greenStep = (greenTo - greenFrom) / Number;
   int blueStep = (blueTo - blueFrom) / Number;
   
   for (int i = 1; i <= Number; ++i)
   {
      int clr = (redFrom + redStep * (i - 1)) + ((greenFrom + greenStep * (i - 1)) << 8) + ((blueFrom + blueStep * (i - 1)) << 16);
      streams[i - 1] = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      streams[i - 1].RegisterStream(i - 1, clr, 1, STYLE_SOLID, IntegerToString(Length * i));
   }

   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(streams); ++i)
   {
      delete streams[i];
   }
   ArrayResize(streams, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      for (int i = 0; i < ArraySize(streams); ++i)
      {
         double maValue = iMA(_Symbol, _Period, Length * (i + 1), 0, MA_Method, PRICE_CLOSE, pos);
         streams[i]._stream[pos] = maValue;
      }
   }
   return 0;
}
