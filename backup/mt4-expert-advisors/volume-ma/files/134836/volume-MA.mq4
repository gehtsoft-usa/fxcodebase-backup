// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70003

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
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 5

#property indicator_color1 clrSandyBrown
#property indicator_color2 clrDeepSkyBlue
#property indicator_color3 clrDimGray

#property indicator_level1 30;
#property indicator_levelcolor clrSilver;
#property indicator_levelstyle STYLE_DASHDOTDOT;

// User input
input int MA_Period = 34;
input int MA_Shift = 0;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input double level_1 = 100;        // Level 1
input color level_1_color = Red;   // Level 1 color
input double level_2 = 1000;       // Level 2
input color level_2_color = Blue;  // Level 2 color
input color level_3_color = Green; // Level 3 color

// Buffers
double VolBuffer1[]; // value down
double VolBuffer2[]; // value up

//----
int ExtCountedBars = 0;
int lastcolor = 0;

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
ColoredStream *stream;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   int draw_begin;
   string short_name;

   // indicator buffers mapping, drawing settings and Shift
   IndicatorBuffers(6);

   // Histogram downArrow Red
   SetIndexBuffer(0, VolBuffer1);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexShift(0, MA_Shift);

   // Histogram upArrow Green
   SetIndexBuffer(1, VolBuffer2);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexShift(1, MA_Shift);
   stream = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int id = 2;
   id = stream.RegisterStream(id, level_1_color, "", DRAW_HISTOGRAM);
   id = stream.RegisterStream(id, level_2_color, "", DRAW_HISTOGRAM);
   id = stream.RegisterStream(id, level_3_color, "", DRAW_HISTOGRAM);
   id = stream.RegisterInternalStream(id);

   SetIndexShift(2, MA_Shift);
   SetIndexShift(3, MA_Shift);
   SetIndexShift(4, MA_Shift);
   SetIndexShift(5, MA_Shift);

   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));

   draw_begin = MA_Period - 1;

   switch (MA_Method)
   {
   case 1:
      short_name = "EMA(";
      draw_begin = 0;
      break;
   case 2:
      short_name = "SMMA(";
      break;
   case 3:
      short_name = "LWMA(";
      break;
   default:
      short_name = "SMA(";
   }
   IndicatorShortName(short_name + MA_Period + ")");

   SetIndexDrawBegin(0, draw_begin);

   return (0);
}

void OnDeinit(const int reason)
{
   delete stream;
   stream = NULL;
}

//+------------------------------------------------------------------+
//| Main                                                             |
//+------------------------------------------------------------------+
int start()
{
   if (Bars <= MA_Period)
      return (0);
   ExtCountedBars = IndicatorCounted();

   // check for possible errors
   if (ExtCountedBars < 0)
      return (-1);

   // last counted bar will be recounted
   if (ExtCountedBars > 0)
      ExtCountedBars--;

   switch (MA_Method)
   {
   case 0:
      sma();
      break;
   case 1:
      ema();
      break;
   case 2:
      smma();
      break;
   case 3:
      lwma();
   }
   return (0);
}

int GetColor(double val)
{
   if (val < level_1)
   {
      return 0;
   }
   if (val < level_2)
   {
      return 1;
   }
   return 2;
}

void SetVal(double value, int pos)
{
   stream.Set(value, pos, GetColor(value));
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
{
   double sum = 0;
   int i, pos = Bars - ExtCountedBars - 1;

   // initial accumulation
   if (pos < MA_Period)
      pos = MA_Period;
   for (i = 1; i < MA_Period; i++, pos--)
      sum += Volume[pos];

   while (pos >= 0)
   {
      sum += Volume[pos];
      SetVal(sum / MA_Period, pos);
      sum -= Volume[pos + MA_Period - 1];
      Vcolor(pos);
      pos--;
   }

   // zero initial bars
   if (ExtCountedBars < 1)
      for (i = 1; i < MA_Period; i++)
         VolBuffer1[Bars - i] = 0;
}

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
{
   double pr = 2.0 / (MA_Period + 1);
   int pos = Bars - 2;

   if (ExtCountedBars > 2)
      pos = Bars - ExtCountedBars - 1;

   while (pos >= 0)
   {
      if (pos == Bars - 2)
         SetVal(Volume[pos + 1], pos + 1);
      SetVal(Volume[pos] * pr + stream._data[pos + 1] * (1 - pr), pos);
      Vcolor(pos);
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
{
   double sum = 0;
   int i, k, pos = Bars - ExtCountedBars + 1;

   pos = Bars - MA_Period;
   if (pos > Bars - ExtCountedBars)
      pos = Bars - ExtCountedBars;
   while (pos >= 0)
   {
      if (pos == Bars - MA_Period)
      {
         // initial accumulation
         for (i = 0, k = pos; i < MA_Period; i++, k++)
         {
            sum += Volume[k];
            // zero initial bars
            SetVal(0, k);
         }
      }
      else
         sum = stream._data[pos + 1] * (MA_Period - 1) + Volume[pos];
      SetVal(sum / MA_Period, pos);
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
{
   double sum = 0.0, lsum = 0.0;
   double price;
   int i, weight = 0, pos = Bars - ExtCountedBars - 1;
   //---- initial accumulation
   if (pos < MA_Period)
      pos = MA_Period;
   for (i = 1; i <= MA_Period; i++, pos--)
   {
      price = Volume[pos];
      sum += price * i;
      lsum += price;
      weight += i;
   }
   //---- main calculation loop
   pos++;
   i = pos + MA_Period;
   while (pos >= 0)
   {
      SetVal(sum / weight, pos);
      if (pos == 0)
         break;
      pos--;
      i--;
      price = Volume[pos];
      sum = sum - lsum + price * MA_Period;
      lsum -= Volume[i];
      lsum += price;
   }
   //---- zero initial bars
   if (ExtCountedBars < 1)
      for (i = 1; i < MA_Period; i++)
         SetVal(0, Bars - i);
}

//+------------------------------------------------------------------+
//| Color depends on gain or loss and previous volume                |
//+------------------------------------------------------------------+
// 1 - histo down red
// 2 - histo up green
// 3 - line white

void Vcolor(int p)
{

   if (Volume[p + 1] > Volume[p])
   {
      VolBuffer1[p] = Volume[p];
      VolBuffer2[p] = 0;
      lastcolor = Red;
   }

   if (Volume[p + 1] < Volume[p])
   {
      VolBuffer1[p] = 0;
      VolBuffer2[p] = Volume[p];
      lastcolor = Green;
   }

   if (Volume[p + 1] == Volume[p])
   {
      if (lastcolor == Red)
      {
         VolBuffer1[p] = Volume[p];
         VolBuffer2[p] = 0;
      }
      if (lastcolor == Green)
      {
         VolBuffer1[p] = 0;
         VolBuffer2[p] = Volume[p];
      }
   }
}

//+------------------------------------------------------------------+
