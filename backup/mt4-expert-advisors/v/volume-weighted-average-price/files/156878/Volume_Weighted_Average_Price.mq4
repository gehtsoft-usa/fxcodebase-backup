//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75259

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "VWAP"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0xFF6229
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Upper Band #1"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Lower Band #1"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Upper Band #2"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Olive
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Lower Band #2"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Olive
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Upper Band #3"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Teal
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Lower Band #3"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Teal
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

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
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0

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


// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

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
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
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


#endif
// Bar stream v2.1



#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh() { }
};

#endif

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL


// Float stream v2.3

class FloatStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif


//Base implementation of stream based on another stream 
//v1.1

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
      if (_source != NULL)
      {
         _source.AddRef();
      }
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

// Cumulative on stream v1.1

#ifndef CumOnStream_IMP
#define CumOnStream_IMP

class CumOnStream : public AOnStream
{
   double _buffer[];
public:
   CumOnStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double current;
      if (!_source.GetValue(period, current))
         return false;
      
      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - 1 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current;
      }
      else 
      {
         _buffer[bufferIndex] = current;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

class NewBarState
{
   datetime _last;
public:
   NewBarState()
   {
      _last = 0;
   }
   void Clear()
   {
      _last = 0;
   }
   bool IsNew(datetime date)
   {
      bool isnew = _last != date;
      _last = date;
      return isnew;
   }
};

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

datetime Timestamp(int year, int month, int day, int hour, int minute, int second)
{
   MqlDateTime time;
   time.year = year;
   time.mon = month;
   time.day = day;
   time.hour = hour;
   time.min = minute;
   time.sec = second;
   return StructToTime(time);
}

class PineScriptTime
{
public:
   static int Hour(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.hour;
   }
   static int Year(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.year;
   }
   static int DayOfWeek(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day_of_week;
   }
   static int Sunday()
   {
      return 0;
   }
   static int Monday()
   {
      return 1;
   }
   static int Tuesday()
   {
      return 2;
   }
   static int Wednesday()
   {
      return 3;
   }
   static int Thursday()
   {
      return 4;
   }
   static int Friday()
   {
      return 5;
   }
   static int Saturday()
   {
      return 6;
   }
};

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// PineScript request.* functions
// v1.0

class Request
{
public:
   static double Earnings(string ticker, string field, string gaps, string lookagead, bool ignore_invalid_symbol, string currency)
   {
      return EMPTY_VALUE;
   }
   static double Dividends(string ticker, string field, string gaps, string lookagead, bool ignore_invalid_symbol, string currency)
   {
      return EMPTY_VALUE;
   }
   static double Splits(string ticker, string field, string gaps, string lookagead, bool ignore_invalid_symbol, string currency)
   {
      return EMPTY_VALUE;
   }
};
// PineScript syminfo.* functions
// v1.0

class SymInfo
{
public:
   static string TickerId()
   {
      return _Symbol;
   }
   
   static string Currency()
   {
      return SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
   }
};
// PineScript timeframe.* functions
// v1.0

class Timeframe
{
public:
   static bool Change(string timeframe, int pos)
   {
      int bars = iBars(_Symbol, _Period);
      if (bars <= pos + 1)
      {
         return true;
      }
      datetime currentBar = iTime(_Symbol, _Period, pos);
      datetime prevBar = iTime(_Symbol, _Period, pos + 1);
      ENUM_TIMEFRAMES tf = GetTimeframe(timeframe);
      return iBarShift(_Symbol, tf, currentBar) != iBarShift(_Symbol, tf, prevBar);
   }
   
   static bool IsDWM()
   {
      switch (_Period)
      {
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }
};
// Custom boolean stream v1.1

#ifndef BoolStream_IMPL
#define BoolStream_IMPL

// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, bool &val) = 0;
   virtual bool GetValue(const int period, int &val) = 0;
};

#endif

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   bool _stream[];
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, bool &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
   
   bool GetValue(const int period, int &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};
#endif
// Vwap on stream v1.2


// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, int &val) = 0;
};

#endif

// Date/time Stream v.1.0

#ifndef IDateTimeStream_IMPL
#define IDateTimeStream_IMPL

interface IDateTimeStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, datetime &val) = 0;
};

#endif
// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL


class AIntStream : public IIntStream
{
   int _refs;   
public:
   AIntStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif

// Volume stream v1.0

#ifndef VolumeStream_IMP
#define VolumeStream_IMP

class VolumeStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   VolumeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   ~VolumeStream()
   {
   }

   bool GetValue(const int period, int &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
      {
         return false;
      }
      val = iVolume(_symbol, _timeframe, period);
      return true;
   }
   
   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
};
#endif
// Abstract date/time stream v1.0

#ifndef ADateTimeStream_IMPL
#define ADateTimeStream_IMPL


class ADateTimeStream : public IDateTimeStream
{
   int _refs;   
public:
   ADateTimeStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif

// Date/time stream v1.0

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

class DateTimeStream : public ADateTimeStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   ~DateTimeStream()
   {
   }

   bool GetValue(const int period, datetime &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
      {
         return false;
      }
      val = iTime(_symbol, _timeframe, period);
      return true;
   }
   
   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#endif
// Array v1.4
// Array interface v1.0

// int array interface v1.2

class IIntArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual void Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual void Set(int index, int value) = 0;
   virtual IIntArray* Slice(int from, int to) = 0;
   virtual IIntArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
};
// Line array interface v1.2
// Line object v1.2

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   color _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window)
   {
      _refs = 1;
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }

   void SetXY1(int x, double y)
   {
      _x1 = x;
      _y1 = y;
   }
   static void SetXY1(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY1(x, y);
   }
   
   void SetXY2(int x, double y)
   {
      _x2 = x;
      _y2 = y;
   }
   static void SetXY2(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY2(x, y);
   }

   void SetX1(int x) { _x1 = x; }
   static void SetX1(Line* line, int x) { if (line == NULL) { return; } line.SetX1(x); }
   void SetX2(int x) { _x2 = x; }
   static void SetX2(Line* line, int x) { if (line == NULL) { return; } line.SetX2(x); }
   void SetY1(double y) { _y1 = y; }
   static void SetY1(Line* line, double y) { if (line == NULL) { return; } line.SetY1(y); }
   void SetY2(double y) { _y2 = y; }
   static void SetY2(Line* line, double y) { if (line == NULL) { return; } line.SetY2(y); }

   int GetX1() { return _x1; }
   static int GetX1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
};

class ILineArray
{
public:
   virtual void Unshift(Line* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Line* value) = 0;
   virtual Line* Pop() = 0;
   virtual Line* Get(int index) = 0;
   virtual void Set(int index, Line* value) = 0;
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
   virtual Line* Shift() = 0;
   virtual Line* Remove(int index) = 0;
};
// float array interface v1.2

class IFloatArray
{
public:
   virtual void Unshift(double value) = 0;
   virtual int Size() = 0;
   virtual void Push(double value) = 0;
   virtual double Pop() = 0;
   virtual double Get(int index) = 0;
   virtual void Set(int index, double value) = 0;
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
   virtual double Shift() = 0;
   virtual double Remove(int index) = 0;
};


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.3

// Collection of lines v1.1

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL



class LinesCollection
{
   string _id;
   Line* _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int _max;
public:
   static Line* Get(Line* line, int index)
   {
      if (line == NULL)
      {
         return NULL;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new LinesCollection("");
         }
      }
      else
      {
      
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(line))
      {
         return;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(line);
   }

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped());
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      line.Release();
      return line;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   int Count()
   {
      return ArraySize(_array);
   }

   Line* GetFirst()
   {
      return _array[0];
   }

   Line* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }
   
   int FindIndex(Line* line)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == line)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Line* line)
   {
      int index = FindIndex(line);
      if (index == -1)
      {
         return false;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   
   void Add(Line* line)
   {
      int index = FindIndex(line);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if (line != NULL)
      {
         line.AddRef();
      }
   }

   void RedrawLines()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(LinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LinesCollection* LinesCollection::_collections[];
LinesCollection* LinesCollection::_all;
int LinesCollection::_max = 50;
#endif

class LineArray : public ILineArray
{
   Line* _array[];
   int _defaultSize;
   Line* _defaultValue;
public:
   LineArray(int size, Line* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~LineArray()
   {
      Clear();
   }

   ILineArray* Clear()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            LinesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Line* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(Line* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Line* Pop()
   {
      int size = ArraySize(_array);
      Line* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Line* Shift()
   {
      return Remove(0);
   }

   Line* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, Line* value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
   
   ILineArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Line* Remove(int index)
   {
      int size = ArraySize(_array);
      Line* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
};
#endif
// Int array v1.3


class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IIntArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Shift()
   {
      return Remove(0);
   }

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, int value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IIntArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
// Float array v1.3


class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }

   IFloatArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(_array);
      double value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   double Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, double value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   double Shift()
   {
      return Remove(0);
   }
   
   IFloatArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   double Remove(int index)
   {
      int size = ArraySize(_array);
      double value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v1.4
// Box array interface v1.1
#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.3

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   color _bgcolor;
   color _borderColor;
   ENUM_TIMEFRAMES _timeframe;
   string _extend;

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window)
   {
      _refs = 1;
      _textColor = White;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static Box* Copy(Box* box) { if (box == NULL) { return NULL; } return box.Copy(); }
   Box* Copy()
   {
      Box* copy = new Box(_left, _top, _right, _bottom, _id, _collectionId, _window);
      copy.SetBgColor(_bgcolor);
      copy.SetBorderColor(_borderColor);
      copy.SetExtend(_extend);
      copy.SetText(_text);
      copy.SetTextHAlign(_textHAlign);
      copy.SetTextVAlign(_textVAlign);
      copy.SetTextSize(_textSize);
      copy.SetTextColor(_textColor);
      return copy;
   }

   static double GetTop(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }
   double GetTop() { return _top; }
   static double GetBottom(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }
   double GetBottom() { return _bottom; }
   static int GetLeft(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetRight(); }
   int GetRight() { return _right; }

   static void SetTop(Box* box, double value) { if (box == NULL) { return; } box.SetTop(value); }
   void SetTop(double value) { _top = value; }
   static void SetBottom(Box* box, double value) { if (box == NULL) { return; } box.SetBottom(value); }
   void SetBottom(double value) { _bottom = value; }
   static void SetLeft(Box* box, int value) { if (box == NULL) { return; } box.SetLeft(value); }
   void SetLeft(int value) { _left = value; }
   static void SetRight(Box* box, int value) { if (box == NULL) { return; } box.SetRight(value); }
   void SetRight(int value) { _right = value; }

   static void SetBgColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

   static void SetText(Box* box, string text) { if (box == NULL) { return; } box.SetText(text); }
   Box* SetText(string text) { _text = text; return &this; }
   static void SetTextHAlign(Box* box, string halign) { if (box == NULL) { return; } box.SetTextHAlign(halign); }
   Box* SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void SetTextVAlign(Box* box, string valign) { if (box == NULL) { return; } box.SetTextVAlign(valign); }
   Box* SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void SetTextSize(Box* box, string size) { if (box == NULL) { return; } box.SetTextSize(size); }
   Box* SetTextSize(string size) { _textSize = size; return &this; }
   static void SetTextColor(Box* box, color clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(color clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int pos1 = 0;
      if (_extend == "left" || _extend == "both")
      {
         pos1 = iBars(_Symbol, _timeframe) - 1;
      }
      else
      {
         pos1 = iBars(_Symbol, _timeframe) - _left - 1;
      }
      datetime left = iTime(_Symbol, _timeframe, MathMax(0, pos1));
      int pos2 = 0;
      if (_extend == "right" || _extend == "both")
      {
         pos2 = 0;
      }
      else
      {
         pos2 = iBars(_Symbol, _timeframe) - _right - 1;
      }
      datetime right = iTime(_Symbol, _timeframe, MathMax(0, pos2));
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _bgcolor);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, right);
   }
};

#endif

class IBoxArray
{
public:
   virtual void Unshift(Box* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Box* value) = 0;
   virtual Box* Pop() = 0;
   virtual Box* Get(int index) = 0;
   virtual void Set(int index, Box* value) = 0;
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
   virtual Box* Shift() = 0;
   virtual Box* Remove(int index) = 0;
};
// Collection of boxes v1.1

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL



class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   string GetId()
   {
      return _id;
   }

   int Count()
   {
      return ArraySize(_array);
   }

   Box* GetFirst()
   {
      return _array[0];
   }

   Box* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }

   static Box* Get(Box* box, int index)
   {
      if (box == NULL)
      {
         return NULL;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new BoxesCollection("");
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Box* box)
   {
      if (box == NULL)
      {
         return;
      }
      if (!_all.RemoveItem(box))
      {
         return;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - left - 1);
      string boxId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Box* box = new Box(left, top, right, bottom, boxId, id, WindowOnDropped());
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      return box;
   }
   
   static void SetMaxBoxes(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawBoxs();
      }
   }
private:
   int FindIndex(Box* box)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == box)
         {
            return i;
         }
      }
      return -1;
   }

   bool RemoveItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return false;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   void DeleteItem(Box* box)
   {
      if (RemoveItem(box))
      {
         box.Release();
      }
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
   }

   void RedrawBoxs()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(BoxesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static BoxesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
BoxesCollection* BoxesCollection::_collections[];
BoxesCollection* BoxesCollection::_all;
int BoxesCollection::_max = 50;
#endif

class BoxArray : public IBoxArray
{
   Box* _array[];
   int _defaultSize;
   Box* _defaultValue;
public:
   BoxArray(int size, Box* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~BoxArray()
   {
      Clear();
   }

   IBoxArray* Clear()
   {
      int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            BoxesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Box* Pop()
   {
      int size = ArraySize(_array);
      Box* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Box* Shift()
   {
      return Remove(0);
   }

   Box* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, Box* value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
   
   IBoxArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Box* Remove(int index)
   {
      int size = ArraySize(_array);
      Box* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
};
#endif

class Array
{
public:
   static void Unshift(IIntArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IFloatArray* array, double value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IBoxArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }

   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static Box* Pop(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static Box* Get(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   
   static void Set(IIntArray* array, int index, int value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IFloatArray* array, int index, double value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(ILineArray* array, int index, Line* value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IBoxArray* array, int index, Box* value) { if (array == NULL) { return; } array.Set(index, value); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Line* Remove(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }

   static int PercentRank(IIntArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return EMPTY_VALUE; }
      int target = array.Get(index);
      if (target == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != EMPTY_VALUE && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   static double PercentRank(IFloatArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return EMPTY_VALUE; }
      double target = array.Get(index);
      if (target == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         double current = array.Get(i);
         if (current != EMPTY_VALUE && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }

   static int Max(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static double Max(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static int Min(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   static double Min(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }

   static int Sum(IIntArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      int sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(IFloatArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      double sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   
   static double Stdev(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         int value = array.Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   static double Stdev(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         double value = array.Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
};




#ifndef VwapOnStream_IMP
#define VwapOnStream_IMP

class VwapStdev : public AOnStream
{
   IIntStream* volume;
   IBoolStream* anchor;
   double stdev;
public:
   VwapStdev(IStream *source, IIntStream* volume, IBoolStream* anchor, double stdev)
      :AOnStream(source)
   {
      this.volume = volume;
      volume.AddRef();
      this.anchor = anchor;
      anchor.AddRef();
      this.stdev = stdev;
   }
   
   ~VwapStdev()
   {
      volume.Release();
      anchor.Release();
   }

   bool GetValue(const int period, double &val, double &upper, double &lower)
   {
      int totalBars = volume.Size();
      if (period > totalBars)
         return false;
         
      double sum1 = 0;
      double sum2 = 0;
      FloatArray* arr = new FloatArray(0, 0);
      for (int i = period; i < Size(); ++i)
      {
         int current;
         if (!anchor.GetValue(i, current))
         {
            val = EMPTY_VALUE;
            upper = EMPTY_VALUE;
            lower = EMPTY_VALUE;
            return false;
         }
         if (current == 1)
         {
            break;
         }
         double value;
         if (!_source.GetValue(i, value))
         {
            val = EMPTY_VALUE;
            upper = EMPTY_VALUE;
            lower = EMPTY_VALUE;
            return false;
         }
         int volumeValue;
         if (!volume.GetValue(i, volumeValue))
         {
            val = EMPTY_VALUE;
            upper = EMPTY_VALUE;
            lower = EMPTY_VALUE;
            return false;
         }
         sum1 += value * volumeValue;
         sum2 += volumeValue;
         arr.Push(sum2 != 0 ? sum1 / sum2 : 0);
      }
      if (sum2 == 0)
      {
         val = EMPTY_VALUE;
         upper = EMPTY_VALUE;
         lower = EMPTY_VALUE;
         return false;
      }
      val = sum2 != 0 ? sum1 / sum2 : 0;
      double stdevValue = Array::Stdev(arr);
      delete arr;
      upper = val + stdevValue * stdev;
      lower = val - stdevValue * stdev;
      return true;
   }
   bool GetValue(const int period, double &val)
   {
      int totalBars = volume.Size();
      if (period > totalBars)
         return false;
         
      double sum1 = 0;
      double sum2 = 0;
      for (int i = period; i < Size(); ++i)
      {
         int current;
         if (!anchor.GetValue(i, current))
         {
            val = EMPTY_VALUE;
            return false;
         }
         if (current == 1)
         {
            break;
         }
         double value;
         if (!_source.GetValue(i, value))
         {
            val = EMPTY_VALUE;
            return false;
         }
         int volumeValue;
         if (!volume.GetValue(i, volumeValue))
         {
            val = EMPTY_VALUE;
            return false;
         }
         sum1 += value * volumeValue;
         sum2 += volumeValue;
      }
      val = sum2 != 0 ? sum1 / sum2 : 0;
      return true;
   }
};

class VwapOnStream : public AOnStream
{
   IIntStream* _volume;
   IDateTimeStream* _dates;
public:
   VwapOnStream(IStream *source, IIntStream* volume, IDateTimeStream* dates)
      :AOnStream(source)
   {
      _volume = volume;
      _volume.AddRef();
      _dates = dates;
      _dates.AddRef();
   }
   
   ~VwapOnStream()
   {
      _volume.Release();
      _dates.Release();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _volume.Size();
      if (period > totalBars)
         return false;
         
      double sum1 = 0;
      double sum2 = 0;
      datetime startDate;
      if (!_dates.GetValue(period, startDate))
      {
         val = EMPTY_VALUE;
         return false;
      }
      int startDay = TimeDay(startDate);
      for (int i = period; i < Size(); ++i)
      {
         datetime current;
         if (!_dates.GetValue(i, current))
         {
            val = EMPTY_VALUE;
            return false;
         }
         int currentDay = TimeDay(current);
         if (currentDay != startDay)
         {
            break;
         }
         double value;
         if (!_source.GetValue(i, value))
         {
            val = EMPTY_VALUE;
            return false;
         }
         int volume;
         if (!_volume.GetValue(i, volume))
         {
            val = EMPTY_VALUE;
            return false;
         }
         sum1 += value * volume;
         sum2 += volume;
      }
      val = sum2 != 0 ? sum1 / sum2 : 0;
      return true;
   }
};

class VwapOnStreamFactory
{
public:
   static IStream* Create(const string symbol, ENUM_TIMEFRAMES timeframe, IStream *source)
   {
      VolumeStream* volume = new VolumeStream(symbol, timeframe);
      DateTimeStream* dates = new DateTimeStream(symbol, timeframe);
      VwapOnStream* stream = new VwapOnStream(source, volume, dates);
      volume.Release();
      dates.Release();
      return stream;
   }
   
   static IStream* Create(IStream *source, IIntStream* volume, IDateTimeStream* dates)
   {
      return new VwapOnStream(source, volume, dates);
   }
   
   static VwapStdev* Create(const string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, IBoolStream* anchor, double stdev)
   {
      VolumeStream* volume = new VolumeStream(symbol, timeframe);
      VwapStdev* stream = new VwapStdev(source, volume, anchor, stdev);
      volume.Release();
      return stream;
   }
};

#endif
// Pine-script like safe operations
// v.1.2

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
double SafeMathFloor(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathFloor(value);
}
input bool param1 = false; // Hide VWAP on 1D or Above
input string param2 = "Session"; // Anchor Period
input PriceType param3 = PriceTypical; // Source
input int param4 = 0; // Offset
input string param5 = "Standard Deviation"; // Bands Calculation Mode
input bool param6 = true; // 
input double param7 = 1.0; // Bands Multiplier #1
input bool param8 = false; // 
input double param9 = 2.0; // Bands Multiplier #2
input bool param10 = false; // 
input double param11 = 3.0; // Bands Multiplier #3
input int bars_limit = 100000; // Bars limit
int hideonDWM;
string anchor;
IStream* param3Stream;
IStream* src;
int offset;
string calcModeInput;
int showBand_1;
double bandMult_1;
int showBand_2;
double bandMult_2;
int showBand_3;
double bandMult_3;
FloatStream* cum1X;
CumOnStream* cum1;
FloatStream* vwap1Source;
BoolStream* vwap1Anchor;
VwapStdev* vwap1;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];

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

int init()
{
   IndicatorBuffers(7);
   int id = 0;
   hideonDWM = param1;
   anchor = param2;
   param3Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param3);
   src = param3Stream;
   offset = param4;
   calcModeInput = param5;
   showBand_1 = param6;
   bandMult_1 = param7;
   showBand_2 = param8;
   bandMult_2 = param9;
   showBand_3 = param10;
   bandMult_3 = param11;
   cum1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum1 = new CumOnStream(cum1X);
   vwap1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   vwap1Anchor = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   vwap1 = VwapOnStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, vwap1Source, vwap1Anchor, 1);
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   IndicatorObjPrefix = GenerateIndicatorPrefix("VWAP");
   IndicatorShortName("Volume Weighted Average Price");
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param3Stream.Release();
   cum1X.Release();
   cum1.Release();
   vwap1Source.Release();
   vwap1Anchor.Release();
   vwap1.Release();
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
      cum1X.Init();
      vwap1Source.Init();
      vwap1Anchor.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
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
      string BANDS_GROUP = "Bands Settings";
      string CALC_MODE_TOOLTIP = "Determines the units used to calculate the distance of the bands. When 'Percentage' is selected, a multiplier of 1 means 1%.";
      cum1X.SetValue(pos, tick_volume[pos]);
      double cum1Value;
      if (!cum1.GetValue(pos, cum1Value)) { cum1Value = EMPTY_VALUE; }
      if ((pos == 0) && (cum1Value == 0))
      {
         Runtime::Error("No volume is provided by the data vendor.");
      }
      double new_earnings = Request::Earnings(SymInfo::TickerId(), "actual", "gaps_on", "lookahead_on", true, SymInfo::Currency());
      double new_dividends = Request::Dividends(SymInfo::TickerId(), "gross", "gaps_on", "lookahead_on", true, SymInfo::Currency());
      double new_split = Request::Splits(SymInfo::TickerId(), "denominator", "gaps_on", "lookahead_on", true, SymInfo::Currency());
      int switch1Result;
      if ((anchor == "Earnings"))
      {
         switch1Result = !((new_earnings) == EMPTY_VALUE);
      }
      else if ((anchor == "Dividends"))
      {
         switch1Result = !((new_dividends) == EMPTY_VALUE);
      }
      else if ((anchor == "Splits"))
      {
         switch1Result = !((new_split) == EMPTY_VALUE);
      }
      else if ((anchor == "Session"))
      {
         switch1Result = Timeframe::Change("D", pos);
      }
      else if ((anchor == "Week"))
      {
         switch1Result = Timeframe::Change("W", pos);
      }
      else if ((anchor == "Month"))
      {
         switch1Result = Timeframe::Change("M", pos);
      }
      else if ((anchor == "Quarter"))
      {
         switch1Result = Timeframe::Change("3M", pos);
      }
      else if ((anchor == "Year"))
      {
         switch1Result = Timeframe::Change("12M", pos);
      }
      else if ((anchor == "Decade"))
      {
         switch1Result = Timeframe::Change("12M", pos) && (PineScriptTime::Year(time[pos]) % 10 == 0);
      }
      else if ((anchor == "Century"))
      {
         switch1Result = Timeframe::Change("12M", pos) && (PineScriptTime::Year(time[pos]) % 100 == 0);
      }
      else
      {
         switch1Result = false;
      }
      int isNewPeriod = switch1Result;
      int isEsdAnchor = (((anchor == "Earnings") || (anchor == "Dividends")) || (anchor == "Splits"));
      double srcValue_1;
      if (!src.GetValue(pos + 1, srcValue_1)) { srcValue_1 = EMPTY_VALUE; }
      if (((srcValue_1) == EMPTY_VALUE) && !isEsdAnchor)
      {
         isNewPeriod = true;
      }
      double vwapValue = EMPTY_VALUE;
      double upperBandValue1 = EMPTY_VALUE;
      double lowerBandValue1 = EMPTY_VALUE;
      double upperBandValue2 = EMPTY_VALUE;
      double lowerBandValue2 = EMPTY_VALUE;
      double upperBandValue3 = EMPTY_VALUE;
      double lowerBandValue3 = EMPTY_VALUE;
      if (!(hideonDWM && Timeframe::IsDWM()))
      {
         double srcValue;
         if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
         vwap1Source.SetValue(pos, srcValue);
         vwap1Anchor.SetValue(pos, isNewPeriod);
         double vwap1Value1;
         double vwap1Value2;
         double vwap1Value3;
         if (!vwap1.GetValue(pos, vwap1Value1, vwap1Value2, vwap1Value3)) { vwap1Value1 = EMPTY_VALUE; vwap1Value2 = EMPTY_VALUE; vwap1Value3 = EMPTY_VALUE; }
         double _vwap = vwap1Value1;
         double _stdevUpper = vwap1Value2;
         double _ = vwap1Value3;
         vwapValue = _vwap;
         double stdevAbs = SafeMinus(_stdevUpper, _vwap);
         double bandBasis = ((calcModeInput == "Standard Deviation") ? stdevAbs : SafeMultiply(_vwap, 0.01));
         upperBandValue1 = SafePlus(_vwap, SafeMultiply(bandBasis, bandMult_1));
         lowerBandValue1 = SafeMinus(_vwap, SafeMultiply(bandBasis, bandMult_1));
         upperBandValue2 = SafePlus(_vwap, SafeMultiply(bandBasis, bandMult_2));
         lowerBandValue2 = SafeMinus(_vwap, SafeMultiply(bandBasis, bandMult_2));
         upperBandValue3 = SafePlus(_vwap, SafeMultiply(bandBasis, bandMult_3));
         lowerBandValue3 = SafeMinus(_vwap, SafeMultiply(bandBasis, bandMult_3));
      }
      plot1[pos] = vwapValue;
      plot2[pos] = upperBandValue1;
      double upperBand_1 = plot2[pos];
      plot3[pos] = lowerBandValue1;
      double lowerBand_1 = plot3[pos];
      plot4[pos] = upperBandValue2;
      double upperBand_2 = plot4[pos];
      plot5[pos] = lowerBandValue2;
      double lowerBand_2 = plot5[pos];
      plot6[pos] = upperBandValue3;
      double upperBand_3 = plot6[pos];
      plot7[pos] = lowerBandValue3;
      double lowerBand_3 = plot7[pos];
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
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 