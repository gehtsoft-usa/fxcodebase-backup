//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76389s
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
#property indicator_separate_window
#property indicator_buffers 25
#property indicator_label1 "OB Extreme"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "OB"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Median"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Orange
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label4 "OS"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "OS Extreme"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "RSI Histogram"
#property indicator_type6 DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "RSI Histogram"
#property indicator_type7 DRAW_HISTOGRAM
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label16 "RSI Shadow"
#property indicator_type16 DRAW_LINE
#property indicator_style16 STYLE_SOLID
#property indicator_width16 3
#property indicator_label17 "RSI Overlay"
#property indicator_type17 DRAW_LINE
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1

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
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v2.0

// Stream base v2.0

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

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public TIStream<double>
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
// IBarStream v3.0



#ifndef IBarStream_IMP
#define IBarStream_IMP

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
   static TIStream<double>* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      TIStream<double>* stream = new PriceStream(source, price);
      source.Release();
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
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}
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
// Change stream v2.1

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

// v2.0
// Wraps TIStream<int> and provides TIStream<double>

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


// RSI stream v2.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSISimpleStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSISimpleStream(TIStream<double>* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff;
      if (period == totalBars - 1 || _pos[period + 1])
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValue(period + i, diff))
            {
               return false;
            }
            if (diff >= 0)
            {
               sump = sump + diff;
            }
            else
            {
               sumn = sumn - diff;
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValue(period, diff))
         {
            return false;
         }
         if (diff > 0)
         {
            sump = diff;
         }
         else
         {
            sumn = -diff;
         }
         positive = (_pos[period + 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period + 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};

class PineScriptRSIUpDownStream : public AStreamBase
{
   TIStream<double>* _up;
   TIStream<double>* _down;
public:
   PineScriptRSIUpDownStream(TIStream<double>* up, TIStream<double>* down)
   {
      _up = up;
      _up.AddRef();
      _down = down;
      _down.AddRef();
   }
   ~PineScriptRSIUpDownStream()
   {
      _up.Release();
      _down.Release();
   }
   
   virtual int Size()
   {
      return _up.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      double up;
      double down;
      if (!_up.GetValue(period, up) || !_down.GetValue(period, down))
      {
         return false;
      }
      if (down == 0)
      {
         val = 0;
         return true;
      }
      double rs = up / down;
      val = 100 - 100.0 / (1.0 + rs);
      return true;
   }
};

class RSIStream : public AStreamBase
{
   TIStream<double>* _impl;
public:
   RSIStream(TIStream<double>* stream, int period)
   {
      _impl = new RSISimpleStream(stream, period);
   }

   RSIStream(TIStream<double>* up, TIStream<double>* down)
   {
      _impl = new PineScriptRSIUpDownStream(up, down);
   }

   ~RSIStream()
   {
      _impl.Release();
   }
   
   virtual int Size()
   {
      return _impl.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _impl.GetValue(period, val);
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


// Simple price stream v1.2



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

// Stochastics on stream v2.0

class StochOnStream : public AStreamBase
{
   TIStream<double>* _closeStream;
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
   int _period;
public:
   StochOnStream(TIStream<double>* closeStream, TIStream<double>* highStream, TIStream<double>* lowStream, int period)
      :AStreamBase()
   {
      _period = period;
      _closeStream = closeStream;
      _closeStream.AddRef();
      _highest = new HighestHighStream(highStream, period);
      _lowest = new LowestLowStream(lowStream, period);
   }

   ~StochOnStream()
   {
      _closeStream.Release();
      _highest.Release();
      _lowest.Release();
   }
   
   virtual int Size()
   {
      return _closeStream.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double close;
      if (!_closeStream.GetValue(period, close))
      {
         return false;
      }
      double lowest;
      if (!_lowest.GetValue(period, lowest))
      {
         return false;
      }
      double highest;
      if (!_highest.GetValue(period, highest))
      {
         return false;
      }
      double diff = (highest - lowest);
      val = diff == 0 ? 0 : 100 * (close - lowest) / diff;
      return true;
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
// Candles stream v.1.5
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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



// Colored stream v4.1

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

class InternalStream
{
public:
   double _stream[];
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
   InternalStream* _internalStream;
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width, InternalStream* internalStream)
   {
      _internalStream = internalStream;
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
      if (value == EMPTY_VALUE)
      {
         _stream[period] = EMPTY_VALUE;
         return;
      }
      int size = iBars(_symbol, _timeframe);
      int nextNonEmpty = FindNextNonempty(period, size);
      int count = nextNonEmpty - period + 1;
      double startPoint = _internalStream._stream[nextNonEmpty];
      double diff = startPoint - value;
      for (int i = nextNonEmpty; i >= period; --i)
      {
         _stream[i] = value - double(period - i) / count * diff;
      }
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
private:
   int FindNextNonempty(int period, int size)
   {
      for (int i = period + 1; i < size; ++i)
      {
         if (_internalStream._stream[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return period;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width, InternalStream* internalStream)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
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
   InternalStream* _internal;
public:
   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _internal = new InternalStream();
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      delete _internal;
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_internal._stream, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _internal._stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }
   
   int RegisterArrowStream(int id, uint clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, GetColorOnly(clr));
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, uint clr, int transparency)
   {
      return RegisterStream(id, GetColorOnly(clr), "", transparency == 100 ? DRAW_NONE : DRAW_LINE, STYLE_SOLID, 1);
   }
   int RegisterStream(int id, uint clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, lineType, lineStyle, width, _internal);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, uint clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, width, _internal);
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
   
   double SetByColor(double value, int period, uint clr)
   {
      clr = GetColorOnly(clr);
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetColor() == clr)
         {
            Set(value, period, i);
            return value;
         }
      }
      _internal._stream[period] = value;
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _internal._stream[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _internal._stream[period + 1];
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
      val = _internal._stream[period];
      return _internal._stream[period] != EMPTY_VALUE;
   }
};

#endif
input int param1 = 14; // Length
input int param2 = 1; // Open Smoothing
input color param3 = Teal; // Colour Pallette??
input color param4 = Red; //  
input color param5 = Gray; //  
input PriceType param6 = PriceAverage; // Source
input int param7 = 7; // Length
input bool param8 = true; // Smoothed Mode RSI?
input bool param9 = true; // Show RSI Plot?
input bool param10 = true; // Show RSI Histogram?
input bool param11 = false; // Show Stochastic??
input bool param12 = true; // Ribbon?
input int param13 = 3; // Smoothing K
input int param14 = 3; // Smoothing D
input int param15 = 14; // Stochastic Length
input int param16 = 80; // Stoch Scaling %
input int param17 = 20; // OB
input int param18 = 30; // OB Extreme
input int param19 = (-20); // OS
input int param20 = (-30); // OS Extreme
input int bars_limit = 100000; // Bars limit
int i_lenHARSI;
int i_smoothing;
uint i_colUp;
uint i_colDown;
uint i_colWick;
TIStream<double>* param6Stream;
TIStream<double>* i_source;
int i_lenRSI;
int i_mode;
int i_showPlot;
int i_showHist;
int i_showStoch;
int i_ribbon;
int i_smoothK;
int i_smoothD;
int i_stochLen;
int i_stochFit;
int i_upper;
int i_upperx;
int i_lower;
int i_lowerx;
class f_zrsi_1Stream
{
   int _length;
   FloatStream* rsi1X;
   RSIStream* rsi1;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_zrsi_1Stream(int _length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rsi1 = new RSIStream(rsi1X, _length);
   }
   ~f_zrsi_1Stream()
   {
      rsi1X.Release();
      rsi1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double ___source, double &__out1)
   {
      if (!_initialized)
      {
         rsi1X.Init();
         _initialized = true;
      }
      double _source = ___source;
      rsi1X.SetValue(pos, _source);
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value)) { rsi1Value = EMPTY_VALUE; }
      __out1 = SafeMinus(rsi1Value, 50);
      return true;
   }
};
class f_rsi_1Stream
{
   int _length;
   int _mode;
   f_zrsi_1Stream* f_zrsi_11;
   double _smoothed[];
   double _smoothed_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_rsi_1Stream(int _length, int _mode, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      this._mode = _mode;
   }
   ~f_rsi_1Stream()
   {
      delete f_zrsi_11;
   }
   int Init(int id)
   {
      f_zrsi_11 = new f_zrsi_1Stream(_length, IndicatorObjPrefix + "_1");
      id = f_zrsi_11.Init(id);
      SetIndexBuffer(id++, _smoothed);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double ___source, double &__out1)
   {
      if (!_initialized)
      {
         f_zrsi_11.Clear();
         _smoothed_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(_smoothed, _smoothed_DEFAULT_VALUE);
         _initialized = true;
      }
      _smoothed[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? _smoothed[pos + 1] : EMPTY_VALUE;
      double _source = ___source;
      double f_zrsi_11Value;
      if (!f_zrsi_11.GetValue(pos, _source, f_zrsi_11Value)) { f_zrsi_11Value = EMPTY_VALUE; }
      double _zrsi = f_zrsi_11Value;
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(_smoothed, pos, (((_smoothed[pos + 1]) == EMPTY_VALUE) ? _zrsi : SafeDivide((SafePlus(_smoothed[pos + 1], _zrsi)), 2)), _smoothed_DEFAULT_VALUE);
      __out1 = (_mode ? _smoothed[pos] : _zrsi);
      return true;
   }
};
f_rsi_1Stream* f_rsi_12;
class f_zstoch_1Stream
{
   int _length;
   int _smooth;
   int _scale;
   FloatStream* stoch1Source;
   FloatStream* stoch1High;
   FloatStream* stoch1Low;
   StochOnStream* stoch1;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_zstoch_1Stream(int _length, int _smooth, int _scale, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      this._smooth = _smooth;
      this._scale = _scale;
      stoch1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1High = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1Low = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1 = new StochOnStream(stoch1Source, stoch1High, stoch1Low, _length);
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, _smooth);
   }
   ~f_zstoch_1Stream()
   {
      stoch1Source.Release();
      stoch1High.Release();
      stoch1Low.Release();
      stoch1.Release();
      sma1Source.Release();
      sma1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double ___source, double &__out1)
   {
      if (!_initialized)
      {
         stoch1Source.Init();
         stoch1High.Init();
         stoch1Low.Init();
         sma1Source.Init();
         _initialized = true;
      }
      double _source = ___source;
      stoch1Source.SetValue(pos, _source);
      stoch1High.SetValue(pos, _source);
      stoch1Low.SetValue(pos, _source);
      double stoch1Value;
      if (!stoch1.GetValue(pos, stoch1Value)) { stoch1Value = EMPTY_VALUE; }
      double _zstoch = SafeMinus(stoch1Value, 50);
      sma1Source.SetValue(pos, _zstoch);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double _smoothed = sma1Value;
      double _scaled = SafeMultiply((SafeDivide(_smoothed, 100)), _scale);
      __out1 = _scaled;
      return true;
   }
};
f_zstoch_1Stream* f_zstoch_13;
FloatStream* sma2Source;
SmaOnStream* sma2;
class f_rsiHeikinAshi_1Stream
{
   int _length;
   f_zrsi_1Stream* f_zrsi_14;
   double _closeRSI[];
   double _closeRSI_DEFAULT_VALUE;
   f_zrsi_1Stream* f_zrsi_15;
   f_zrsi_1Stream* f_zrsi_16;
   double _open[];
   double _open_DEFAULT_VALUE;
   double _close[];
   double _close_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_rsiHeikinAshi_1Stream(int _length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
   }
   ~f_rsiHeikinAshi_1Stream()
   {
      delete f_zrsi_14;
      delete f_zrsi_15;
      delete f_zrsi_16;
   }
   int Init(int id)
   {
      f_zrsi_14 = new f_zrsi_1Stream(_length, IndicatorObjPrefix + "_4");
      id = f_zrsi_14.Init(id);
      SetIndexBuffer(id++, _closeRSI);
      f_zrsi_15 = new f_zrsi_1Stream(_length, IndicatorObjPrefix + "_5");
      id = f_zrsi_15.Init(id);
      f_zrsi_16 = new f_zrsi_1Stream(_length, IndicatorObjPrefix + "_6");
      id = f_zrsi_16.Init(id);
      SetIndexBuffer(id++, _open);
      SetIndexBuffer(id++, _close);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2, double &__out3, double &__out4)
   {
      if (!_initialized)
      {
         f_zrsi_14.Clear();
         _closeRSI_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(_closeRSI, _closeRSI_DEFAULT_VALUE);
         f_zrsi_15.Clear();
         f_zrsi_16.Clear();
         _open_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(_open, _open_DEFAULT_VALUE);
         _close_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(_close, _close_DEFAULT_VALUE);
         _initialized = true;
      }
      _open[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? _open[pos + 1] : EMPTY_VALUE;
      double f_zrsi_14Value;
      if (!f_zrsi_14.GetValue(pos, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), f_zrsi_14Value)) { f_zrsi_14Value = EMPTY_VALUE; }
      SetStream(_closeRSI, pos, f_zrsi_14Value, _closeRSI_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double _openRSI = Nz(_closeRSI[pos + 1], _closeRSI[pos]);
      double f_zrsi_15Value;
      if (!f_zrsi_15.GetValue(pos, iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), f_zrsi_15Value)) { f_zrsi_15Value = EMPTY_VALUE; }
      double _highRSI_raw = f_zrsi_15Value;
      double f_zrsi_16Value;
      if (!f_zrsi_16.GetValue(pos, iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), f_zrsi_16Value)) { f_zrsi_16Value = EMPTY_VALUE; }
      double _lowRSI_raw = f_zrsi_16Value;
      double _highRSI = SafeMathMax(_highRSI_raw, _lowRSI_raw);
      double _lowRSI = SafeMathMin(_highRSI_raw, _lowRSI_raw);
      SetStream(_close, pos, SafeDivide((SafePlus(SafePlus(SafePlus(_openRSI, _highRSI), _lowRSI), _closeRSI[pos])), 4), _close_DEFAULT_VALUE);
      if (pos + i_smoothing > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(_open, pos, (((_open[pos + i_smoothing]) == EMPTY_VALUE) ? SafeDivide((SafePlus(_openRSI, _closeRSI[pos])), 2) : SafeDivide((SafePlus((SafeMultiply(_open[pos + 1], i_smoothing)), _close[pos + 1])), (i_smoothing + 1))), _open_DEFAULT_VALUE);
      double _high = SafeMathMax(_highRSI, SafeMathMax(_open[pos], _close[pos]));
      double _low = SafeMathMin(_lowRSI, SafeMathMin(_open[pos], _close[pos]));
      __out1 = _open[pos];
      __out2 = _high;
      __out3 = _low;
      __out4 = _close[pos];
      return true;
   }
};
f_rsiHeikinAshi_1Stream* f_rsiHeikinAshi_17;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot6_dn[];
CandleStreams* plotcandle1;
double plot16[];
double plot17[];
ColoredStream* plot18;
ColoredStream* plot20;
ColoredStream* plot22;
ColoredStream* plot24;

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
   IndicatorBuffers(33);
   i_lenHARSI = param1;
   i_smoothing = param2;
   i_colUp = param3;
   i_colDown = param4;
   i_colWick = param5;
   param6Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param6);
   i_source = param6Stream;
   i_lenRSI = param7;
   i_mode = param8;
   i_showPlot = param9;
   i_showHist = param10;
   i_showStoch = param11;
   i_ribbon = param12;
   i_smoothK = param13;
   i_smoothD = param14;
   i_stochLen = param15;
   i_stochFit = param16;
   i_upper = param17;
   i_upperx = param18;
   i_lower = param19;
   i_lowerx = param20;
   int id = 0;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, i_smoothD);
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 60)));
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 80)));
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id, plot4);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 80)));
   SetIndexBuffer(id, plot5);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 60)));
   SetIndexBuffer(id, plot6);
   SetIndexStyle(id++, DRAW_HISTOGRAM, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 80)));
   SetIndexBuffer(id, plot6_dn);
   SetIndexStyle(id++, DRAW_HISTOGRAM, STYLE_SOLID, 1, GetColorOnly(AddTransparency(Silver, 80)));
   plotcandle1 = new CandleStreams();
   id = plotcandle1.RegisterStreams(id, i_colUp);
   id = plotcandle1.RegisterStreams(id, i_colDown);
   SetIndexBuffer(id, plot16);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 3, GetColorOnly(ColorRGB(0, 0, 0, 20)));
   SetIndexBuffer(id, plot17);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, GetColorOnly(ColorRGB(250, 200, 50, 0)));
   plot18 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot18.RegisterStream(id, ColorRGB(0, 0, 0, 20), "Stoch K Shadow", DRAW_LINE, STYLE_SOLID, 3);
   id = plot18.RegisterStream(id, ColorRGB(0, 0, 0, 100), "Stoch K Shadow", DRAW_LINE, STYLE_SOLID, 3);
   plot20 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot20.RegisterStream(id, ColorRGB(0, 0, 0, 20), "Stoch D Shadow", DRAW_LINE, STYLE_SOLID, 3);
   id = plot20.RegisterStream(id, ColorRGB(0, 0, 0, 100), "Stoch D Shadow", DRAW_LINE, STYLE_SOLID, 3);
   plot22 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot22.RegisterStream(id, AddTransparency(0xFF9400, 0), "Stoch K", DRAW_LINE, STYLE_SOLID, 1);
   id = plot22.RegisterStream(id, ColorRGB(0, 0, 0, 100), "Stoch K", DRAW_LINE, STYLE_SOLID, 1);
   plot24 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot24.RegisterStream(id, AddTransparency(0x006AFF, 0), "Stoch D", DRAW_LINE, STYLE_SOLID, 1);
   id = plot24.RegisterStream(id, ColorRGB(0, 0, 0, 100), "Stoch D", DRAW_LINE, STYLE_SOLID, 1);
   IndicatorObjPrefix = GenerateIndicatorPrefix("HARSI ?");
   IndicatorShortName("Heikin Ashi RSI Oscillator");
   f_rsi_12 = new f_rsi_1Stream(i_lenRSI, i_mode, IndicatorObjPrefix + "_2");
   id = f_rsi_12.Init(id);
   f_zstoch_13 = new f_zstoch_1Stream(i_stochLen, i_smoothK, i_stochFit, IndicatorObjPrefix + "_3");
   id = f_zstoch_13.Init(id);
   f_rsiHeikinAshi_17 = new f_rsiHeikinAshi_1Stream(i_lenHARSI, IndicatorObjPrefix + "_7");
   id = f_rsiHeikinAshi_17.Init(id);
   id = plot18.RegisterInternalStream(id);
   id = plot20.RegisterInternalStream(id);
   id = plot22.RegisterInternalStream(id);
   id = plot24.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param6Stream.Release();
   delete f_rsi_12;
   delete f_zstoch_13;
   sma2Source.Release();
   sma2.Release();
   delete f_rsiHeikinAshi_17;
   delete plotcandle1;
   delete plot18;
   delete plot20;
   delete plot22;
   delete plot24;
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
      f_rsi_12.Clear();
      f_zstoch_13.Clear();
      sma2Source.Init();
      f_rsiHeikinAshi_17.Clear();
      ArrayInitialize(plot1, i_upperx);
      ArrayInitialize(plot2, i_upper);
      ArrayInitialize(plot3, 0);
      ArrayInitialize(plot4, i_lower);
      ArrayInitialize(plot5, i_lowerx);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot6_dn, EMPTY_VALUE);
      plotcandle1.Init();
      ArrayInitialize(plot16, EMPTY_VALUE);
      ArrayInitialize(plot17, EMPTY_VALUE);
      plot18.Init(EMPTY_VALUE);
      plot20.Init(EMPTY_VALUE);
      plot22.Init(EMPTY_VALUE);
      plot24.Init(EMPTY_VALUE);
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
      string TT_HARSI = "Period for the RSI calculations used to generate the" + "candles. This seperate from the RSI plot/histogram length.";
      string TT_PBIAS = "Smoothing feature for the OPEN of the HARSI candles." + "\n\nIncreases bias toward the prior open value which can" + " help provide better visualisation of trend strength." + "\n\n** By changing the Open values, High and Low can also" + " be distorted - however Close will remain unchanged.";
      string TT_SMRSI = "This option smoothes the RSI in a manner similar to HA" + " open, but uses the realtime rsi rather than the prior" + " close value.";
      string TT_STOCH = "Uses the RSI generated by the above settings, and as such" + " will be affected by the smoothing option.";
      string TT_STFIT = "Adjusts the vertical scaling of the stochastic, can help" + " to prevent distortion of other data in the channel." + "\n\nHas no impact cross conditions.";
      string GROUP_CAND = "Config???HARSI Candles";
      string INLINE_COL = "Colour Pallette";
      string GROUP_PLOT = "Config???RSI Plot";
      string GROUP_STOCH = "Config???Stochastic RSI Plot";
      string INLINE_STDS = "Stoch Draw States";
      string GROUP_CHAN = "Config???OB/OS Boundaries";
      double i_sourceValue;
      if (!i_source.GetValue(pos, i_sourceValue)) { i_sourceValue = EMPTY_VALUE; }
      double f_rsi_12Value;
      if (!f_rsi_12.GetValue(pos, i_sourceValue, f_rsi_12Value)) { f_rsi_12Value = EMPTY_VALUE; }
      double RSI = f_rsi_12Value;
      double f_zstoch_13Value;
      if (!f_zstoch_13.GetValue(pos, RSI, f_zstoch_13Value)) { f_zstoch_13Value = EMPTY_VALUE; }
      double StochK = f_zstoch_13Value;
      sma2Source.SetValue(pos, StochK);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double StochD = sma2Value;
      double f_rsiHeikinAshi_17Value1;
      double f_rsiHeikinAshi_17Value2;
      double f_rsiHeikinAshi_17Value3;
      double f_rsiHeikinAshi_17Value4;
      if (!f_rsiHeikinAshi_17.GetValue(pos, f_rsiHeikinAshi_17Value1, f_rsiHeikinAshi_17Value2, f_rsiHeikinAshi_17Value3, f_rsiHeikinAshi_17Value4)) { f_rsiHeikinAshi_17Value1 = EMPTY_VALUE; f_rsiHeikinAshi_17Value2 = EMPTY_VALUE; f_rsiHeikinAshi_17Value3 = EMPTY_VALUE; f_rsiHeikinAshi_17Value4 = EMPTY_VALUE; }
      double O = f_rsiHeikinAshi_17Value1;
      double H = f_rsiHeikinAshi_17Value2;
      double L = f_rsiHeikinAshi_17Value3;
      double C = f_rsiHeikinAshi_17Value4;
      uint bodyColour = (SafeGreater(C, O) ? i_colUp : i_colDown);
      uint wickColour = i_colWick;
      uint colShadow = ColorRGB(0, 0, 0, 20);
      uint colNone = ColorRGB(0, 0, 0, 100);
      uint colRSI = ColorRGB(250, 200, 50, 0);
      uint colStochK = AddTransparency(0xFF9400, 0);
      uint colStochD = AddTransparency(0x006AFF, 0);
      uint colStochFill = (SafeGE(StochK, StochD) ? AddTransparency(colStochK, 50) : AddTransparency(colStochD, 50));
      double upperx = plot1[pos];
      double upper = plot2[pos];
      double median = plot3[pos];
      double lower = plot4[pos];
      double lowerx = plot5[pos];
      uint plot6_color = AddTransparency(Silver, 80);
      if (plot6_color != INT_MAX) { plot6[pos] = (i_showHist ? RSI : EMPTY_VALUE); plot6_dn[pos] = 0; }
      else { plot6[pos] = EMPTY_VALUE; plot6_dn[pos] = EMPTY_VALUE; }
      double plotcandle1_open = O;
      double plotcandle1_close = C;
      uint plotcandle1_color = bodyColour;
      if (plotcandle1_color != INT_MAX)
      {
         plotcandle1.Set(pos, plotcandle1_open, H, L, plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
      uint plot16_color = colShadow;
      if (plot16_color != INT_MAX) { plot16[pos] = (i_showPlot ? RSI : EMPTY_VALUE); }
      else { plot16[pos] = EMPTY_VALUE; }
      uint plot17_color = colRSI;
      if (plot17_color != INT_MAX) { plot17[pos] = (i_showPlot ? RSI : EMPTY_VALUE); }
      else { plot17[pos] = EMPTY_VALUE; }
      double plot_rsi = plot17[pos];
      double plot18Value = plot18.SetByColor((i_showStoch ? StochK : EMPTY_VALUE), pos, (!i_ribbon ? colShadow : colNone));
      double plot20Value = plot20.SetByColor((i_showStoch ? StochD : EMPTY_VALUE), pos, (!i_ribbon ? colShadow : colNone));
      double plot22Value = plot22.SetByColor((i_showStoch ? StochK : EMPTY_VALUE), pos, (!i_ribbon ? colStochK : colNone));
      double plot_stochK = plot22Value;
      double plot24Value = plot24.SetByColor((i_showStoch ? StochD : EMPTY_VALUE), pos, (!i_ribbon ? colStochD : colNone));
      double plot_stochD = plot24Value;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76389s
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