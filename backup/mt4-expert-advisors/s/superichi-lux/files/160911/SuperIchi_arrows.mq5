//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160733#p160733
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
#property indicator_buffers 26
#property indicator_plots 10

#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
input bool ArrowsOn = true;
double     ArrowUp[];
double     ArrowDn[];

#property indicator_label3 "Tenkan-Sen"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0xf35721
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
//
#property indicator_label4 "Kijun-Sen"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x005dff
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//
#property indicator_label5 "Crossover"
#property indicator_type5 DRAW_ARROW
#property indicator_color5 0xf35721
#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
//
#property indicator_label6 "Crossunder"
#property indicator_type6 DRAW_ARROW
#property indicator_color6 0x005dff
#property indicator_style6 STYLE_SOLID
#property indicator_width6 3
//
#property indicator_label7 "Senkou Span A"
#property indicator_type7 DRAW_NONE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
//
#property indicator_label8 "Senkou Span B"
#property indicator_type8 DRAW_NONE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
//
#property indicator_type9 DRAW_FILLING
#property indicator_width9 1
//
#property indicator_label10 "Chikou"
#property indicator_type10 DRAW_NONE
#property indicator_color10 0xa21f7b
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1

// #property indicator_label1 "Tenkan-Sen"
// #property  indicator_type1 DRAW_LINE
// #property indicator_color1 0xf35721
// #property indicator_style1 STYLE_SOLID
// #property indicator_width1 1

// #property indicator_label2 "Kijun-Sen"
// #property  indicator_type2 DRAW_LINE
// #property indicator_color2 0x005dff
// #property indicator_style2 STYLE_SOLID
// #property indicator_width2 1

// #property indicator_label3 "Crossover"
// #property  indicator_type3 DRAW_ARROW
// #property indicator_color3 0xf35721
// #property indicator_style3 STYLE_SOLID
// #property indicator_width3 3

// #property indicator_label4 "Crossunder"
// #property  indicator_type4 DRAW_ARROW
// #property indicator_color4 0x005dff
// #property indicator_style4 STYLE_SOLID
// #property indicator_width4 3

// #property indicator_label5 "Senkou Span A"
// #property  indicator_type5 DRAW_NONE
// #property indicator_color5 Blue
// #property indicator_style5 STYLE_SOLID
// #property indicator_width5 1

// #property indicator_label6 "Senkou Span B"
// #property  indicator_type6 DRAW_NONE
// #property indicator_color6 Blue
// #property indicator_style6 STYLE_SOLID
// #property indicator_width6 1

// #property  indicator_type7 DRAW_FILLING
// #property indicator_width7 1

// #property indicator_label8 "Chikou"
// #property  indicator_type8 DRAW_NONE
// #property indicator_color8 0xa21f7b
// #property indicator_style8 STYLE_SOLID
// #property indicator_width8 1

// Pine-script like safe operations
// v1.2

double Nz(double val, double defaultValue = 0) { return val == EMPTY_VALUE ? defaultValue : val; }
double SafePlus(int left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left + right;
}
double SafePlus(double left, int right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left + right;
}
int SafePlus(int left, int right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left + right;
}
double SafePlus(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left + right;
}
string SafePlus(string left, string right)
{
    if (left == NULL || right == NULL) {
        return NULL;
    }
    return left + right;
}

double SafeMinus(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left - right;
}

double SafeDivide(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0) {
        return EMPTY_VALUE;
    }
    return left / right;
}

double SafeMultiply(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return left * right;
}

bool SafeGreater(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return false;
    }
    return left > right;
}

bool SafeGE(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return false;
    }
    return left >= right;
}

bool SafeLess(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return false;
    }
    return left < right;
}

bool SafeLE(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return false;
    }
    return left <= right;
}

double SafeMathExp(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathExp(value);
}

double SafeMathMax(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathMax(left, right);
}

double SafeMathMax(double param1, double param2, double param3)
{
    if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
    if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathMin(MathMin(param1, param2), param3);
}

double SafeMathPow(double value, double power)
{
    if (value == EMPTY_VALUE || power == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathPow(value, power);
}

double SafeMathAbs(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathAbs(value);
}

double SafeMathRound(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathSqrt(value);
}

int SafeSign(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    if (value == 0) {
        return 0;
    }
    return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathLog(value);
}
double SafeLog10(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathLog10(value);
}
double SafeCos(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathCos(value);
}
double SafeArccos(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathArccos(value);
}
double SafeSin(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathSin(value);
}
double SafeArcsin(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathArcsin(value);
}
double SafeTan(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathTan(value);
}
double SafeArctan(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathArctan(value);
}
double InvertSign(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return -value;
}
// AStream v1.1
// IStream v.2.0
interface IStream
{
  public:
    virtual void AddRef()  = 0;
    virtual void Release() = 0;

    virtual bool GetValues(const int period, const int count, double &val[])       = 0;
    virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

    virtual int Size() = 0;
};

// AOnStream v2.0
class AStreamBase : public IStream
{
    int _references;

  public:
    AStreamBase() { _references = 1; }

    ~AStreamBase() {}

    void AddRef() { ++_references; }

    void Release()
    {
        --_references;
        if (_references == 0) delete &this;
    }
};
class AStream : public AStreamBase
{
  protected:
    string          _symbol;
    ENUM_TIMEFRAMES _timeframe;
    double          _shift;

  public:
    AStream(string symbol, ENUM_TIMEFRAMES timeframe) : AStreamBase()
    {
        _symbol    = symbol;
        _timeframe = timeframe;
    }

    ~AStream() {}

    void SetShift(const double shift) { _shift = shift; }

    virtual int Size() { return iBars(_symbol, _timeframe); }

    virtual bool GetValues(const int period, const int count, double &val[])
    {
        int bars     = iBars(_symbol, _timeframe);
        int oldIndex = bars - period - 1;
        return GetSeriesValues(oldIndex, count, val);
    }
};

// True range stream v1.1
class TrueRangeStream : public AStream
{
    bool _handleNa;

  public:
    TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false) : AStream(symbol, timeframe) { _handleNa = handleNa; }

    virtual bool GetSeriesValues(const int period, const int count, double &val[])
    {
        int size = Size();
        if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size)) {
            return false;
        }
        for (int i = 0; i < count; ++i) {
            if ((period + i + 1 == size) && _handleNa) {
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

// AOnStream v2.0
class AOnStream : public AStreamBase
{
  protected:
    IStream *_source;

  public:
    AOnStream(IStream *source) : AStreamBase()
    {
        _source = source;
        _source.AddRef();
    }

    ~AOnStream() { _source.Release(); }

    virtual bool GetSeriesValue(const int period, double &val) = 0;

    virtual bool GetSeriesValues(const int period, const int count, double &val[])
    {
        for (int i = 0; i < count; ++i) {
            double v;
            if (!GetSeriesValue(period + i, v)) return false;
            val[i] = v;
        }
        return true;
    }

    bool GetValues(const int period, const int count, double &val[])
    {
        int size = Size();
        for (int i = 0; i < count; ++i) {
            double v;
            if (!GetSeriesValue(size - 1 - period + i, v)) return false;
            val[i] = v;
        }
        return true;
    }

    virtual int Size() { return _source.Size(); }
};

// #include <Streams/Averages/SmaOnStream.mqh>

// SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
    double _length;

  public:
    SmaOnStream(IStream *source, const int length) : AOnStream(source) { _length = length; }

    bool GetSeriesValue(const int period, double &val)
    {
        double summ = 0;
        for (int i = 0; i < _length; ++i) {
            double price[1];
            if (!_source.GetSeriesValues(period + i, 1, price)) return false;
            summ += price[0];
        }
        val = summ / _length;
        return true;
    }
};

// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
    IStream *_avg;

  public:
    ATRStream(int length) : AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
    {
        IStream *tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
        _avg        = new SmaOnStream(tr, length);
        tr.Release();
    }
    ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length) : AStream(symbol, timeframe)
    {
        IStream *tr = new TrueRangeStream(symbol, timeframe, true);
        _avg        = new SmaOnStream(tr, length);
        tr.Release();
    }
    ~ATRStream() { _avg.Release(); }

    bool GetValues(const int period, const int count, double &val[]) { return _avg.GetValues(period, count, val); }

    bool GetSeriesValues(const int period, const int count, double &val[])
    {
        int oldPos = Size() - period - 1;
        return GetValues(oldPos, count, val);
    }
};
#endif
#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

bool NumberToBool(double number) { return number != EMPTY_VALUE && number != 0; }

class FirstBarState
{
    bool _first;

  public:
    FirstBarState() { _first = true; }
    void Clear() { _first = true; }
    bool IsFirst()
    {
        bool first = _first;
        _first     = false;
        return first;
    }
};

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
    if (value == EMPTY_VALUE || topValue == EMPTY_VALUE) {
        return bottomColor;
    }
    if (bottomValue == EMPTY_VALUE) {
        return topColor;
    }
    double range = topValue - bottomValue;
    double rate  = (value - bottomValue) / range;
    if (rate > 1) {
        return bottomColor;
    }
    if (rate < 0) {
        return topColor;
    }
    uint bottomR = ColorR(bottomColor);
    uint bottomG = ColorG(bottomColor);
    uint bottomB = ColorB(bottomColor);
    uint topR    = ColorR(topColor);
    uint topG    = ColorG(topColor);
    uint topB    = ColorB(topColor);
    return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
    stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
    return stream[pos];
}
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL

class AFloatStream : public IStream
{
    int _refs;

  public:
    AFloatStream() { _refs = 1; }

    void AddRef() { _refs++; }
    void Release()
    {
        if (--_refs == 0) {
            delete &this;
        }
    }
};

#endif
// Float stream v2.0

class FloatStream : public AFloatStream
{
    string          _symbol;
    ENUM_TIMEFRAMES _timeframe;
    double          _stream[];

  public:
    FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
    {
        _symbol    = symbol;
        _timeframe = timeframe;
    }

    void Init() { ArrayInitialize(_stream, EMPTY_VALUE); }

    virtual int Size() { return Bars(_symbol, _timeframe); }

    void SetValue(const int period, double value)
    {
        int totalBars = Size();
        if (period < 0 || totalBars <= period) {
            return;
        }
        EnsureStreamHasProperSize(totalBars);
        _stream[period] = value;
    }

    virtual bool GetValues(const int period, const int count, double &val[])
    {
        int totalBars = Size();
        if (period - count + 1 < 0 || totalBars <= period) {
            return false;
        }
        EnsureStreamHasProperSize(totalBars);

        for (int i = 0; i < count; ++i) {
            val[i] = _stream[period - i];
            if (val[i] == EMPTY_VALUE) {
                return false;
            }
        }
        return true;
    }

    virtual bool GetSeriesValues(const int period, const int count, double &val[]) { return GetValues(Size() - period - 1, count, val); }

  private:
    void EnsureStreamHasProperSize(int size)
    {
        int currentSize = ArrayRange(_stream, 0);
        if (currentSize != size) {
            ArrayResize(_stream, size);
            for (int i = currentSize; i < size; ++i) {
                _stream[i] = EMPTY_VALUE;
            }
        }
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
// Boolean Stream v.1.1

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
  public:
    virtual void AddRef()  = 0;
    virtual void Release() = 0;
    virtual int  Size()    = 0;

    virtual bool GetValues(const int period, const int count, bool &val[])       = 0;
    virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
    virtual bool GetValues(const int period, const int count, int &val[])        = 0;
    virtual bool GetSeriesValues(const int period, const int count, int &val[])  = 0;
};

#endif

class ABoolStream : public IBoolStream
{
    int _refs;

  public:
    ABoolStream() { _refs = 1; }

    void AddRef() { _refs++; }
    void Release()
    {
        if (--_refs == 0) {
            delete &this;
        }
    }
};

#endif
// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
  public:
    virtual void   AddRef()                                             = 0;
    virtual void   Release()                                            = 0;
    virtual bool   IsPass(const int period, const datetime date)        = 0;
    virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

// ConditionStreamV2 v1.1

class ConditionStreamV2 : public ABoolStream
{
  protected:
    ICondition *_condition;

  public:
    ConditionStreamV2(ICondition *condition)
    {
        _condition = condition;
        _condition.AddRef();
    }

    ~ConditionStreamV2() { _condition.Release(); }

    virtual int Size() { return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period); }

    bool GetValue(const int period, bool &val)
    {
        val = _condition.IsPass(period, 0);
        return true;
    }
    virtual bool GetValues(const int period, const int count, bool &val[])
    {
        if (Size() <= period || period - count + 1 < 0) {
            return false;
        }
        for (int i = 0; i < count; ++i) {
            val[i] = _condition.IsPass(period - i, 0);
        }
        return true;
    }
    virtual bool GetSeriesValues(const int period, const int count, bool &val[])
    {
        int pos = Size() - period - 1;
        return GetValues(pos, count, val);
    }
    virtual bool GetValues(const int period, const int count, int &val[])
    {
        bool values[];
        ArrayResize(values, count);
        if (!GetValues(period, count, values)) {
            return false;
        }
        for (int i = 0; i < count; ++i) {
            val[i] = values[i];
        }
        return true;
    }
    virtual bool GetSeriesValues(const int period, const int count, int &val[])
    {
        int pos = Size() - period - 1;
        return GetValues(pos, count, val);
    }
};
#endif

// Condition base v2.1

#ifndef ACondition_IMP
#define ACondition_IMP

class AConditionBase : public ICondition
{
    int    _references;
    string _conditionName;

  public:
    AConditionBase(string name = "")
    {
        _conditionName = name;
        _references    = 1;
    }

    virtual void AddRef() { ++_references; }

    virtual void Release()
    {
        --_references;
        if (_references == 0) delete &this;
    }

    virtual string GetLogMessage(const int period, const datetime date)
    {
        if (_conditionName == "" || _conditionName == NULL) {
            return "";
        }
        return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
    }
};
#endif

// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
    string _symbol;
    double _mult;
    double _point;
    double _pipSize;
    int    _digit;
    double _ticksize;

  public:
    InstrumentInfo(const string symbol)
    {
        _symbol   = symbol;
        _point    = SymbolInfoDouble(symbol, SYMBOL_POINT);
        _digit    = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        _mult     = _digit == 3 || _digit == 5 ? 10 : 1;
        _pipSize  = _point * _mult;
        _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
    }

    // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
    int CompareLots(double lot1, double lot2)
    {
        double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
        if (lotStep == 0) {
            return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
        }
        int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
        int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
        int res       = lotSteps1 - lotSteps2;
        return res;
    }

    static double GetPipSize(const string symbol)
    {
        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double mult  = digit == 3 || digit == 5 ? 10 : 1;
        return point * mult;
    }
    double        GetPointSize() { return _point; }
    double        GetPipSize() { return _pipSize; }
    int           GetDigits() { return _digit; }
    string        GetSymbol() { return _symbol; }
    static double GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
    static double GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
    double        GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
    double        GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
    double        GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

    double RoundRate(const double rate) { return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit); }

    double RoundLots(const double lots)
    {
        double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
        if (lotStep == 0) {
            return 0.0;
        }
        return floor(lots / lotStep) * lotStep;
    }

    double LimitLots(const double lots)
    {
        double minVolume = GetMinLots();
        if (minVolume > lots) {
            return 0.0;
        }
        double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
        if (maxVolume < lots) {
            return maxVolume;
        }
        return lots;
    }

    double NormalizeLots(const double lots) { return LimitLots(RoundLots(lots)); }
};

#endif

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

class ACondition : public AConditionBase
{
  protected:
    ENUM_TIMEFRAMES _timeframe;
    InstrumentInfo *_instrument;
    string          _symbol;

  public:
    ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = NULL) : AConditionBase(name)
    {
        _instrument = new InstrumentInfo(symbol);
        _timeframe  = timeframe;
        _symbol     = symbol;
    }
    ~ACondition() { delete _instrument; }
};

#endif

// #include <streams/IStream.mqh>
// #include <streams/IBarStream.mqh>

#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public IStream
{
  public:
    virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

    virtual bool FindDatePeriod(const datetime date, int &period) = 0;

    virtual bool GetOpen(const int period, double &open)   = 0;
    virtual bool GetHigh(const int period, double &high)   = 0;
    virtual bool GetLow(const int period, double &low)     = 0;
    virtual bool GetClose(const int period, double &close) = 0;

    virtual bool GetHighLow(const int period, double &high, double &low)     = 0;
    virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

    virtual bool GetDate(const int period, datetime &dt) = 0;

    virtual int Size() = 0;

    virtual void Refresh() = 0;
};
#endif

#ifndef TwoStreamsConditionType_IMP
#define TwoStreamsConditionType_IMP

enum TwoStreamsConditionType { FirstAboveSecond, FirstBelowSecond, FirstCrossOverSecond, FirstCrossUnderSecond };

#endif

// Stream-stream condition v2.0

#ifndef StreamStreamCondition_IMP
#define StreamStreamCondition_IMP

class StreamStreamCondition : public ACondition
{
    IStream *               _stream1;
    IStream *               _stream2;
    int                     _periodShift1;
    int                     _periodShift2;
    string                  _name1;
    string                  _name2;
    TwoStreamsConditionType _condition;

  public:
    StreamStreamCondition(const string symbol, ENUM_TIMEFRAMES timeframe, TwoStreamsConditionType condition, IStream *stream1, IStream *stream2, string name1, string name2, int streamPeriodShift1 = 0,
                          int streamPeriodShift2 = 0)
        : ACondition(symbol, timeframe)
    {
        _name1   = name1;
        _name2   = name2;
        _stream1 = stream1;
        _stream1.AddRef();
        _stream2 = stream2;
        _stream2.AddRef();
        _condition    = condition;
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
        switch (_condition) {
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
        double value1[2];
        if (!_stream1.GetValues(period - _periodShift1, 2, value1)) {
            return false;
        }
        double value2[2];
        if (!_stream2.GetValues(period - _periodShift2, 2, value2)) {
            return false;
        }
        switch (_condition) {
        case FirstAboveSecond:
            return value1[0] > value2[0];
        case FirstBelowSecond:
            return value1[0] < value2[0];
        case FirstCrossOverSecond:
            return value1[0] >= value2[0] && value1[1] < value2[1];
        case FirstCrossUnderSecond:
            return value1[0] <= value2[0] && value1[1] > value2[1];
        }
        return value1[0] >= value2[0] && value1[1] < value2[1];
    }
};
#endif

// Or condition v1.0

// Returns true when at least one of the conditions returns true.

class OrCondition : public AConditionBase
{
    ICondition *_conditions[];

  public:
    ~OrCondition()
    {
        int size = ArraySize(_conditions);
        for (int i = 0; i < size; ++i) {
            _conditions[i].Release();
        }
    }

    void Add(ICondition *condition, bool addRef)
    {
        int size = ArraySize(_conditions);
        ArrayResize(_conditions, size + 1);
        _conditions[size] = condition;
        if (addRef) {
            condition.AddRef();
        }
    }

    virtual bool IsPass(const int period, const datetime date)
    {
        int size = ArraySize(_conditions);
        for (int i = 0; i < size; ++i) {
            if (_conditions[i].IsPass(period, date)) return true;
        }
        return false;
    }

    virtual string GetLogMessage(const int period, const datetime date)
    {
        string messages = "";
        int    size     = ArraySize(_conditions);
        for (int i = 0; i < size; ++i) {
            string logMessage = _conditions[i].GetLogMessage(period, date);
            if (messages != "")
                messages = messages + " or (" + logMessage + ")";
            else
                messages = "(" + logMessage + ")";
        }
        return messages + (IsPass(period, date) ? "=true" : "=false");
    }
};

// v1.0
// Wraps IIntStream and provides IStream

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL

// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
  public:
    virtual void AddRef()  = 0;
    virtual void Release() = 0;
    virtual int  Size()    = 0;

    virtual bool GetValues(const int period, const int count, int &val[])       = 0;
    virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
};

#endif

class IntToFloatStreamWrapper : public AFloatStream
{
    IIntStream *_source;

  public:
    IntToFloatStreamWrapper(IIntStream *source)
    {
        _source = source;
        _source.AddRef();
    }
    ~IntToFloatStreamWrapper() { _source.Release(); }

    int          Size() { return _source.Size(); }
    virtual bool GetValues(const int period, const int count, double &val[])
    {
        int intVal[];
        ArrayResize(intVal, count);
        if (!_source.GetValues(period, count, intVal)) {
            return false;
        }
        for (int i = 0; i < count; ++i) {
            val[i] = intVal[i];
        }
        return true;
    }
    virtual bool GetSeriesValues(const int period, const int count, double &val[]) { return GetValues(Size() - period - 1, count, val); }
};
#endif

// CrossStreamV2 v1.0

class CrossStreamFactory
{
  public:
    static IBoolStream *CreateCross(IStream *left, IStream *right)
    {
        OrCondition * or = new OrCondition();
        or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
        or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
        ConditionStreamV2 *result = new ConditionStreamV2(or);
        or.Release();
        return result;
    }

    static IBoolStream *CreateCrossunder(IStream *left, IStream *right)
    {
        StreamStreamCondition *condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
        ConditionStreamV2 *    result    = new ConditionStreamV2(condition);
        condition.Release();
        return result;
    }
    static IBoolStream *CreateCrossunder(IStream *left, IIntStream *right)
    {
        IntToFloatStreamWrapper *rightWrapper = new IntToFloatStreamWrapper(right);
        IBoolStream *            condition    = CreateCrossunder(left, rightWrapper);
        rightWrapper.Release();
        return condition;
    }

    static IBoolStream *CreateCrossover(IStream *left, IStream *right)
    {
        StreamStreamCondition *condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
        ConditionStreamV2 *    result    = new ConditionStreamV2(condition);
        condition.Release();
        return result;
    }
    static IBoolStream *CreateCrossover(IIntStream *left, IIntStream *right)
    {
        IntToFloatStreamWrapper *leftWrapper  = new IntToFloatStreamWrapper(left);
        IntToFloatStreamWrapper *rightWrapper = new IntToFloatStreamWrapper(right);
        IBoolStream *            condition    = CreateCrossover(leftWrapper, rightWrapper);
        leftWrapper.Release();
        rightWrapper.Release();
        return condition;
    }
    static IBoolStream *CreateCrossover(IStream *left, IIntStream *right)
    {
        IntToFloatStreamWrapper *rightWrapper = new IntToFloatStreamWrapper(right);
        IBoolStream *            condition    = CreateCrossover(left, rightWrapper);
        rightWrapper.Release();
        return condition;
    }
};
#endif
// Colored fill v1.2

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
    double   p1[];
    double   p2[];
    int      colorsCount;
    color    upColor;
    color    dnColor;
    int      streamIndex;
    IStream *top;
    IStream *bottom;

  public:
    ColoredFill(int streamIndex)
    {
        this.streamIndex = streamIndex;
        colorsCount      = 0;
        top              = NULL;
        bottom           = NULL;
    }
    ~ColoredFill()
    {
        if (top != NULL) {
            top.Release();
        }
        if (bottom != NULL) {
            bottom.Release();
        }
    }
    void Init()
    {
        ArrayInitialize(p1, 0);
        ArrayInitialize(p2, 0);
    }

    void SetTopBottom(IStream *top, IStream *bottom)
    {
        this.top = top;
        top.AddRef();
        this.bottom = bottom;
        bottom.AddRef();
    }

    void AddColor(uint clr)
    {
        int transp = GetTranparency(clr);
        if (transp == 100) {
            return;
        }
        clr     = GetColorOnly(clr);
        dnColor = colorsCount == 0 ? clr : upColor;
        upColor = clr;
        colorsCount++;
    }
    void AddColor(double clr)
    {
        if (clr == EMPTY_VALUE) {
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
        if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100) {
            p1[period] = 0;
            p2[period] = 0;
            return;
        }
        value1 = LimitValue(period, value1);
        value2 = LimitValue(period, value2);
        if (upColor == clr) {
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
        if (top == NULL || bottom == NULL) {
            return value;
        }
        double topValue[1];
        if (!top.GetValues(pos, 1, topValue)) {
            return value;
        }
        double bottomValue[1];
        if (!bottom.GetValues(pos, 1, bottomValue)) {
            return value;
        }
        if (value > topValue[0]) {
            return topValue[0];
        }
        if (value < bottomValue[0]) {
            return bottomValue[0];
        }
        return value;
    }
};
#endif
input int    param1     = 9;    // Tenkan Len
input double param2     = 2.;   // Tenkan Multiplier
input int    param3     = 26;   // Kijun Len
input double param4     = 4.;   // Kijun Multiplier
input int    param5     = 52;   // Senkou Span B
input double param6     = 6.;   // Senkou Span B Multiplier
input int    param7     = 26;   // Displacement
input int    bars_limit = 1000; // Bars limit
int          tenkan_len;
// IStream* tenkan_mult;
double tenkan_mult;
int    kijun_len;
// IStream* kijun_mult;
double kijun_mult;
int    spanB_len;
// IStream* spanB_mult;
double spanB_mult;
int    offset;
class avg__custom_fS_i_fSStream
{
    IStream *    src;
    int          length;
    IStream *    mult;
    ATRStream *  atr1;
    double       upper[];
    double       upper_DEFAULT_VALUE;
    double       lower[];
    double       lower_DEFAULT_VALUE;
    double       os[];
    double       os_DEFAULT_VALUE;
    FloatStream *cross1X;
    FloatStream *cross1Y;
    IBoolStream *cross1;
    double       max[];
    double       max_DEFAULT_VALUE;
    FloatStream *cross2X;
    FloatStream *cross2Y;
    IBoolStream *cross2;
    double       min[];
    double       min_DEFAULT_VALUE;
    bool         _initialized;

  public:
    avg__custom_fS_i_fSStream(IStream *src, int length, IStream *mult)
    {
        _initialized = false;
        this.src     = src;
        src.AddRef();
        this.length = length;
        this.mult   = mult;
        mult.AddRef();
        atr1    = new ATRStream(length);
        cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
        cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
        cross1  = CrossStreamFactory::CreateCross(cross1X, cross1Y);
        cross2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
        cross2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
        cross2  = CrossStreamFactory::CreateCross(cross2X, cross2Y);
    }
    ~avg__custom_fS_i_fSStream()
    {
        src.Release();
        mult.Release();
        atr1.Release();
        cross1X.Release();
        cross1Y.Release();
        cross1.Release();
        cross2X.Release();
        cross2Y.Release();
        cross2.Release();
    }
    int Init(int id)
    {
        SetIndexBuffer(id++, upper, INDICATOR_CALCULATIONS);
        SetIndexBuffer(id++, lower, INDICATOR_CALCULATIONS);
        SetIndexBuffer(id++, os, INDICATOR_CALCULATIONS);
        SetIndexBuffer(id++, max, INDICATOR_CALCULATIONS);
        SetIndexBuffer(id++, min, INDICATOR_CALCULATIONS);
        return id;
    }
    void Clear() { _initialized = false; }
    bool GetValue(const int pos, const int oldPos, double &__out1)
    {
        if (!_initialized) {
            upper_DEFAULT_VALUE = 0.;
            ArrayInitialize(upper, upper_DEFAULT_VALUE);
            lower_DEFAULT_VALUE = 0.;
            ArrayInitialize(lower, lower_DEFAULT_VALUE);
            os_DEFAULT_VALUE = 0;
            ArrayInitialize(os, os_DEFAULT_VALUE);
            cross1X.Init();
            cross1Y.Init();
            max_DEFAULT_VALUE = 0.;
            ArrayInitialize(max, max_DEFAULT_VALUE);
            cross2X.Init();
            cross2Y.Init();
            min_DEFAULT_VALUE = 0.;
            ArrayInitialize(min, min_DEFAULT_VALUE);
            _initialized = true;
        }
        double atr1Value[1];
        if (!atr1.GetValues(pos, 1, atr1Value)) {
            atr1Value[0] = EMPTY_VALUE;
        }
        double multValue[1];
        if (!mult.GetValues(pos, 1, multValue)) {
            multValue[0] = EMPTY_VALUE;
        }
        double atr = SafeMultiply(atr1Value[0], multValue[0]);
        double up  = SafePlus(SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)), 2), atr);
        double dn  = SafeMinus(SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)), 2), atr);
        double srcValue_1[1];
        if (!src.GetValues(pos - 1, 1, srcValue_1)) {
            srcValue_1[0] = EMPTY_VALUE;
        }
        if (pos - 1 < 0) {
            return false;
        }
        if (pos - 1 < 0) {
            return false;
        }
        SetStream(upper, pos, (SafeLess(srcValue_1[0], upper[pos - 1]) ? SafeMathMin(up, upper[pos - 1]) : up), upper_DEFAULT_VALUE);
        if (pos - 1 < 0) {
            return false;
        }
        if (pos - 1 < 0) {
            return false;
        }
        SetStream(lower, pos, (SafeGreater(srcValue_1[0], lower[pos - 1]) ? SafeMathMax(dn, lower[pos - 1]) : dn), lower_DEFAULT_VALUE);
        double srcValue[1];
        if (!src.GetValues(pos, 1, srcValue)) {
            srcValue[0] = EMPTY_VALUE;
        }
        if (pos - 1 < 0) {
            return false;
        }
        SetStream(os, pos, ((srcValue[0] > upper[pos]) ? 1 : ((srcValue[0] < lower[pos]) ? 0 : os[pos - 1])), os_DEFAULT_VALUE);
        double spt = ((os[pos] == 1) ? lower[pos] : upper[pos]);
        cross1X.SetValue(pos, srcValue[0]);
        cross1Y.SetValue(pos, spt);
        int cross1Value[1];
        if (!cross1.GetValues(pos, 1, cross1Value)) {
            cross1Value[0] = (-1);
        }
        if (pos - 1 < 0) {
            return false;
        }
        if (pos - 1 < 0) {
            return false;
        }
        SetStream(max, pos, (cross1Value[0] ? SafeMathMax(srcValue[0], max[pos - 1]) : ((os[pos] == 1) ? SafeMathMax(srcValue[0], max[pos - 1]) : spt)), max_DEFAULT_VALUE);
        cross2X.SetValue(pos, srcValue[0]);
        cross2Y.SetValue(pos, spt);
        int cross2Value[1];
        if (!cross2.GetValues(pos, 1, cross2Value)) {
            cross2Value[0] = (-1);
        }
        if (pos - 1 < 0) {
            return false;
        }
        if (pos - 1 < 0) {
            return false;
        }
        SetStream(min, pos, (cross2Value[0] ? SafeMathMin(srcValue[0], min[pos - 1]) : ((os[pos] == 0) ? SafeMathMin(srcValue[0], min[pos - 1]) : spt)), min_DEFAULT_VALUE);
        __out1 = SafeDivide((max[pos] + min[pos]), 2);
        return true;
    }
};
FloatStream *              avg__custom_fS_i_fS1_param1;
FloatStream *              avg__custom_fS_i_fS1_param3;
avg__custom_fS_i_fSStream *avg__custom_fS_i_fS1;
FloatStream *              avg__custom_fS_i_fS2_param1;
FloatStream *              avg__custom_fS_i_fS2_param3;
avg__custom_fS_i_fSStream *avg__custom_fS_i_fS2;
FloatStream *              avg__custom_fS_i_fS3_param1;
FloatStream *              avg__custom_fS_i_fS3_param3;
avg__custom_fS_i_fSStream *avg__custom_fS_i_fS3;
double                     plot1[];
double                     plot2[];
double                     plot3[];
FloatStream *              crossover1X;
FloatStream *              crossover1Y;
IBoolStream *              crossover1;
double                     plot4[];
FloatStream *              crossunder1X;
FloatStream *              crossunder1Y;
IBoolStream *              crossunder1;
double                     plot5[];
double                     plot6[];
ColoredFill *              fill7;
double                     plot8[];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
    for (int k = ObjectsTotal(0); k >= 0; k--) {
        if (StringFind(ObjectName(0, k), name) == 0) {
            return true;
        }
    }
    return false;
}

string GenerateIndicatorPrefix(const string target)
{
    for (int i = 0; i < 1000; ++i) {
        string prefix = target + "_" + IntegerToString(i);
        if (!NamesCollision(prefix)) {
            return prefix;
        }
    }
    return target;
}

// Mark: oninit
void OnInit()
{
    int id      = 0;
    tenkan_len  = param1;
    tenkan_mult = param2;
    kijun_len   = param3;
    kijun_mult  = param4;
    spanB_len   = param5;
    spanB_mult  = param6;
    offset      = param7;

    int id_up = id++;
    int id_dn = id++;
    SetIndexBuffer(id_up, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(id_up, PLOT_ARROW, 233);
    PlotIndexSetInteger(id_up, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(id_up, PLOT_LINE_COLOR, Blue);
    if (!ArrowsOn) PlotIndexSetInteger(id_up, PLOT_DRAW_TYPE, DRAW_NONE);

    SetIndexBuffer(id_dn, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(id_dn, PLOT_ARROW, 234);
    PlotIndexSetInteger(id_dn, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(id_dn, PLOT_LINE_COLOR, Crimson);
    if (!ArrowsOn) PlotIndexSetInteger(id_dn, PLOT_DRAW_TYPE, DRAW_NONE);

    SetIndexBuffer(id++, plot1, INDICATOR_DATA);
    SetIndexBuffer(id++, plot2, INDICATOR_DATA);
    crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    crossover1  = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
    SetIndexBuffer(id, plot3, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 161);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
    ++id;
    crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    crossunder1  = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
    SetIndexBuffer(id, plot4, INDICATOR_DATA);
    PlotIndexSetInteger(4, PLOT_ARROW, 161);
    PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, 5);
    ++id;
    SetIndexBuffer(id++, plot5, INDICATOR_DATA);
    SetIndexBuffer(id++, plot6, INDICATOR_DATA);
    fill7 = new ColoredFill(6);
    fill7.AddColor(AddTransparency(Teal, 80));
    fill7.AddColor(AddTransparency(Red, 80));
    id = fill7.RegisterStreams(id);
    SetIndexBuffer(id++, plot8, INDICATOR_DATA);
    IndicatorObjPrefix = GenerateIndicatorPrefix("SuperIchi [LuxAlgo]");
    IndicatorSetString(INDICATOR_SHORTNAME, "SuperIchi [LUX]");
    IndicatorSetInteger(INDICATOR_DIGITS, Digits());
    avg__custom_fS_i_fS1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS1_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS1        = new avg__custom_fS_i_fSStream(avg__custom_fS_i_fS1_param1, tenkan_len, avg__custom_fS_i_fS1_param3);
    id                          = avg__custom_fS_i_fS1.Init(id);
    avg__custom_fS_i_fS2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS2        = new avg__custom_fS_i_fSStream(avg__custom_fS_i_fS2_param1, kijun_len, avg__custom_fS_i_fS2_param3);
    id                          = avg__custom_fS_i_fS2.Init(id);
    avg__custom_fS_i_fS3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS3_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    avg__custom_fS_i_fS3        = new avg__custom_fS_i_fSStream(avg__custom_fS_i_fS3_param1, spanB_len, avg__custom_fS_i_fS3_param3);
    id                          = avg__custom_fS_i_fS3.Init(id);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, IndicatorObjPrefix);
    avg__custom_fS_i_fS1_param1.Release();
    avg__custom_fS_i_fS1_param3.Release();
    delete avg__custom_fS_i_fS1;
    avg__custom_fS_i_fS2_param1.Release();
    avg__custom_fS_i_fS2_param3.Release();
    delete avg__custom_fS_i_fS2;
    avg__custom_fS_i_fS3_param1.Release();
    avg__custom_fS_i_fS3_param3.Release();
    delete avg__custom_fS_i_fS3;
    crossover1X.Release();
    crossover1Y.Release();
    crossover1.Release();
    crossunder1X.Release();
    crossunder1Y.Release();
    crossunder1.Release();
    delete fill7;
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (prev_calculated <= 0 || prev_calculated > rates_total) {
        avg__custom_fS_i_fS1_param1.Init();
        avg__custom_fS_i_fS1_param3.Init();
        avg__custom_fS_i_fS1.Clear();
        avg__custom_fS_i_fS2_param1.Init();
        avg__custom_fS_i_fS2_param3.Init();
        avg__custom_fS_i_fS2.Clear();
        avg__custom_fS_i_fS3_param1.Init();
        avg__custom_fS_i_fS3_param3.Init();
        avg__custom_fS_i_fS3.Clear();
        ArrayInitialize(plot1, EMPTY_VALUE);
        ArrayInitialize(plot2, EMPTY_VALUE);
        ArrayInitialize(plot3, EMPTY_VALUE);
        crossover1X.Init();
        crossover1Y.Init();
        ArrayInitialize(plot4, EMPTY_VALUE);
        crossunder1X.Init();
        crossunder1Y.Init();
        ArrayInitialize(plot5, EMPTY_VALUE);
        ArrayInitialize(plot6, EMPTY_VALUE);
        fill7.Init();
        ArrayInitialize(plot8, EMPTY_VALUE);
    }

    int first = 0;
    for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos) {
        int oldPos = rates_total - pos - 1;
        avg__custom_fS_i_fS1_param1.SetValue(pos, close[pos]);
        avg__custom_fS_i_fS1_param3.SetValue(pos, tenkan_mult);
        double avg__custom_fS_i_fS1Value;

        if (!avg__custom_fS_i_fS1.GetValue(pos, oldPos, avg__custom_fS_i_fS1Value)) {
            avg__custom_fS_i_fS1Value = EMPTY_VALUE;
        }
        double tenkan = avg__custom_fS_i_fS1Value;
        avg__custom_fS_i_fS2_param1.SetValue(pos, close[pos]);
        avg__custom_fS_i_fS2_param3.SetValue(pos, kijun_mult);
        double avg__custom_fS_i_fS2Value;

        if (!avg__custom_fS_i_fS2.GetValue(pos, oldPos, avg__custom_fS_i_fS2Value)) {
            avg__custom_fS_i_fS2Value = EMPTY_VALUE;
        }
        double kijun   = avg__custom_fS_i_fS2Value;
        double senkouA = SafeDivide((SafePlus(kijun, tenkan)), 2);
        avg__custom_fS_i_fS3_param1.SetValue(pos, close[pos]);
        avg__custom_fS_i_fS3_param3.SetValue(pos, spanB_mult);
        double avg__custom_fS_i_fS3Value;

        if (!avg__custom_fS_i_fS3.GetValue(pos, oldPos, avg__custom_fS_i_fS3Value)) {
            avg__custom_fS_i_fS3Value = EMPTY_VALUE;
        }
        double senkouB    = avg__custom_fS_i_fS3Value;
        uint   tenkan_css = 0xf35721;
        uint   kijun_css  = 0x005dff;
        uint   cloud_a    = AddTransparency(Teal, 80);
        uint   cloud_b    = AddTransparency(Red, 80);
        uint   chikou_css = 0xa21f7b;
        plot1[pos]        = tenkan;
        plot2[pos]        = kijun;
        crossover1X.SetValue(pos, tenkan); 
        crossover1Y.SetValue(pos, kijun);
        int crossover1Value[1];

        if (!crossover1.GetValues(pos, 1, crossover1Value)) {
            crossover1Value[0] = (-1);            
        }
        plot3[pos] = (crossover1Value[0] ? kijun : EMPTY_VALUE);
        
        if(plot3[pos] != EMPTY_VALUE) {
           ArrowUp[pos-1] = low[pos-1];            
        }
        crossunder1X.SetValue(pos, tenkan);
        crossunder1Y.SetValue(pos, kijun);
        int crossunder1Value[1];

        if (!crossunder1.GetValues(pos, 1, crossunder1Value)) {
            crossunder1Value[0] = (-1);
        }
        plot4[pos] = (crossunder1Value[0] ? kijun : EMPTY_VALUE);
        
        if(plot4[pos] != EMPTY_VALUE) { 
         ArrowDn[pos-1] = high[pos-1]; 
        }
        
        plot5[pos] = senkouA;
        double A   = plot5[pos];
        plot6[pos] = senkouB;
        double B   = plot6[pos];
        fill7.Set(pos, A, B, (SafeGreater(senkouA, senkouB) ? cloud_a : cloud_b));
        plot8[pos] = close[pos];
    }
    return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160733#p160733
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