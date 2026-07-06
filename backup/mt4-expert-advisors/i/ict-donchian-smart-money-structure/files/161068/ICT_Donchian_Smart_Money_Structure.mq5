//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160959#p160959
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
#property indicator_buffers 28
#property indicator_plots 12
#property indicator_label1 "Range High"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Range Low"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Premium"
#property indicator_type3 DRAW_NONE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Premium"
#property indicator_type4 DRAW_NONE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Discount"
#property indicator_type5 DRAW_NONE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Discount"
#property indicator_type6 DRAW_NONE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Equilibrium"
#property indicator_type7 DRAW_NONE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Equilibrium"
#property indicator_type8 DRAW_NONE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_type9 DRAW_FILLING
#property indicator_width9 1
#property indicator_type10 DRAW_FILLING
#property indicator_width10 1
#property indicator_type11 DRAW_FILLING
#property indicator_width11 1
#property indicator_type12 DRAW_COLOR_CANDLES

#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
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
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}
// Pine-script like safe operations
// v1.2

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

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
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
// Float stream v2.0

class FloatStream : public AFloatStream
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
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
// Pivot high stream v1.0



//AOnStream v2.0
class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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

//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
   }
   
   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};
// AStream v1.1

class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
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

// Simple price stream v1.0
class SimplePriceStream : public AStream
{
   PriceType _price;
   double _pipSize;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PriceClose:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PriceOpen:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PriceHigh:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PriceLow:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PriceMedian:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PriceTypical:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PriceWeighted:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
               break;
            case PriceMedianBody:
               val[i] = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
               break;
            case PriceAverage:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
               break;
            case PriceTrendBiased:
               {
                  double close = iClose(_symbol, _timeframe, period);
                  if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                     val[i] = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
                  else
                     val[i] = (iLow(_symbol, _timeframe, period) + close) / 2.0;
               }
               break;
            case PriceVolume:
               val[i] = (double)iVolume(_symbol, _timeframe, period);
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
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
   
      
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Pivot low stream v1.0





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
   
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Collection of labels v1.1

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.3

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   string _textAlign;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
public:
   Label(int x, double y, string labelId, string collectionId, int window)
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
   void SetX(int x)
   {
      _x = x;
   }
   static void SetX(Label* label, int x)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetX(x);
   }
   void SetY(double y)
   {
      _y = y;
   }
   static void SetY(Label* label, double y)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetY(y);
   }
   void SetXY(int x, double y)
   {
      SetX(x);
      SetY(y);
   }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetXY(x, y);
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
   
   Label* SetColor(color clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, color clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
   }
   Label* SetTextColor(color clr)
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
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE, 1, y);
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
         delete _labels[i];
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

   static Label* Create(string id, int x, double y, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string labelId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      Label* label = new Label(x, y, labelId, id, ChartWindowOnDropped());
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      if (_all.Count() > _maxLabels)
      {
         Delete(_all.GetFirst());
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
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      delete label;
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
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
#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract Int stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL
// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
};

#endif

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
// Int stream v1.0

class IntStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _stream[];
public:
   IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, int value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, int &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
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
// Collection of lines v1.1

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

// Line object v1.5

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
   ~Line()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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

   static Line* SetColor(Line* line, color clr) { if (line == NULL) { return NULL; } return line.SetColor(clr); }
   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   static Line* SetStyle(Line* line, string style) { if (line == NULL) { return NULL; } return line.SetStyle(style); }
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }

   static Line* SetWidth(Line* line, int width) { if (line == NULL) { return NULL; } return line.SetWidth(width); }
   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int totalBars = iBars(_Symbol, _timeframe);
      datetime x1 = GetTime(_x1, totalBars);
      datetime x2 = GetTime(_x2, totalBars);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, x2);
   }
private:
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};

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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string lineId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped());
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
// Colored fill v1.2



#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
   IStream* top;
   IStream* bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = NULL;
      bottom = NULL;
   }
   ~ColoredFill()
   {
      if (top != NULL)
      {
         top.Release();
      }
      if (bottom != NULL)
      {
         bottom.Release();
      }
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(IStream* top, IStream* bottom)
   {
      this.top = top;
      top.AddRef();
      this.bottom = bottom;
      bottom.AddRef();
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      clr = GetColorOnly(clr);
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((uint)clr);
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, uint clr)
   {
      int transp = GetTranparency(clr);
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(period, value1);
      value2 = LimitValue(period, value2);
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
private:
   double LimitValue(int pos, double value)
   {
      if (top == NULL || bottom == NULL)
      {
         return value;
      }
      double topValue[1];
      if (!top.GetValues(pos, 1, topValue))
      {
         return value;
      }
      double bottomValue[1];
      if (!bottom.GetValues(pos, 1, bottomValue))
      {
         return value;
      }
      if (value > topValue[0])
      {
         return topValue[0];
      }
      if (value < bottomValue[0])
      {
         return bottomValue[0];
      }
      return value;
   }   
};
#endif




// Highest high stream v1.6

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
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMax(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return HighestHighStream::GetValue(oldPos, val, _source, _loopback);
   }
};




// Lowest low stream v1.6

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
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMin(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return LowestLowStream::GetValue(oldPos, val, _source, _loopback);
   }
};
// Candles stream v.1.0
class CandleStreams
{
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   double ColorIndex[];
   color colors[];
   int streamIndex;
public:
   CandleStreams(int streamIndex)
   {
      this.streamIndex = streamIndex;
   }
   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
      ArrayInitialize(ColorIndex, 0);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
      ColorIndex[index] = 0;
   }
   
   void AddColor(color clr)
   {
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = clr;
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, OpenStream, INDICATOR_DATA);
      SetIndexBuffer(id + 1, HighStream, INDICATOR_DATA);
      SetIndexBuffer(id + 2, LowStream, INDICATOR_DATA);
      SetIndexBuffer(id + 3, CloseStream, INDICATOR_DATA);
      SetIndexBuffer(id + 4, ColorIndex, INDICATOR_COLOR_INDEX);
      int size = ArraySize(colors);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size);
      for (int i = 0; i < size; ++i)
      {
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, i, colors[i]);
      }
      return id + 5;
   }
   
   void Set(const int index, const double open, const double high, const double low, const double close, color clr)
   {
      if (clr == (color)EMPTY_VALUE)
      {
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
      ColorIndex[index] = FindColor(clr);
   }
   
   void SetOffset(int offset)
   {
   }
private:
   int FindColor(color clr)
   {
      int size = ArraySize(colors);
      for (int i = 0; i < size; ++i)
      {
         if (colors[i] == clr)
         {
            return i;
         }
      }
      return 0;
   }
};
input int param1 = 20; // Structure Period
input bool param2 = true; // Structure Response??
input int param3 = 7; // 
input bool param4 = true; // Bullish Structure?????
input color param5 = ColorRGB(8, 236, 126, 0); // 
input color param6 = ColorRGB(8, 236, 126, 0); // 
input bool param7 = true; // Bearish Structure????
input color param8 = ColorRGB(255, 34, 34, 0); // 
input color param9 = ColorRGB(255, 34, 34, 0); // 
input bool param10 = true; // Premium & Discount
input color param11 = AddTransparency(ColorRGB(255, 34, 34, 0), 80); // 
input color param12 = AddTransparency(ColorRGB(8, 236, 126, 0), 80); // 
input bool param13 = false; // Donchian Channel
input bool param14 = true; // Structure Candles
input int param15 = 40; // Structure Response
input int bars_limit = 1000; // Bars limit
int prd;
int s1;
int resp;
int bull;
uint bull2;
uint bull3;
int bear;
uint bear2;
uint bear3;
int showPD;
uint prem;
uint disc;
int don;
int Candle;
int length;
int b;
double Up[];
double Up_DEFAULT_VALUE;
double Dn[];
double Dn_DEFAULT_VALUE;
double iUp[];
double iUp_DEFAULT_VALUE;
double iDn[];
double iDn_DEFAULT_VALUE;
FloatStream* highestpivot1Source;
FloatStream* lowestpivot1Source;
double _pos[];
double _pos_DEFAULT_VALUE;
class CreateLabel_iS_fS_s_c_bStream
{
   IIntStream* x;
   IStream* y;
   string txt;
   uint col;
   int z;
   bool _initialized;
public:
   CreateLabel_iS_fS_s_c_bStream(IIntStream* x, IStream* y, string txt, uint col, int z)
   {
      _initialized = false;
      this.x = x;
      x.AddRef();
      this.y = y;
      y.AddRef();
      this.txt = txt;
      this.col = col;
      this.z = z;
   }
   ~CreateLabel_iS_fS_s_c_bStream()
   {
      x.Release();
      y.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, Label* &__out1)
   {
      int xValue[1];
      if (!x.GetValues(pos, 1, xValue)) { xValue[0] = INT_MIN; }
      double yValue[1];
      if (!y.GetValues(pos, 1, yValue)) { yValue[0] = EMPTY_VALUE; }
      __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", xValue[0], yValue[0], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((uint)(INT_MIN)).SetText(txt).SetTextColor(col).SetStyle((z ? "down" : "up")).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      return true;
   }
};
IntStream* CreateLabel_iS_fS_s_c_b1_param1;
FloatStream* CreateLabel_iS_fS_s_c_b1_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b1;
class CreateLine_iS_fS_fS_cStream
{
   IIntStream* x1;
   IStream* x2;
   IStream* y;
   uint col;
   bool _initialized;
public:
   CreateLine_iS_fS_fS_cStream(IIntStream* x1, IStream* x2, IStream* y, uint col)
   {
      _initialized = false;
      this.x1 = x1;
      x1.AddRef();
      this.x2 = x2;
      x2.AddRef();
      this.y = y;
      y.AddRef();
      this.col = col;
   }
   ~CreateLine_iS_fS_fS_cStream()
   {
      x1.Release();
      x2.Release();
      y.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, Line* &__out1)
   {
      int x1Value[1];
      if (!x1.GetValues(pos, 1, x1Value)) { x1Value[0] = INT_MIN; }
      double x2Value[1];
      if (!x2.GetValues(pos, 1, x2Value)) { x2Value[0] = EMPTY_VALUE; }
      double yValue[1];
      if (!y.GetValues(pos, 1, yValue)) { yValue[0] = EMPTY_VALUE; }
      __out1 = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", x1Value[0], x2Value[0], b, yValue[0], iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(col).SetWidth(1).SetStyle("solid");
      return true;
   }
};
IntStream* CreateLine_iS_fS_fS_c2_param1;
FloatStream* CreateLine_iS_fS_fS_c2_param2;
FloatStream* CreateLine_iS_fS_fS_c2_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c2;
IntStream* CreateLabel_iS_fS_s_c_b3_param1;
FloatStream* CreateLabel_iS_fS_s_c_b3_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b3;
IntStream* CreateLine_iS_fS_fS_c4_param1;
FloatStream* CreateLine_iS_fS_fS_c4_param2;
FloatStream* CreateLine_iS_fS_fS_c4_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c4;
IntStream* CreateLabel_iS_fS_s_c_b5_param1;
FloatStream* CreateLabel_iS_fS_s_c_b5_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b5;
IntStream* CreateLine_iS_fS_fS_c6_param1;
FloatStream* CreateLine_iS_fS_fS_c6_param2;
FloatStream* CreateLine_iS_fS_fS_c6_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c6;
IntStream* CreateLabel_iS_fS_s_c_b7_param1;
FloatStream* CreateLabel_iS_fS_s_c_b7_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b7;
IntStream* CreateLine_iS_fS_fS_c8_param1;
FloatStream* CreateLine_iS_fS_fS_c8_param2;
FloatStream* CreateLine_iS_fS_fS_c8_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c8;
IntStream* CreateLabel_iS_fS_s_c_b9_param1;
FloatStream* CreateLabel_iS_fS_s_c_b9_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b9;
IntStream* CreateLine_iS_fS_fS_c10_param1;
FloatStream* CreateLine_iS_fS_fS_c10_param2;
FloatStream* CreateLine_iS_fS_fS_c10_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c10;
IntStream* CreateLabel_iS_fS_s_c_b11_param1;
FloatStream* CreateLabel_iS_fS_s_c_b11_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b11;
IntStream* CreateLine_iS_fS_fS_c12_param1;
FloatStream* CreateLine_iS_fS_fS_c12_param2;
FloatStream* CreateLine_iS_fS_fS_c12_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c12;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
ColoredFill* fill9;
ColoredFill* fill10;
ColoredFill* fill11;
class DonCandles_fS_fS_fS_fS_b_b_iStream
{
   IStream* high_;
   IStream* low_;
   IStream* close_;
   IStream* src_;
   int factor_;
   int candle_;
   int length_;
   FloatStream* highest1Source;
   FloatStream* lowest1Source;
   double initial[];
   double initial_DEFAULT_VALUE;
   bool _initialized;
public:
   DonCandles_fS_fS_fS_fS_b_b_iStream(IStream* high_, IStream* low_, IStream* close_, IStream* src_, int factor_, int candle_, int length_)
   {
      _initialized = false;
      this.high_ = high_;
      high_.AddRef();
      this.low_ = low_;
      low_.AddRef();
      this.close_ = close_;
      close_.AddRef();
      this.src_ = src_;
      src_.AddRef();
      this.factor_ = factor_;
      this.candle_ = candle_;
      this.length_ = length_;
      highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~DonCandles_fS_fS_fS_fS_b_b_iStream()
   {
      high_.Release();
      low_.Release();
      close_.Release();
      src_.Release();
      highest1Source.Release();
      lowest1Source.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, initial, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1)
   {
      if (!_initialized)
      {
         highest1Source.Init();
         lowest1Source.Init();
         initial_DEFAULT_VALUE = 0.0;
         ArrayInitialize(initial, initial_DEFAULT_VALUE);
         _initialized = true;
      }
      double high_Value[1];
      if (!high_.GetValues(pos, 1, high_Value)) { high_Value[0] = EMPTY_VALUE; }
      highest1Source.SetValue(pos, high_Value[0]);
      double highest1Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest1Value, highest1Source, length_)) { highest1Value[0] = EMPTY_VALUE; }
      double Don_High = highest1Value[0];
      double low_Value[1];
      if (!low_.GetValues(pos, 1, low_Value)) { low_Value[0] = EMPTY_VALUE; }
      lowest1Source.SetValue(pos, low_Value[0]);
      double lowest1Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest1Value, lowest1Source, length_)) { lowest1Value[0] = EMPTY_VALUE; }
      double Don_Low = lowest1Value[0];
      double close_Value[1];
      if (!close_.GetValues(pos, 1, close_Value)) { close_Value[0] = EMPTY_VALUE; }
      double Norm = (SafeDivide((SafeMinus(close_Value[0], Don_Low)), (SafeMinus(Don_High, Don_Low))));
      if (pos - 1 < 0) { return false; }
      if (pos - 1 < 0) { return false; }
      SetStream(initial, pos, (candle_ ? (SafePlus(SafeMultiply(Norm, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)), SafeMultiply(((SafeMinus(1, Norm))), Nz(initial[pos - 1], iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos))))) : (SafePlus(SafeMultiply(Norm, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)), SafeMultiply(((SafeMinus(1, SafeMultiply(Norm, 2)))), Nz(initial[pos - 1], iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)))))), initial_DEFAULT_VALUE);
      if (pos - 1 < 0) { return false; }
      double src_Value[1];
      if (!src_.GetValues(pos, 1, src_Value)) { src_Value[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { return false; }
      double Factor = (candle_ ? SafeMultiply((SafeMinus(1, Norm)), Nz(initial[pos - 1], src_Value[0])) : SafeMultiply(((factor_ ? (SafeMinus(1, SafeMultiply(Norm, 2))) : (SafeMinus(1, SafeDivide(Norm, 2))))), Nz(initial[pos - 1], src_Value[0])));
      double output = SafePlus((SafeMultiply(Norm, src_Value[0])), Factor);
      __out1 = output;
      return true;
   }
};
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i13;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i14;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i15;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i16;
class pricewick_fS_fSStream
{
   IStream* h_;
   IStream* a;
   bool _initialized;
public:
   pricewick_fS_fSStream(IStream* h_, IStream* a)
   {
      _initialized = false;
      this.h_ = h_;
      h_.AddRef();
      this.a = a;
      a.AddRef();
   }
   ~pricewick_fS_fSStream()
   {
      h_.Release();
      a.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      double h_Value[1];
      if (!h_.GetValues(pos, 1, h_Value)) { h_Value[0] = EMPTY_VALUE; }
      double aValue[1];
      if (!a.GetValues(pos, 1, aValue)) { aValue[0] = EMPTY_VALUE; }
      int cond = (h_Value[0] > aValue[0]);
      __out1 = cond;
      return true;
   }
};
FloatStream* pricewick_fS_fS17_param1;
FloatStream* pricewick_fS_fS17_param2;
pricewick_fS_fSStream* pricewick_fS_fS17;
FloatStream* pricewick_fS_fS18_param1;
FloatStream* pricewick_fS_fS18_param2;
pricewick_fS_fSStream* pricewick_fS_fS18;
FloatStream* pricewick_fS_fS19_param1;
FloatStream* pricewick_fS_fS19_param2;
pricewick_fS_fSStream* pricewick_fS_fS19;
FloatStream* pricewick_fS_fS20_param1;
FloatStream* pricewick_fS_fS20_param2;
pricewick_fS_fSStream* pricewick_fS_fS20;
CandleStreams* plotcandle1;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

void OnInit()
{
   int id = 0;
   prd = param1;
   s1 = param2;
   resp = param3;
   bull = param4;
   bull2 = param5;
   bull3 = param6;
   bear = param7;
   bear2 = param8;
   bear3 = param9;
   showPD = param10;
   prem = param11;
   disc = param12;
   don = param13;
   Candle = param14;
   length = param15;
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, bear2);
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, bull2);
   ++id;
   SetIndexBuffer(id++, plot3, INDICATOR_DATA);
   SetIndexBuffer(id++, plot4, INDICATOR_DATA);
   SetIndexBuffer(id++, plot5, INDICATOR_DATA);
   SetIndexBuffer(id++, plot6, INDICATOR_DATA);
   SetIndexBuffer(id++, plot7, INDICATOR_DATA);
   SetIndexBuffer(id++, plot8, INDICATOR_DATA);
   fill9 = new ColoredFill(8);
   fill9.AddColor(prem);
   id = fill9.RegisterStreams(id);
   fill10 = new ColoredFill(9);
   fill10.AddColor(disc);
   id = fill10.RegisterStreams(id);
   fill11 = new ColoredFill(10);
   fill11.AddColor(AddTransparency(Gray, 75));
   id = fill11.RegisterStreams(id);
   plotcandle1 = new CandleStreams(11);
   plotcandle1.AddColor(Lime);
   plotcandle1.AddColor(Red);
   plotcandle1.AddColor(INT_MIN);
   id = plotcandle1.RegisterStreams(id);
   LabelsCollection::SetMaxLabels(500);
   LinesCollection::SetMaxLines(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "ICT Donchian Smart Money Structure");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, Up, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Dn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, iUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, iDn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, _pos, INDICATOR_CALCULATIONS);
   CreateLabel_iS_fS_s_c_b1_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b1_param1, CreateLabel_iS_fS_s_c_b1_param2, "CHoCH", bull3, true);
   id = CreateLabel_iS_fS_s_c_b1.Init(id);
   CreateLine_iS_fS_fS_c2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c2_param1, CreateLine_iS_fS_fS_c2_param2, CreateLine_iS_fS_fS_c2_param3, bull2);
   id = CreateLine_iS_fS_fS_c2.Init(id);
   CreateLabel_iS_fS_s_c_b3_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b3_param1, CreateLabel_iS_fS_s_c_b3_param2, "SMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b3.Init(id);
   CreateLine_iS_fS_fS_c4_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c4_param1, CreateLine_iS_fS_fS_c4_param2, CreateLine_iS_fS_fS_c4_param3, bull2);
   id = CreateLine_iS_fS_fS_c4.Init(id);
   CreateLabel_iS_fS_s_c_b5_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b5_param1, CreateLabel_iS_fS_s_c_b5_param2, "BMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b5.Init(id);
   CreateLine_iS_fS_fS_c6_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c6_param1, CreateLine_iS_fS_fS_c6_param2, CreateLine_iS_fS_fS_c6_param3, bull2);
   id = CreateLine_iS_fS_fS_c6.Init(id);
   CreateLabel_iS_fS_s_c_b7_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b7_param1, CreateLabel_iS_fS_s_c_b7_param2, "CHoCH", bear3, false);
   id = CreateLabel_iS_fS_s_c_b7.Init(id);
   CreateLine_iS_fS_fS_c8_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c8_param1, CreateLine_iS_fS_fS_c8_param2, CreateLine_iS_fS_fS_c8_param3, bear2);
   id = CreateLine_iS_fS_fS_c8.Init(id);
   CreateLabel_iS_fS_s_c_b9_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b9_param1, CreateLabel_iS_fS_s_c_b9_param2, "SMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b9.Init(id);
   CreateLine_iS_fS_fS_c10_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c10_param1, CreateLine_iS_fS_fS_c10_param2, CreateLine_iS_fS_fS_c10_param3, bear2);
   id = CreateLine_iS_fS_fS_c10.Init(id);
   CreateLabel_iS_fS_s_c_b11_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b11_param1, CreateLabel_iS_fS_s_c_b11_param2, "BMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b11.Init(id);
   CreateLine_iS_fS_fS_c12_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c12_param1, CreateLine_iS_fS_fS_c12_param2, CreateLine_iS_fS_fS_c12_param3, bear2);
   id = CreateLine_iS_fS_fS_c12.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i13_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i13_param1, DonCandles_fS_fS_fS_fS_b_b_i13_param2, DonCandles_fS_fS_fS_fS_b_b_i13_param3, DonCandles_fS_fS_fS_fS_b_b_i13_param4, true, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i13.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i14_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i14_param1, DonCandles_fS_fS_fS_fS_b_b_i14_param2, DonCandles_fS_fS_fS_fS_b_b_i14_param3, DonCandles_fS_fS_fS_fS_b_b_i14_param4, false, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i14.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i15_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i15_param1, DonCandles_fS_fS_fS_fS_b_b_i15_param2, DonCandles_fS_fS_fS_fS_b_b_i15_param3, DonCandles_fS_fS_fS_fS_b_b_i15_param4, false, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i15.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i16_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i16_param1, DonCandles_fS_fS_fS_fS_b_b_i16_param2, DonCandles_fS_fS_fS_fS_b_b_i16_param3, DonCandles_fS_fS_fS_fS_b_b_i16_param4, true, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i16.Init(id);
   pricewick_fS_fS17_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS17_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS17 = new pricewick_fS_fSStream(pricewick_fS_fS17_param1, pricewick_fS_fS17_param2);
   id = pricewick_fS_fS17.Init(id);
   pricewick_fS_fS18_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS18_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS18 = new pricewick_fS_fSStream(pricewick_fS_fS18_param1, pricewick_fS_fS18_param2);
   id = pricewick_fS_fS18.Init(id);
   pricewick_fS_fS19_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS19_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS19 = new pricewick_fS_fSStream(pricewick_fS_fS19_param1, pricewick_fS_fS19_param2);
   id = pricewick_fS_fS19.Init(id);
   pricewick_fS_fS20_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS20_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS20 = new pricewick_fS_fSStream(pricewick_fS_fS20_param1, pricewick_fS_fS20_param2);
   id = pricewick_fS_fS20.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   highestpivot1Source.Release();
   lowestpivot1Source.Release();
   CreateLabel_iS_fS_s_c_b1_param1.Release();
   CreateLabel_iS_fS_s_c_b1_param2.Release();
   delete CreateLabel_iS_fS_s_c_b1;
   CreateLine_iS_fS_fS_c2_param1.Release();
   CreateLine_iS_fS_fS_c2_param2.Release();
   CreateLine_iS_fS_fS_c2_param3.Release();
   delete CreateLine_iS_fS_fS_c2;
   CreateLabel_iS_fS_s_c_b3_param1.Release();
   CreateLabel_iS_fS_s_c_b3_param2.Release();
   delete CreateLabel_iS_fS_s_c_b3;
   CreateLine_iS_fS_fS_c4_param1.Release();
   CreateLine_iS_fS_fS_c4_param2.Release();
   CreateLine_iS_fS_fS_c4_param3.Release();
   delete CreateLine_iS_fS_fS_c4;
   CreateLabel_iS_fS_s_c_b5_param1.Release();
   CreateLabel_iS_fS_s_c_b5_param2.Release();
   delete CreateLabel_iS_fS_s_c_b5;
   CreateLine_iS_fS_fS_c6_param1.Release();
   CreateLine_iS_fS_fS_c6_param2.Release();
   CreateLine_iS_fS_fS_c6_param3.Release();
   delete CreateLine_iS_fS_fS_c6;
   CreateLabel_iS_fS_s_c_b7_param1.Release();
   CreateLabel_iS_fS_s_c_b7_param2.Release();
   delete CreateLabel_iS_fS_s_c_b7;
   CreateLine_iS_fS_fS_c8_param1.Release();
   CreateLine_iS_fS_fS_c8_param2.Release();
   CreateLine_iS_fS_fS_c8_param3.Release();
   delete CreateLine_iS_fS_fS_c8;
   CreateLabel_iS_fS_s_c_b9_param1.Release();
   CreateLabel_iS_fS_s_c_b9_param2.Release();
   delete CreateLabel_iS_fS_s_c_b9;
   CreateLine_iS_fS_fS_c10_param1.Release();
   CreateLine_iS_fS_fS_c10_param2.Release();
   CreateLine_iS_fS_fS_c10_param3.Release();
   delete CreateLine_iS_fS_fS_c10;
   CreateLabel_iS_fS_s_c_b11_param1.Release();
   CreateLabel_iS_fS_s_c_b11_param2.Release();
   delete CreateLabel_iS_fS_s_c_b11;
   CreateLine_iS_fS_fS_c12_param1.Release();
   CreateLine_iS_fS_fS_c12_param2.Release();
   CreateLine_iS_fS_fS_c12_param3.Release();
   delete CreateLine_iS_fS_fS_c12;
   delete fill9;
   delete fill10;
   delete fill11;
   DonCandles_fS_fS_fS_fS_b_b_i13_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i13;
   DonCandles_fS_fS_fS_fS_b_b_i14_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i14;
   DonCandles_fS_fS_fS_fS_b_b_i15_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i15;
   DonCandles_fS_fS_fS_fS_b_b_i16_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i16;
   pricewick_fS_fS17_param1.Release();
   pricewick_fS_fS17_param2.Release();
   delete pricewick_fS_fS17;
   pricewick_fS_fS18_param1.Release();
   pricewick_fS_fS18_param2.Release();
   delete pricewick_fS_fS18;
   pricewick_fS_fS19_param1.Release();
   pricewick_fS_fS19_param2.Release();
   delete pricewick_fS_fS19;
   pricewick_fS_fS20_param1.Release();
   pricewick_fS_fS20_param2.Release();
   delete pricewick_fS_fS20;
   delete plotcandle1;
   LabelsCollection::Clear(true);
   LinesCollection::Clear(true);
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
      LabelsCollection::Clear();
      LinesCollection::Clear();
      Up_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Up, Up_DEFAULT_VALUE);
      Dn_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Dn, Dn_DEFAULT_VALUE);
      iUp_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iUp, iUp_DEFAULT_VALUE);
      iDn_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iDn, iDn_DEFAULT_VALUE);
      highestpivot1Source.Init();
      lowestpivot1Source.Init();
      _pos_DEFAULT_VALUE = 0;
      ArrayInitialize(_pos, _pos_DEFAULT_VALUE);
      CreateLabel_iS_fS_s_c_b1_param1.Init();
      CreateLabel_iS_fS_s_c_b1_param2.Init();
      CreateLabel_iS_fS_s_c_b1.Clear();
      CreateLine_iS_fS_fS_c2_param1.Init();
      CreateLine_iS_fS_fS_c2_param2.Init();
      CreateLine_iS_fS_fS_c2_param3.Init();
      CreateLine_iS_fS_fS_c2.Clear();
      CreateLabel_iS_fS_s_c_b3_param1.Init();
      CreateLabel_iS_fS_s_c_b3_param2.Init();
      CreateLabel_iS_fS_s_c_b3.Clear();
      CreateLine_iS_fS_fS_c4_param1.Init();
      CreateLine_iS_fS_fS_c4_param2.Init();
      CreateLine_iS_fS_fS_c4_param3.Init();
      CreateLine_iS_fS_fS_c4.Clear();
      CreateLabel_iS_fS_s_c_b5_param1.Init();
      CreateLabel_iS_fS_s_c_b5_param2.Init();
      CreateLabel_iS_fS_s_c_b5.Clear();
      CreateLine_iS_fS_fS_c6_param1.Init();
      CreateLine_iS_fS_fS_c6_param2.Init();
      CreateLine_iS_fS_fS_c6_param3.Init();
      CreateLine_iS_fS_fS_c6.Clear();
      CreateLabel_iS_fS_s_c_b7_param1.Init();
      CreateLabel_iS_fS_s_c_b7_param2.Init();
      CreateLabel_iS_fS_s_c_b7.Clear();
      CreateLine_iS_fS_fS_c8_param1.Init();
      CreateLine_iS_fS_fS_c8_param2.Init();
      CreateLine_iS_fS_fS_c8_param3.Init();
      CreateLine_iS_fS_fS_c8.Clear();
      CreateLabel_iS_fS_s_c_b9_param1.Init();
      CreateLabel_iS_fS_s_c_b9_param2.Init();
      CreateLabel_iS_fS_s_c_b9.Clear();
      CreateLine_iS_fS_fS_c10_param1.Init();
      CreateLine_iS_fS_fS_c10_param2.Init();
      CreateLine_iS_fS_fS_c10_param3.Init();
      CreateLine_iS_fS_fS_c10.Clear();
      CreateLabel_iS_fS_s_c_b11_param1.Init();
      CreateLabel_iS_fS_s_c_b11_param2.Init();
      CreateLabel_iS_fS_s_c_b11.Clear();
      CreateLine_iS_fS_fS_c12_param1.Init();
      CreateLine_iS_fS_fS_c12_param2.Init();
      CreateLine_iS_fS_fS_c12_param3.Init();
      CreateLine_iS_fS_fS_c12.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      fill9.Init();
      fill10.Init();
      fill11.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i14_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i15_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i16_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16.Clear();
      pricewick_fS_fS17_param1.Init();
      pricewick_fS_fS17_param2.Init();
      pricewick_fS_fS17.Clear();
      pricewick_fS_fS18_param1.Init();
      pricewick_fS_fS18_param2.Init();
      pricewick_fS_fS18.Clear();
      pricewick_fS_fS19_param1.Init();
      pricewick_fS_fS19_param2.Init();
      pricewick_fS_fS19.Clear();
      pricewick_fS_fS20_param1.Init();
      pricewick_fS_fS20_param2.Init();
      pricewick_fS_fS20.Clear();
      plotcandle1.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      Up[pos] = pos > 0 ? Up[pos - 1] : (double)(NULL);
      Dn[pos] = pos > 0 ? Dn[pos - 1] : (double)(NULL);
      iUp[pos] = pos > 0 ? iUp[pos - 1] : (int)(NULL);
      iDn[pos] = pos > 0 ? iDn[pos - 1] : (int)(NULL);
      _pos[pos] = pos > 0 ? _pos[pos - 1] : 0;
      string t1 = "Set the pivot period";
      string t2 = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
      string t3 = "Enable the Donchian Channel.";
      string t4 = "A high value returns the long-term structure and a low value returns the short-term structure.";
      b = pos;
      if (pos - 1 < 0) { continue; }
      SetStream(Up, pos, SafeMathMax(Up[pos - 1], high[pos]), Up_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(Dn, pos, SafeMathMin(Dn[pos - 1], low[pos]), Dn_DEFAULT_VALUE);
      highestpivot1Source.SetValue(pos, high[pos]);
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, highestpivot1Source, prd, prd)) { highestpivot1Value[0] = EMPTY_VALUE; }
      double pvtHi = highestpivot1Value[0];
      lowestpivot1Source.SetValue(pos, low[pos]);
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, lowestpivot1Source, prd, prd)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      double pvtLo = lowestpivot1Value[0];
      if (NumberToBool(pvtHi))
      {
         SetStream(Up, pos, pvtHi, Up_DEFAULT_VALUE);
      }
      if (NumberToBool(pvtLo))
      {
         SetStream(Dn, pos, pvtLo, Dn_DEFAULT_VALUE);
      }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (SafeGreater(Up[pos], Up[pos - 1]))
      {
         SetStream(iUp, pos, b, iUp_DEFAULT_VALUE);
         if (pos - 1 < 0) { continue; }
         int centerBull = SafeMathRound(SafeDivide((SafePlus(iUp[pos - 1], b)), 2));
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - (s1 ? resp : prd) < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - (s1 ? resp : prd) < 0) { continue; }
         if ((_pos[pos] <= 0))
         {
            if (bull)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b1_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b1_param2.SetValue(pos, Up[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b1Value;
               if (!CreateLabel_iS_fS_s_c_b1.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b1Value)) { CreateLabel_iS_fS_s_c_b1Value = NULL; }
               CreateLabel_iS_fS_s_c_b1Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c2_param1.SetValue(pos, iUp[pos - 1]);
               CreateLine_iS_fS_fS_c2_param2.SetValue(pos, Up[pos - 1]);
               CreateLine_iS_fS_fS_c2_param3.SetValue(pos, Up[pos - 1]);
               Line* CreateLine_iS_fS_fS_c2Value;
               if (!CreateLine_iS_fS_fS_c2.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c2Value)) { CreateLine_iS_fS_fS_c2Value = NULL; }
               CreateLine_iS_fS_fS_c2Value;
            }
            SetStream(_pos, pos, 1, _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] == 1) && SafeGreater(Up[pos], Up[pos - 1]) && (Up[pos - 1] == Up[pos - ((s1 ? resp : prd))]))
         {
            if (bull)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b3_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b3_param2.SetValue(pos, Up[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b3Value;
               if (!CreateLabel_iS_fS_s_c_b3.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b3Value)) { CreateLabel_iS_fS_s_c_b3Value = NULL; }
               CreateLabel_iS_fS_s_c_b3Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c4_param1.SetValue(pos, iUp[pos - 1]);
               CreateLine_iS_fS_fS_c4_param2.SetValue(pos, Up[pos - 1]);
               CreateLine_iS_fS_fS_c4_param3.SetValue(pos, Up[pos - 1]);
               Line* CreateLine_iS_fS_fS_c4Value;
               if (!CreateLine_iS_fS_fS_c4.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c4Value)) { CreateLine_iS_fS_fS_c4Value = NULL; }
               CreateLine_iS_fS_fS_c4Value;
            }
            SetStream(_pos, pos, 2, _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] > 1) && SafeGreater(Up[pos], Up[pos - 1]) && (Up[pos - 1] == Up[pos - ((s1 ? resp : prd))]))
         {
            if (bull)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b5_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b5_param2.SetValue(pos, Up[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b5Value;
               if (!CreateLabel_iS_fS_s_c_b5.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b5Value)) { CreateLabel_iS_fS_s_c_b5Value = NULL; }
               CreateLabel_iS_fS_s_c_b5Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c6_param1.SetValue(pos, iUp[pos - 1]);
               CreateLine_iS_fS_fS_c6_param2.SetValue(pos, Up[pos - 1]);
               CreateLine_iS_fS_fS_c6_param3.SetValue(pos, Up[pos - 1]);
               Line* CreateLine_iS_fS_fS_c6Value;
               if (!CreateLine_iS_fS_fS_c6.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c6Value)) { CreateLine_iS_fS_fS_c6Value = NULL; }
               CreateLine_iS_fS_fS_c6Value;
            }
            SetStream(_pos, pos, _pos[pos] + 1, _pos_DEFAULT_VALUE);
         }
      }
      else if (SafeLess(Up[pos], Up[pos - 1]))
      {
         SetStream(iUp, pos, b - prd, iUp_DEFAULT_VALUE);
      }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (SafeLess(Dn[pos], Dn[pos - 1]))
      {
         SetStream(iDn, pos, b, iDn_DEFAULT_VALUE);
         if (pos - 1 < 0) { continue; }
         int centerBear = SafeMathRound(SafeDivide((SafePlus(iDn[pos - 1], b)), 2));
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - (s1 ? resp : prd) < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - (s1 ? resp : prd) < 0) { continue; }
         if ((_pos[pos] >= 0))
         {
            if (bear)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b7_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b7_param2.SetValue(pos, Dn[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b7Value;
               if (!CreateLabel_iS_fS_s_c_b7.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b7Value)) { CreateLabel_iS_fS_s_c_b7Value = NULL; }
               CreateLabel_iS_fS_s_c_b7Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c8_param1.SetValue(pos, iDn[pos - 1]);
               CreateLine_iS_fS_fS_c8_param2.SetValue(pos, Dn[pos - 1]);
               CreateLine_iS_fS_fS_c8_param3.SetValue(pos, Dn[pos - 1]);
               Line* CreateLine_iS_fS_fS_c8Value;
               if (!CreateLine_iS_fS_fS_c8.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c8Value)) { CreateLine_iS_fS_fS_c8Value = NULL; }
               CreateLine_iS_fS_fS_c8Value;
            }
            SetStream(_pos, pos, (-1), _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] == (-1)) && SafeLess(Dn[pos], Dn[pos - 1]) && (Dn[pos - 1] == Dn[pos - ((s1 ? resp : prd))]))
         {
            if (bear)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b9_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b9_param2.SetValue(pos, Dn[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b9Value;
               if (!CreateLabel_iS_fS_s_c_b9.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b9Value)) { CreateLabel_iS_fS_s_c_b9Value = NULL; }
               CreateLabel_iS_fS_s_c_b9Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c10_param1.SetValue(pos, iDn[pos - 1]);
               CreateLine_iS_fS_fS_c10_param2.SetValue(pos, Dn[pos - 1]);
               CreateLine_iS_fS_fS_c10_param3.SetValue(pos, Dn[pos - 1]);
               Line* CreateLine_iS_fS_fS_c10Value;
               if (!CreateLine_iS_fS_fS_c10.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c10Value)) { CreateLine_iS_fS_fS_c10Value = NULL; }
               CreateLine_iS_fS_fS_c10Value;
            }
            SetStream(_pos, pos, (-2), _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] < (-1)) && SafeLess(Dn[pos], Dn[pos - 1]) && (Dn[pos - 1] == Dn[pos - ((s1 ? resp : prd))]))
         {
            if (bear)
            {
               if (pos - 1 < 0) { continue; }
               CreateLabel_iS_fS_s_c_b11_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b11_param2.SetValue(pos, Dn[pos - 1]);
               Label* CreateLabel_iS_fS_s_c_b11Value;
               if (!CreateLabel_iS_fS_s_c_b11.GetValue(pos, oldPos, CreateLabel_iS_fS_s_c_b11Value)) { CreateLabel_iS_fS_s_c_b11Value = NULL; }
               CreateLabel_iS_fS_s_c_b11Value;
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               if (pos - 1 < 0) { continue; }
               CreateLine_iS_fS_fS_c12_param1.SetValue(pos, iDn[pos - 1]);
               CreateLine_iS_fS_fS_c12_param2.SetValue(pos, Dn[pos - 1]);
               CreateLine_iS_fS_fS_c12_param3.SetValue(pos, Dn[pos - 1]);
               Line* CreateLine_iS_fS_fS_c12Value;
               if (!CreateLine_iS_fS_fS_c12.GetValue(pos, oldPos, CreateLine_iS_fS_fS_c12Value)) { CreateLine_iS_fS_fS_c12Value = NULL; }
               CreateLine_iS_fS_fS_c12Value;
            }
            SetStream(_pos, pos, _pos[pos] - 1, _pos_DEFAULT_VALUE);
         }
      }
      else if (SafeGreater(Dn[pos], Dn[pos - 1]))
      {
         SetStream(iDn, pos, b - prd, iDn_DEFAULT_VALUE);
      }
      double PremiumTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double PremiumBot = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountTop = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double MidTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      double MidBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      uint plot1_color = bear2;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = (don ? Up[pos] : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      double r1 = plot1[pos];
      uint plot2_color = bull2;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = (don ? Dn[pos] : EMPTY_VALUE); }
      else { plot2[pos] = EMPTY_VALUE; }
      double r2 = plot2[pos];
      plot3[pos] = (showPD ? PremiumTop : EMPTY_VALUE);
      double p1 = plot3[pos];
      plot4[pos] = (showPD ? PremiumBot : EMPTY_VALUE);
      double p2 = plot4[pos];
      plot5[pos] = (showPD ? DiscountTop : EMPTY_VALUE);
      double d1 = plot5[pos];
      plot6[pos] = (showPD ? DiscountBot : EMPTY_VALUE);
      double d2 = plot6[pos];
      plot7[pos] = (showPD ? MidTop : EMPTY_VALUE);
      double m1 = plot7[pos];
      plot8[pos] = (showPD ? MidBot : EMPTY_VALUE);
      double m2 = plot8[pos];
      double fill9_val1 = p1;
      double fill9_val2 = p2;
      fill9.Set(pos, fill9_val1, fill9_val2, prem);
      double fill10_val1 = d1;
      double fill10_val2 = d2;
      fill10.Set(pos, fill10_val1, fill10_val2, disc);
      double fill11_val1 = m1;
      double fill11_val2 = m2;
      fill11.Set(pos, fill11_val1, fill11_val2, AddTransparency(Gray, 75));
      DonCandles_fS_fS_fS_fS_b_b_i13_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param4.SetValue(pos, open[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i13Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i13.GetValue(pos, oldPos, DonCandles_fS_fS_fS_fS_b_b_i13Value)) { DonCandles_fS_fS_fS_fS_b_b_i13Value = EMPTY_VALUE; }
      double O = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i13Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i14_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param4.SetValue(pos, high[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i14Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i14.GetValue(pos, oldPos, DonCandles_fS_fS_fS_fS_b_b_i14Value)) { DonCandles_fS_fS_fS_fS_b_b_i14Value = EMPTY_VALUE; }
      double H = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i14Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i15_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param4.SetValue(pos, low[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i15Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i15.GetValue(pos, oldPos, DonCandles_fS_fS_fS_fS_b_b_i15Value)) { DonCandles_fS_fS_fS_fS_b_b_i15Value = EMPTY_VALUE; }
      double L = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i15Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i16_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param4.SetValue(pos, close[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i16Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i16.GetValue(pos, oldPos, DonCandles_fS_fS_fS_fS_b_b_i16Value)) { DonCandles_fS_fS_fS_fS_b_b_i16Value = EMPTY_VALUE; }
      double C = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i16Value : EMPTY_VALUE);
      pricewick_fS_fS17_param1.SetValue(pos, H);
      pricewick_fS_fS17_param2.SetValue(pos, open[pos]);
      int pricewick_fS_fS17Value;
      if (!pricewick_fS_fS17.GetValue(pos, oldPos, pricewick_fS_fS17Value)) { pricewick_fS_fS17Value = (-1); }
      int cond_open = pricewick_fS_fS17Value;
      pricewick_fS_fS18_param1.SetValue(pos, H);
      pricewick_fS_fS18_param2.SetValue(pos, high[pos]);
      int pricewick_fS_fS18Value;
      if (!pricewick_fS_fS18.GetValue(pos, oldPos, pricewick_fS_fS18Value)) { pricewick_fS_fS18Value = (-1); }
      int cond_high = pricewick_fS_fS18Value;
      pricewick_fS_fS19_param1.SetValue(pos, H);
      pricewick_fS_fS19_param2.SetValue(pos, low[pos]);
      int pricewick_fS_fS19Value;
      if (!pricewick_fS_fS19.GetValue(pos, oldPos, pricewick_fS_fS19Value)) { pricewick_fS_fS19Value = (-1); }
      int cond_low = pricewick_fS_fS19Value;
      pricewick_fS_fS20_param1.SetValue(pos, H);
      pricewick_fS_fS20_param2.SetValue(pos, close[pos]);
      int pricewick_fS_fS20Value;
      if (!pricewick_fS_fS20.GetValue(pos, oldPos, pricewick_fS_fS20Value)) { pricewick_fS_fS20Value = (-1); }
      int cond_close = pricewick_fS_fS20Value;
      uint sign = (((((cond_open || cond_high) || cond_low) || cond_close)) ? Lime : Red);
      double plotcandle1_open = open[pos];
      double plotcandle1_close = close[pos];
      plotcandle1.Set(pos, plotcandle1_open, high[pos], low[pos], plotcandle1_close, (Candle ? sign : INT_MIN));
   }
   LabelsCollection::Redraw();
   LinesCollection::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160959#p160959
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