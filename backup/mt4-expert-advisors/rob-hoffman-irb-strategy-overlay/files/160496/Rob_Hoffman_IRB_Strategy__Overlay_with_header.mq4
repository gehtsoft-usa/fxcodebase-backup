/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76299
License:     GNU


── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com


── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7


── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
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
#property indicator_buffers 11
#property indicator_label1 "SMA 3"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "SMA 5"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Fuchsia
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "EMA 18"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Black
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "EMA 20"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "SMA 50"
#property indicator_type5 DRAW_ARROW
#property indicator_color5 Yellow
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "SMA 89"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Teal
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "EMA 144"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Orange
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "SMA 200"
#property indicator_type8 DRAW_LINE
#property indicator_color8 Fuchsia
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "EMA 35"
#property indicator_type9 DRAW_LINE
#property indicator_color9 Lime
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "No Trend Upper"
#property indicator_type10 DRAW_LINE
#property indicator_color10 Gray
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "No Trend Lower"
#property indicator_type11 DRAW_LINE
#property indicator_color11 Gray
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL
// Date/time Stream v.1.0

#ifndef TIStream_IMPL
#define TIStream_IMPL

template <typename T>
interface TIStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, T &val) = 0;
};

#endif

template <typename T>
class TAStream : public TIStream<T>
{
   int _refs;   
public:
   TAStream()
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
// Float stream v3.0

class FloatStream : public TAStream<double>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
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
      return _stream[index] != _emptyValue;
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
            _stream[i] = _emptyValue;
         }
      }
   }
};

#endif


//Base implementation of stream based on another stream 
//v2.0

class AOnStream : public TIStream<double>
{
protected:
   TIStream<double> *_source;
   int _references;
public:
   AOnStream(TIStream<double> *source)
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

// SMA on stream v2.0
#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
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


// EMA on stream v3.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public TIStream<double>
{
   TIStream<double>* _source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(TIStream<double>* source, const int length)
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


//RmaOnStream v2.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(TIStream<double> *source, const int length)
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


// Abstract stream v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public TIStream<double>
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

// True range stream v2.2

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
      double h = iHigh(_symbol, _timeframe, period);
      double l = iLow(_symbol, _timeframe, period);
      double c1 = iClose(_symbol, _timeframe, period + 1);
      double hl = MathAbs(h - l);
      double hc = MathAbs(h - c1);
      double lc = MathAbs(l - c1);

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
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}
// Custom datetime stream v1.1

#ifndef DatetimeStream_IMPL
#define DatetimeStream_IMPL

// Template for custom stream v1.0

#ifndef TStream_IMPL
#define TStream_IMPL



template <typename T>
class TStream : public TAStream<T>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   T _stream[];
   T _emptyValue;
public:
   TStream(const string symbol, const ENUM_TIMEFRAMES timeframe, T emptyValue)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = _emptyValue;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, T value)
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

   bool GetValue(const int period, T &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != _emptyValue;
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
            _stream[i] = _emptyValue;
         }
      }
   }
};
#endif
// PineScript timeframe.* functions
// v1.0

class Timeframe
{
public:
   static string Period()
   {
      if (_Period == PERIOD_M1) { return "1"; }
      if (_Period == PERIOD_M5) { return "5"; }
      if (_Period == PERIOD_M15) { return "15"; }
      if (_Period == PERIOD_M30) { return "30"; }
      if (_Period == PERIOD_H1) { return "60"; }
      if (_Period == PERIOD_H4) { return "240"; }
      if (_Period == PERIOD_D1) { return "D"; }
      if (_Period == PERIOD_W1) { return "W"; }
      if (_Period == PERIOD_MN1) { return "M"; }
      return "1";
   }
   
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

   static bool IsIntraday()
   {
      return ~IsDWM();
   }

   static int Interval()
   {
      switch (_Period)
      {
         case PERIOD_M1:
         case PERIOD_H1:
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return 1;
         case PERIOD_M5:
            return 5;
         case PERIOD_M15:
            return 15;
         case PERIOD_M30:
            return 30;
         case PERIOD_H4:
            return 4;
      }
      return INT_MIN;
   }
};

class DatetimeStream : public TStream<datetime>
{
public:
   DatetimeStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : TStream<datetime>(symbol, timeframe, INT_MIN)
   {
   }
};
#endif
// Change stream v2.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

// v2.0
// Wraps IIntStream and provides TIStream<double>

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL


class IntToFloatStreamWrapper : public TAStream<double>
{
   TIStream<int>* _source;
public:
   IntToFloatStreamWrapper(TIStream<int>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~IntToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      int intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif
// v2.0
// Wraps IBoolStream and provides TIStream<double>

#ifndef BoolToFloatStreamWrapper_IMPL
#define BoolToFloatStreamWrapper_IMPL

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

class BoolToFloatStreamWrapper : public TAStream<double>
{
   IBoolStream* _source;
public:
   BoolToFloatStreamWrapper(IBoolStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~BoolToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      int intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif
// v2.0
// Wraps IDateTimeStream and provides TIStream<double>

#ifndef DateTimeToFloatStreamWrapper_IMPL
#define DateTimeToFloatStreamWrapper_IMPL



class DateTimeToFloatStreamWrapper : public TAStream<double>
{
   TIStream<datetime>* _source;
public:
   DateTimeToFloatStreamWrapper(TIStream<datetime>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~DateTimeToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      datetime intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(TIStream<double>* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(TIStream<int>* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(IBoolStream* stream, int period = 1)
      :AOnStream(new BoolToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(TIStream<datetime>* stream, int period = 1)
      :AOnStream(new DateTimeToFloatStreamWrapper(stream))
   {
      _source.Release();
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



// Date/time stream v1.1

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

class DateTimeStream : public TAStream<datetime>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _targetTimeframe;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = timeframe;
   }
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe, string targetTimeframe, string session, string timezone)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = Timeframe::GetTimeframe(targetTimeframe);
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
      int shift = iBarShift(_symbol, _targetTimeframe, iTime(_symbol, _timeframe, period));
      if (shift < 0)
      {
         return false;
      }
      val = iTime(_symbol, _targetTimeframe, shift);
      return true;
   }
   
   int Size()
   {
      return iBars(_symbol, _timeframe);
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

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
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

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// Pine-script like strategy functions
// v1.0

#ifndef PineStrategy_IMPL
#define PineStrategy_IMPL

//Signaler v2.2
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

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void Alert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
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


class PineStrategy
{
public:
   static void Entry(Signaler* signaler, string id, bool longDirection)
   {
      signaler.SendNotifications(id);
   }
   
   static void Exit(Signaler* signaler, string id, string comment)
   {
      string message = id;
      if (comment != NULL)
      {
         message = message + ": " + comment;
      }
      signaler.SendNotifications(message);
   }
   
   static double GetPositionSize()
   {
      return 0;
   }
   
   static void Close(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void Cancel(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void CloseAll(Signaler* signaler, bool when, string id)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static double Equity()
   {
      return 0;
   }
};

#endif 

input int param1 = 45; // IRB%
input double param2 = 2.0; // RiskRewardRatio
input double param3 = 0.0; // point
input int bars_limit = 100000; // Bars limit
Signaler* _signaler;
int percent45;
double rrratio;
double point;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* sma3Source;
SmaOnStream* sma3;
FloatStream* sma4Source;
SmaOnStream* sma4;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* sma5Source;
SmaOnStream* sma5;
FloatStream* ema4Source;
EMAOnStream* ema4;
FloatStream* rma1Source;
RmaOnStream* rma1;
TIStream<double>* tr1;
DatetimeStream* change1Source;
ChangeStream* change1;
DateTimeStream* time1;
double trades_today[];
double trades_today_DEFAULT_VALUE;
double buy_entry_price[];
double buy_entry_price_DEFAULT_VALUE;
double buy_irb_sl[];
double buy_irb_sl_DEFAULT_VALUE;
double buy_irb_tp[];
double buy_irb_tp_DEFAULT_VALUE;
double sell_entry_price[];
double sell_entry_price_DEFAULT_VALUE;
double sell_irb_sl[];
double sell_irb_sl_DEFAULT_VALUE;
double sell_irb_tp[];
double sell_irb_tp_DEFAULT_VALUE;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
double plot9[];
double plot10[];
double plot11[];

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
   IndicatorBuffers(18);
   percent45 = param1;
   rrratio = param2;
   point = param3;
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, 3);
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, 5);
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, 18);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 20);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, 50);
   sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, 89);
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, 144);
   sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma5 = new SmaOnStream(sma5Source, 200);
   ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, 35);
   rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma1 = new RmaOnStream(rma1Source, 35);
   time1 = new DateTimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, "D", "", "");
   change1Source = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id, plot5);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, plot9);
   SetIndexBuffer(id++, plot10);
   SetIndexBuffer(id++, plot11);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Rob Hoffman IRB Strategy + Overlay Set youtube version");
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id++, trades_today);
   SetIndexBuffer(id++, buy_entry_price);
   SetIndexBuffer(id++, buy_irb_sl);
   SetIndexBuffer(id++, buy_irb_tp);
   SetIndexBuffer(id++, sell_entry_price);
   SetIndexBuffer(id++, sell_irb_sl);
   SetIndexBuffer(id++, sell_irb_tp);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   sma3Source.Release();
   sma3.Release();
   sma4Source.Release();
   sma4.Release();
   ema3Source.Release();
   ema3.Release();
   sma5Source.Release();
   sma5.Release();
   ema4Source.Release();
   ema4.Release();
   rma1Source.Release();
   rma1.Release();
   tr1.Release();
   change1Source.Release();
   change1.Release();
   time1.Release();
   delete _signaler;
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
      sma1Source.Init();
      sma2Source.Init();
      ema1Source.Init();
      ema2Source.Init();
      sma3Source.Init();
      sma4Source.Init();
      ema3Source.Init();
      sma5Source.Init();
      ema4Source.Init();
      rma1Source.Init();
      change1Source.Init();
      trades_today_DEFAULT_VALUE = 0;
      ArrayInitialize(trades_today, trades_today_DEFAULT_VALUE);
      buy_entry_price_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(buy_entry_price, buy_entry_price_DEFAULT_VALUE);
      buy_irb_sl_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(buy_irb_sl, buy_irb_sl_DEFAULT_VALUE);
      buy_irb_tp_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(buy_irb_tp, buy_irb_tp_DEFAULT_VALUE);
      sell_entry_price_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(sell_entry_price, sell_entry_price_DEFAULT_VALUE);
      sell_irb_sl_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(sell_irb_sl, sell_irb_sl_DEFAULT_VALUE);
      sell_irb_tp_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(sell_irb_tp, sell_irb_tp_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
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
      trades_today[pos] = pos < (rates_total - 1) ? trades_today[pos + 1] : 0;
      buy_entry_price[pos] = pos < (rates_total - 1) ? buy_entry_price[pos + 1] : EMPTY_VALUE;
      buy_irb_sl[pos] = pos < (rates_total - 1) ? buy_irb_sl[pos + 1] : EMPTY_VALUE;
      buy_irb_tp[pos] = pos < (rates_total - 1) ? buy_irb_tp[pos + 1] : EMPTY_VALUE;
      sell_entry_price[pos] = pos < (rates_total - 1) ? sell_entry_price[pos + 1] : EMPTY_VALUE;
      sell_irb_sl[pos] = pos < (rates_total - 1) ? sell_irb_sl[pos + 1] : EMPTY_VALUE;
      sell_irb_tp[pos] = pos < (rates_total - 1) ? sell_irb_tp[pos + 1] : EMPTY_VALUE;
      sma1Source.SetValue(pos, close[pos]);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double ma3 = sma1Value;
      sma2Source.SetValue(pos, close[pos]);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double ma5 = sma2Value;
      ema1Source.SetValue(pos, close[pos]);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double ema18 = ema1Value;
      ema2Source.SetValue(pos, close[pos]);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      double ema20 = ema2Value;
      sma3Source.SetValue(pos, close[pos]);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
      double ma50 = sma3Value;
      sma4Source.SetValue(pos, close[pos]);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      double ma89 = sma4Value;
      ema3Source.SetValue(pos, close[pos]);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      double ema144 = ema3Value;
      sma5Source.SetValue(pos, close[pos]);
      double sma5Value;
      if (!sma5.GetValue(pos, sma5Value)) { sma5Value = EMPTY_VALUE; }
      double ma200 = sma5Value;
      ema4Source.SetValue(pos, close[pos]);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      double ema35 = ema4Value;
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      rma1Source.SetValue(pos, tr1Value);
      double rma1Value;
      if (!rma1.GetValue(pos, rma1Value)) { rma1Value = EMPTY_VALUE; }
      double r = rma1Value;
      double upperm = SafePlus(ema35, SafeMultiply(r, 0.5));
      double lowerm = SafeMinus(ema35, SafeMultiply(r, 0.5));
      double a = MathAbs(high[pos] - low[pos]);
      double b = MathAbs(close[pos] - open[pos]);
      int c = SafeDivide(percent45, 100);
      int cal = SafeLess(b, SafeMultiply(c, a));
      double x = SafePlus(low[pos], (SafeMultiply(c, a)));
      double y = SafeMinus(high[pos], (SafeMultiply(c, a)));
      int irblong = cal && SafeGreater(high[pos], y) && SafeLess(close[pos], y) && SafeLess(open[pos], y);
      int irbshort = cal && SafeLess(low[pos], x) && SafeGreater(close[pos], x) && SafeGreater(open[pos], x);
      int bull_trend = SafeGreater(ma3, ma5) && SafeGreater(ma5, ema18) && SafeGreater(ema18, ema20) && SafeGreater(close[pos], upperm);
      int bear_trend = SafeLess(ma3, ma5) && SafeLess(ma5, ema18) && SafeLess(ema18, ema20) && SafeLess(close[pos], lowerm);
      datetime time1Value;
      if (!time1.GetValue(pos, time1Value)) { time1Value = NULL; }
      change1Source.SetValue(pos, time1Value);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      int new_day = (change1Value != 0);
      if (new_day)
      {
         SetStream(trades_today, pos, 0, trades_today_DEFAULT_VALUE);
      }
      int can_trade = (trades_today[pos] < 2);
      if (irbshort && can_trade && (PineStrategy::GetPositionSize() == 0) && bull_trend)
      {
         SetStream(buy_entry_price, pos, close[pos], buy_entry_price_DEFAULT_VALUE);
         SetStream(buy_irb_sl, pos, low[pos] - point, buy_irb_sl_DEFAULT_VALUE);
         SetStream(buy_irb_tp, pos, SafePlus(buy_entry_price[pos], SafeMultiply((SafeMinus(buy_entry_price[pos], buy_irb_sl[pos])), rrratio)), buy_irb_tp_DEFAULT_VALUE);
         PineStrategy::Entry(_signaler, "Buy", true);
         SetStream(trades_today, pos, trades_today[pos] + 1, trades_today_DEFAULT_VALUE);
      }
      if (irblong && can_trade && (PineStrategy::GetPositionSize() == 0) && bear_trend)
      {
         SetStream(sell_entry_price, pos, close[pos], sell_entry_price_DEFAULT_VALUE);
         SetStream(sell_irb_sl, pos, high[pos] + point, sell_irb_sl_DEFAULT_VALUE);
         SetStream(sell_irb_tp, pos, SafeMinus(sell_entry_price[pos], SafeMultiply((SafeMinus(sell_irb_sl[pos], sell_entry_price[pos])), rrratio)), sell_irb_tp_DEFAULT_VALUE);
         PineStrategy::Entry(_signaler, "Sell", false);
         SetStream(trades_today, pos, trades_today[pos] + 1, trades_today_DEFAULT_VALUE);
      }
      if ((PineStrategy::GetPositionSize() > 0))
      {
         PineStrategy::Close(_signaler, "Buy", (SafeLE(close[pos], buy_irb_sl[pos]) || SafeGE(close[pos], buy_irb_tp[pos])));
      }
      if ((PineStrategy::GetPositionSize() < 0))
      {
         PineStrategy::Close(_signaler, "Sell", (SafeGE(close[pos], sell_irb_sl[pos]) || SafeLE(close[pos], sell_irb_tp[pos])));
      }
      plot1[pos] = ma3;
      plot2[pos] = ma5;
      plot3[pos] = ema18;
      plot4[pos] = ema20;
      plot5[pos] = ma50;
      plot6[pos] = ma89;
      plot7[pos] = ema144;
      plot8[pos] = ma200;
      plot9[pos] = ema35;
      plot10[pos] = upperm;
      plot11[pos] = lowerm;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160315#p160315
License:     GNU


── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com


── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7


── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
