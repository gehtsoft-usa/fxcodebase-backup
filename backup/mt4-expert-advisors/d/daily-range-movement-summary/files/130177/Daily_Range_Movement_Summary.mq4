// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67334

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
#property version   "1.6"
#property strict

#property indicator_chart_window

enum ShowMode
{
   ShowInPips, // In pips
   ShowInPoints // In points
};

extern int ADRPeriod = 7; // ADR length
extern int ADMPeriod = 7; // ADM length
extern ShowMode show_mode = ShowInPoints; // Values unit
extern ENUM_BASE_CORNER DisplayLocation = CORNER_RIGHT_UPPER; //Display location
extern int x_shift = 0; // X shift
extern int y_shift = 0; // Y shift
extern color labelColor = Red; // Label color
input ENUM_TIMEFRAMES adm_period = PERIOD_CURRENT; // ADM period
input int HourStart = 17;
input string start_time = "090000"; // Start time in hhmmss format
input string stop_time = "170000"; // Stop time in hhmmss format

// Trading time condition v3.0

// Abstract condition v1.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

#ifndef AConditionBase_IMP
#define AConditionBase_IMP

class AConditionBase : public ICondition
{
   int _references;
public:
   AConditionBase()
   {
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "";
   }
};

#endif
// No condition v3.0



#ifndef NoCondition_IMP
#define NoCondition_IMP

class NoCondition : public AConditionBase
{
public:
   bool IsPass(const int period, const datetime date) { return true; }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "No condition";
   }
};

#endif

#ifndef TradingTimeCondition_IMP
#define TradingTimeCondition_IMP

int ParseTime(const string time, string &error)
{
   int hours;
   int minutes;
   int seconds;
   if (StringFind(time, ":") == -1)
   {
      //hh:mm:ss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      hours = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      seconds = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}

// Day of week v1.0

#ifndef DayOfWeek_IMP
   enum DayOfWeek
   {
      DayOfWeekSunday = 0, // Sunday
      DayOfWeekMonday = 1, // Monday
      DayOfWeekTuesday = 2, // Tuesday
      DayOfWeekWednesday = 3, // Wednesday
      DayOfWeekThursday = 4, // Thursday
      DayOfWeekFriday = 5, // Friday
      DayOfWeekSaturday = 6 // Saturday
   };
   #define DayOfWeek_IMP
#endif

ICondition* CreateTradingTimeCondition(const string startTime, const string endTime, bool useWeekly,
   const DayOfWeek startDay, const string weekStartTime, const DayOfWeek stopDay, 
   const string weekEndTime, string &error)
{
   int _startTime = ParseTime(startTime, error);
   if (_startTime == -1)
      return NULL;
   int _endTime = ParseTime(endTime, error);
   if (_endTime == -1)
      return NULL;
   if (!useWeekly)
   {
      if (_startTime == _endTime)
         return new NoCondition();
      return new TradingTimeCondition(_startTime, _endTime);
   }

   int _weekStartTime = ParseTime(weekStartTime, error);
   if (_weekStartTime == -1)
      return NULL;
   int _weekEndTime = ParseTime(weekEndTime, error);
   if (_weekEndTime == -1)
      return NULL;

   return new TradingTimeCondition(_startTime, _endTime, startDay, _weekStartTime, stopDay, _weekEndTime);
}

class TradingTimeCondition : public AConditionBase
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTimeCondition(int startTime, int endTime)
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = false;
   }

   TradingTimeCondition(int startTime, int endTime, const DayOfWeek startDay,
      int weekStartTime, const DayOfWeek stopDay, int weekEndTime)
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = true;
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      _weekStartTime = weekStartTime;
      _weekStopTime = weekEndTime;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }

   void GetStartEndTime(const datetime date, datetime &start, datetime &end)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime referece = StructToTime(current_time);

      start = referece + _startTime;
      end = referece + _endTime;
      if (_startTime > _endTime)
      {
         start -= 86400;
      }
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }
};

class TokyoTimezoneCondition : public TradingTimeCondition
{
public:
   TokyoTimezoneCondition()
      : TradingTimeCondition((-5) * 3600, (-5 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Tokyo TZ: " + (result ? "true" : "false");
   }
};

class NewYorkTimezoneCondition : public TradingTimeCondition
{
public:
   NewYorkTimezoneCondition()
      : TradingTimeCondition(8 * 3600, (8 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "NY TZ: " + (result ? "true" : "false");
   }
};

class LondonTimezoneCondition : public TradingTimeCondition
{
public:
   LondonTimezoneCondition()
      : TradingTimeCondition(3 * 3600, (3 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "London TZ: " + (result ? "true" : "false");
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

// D1 custom hour bar stream v1.1
// ACustomBarStream v1.2

// IBarStream v2.0

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

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

#ifndef ACustomBarStream_IMP
#define ACustomBarStream_IMP

class ACustomBarStream : public IBarStream
{
protected:
   int _references;

   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;

   ACustomBarStream()
   {
      _size = 0;
      _references = 1;
   }
public:
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

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      for (int i = 0; i < _size; ++i)
      {
         if (_dates[_size - 1 - i] <= date)
         {
            period = MathMax(i, 0);
            return true;
         }
      }
      return false;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (_size <= period)
         return false;
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      open = _open[_size - 1 - period];
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (period >= _size)
         return false;
      close = _close[_size - 1 - period];
      open = _open[_size - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] < _close[_size - 1 - period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] > _close[_size - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return _size;
   }
};
#endif
#ifndef D1CustomHourBarStream_IMP
#define D1CustomHourBarStream_IMP

class D1CustomHourBarStream : public ACustomBarStream
{
   string _symbol;
   int _hour;
public:
   D1CustomHourBarStream(const string symbol, int hour)
   {
      _symbol = symbol;
      _hour = hour;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, PERIOD_H1) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, PERIOD_H1, _dates[_size - 1]);

      int periodLength = (int)PERIOD_H1 * 24 * 60;
      for (int i = start; i >= 0; --i)
      {
         datetime h1Time = iTime(_symbol, PERIOD_H1, i);
         datetime barStart = (h1Time / periodLength) * periodLength + _hour * 3600;
         if (barStart > h1Time)
            barStart -= 24 * 3600;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, PERIOD_H1, i);
            _high[_size - 1] = iHigh(_symbol, PERIOD_H1, i);
            _low[_size - 1] = iLow(_symbol, PERIOD_H1, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, PERIOD_H1, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, PERIOD_H1, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, PERIOD_H1, i);
      }
   }
};

#endif
D1CustomHourBarStream* d1Stream;
// Range stream on stream v1.0

// Stream base v1.0



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


#ifndef RangeStreamOnStream_IMP
#define RangeStreamOnStream_IMP

class RangeStreamOnStream : public AStreamBase
{
   IBarStream* _stream;
public:
   RangeStreamOnStream(IBarStream* stream)
   {
      _stream = stream;
      _stream.AddRef();
   }

   ~RangeStreamOnStream()
   {
      _stream.Release();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double high, low;
      if (!_stream.GetHighLow(period, high, low))
         return false;
      val = high - low;
      return true;
   }
};

#endif
// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP



class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   int _references;
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
   }

   ~SmaOnStream()
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
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// Move stream on stream v1.0


#ifndef MoveStreamOnStream_IMP
#define MoveStreamOnStream_IMP
class MoveStreamOnStream : public AStreamBase
{
   IBarStream* _stream;
   string _symbol;
   ENUM_TIMEFRAMES _baseTimeframe;
public:
   MoveStreamOnStream(const string symbol, const ENUM_TIMEFRAMES baseTimeframe, IBarStream* stream)
   {
      _symbol = symbol;
      _baseTimeframe = baseTimeframe;
      _stream = stream;
      _stream.AddRef();
   }

   ~MoveStreamOnStream()
   {
      _stream.Release();
   }

   virtual bool GetValue(const int period, double &val)
   {
      int startIndex;
      if (!_stream.FindDatePeriod(iTime(_symbol, _baseTimeframe, period), startIndex))
         return false;
      int endIndex = 0;
      if (period != 0 && !_stream.FindDatePeriod(iTime(_symbol, _baseTimeframe, period - 1), endIndex))
         return false;
      val = 0;
      for (int i = startIndex; i >= endIndex; --i)
      {
         double open, close;
         if (!_stream.GetOpenClose(i, open, close))
            return false;
         val += MathAbs(close - open);
      }

      return true;
   }
};
#endif
// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
};


IStream *dr;
IStream *adr;
IStream *dm;
IStream *adm;
InstrumentInfo *instr;
TradingTimeCondition* tradingTime;

int init()
{
   IndicatorName = GenerateIndicatorName("DailyRangeMovementSummary");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   d1Stream = new D1CustomHourBarStream(_Symbol, HourStart);
   dr = new RangeStreamOnStream(d1Stream);
   adr = new SmaOnStream(dr, ADRPeriod);
   instr = new InstrumentInfo(_Symbol);
   dm = new MoveStreamOnStream(_Symbol, adm_period, d1Stream);
   adm = new SmaOnStream(dm, ADMPeriod);

   string error;
   tradingTime = CreateTradingTimeCondition(start_time, stop_time, false, 0, "", 0, "", error);
   
   return(0);
}

int deinit()
{
   tradingTime.Release();
   tradingTime = NULL;
   d1Stream.Release();
   d1Stream = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   dr.Release();
   dr = NULL;
   adr.Release();
   adr = NULL;
   dm.Release();
   dm = NULL;
   adm.Release();
   adm = NULL;
   delete instr;
   return(0);
}

int start()
{
   d1Stream.Refresh();
   double open;
   d1Stream.GetOpen(0, open);
   Print(open);
   double adrValue;
   if (!adr.GetValue(1, adrValue))
      return 0;
   double drValue;
   if (!dr.GetValue(0, drValue))
      return 0;

   double admValue;
   if (!adm.GetValue(1, admValue))
      return 0;
   double dmValue;
   if (!dm.GetValue(0, dmValue))
      return 0;

   double divider;
   int numbers;
   if (show_mode == ShowInPips)
   {
      divider = instr.GetPipSize();
      numbers = 1;
   }
   else
   {
      divider = instr.GetPointSize();
      numbers = 0;
   }

   datetime start;
   datetime end;
   tradingTime.GetStartEndTime(Time[0], start, end);
   int fromIndex = iBarShift(_Symbol, adm_period, start);
   int toIndex = iBarShift(_Symbol, adm_period, end);
   double totalMovement = 0;
   for (int i = fromIndex; i >= toIndex; --i)
   {
      totalMovement += MathAbs(iOpen(_Symbol, adm_period, i) - iClose(_Symbol, adm_period, i));
   }

   string adrLabel = IndicatorObjPrefix + "adr";
   double adrPr = (drValue / adrValue) * 100;
   string adrText = "ADR: " + DoubleToStr(adrValue / divider, numbers) + " (" + IntegerToString((int)adrPr) + "%)";
   ObjectCreate(0, adrLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, adrLabel, OBJPROP_CORNER, DisplayLocation); 
   ObjectSetString(0, adrLabel, OBJPROP_TEXT, adrText); 
   ObjectSetString(0, adrLabel, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, adrLabel, OBJPROP_FONTSIZE, 8); 
   ObjectSetInteger(0, adrLabel, OBJPROP_COLOR, labelColor);

   string admLabel = IndicatorObjPrefix + "adm";
   double admPr = (dmValue / admValue) * 100;
   string admText = "ADM: " + DoubleToStr(admValue / divider, numbers) + " (" + IntegerToString((int)admPr) + "%)";
   ObjectCreate(0, admLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, admLabel, OBJPROP_CORNER, DisplayLocation); 
   ObjectSetString(0, admLabel, OBJPROP_TEXT, admText); 
   ObjectSetString(0, admLabel, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, admLabel, OBJPROP_FONTSIZE, 8); 
   ObjectSetInteger(0, admLabel, OBJPROP_COLOR, labelColor);

   string asmLabel = IndicatorObjPrefix + "asm";
   double asm = (totalMovement / (fromIndex - toIndex));
   string asmText = "ASM: " + DoubleToStr(asm / divider, numbers) ;
   ObjectCreate(0, asmLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, asmLabel, OBJPROP_CORNER, DisplayLocation); 
   ObjectSetString(0, asmLabel, OBJPROP_TEXT, asmText); 
   ObjectSetString(0, asmLabel, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, asmLabel, OBJPROP_FONTSIZE, 8); 
   ObjectSetInteger(0, asmLabel, OBJPROP_COLOR, labelColor);

   ObjectSetInteger(0, adrLabel, OBJPROP_XDISTANCE, x_shift);
   ObjectSetInteger(0, adrLabel, OBJPROP_YDISTANCE, y_shift);
   ObjectSetInteger(0, admLabel, OBJPROP_XDISTANCE, x_shift);
   ObjectSetInteger(0, admLabel, OBJPROP_YDISTANCE, y_shift + 20);
   ObjectSetInteger(0, asmLabel, OBJPROP_XDISTANCE, x_shift);
   ObjectSetInteger(0, asmLabel, OBJPROP_YDISTANCE, y_shift + 40);

   switch (DisplayLocation)
   {
      case CORNER_LEFT_LOWER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
         ObjectSetInteger(0, asmLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
         break;
      case CORNER_LEFT_UPPER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
         ObjectSetInteger(0, asmLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
         break;
      case CORNER_RIGHT_LOWER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER); 
         ObjectSetInteger(0, asmLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER); 
         break;
      case CORNER_RIGHT_UPPER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER); 
         ObjectSetInteger(0, asmLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER); 
         break;
   }
   return 0;
}

