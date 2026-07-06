/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Buy_Sell_Signals_Only_v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161335#p161335
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
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property strict
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 2
#property indicator_label1 "Buy Signal"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Sell Signal"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
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
template <typename T>
interface TIStream
  {
public:

   virtual void AddRef() = 0;

   virtual void Release() = 0;

   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;

   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
  };
class AStreamBase : public TIStream<double>
  {
   int               _references;
public:

                     AStreamBase()
     {
      _references = 1;
     }

                    ~AStreamBase()
     {
     }

   void              AddRef()
     {
      ++_references;
     }

   void              Release()
     {
      --_references;
      if(_references == 0)
         delete &this;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AStream : public AStreamBase
  {
protected:
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   double            _shift;
public:

                     AStream(string symbol, ENUM_TIMEFRAMES timeframe)

      :              AStreamBase()
     {
      _symbol = symbol;
      _timeframe = timeframe;
     }

                    ~AStream()
     {
     }

   void              SetShift(const double shift)
     {
      _shift = shift;
     }

   virtual int       Size()
     {
      return iBars(_symbol, _timeframe);
     }

   virtual bool      GetValues(const int period, const int count, double &val[])
     {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
     }
  };
interface IBarStream : public TIStream<double>
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PriceStream : public AStreamBase
  {
   PriceType         _price;
   IBarStream*       _source;
public:

                     PriceStream(IBarStream* source, const PriceType __price)

      :              AStreamBase()
     {
      _source = source;
      _source.AddRef();
      _price = __price;
     }

                    ~PriceStream()
     {
      _source.Release();
     }

   int               Size()
     {
      return _source.Size();
     }

   virtual bool      GetSeriesValues(const int period, const int count, double &values[])
     {
      int pos = Size() - 1 - period;
      return GetValues(pos, count, values);
     }

   virtual bool      GetValues(const int period, const int count, double &values[])
     {
      for(int i = 0; i < count; ++i)
        {
         double val;
         switch(_price)
           {
            case PriceClose:
               if(!_source.GetClose(period - i, val))
                 {
                  return false;
                 }
               break;
            case PriceOpen:
               if(!_source.GetOpen(period - i, val))
                 {
                  return false;
                 }
               break;
            case PriceHigh:
               if(!_source.GetHigh(period - i, val))
                 {
                  return false;
                 }
               break;
            case PriceLow:
               if(!_source.GetLow(period - i, val))
                 {
                  return false;
                 }
               break;
            case PriceMedian:
              {
               double high, low;
               if(!_source.GetHighLow(period - i, high, low))
                 {
                  return false;
                 }
               val = (high + low) / 2.0;
              }
            break;
            case PriceTypical:
              {
               double open, high, low, close;
               if(!_source.GetValues(period - i, open, high, low, close))
                 {
                  return false;
                 }
               val = (high + low + close) / 3.0;
              }
            break;
            case PriceWeighted:
              {
               double open, high, low, close;
               if(!_source.GetValues(period - i, open, high, low, close))
                 {
                  return false;
                 }
               val = (high + low + close * 2) / 4.0;
              }
            break;
            case PriceMedianBody:
              {
               double open3, close3;
               if(!_source.GetOpenClose(period - i, open3, close3))
                 {
                  return false;
                 }
               val = (open3 + close3) / 2.0;
              }
            break;
            case PriceAverage:
              {
               double open4, high4, low4, close4;
               if(!_source.GetValues(period - i, open4, high4, low4, close4))
                 {
                  return false;
                 }
               val = (high4 + low4 + close4 + open4) / 4.0;
              }
            break;
            case PriceTrendBiased:
              {
               double open5, high5, low5, close5;
               if(!_source.GetValues(period - i, open5, high5, low5, close5))
                 {
                  return false;
                 }
               if(open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
              }
            break;
           }
         values[i] = val;
        }
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BarStream : public IBarStream
  {
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   int               _referenceCount;
public:

                     BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
     {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
     }

   virtual void      AddRef()
     {
      ++_referenceCount;
     }

   virtual void      Release()
     {
      --_referenceCount;
      if(_referenceCount == 0)
         delete &this;
     }

   virtual bool      FindDatePeriod(const datetime date, int& period)
     {
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
     }

   virtual bool      GetDate(const int period, datetime &dt)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetOpen(const int period, double &open)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetHigh(const int period, double &high)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetLow(const int period, double &low)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetClose(const int period, double &close)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetValues(const int period, double &open, double &high, double &low, double &close)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetHighLow(const int period, double &high, double &low)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual bool      GetOpenClose(const int period, double& open, double& close)
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos || oldPos < 0)
        {
         return false;
        }
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
     }

   virtual int       Size()
     {
      return iBars(_symbol, _timeframe);
     }

   virtual bool      GetValues(const int period, const int count, double &val[])
     {
      int size = Size();
      int oldPos = size - period - 1;
      if(size <= oldPos + count - 1 || oldPos < 0)
        {
         return false;
        }
      for(int i = 0; i < count; ++i)
        {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
        }
      return true;
     }

   virtual bool      GetSeriesValues(const int oldPos, const int count, double &val[])
     {
      int size = Size();
      if(size <= oldPos + count - 1 || oldPos < 0)
        {
         return false;
        }
      for(int i = 0; i < count; ++i)
        {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
        }
      return true;
     }

   virtual void      Refresh() { }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PriceStreamFactory
  {
public:
   static TIStream<double>* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
     {
      BarStream* source = new BarStream(symbol, timeframe);
      TIStream<double>* stream = new PriceStream(source, price);
      source.Release();
      return stream;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Nz(double val, double defaultValue = 0)
  {
   return val == EMPTY_VALUE ? defaultValue : val;
  }

bool ParameterDefined(double p) { return p != EMPTY_VALUE; }

bool ParameterDefined(int p) { return p != INT_MIN; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParameterDefined(string p) { return p != NULL; }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BothParametersDefined(T1 left, T2 right) { return ParameterDefined(left) && ParameterDefined(right); }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafePlus(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return EMPTY_VALUE;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafePlus(int left, int right)
  {
   if(!BothParametersDefined(left, right))
     {
      return INT_MIN;
     }
   return left + right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMinus(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return EMPTY_VALUE;
     }
   return left - right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMinus(int left, int right)
  {
   if(!BothParametersDefined(left, right))
     {
      return INT_MIN;
     }
   return left - right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeDivide(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right) || right == 0)
     {
      return EMPTY_VALUE;
     }
   return left / right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMultiply(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return EMPTY_VALUE;
     }
   return left * right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMultiply(int left, int right)
  {
   if(!BothParametersDefined(left, right))
     {
      return INT_MIN;
     }
   return left * right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeGreater(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return false;
     }
   return left > right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeGE(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return false;
     }
   return left >= right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeLess(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return false;
     }
   return left < right;
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeLE(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return false;
     }
   return left <= right;
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathExp(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathExp(value);
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMax(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return EMPTY_VALUE;
     }
   return MathMax(left, right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathMax(int left, int right)
  {
   if(!BothParametersDefined(left, right))
     {
      return INT_MIN;
     }
   return MathMax(left, right);
  }
template <typename T1, typename T2, typename T3>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMax(T1 param1, T2 param2, T3 param3)
  {
   if(!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
     {
      return EMPTY_VALUE;
     }
   return MathMax(MathMax(param1, param2), param3);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathMax(int param1, int param2, int param3)
  {
   if(!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
     {
      return INT_MIN;
     }
   return MathMax(MathMax(param1, param2), param3);
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMin(T1 left, T2 right)
  {
   if(!BothParametersDefined(left, right))
     {
      return EMPTY_VALUE;
     }
   return MathMin(left, right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathMin(int left, int right)
  {
   if(!BothParametersDefined(left, right))
     {
      return INT_MIN;
     }
   return MathMin(left, right);
  }
template <typename T1, typename T2, typename T3>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMin(T1 param1, T2 param2, T3 param3)
  {
   if(!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
     {
      return EMPTY_VALUE;
     }
   return MathMin(MathMin(param1, param2), param3);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathMin(int param1, int param2, int param3)
  {
   if(!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
     {
      return INT_MIN;
     }
   return MathMin(MathMin(param1, param2), param3);
  }
template <typename T1, typename T2>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathPow(T1 value, T2 power)
  {
   if(!BothParametersDefined(value, power))
     {
      return EMPTY_VALUE;
     }
   return MathPow(value, power);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathAbs(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathAbs(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathRound(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathRound(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathRound(T value, int precision)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return NormalizeDouble(value, precision);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathSqrt(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathSqrt(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeSign(T value)
  {
   if(!ParameterDefined(value))
     {
      return INT_MIN;
     }
   if(value == 0)
     {
      return 0;
     }
   return value > 0 ? 1 : -1;
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeLog(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathLog(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeLog10(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathLog10(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeCos(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathCos(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArccos(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathArccos(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeSin(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathSin(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArcsin(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathArcsin(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeTan(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathTan(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArctan(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathArctan(value);
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double InvertSign(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return -value;
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathCeil(T value)
  {
   if(!ParameterDefined(value))
     {
      return INT_MIN;
     }
   return (int)MathCeil(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMod(int val1, int val2)
  {
   if(val1 == INT_MIN || val2 == INT_MIN)
     {
      return EMPTY_VALUE;
     }
   return val1 % val2;
  }
template <typename T>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathFloor(T value)
  {
   if(!ParameterDefined(value))
     {
      return EMPTY_VALUE;
     }
   return MathFloor(value);
  }

#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))

#define ColorR(clr) ((clr & 0x00FF0000) >> 16)

#define ColorG(clr) ((clr & 0x0000FF00) >> 8)

#define ColorB(clr) (clr & 0x000000FF)

#define GetColorOnly(clr) (clr & 0xFFFFFF)

#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)

#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NumberToBool(double number)
  {
   return number != EMPTY_VALUE && number != 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FirstBarState
  {
   bool              _first;
public:

                     FirstBarState()
     {
      _first = true;
     }

   void              Clear()
     {
      _first = true;
     }

   bool              IsFirst()
     {
      bool first = _first;
      _first = false;
      return first;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
  {
   if(value == EMPTY_VALUE || topValue == EMPTY_VALUE)
     {
      return bottomColor;
     }
   if(bottomValue == EMPTY_VALUE)
     {
      return topColor;
     }
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if(rate > 1)
     {
      return bottomColor;
     }
   if(rate < 0)
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SetStream(double &stream[], int pos, double value, double defaultValue)
  {
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PineScriptTime
  {
public:
   static int        Day(datetime dt)
     {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day;
     }
   static int        Hour(datetime dt)
     {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.hour;
     }
   static int        Year(datetime dt)
     {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.year;
     }
   static int        DayOfWeek(datetime dt)
     {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day_of_week;
     }
   static int        Sunday()
     {
      return 0;
     }
   static int        Monday()
     {
      return 1;
     }
   static int        Tuesday()
     {
      return 2;
     }
   static int        Wednesday()
     {
      return 3;
     }
   static int        Thursday()
     {
      return 4;
     }
   static int        Friday()
     {
      return 5;
     }
   static int        Saturday()
     {
      return 6;
     }
  };
class AFloatStream : public TIStream<double>
  {
   int               _refs;
public:

                     AFloatStream()
     {
      _refs = 1;
     }

   void              AddRef()
     {
      _refs++;
     }

   void              Release()
     {
      if(--_refs == 0)
        {
         delete &this;
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FloatStream : public AFloatStream
  {
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   double            _stream[];
   double            _emptyValue;
public:

                     FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
     {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
     }

   void              Init()
     {
      ArrayInitialize(_stream, _emptyValue);
     }

   virtual int       Size()
     {
      return Bars(_symbol, _timeframe);
     }

   void              SetValue(const int period, double value)
     {
      int totalBars = Size();
      if(period < 0 || totalBars <= period)
        {
         return;
        }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
     }

   virtual bool      GetValues(const int period, const int count, double &val[])
     {
      int totalBars = Size();
      if(period - count + 1 < 0 || totalBars <= period)
        {
         return false;
        }
      EnsureStreamHasProperSize(totalBars);
      for(int i = 0; i < count; ++i)
        {
         val[i] = _stream[period - i];
         if(val[i] == _emptyValue)
           {
            return false;
           }
        }
      return true;
     }

   virtual bool      GetSeriesValues(const int period, const int count, double &val[])
     {
      return GetValues(Size() - period - 1, count, val);
     }
private:

   void              EnsureStreamHasProperSize(int size)
     {
      int currentSize = ArrayRange(_stream, 0);
      if(currentSize != size)
        {
         ArrayResize(_stream, size);
         for(int i = currentSize; i < size; ++i)
           {
            _stream[i] = _emptyValue;
           }
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AOnStream : public AStreamBase
  {
protected:
   TIStream<double>  *_source;
public:

                     AOnStream(TIStream<double> *source)

      :              AStreamBase()
     {
      _source = source;
      _source.AddRef();
     }

                    ~AOnStream()
     {
      _source.Release();
     }

   virtual bool      GetSeriesValue(const int period, double &val) = 0;

   virtual bool      GetSeriesValues(const int period, const int count, double &val[])
     {
      for(int i = 0; i < count; ++i)
        {
         double v;
         if(!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
        }
      return true;
     }

   bool              GetValues(const int period, const int count, double &val[])
     {
      int size = Size();
      for(int i = 0; i < count; ++i)
        {
         double v;
         if(!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
        }
      return true;
     }

   virtual int       Size()
     {
      return _source.Size();
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SmaOnStream : public AOnStream
  {
   double            _length;
public:

                     SmaOnStream(TIStream<double> *source, const int length)

      :              AOnStream(source)
     {
      _length = length;
     }

   bool              GetSeriesValue(const int period, double &val)
     {
      double summ = 0;
      for(int i = 0; i < _length; ++i)
        {
         double price[1];
         if(!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
        }
      val = summ / _length;
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TrueRangeStream : public AStream
  {
   bool              _handleNa;
public:

                     TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)

      :              AStream(symbol, timeframe)
     {
      _handleNa = handleNa;
     }

   virtual bool      GetSeriesValues(const int period, const int count, double &val[])
     {
      int size = Size();
      if((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
        {
         return false;
        }
      for(int i = 0; i < count; ++i)
        {
         if((period + i + 1 == size) && _handleNa)
           {
            double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
            double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
           }
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         val[i] = MathMax(lc, MathMax(hl, hc));
        }
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATRStream : public AStream
  {
   TIStream<double>* _avg;
public:

                     ATRStream(int length)

      :              AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
     {
      TIStream<double>* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
     }

                     ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)

      :              AStream(symbol, timeframe)
     {
      TIStream<double>* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
     }

                    ~ATRStream()
     {
      _avg.Release();
     }

   bool              GetValues(const int period, const int count, double &val[])
     {
      return _avg.GetValues(period, count, val);
     }

   bool              GetSeriesValues(const int period, const int count, double &val[])
     {
      int oldPos = Size() - period - 1;
      return GetValues(oldPos, count, val);
     }
  };
interface ICondition
  {
public:

   virtual void AddRef() = 0;

   virtual void Release() = 0;

   virtual bool IsPass(const int period, const datetime date) = 0;

   virtual string GetLogMessage(const int period, const datetime date) = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ValueWhenSimpleStream : public AStream
  {
   datetime          _periods[];
   double            _values[];
   int               _shift;
public:
   double            _stream[];

                     ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)

      :              AStream(symbol, timeframe)
     {
      _shift = shift;
     }

   int               RegisterInternalStream(int id)
     {
      SetIndexBuffer(id, _stream, INDICATOR_CALCULATIONS);
      return id + 1;
     }

   double            Update(const int period, datetime date, bool condition, double val)
     {
      if(condition)
        {
         int size = ArraySize(_periods);
         if(size == 0 || _periods[size - 1] != date)
           {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
           }
         else
           {
            _values[size - 1] = val;
           }
         if(size - 1 - _shift >= 0)
           {
            _stream[period] = _values[size - 1 - _shift];
           }
         else
           {
            _stream[period] = EMPTY_VALUE;
           }
        }
      else
         if(period > 0)
           {
            _stream[period] = _stream[period - 1];
           }
      return _stream[period];
     }

   virtual bool      GetSeriesValues(const int period, const int count, double &val[])
     {
      return GetValues(Size() - period - 1, count, val);
     }

   virtual bool      GetValues(const int period, const int count, double &val[])
     {
      for(int i = 0; i < count; i++)
        {
         if(_stream[period - i] == EMPTY_VALUE)
           {
            return false;
           }
         val[i] = _stream[period - i];
        }
      return true;
     }
  };
enum SignalerFrequency
  {
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Signaler
  {
   string            _prefix;
   SignalerFrequency _frequency;
   datetime          _lastSignal;
   bool              startProgram;
   string            startProgramPath;
   bool              popup_alert;
   bool              email_alert;
   bool              play_sound;
   string            sound_file;
   bool              notification_alert;
   bool              advanced_alert;
   string            advanced_key;
   string            advanced_server;
public:

                     Signaler(string frequency)
     {
      startProgram = false;
      popup_alert = true;
      email_alert = false;
      if(frequency == "all")
        {
         _frequency = SignalsAll;
        }
      else
         if(frequency == "once_per_bar_close")
           {
            _frequency = SignalsOncePerBarClose;
           }
         else
            if(frequency == "once_per_bar")
              {
               _frequency = SignalsOncePerBar;
              }
      _lastSignal = 0;
     }

                     Signaler()
     {
      _lastSignal = 0;
     }

   void              EnablePopupAlert(bool enable)
     {
      popup_alert = enable;
     }

   void              EnableEmailAlert(bool enable)
     {
      email_alert = enable;
     }

   void              SetStartProgram(bool start, string path)
     {
      startProgram = start;
      startProgramPath = path;
     }

   void              EnableSound(bool enabled, string soundFile)
     {
      play_sound = enabled;
      sound_file = soundFile;
     }

   void              EnableNotificationAlert(bool enabled)
     {
      notification_alert = enabled;
     }

   void              EnableAdvanced(bool enabled, string key, string server)
     {
      advanced_alert = enabled;
      advanced_key = key;
      advanced_server = server;
     }

   void              SetMessagePrefix(string prefix)
     {
      _prefix = prefix;
     }

   void              ShowAlert(string message, int position, datetime time)
     {
      if(position != 0)
        {
         return;
        }
      if(_frequency != SignalsAll)
        {
         if(_lastSignal == time)
           {
            return;
           }
        }
      _lastSignal = time;
      SendNotifications("", message);
     }

   void              SendNotifications(const string subject, string message = NULL)
     {
      if(message == NULL)
         message = subject;
      if(_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if(popup_alert)
         Alert(message);
      if(email_alert)
         SendMail(subject, message);
      if(play_sound)
         PlaySound(sound_file);
      if(notification_alert)
         SendNotification(message);
     }
  };
input PriceType param1 = PriceClose; // Source
input int param2 = 10; // ATR Period
input double param3 = 1.5; // ATR Multiplier
input double param4 = 1; // Sensitivity
input bool param5 = true; // Change ATR Calculation Method yes/no
input int bars_limit = 1000; // Bars limit
enum alert_mode
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert_mode notificationsOn = 1; // Notifications
input bool desktop_notifications = true; // Desktop MT5 notifications
input bool email_notifications = false; // Email notifications
input bool push_notifications = false; // Push mobile notifications
input bool sound_notifications = false; // Sound notifications
input string sound_file = "alert.wav"; // Choose a sound file for notifications
TIStream<double>* param1Stream;
TIStream<double>* source;
int Periods;
double Multiplier;
double Sensitivity;
int changeATR;
double haOpen[];
double haOpen_DEFAULT_VALUE;
double haClose[];
double haClose_DEFAULT_VALUE;
FloatStream* sma1Source;
SmaOnStream* sma1;
TIStream<double>* tr1;
ATRStream* atr1;
double up[];
double up_DEFAULT_VALUE;
ValueWhenSimpleStream* valuewhen1;
double dn[];
double dn_DEFAULT_VALUE;
ValueWhenSimpleStream* valuewhen2;
double trend[];
double trend_DEFAULT_VALUE;
double plot1[];
double plot2[];
Signaler* _signaler;
string IndicatorObjPrefix;
bool alerted;
datetime lastBarTime;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(0); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(string target)
  {
   if(StringLen(target) > 20)
     {
      target = StringSubstr(target, 0, 20);
     }
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   param1Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param1);
   source = param1Stream;
   Periods = param2;
   Multiplier = param3;
   Sensitivity = param4;
   changeATR = param5;
   int id = 0;
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, Periods);
   atr1 = new ATRStream(Periods);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_SHIFT, (-1));
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, AddTransparency(Lime, 0));
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_SHIFT, (-1));
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, AddTransparency(0x1a1ae0, 0));
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 5);
   ++id;
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "Buy/Sell Signals Only");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, haOpen, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, haClose, INDICATOR_CALCULATIONS);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id++, up, INDICATOR_CALCULATIONS);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, dn, INDICATOR_CALCULATIONS);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen2.RegisterInternalStream(id);
   SetIndexBuffer(id++, trend, INDICATOR_CALCULATIONS);
   _signaler = new Signaler();
   alerted = false;
   lastBarTime = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   param1Stream.Release();
   sma1Source.Release();
   sma1.Release();
   tr1.Release();
   atr1.Release();
   valuewhen1.Release();
   valuewhen2.Release();
   delete _signaler;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(prev_calculated <= 0 || prev_calculated > rates_total)
     {
      haOpen_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(haOpen, haOpen_DEFAULT_VALUE);
      haClose_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(haClose, haClose_DEFAULT_VALUE);
      sma1Source.Init();
      up_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(up, up_DEFAULT_VALUE);
      dn_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(dn, dn_DEFAULT_VALUE);
      trend_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(trend, trend_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
     }
   int first = 0;
   for(int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
     {
      int oldPos = rates_total - pos - 1;
      haOpen[pos] = pos > 0 ? haOpen[pos - 1] : EMPTY_VALUE;
      trend[pos] = pos > 0 ? trend[pos - 1] : INT_MIN;
      double sourceValue[1];
      if(!source.GetValues(pos, 1, sourceValue))
        {
         sourceValue[0] = EMPTY_VALUE;
        }
      SetStream(haClose, pos, SafeDivide((open[pos] + high[pos] + low[pos] + sourceValue[0]), 4), haClose_DEFAULT_VALUE);
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      SetStream(haOpen, pos, (((haOpen[pos - 1]) == EMPTY_VALUE) ? SafeDivide((open[pos] + sourceValue[0]), 2) : SafeDivide((SafePlus(haOpen[pos - 1], haClose[pos - 1])), 2)), haOpen_DEFAULT_VALUE);
      double haHigh = SafeMathMax(high[pos], SafeMathMax(haClose[pos], haOpen[pos]));
      double haLow = SafeMathMin(low[pos], SafeMathMin(haClose[pos], haOpen[pos]));
      double tr1Value[1];
      if(!tr1.GetValues(pos, 1, tr1Value))
        {
         tr1Value[0] = EMPTY_VALUE;
        }
      sma1Source.SetValue(pos, tr1Value[0]);
      double sma1Value[1];
      if(!sma1.GetValues(pos, 1, sma1Value))
        {
         sma1Value[0] = EMPTY_VALUE;
        }
      double atr2 = sma1Value[0];
      double atr1Value[1];
      if(!atr1.GetValues(pos, 1, atr1Value))
        {
         atr1Value[0] = EMPTY_VALUE;
        }
      double atr = (changeATR ? atr1Value[0] : atr2);
      double adjustedMultiplier = Multiplier * Sensitivity;
      SetStream(up, pos, SafeMinus(haClose[pos], (SafeMultiply(adjustedMultiplier, atr))), up_DEFAULT_VALUE);
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      double up1 = valuewhen1.Update(pos, time[pos], SafeGreater(haClose[pos - 1], up[pos - 1]), up[pos - 1]);
      if(pos - 1 < 0)
        {
         continue;
        }
      SetStream(up, pos, (SafeGreater(haClose[pos - 1], up1) ? SafeMathMax(up[pos], up1) : up[pos]), up_DEFAULT_VALUE);
      SetStream(dn, pos, SafePlus(haClose[pos], (SafeMultiply(adjustedMultiplier, atr))), dn_DEFAULT_VALUE);
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      if(pos - 1 < 0)
        {
         continue;
        }
      double dn1 = valuewhen2.Update(pos, time[pos], SafeLess(haClose[pos - 1], dn[pos - 1]), dn[pos - 1]);
      if(pos - 1 < 0)
        {
         continue;
        }
      SetStream(dn, pos, (SafeLess(haClose[pos - 1], dn1) ? SafeMathMin(dn[pos], dn1) : dn[pos]), dn_DEFAULT_VALUE);
      if(pos - 1 < 0)
        {
         continue;
        }
      SetStream(trend, pos, (((trend[pos - 1]) == INT_MIN) ? 1 : trend[pos]), trend_DEFAULT_VALUE);
      SetStream(trend, pos, ((trend[pos] == (-1)) && SafeGreater(haClose[pos], dn1) ? 1 : ((trend[pos] == 1) && SafeLess(haClose[pos], up1) ? (-1) : trend[pos])), trend_DEFAULT_VALUE);
      if(pos - 1 < 0)
        {
         continue;
        }
      int buySignal = (trend[pos] == 1) && (trend[pos - 1] == (-1));
      if(pos - 1 < 0)
        {
         continue;
        }
      int sellSignal = (trend[pos] == (-1)) && (trend[pos - 1] == 1);
      string plot1_location = "belowbar";
      if(plot1_location == "absolute")
         plot1[pos] = (buySignal ? up[pos] : EMPTY_VALUE);
      else
         if(plot1_location == "abovebar" || plot1_location == "top")
           {
            int plotshape1_condition = NumberToBool((buySignal ? up[pos] : EMPTY_VALUE));
            if(plotshape1_condition == true)
              {
               if(pos - 1 >= 0)
                  plot1[pos] = high[pos - 1];
              }
           }
         else
            if(plot1_location == "belowbar" || plot1_location == "bottom")
              {
               int plotshape1_condition = NumberToBool((buySignal ? up[pos] : EMPTY_VALUE));
               if(plotshape1_condition == true)
                 {
                  if(pos - 1 >= 0)
                     plot1[pos] = low[pos - 1];
                 }
              }
      string plot2_location = "abovebar";
      if(plot2_location == "absolute")
         plot2[pos] = (sellSignal ? dn[pos] : EMPTY_VALUE);
      else
         if(plot2_location == "abovebar" || plot2_location == "top")
           {
            int plotshape2_condition = NumberToBool((sellSignal ? dn[pos] : EMPTY_VALUE));
            if(plotshape2_condition == true)
              {
               if(pos - 1 >= 0)
                  plot2[pos] = high[pos - 1];
              }
           }
         else
            if(plot2_location == "belowbar" || plot2_location == "bottom")
              {
               int plotshape2_condition = NumberToBool((sellSignal ? dn[pos] : EMPTY_VALUE));
               if(plotshape2_condition == true)
                 {
                  if(pos - 1 >= 0)
                     plot2[pos] = low[pos - 1];
                 }
              }
      if(buySignal)
        {
         _signaler.SendNotifications("Buy", "{{ticker}} - BUY Signal on {{interval}}");
        }
      if(sellSignal)
        {
         _signaler.SendNotifications("Sell", "{{ticker}} - SELL Signal on {{interval}}");
        }
     }
   if(notificationsOn > 0)
     {
      CheckAlert(rates_total);
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime curbar = iTime(_Symbol, _Period, 0);
   if(lastBarTime != curbar)
     {
      lastBarTime = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAlert(int rates_total)
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(plot1[rates_total - 1] != EMPTY_VALUE)
        {
         NotifyAlert("BUY");
         alerted = true;
        }
      if(plot2[rates_total - 1] != EMPTY_VALUE)
        {
         NotifyAlert("SELL");
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(plot1[rates_total - 2] != EMPTY_VALUE)
        {
         NotifyAlert("BUY");
        }
      if(plot2[rates_total - 2] != EMPTY_VALUE)
        {
         NotifyAlert("SELL");
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NotifyAlert(string signal)
  {
   string text = "Buy/Sell Signals: ";
   text += signal + " Signal - " + _Symbol + " " + GetTimeFrame(_Period);
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
     }
   return IntegerToString(period);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Buy_Sell_Signals_Only_v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161335#p161335
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
