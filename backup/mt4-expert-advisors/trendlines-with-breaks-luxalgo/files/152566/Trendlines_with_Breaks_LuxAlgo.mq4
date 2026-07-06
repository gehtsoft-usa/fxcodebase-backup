//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74159

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_label1 "Upper Break"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 0x26a69a
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Lower Break"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 0xef5350
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Upper"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x26a69a
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Lower"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0xef5350
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

input int length = 14;
input double k = 1; // Slope
input string method = "Atr"; // Slope Calculation Method
input bool show = false; // Show Only Confirmed Breakouts
input int bars_limit = 100000; // Bars limit
double slope_ph[], slope_pl[], upper[], lower[], src[], single_upper[], single_lower[], ph[], pl[];

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

// Pivot high stream v1.3

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
// Simple price stream v1.2

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
   int _periodShift;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price, int periodShift = 0)
      :AStream(symbol, timeframe)
   {
      _price = __price;
      _periodShift = periodShift;
   }

   bool GetValue(const int period, double &val)
   {
      ResetLastError();
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) + iOpen(_symbol, _timeframe, period + _periodShift)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period + _periodShift);
               if (iOpen(_symbol, _timeframe, period + _periodShift) > iClose(_symbol, _timeframe, period + _periodShift))
                  val = (iHigh(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period + _periodShift);
            break;
      }
      if (GetLastError() != ERR_NO_ERROR)
      {
         return false;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   bool GetValue(const int period, double &val)
   {
      double center;
      if (!_source.GetValue(period + _rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < _rightBars; ++i)
      {
         if (!_source.GetValue(period + i, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < _leftBars; ++ii)
      {
         if (!_source.GetValue(period + ii + _rightBars, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }
};
// Pivot low stream v1.3



class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   bool GetValue(const int period, double &val)
   {
      double center;
      if (!_source.GetValue(period + _rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < _rightBars; ++i)
      {
         if (!_source.GetValue(period + i, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < _leftBars; ++ii)
      {
         if (!_source.GetValue(period + ii + _rightBars, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }
};


// True range stream v2.1

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         if (_handleNa)
         {
            val = CalcFirst(pos);
            return true;
         }
         return false;
      }
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
private:
   double CalcFirst(int pos)
   {
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));

      return MathMax(lc, MathMax(hl, hc));
   }
};
#endif


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

// Average true range stream v2.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
   }
};
#endif
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
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};

// Variance on stream v1.0



class VarianceOnStream : public AOnStream
{
   int _length;
   bool _biased;
public:
   VarianceOnStream(IStream *source, int length, bool biased)
      :AOnStream(source)
   {
      _length = length;
      _biased = biased;
   }

   bool GetValue(const int period, double &val)
   {
      if (_length == 1)
      {
         return false;
      }
      if (!_biased)
      {
         return false; // not supported yet
      }
      //period is an index for time series (0 = latest)
      int totalBars = Bars;

      double values[];
      ArrayResize(values, _length);

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current;
         if (!_source.GetValue(period + i, current))
         {
            return false;
         }
         values[i] = current;
         sum += current;
      }
      double diffSumm = 0;
      for (int i = 0; i < _length; ++i)
      {
         diffSumm += MathSqrt(values[i] - sum);
      }
      val = diffSumm / (_length - 1);
      return true;
   }
};
IStream* ta_pivothigh1;
IStream* ta_pivotlow2;
IStream* ta_atr3;
CustomStream* ta_variance4Source;
IStream* ta_variance4;


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


// Collection of lines v1.0
class LinesCollection
{
   string _prefix;
public:
   LinesCollection(string prefix)
   {
      _prefix = prefix;
   }

   void Delete(int index)
   {
      //ObjectDelete();
   }

   void Create(string id, datetime x1, double y1, datetime x2, double y2, color clr, bool extend, datetime dateId)
   {
      ResetLastError();
      string lineId = IndicatorObjPrefix + id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, y1, x2, y2))
      {
         ObjectSetInteger(0, lineId, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, lineId, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, lineId, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, lineId, OBJPROP_RAY_RIGHT, extend);
      }
      ObjectSetDouble(0, lineId, OBJPROP_PRICE1, y1);
      ObjectSetDouble(0, lineId, OBJPROP_PRICE2, y2);
      ObjectSetInteger(0, lineId, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, lineId, OBJPROP_TIME2, x2);
   }
};
// Collection of labels v1.0

class LabelsCollection
{
   string _prefix;
public:
   LabelsCollection(string prefix)
   {
      _prefix = prefix;
   }

   void Delete(int index)
   {
      //ObjectDelete();
   }

   void Create(string id, datetime x, double y, string text, color clr, datetime dateId)
   {
      ResetLastError();
      string labelId = IndicatorObjPrefix + id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      if (ObjectFind(0, labelId) == -1 && ObjectCreate(0, labelId, OBJ_TEXT, 0, x, y))
      {
         ObjectSetString(0, labelId, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, labelId, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, labelId, OBJPROP_COLOR, clr);
      }
      ObjectSetInteger(0, labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, labelId, OBJPROP_TEXT, text);
   }
};

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

//AOnStream v1.0

class ConditionStream : public AStreamBase
{
protected:
   ICondition* _condition;
public:
   ConditionStream(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStream()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, double &val)
   {
      val = _condition.IsPass(period, 0) ? 1 : 0;
      return true;
   }
};
// ACondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ACondition_IMP
#define ACondition_IMP
// Abstract condition v1.1



#ifndef AConditionBase_IMP
#define AConditionBase_IMP

class AConditionBase : public ICondition
{
   int _references;
   string _conditionName;
public:
   AConditionBase(string name = "")
   {
      _conditionName = name;
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
      if (_conditionName == "" || _conditionName == NULL)
      {
         return "";
      }
      return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
   }
};

#endif


class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = "")
      :AConditionBase(name)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ACondition()
   {
      delete _instrument;
   }
};
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
#ifndef TwoStreamsConditionType_IMP
#define TwoStreamsConditionType_IMP

enum TwoStreamsConditionType
{
   FirstAboveSecond,
   FirstBelowSecond,
   FirstCrossOverSecond,
   FirstCrossUnderSecond,
   FirstEqualsSecond
};

#endif

// Stream-stream condition v1.0

#ifndef StreamStreamCondition_IMP
#define StreamStreamCondition_IMP

class StreamStreamCondition : public ACondition
{
   IStream* _stream1;
   IStream* _stream2;
   int _periodShift1;
   int _periodShift2;
   string _name1;
   string _name2;
   TwoStreamsConditionType _condition;
public:
   StreamStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      IStream* stream1,
      IStream* stream2,
      string name1,
      string name2,
      int streamPeriodShift1 = 0,
      int streamPeriodShift2 = 0)
      :ACondition(symbol, timeframe)
   {
      _name1 = name1;
      _name2 = name2;
      _stream1 = stream1;
      _stream1.AddRef();
      _stream2 = stream2;
      _stream2.AddRef();
      _condition = condition;
      _periodShift1 = streamPeriodShift1;
      _periodShift2 = streamPeriodShift2;
   }

   ~StreamStreamCondition()
   {
      _stream1.Release();
      _stream2.Release();
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return _name1 + " > " + _name2 + ": " + (result ? "true" : "false");
         case FirstBelowSecond:
            return _name1 + " < " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return _name1 + " co " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return _name1 + " cu " + _name2 + ": " + (result ? "true" : "false");
      }
      return _name1 + "-" + _name2 + ": " + (result ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value10, value11;
      if (!_stream1.GetValue(period + _periodShift1, value10) || !_stream1.GetValue(period + _periodShift1 + 1, value11))
      {
         return false;
      }
      double value20, value21;
      if (!_stream2.GetValue(period + _periodShift2, value20) || !_stream2.GetValue(period + _periodShift2 + 1, value21))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value10 > value20;
         case FirstBelowSecond:
            return value10 < value20;
         case FirstCrossOverSecond:
            return value10 >= value20 && value11 < value21;
         case FirstCrossUnderSecond:
            return value10 <= value20 && value11 > value21;
      }
      return value10 >= value20 && value11 < value21;
   }
};
#endif


//AOnStream v1.0

class CrossoverStream : public ConditionStream
{
public:
   CrossoverStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};




//AOnStream v1.0

class CrossunderStream : public ConditionStream
{
public:
   CrossunderStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};
CustomStream* ta_stdev1Source;
IStream* ta_stdev1;
CustomStream* ta_sma1Source;
IStream* ta_sma1;
CustomStream* ta_sma2Source;
IStream* ta_sma2;
CustomStream* ta_sma3Source;
IStream* ta_sma3;
double plot1[];
double plot2[];
LinesCollection* up_l;
LinesCollection* dn_l;
LabelsCollection* recent_up_break;
LabelsCollection* recent_dn_break;
CustomStream* ta_crossover1X;
CustomStream* ta_crossover1Y;
IStream* ta_crossover1;
CustomStream* ta_crossunder1X;
CustomStream* ta_crossunder1Y;
IStream* ta_crossunder1;
double plot3[];
double plot4[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Trendlines with Breaks [LuxAlgo]");
   IndicatorShortName("Trendlines with Breaks [LuxAlgo]");
   IndicatorBuffers(13);
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexShift(id, (-length));
   SetIndexArrow(id++, 233);
   SetIndexBuffer(id, plot2);
   SetIndexShift(id, (-length));
   SetIndexArrow(id++, 234);
   up_l = new LinesCollection(IndicatorObjPrefix);
   dn_l = new LinesCollection(IndicatorObjPrefix);
   recent_up_break = new LabelsCollection(IndicatorObjPrefix);
   recent_dn_break = new LabelsCollection(IndicatorObjPrefix);
   SetIndexBuffer(id, plot3);
   SetIndexShift(id++, (-length));
   SetIndexBuffer(id, plot4);
   SetIndexShift(id++, (-length));
   SetIndexBuffer(id++, slope_ph);
   SetIndexBuffer(id++, slope_pl);
   SetIndexBuffer(id++, upper);
   SetIndexBuffer(id++, lower);
   SetIndexBuffer(id++, src);
   SetIndexBuffer(id++, single_upper);
   SetIndexBuffer(id++, single_lower);
   SetIndexBuffer(id++, ph);
   SetIndexBuffer(id++, pl);
   ta_stdev1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_stdev1 = new StDevStream(ta_stdev1Source, length);
   ta_sma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_sma1 = new SmaOnStream(ta_sma1Source, length);
   ta_sma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_sma2 = new SmaOnStream(ta_sma2Source, length);
   ta_sma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_sma3 = new SmaOnStream(ta_sma3Source, length);
   ta_crossover1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossover1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossover1 = new CrossoverStream(ta_crossover1X, ta_crossover1Y);
   ta_crossunder1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossunder1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossunder1 = new CrossunderStream(ta_crossunder1X, ta_crossunder1Y);
   ta_pivothigh1 = new PivotHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length, length);
   ta_pivotlow2 = new PivotLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length, length);
   ta_atr3 = new ATRStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length);
   ta_variance4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_variance4 = new VarianceOnStream(ta_variance4Source, length, true);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ta_pivothigh1.Release();
   ta_pivotlow2.Release();
   ta_atr3.Release();
   ta_variance4Source.Release();
   ta_variance4.Release();
   ta_stdev1Source.Release();
   ta_stdev1.Release();
   ta_sma1Source.Release();
   ta_sma1.Release();
   ta_sma2Source.Release();
   ta_sma2.Release();
   ta_sma3Source.Release();
   ta_sma3.Release();
   delete up_l;
   delete dn_l;
   delete recent_up_break;
   delete recent_dn_break;
   ta_crossover1X.Release();
   ta_crossover1Y.Release();
   ta_crossover1.Release();
   ta_crossunder1X.Release();
   ta_crossunder1Y.Release();
   ta_crossunder1.Release();
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
      ArrayInitialize(upper, 0.);
      ArrayInitialize(lower, 0.);
      ArrayInitialize(slope_ph, 0.);
      ArrayInitialize(slope_pl, 0.);
      ArrayInitialize(single_upper, 0);
      ArrayInitialize(single_lower, 0);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(src, EMPTY_VALUE);
      ArrayInitialize(ph, EMPTY_VALUE);
      ArrayInitialize(pl, EMPTY_VALUE);
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
      src[pos] = close[pos];
      int n = (rates_total - 1 - pos);
      double ta_pivothigh1Value;
      if (!ta_pivothigh1.GetValue(pos, ta_pivothigh1Value))
      {
         continue;
      }
      ph[pos] = ta_pivothigh1Value;
      double ta_pivotlow2Value;
      if (!ta_pivotlow2.GetValue(pos, ta_pivotlow2Value))
      {
         continue;
      }
      pl[pos] = ta_pivotlow2Value;
         double ta_atr3Value;
         if (!ta_atr3.GetValue(pos, ta_atr3Value))
         {
            continue;
         }
         ta_stdev1Source.SetValue(pos, src[pos]);
         double ta_stdev1Value;
         if (!ta_stdev1.GetValue(pos, ta_stdev1Value))
         {
            continue;
         }
         ta_sma1Source.SetValue(pos, src[pos] * (rates_total - 1 - pos));
         double ta_sma1Value;
         if (!ta_sma1.GetValue(pos, ta_sma1Value))
         {
            continue;
         }
         ta_sma2Source.SetValue(pos, src[pos]);
         double ta_sma2Value;
         if (!ta_sma2.GetValue(pos, ta_sma2Value))
         {
            continue;
         }
         ta_sma3Source.SetValue(pos, (rates_total - 1 - pos));
         double ta_sma3Value;
         if (!ta_sma3.GetValue(pos, ta_sma3Value))
         {
            continue;
         }
         ta_variance4Source.SetValue(pos, n);
         double ta_variance4Value;
         if (!ta_variance4.GetValue(pos, ta_variance4Value))
         {
            continue;
         }
      double switch1Result;
      if (method == "Atr")
      {
         switch1Result = ta_atr3Value / length * k;
      }
      else if (method == "Stdev")
      {
         switch1Result = ta_stdev1Value / length * k;
      }
      else if (method == "Linreg")
      {
         switch1Result = MathAbs(ta_sma1Value - ta_sma2Value * ta_sma3Value) / ta_variance4Value / 2 * k;
      }
      double slope = switch1Result;
      slope_ph[pos] = (ph[pos] != EMPTY_VALUE ? slope : slope_ph[pos + 1]);
      slope_pl[pos] = (pl[pos] != EMPTY_VALUE ? slope : slope_pl[pos + 1]);
      upper[pos] = (ph[pos] != EMPTY_VALUE ? ph[pos] : upper[pos + 1] - slope_ph[pos]);
      lower[pos] = (pl[pos] != EMPTY_VALUE ? pl[pos] : lower[pos + 1] + slope_pl[pos]);
      single_upper[pos] = ((src[pos + length] > upper[pos]) ? 0 : (ph[pos] != EMPTY_VALUE ? 1 : single_upper[pos + 1]));
      single_lower[pos] = ((src[pos + length] < lower[pos]) ? 0 : (pl[pos] != EMPTY_VALUE ? 1 : single_lower[pos + 1]));
      bool upper_breakout = ((single_upper[pos + 1] != EMPTY_VALUE && (src[pos + length] > upper[pos])) && ((show ? (src[pos] > src[pos + length]) : 1)));
      bool lower_breakout = ((single_lower[pos + 1] != EMPTY_VALUE && (src[pos + length] < lower[pos])) && ((show ? (src[pos] < src[pos + length]) : 1)));
      plot1[pos] = (upper_breakout ? low[pos + length] : EMPTY_VALUE);
      plot2[pos] = (lower_breakout ? high[pos + length] : EMPTY_VALUE);
      if (ph[pos + 1] != EMPTY_VALUE)
      {
         up_l.Delete(1);
         recent_up_break.Delete(1);
         up_l.Create("line_1_id", time[rates_total - 1 - (int)(n - length - 1)], ph[pos + 1], time[rates_total - 1 - (int)(n - length)], upper[pos], 0x26a69a, true, time[pos]);
      }
      if (pl[pos + 1] != EMPTY_VALUE)
      {
         dn_l.Delete(1);
         recent_dn_break.Delete(1);
         dn_l.Create("line_2_id", time[rates_total - 1 - (int)(n - length - 1)], pl[pos + 1], time[rates_total - 1 - (int)(n - length)], lower[pos], 0xef5350, true, time[pos]);
      }
      ta_crossover1X.SetValue(pos, src[pos]);
      ta_crossover1Y.SetValue(pos, upper[pos] - slope_ph[pos] * length);
      double ta_crossover1Value;
      if (!ta_crossover1.GetValue(pos, ta_crossover1Value))
      {
         continue;
      }
      if (ta_crossover1Value)
      {
         recent_up_break.Delete(1);
         recent_up_break.Create("label_1_id", time[pos + n], low[pos], "B", White, time[pos]);
      }
      ta_crossunder1X.SetValue(pos, src[pos]);
      ta_crossunder1Y.SetValue(pos, lower[pos] + slope_pl[pos] * length);
      double ta_crossunder1Value;
      if (!ta_crossunder1.GetValue(pos, ta_crossunder1Value))
      {
         continue;
      }
      if (ta_crossunder1Value)
      {
         recent_dn_break.Delete(1);
         recent_dn_break.Create("label_2_id", time[pos + n], high[pos], "B", White, time[pos]);
      }
      plot3[pos] = upper[pos];
      plot4[pos] = lower[pos];
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
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+