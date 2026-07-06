//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76387
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
#property indicator_buffers 9
#property indicator_label1 "Upper Band"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x1d1daa
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Middle Band"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Lower Band"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x0f790f
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Upper Margin"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x1d1daa
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Lower Margin"
#property indicator_type5 DRAW_LINE
#property indicator_color5 0x0f790f
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Buy"
#property indicator_type6 DRAW_ARROW
#property indicator_color6 0x098209
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Sell"
#property indicator_type7 DRAW_ARROW
#property indicator_color7 0x0d0dea
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_type8 DRAW_ARROW
#property indicator_color8 0xb8173a
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_type9 DRAW_ARROW
#property indicator_color9 0xb8173a
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1

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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL


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
// Line object v1.7

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   string _xloc;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
   string _extend;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _extend = "none";
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
      this.global = global;
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
   
   void CopyTo(Line* line)
   {
      line._x1 = _x1;
      line._y1 = _y1;
      line._x2 = _x2;
      line._y2 = _y2;
      line._clr = _clr;
      line._width = _width;
      line._timeframe = _timeframe;
      line._style = _style;
      line._window = _window;
      line._extend = _extend;
   }
   
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static void SetStyle(Line* line, string style)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetStyle(style);
   }
   
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetExtend(Line* line, string extend)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetExtend(extend);
   }
   
   Line* SetExtend(string extend)
   {
      _extend = extend;
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

   Line* SetColor(uint clr)
   {
      _clr = clr;
      return &this;
   }
   static void SetColor(Line* line, uint clr)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetColor(clr);
   }

   static void SetWidth(Line* line, int width)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetWidth(width);
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }
   
   static void SetXLoc(Line* line, string xloc)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXLoc(xloc);
   }
   Line* SetXLoc(string xloc)
   {
      _xloc = xloc;
      return &this;
   }

   void Redraw()
   {
      if (_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
      {
         return;
      }
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, GetStyleMQL());
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         if (_extend == "right")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
         }
         else if (_extend == "left")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "both")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "none")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, false);
         }
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
private:
   int GetStyleMQL()
   {
      if (_style == "dashed")
      {
         return STYLE_DASH;
      }
      if (_style == "solid")
      {
         return STYLE_SOLID;
      }
      return STYLE_SOLID;
   }
};
// Collection of lines v1.3

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

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId, bool global = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped(), global);
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      int allLinesCount = _all.Count();
      if (allLinesCount > _max)
      {
         for (int i = 0; i < allLinesCount; ++i)
         {
            Line* lineToDelete = _all.Get(i);
            if (!lineToDelete.IsGlobal() && lineToDelete != line)
            {
               Delete(lineToDelete);
               break;
            }
         }
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

   Line* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
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
// str.* functions from Pine Script
// v1.1

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      return DoubleToString(value);
   }
   static string ToString(double value)
   {
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      return IntegerToString(value);
   }
   static string ToString(string value)
   {
      return value;
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string source, string str)
   {
      return StringFind(source, str) >= 0;
   }
   static int Length(string str)
   {
      return StringLen(str);
   }
};

enum StrFormatValueType
{
   String,
   Integer,
   Float
};
interface IStrFormatValue
{
public:
   virtual StrFormatValueType GetType() = 0;
};
class StrFormatStringValue : public IStrFormatValue
{
   string value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::String;
   }
   
   void SetValue(string val)
   {
      value = val;
   }
   string GetValue()
   {
      return value;
   }
};
class StrFormatIntValue : public IStrFormatValue
{
   int value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Integer;
   }
   
   void SetValue(int val)
   {
      value = val;
   }
   int GetValue()
   {
      return value;
   }
};
class StrFormatDoubleValue : public IStrFormatValue
{
   double value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Float;
   }
   
   void SetValue(double val)
   {
      value = val;
   }
   double GetValue()
   {
      return value;
   }
};
class StrFormat
{
   string format;
   IStrFormatValue* values[];
   int nextValueIndex;
public:
   StrFormat(string format)
   {
      this.format = format;
      nextValueIndex = 0;
   }
   ~StrFormat()
   {
      int size = ArraySize(values);
      for (int i = 0; i < size; ++i)
      {
         delete values[i];
      }
   }
   
   StrFormat* Add(string value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatStringValue();
      }
      ((StrFormatStringValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(int value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatIntValue();
      }
      ((StrFormatIntValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(double value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatDoubleValue();
      }
      ((StrFormatDoubleValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   
   string Format()
   {
      int size = ArraySize(values);
      string res = format;
      for (int i = 0; i < size; ++i)
      {
         int pos = StringFind(res, "{" + IntegerToString(i));
         if (pos < 0)
         {
            continue;
         }
         int end = StringFind(res, "}", pos + 1);
         if (end < 0)
         {
            continue;
         }
         switch (values[i].GetType())
         {
         case StrFormatValueType::String:
            {
               string strValue = ((StrFormatStringValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + strValue + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Integer:
            {
               int intValue = ((StrFormatIntValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               
               res = StringSubstr(res, 0, pos) + FormatIntValue(intValue, numberFormat) + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Float:
            {
               double doubleValue = ((StrFormatDoubleValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + DoubleToString(doubleValue) + StringSubstr(res, end + 1);
            }
            break;
         }
      }
      nextValueIndex = 0;
      return res;
   }
private:
   string FormatIntValue(int intValue, string numberFormat)
   {
      string tokens[];
      int count = StringSplit(numberFormat, ',', tokens);
      if (count == 1 || tokens[1] != "number")
      {
          return IntegerToString(intValue);
      }
      int precision = GetPrecision(tokens[2]);
      if (precision == 0)
      {
         return IntegerToString(intValue);
      }
      return DoubleToString(intValue, precision);
   }
   
   int GetPrecision(string format)
   {
      int pointPos = StringFind(format, ".");
      if (pointPos < 0)
      {
         return -1;
      }
      return StringLen(format) - pointPos;
   }
};
// Label v1.6

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   string _textAlign;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
   bool globalLabel;
public:
   Label(int x, double y, string labelId, string collectionId, int window, bool globalLabel)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _textAlign = "";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.globalLabel = globalLabel;
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
   
   void CopyTo(Label* label)
   {
      label._color = _color;
      label._textColor = _textColor;
      label._text = _text;
      label._textAlign = _textAlign;
      label._x = _x;
      label._y = _y;
      label._font = _font;
      label._style = _style;
      label._size = _size;
      label._yloc = _yloc;
      label._timeframe = _timeframe;
      label._window = _window;
   }
   
   bool IsGlobal()
   {
      return globalLabel;
   }
   
   string GetId()
   {
      return _labelId;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   int GetX()
   {
      return _x;
   }
   static int GetX(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetX();
   }

   double GetY()
   {
      return _y;
   }
   static double GetY(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetY();
   }
   void SetX(int x) { _x = x; }
   static void SetX(Label* label, int x) { if (label == NULL) { return; } label.SetX(x); }
   void SetY(double y) { _y = y; }
   static void SetY(Label* label, double y) { if (label == NULL) { return; } label.SetY(y); }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL) { return; }
      label.SetX(x);
      label.SetY(y);
  }

   Label* SetSize(string size)
   {
      _size = size;
      return &this;
   }
   static void SetSize(Label* label, string size)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetSize(size);
   }

   Label* SetYLoc(string yloc)
   {
      _yloc = yloc;
      return &this;
   }
   static void SetYLoc(Label* label, string yloc)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetYLoc(yloc);
   }
   
   static void SetColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetColor(clr);
   }
   
   Label* SetColor(uint clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
   }
   Label* SetTextColor(uint clr)
   {
      _textColor = clr;
      return &this;
   }
   
   static void SetStyle(Label* label, string style)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetStyle(style);
   }
   Label* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetText(Label* label, string text)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetText(text);
   }
   Label* SetText(string text)
   {
      _text = text;
      StringReplace(_text, "\n", " ");
      if (_text == "")
      {
         _font = "Wingdings";
      }
      else
      {
         _font = "Arial";
      }
      return &this;
   }
   
   static void SetTextAlign(Label* label, string textAlign)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextAlign(textAlign);
   }
   Label* SetTextAlign(string textAlign)
   {
      _textAlign = textAlign;
      return &this;
   }

   void Redraw()
   {
      string usedText = _text;
      if (usedText == "")
      {
         if (_style == "up")
         {
            usedText = "\217";
         }
         else if (_style == "down")
         {
            usedText = "\218";
         }
         else if (_style == "diamond")
         {
            usedText = "\116";
         }
      }
      ResetLastError();
      int pos = iBars(_Symbol, _timeframe) - _x - 1;
      datetime x = iTime(_Symbol, _timeframe, pos);
      double y = getY(pos);
      
      if (ObjectFind(0, _labelId) == -1 
         && ObjectCreate(0, _labelId, OBJ_TEXT, _window, x, y))
      {
         ObjectSetString(0, _labelId, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
   int GetAnchor()
   {
      if (_yloc == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_yloc == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   int getFontSize()
   {
      if (_size == "tiny")
      {
         return 8;
      }
      if (_size == "small")
      {
         return 10;
      }
      if (_size == "large")
      {
         return 14;
      }
      if (_size == "huge")
      {
         return 16;
      }
      return 12;
   }
   double getY(int pos)
   {
      if (_yloc == "abovebar")
      {
         return iHigh(_Symbol, _timeframe, pos);
      }
      if (_yloc == "belowbar")
      {
         return iLow(_Symbol, _timeframe, pos);
      }
      return _y;
   }
};
#endif
// Collection of labels v1.3

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL



class LabelsCollection
{
   string _id;
   Label* _labels[];
   static LabelsCollection* _collections[];
   static LabelsCollection* _all;
   static int _maxLabels;
public:
   LabelsCollection(string id)
   {
      _id = id;
   }
   
   ~LabelsCollection()
   {
      ClearLabels();
   }
   
   void ClearLabels()
   {
      for (int i = 0; i < ArraySize(_labels); ++i)
      {
         if (_labels[i] != NULL)
         {
            _labels[i].Release();
         }
      }
      ArrayResize(_labels, 0);
   }
   
   string GetId()
   {
      return _id;
   }
   
   int Count()
   {
      return ArraySize(_labels);
   }
   
   Label* GetFirst()
   {
      return _labels[0];
   }
   
   Label* Get(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[index];
   }
   Label* GetByIndex(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[size - 1 - index];
   }

   static Label* Get(Label* label, int index)
   {
      if (label == NULL)
      {
         return NULL;
      }
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
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
         _all = new LabelsCollection("");
      }
      else
      {
         _all.ClearLabels();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Label* label)
   {
      if (label == NULL)
      {
         return;
      }
      _all.RemoveLabel(label);
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLabel(label);
   }

   static Label* Create(string id, int x, double y, datetime dateId, bool globalLabel = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, WindowOnDropped(), globalLabel);
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      int allLabelsCount = _all.Count();
      if (allLabelsCount > _maxLabels)
      {
         for (int i = 0; i < allLabelsCount; ++i)
         {
            Label* labelToDelete = _all.Get(i);
            if (!labelToDelete.IsGlobal() && labelToDelete != label)
            {
               Delete(labelToDelete);
               break;
            }
         }
      }
      return label;
   }

   static void SetMaxLabels(int max)
   {
      _maxLabels = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   int FindIndex(Label* label)
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         if (_labels[i] == label)
         {
            return i;
         }
      }
      return -1;
   }
   void RemoveLabel(Label* label)
   {
      int index = FindIndex(label);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_labels);
      for (int i = index + 1; i < size; ++i)
      {
         _labels[i - 1] = _labels[i];
      }
      ArrayResize(_labels, size - 1);
      label.Release();
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      label.Release();
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
      if (label != NULL)
      {
         label.AddRef();
      }
   }

   void RedrawLabels()
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         _labels[i].Redraw();
      }
   }

   static void AddCollection(LabelsCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LabelsCollection* FindCollection(string id)
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
LabelsCollection* LabelsCollection::_collections[];
LabelsCollection* LabelsCollection::_all;
int LabelsCollection::_maxLabels = 50;
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
// Simple price stream v1.2

#ifndef PriceType_IMPL
#define PriceType_IMPL
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
#endif

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


// Highest high stream v2.0

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _loopback = loopback;
      _source.Release();
   }
   HighestHighStream(TIStream<double>* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return HighestHighStream::GetValue(period, val, _source, _loopback);
   }
};




// Lowest low stream v2.0

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _loopback = loopback;
      _source.Release();
   }
   LowestLowStream(TIStream<double>* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return LowestLowStream::GetValue(period, val, _source, _loopback);
   }
};
// PlotShape v1.2
#ifndef PlotShape_IMPL
#define PlotShape_IMPL

class PlotShape
{
private:
   static void SetNA(double& plot[], int period)
   {
      plot[period] = EMPTY_VALUE;
   }
   
   static void SetValue(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (location == "abovebar" || location == "top")
      {
         plot[period] = high[period + shift];
         return;
      }
      if (location == "belowbar" || location == "bottom")
      {
         plot[period] = low[period + shift];
         return;
      }
      plot[period] = seriesValue;
   }
public:
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == EMPTY_VALUE)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == INT_MIN)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == -1 || seriesValue == 0)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
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

input int param1 = 1; // Buy Limit/Take Profit Line Width
input int param2 = 20; // Label Distance
input int param3 = 2; // Decimal Places
input bool param4 = true; // Show Take Profit
input bool param5 = true; // Show Market Order
input bool param6 = true; // Show Buy Limit 1
input bool param7 = true; // Show Buy Limit 2
input bool param8 = true; // Show Buy Limit 3
input double param9 = 1.04; // Take Profit % (Default 4%)
input int param10 = 10; // Signal Strength
input int bars_limit = 100000; // Bars limit
Signaler* _signaler;
class Approximation1_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation1_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation1_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation1 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation1;
      return true;
   }
};
Approximation1_1Stream* Approximation1_11;
class Approximation2_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation2_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation2_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation2 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation2;
      return true;
   }
};
Approximation2_1Stream* Approximation2_12;
class Approximation3_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation3_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation3_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation3 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation3;
      return true;
   }
};
Approximation3_1Stream* Approximation3_13;
class Approximation4_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation4_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation4_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation4 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation4;
      return true;
   }
};
Approximation4_1Stream* Approximation4_14;
class Approximation5_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation5_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation5_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation5 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation5;
      return true;
   }
};
Approximation5_1Stream* Approximation5_15;
class Approximation6_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation6_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation6_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation6 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation6;
      return true;
   }
};
Approximation6_1Stream* Approximation6_16;
class Approximation7_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation7_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation7_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation7 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation7;
      return true;
   }
};
Approximation7_1Stream* Approximation7_17;
class Approximation8_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation8_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation8_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation8 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation8;
      return true;
   }
};
Approximation8_1Stream* Approximation8_18;
class Approximation9_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation9_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation9_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation9 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation9;
      return true;
   }
};
Approximation9_1Stream* Approximation9_19;
class Approximation10_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation10_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation10_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation10 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation10;
      return true;
   }
};
Approximation10_1Stream* Approximation10_110;
class Approximation11_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation11_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation11_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation11 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation11;
      return true;
   }
};
Approximation11_1Stream* Approximation11_111;
class Approximation12_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation12_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation12_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation12 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation12;
      return true;
   }
};
Approximation12_1Stream* Approximation12_112;
class Approximation13_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation13_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation13_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation13 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation13;
      return true;
   }
};
Approximation13_1Stream* Approximation13_113;
class Approximation14_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation14_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation14_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation14 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation14;
      return true;
   }
};
Approximation14_1Stream* Approximation14_114;
class Approximation15_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation15_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation15_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation15 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation15;
      return true;
   }
};
Approximation15_1Stream* Approximation15_115;
class Approximation16_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation16_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation16_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation16 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation16;
      return true;
   }
};
Approximation16_1Stream* Approximation16_116;
class Approximation17_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation17_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation17_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation17 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation17;
      return true;
   }
};
Approximation17_1Stream* Approximation17_117;
class Approximation18_1Stream
{
   double b;
   double l0[];
   double l0_DEFAULT_VALUE;
   double l1[];
   double l1_DEFAULT_VALUE;
   double l2[];
   double l2_DEFAULT_VALUE;
   double l3[];
   double l3_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Approximation18_1Stream(double b, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.b = b;
   }
   ~Approximation18_1Stream()
   {
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, l0);
      SetIndexBuffer(id++, l1);
      SetIndexBuffer(id++, l2);
      SetIndexBuffer(id++, l3);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double __a, double &__out1)
   {
      if (!_initialized)
      {
         l0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l0, l0_DEFAULT_VALUE);
         l1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l1, l1_DEFAULT_VALUE);
         l2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l2, l2_DEFAULT_VALUE);
         l3_DEFAULT_VALUE = 0.0;
         ArrayInitialize(l3, l3_DEFAULT_VALUE);
         _initialized = true;
      }
      double a = __a;
      SetStream(l0, pos, 0.0, l0_DEFAULT_VALUE);
      SetStream(l1, pos, 0.0, l1_DEFAULT_VALUE);
      SetStream(l2, pos, 0.0, l2_DEFAULT_VALUE);
      SetStream(l3, pos, 0.0, l3_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l0, pos, SafePlus((1 - b) * a, SafeMultiply(b, Nz(l0[pos + 1]))), l0_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l1, pos, SafePlus(SafePlus((-b) * l0[pos], Nz(l0[pos + 1])), SafeMultiply(b, Nz(l1[pos + 1]))), l1_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l2, pos, SafePlus(SafePlus((-b) * l1[pos], Nz(l1[pos + 1])), SafeMultiply(b, Nz(l2[pos + 1]))), l2_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(l3, pos, SafePlus(SafePlus((-b) * l2[pos], Nz(l2[pos + 1])), SafeMultiply(b, Nz(l3[pos + 1]))), l3_DEFAULT_VALUE);
      double Approximation18 = SafeDivide((l0[pos] + 2 * l1[pos] + 2 * l2[pos] + l3[pos]), 6);
      __out1 = Approximation18;
      return true;
   }
};
Approximation18_1Stream* Approximation18_118;
TIStream<double>* tr1;
Approximation1_1Stream* Approximation1_119;
TIStream<double>* tr2;
Approximation2_1Stream* Approximation2_120;
TIStream<double>* tr3;
Approximation3_1Stream* Approximation3_121;
TIStream<double>* tr4;
Approximation4_1Stream* Approximation4_122;
TIStream<double>* tr5;
Approximation5_1Stream* Approximation5_123;
TIStream<double>* tr6;
Approximation6_1Stream* Approximation6_124;
TIStream<double>* tr7;
Approximation7_1Stream* Approximation7_125;
TIStream<double>* tr8;
Approximation8_1Stream* Approximation8_126;
TIStream<double>* tr9;
Approximation9_1Stream* Approximation9_127;
TIStream<double>* tr10;
Approximation10_1Stream* Approximation10_128;
TIStream<double>* tr11;
Approximation11_1Stream* Approximation11_129;
TIStream<double>* tr12;
Approximation12_1Stream* Approximation12_130;
TIStream<double>* tr13;
Approximation13_1Stream* Approximation13_131;
TIStream<double>* tr14;
Approximation14_1Stream* Approximation14_132;
TIStream<double>* tr15;
Approximation15_1Stream* Approximation15_133;
TIStream<double>* tr16;
Approximation16_1Stream* Approximation16_134;
TIStream<double>* tr17;
Approximation17_1Stream* Approximation17_135;
TIStream<double>* tr18;
Approximation18_1Stream* Approximation18_136;
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* ema4Source;
EMAOnStream* ema4;
double plot1[];
double plot2[];
double plot3[];
double Upper_Threshold_of_Approximability2[];
double Upper_Threshold_of_Approximability2_DEFAULT_VALUE;
double Lower_Threshold_of_Approximability2[];
double Lower_Threshold_of_Approximability2_DEFAULT_VALUE;
FloatStream* ema5Source;
EMAOnStream* ema5;
FloatStream* ema6Source;
EMAOnStream* ema6;
FloatStream* ema7Source;
EMAOnStream* ema7;
FloatStream* ema8Source;
EMAOnStream* ema8;
double plot4[];
FloatStream* ema9Source;
EMAOnStream* ema9;
FloatStream* ema10Source;
EMAOnStream* ema10;
double plot5[];
FloatStream* ema11Source;
EMAOnStream* ema11;
FloatStream* ema12Source;
EMAOnStream* ema12;
int w_adjust;
int away;
int dp;
int show_takeprofit;
int show_marketorder;
int show_buylimit1;
int show_buylimit2;
int show_buylimit3;
double slp1;
int Input;
class lele_1Stream
{
   int len;
   double bindex[];
   double bindex_DEFAULT_VALUE;
   double sindex[];
   double sindex_DEFAULT_VALUE;
   FloatStream* highest1Source;
   FloatStream* lowest1Source;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   lele_1Stream(int len, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.len = len;
      highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~lele_1Stream()
   {
      highest1Source.Release();
      lowest1Source.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, bindex);
      SetIndexBuffer(id++, sindex);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int __qual, int &__out1)
   {
      if (!_initialized)
      {
         bindex_DEFAULT_VALUE = 0.0;
         ArrayInitialize(bindex, bindex_DEFAULT_VALUE);
         sindex_DEFAULT_VALUE = 0.0;
         ArrayInitialize(sindex, sindex_DEFAULT_VALUE);
         highest1Source.Init();
         lowest1Source.Init();
         _initialized = true;
      }
      int qual = __qual;
      SetStream(bindex, pos, 0.0, bindex_DEFAULT_VALUE);
      SetStream(sindex, pos, 0.0, sindex_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(bindex, pos, Nz(bindex[pos + 1], 0), bindex_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(sindex, pos, Nz(sindex[pos + 1], 0), sindex_DEFAULT_VALUE);
      int ret = 0;
      if ((SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 4))))
      {
         SetStream(bindex, pos, bindex[pos] + 1, bindex_DEFAULT_VALUE);
      }
      if ((SafeLess(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 4))))
      {
         SetStream(sindex, pos, sindex[pos] + 1, sindex_DEFAULT_VALUE);
      }
      highest1Source.SetValue(pos, iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      double highest1Value;
      if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, len)) { highest1Value = EMPTY_VALUE; }
      if (((bindex[pos] > qual)) && ((iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) < iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))) && SafeGE(iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), highest1Value))
      {
         SetStream(bindex, pos, 0, bindex_DEFAULT_VALUE);
         ret = (-1);
      }
      lowest1Source.SetValue(pos, iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      double lowest1Value;
      if (!LowestLowStream::GetValue(pos, lowest1Value, lowest1Source, len)) { lowest1Value = EMPTY_VALUE; }
      if ((((sindex[pos] > qual)) && ((iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) > iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))) && (SafeLE(iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), lowest1Value))))
      {
         SetStream(sindex, pos, 0, sindex_DEFAULT_VALUE);
         ret = 1;
      }
      __out1 = ret;
      return true;
   }
};
lele_1Stream* lele_137;
double REPAINT_MAJ_BUR[];
double REPAINT_MAJ_BUR_DEFAULT_VALUE;
NewBarState* isNew1;
double plot6[];
double REPAINT_MAJ_BER[];
double REPAINT_MAJ_BER_DEFAULT_VALUE;
NewBarState* isNew2;
double plot7[];
double REPAINT_LTA[];
double REPAINT_LTA_DEFAULT_VALUE;
NewBarState* isNew3;
double plot8[];
double REPAINT_UTA[];
double REPAINT_UTA_DEFAULT_VALUE;
NewBarState* isNew4;
double plot9[];
double REPAINT_MAJ_BUL_ALERT[];
double REPAINT_MAJ_BUL_ALERT_DEFAULT_VALUE;
NewBarState* isNew5;
double REPAINT_MAJ_BER_ALERT[];
double REPAINT_MAJ_BER_ALERT_DEFAULT_VALUE;
NewBarState* isNew6;
double REPAINT_LTA_ALERT[];
double REPAINT_LTA_ALERT_DEFAULT_VALUE;
NewBarState* isNew7;
double REPAINT_UTA_ALERT[];
double REPAINT_UTA_ALERT_DEFAULT_VALUE;
NewBarState* isNew8;

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

string GenerateIndicatorPrefix(string target)
{
   if (StringLen(target) > 20)
   {
      target = StringSubstr(target, 0, 20);
   }
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
   IndicatorBuffers(165);
   int id = 0;
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, 40);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 40);
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, 40);
   ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, 40);
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(AddTransparency(0x808000, 50)));
   SetIndexBuffer(id++, plot3);
   ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, 40);
   ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema6 = new EMAOnStream(ema6Source, 40);
   ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema7 = new EMAOnStream(ema7Source, 40);
   ema8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema8 = new EMAOnStream(ema8Source, 40);
   ema9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema9 = new EMAOnStream(ema9Source, 40);
   ema10Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema10 = new EMAOnStream(ema10Source, 40);
   SetIndexBuffer(id++, plot4);
   ema11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema11 = new EMAOnStream(ema11Source, 40);
   ema12Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema12 = new EMAOnStream(ema12Source, 40);
   SetIndexBuffer(id++, plot5);
   w_adjust = param1;
   away = param2;
   dp = param3;
   show_takeprofit = param4;
   show_marketorder = param5;
   show_buylimit1 = param6;
   show_buylimit2 = param7;
   show_buylimit3 = param8;
   slp1 = param9;
   Input = param10;
   SetIndexBuffer(id, plot6);
   SetIndexArrow(id++, 241);
   SetIndexBuffer(id, plot7);
   SetIndexArrow(id++, 242);
   SetIndexBuffer(id, plot8);
   SetIndexArrow(id++, 241);
   SetIndexBuffer(id, plot9);
   SetIndexArrow(id++, 242);
   LinesCollection::SetMaxLines(50);
   LabelsCollection::SetMaxLabels(50);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("TC Top & Bottom Finder");
   Approximation1_11 = new Approximation1_1Stream(0.1, IndicatorObjPrefix + "_1");
   id = Approximation1_11.Init(id);
   Approximation2_12 = new Approximation2_1Stream(0.15, IndicatorObjPrefix + "_2");
   id = Approximation2_12.Init(id);
   Approximation3_13 = new Approximation3_1Stream(0.2, IndicatorObjPrefix + "_3");
   id = Approximation3_13.Init(id);
   Approximation4_14 = new Approximation4_1Stream(0.25, IndicatorObjPrefix + "_4");
   id = Approximation4_14.Init(id);
   Approximation5_15 = new Approximation5_1Stream(0.3, IndicatorObjPrefix + "_5");
   id = Approximation5_15.Init(id);
   Approximation6_16 = new Approximation6_1Stream(0.35, IndicatorObjPrefix + "_6");
   id = Approximation6_16.Init(id);
   Approximation7_17 = new Approximation7_1Stream(0.4, IndicatorObjPrefix + "_7");
   id = Approximation7_17.Init(id);
   Approximation8_18 = new Approximation8_1Stream(0.45, IndicatorObjPrefix + "_8");
   id = Approximation8_18.Init(id);
   Approximation9_19 = new Approximation9_1Stream(0.5, IndicatorObjPrefix + "_9");
   id = Approximation9_19.Init(id);
   Approximation10_110 = new Approximation10_1Stream(0.55, IndicatorObjPrefix + "_10");
   id = Approximation10_110.Init(id);
   Approximation11_111 = new Approximation11_1Stream(0.6, IndicatorObjPrefix + "_11");
   id = Approximation11_111.Init(id);
   Approximation12_112 = new Approximation12_1Stream(0.65, IndicatorObjPrefix + "_12");
   id = Approximation12_112.Init(id);
   Approximation13_113 = new Approximation13_1Stream(0.7, IndicatorObjPrefix + "_13");
   id = Approximation13_113.Init(id);
   Approximation14_114 = new Approximation14_1Stream(0.75, IndicatorObjPrefix + "_14");
   id = Approximation14_114.Init(id);
   Approximation15_115 = new Approximation15_1Stream(0.8, IndicatorObjPrefix + "_15");
   id = Approximation15_115.Init(id);
   Approximation16_116 = new Approximation16_1Stream(0.85, IndicatorObjPrefix + "_16");
   id = Approximation16_116.Init(id);
   Approximation17_117 = new Approximation17_1Stream(0.9, IndicatorObjPrefix + "_17");
   id = Approximation17_117.Init(id);
   Approximation18_118 = new Approximation18_1Stream(0.95, IndicatorObjPrefix + "_18");
   id = Approximation18_118.Init(id);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation1_119 = new Approximation1_1Stream(0.1, IndicatorObjPrefix + "_19");
   id = Approximation1_119.Init(id);
   tr2 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation2_120 = new Approximation2_1Stream(0.15, IndicatorObjPrefix + "_20");
   id = Approximation2_120.Init(id);
   tr3 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation3_121 = new Approximation3_1Stream(0.2, IndicatorObjPrefix + "_21");
   id = Approximation3_121.Init(id);
   tr4 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation4_122 = new Approximation4_1Stream(0.25, IndicatorObjPrefix + "_22");
   id = Approximation4_122.Init(id);
   tr5 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation5_123 = new Approximation5_1Stream(0.3, IndicatorObjPrefix + "_23");
   id = Approximation5_123.Init(id);
   tr6 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation6_124 = new Approximation6_1Stream(0.35, IndicatorObjPrefix + "_24");
   id = Approximation6_124.Init(id);
   tr7 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation7_125 = new Approximation7_1Stream(0.4, IndicatorObjPrefix + "_25");
   id = Approximation7_125.Init(id);
   tr8 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation8_126 = new Approximation8_1Stream(0.45, IndicatorObjPrefix + "_26");
   id = Approximation8_126.Init(id);
   tr9 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation9_127 = new Approximation9_1Stream(0.5, IndicatorObjPrefix + "_27");
   id = Approximation9_127.Init(id);
   tr10 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation10_128 = new Approximation10_1Stream(0.55, IndicatorObjPrefix + "_28");
   id = Approximation10_128.Init(id);
   tr11 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation11_129 = new Approximation11_1Stream(0.6, IndicatorObjPrefix + "_29");
   id = Approximation11_129.Init(id);
   tr12 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation12_130 = new Approximation12_1Stream(0.65, IndicatorObjPrefix + "_30");
   id = Approximation12_130.Init(id);
   tr13 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation13_131 = new Approximation13_1Stream(0.7, IndicatorObjPrefix + "_31");
   id = Approximation13_131.Init(id);
   tr14 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation14_132 = new Approximation14_1Stream(0.75, IndicatorObjPrefix + "_32");
   id = Approximation14_132.Init(id);
   tr15 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation15_133 = new Approximation15_1Stream(0.8, IndicatorObjPrefix + "_33");
   id = Approximation15_133.Init(id);
   tr16 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation16_134 = new Approximation16_1Stream(0.85, IndicatorObjPrefix + "_34");
   id = Approximation16_134.Init(id);
   tr17 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation17_135 = new Approximation17_1Stream(0.9, IndicatorObjPrefix + "_35");
   id = Approximation17_135.Init(id);
   tr18 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Approximation18_136 = new Approximation18_1Stream(0.95, IndicatorObjPrefix + "_36");
   id = Approximation18_136.Init(id);
   SetIndexBuffer(id++, Upper_Threshold_of_Approximability2);
   SetIndexBuffer(id++, Lower_Threshold_of_Approximability2);
   lele_137 = new lele_1Stream(Input, IndicatorObjPrefix + "_37");
   id = lele_137.Init(id);
   SetIndexBuffer(id++, REPAINT_MAJ_BUR);
   isNew1 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_MAJ_BER);
   isNew2 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_LTA);
   isNew3 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_UTA);
   isNew4 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_MAJ_BUL_ALERT);
   isNew5 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_MAJ_BER_ALERT);
   isNew6 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_LTA_ALERT);
   isNew7 = new NewBarState();
   SetIndexBuffer(id++, REPAINT_UTA_ALERT);
   isNew8 = new NewBarState();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete Approximation1_11;
   delete Approximation2_12;
   delete Approximation3_13;
   delete Approximation4_14;
   delete Approximation5_15;
   delete Approximation6_16;
   delete Approximation7_17;
   delete Approximation8_18;
   delete Approximation9_19;
   delete Approximation10_110;
   delete Approximation11_111;
   delete Approximation12_112;
   delete Approximation13_113;
   delete Approximation14_114;
   delete Approximation15_115;
   delete Approximation16_116;
   delete Approximation17_117;
   delete Approximation18_118;
   tr1.Release();
   delete Approximation1_119;
   tr2.Release();
   delete Approximation2_120;
   tr3.Release();
   delete Approximation3_121;
   tr4.Release();
   delete Approximation4_122;
   tr5.Release();
   delete Approximation5_123;
   tr6.Release();
   delete Approximation6_124;
   tr7.Release();
   delete Approximation7_125;
   tr8.Release();
   delete Approximation8_126;
   tr9.Release();
   delete Approximation9_127;
   tr10.Release();
   delete Approximation10_128;
   tr11.Release();
   delete Approximation11_129;
   tr12.Release();
   delete Approximation12_130;
   tr13.Release();
   delete Approximation13_131;
   tr14.Release();
   delete Approximation14_132;
   tr15.Release();
   delete Approximation15_133;
   tr16.Release();
   delete Approximation16_134;
   tr17.Release();
   delete Approximation17_135;
   tr18.Release();
   delete Approximation18_136;
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   ema4Source.Release();
   ema4.Release();
   ema5Source.Release();
   ema5.Release();
   ema6Source.Release();
   ema6.Release();
   ema7Source.Release();
   ema7.Release();
   ema8Source.Release();
   ema8.Release();
   ema9Source.Release();
   ema9.Release();
   ema10Source.Release();
   ema10.Release();
   ema11Source.Release();
   ema11.Release();
   ema12Source.Release();
   ema12.Release();
   delete lele_137;
   delete isNew1;
   delete isNew2;
   delete isNew3;
   delete isNew4;
   delete isNew5;
   delete isNew6;
   delete isNew7;
   delete isNew8;
   LinesCollection::Clear(true);
   LabelsCollection::Clear(true);
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
      LinesCollection::Clear();
      LabelsCollection::Clear();
      Approximation1_11.Clear();
      Approximation2_12.Clear();
      Approximation3_13.Clear();
      Approximation4_14.Clear();
      Approximation5_15.Clear();
      Approximation6_16.Clear();
      Approximation7_17.Clear();
      Approximation8_18.Clear();
      Approximation9_19.Clear();
      Approximation10_110.Clear();
      Approximation11_111.Clear();
      Approximation12_112.Clear();
      Approximation13_113.Clear();
      Approximation14_114.Clear();
      Approximation15_115.Clear();
      Approximation16_116.Clear();
      Approximation17_117.Clear();
      Approximation18_118.Clear();
      Approximation1_119.Clear();
      Approximation2_120.Clear();
      Approximation3_121.Clear();
      Approximation4_122.Clear();
      Approximation5_123.Clear();
      Approximation6_124.Clear();
      Approximation7_125.Clear();
      Approximation8_126.Clear();
      Approximation9_127.Clear();
      Approximation10_128.Clear();
      Approximation11_129.Clear();
      Approximation12_130.Clear();
      Approximation13_131.Clear();
      Approximation14_132.Clear();
      Approximation15_133.Clear();
      Approximation16_134.Clear();
      Approximation17_135.Clear();
      Approximation18_136.Clear();
      ema1Source.Init();
      ema2Source.Init();
      ema3Source.Init();
      ema4Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      Upper_Threshold_of_Approximability2_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Upper_Threshold_of_Approximability2, Upper_Threshold_of_Approximability2_DEFAULT_VALUE);
      Lower_Threshold_of_Approximability2_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Lower_Threshold_of_Approximability2, Lower_Threshold_of_Approximability2_DEFAULT_VALUE);
      ema5Source.Init();
      ema6Source.Init();
      ema7Source.Init();
      ema8Source.Init();
      ema9Source.Init();
      ema10Source.Init();
      ArrayInitialize(plot4, EMPTY_VALUE);
      ema11Source.Init();
      ema12Source.Init();
      ArrayInitialize(plot5, EMPTY_VALUE);
      lele_137.Clear();
      REPAINT_MAJ_BUR_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_MAJ_BUR, REPAINT_MAJ_BUR_DEFAULT_VALUE);
      isNew1.Clear();
      ArrayInitialize(plot6, EMPTY_VALUE);
      REPAINT_MAJ_BER_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_MAJ_BER, REPAINT_MAJ_BER_DEFAULT_VALUE);
      isNew2.Clear();
      ArrayInitialize(plot7, EMPTY_VALUE);
      REPAINT_LTA_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_LTA, REPAINT_LTA_DEFAULT_VALUE);
      isNew3.Clear();
      ArrayInitialize(plot8, EMPTY_VALUE);
      REPAINT_UTA_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_UTA, REPAINT_UTA_DEFAULT_VALUE);
      isNew4.Clear();
      ArrayInitialize(plot9, EMPTY_VALUE);
      REPAINT_MAJ_BUL_ALERT_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_MAJ_BUL_ALERT, REPAINT_MAJ_BUL_ALERT_DEFAULT_VALUE);
      isNew5.Clear();
      REPAINT_MAJ_BER_ALERT_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_MAJ_BER_ALERT, REPAINT_MAJ_BER_ALERT_DEFAULT_VALUE);
      isNew6.Clear();
      REPAINT_LTA_ALERT_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_LTA_ALERT, REPAINT_LTA_ALERT_DEFAULT_VALUE);
      isNew7.Clear();
      REPAINT_UTA_ALERT_DEFAULT_VALUE = false;
      ArrayInitialize(REPAINT_UTA_ALERT, REPAINT_UTA_ALERT_DEFAULT_VALUE);
      isNew8.Clear();
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
      REPAINT_MAJ_BUR[pos] = pos < (rates_total - 1) ? REPAINT_MAJ_BUR[pos + 1] : false;
      REPAINT_MAJ_BER[pos] = pos < (rates_total - 1) ? REPAINT_MAJ_BER[pos + 1] : false;
      REPAINT_LTA[pos] = pos < (rates_total - 1) ? REPAINT_LTA[pos + 1] : false;
      REPAINT_UTA[pos] = pos < (rates_total - 1) ? REPAINT_UTA[pos + 1] : false;
      REPAINT_MAJ_BUL_ALERT[pos] = pos < (rates_total - 1) ? REPAINT_MAJ_BUL_ALERT[pos + 1] : false;
      REPAINT_MAJ_BER_ALERT[pos] = pos < (rates_total - 1) ? REPAINT_MAJ_BER_ALERT[pos + 1] : false;
      REPAINT_LTA_ALERT[pos] = pos < (rates_total - 1) ? REPAINT_LTA_ALERT[pos + 1] : false;
      REPAINT_UTA_ALERT[pos] = pos < (rates_total - 1) ? REPAINT_UTA_ALERT[pos + 1] : false;
      double Approximation1_11Value;
      if (!Approximation1_11.GetValue(pos, open[pos], Approximation1_11Value)) { Approximation1_11Value = EMPTY_VALUE; }
      double Conjecture1 = Approximation1_11Value;
      double Approximation2_12Value;
      if (!Approximation2_12.GetValue(pos, open[pos], Approximation2_12Value)) { Approximation2_12Value = EMPTY_VALUE; }
      double Conjecture2 = Approximation2_12Value;
      double Approximation3_13Value;
      if (!Approximation3_13.GetValue(pos, open[pos], Approximation3_13Value)) { Approximation3_13Value = EMPTY_VALUE; }
      double Conjecture3 = Approximation3_13Value;
      double Approximation4_14Value;
      if (!Approximation4_14.GetValue(pos, open[pos], Approximation4_14Value)) { Approximation4_14Value = EMPTY_VALUE; }
      double Conjecture4 = Approximation4_14Value;
      double Approximation5_15Value;
      if (!Approximation5_15.GetValue(pos, open[pos], Approximation5_15Value)) { Approximation5_15Value = EMPTY_VALUE; }
      double Conjecture5 = Approximation5_15Value;
      double Approximation6_16Value;
      if (!Approximation6_16.GetValue(pos, open[pos], Approximation6_16Value)) { Approximation6_16Value = EMPTY_VALUE; }
      double Conjecture6 = Approximation6_16Value;
      double Approximation7_17Value;
      if (!Approximation7_17.GetValue(pos, open[pos], Approximation7_17Value)) { Approximation7_17Value = EMPTY_VALUE; }
      double Conjecture7 = Approximation7_17Value;
      double Approximation8_18Value;
      if (!Approximation8_18.GetValue(pos, open[pos], Approximation8_18Value)) { Approximation8_18Value = EMPTY_VALUE; }
      double Conjecture8 = Approximation8_18Value;
      double Approximation9_19Value;
      if (!Approximation9_19.GetValue(pos, open[pos], Approximation9_19Value)) { Approximation9_19Value = EMPTY_VALUE; }
      double Conjecture9 = Approximation9_19Value;
      double Approximation10_110Value;
      if (!Approximation10_110.GetValue(pos, open[pos], Approximation10_110Value)) { Approximation10_110Value = EMPTY_VALUE; }
      double Conjecture10 = Approximation10_110Value;
      double Approximation11_111Value;
      if (!Approximation11_111.GetValue(pos, open[pos], Approximation11_111Value)) { Approximation11_111Value = EMPTY_VALUE; }
      double Conjecture11 = Approximation11_111Value;
      double Approximation12_112Value;
      if (!Approximation12_112.GetValue(pos, open[pos], Approximation12_112Value)) { Approximation12_112Value = EMPTY_VALUE; }
      double Conjecture12 = Approximation12_112Value;
      double Approximation13_113Value;
      if (!Approximation13_113.GetValue(pos, open[pos], Approximation13_113Value)) { Approximation13_113Value = EMPTY_VALUE; }
      double Conjecture13 = Approximation13_113Value;
      double Approximation14_114Value;
      if (!Approximation14_114.GetValue(pos, open[pos], Approximation14_114Value)) { Approximation14_114Value = EMPTY_VALUE; }
      double Conjecture14 = Approximation14_114Value;
      double Approximation15_115Value;
      if (!Approximation15_115.GetValue(pos, open[pos], Approximation15_115Value)) { Approximation15_115Value = EMPTY_VALUE; }
      double Conjecture15 = Approximation15_115Value;
      double Approximation16_116Value;
      if (!Approximation16_116.GetValue(pos, open[pos], Approximation16_116Value)) { Approximation16_116Value = EMPTY_VALUE; }
      double Conjecture16 = Approximation16_116Value;
      double Approximation17_117Value;
      if (!Approximation17_117.GetValue(pos, open[pos], Approximation17_117Value)) { Approximation17_117Value = EMPTY_VALUE; }
      double Conjecture17 = Approximation17_117Value;
      double Approximation18_118Value;
      if (!Approximation18_118.GetValue(pos, open[pos], Approximation18_118Value)) { Approximation18_118Value = EMPTY_VALUE; }
      double Conjecture18 = Approximation18_118Value;
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      double Approximation1_119Value;
      if (!Approximation1_119.GetValue(pos, tr1Value, Approximation1_119Value)) { Approximation1_119Value = EMPTY_VALUE; }
      double tr2Value;
      if (!tr2.GetValue(pos, tr2Value)) { tr2Value = EMPTY_VALUE; }
      double Approximation2_120Value;
      if (!Approximation2_120.GetValue(pos, tr2Value, Approximation2_120Value)) { Approximation2_120Value = EMPTY_VALUE; }
      double tr3Value;
      if (!tr3.GetValue(pos, tr3Value)) { tr3Value = EMPTY_VALUE; }
      double Approximation3_121Value;
      if (!Approximation3_121.GetValue(pos, tr3Value, Approximation3_121Value)) { Approximation3_121Value = EMPTY_VALUE; }
      double tr4Value;
      if (!tr4.GetValue(pos, tr4Value)) { tr4Value = EMPTY_VALUE; }
      double Approximation4_122Value;
      if (!Approximation4_122.GetValue(pos, tr4Value, Approximation4_122Value)) { Approximation4_122Value = EMPTY_VALUE; }
      double tr5Value;
      if (!tr5.GetValue(pos, tr5Value)) { tr5Value = EMPTY_VALUE; }
      double Approximation5_123Value;
      if (!Approximation5_123.GetValue(pos, tr5Value, Approximation5_123Value)) { Approximation5_123Value = EMPTY_VALUE; }
      double tr6Value;
      if (!tr6.GetValue(pos, tr6Value)) { tr6Value = EMPTY_VALUE; }
      double Approximation6_124Value;
      if (!Approximation6_124.GetValue(pos, tr6Value, Approximation6_124Value)) { Approximation6_124Value = EMPTY_VALUE; }
      double tr7Value;
      if (!tr7.GetValue(pos, tr7Value)) { tr7Value = EMPTY_VALUE; }
      double Approximation7_125Value;
      if (!Approximation7_125.GetValue(pos, tr7Value, Approximation7_125Value)) { Approximation7_125Value = EMPTY_VALUE; }
      double tr8Value;
      if (!tr8.GetValue(pos, tr8Value)) { tr8Value = EMPTY_VALUE; }
      double Approximation8_126Value;
      if (!Approximation8_126.GetValue(pos, tr8Value, Approximation8_126Value)) { Approximation8_126Value = EMPTY_VALUE; }
      double tr9Value;
      if (!tr9.GetValue(pos, tr9Value)) { tr9Value = EMPTY_VALUE; }
      double Approximation9_127Value;
      if (!Approximation9_127.GetValue(pos, tr9Value, Approximation9_127Value)) { Approximation9_127Value = EMPTY_VALUE; }
      double tr10Value;
      if (!tr10.GetValue(pos, tr10Value)) { tr10Value = EMPTY_VALUE; }
      double Approximation10_128Value;
      if (!Approximation10_128.GetValue(pos, tr10Value, Approximation10_128Value)) { Approximation10_128Value = EMPTY_VALUE; }
      double tr11Value;
      if (!tr11.GetValue(pos, tr11Value)) { tr11Value = EMPTY_VALUE; }
      double Approximation11_129Value;
      if (!Approximation11_129.GetValue(pos, tr11Value, Approximation11_129Value)) { Approximation11_129Value = EMPTY_VALUE; }
      double tr12Value;
      if (!tr12.GetValue(pos, tr12Value)) { tr12Value = EMPTY_VALUE; }
      double Approximation12_130Value;
      if (!Approximation12_130.GetValue(pos, tr12Value, Approximation12_130Value)) { Approximation12_130Value = EMPTY_VALUE; }
      double tr13Value;
      if (!tr13.GetValue(pos, tr13Value)) { tr13Value = EMPTY_VALUE; }
      double Approximation13_131Value;
      if (!Approximation13_131.GetValue(pos, tr13Value, Approximation13_131Value)) { Approximation13_131Value = EMPTY_VALUE; }
      double tr14Value;
      if (!tr14.GetValue(pos, tr14Value)) { tr14Value = EMPTY_VALUE; }
      double Approximation14_132Value;
      if (!Approximation14_132.GetValue(pos, tr14Value, Approximation14_132Value)) { Approximation14_132Value = EMPTY_VALUE; }
      double tr15Value;
      if (!tr15.GetValue(pos, tr15Value)) { tr15Value = EMPTY_VALUE; }
      double Approximation15_133Value;
      if (!Approximation15_133.GetValue(pos, tr15Value, Approximation15_133Value)) { Approximation15_133Value = EMPTY_VALUE; }
      double tr16Value;
      if (!tr16.GetValue(pos, tr16Value)) { tr16Value = EMPTY_VALUE; }
      double Approximation16_134Value;
      if (!Approximation16_134.GetValue(pos, tr16Value, Approximation16_134Value)) { Approximation16_134Value = EMPTY_VALUE; }
      double tr17Value;
      if (!tr17.GetValue(pos, tr17Value)) { tr17Value = EMPTY_VALUE; }
      double Approximation17_135Value;
      if (!Approximation17_135.GetValue(pos, tr17Value, Approximation17_135Value)) { Approximation17_135Value = EMPTY_VALUE; }
      double tr18Value;
      if (!tr18.GetValue(pos, tr18Value)) { tr18Value = EMPTY_VALUE; }
      double Approximation18_136Value;
      if (!Approximation18_136.GetValue(pos, tr18Value, Approximation18_136Value)) { Approximation18_136Value = EMPTY_VALUE; }
      double Inapproximability = SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(Approximation1_119Value, Approximation2_120Value), Approximation3_121Value), Approximation4_122Value), Approximation5_123Value), Approximation6_124Value), Approximation7_125Value), Approximation8_126Value), Approximation9_127Value), Approximation10_128Value), Approximation11_129Value), Approximation12_130Value), Approximation13_131Value), Approximation14_132Value), Approximation15_133Value), Approximation16_134Value), Approximation17_135Value), Approximation18_136Value)), 18);
      double amlag = SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(Conjecture1, Conjecture2), Conjecture3), Conjecture4), Conjecture5), Conjecture6), Conjecture7), Conjecture8), Conjecture9), Conjecture10), Conjecture11), Conjecture12), Conjecture13), Conjecture14), Conjecture15), Conjecture16), Conjecture17), Conjecture18)), 18);
      double Upper_Threshold_of_Approximability1 = SafePlus(amlag, SafeMultiply(Inapproximability, 1.618));
      SetStream(Upper_Threshold_of_Approximability2, pos, SafePlus(amlag, SafeMultiply(SafeMultiply(2, Inapproximability), 1.618)), Upper_Threshold_of_Approximability2_DEFAULT_VALUE);
      double Lower_Threshold_of_Approximability1 = SafeMinus(amlag, SafeMultiply(Inapproximability, 1.618));
      SetStream(Lower_Threshold_of_Approximability2, pos, SafeMinus(amlag, SafeMultiply(SafeMultiply(2, Inapproximability), 1.618)), Lower_Threshold_of_Approximability2_DEFAULT_VALUE);
      uint bcolor = 0x808000;
      ema1Source.SetValue(pos, close[pos]);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      ema2Source.SetValue(pos, high[pos] - low[pos]);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      uint lower_color = (SafeLess(SafeMinus(ema1Value, SafeMultiply(ema2Value, 4)), Lower_Threshold_of_Approximability2[pos]) ? 0x0f790f : 0x0f790f);
      ema3Source.SetValue(pos, close[pos]);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      ema4Source.SetValue(pos, high[pos] - low[pos]);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      uint upper_color = (SafeGreater(SafePlus(ema3Value, SafeMultiply(ema4Value, 4)), Upper_Threshold_of_Approximability2[pos]) ? 0x1d1daa : 0x1d1daa);
      plot1[pos] = Upper_Threshold_of_Approximability2[pos];
      double hplot2 = plot1[pos];
      uint plot2_color = AddTransparency(bcolor, 50);
      if (plot2_color != INT_MAX) { plot2[pos] = amlag; }
      else { plot2[pos] = EMPTY_VALUE; }
      double alplot = plot2[pos];
      plot3[pos] = Lower_Threshold_of_Approximability2[pos];
      double lplot2 = plot3[pos];
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      int crossdn = SafeLess(high[pos], Upper_Threshold_of_Approximability2[pos + 1]) && SafeGE(high[pos + 1], Upper_Threshold_of_Approximability2[pos + 1]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      int crossup = SafeGreater(low[pos], Lower_Threshold_of_Approximability2[pos + 1]) && SafeLE(low[pos + 1], Lower_Threshold_of_Approximability2[pos + 1]);
      ema5Source.SetValue(pos, close[pos]);
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
      ema6Source.SetValue(pos, high[pos] - low[pos]);
      double ema6Value;
      if (!ema6.GetValue(pos, ema6Value)) { ema6Value = EMPTY_VALUE; }
      uint u_color = (SafeGreater(Upper_Threshold_of_Approximability2[pos], SafePlus(ema5Value, SafeMultiply(ema6Value, 4))) ? 0x1d1daa : INT_MAX);
      ema7Source.SetValue(pos, close[pos]);
      double ema7Value;
      if (!ema7.GetValue(pos, ema7Value)) { ema7Value = EMPTY_VALUE; }
      ema8Source.SetValue(pos, high[pos] - low[pos]);
      double ema8Value;
      if (!ema8.GetValue(pos, ema8Value)) { ema8Value = EMPTY_VALUE; }
      uint l_color = (SafeLess(Lower_Threshold_of_Approximability2[pos], SafeMinus(ema7Value, SafeMultiply(ema8Value, 4))) ? 0x0f790f : INT_MAX);
      ema9Source.SetValue(pos, close[pos]);
      double ema9Value;
      if (!ema9.GetValue(pos, ema9Value)) { ema9Value = EMPTY_VALUE; }
      ema10Source.SetValue(pos, high[pos] - low[pos]);
      double ema10Value;
      if (!ema10.GetValue(pos, ema10Value)) { ema10Value = EMPTY_VALUE; }
      plot4[pos] = SafePlus(ema9Value, SafeMultiply(ema10Value, 4));
      double u = plot4[pos];
      ema11Source.SetValue(pos, close[pos]);
      double ema11Value;
      if (!ema11.GetValue(pos, ema11Value)) { ema11Value = EMPTY_VALUE; }
      ema12Source.SetValue(pos, high[pos] - low[pos]);
      double ema12Value;
      if (!ema12.GetValue(pos, ema12Value)) { ema12Value = EMPTY_VALUE; }
      plot5[pos] = SafeMinus(ema11Value, SafeMultiply(ema12Value, 4));
      double l = plot5[pos];
      int p_display = true;
      int label_direction = true;
      string updown = (label_direction ? "down" : "up");
      string down = (label_direction ? "up" : "down");
      double liveprice = close[pos];
      int show_selllimitone = true;
      uint TPC = Green;
      uint BLC = Gray;
      int tpl_display = true;
      int slp = true;
      int blp1 = 1;
      int blp2 = 1;
      double blp3 = 0.77;
      double blp4 = 0.55;
      double blp5 = 0.27;
      double bep1 = 0.906;
      double bep2 = 0.807;
      double bep3 = 0.712;
      double bep4 = 0.624;
      double long_tp = liveprice * slp1;
      double long_bl1 = liveprice * blp1;
      double long_bl2 = liveprice * blp2;
      double long_bl3 = liveprice * blp3;
      double long_bl4 = liveprice * blp4;
      double long_bl5 = liveprice * blp5;
      double long_be1 = liveprice * bep1;
      double long_be2 = liveprice * bep2;
      double long_be3 = liveprice * bep3;
      double long_be4 = liveprice * bep4;
      if (show_marketorder)
      {
         Line* bl2 = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", ((rates_total - 1) - pos), long_bl2, ((rates_total - 1) - pos) + away + 100, long_bl2, time[pos]).SetColor(BLC).SetWidth(w_adjust).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
         LinesCollection::Delete(LinesCollection::Get(bl2, 1));
      }
      if (show_buylimit1)
      {
         Line* bl3 = LinesCollection::Create(IndicatorObjPrefix + "line_2_id", ((rates_total - 1) - pos), long_bl3, ((rates_total - 1) - pos) + away + 100, long_bl3, time[pos]).SetColor(BLC).SetWidth(w_adjust).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
         LinesCollection::Delete(LinesCollection::Get(bl3, 1));
      }
      if (show_buylimit2)
      {
         Line* bl4 = LinesCollection::Create(IndicatorObjPrefix + "line_3_id", ((rates_total - 1) - pos), long_bl4, ((rates_total - 1) - pos) + away + 100, long_bl4, time[pos]).SetColor(BLC).SetWidth(w_adjust).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
         LinesCollection::Delete(LinesCollection::Get(bl4, 1));
      }
      if (show_buylimit3)
      {
         Line* bl5 = LinesCollection::Create(IndicatorObjPrefix + "line_4_id", ((rates_total - 1) - pos), long_bl5, ((rates_total - 1) - pos) + away + 100, long_bl5, time[pos]).SetColor(BLC).SetWidth(w_adjust).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
         LinesCollection::Delete(LinesCollection::Get(bl5, 1));
      }
      if (show_takeprofit)
      {
         Line* lt = LinesCollection::Create(IndicatorObjPrefix + "line_5_id", ((rates_total - 1) - pos), long_tp, ((rates_total - 1) - pos) + away + 100, long_tp, time[pos]).SetColor(TPC).SetWidth(w_adjust).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
         LinesCollection::Delete(LinesCollection::Get(lt, 1));
      }
      if ((pos == 0))
      {
         double p1 = (slp ? long_tp : blp4);
         double p2 = (slp ? long_bl1 : blp4);
         double p3 = (slp ? long_bl1 : blp4);
         double p4 = (slp ? long_bl2 : blp4);
         double p5 = (slp ? long_bl3 : blp4);
         double p6 = (slp ? long_bl4 : blp4);
         double p7 = (slp ? long_bl5 : blp4);
         string p1t = Str::ToString(NormalizeDouble(p1, dp));
         int ln = 0;
         ln = SafeMinus(Str::Length(p1t), Str::Length(Str::ToString((int)(p1))));
         if ((ln == 0))
         {
            p1t = SafePlus(p1t, ".");
         }
         while ((ln < dp + 1))
         {
            p1t = SafePlus(p1t, "0");
            ln = SafeMinus(Str::Length(p1t), Str::Length(Str::ToString((int)(p1))));
         }
         string p2t = Str::ToString(NormalizeDouble(p2, dp));
         ln = SafeMinus(Str::Length(p2t), Str::Length(Str::ToString((int)(p2))));
         if ((ln == 0))
         {
            p2t = SafePlus(p2t, ".");
         }
         while ((ln < dp + 1))
         {
            p2t = SafePlus(p2t, "0");
            ln = SafeMinus(Str::Length(p2t), Str::Length(Str::ToString((int)(p2))));
         }
         string p3t = Str::ToString(NormalizeDouble(p3, dp));
         ln = SafeMinus(Str::Length(p3t), Str::Length(Str::ToString((int)(p3))));
         if ((ln == 0))
         {
            p3t = SafePlus(p3t, ".");
         }
         while ((ln < dp + 1))
         {
            p3t = SafePlus(p3t, "0");
            ln = SafeMinus(Str::Length(p3t), Str::Length(Str::ToString((int)(p3))));
         }
         string p4t = Str::ToString(NormalizeDouble(p4, dp));
         ln = SafeMinus(Str::Length(p4t), Str::Length(Str::ToString((int)(p4))));
         if ((ln == 0))
         {
            p4t = SafePlus(p4t, ".");
         }
         while ((ln < dp + 1))
         {
            p4t = SafePlus(p4t, "0");
            ln = SafeMinus(Str::Length(p4t), Str::Length(Str::ToString((int)(p4))));
         }
         string p5t = Str::ToString(NormalizeDouble(p5, dp));
         ln = SafeMinus(Str::Length(p5t), Str::Length(Str::ToString((int)(p5))));
         if ((ln == 0))
         {
            p5t = SafePlus(p5t, ".");
         }
         while ((ln < dp + 1))
         {
            p5t = SafePlus(p5t, "0");
            ln = SafeMinus(Str::Length(p5t), Str::Length(Str::ToString((int)(p5))));
         }
         string p6t = Str::ToString(NormalizeDouble(p6, dp));
         ln = SafeMinus(Str::Length(p6t), Str::Length(Str::ToString((int)(p6))));
         if ((ln == 0))
         {
            p6t = SafePlus(p6t, ".");
         }
         while ((ln < dp + 1))
         {
            p6t = SafePlus(p6t, "0");
            ln = SafeMinus(Str::Length(p6t), Str::Length(Str::ToString((int)(p6))));
         }
         string p7t = Str::ToString(NormalizeDouble(p7, dp));
         ln = SafeMinus(Str::Length(p7t), Str::Length(Str::ToString((int)(p7))));
         if ((ln == 0))
         {
            p7t = SafePlus(p7t, ".");
         }
         while ((ln < dp + 1))
         {
            p7t = SafePlus(p7t, "0");
            ln = SafeMinus(Str::Length(p7t), Str::Length(Str::ToString((int)(p7))));
         }
         if (show_takeprofit)
         {
            Label* lbl1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((rates_total - 1) - pos) + away, long_tp, time[pos]).SetColor(0x262422).SetText(SafePlus(((p_display ? p1t : NULL)), " - TAKE PROFIT")).SetTextColor(White).SetStyle(updown).SetSize("normal").SetYLoc("price").SetTextAlign("right");
            LabelsCollection::Delete(LabelsCollection::Get(lbl1, 1));
         }
         if (show_marketorder)
         {
            Label* lbl3 = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((rates_total - 1) - pos) + away, long_bl2, time[pos]).SetColor(0x262422).SetText(SafePlus(((p_display ? p4t : NULL)), " - MARKET ORDER ")).SetTextColor(White).SetStyle(down).SetSize("normal").SetYLoc("price").SetTextAlign("right");
            LabelsCollection::Delete(LabelsCollection::Get(lbl3, 1));
         }
         if (show_buylimit1)
         {
            Label* lbl4 = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", ((rates_total - 1) - pos) + away, long_bl3, time[pos]).SetColor(0x262422).SetText(SafePlus(((p_display ? p5t : NULL)), " - BUY LIMIT 1 ")).SetTextColor(White).SetStyle(down).SetSize("normal").SetYLoc("price").SetTextAlign("right");
            LabelsCollection::Delete(LabelsCollection::Get(lbl4, 1));
         }
         if (show_buylimit2)
         {
            Label* lbl5 = LabelsCollection::Create(IndicatorObjPrefix + "label_4_id", ((rates_total - 1) - pos) + away, long_bl4, time[pos]).SetColor(0x262422).SetText(SafePlus(((p_display ? p6t : NULL)), " - BUY LIMIT 2 ")).SetTextColor(White).SetStyle(down).SetSize("normal").SetYLoc("price").SetTextAlign("right");
            LabelsCollection::Delete(LabelsCollection::Get(lbl5, 1));
         }
         if (show_buylimit3)
         {
            Label* lbl6 = LabelsCollection::Create(IndicatorObjPrefix + "label_5_id", ((rates_total - 1) - pos) + away, long_bl5, time[pos]).SetColor(0x262422).SetText(SafePlus(((p_display ? p7t : NULL)), " - BUY LIMIT 3")).SetTextColor(White).SetStyle(down).SetSize("normal").SetYLoc("price").SetTextAlign("right");
            LabelsCollection::Delete(LabelsCollection::Get(lbl6, 1));
         }
      }
      int ValueOne = (2);
      int lele_137Value;
      if (!lele_137.GetValue(pos, ValueOne, lele_137Value)) { lele_137Value = INT_MIN; }
      int major = lele_137Value;
      double major_bearish_reversal = (((major == (-1)) ? high[pos] : EMPTY_VALUE));
      double major_bullish_reversal = (((major == 1) ? low[pos] : EMPTY_VALUE));
      if (isNew1.IsNew(time[pos]))
      {
         SetStream(REPAINT_MAJ_BUR, pos, false, REPAINT_MAJ_BUR_DEFAULT_VALUE);
      }
      if (NumberToBool(major_bullish_reversal))
      {
         SetStream(REPAINT_MAJ_BUR, pos, true, REPAINT_MAJ_BUR_DEFAULT_VALUE);
      }
      int MAJ_BUR_NO_REPAINT = (pos > 0);
      PlotShape::SetBool(plot6, pos, "belowbar", NumberToBool(major_bullish_reversal) && MAJ_BUR_NO_REPAINT, high, low, 0);
      if (isNew2.IsNew(time[pos]))
      {
         SetStream(REPAINT_MAJ_BER, pos, false, REPAINT_MAJ_BER_DEFAULT_VALUE);
      }
      if (NumberToBool(major_bearish_reversal))
      {
         SetStream(REPAINT_MAJ_BER, pos, true, REPAINT_MAJ_BER_DEFAULT_VALUE);
      }
      int MAJ_BER_NO_REPAINT = (pos > 0);
      PlotShape::SetBool(plot7, pos, "abovebar", NumberToBool(major_bearish_reversal) && MAJ_BER_NO_REPAINT, high, low, 0);
      if (isNew3.IsNew(time[pos]))
      {
         SetStream(REPAINT_LTA, pos, false, REPAINT_LTA_DEFAULT_VALUE);
      }
      if (NumberToBool(Lower_Threshold_of_Approximability2[pos]))
      {
         SetStream(REPAINT_LTA, pos, true, REPAINT_LTA_DEFAULT_VALUE);
      }
      int LTA_NO_REPAINT = (pos > 0);
      PlotShape::SetBool(plot8, pos, "belowbar", (crossup ? NumberToBool(Lower_Threshold_of_Approximability2[pos]) && LTA_NO_REPAINT : (-1)), high, low, 0);
      if (isNew4.IsNew(time[pos]))
      {
         SetStream(REPAINT_UTA, pos, false, REPAINT_UTA_DEFAULT_VALUE);
      }
      if (NumberToBool(Upper_Threshold_of_Approximability2[pos]))
      {
         SetStream(REPAINT_UTA, pos, true, REPAINT_UTA_DEFAULT_VALUE);
      }
      int UTA_NO_REPAINT = (pos > 0);
      PlotShape::SetBool(plot9, pos, "abovebar", (crossdn ? NumberToBool(Upper_Threshold_of_Approximability2[pos]) && UTA_NO_REPAINT : (-1)), high, low, 0);
      if (isNew5.IsNew(time[pos]))
      {
         SetStream(REPAINT_MAJ_BUL_ALERT, pos, false, REPAINT_MAJ_BUL_ALERT_DEFAULT_VALUE);
      }
      if (NumberToBool(major_bullish_reversal))
      {
         SetStream(REPAINT_MAJ_BUL_ALERT, pos, true, REPAINT_MAJ_BUL_ALERT_DEFAULT_VALUE);
      }
      int MAJ_BUL_ALERT_NO_REPAINT = (pos > 0);
      if (NumberToBool(major_bullish_reversal) && MAJ_BUL_ALERT_NO_REPAINT) { _signaler.SendNotifications("Buy", "Buy Signal"); }
      if (isNew6.IsNew(time[pos]))
      {
         SetStream(REPAINT_MAJ_BER_ALERT, pos, false, REPAINT_MAJ_BER_ALERT_DEFAULT_VALUE);
      }
      if (NumberToBool(major_bearish_reversal))
      {
         SetStream(REPAINT_MAJ_BER_ALERT, pos, true, REPAINT_MAJ_BER_ALERT_DEFAULT_VALUE);
      }
      int MAJ_BER_ALERT_NO_REPAINT = (pos > 0);
      if (NumberToBool(major_bearish_reversal) && MAJ_BER_ALERT_NO_REPAINT) { _signaler.SendNotifications("Sell", "Sell Signal"); }
      if (isNew7.IsNew(time[pos]))
      {
         SetStream(REPAINT_LTA_ALERT, pos, false, REPAINT_LTA_ALERT_DEFAULT_VALUE);
      }
      if (NumberToBool(Lower_Threshold_of_Approximability2[pos]))
      {
         SetStream(REPAINT_LTA_ALERT, pos, true, REPAINT_LTA_ALERT_DEFAULT_VALUE);
      }
      int REPAINT_LTA_ALERT_NO_REPAINT = (pos > 0);
      if ((crossup ? NumberToBool(Lower_Threshold_of_Approximability2[pos]) && REPAINT_LTA_ALERT_NO_REPAINT : (-1))) { _signaler.SendNotifications("Strong Buy", "Strong Buy Signal"); }
      if (isNew8.IsNew(time[pos]))
      {
         SetStream(REPAINT_UTA_ALERT, pos, false, REPAINT_UTA_ALERT_DEFAULT_VALUE);
      }
      if (NumberToBool(Upper_Threshold_of_Approximability2[pos]))
      {
         SetStream(REPAINT_UTA_ALERT, pos, true, REPAINT_UTA_ALERT_DEFAULT_VALUE);
      }
      int UTA_ALERT_NO_REPAINT = (pos > 0);
      if ((crossdn ? NumberToBool(Upper_Threshold_of_Approximability2[pos]) && UTA_ALERT_NO_REPAINT : (-1))) { _signaler.SendNotifications("Strong Sell", "Strong Sell Signal"); }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76387
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