//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76360&sid=14b4126950beb814ce960a2ce3588fbe
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 50
#property indicator_label45 "MA Line"
#property indicator_type45 DRAW_LINE
#property indicator_style45 STYLE_SOLID
#property indicator_width45 2
#property indicator_label46 "MA Line"
#property indicator_type46 DRAW_LINE
#property indicator_style46 STYLE_SOLID
#property indicator_width46 2
#property indicator_label47 "MA Line"
#property indicator_type47 DRAW_LINE
#property indicator_style47 STYLE_SOLID
#property indicator_width47 2
#property indicator_label48 "MA Line"
#property indicator_type48 DRAW_LINE
#property indicator_style48 STYLE_SOLID
#property indicator_width48 2
#property indicator_label49 "MA Line"
#property indicator_type49 DRAW_LINE
#property indicator_color49 Green
#property indicator_style49 STYLE_SOLID
#property indicator_width49 2
#property indicator_label50 "MA Line"
#property indicator_type50 DRAW_LINE
#property indicator_color50 Red
#property indicator_style50 STYLE_SOLID
#property indicator_width50 2

#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)

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


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif


//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      int currentSize = ArrayRange(_buffer, 0);
      if (currentSize < size)
      {
         ArrayResize(_buffer, size);
         for (int i = currentSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] =  alpha * price + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
      return true;
   }
};

#endif


// WMA on stream v1.1

#ifndef WMAOnStream_IMP
#define WMAOnStream_IMP

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;

      _buffer[bufferIndex] = (current - last) * _k + last;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// VWMA on stream v1.1



#ifndef VwmaOnStream_IMP
#define VwmaOnStream_IMP

class VwmaOnStream : public AOnStream
{
   int _length;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   VwmaOnStream(string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, const int length)
      :AOnStream(source)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = iBars(_symbol, _timeframe);
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = iVolume(_symbol, _timeframe, period);
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

#endif
// HMA on stream v1.1

#ifndef HMAOnStream_IMP
#define HMAOnStream_IMP




class HMAOnStream : public AOnStream
{
   int _length;
   WMAOnStream* wmaHalf;
   WMAOnStream* wma;
   WMAOnStream* wmaOnDiff;
   FloatStream* diff;
public:
   HMAOnStream(IStream *source, const int length)
      : AOnStream(source)
   {
      _length = length;
      wmaHalf = new WMAOnStream(source, MathFloor(length / 2 + 0.5));
      wma = new WMAOnStream(source, length);
      diff = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wmaOnDiff = new WMAOnStream(diff, MathFloor(MathSqrt(length) + 0.5));
   }

   ~HMAOnStream()
   {
      wmaHalf.Release();
      wma.Release();
      diff.Release();
      wmaOnDiff.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double n2ma;
      if (!wmaHalf.GetValue(period, n2ma))
      {
         return false;
      }
      n2ma *= 2;
      double nma;
      if (!wma.GetValue(period, nma))
      {
         return false;
      }
      diff.SetValue(period, n2ma - nma);

      return wmaOnDiff.GetValue(period, val);
   }
};
#endif
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
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

//ConditionStreamV2 v1.0

class ConditionStreamV2 : public ABoolStream
{
protected:
   ICondition* _condition;
public:
   ConditionStreamV2(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStreamV2()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, bool &val)
   {
      val = _condition.IsPass(period, 0);
      return true;
   }
};
#endif
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
// Or condition v4.1



#ifndef OrCondition_IMP
#define OrCondition_IMP

class OrCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition *condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
         condition.AddRef();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period, date))
            return true;
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " or (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};
#endif


//CrossStreamV2 v1.0

class CrossStreamFactory
{
public:
   static IBoolStream* CreateCross(IStream *left, IStream* right)
   {
      OrCondition* or = new OrCondition();
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      ConditionStreamV2* result = new ConditionStreamV2(or);
      or.Release();
      return result;
   }

   static IBoolStream* CreateCrossunder(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }

   static IBoolStream* CreateCrossover(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
};
#endif


// Change stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double src1, src2;
      if (!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
      {
         return false;
      }
      val = src1 - src2;
      return true;
   }
};

#endif
// Pine-script like safe operations
// v.1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}

double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
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

double SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left > right;
}

double SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left >= right;
}

double SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left < right;
}

double SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left <= right;
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
// Candles stream v.1.4
class CandleStreamsData
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   color Color;

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      Color = clr;
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

class CandleStreams
{
   int _offset;
public:
   CandleStreamsData* candles[];
   CandleStreams()
   {
      _offset = 0;
   }

   ~CandleStreams()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         delete candles[i];
      }
   }
   
   void SetOffset(int offset)
   {
      _offset = offset;
   }

   void Init()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Init();
      }
   }

   void Clear(const int index)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Clear(index + _offset);
      }
   }

   int RegisterStreams(const int id, const color clr)
   {
      int size = ArraySize(candles);
      ArrayResize(candles, size + 1);
      candles[size] = new CandleStreamsData();
      return candles[size].RegisterStreams(id, clr);
   }

   void Set(const int index, const double open, const double high, const double low, const double close, const color clr)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         if (item.Color == clr)
         {
            item.Set(index + _offset, open, high, low, close);
         }
         else
         {
            item.Clear(index + _offset);
         }
      }
   }
};


// Colored stream v3.4

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class IColoredStreamData
{
public:
   virtual void Init(double defaultValue) = 0;
   virtual int Register(int id) = 0;
   virtual double GetValue(int pos) = 0;
   virtual color GetColor() = 0;
   virtual void Set(int period, double value, double prevValue) = 0;
   virtual void Clear(int period) = 0;
};

class LineColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   string _label;
   int _lineType;
   ENUM_LINE_STYLE _lineStyle;
   int _width;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _color = clr;
      _label = label;
      _lineType = lineType;
      _lineStyle = lineStyle;
      _width = width;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexStyle(id, _lineType, _lineStyle, _width, _color);
      if (_label != "")
         SetIndexLabel(id, _label);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      _stream[period] = value;
      if (period + 1 < iBars(_symbol, _timeframe) && _stream[period + 1] == EMPTY_VALUE)
         _stream[period + 1] = prevValue;
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width);
   }
   ~HistogramColoredStreamData()
   {
      delete _up;
      delete _down;
   }
   void Init(double defaultValue)
   {
      _up.Init(defaultValue);
      _down.Init(defaultValue);
   }

   int Register(int id)
   {
      id = _up.Register(id);
      return _down.Register(id);
   }

   double GetValue(int pos)
   {
      return _up.GetValue(pos);
   }

   color GetColor()
   {
      return _up.GetColor();
   }

   void Set(int period, double value, double prevValue)
   {
      _up.Set(period, value, prevValue);
      _down.Set(period, 0, 0);
   }

   void Clear(int period)
   {
      _up.Clear(period);
      _down.Clear(period);
   }
};

class ArrowColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   int _arrow;
public:
   ArrowColoredStreamData(int arrow, color clr)
   {
      _arrow = arrow;
      _color = clr;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexArrow(id, _arrow);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      _stream[period] = value;
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
};

class ColoredStream : public AStream
{
   IColoredStreamData* _streams[];
   double _data[];
public:

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _data);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }
   
   int RegisterArrowStream(int id, color clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, clr);
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, clr, label, lineType, lineStyle, width);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, color clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, clr, label, width);
      return _streams[size].Register(id);
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetValue(period) != EMPTY_VALUE)
            return i;
      }
      return -1;
   }
   
   double SetByColor(double value, int period, color clr)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetColor() == clr)
         {
            Set(value, period, i);
            return value;
         }
      }
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _data[period + 1];
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Set(period, value, prevValue);
         }
         else
         {
            _streams[i].Clear(period);
         }
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
// Stream returns rising flag. Similar to ta.rising in PineScript v1.1


class RisingStream : public ABoolStream
{
   IStream* _source;
   int _length;
public:
   RisingStream(IStream* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
   }
   ~RisingStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, bool &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double prev;
      if (!_source.GetValue(period + _length, prev))
      {
         return false;
      }
      val = prev < current;
      return true;
   }
};
// Stream returns falling flag. Similar to ta.falling in PineScript v1.0


class FallingStream : public ABoolStream
{
   IStream* _source;
   int _length;
public:
   FallingStream(IStream* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
   }
   ~FallingStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, bool &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double prev;
      if (!_source.GetValue(period + _length, prev))
      {
         return false;
      }
      val = prev > current;
      return true;
   }
};
// Table v1.0
// Interface for a cell v2.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(int& width, int& height) = 0;
};

#endif
//Row size v1.0

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }
};

// Row v2.2

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Measure(RowSize* rowSizes)
   {
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int w, h;
         _cells[i].Measure(w, h);
         rowSizes.Add(i, w + 5, h + 5);
      } 
   }
   
   int GetColumnsCount()
   {
      return ArraySize(_cells);
   }

   void Draw(int x, int y, RowSize* rowSizes) 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(x, y);
         x += rowSizes.GetWidth(i);
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }
   
   ICell* GetCell(int index)
   {
      if (index < 0)
      {
         return NULL;
      }
      int count = ArraySize(_cells);
      if (index >= count)
      {
         return NULL;
      }
      return _cells[index];
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif


// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int w, h;
         _rows[i].Draw(x, y, widths);
         y += widths.GetMaxHeight();
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif


// ACell v1.1

class ACell : public ICell
{
protected:
   void Measure(string text, string font, int fontSize, int& width, int& height)
   {
      TextSetFont(font, -fontSize * 10);
      TextGetSize(text, width, height);
   }
   void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, text, FSize, Font, LabelColor);
   }
};

// Label cell v4.0

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   color _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   color _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, color clr, int windowNumber)
   { 
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = clr;
      _windowNumber = windowNumber;
   }

   virtual void Measure(int& width, int& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         int w, h;
         Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y) 
   {
      if (_withBackground)
      {
         ObjectCreate(_id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor); 
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, _width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (_width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += _width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(color clr)
   {
      if (_bgColor == clr)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = true;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(color clr)
   {
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif

class Table;
class TableManager
{
   static Table* tables[];
public:
   static void Clear();
   static void Add(Table* table);
   static void Redraw();
};

Table* TableManager::tables[];
void TableManager::Clear()
{
   for (int i = 0; i < ArraySize(TableManager::tables); ++i)
   {
      delete tables[i];
   }
   ArrayResize(tables, 0);
}

void TableManager::Add(Table* table)
{
   int size = ArraySize(tables);
   ArrayResize(tables, size + 1);
   tables[size] = table;
}

void TableManager::Redraw()
{
   for (int i = 0; i < ArraySize(tables); ++i)
   {
      tables[i].Redraw();
   }
}

enum TablePosition
{
   TablePositionTopLeft,
   TablePositionTopCenter,
   TablePositionTopRight,
   TablePositionMiddleLeft,
   TablePositionMiddleCenter,
   TablePositionMiddleRight,
   TablePositionBottomLeft,
   TablePositionBottomCenter,
   TablePositionBottomRight
};

TablePosition TablePositionFromString(string value)
{
   if (value == "top_left") return TablePositionTopLeft;
   if (value == "top_center") return TablePositionTopCenter;
   if (value == "top_right") return TablePositionTopRight;
   if (value == "middle_left") return TablePositionMiddleLeft;
   if (value == "middle_center") return TablePositionMiddleCenter;
   if (value == "middle_right") return TablePositionMiddleRight;
   if (value == "bottom_left") return TablePositionBottomLeft;
   if (value == "bottom_center") return TablePositionBottomCenter;
   if (value == "bottom_right") return TablePositionBottomRight;
   return TablePositionMiddleCenter;
}

class Table
{
   string _prefix;
   TablePosition _position;
   int _columns;
   int _rows;

   int _borderWidth;
   color _borderColor;
   
   int _frameWidth;
   color _frameColor;
   Grid* _grid;
public:
   Table(string prefix, string position, int columns, int rows)
   {
      if (columns == EMPTY_VALUE)
      {
         columns = 0;
      }
      if (rows == EMPTY_VALUE)
      {
         rows = 0;
      }
      _prefix = prefix;
      _position = TablePositionFromString(position);
      _columns = columns;
      _rows = rows;
      _borderWidth = 0;
      _frameWidth = 0;
      _grid = new Grid();
      for (int i = 0; i < rows; ++i)
      {
         Row* row = _grid.AddRow();
         for (int j = 0; j < columns; ++j)
         {
            string id = _prefix + "_cell_" + IntegerToString(i) + "_" + IntegerToString(j);
            row.Add(new LabelCell(id, "", CORNER_LEFT_UPPER, 10, Red, 0));
         }
      }
      Redraw();
      TableManager::Add(&this);
   }
   ~Table()
   {
      delete _grid;
   }

   Table* SetBorderColor(color clr)
   {
      _borderColor = clr;
      return &this;
   }
   Table* SetBorderWidth(int borderWidth)
   {
      _borderWidth = borderWidth;
      return &this;
   }
   Table* SetBGColor(color clr)
   {
      for (int row = 0; row < _grid.GetRowsCount(); ++row)
      {
         Row* gridRow = _grid.GetRow(row);
         for (int column = 0; column < gridRow.GetColumnsCount(); ++column)
         {
            LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
            cell.SetBgColor(clr);
         }
      }
      return &this;
   }
   
   Table* SetFrameColor(color clr)
   {
      _frameColor = clr;
      return &this;
   }
   Table* SetFrameWidth(int frameWidth)
   {
      _frameWidth = frameWidth;
      return &this;
   }
   static void CellText(Table* table, int column, int row, string text)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellText(column, row, text);
   }
   void CellText(int column, int row, string text)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetText(text))
      {
         Redraw();
      }
   }
   static void CellTextColor(Table* table, int column, int row, color clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextColor(column, row, clr);
   }
   void CellTextColor(int column, int row, color clr)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetColor(clr))
      {
      }
   }
   static void CellTextSize(Table* table, int column, int row, string size)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextSize(column, row, size);
   }
   void CellTextSize(int column, int row, string size)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetFontSize(GetFontSize(size)))
      {
      }
   }
   
   static void CellTextHAlign(Table* table, int column, int row, string halign)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextHAlign(column, row, halign);
   }
   void CellTextHAlign(int column, int row, string halign)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetTextHAlign(halign))
      {
      }
   }
   
   void Redraw()
   {
      int x = 0;
      int y = 0;
      switch (_position)
      {
         case TablePositionTopLeft:
            break;
         case TablePositionTopCenter:
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionTopRight:
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionMiddleLeft:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            break;
         case TablePositionMiddleCenter:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionMiddleRight:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionBottomLeft:
            y = GetScreenHeight() - GetGridHeight();
            break;
         case TablePositionBottomCenter:
            y = GetScreenHeight() - GetGridHeight();
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionBottomRight:
            y = GetScreenHeight() - GetGridHeight();
            x = GetScreenWidth() - GetGridWidth();
            break;
      }
      _grid.Draw(x, y);
   }
private:
   int GetFontSize(string size)
   {
      if (size == "auto" || size == "normal")
      {
         return 10;
      }
      if (size == "tiny")
      {
         return 6;
      }
      if (size == "small")
      {
         return 8;
      }
      if (size == "large")
      {
         return 12;
      }
      if (size == "huge")
      {
         return 14;
      }
      return 10;
   }
   int GetScreenWidth()
   {
      return ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   }
   int GetGridWidth()
   {
      int width = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         int rowWidth = 0;
         for (int ii = 0; ii < _columns; ++ii)
         {
            rowWidth += rowSizes.GetWidth(ii);
         }
         delete rowSizes;
         width = MathMax(width, rowWidth);
      }
      return width;
   }
   int GetScreenHeight()
   {
      return ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   }
   int GetGridHeight()
   {
      int height = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         height = MathMax(height, rowSizes.GetMaxHeight());
         delete rowSizes;
      }
      return height;
   }
};

input color param1 = ColorRGB(0, 255, 0, 0); // Bull Color
input color param2 = ColorRGB(255, 0, 0, 0); // Bear Color
input color param3 = ColorRGB(255, 255, 0, 0); // Neutral Color
input bool param4 = true; // Use Gradient Colors
input int param5 = 5; // Max Gradient Steps
input color param6 = ColorRGB(80, 80, 80, 100); // Wick Color
input int param7 = 25; // Length Open
input string param8 = "EMA"; // Type
input int param9 = 20; // Length Close
input string param10 = "EMA"; // Type
input int param11 = 55; // MA Line Length
input string param12 = "EMA"; // MA Line Type
input PriceType param13 = PriceClose; // MA Source
input int bars_limit = 100000; // Bars limit
color bull;
color bear;
color neutral;
bool UseGradient;
int stepn;
class mat_fS_i_sStream
{
   IStream* source;
   int length;
   string type;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* rma1Source;
   RmaOnStream* rma1;
   FloatStream* wma1Source;
   WMAOnStream* wma1;
   FloatStream* vwma1Source;
   VwmaOnStream* vwma1;
   FloatStream* hma1Source;
   HMAOnStream* hma1;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* sma3Source;
   SmaOnStream* sma3;
   bool _initialized;
public:
   mat_fS_i_sStream(IStream* source, int length, string type)
   {
      _initialized = false;
      this.source = source;
      source.AddRef();
      this.length = length;
      this.type = type;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, length);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, length);
      rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rma1 = new RmaOnStream(rma1Source, length);
      wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma1 = new WMAOnStream(wma1Source, length);
      vwma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      vwma1 = new VwmaOnStream(_Symbol, (ENUM_TIMEFRAMES)_Period, vwma1Source, length);
      hma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      hma1 = new HMAOnStream(hma1Source, length);
      sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma3 = new SmaOnStream(sma3Source, length);
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, length);
   }
   ~mat_fS_i_sStream()
   {
      source.Release();
      sma1Source.Release();
      sma1.Release();
      ema1Source.Release();
      ema1.Release();
      rma1Source.Release();
      rma1.Release();
      wma1Source.Release();
      wma1.Release();
      vwma1Source.Release();
      vwma1.Release();
      hma1Source.Release();
      hma1.Release();
      sma2Source.Release();
      sma2.Release();
      sma3Source.Release();
      sma3.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         sma1Source.Init();
         ema1Source.Init();
         rma1Source.Init();
         wma1Source.Init();
         vwma1Source.Init();
         hma1Source.Init();
         sma3Source.Init();
         sma2Source.Init();
         _initialized = true;
      }
      double sourceValue;
      if (!source.GetValue(pos, sourceValue)) { sourceValue = EMPTY_VALUE; }
      sma1Source.SetValue(pos, sourceValue);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      ema1Source.SetValue(pos, sourceValue);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      rma1Source.SetValue(pos, sourceValue);
      double rma1Value;
      if (!rma1.GetValue(pos, rma1Value)) { rma1Value = EMPTY_VALUE; }
      wma1Source.SetValue(pos, sourceValue);
      double wma1Value;
      if (!wma1.GetValue(pos, wma1Value)) { wma1Value = EMPTY_VALUE; }
      vwma1Source.SetValue(pos, sourceValue);
      double vwma1Value;
      if (!vwma1.GetValue(pos, vwma1Value)) { vwma1Value = EMPTY_VALUE; }
      hma1Source.SetValue(pos, sourceValue);
      double hma1Value;
      if (!hma1.GetValue(pos, hma1Value)) { hma1Value = EMPTY_VALUE; }
      sma3Source.SetValue(pos, sourceValue);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
      sma2Source.SetValue(pos, sma3Value);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      __out1 = ((type == "SMA") ? sma1Value : ((type == "EMA") ? ema1Value : ((type == "RMA") ? rma1Value : ((type == "WMA") ? wma1Value : ((type == "VWMA") ? vwma1Value : ((type == "HMA") ? hma1Value : ((type == "TMA") ? sma2Value : EMPTY_VALUE)))))));
      return true;
   }
};
FloatStream* mat_fS_i_s1_param1;
mat_fS_i_sStream* mat_fS_i_s1;
class f_c_gradientAdvDecPro_fS_fS_i_c_c_c_cStream
{
   IStream* _source;
   IStream* _center;
   int _steps;
   color _c_bearWeak;
   color _c_bearStrong;
   color _c_bullWeak;
   color _c_bullStrong;
   double _qtyAdvDec[];
   double _maxSteps[];
   FloatStream* crossover1X;
   FloatStream* crossover1Y;
   IBoolStream* crossover1;
   FloatStream* crossunder1X;
   FloatStream* crossunder1Y;
   IBoolStream* crossunder1;
   FloatStream* change1Source;
   ChangeStream* change1;
   double _return[];
   bool _initialized;
public:
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_cStream(IStream* _source, IStream* _center, int _steps, color _c_bearWeak, color _c_bearStrong, color _c_bullWeak, color _c_bullStrong)
   {
      _initialized = false;
      this._source = _source;
      _source.AddRef();
      this._center = _center;
      _center.AddRef();
      this._steps = _steps;
      this._c_bearWeak = _c_bearWeak;
      this._c_bearStrong = _c_bearStrong;
      this._c_bullWeak = _c_bullWeak;
      this._c_bullStrong = _c_bullStrong;
      crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
      crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
      change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change1 = new ChangeStream(change1Source, 1);
   }
   ~f_c_gradientAdvDecPro_fS_fS_i_c_c_c_cStream()
   {
      _source.Release();
      _center.Release();
      crossover1X.Release();
      crossover1Y.Release();
      crossover1.Release();
      crossunder1X.Release();
      crossunder1Y.Release();
      crossunder1.Release();
      change1Source.Release();
      change1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, _qtyAdvDec);
      SetIndexBuffer(id++, _maxSteps);
      SetIndexBuffer(id++, _return);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, color &__out1)
   {
      if (!_initialized)
      {
         ArrayInitialize(_qtyAdvDec, 0.);
         ArrayInitialize(_maxSteps, MathMax(1, _steps));
         crossover1X.Init();
         crossover1Y.Init();
         crossunder1X.Init();
         crossunder1Y.Init();
         change1Source.Init();
         ArrayInitialize(_return, EMPTY_VALUE);
         _initialized = true;
      }
      _qtyAdvDec[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? _qtyAdvDec[pos + 1] : 0.;
      _maxSteps[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? _maxSteps[pos + 1] : MathMax(1, _steps);
      _return[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? _return[pos + 1] : EMPTY_VALUE;
      double _sourceValue;
      if (!_source.GetValue(pos, _sourceValue)) { _sourceValue = EMPTY_VALUE; }
      double _centerValue;
      if (!_center.GetValue(pos, _centerValue)) { _centerValue = EMPTY_VALUE; }
      crossover1X.SetValue(pos, _sourceValue);
      crossover1Y.SetValue(pos, _centerValue);
      bool crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = EMPTY_VALUE; }
      bool _xUp = crossover1Value;
      crossunder1X.SetValue(pos, _sourceValue);
      crossunder1Y.SetValue(pos, _centerValue);
      bool crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = EMPTY_VALUE; }
      bool _xDn = crossunder1Value;
      change1Source.SetValue(pos, _sourceValue);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      double _chg = change1Value;
      bool _up = SafeGreater(_chg, 0);
      bool _dn = SafeLess(_chg, 0);
      bool _srcBull = (_sourceValue > _centerValue);
      bool _srcBear = (_sourceValue < _centerValue);
      _qtyAdvDec[pos] = (_srcBull ? (_xUp ? 1 : (_up ? SafeMathMin(_maxSteps[pos], _qtyAdvDec[pos] + 1) : (_dn ? MathMax(1, _qtyAdvDec[pos] - 1) : _qtyAdvDec[pos]))) : (_srcBear ? (_xDn ? 1 : (_dn ? SafeMathMin(_maxSteps[pos], _qtyAdvDec[pos] + 1) : (_up ? MathMax(1, _qtyAdvDec[pos] - 1) : _qtyAdvDec[pos]))) : _qtyAdvDec[pos]));
      _return[pos] = (_srcBull ? FromGradient(_qtyAdvDec[pos], 1, _maxSteps[pos], _c_bullWeak, _c_bullStrong) : (_srcBear ? FromGradient(_qtyAdvDec[pos], 1, _maxSteps[pos], _c_bearWeak, _c_bearStrong) : _return[pos]));
      __out1 = _return[pos];
      return true;
   }
};
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1;
FloatStream* f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2;
f_c_gradientAdvDecPro_fS_fS_i_c_c_c_cStream* f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2;
color WickColor;
int OpenLength;
string OpenType;
int CloseLength;
string CloseType;
int LengthMA;
string MAType;
IStream* param13Stream;
IStream* MASource;
int LengthOpen;
int LengthHigh;
int LengthLow;
int LengthClose;
class funcCalcMA1_s_fS_iStream
{
   string type1;
   IStream* src1;
   int len1;
   FloatStream* ema3Source;
   EMAOnStream* ema3;
   FloatStream* sma4Source;
   SmaOnStream* sma4;
   FloatStream* wma2Source;
   WMAOnStream* wma2;
   bool _initialized;
public:
   funcCalcMA1_s_fS_iStream(string type1, IStream* src1, int len1)
   {
      _initialized = false;
      this.type1 = type1;
      this.src1 = src1;
      src1.AddRef();
      this.len1 = len1;
      ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema3 = new EMAOnStream(ema3Source, len1);
      sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma4 = new SmaOnStream(sma4Source, len1);
      wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma2 = new WMAOnStream(wma2Source, len1);
   }
   ~funcCalcMA1_s_fS_iStream()
   {
      src1.Release();
      ema3Source.Release();
      ema3.Release();
      sma4Source.Release();
      sma4.Release();
      wma2Source.Release();
      wma2.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema3Source.Init();
         sma4Source.Init();
         wma2Source.Init();
         _initialized = true;
      }
      double src1Value;
      if (!src1.GetValue(pos, src1Value)) { src1Value = EMPTY_VALUE; }
      ema3Source.SetValue(pos, src1Value);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      sma4Source.SetValue(pos, src1Value);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      wma2Source.SetValue(pos, src1Value);
      double wma2Value;
      if (!wma2.GetValue(pos, wma2Value)) { wma2Value = EMPTY_VALUE; }
      double return_1 = ((type1 == "EMA") ? ema3Value : ((type1 == "SMA") ? sma4Value : ((type1 == "WMA") ? wma2Value : EMPTY_VALUE)));
      __out1 = return_1;
      return true;
   }
};
FloatStream* funcCalcMA1_s_fS_i3_param2;
funcCalcMA1_s_fS_iStream* funcCalcMA1_s_fS_i3;
class funcCalcOpen_s_fS_iStream
{
   string TypeOpen;
   IStream* SourceOpen;
   int LengthOpen;
   FloatStream* ema4Source;
   EMAOnStream* ema4;
   FloatStream* sma5Source;
   SmaOnStream* sma5;
   FloatStream* wma3Source;
   WMAOnStream* wma3;
   bool _initialized;
public:
   funcCalcOpen_s_fS_iStream(string TypeOpen, IStream* SourceOpen, int LengthOpen)
   {
      _initialized = false;
      this.TypeOpen = TypeOpen;
      this.SourceOpen = SourceOpen;
      SourceOpen.AddRef();
      this.LengthOpen = LengthOpen;
      ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema4 = new EMAOnStream(ema4Source, LengthOpen);
      sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma5 = new SmaOnStream(sma5Source, LengthOpen);
      wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma3 = new WMAOnStream(wma3Source, LengthOpen);
   }
   ~funcCalcOpen_s_fS_iStream()
   {
      SourceOpen.Release();
      ema4Source.Release();
      ema4.Release();
      sma5Source.Release();
      sma5.Release();
      wma3Source.Release();
      wma3.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema4Source.Init();
         sma5Source.Init();
         wma3Source.Init();
         _initialized = true;
      }
      double SourceOpenValue;
      if (!SourceOpen.GetValue(pos, SourceOpenValue)) { SourceOpenValue = EMPTY_VALUE; }
      ema4Source.SetValue(pos, SourceOpenValue);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      sma5Source.SetValue(pos, SourceOpenValue);
      double sma5Value;
      if (!sma5.GetValue(pos, sma5Value)) { sma5Value = EMPTY_VALUE; }
      wma3Source.SetValue(pos, SourceOpenValue);
      double wma3Value;
      if (!wma3.GetValue(pos, wma3Value)) { wma3Value = EMPTY_VALUE; }
      double return_2 = ((TypeOpen == "EMA") ? ema4Value : ((TypeOpen == "SMA") ? sma5Value : ((TypeOpen == "WMA") ? wma3Value : EMPTY_VALUE)));
      __out1 = return_2;
      return true;
   }
};
FloatStream* funcCalcOpen_s_fS_i4_param2;
funcCalcOpen_s_fS_iStream* funcCalcOpen_s_fS_i4;
class funcCalcHigh_s_fS_iStream
{
   string TypeHigh;
   IStream* SourceHigh;
   int LengthHigh;
   FloatStream* ema5Source;
   EMAOnStream* ema5;
   FloatStream* sma6Source;
   SmaOnStream* sma6;
   FloatStream* wma4Source;
   WMAOnStream* wma4;
   bool _initialized;
public:
   funcCalcHigh_s_fS_iStream(string TypeHigh, IStream* SourceHigh, int LengthHigh)
   {
      _initialized = false;
      this.TypeHigh = TypeHigh;
      this.SourceHigh = SourceHigh;
      SourceHigh.AddRef();
      this.LengthHigh = LengthHigh;
      ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema5 = new EMAOnStream(ema5Source, LengthHigh);
      sma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma6 = new SmaOnStream(sma6Source, LengthHigh);
      wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4 = new WMAOnStream(wma4Source, LengthHigh);
   }
   ~funcCalcHigh_s_fS_iStream()
   {
      SourceHigh.Release();
      ema5Source.Release();
      ema5.Release();
      sma6Source.Release();
      sma6.Release();
      wma4Source.Release();
      wma4.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema5Source.Init();
         sma6Source.Init();
         wma4Source.Init();
         _initialized = true;
      }
      double SourceHighValue;
      if (!SourceHigh.GetValue(pos, SourceHighValue)) { SourceHighValue = EMPTY_VALUE; }
      ema5Source.SetValue(pos, SourceHighValue);
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
      sma6Source.SetValue(pos, SourceHighValue);
      double sma6Value;
      if (!sma6.GetValue(pos, sma6Value)) { sma6Value = EMPTY_VALUE; }
      wma4Source.SetValue(pos, SourceHighValue);
      double wma4Value;
      if (!wma4.GetValue(pos, wma4Value)) { wma4Value = EMPTY_VALUE; }
      double return_3 = ((TypeHigh == "EMA") ? ema5Value : ((TypeHigh == "SMA") ? sma6Value : ((TypeHigh == "WMA") ? wma4Value : EMPTY_VALUE)));
      __out1 = return_3;
      return true;
   }
};
FloatStream* funcCalcHigh_s_fS_i5_param2;
funcCalcHigh_s_fS_iStream* funcCalcHigh_s_fS_i5;
class funcCalcLow_s_fS_iStream
{
   string TypeLow;
   IStream* SourceLow;
   int LengthLow;
   FloatStream* ema6Source;
   EMAOnStream* ema6;
   FloatStream* sma7Source;
   SmaOnStream* sma7;
   FloatStream* wma5Source;
   WMAOnStream* wma5;
   bool _initialized;
public:
   funcCalcLow_s_fS_iStream(string TypeLow, IStream* SourceLow, int LengthLow)
   {
      _initialized = false;
      this.TypeLow = TypeLow;
      this.SourceLow = SourceLow;
      SourceLow.AddRef();
      this.LengthLow = LengthLow;
      ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema6 = new EMAOnStream(ema6Source, LengthLow);
      sma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma7 = new SmaOnStream(sma7Source, LengthLow);
      wma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma5 = new WMAOnStream(wma5Source, LengthLow);
   }
   ~funcCalcLow_s_fS_iStream()
   {
      SourceLow.Release();
      ema6Source.Release();
      ema6.Release();
      sma7Source.Release();
      sma7.Release();
      wma5Source.Release();
      wma5.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema6Source.Init();
         sma7Source.Init();
         wma5Source.Init();
         _initialized = true;
      }
      double SourceLowValue;
      if (!SourceLow.GetValue(pos, SourceLowValue)) { SourceLowValue = EMPTY_VALUE; }
      ema6Source.SetValue(pos, SourceLowValue);
      double ema6Value;
      if (!ema6.GetValue(pos, ema6Value)) { ema6Value = EMPTY_VALUE; }
      sma7Source.SetValue(pos, SourceLowValue);
      double sma7Value;
      if (!sma7.GetValue(pos, sma7Value)) { sma7Value = EMPTY_VALUE; }
      wma5Source.SetValue(pos, SourceLowValue);
      double wma5Value;
      if (!wma5.GetValue(pos, wma5Value)) { wma5Value = EMPTY_VALUE; }
      double return_4 = ((TypeLow == "EMA") ? ema6Value : ((TypeLow == "SMA") ? sma7Value : ((TypeLow == "WMA") ? wma5Value : EMPTY_VALUE)));
      __out1 = return_4;
      return true;
   }
};
FloatStream* funcCalcLow_s_fS_i6_param2;
funcCalcLow_s_fS_iStream* funcCalcLow_s_fS_i6;
class funcCalcClose_s_fS_iStream
{
   string TypeClose;
   IStream* SourceClose;
   int LengthClose;
   FloatStream* ema7Source;
   EMAOnStream* ema7;
   FloatStream* sma8Source;
   SmaOnStream* sma8;
   FloatStream* wma6Source;
   WMAOnStream* wma6;
   bool _initialized;
public:
   funcCalcClose_s_fS_iStream(string TypeClose, IStream* SourceClose, int LengthClose)
   {
      _initialized = false;
      this.TypeClose = TypeClose;
      this.SourceClose = SourceClose;
      SourceClose.AddRef();
      this.LengthClose = LengthClose;
      ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema7 = new EMAOnStream(ema7Source, LengthClose);
      sma8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma8 = new SmaOnStream(sma8Source, LengthClose);
      wma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma6 = new WMAOnStream(wma6Source, LengthClose);
   }
   ~funcCalcClose_s_fS_iStream()
   {
      SourceClose.Release();
      ema7Source.Release();
      ema7.Release();
      sma8Source.Release();
      sma8.Release();
      wma6Source.Release();
      wma6.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema7Source.Init();
         sma8Source.Init();
         wma6Source.Init();
         _initialized = true;
      }
      double SourceCloseValue;
      if (!SourceClose.GetValue(pos, SourceCloseValue)) { SourceCloseValue = EMPTY_VALUE; }
      ema7Source.SetValue(pos, SourceCloseValue);
      double ema7Value;
      if (!ema7.GetValue(pos, ema7Value)) { ema7Value = EMPTY_VALUE; }
      sma8Source.SetValue(pos, SourceCloseValue);
      double sma8Value;
      if (!sma8.GetValue(pos, sma8Value)) { sma8Value = EMPTY_VALUE; }
      wma6Source.SetValue(pos, SourceCloseValue);
      double wma6Value;
      if (!wma6.GetValue(pos, wma6Value)) { wma6Value = EMPTY_VALUE; }
      double return_5 = ((TypeClose == "EMA") ? ema7Value : ((TypeClose == "SMA") ? sma8Value : ((TypeClose == "WMA") ? wma6Value : EMPTY_VALUE)));
      __out1 = return_5;
      return true;
   }
};
FloatStream* funcCalcClose_s_fS_i7_param2;
funcCalcClose_s_fS_iStream* funcCalcClose_s_fS_i7;
double CandleOpen[];
CandleStreams* barcolor1;
CandleStreams* plotcandle1;
ColoredStream* plot45;
//Signaler v2.1
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};

Signaler* _signaler;
FloatStream* rising1Source;
RisingStream* rising1;
FloatStream* falling1Source;
FallingStream* falling1;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;

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
   IndicatorBuffers(55);
   int id = 0;
   bull = param1;
   bear = param2;
   neutral = param3;
   UseGradient = param4;
   stepn = param5;
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 3);
   WickColor = param6;
   OpenLength = param7;
   OpenType = param8;
   CloseLength = param9;
   CloseType = param10;
   LengthMA = param11;
   MAType = param12;
   param13Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param13);
   MASource = param13Stream;
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, neutral);
   id = barcolor1.RegisterStreams(id, bull);
   id = barcolor1.RegisterStreams(id, bear);
   id = barcolor1.RegisterStreams(id, Green);
   id = barcolor1.RegisterStreams(id, Red);
   plotcandle1 = new CandleStreams();
   id = plotcandle1.RegisterStreams(id, NULL);
   id = plotcandle1.RegisterStreams(id, neutral);
   id = plotcandle1.RegisterStreams(id, bull);
   id = plotcandle1.RegisterStreams(id, bear);
   id = plotcandle1.RegisterStreams(id, Green);
   id = plotcandle1.RegisterStreams(id, Red);
   plot45 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot45.RegisterStream(id, NULL);
   id = plot45.RegisterStream(id, neutral);
   id = plot45.RegisterStream(id, bull);
   id = plot45.RegisterStream(id, bear);
   id = plot45.RegisterStream(id, Green);
   id = plot45.RegisterStream(id, Red);
   rising1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rising1 = new RisingStream(rising1Source, 2);
   falling1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   falling1 = new FallingStream(falling1Source, 2);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("NSDT HAMA Candles");
   mat_fS_i_s1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int ma_length = 55;
   string ma_type = "WMA";
   mat_fS_i_s1 = new mat_fS_i_sStream(mat_fS_i_s1_param1, ma_length, ma_type);
   id = mat_fS_i_s1.Init(id);
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2 = new f_c_gradientAdvDecPro_fS_fS_i_c_c_c_cStream(f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1, f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2, stepn, neutral, bear, neutral, bull);
   id = f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2.Init(id);
   funcCalcMA1_s_fS_i3_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   funcCalcMA1_s_fS_i3 = new funcCalcMA1_s_fS_iStream(MAType, funcCalcMA1_s_fS_i3_param2, LengthMA);
   id = funcCalcMA1_s_fS_i3.Init(id);
   string TypeOpen = OpenType;
   funcCalcOpen_s_fS_i4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   LengthOpen = OpenLength;
   funcCalcOpen_s_fS_i4 = new funcCalcOpen_s_fS_iStream(TypeOpen, funcCalcOpen_s_fS_i4_param2, LengthOpen);
   id = funcCalcOpen_s_fS_i4.Init(id);
   string HighType = "EMA";
   string TypeHigh = HighType;
   funcCalcHigh_s_fS_i5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int HighLength = 20;
   LengthHigh = HighLength;
   funcCalcHigh_s_fS_i5 = new funcCalcHigh_s_fS_iStream(TypeHigh, funcCalcHigh_s_fS_i5_param2, LengthHigh);
   id = funcCalcHigh_s_fS_i5.Init(id);
   string LowType = "EMA";
   string TypeLow = LowType;
   funcCalcLow_s_fS_i6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int LowLength = 20;
   LengthLow = LowLength;
   funcCalcLow_s_fS_i6 = new funcCalcLow_s_fS_iStream(TypeLow, funcCalcLow_s_fS_i6_param2, LengthLow);
   id = funcCalcLow_s_fS_i6.Init(id);
   string TypeClose = CloseType;
   funcCalcClose_s_fS_i7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   LengthClose = CloseLength;
   funcCalcClose_s_fS_i7 = new funcCalcClose_s_fS_iStream(TypeClose, funcCalcClose_s_fS_i7_param2, LengthClose);
   id = funcCalcClose_s_fS_i7.Init(id);
   SetIndexBuffer(id++, CandleOpen);
   id = plot45.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   mat_fS_i_s1_param1.Release();
   delete mat_fS_i_s1;
   ema2Source.Release();
   ema2.Release();
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1.Release();
   f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2.Release();
   delete f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2;
   param13Stream.Release();
   funcCalcMA1_s_fS_i3_param2.Release();
   delete funcCalcMA1_s_fS_i3;
   funcCalcOpen_s_fS_i4_param2.Release();
   delete funcCalcOpen_s_fS_i4;
   funcCalcHigh_s_fS_i5_param2.Release();
   delete funcCalcHigh_s_fS_i5;
   funcCalcLow_s_fS_i6_param2.Release();
   delete funcCalcLow_s_fS_i6;
   funcCalcClose_s_fS_i7_param2.Release();
   delete funcCalcClose_s_fS_i7;
   delete barcolor1;
   delete plotcandle1;
   delete plot45;
   rising1Source.Release();
   rising1.Release();
   falling1Source.Release();
   falling1.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   delete _signaler;
   TableManager::Clear();
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
      TableManager::Clear();
      mat_fS_i_s1_param1.Init();
      mat_fS_i_s1.Clear();
      ema2Source.Init();
      f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1.Init();
      f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2.Init();
      f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2.Clear();
      funcCalcMA1_s_fS_i3_param2.Init();
      funcCalcMA1_s_fS_i3.Clear();
      funcCalcOpen_s_fS_i4_param2.Init();
      funcCalcOpen_s_fS_i4.Clear();
      funcCalcHigh_s_fS_i5_param2.Init();
      funcCalcHigh_s_fS_i5.Clear();
      funcCalcLow_s_fS_i6_param2.Init();
      funcCalcLow_s_fS_i6.Clear();
      funcCalcClose_s_fS_i7_param2.Init();
      funcCalcClose_s_fS_i7.Clear();
      ArrayInitialize(CandleOpen, EMPTY_VALUE);
      barcolor1.Init();
      plotcandle1.Init();
      plot45.Init(EMPTY_VALUE);
      rising1Source.Init();
      falling1Source.Init();
      crossover2X.Init();
      crossover2Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
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
      bool show_ma = true;
      string ma_type = "WMA";
      double ma_source = close[pos];
      int ma_length = 55;
      mat_fS_i_s1_param1.SetValue(pos, ma_source);
      double mat_fS_i_s1Value;
      if (!mat_fS_i_s1.GetValue(pos, mat_fS_i_s1Value)) { mat_fS_i_s1Value = EMPTY_VALUE; }
      double ma = mat_fS_i_s1Value;
      ema2Source.SetValue(pos, ma);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param1.SetValue(pos, ma);
      f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2_param2.SetValue(pos, ema2Value);
      color f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2Value;
      if (!f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2.GetValue(pos, f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2Value)) { f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2Value = EMPTY_VALUE; }
      color col = f_c_gradientAdvDecPro_fS_fS_i_c_c_c_c2Value;
      int HighLength = 20;
      string HighType = "EMA";
      int LowLength = 20;
      string LowType = "EMA";
      string TypeOpen = OpenType;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      double SourceOpen = SafeDivide((open[pos + 1] + close[pos + 1]), 2);
      LengthOpen = OpenLength;
      string TypeHigh = HighType;
      double SourceHigh = MathMax(high[pos], close[pos]);
      LengthHigh = HighLength;
      string TypeLow = LowType;
      double SourceLow = MathMin(low[pos], close[pos]);
      LengthLow = LowLength;
      string TypeClose = CloseType;
      double SourceClose = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      LengthClose = CloseLength;
      double MASourceValue;
      if (!MASource.GetValue(pos, MASourceValue)) { MASourceValue = EMPTY_VALUE; }
      funcCalcMA1_s_fS_i3_param2.SetValue(pos, MASourceValue);
      double funcCalcMA1_s_fS_i3Value;
      if (!funcCalcMA1_s_fS_i3.GetValue(pos, funcCalcMA1_s_fS_i3Value)) { funcCalcMA1_s_fS_i3Value = EMPTY_VALUE; }
      double MA1 = (funcCalcMA1_s_fS_i3Value);
      funcCalcOpen_s_fS_i4_param2.SetValue(pos, SourceOpen);
      double funcCalcOpen_s_fS_i4Value;
      if (!funcCalcOpen_s_fS_i4.GetValue(pos, funcCalcOpen_s_fS_i4Value)) { funcCalcOpen_s_fS_i4Value = EMPTY_VALUE; }
      CandleOpen[pos] = funcCalcOpen_s_fS_i4Value;
      funcCalcHigh_s_fS_i5_param2.SetValue(pos, SourceHigh);
      double funcCalcHigh_s_fS_i5Value;
      if (!funcCalcHigh_s_fS_i5.GetValue(pos, funcCalcHigh_s_fS_i5Value)) { funcCalcHigh_s_fS_i5Value = EMPTY_VALUE; }
      double CandleHigh = funcCalcHigh_s_fS_i5Value;
      funcCalcLow_s_fS_i6_param2.SetValue(pos, SourceLow);
      double funcCalcLow_s_fS_i6Value;
      if (!funcCalcLow_s_fS_i6.GetValue(pos, funcCalcLow_s_fS_i6Value)) { funcCalcLow_s_fS_i6Value = EMPTY_VALUE; }
      double CandleLow = funcCalcLow_s_fS_i6Value;
      funcCalcClose_s_fS_i7_param2.SetValue(pos, SourceClose);
      double funcCalcClose_s_fS_i7Value;
      if (!funcCalcClose_s_fS_i7.GetValue(pos, funcCalcClose_s_fS_i7Value)) { funcCalcClose_s_fS_i7Value = EMPTY_VALUE; }
      double CandleClose = funcCalcClose_s_fS_i7Value;
      if (pos + 1 > (rates_total - 1)) { continue; }
      color BodyColor = (SafeGreater(CandleOpen[pos], CandleOpen[pos + 1]) ? Green : Red);
      color barcolor1_color = (UseGradient ? col : BodyColor);
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      double plotcandle1_open = CandleOpen[pos];
      double plotcandle1_close = CandleClose;
      color plotcandle1_color = (UseGradient ? col : BodyColor);
      if (plotcandle1_color != EMPTY_VALUE)
      {
         plotcandle1.Set(pos, plotcandle1_open, CandleHigh, CandleLow, plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
      plot45.SetByColor(MA1, pos, (UseGradient ? col : BodyColor));
      rising1Source.SetValue(pos, MA1);
      bool rising1Value;
      if (!rising1.GetValue(pos, rising1Value)) { rising1Value = EMPTY_VALUE; }
      if (rising1Value) { _signaler.SendNotifications("MA Rising", "MA Rising"); }
      falling1Source.SetValue(pos, MA1);
      bool falling1Value;
      if (!falling1.GetValue(pos, falling1Value)) { falling1Value = EMPTY_VALUE; }
      if (falling1Value) { _signaler.SendNotifications("MA Falling", "MA Falling"); }
      crossover2X.SetValue(pos, high[pos]);
      crossover2Y.SetValue(pos, MA1);
      bool crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { crossover2Value = EMPTY_VALUE; }
      if (crossover2Value) { _signaler.SendNotifications("High Crossing MA", "High Crossing MA"); }
      crossunder2X.SetValue(pos, low[pos]);
      crossunder2Y.SetValue(pos, MA1);
      bool crossunder2Value;
      if (!crossunder2.GetValue(pos, crossunder2Value)) { crossunder2Value = EMPTY_VALUE; }
      if (crossunder2Value) { _signaler.SendNotifications("Low Crossing MA", "Low Crossing MA"); }
      Table* Watermark = new Table(IndicatorObjPrefix, "bottom_left", 1, 4).SetBorderWidth(3).SetFrameWidth(0);
      Table::CellText(Watermark, 0, 0, "North Star Day Trading - NSDT HAMA Candles");
      Table::CellTextColor(Watermark, 0, 0, White);
      Table::CellTextSize(Watermark, 0, 0, "huge");
      Table::CellTextHAlign(Watermark, 0, 0, "center");
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   TableManager::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76360&sid=14b4126950beb814ce960a2ce3588fbe
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/