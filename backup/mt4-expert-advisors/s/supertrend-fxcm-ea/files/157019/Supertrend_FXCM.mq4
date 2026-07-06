// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75287

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
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];


enum PriceType {
    PriceClose    = PRICE_CLOSE,    // Close
    PriceOpen     = PRICE_OPEN,     // Open
    PriceHigh     = PRICE_HIGH,     // High
    PriceLow      = PRICE_LOW,      // Low
    PriceMedian   = PRICE_MEDIAN,   // Median
    PriceTypical  = PRICE_TYPICAL,  // Typical
    PriceWeighted = PRICE_WEIGHTED, // Weighted
    PriceMedianBody,                // Median (body)
    PriceAverage,                   // Average
    PriceTrendBiased,               // Trend biased
    PriceVolume,                    // Volume
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
    virtual void AddRef()  = 0;
    virtual void Release() = 0;
    virtual int  Size()    = 0;

    virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
    int _references;

  public:
    AStreamBase() { _references = 1; }

    void AddRef() { ++_references; }

    void Release()
    {
        --_references;
        if (_references == 0) delete &this;
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
    int    _digits;
    double _tickSize;

  public:
    InstrumentInfo(const string symbol)
    {
        _symbol   = symbol;
        _point    = MarketInfo(symbol, MODE_POINT);
        _digits   = (int)MarketInfo(symbol, MODE_DIGITS);
        _mult     = _digits == 3 || _digits == 5 ? 10 : 1;
        _pipSize  = _point * _mult;
        _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
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

    static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
    double        GetBid() { return GetBid(_symbol); }
    static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
    double        GetAsk() { return GetAsk(_symbol); }
    static double GetPipSize(const string symbol)
    {
        double point  = MarketInfo(symbol, MODE_POINT);
        double digits = (int)MarketInfo(symbol, MODE_DIGITS);
        double mult   = digits == 3 || digits == 5 ? 10 : 1;
        return point * mult;
    }
    double GetPipSize() { return _pipSize; }
    double GetPointSize() { return _point; }
    string GetSymbol() { return _symbol; }
    double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
    int    GetDigits() { return _digits; }
    double GetTickSize() { return _tickSize; }
    double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

    double AddPips(const double rate, const double pips) { return RoundRate(rate + pips * _pipSize); }

    double RoundRate(const double rate) { return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits); }

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

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public IStream
{
  protected:
    string          _symbol;
    ENUM_TIMEFRAMES _timeframe;
    double          _shift;
    InstrumentInfo *_instrument;
    int             _references;

    AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
    {
        _references = 1;
        _shift      = 0.0;
        _symbol     = symbol;
        _timeframe  = timeframe;
        _instrument = new InstrumentInfo(_symbol);
    }

    ~AStream() { delete _instrument; }

  public:
    void SetShift(const double shift) { _shift = shift; }

    void AddRef() { ++_references; }

    void Release()
    {
        --_references;
        if (_references == 0) delete &this;
    }

    int Size() { return iBars(_symbol, _timeframe); }
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

    virtual bool FindDatePeriod(const datetime date, int &period) = 0;

    virtual bool GetOpen(const int period, double &open)   = 0;
    virtual bool GetHigh(const int period, double &high)   = 0;
    virtual bool GetLow(const int period, double &low)     = 0;
    virtual bool GetClose(const int period, double &close) = 0;

    virtual bool GetHighLow(const int period, double &high, double &low)     = 0;
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
    PriceType   _price;
    IBarStream *_source;

  public:
    PriceStream(IBarStream *source, const PriceType __price) : AStreamBase()
    {
        _source = source;
        _source.AddRef();
        _price = __price;
    }

    ~PriceStream() { _source.Release(); }

    int Size() { return _source.Size(); }

    bool GetValue(const int period, double &val)
    {
        switch (_price) {
        case PriceClose:
            if (!_source.GetClose(period, val)) {
                return false;
            }
            break;
        case PriceOpen:
            if (!_source.GetOpen(period, val)) {
                return false;
            }
            break;
        case PriceHigh:
            if (!_source.GetHigh(period, val)) {
                return false;
            }
            break;
        case PriceLow:
            if (!_source.GetLow(period, val)) {
                return false;
            }
            break;
        case PriceMedian: {
            double high, low;
            if (!_source.GetHighLow(period, high, low)) {
                return false;
            }
            val = (high + low) / 2.0;
        } break;
        case PriceTypical: {
            double open1, high1, low1, close1;
            if (!_source.GetValues(period, open1, high1, low1, close1)) {
                return false;
            }
            val = (high1 + low1 + close1) / 3.0;
        } break;
        case PriceWeighted: {
            double open2, high2, low2, close2;
            if (!_source.GetValues(period, open2, high2, low2, close2)) {
                return false;
            }
            val = (high2 + low2 + close2 * 2) / 4.0;
        } break;
        case PriceMedianBody: {
            double open3, close3;
            if (!_source.GetOpenClose(period, open3, close3)) {
                return false;
            }
            val = (open3 + close3) / 2.0;
        } break;
        case PriceAverage: {
            double open4, high4, low4, close4;
            if (!_source.GetValues(period, open4, high4, low4, close4)) {
                return false;
            }
            val = (high4 + low4 + close4 + open4) / 4.0;
        } break;
        case PriceTrendBiased: {
            double open5, high5, low5, close5;
            if (!_source.GetValues(period, open5, high5, low5, close5)) {
                return false;
            }
            if (open5 > close5)
                val = (high5 + close5) / 2.0;
            else
                val = (low5 + close5) / 2.0;
        } break;
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
    string          _symbol;
    ENUM_TIMEFRAMES _timeframe;
    int             _referenceCount;

  public:
    BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
    {
        _referenceCount = 1;
        _symbol         = symbol;
        _timeframe      = timeframe;
    }
    virtual void AddRef() { ++_referenceCount; }
    virtual void Release()
    {
        --_referenceCount;
        if (_referenceCount == 0) delete &this;
    }

    virtual bool FindDatePeriod(const datetime date, int &period)
    {
        period = iBarShift(_symbol, _timeframe, date);
        return true;
    }

    virtual bool GetValue(const int period, double &val)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        val = iClose(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetDate(const int period, datetime &dt)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        dt = iTime(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetOpen(const int period, double &open)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        open = iOpen(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetHigh(const int period, double &high)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        high = iHigh(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetLow(const int period, double &low)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        low = iLow(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetClose(const int period, double &close)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        close = iClose(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        open  = iOpen(_symbol, _timeframe, period);
        high  = iHigh(_symbol, _timeframe, period);
        low   = iLow(_symbol, _timeframe, period);
        close = iClose(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetHighLow(const int period, double &high, double &low)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        high = iHigh(_symbol, _timeframe, period);
        low  = iLow(_symbol, _timeframe, period);
        return true;
    }

    virtual bool GetOpenClose(const int period, double &open, double &close)
    {
        if (iBars(_symbol, _timeframe) <= period) return false;
        open  = iOpen(_symbol, _timeframe, period);
        close = iClose(_symbol, _timeframe, period);
        return true;
    }

    virtual int Size() { return iBars(_symbol, _timeframe); }

    virtual void Refresh() {}
};

#endif

class PriceStreamFactory
{
  public:
    static IStream *Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
    {
        BarStream *source = new BarStream(symbol, timeframe);
        IStream *  stream = new PriceStream(source, price);
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

    virtual int Size() { return iBars(_symbol, _timeframe); }

    void SetValue(const int period, double value)
    {
        int totalBars = Size();
        int index     = totalBars - period - 1;
        if (index < 0 || totalBars <= index) {
            return;
        }
        EnsureStreamHasProperSize(totalBars);
        _stream[index] = value;
    }

    bool GetValue(const int period, double &val)
    {
        int totalBars = Size();
        int index     = totalBars - period - 1;
        if (index < 0 || totalBars <= index) {
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
        if (currentSize != size) {
            ArrayResize(_stream, size);
            for (int i = currentSize; i < size; ++i) {
                _stream[i] = EMPTY_VALUE;
            }
        }
    }
};

#endif

// Base implementation of stream based on another stream
// v1.1

class AOnStream : public IStream
{
  protected:
    IStream *_source;
    int      _references;

  public:
    AOnStream(IStream *source)
    {
        _references = 1;
        _source     = source;
        if (_source != NULL) {
            _source.AddRef();
        }
    }

    ~AOnStream() { _source.Release(); }

    void AddRef() { ++_references; }

    void Release()
    {
        --_references;
        if (_references == 0) delete &this;
    }

    virtual int Size() { return _source.Size(); }
};

// SMA on stream v1.1
#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
    int    _length;
    double _buffer[];

  public:
    SmaOnStream(IStream *source, const int length) : AOnStream(source) { _length = length; }

    bool GetValue(const int period, double &val)
    {
        int totalBars         = Bars;
        int currentBufferSize = ArrayRange(_buffer, 0);
        if (currentBufferSize != totalBars) {
            ArrayResize(_buffer, totalBars);
            for (int i = currentBufferSize; i < totalBars; ++i) {
                _buffer[i] = EMPTY_VALUE;
            }
        }

        if (period > totalBars - _length) return false;

        int bufferIndex = totalBars - 1 - period;
        if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE) {
            double current;
            double last;
            if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last)) return false;
            _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
        } else {
            _buffer[bufferIndex] = EMPTY_VALUE;
            double summ          = 0;
            for (int i = 0; i < _length; i++) {
                double current_;
                if (!_source.GetValue(period + i, current_)) return false;

                summ += current_;
            }
            _buffer[bufferIndex] = summ / _length;
        }
        val = _buffer[bufferIndex];
        return true;
    }
};
#endif

// True range stream v2.2

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
    bool _handleNa;

  public:
    TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false) : AStream(symbol, timeframe) { _handleNa = handleNa; }

    bool GetValue(const int period, double &val)
    {
        int pos = Size() - period - 1;
        if (pos < 1) {
            if (_handleNa) {
                val = CalcFirst(pos);
                return true;
            }
            return false;
        }
        double h  = iHigh(_symbol, _timeframe, period);
        double l  = iLow(_symbol, _timeframe, period);
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

// Average true range stream v2.1

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

    bool GetValue(const int period, double &val) { return _avg.GetValue(period, val); }
};
#endif
// Pine-script like safe operations
// v.1.2

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

double SafeMathMin(double left, double right)
{
    if (left == EMPTY_VALUE || right == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathMin(left, right);
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
double SafeMathFloor(double value)
{
    if (value == EMPTY_VALUE) {
        return EMPTY_VALUE;
    }
    return MathFloor(value);
}
#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
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

class NewBarState
{
    datetime _last;

  public:
    NewBarState() { _last = 0; }
    void Clear() { _last = 0; }
    bool IsNew(datetime date)
    {
        bool isnew = _last != date;
        _last      = date;
        return isnew;
    }
};

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
{
    if (value == EMPTY_VALUE || topValue == EMPTY_VALUE) {
        return bottomColor;
    }
    if (bottomValue == EMPTY_VALUE) {
        return topColor;
    }
    return value - bottomValue < topValue - value ? bottomColor : topColor;
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
    time.mon  = month;
    time.day  = day;
    time.hour = hour;
    time.min  = minute;
    time.sec  = second;
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
    static int Sunday() { return 0; }
    static int Monday() { return 1; }
    static int Tuesday() { return 2; }
    static int Wednesday() { return 3; }
    static int Thursday() { return 4; }
    static int Friday() { return 5; }
    static int Saturday() { return 6; }
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

// Measure of difference between the series and it's SMA stream
// v1.0

class DevStream : public AOnStream
{
    SmaOnStream *sma;

  public:
    DevStream(IStream *source, const int length) : AOnStream(source) { sma = new SmaOnStream(source, length); }

    ~DevStream() { sma.Release(); }

    bool GetValue(const int period, double &val)
    {
        double src;
        double smaValue;
        if (!_source.GetValue(period, src) || !sma.GetValue(period, smaValue)) {
            return false;
        }
        val = src - smaValue;
        return true;
    }
};
// Pine-script like strategy functions
// v1.0

#ifndef PineStrategy_IMPL
#define PineStrategy_IMPL

// Signaler v2.2
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string AlertsSection      = "";                         // == Alerts ==
input bool   popup_alert        = false;                      // Popup message
input bool   notification_alert = false;                      // Push notification
input bool   email_alert        = false;                      // Email
input bool   play_sound         = false;                      // Play sound on alert
input string sound_file         = "";                         // Sound file
input bool   start_program      = false;                      // Start external program
input string program_path       = "";                         // Path to the external program executable
input bool   advanced_alert     = false;                      // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string advanced_key       = "";                         // Advanced alert key
input string advanced_server    = "https://profitrobots.com"; // Advanced alert server url
input string Comment2           = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string Comment3           = "- Allow use of dll in the indicator parameters window -";
input string Comment4           = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
// #import "AdvancedNotificationsLib.dll"
// void AdvancedAlert(string key, string text, string instrument, string timeframe);
// void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
// #import
// #import "shell32.dll"
// int ShellExecuteW(int hwnd, string Operation, string File, string Parameters, string Directory, int ShowCmd);
// #import

enum SignalerFrequency { SignalsAll, SignalsOncePerBarClose, SignalsOncePerBar };

class Signaler
{
    string            _prefix;
    SignalerFrequency _frequency;
    datetime          _lastSignal;

  public:
    Signaler(string frequency)
    {
        if (frequency == "all") {
            _frequency = SignalsAll;
        } else if (frequency == "once_per_bar_close") {
            _frequency = SignalsOncePerBarClose;
        } else if (frequency == "once_per_bar") {
            _frequency = SignalsOncePerBar;
        }
        _lastSignal = 0;
    }
    Signaler() { _lastSignal = 0; }

    void SetMessagePrefix(string prefix) { _prefix = prefix; }

    void Alert(string message, int position, datetime time)
    {
        if (position != 0) {
            return;
        }
        if (_frequency != SignalsAll) {
            if (_lastSignal == time) {
                return;
            }
        }
        _lastSignal = time;
        SendNotifications("", message);
    }

    void SendNotifications(const string subject, string message = NULL)
    {
        if (message == NULL) message = subject;
        if (_prefix != "" && _prefix != NULL) message = _prefix + message;

      //   if (start_program) ShellExecuteW(0, "open", program_path, "", "", 1);
        if (popup_alert) Alert(message);
        if (email_alert) SendMail(subject, message);
        if (play_sound) PlaySound(sound_file);
        if (notification_alert) SendNotification(message);
      //   if (advanced_alert && advanced_key != "" && !IsTesting()) AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
    }
};

class PineStrategy
{
  public:
    static void Entry(Signaler *signaler, string id, bool longDirection) { signaler.SendNotifications(id); }

    static void Exit(Signaler *signaler, string id, string comment)
    {
        string message = id;
        if (comment != NULL) {
            message = message + ": " + comment;
        }
        signaler.SendNotifications(message);
    }

    static double GetPositionSize() { return 0; }

    static void Close(Signaler *signaler, string id, bool when)
    {
        if (!when) {
            return;
        }
        signaler.SendNotifications(id);
    }

    static void Cancel(Signaler *signaler, string id, bool when)
    {
        if (!when) {
            return;
        }
        signaler.SendNotifications(id);
    }

    static void CloseAll(Signaler *signaler, bool when, string id)
    {
        if (!when) {
            return;
        }
        signaler.SendNotifications(id);
    }

    static double Equity() { return 0; }
};

#endif

input int       param1     = 12;                         // ATR Period
input PriceType param2     = PriceClose;                 // Source
input double    param3     = 2.6;                        // ATR Multiplier
input bool      param4     = true;                       // Change ATR Calculation Method ?
input int       param5     = 20;                         // Length
input PriceType param6     = PriceClose;                 // Source
input string    param7     = "Replace Webhook Alert ID"; // Buy Webhook Message
input string    param8     = "Replace Webhook Alert ID"; // Sell Webhook Message
input int       param9     = 58;                         // Take Profit in PIPS
input int       param10    = 31;                         // Stop Loss in PIPS
input int       bars_limit = 100000;                     // Bars limit
Signaler *      _signaler;
int             Periods;
IStream *       param2Stream;
IStream *       src;
double          Multiplier;
int             changeATR;
FloatStream *   sma1Source;
SmaOnStream *   sma1;
IStream *       tr1;
ATRStream *     atr1;
double          up[];
double          up_DEFAULT_VALUE;
double          dn[];
double          dn_DEFAULT_VALUE;
double          trend[];
double          trend_DEFAULT_VALUE;
int             clength;
IStream *       param6Stream;
IStream *       csrc;
FloatStream *   sma2Source;
SmaOnStream *   sma2;
FloatStream *   dev1Source;
DevStream *     dev1;
string          buyAlertId;
string          sellAlertId;
int             tp;
int             sl;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
    for (int k = ObjectsTotal(); k >= 0; k--) {
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

int init()
{
    IndicatorBuffers(5);
    int id             = 2;
    Periods            = param1;
    param2Stream       = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param2);
    src                = param2Stream;
    Multiplier         = param3;
    changeATR          = param4;
    sma1Source         = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    sma1               = new SmaOnStream(sma1Source, Periods);
    atr1               = new ATRStream(Periods);
    clength            = param5;
    param6Stream       = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param6);
    csrc               = param6Stream;
    sma2Source         = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    sma2               = new SmaOnStream(sma2Source, clength);
    dev1Source         = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    dev1               = new DevStream(dev1Source, clength);
    buyAlertId         = param7;
    sellAlertId        = param8;
    tp                 = param9;
    sl                 = param10;
    _signaler          = new Signaler();
    IndicatorObjPrefix = GenerateIndicatorPrefix("");
    IndicatorShortName("Supertrend FXCM");
    tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
    
    //--- indicator buffers mapping
  SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, clrBlue);
  SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, clrRed);
   SetIndexArrow(1, 234);

    SetIndexBuffer(id++, up);
   SetIndexStyle(id, DRAW_NONE);
    SetIndexBuffer(id++, dn);
   SetIndexStyle(id, DRAW_NONE);
    SetIndexBuffer(id++, trend);
   SetIndexStyle(id, DRAW_NONE);

    return INIT_SUCCEEDED;
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    param2Stream.Release();
    sma1Source.Release();
    sma1.Release();
    tr1.Release();
    atr1.Release();
    param6Stream.Release();
    sma2Source.Release();
    sma2.Release();
    dev1Source.Release();
    dev1.Release();
    delete _signaler;
    return 0;
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (prev_calculated <= 0 || prev_calculated > rates_total) {
        sma1Source.Init();
        up_DEFAULT_VALUE = EMPTY_VALUE;
        ArrayInitialize(up, up_DEFAULT_VALUE);
        dn_DEFAULT_VALUE = EMPTY_VALUE;
        ArrayInitialize(dn, dn_DEFAULT_VALUE);
        trend_DEFAULT_VALUE = 1;
        ArrayInitialize(trend, trend_DEFAULT_VALUE);
        sma2Source.Init();
        dev1Source.Init();
    }
    bool timeSeries       = ArrayGetAsSeries(time);
    bool openSeries       = ArrayGetAsSeries(open);
    bool highSeries       = ArrayGetAsSeries(high);
    bool lowSeries        = ArrayGetAsSeries(low);
    bool closeSeries      = ArrayGetAsSeries(close);
    bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(tick_volume, true);

    int toSkip = 0;

    for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos) {
        double tr1Value;
        if (!tr1.GetValue(pos, tr1Value)) {
            tr1Value = EMPTY_VALUE;
        }
        sma1Source.SetValue(pos, tr1Value);
        double sma1Value;
        if (!sma1.GetValue(pos, sma1Value)) {
            sma1Value = EMPTY_VALUE;
        }
        double atr2 = sma1Value;
        double atr1Value;
        if (!atr1.GetValue(pos, atr1Value)) {
            atr1Value = EMPTY_VALUE;
        }
        double atr = (changeATR ? atr1Value : atr2);
        double srcValue;
        if (!src.GetValue(pos, srcValue)) {
            srcValue = EMPTY_VALUE;
        }
        SetStream(up, pos, SafeMinus(srcValue, SafeMultiply(Multiplier, atr)), up_DEFAULT_VALUE);
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        double up1 = Nz(up[pos + 1], up[pos]);
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        SetStream(up, pos, (SafeGreater(close[pos + 1], up1) ? SafeMathMax(up[pos], up1) : up[pos]), up_DEFAULT_VALUE);
        SetStream(dn, pos, SafePlus(srcValue, SafeMultiply(Multiplier, atr)), dn_DEFAULT_VALUE);
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        double dn1 = Nz(dn[pos + 1], dn[pos]);
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        SetStream(dn, pos, (SafeLess(close[pos + 1], dn1) ? SafeMathMin(dn[pos], dn1) : dn[pos]), dn_DEFAULT_VALUE);
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        SetStream(trend, pos, Nz(trend[pos + 1], trend[pos]), trend_DEFAULT_VALUE);
        SetStream(trend, pos, ((trend[pos] == (-1)) && SafeGreater(close[pos], dn1) ? 1 : ((trend[pos] == 1) && SafeLess(close[pos], up1) ? (-1) : trend[pos])), trend_DEFAULT_VALUE);
        double csrcValue;
        
        if (!csrc.GetValue(pos, csrcValue)) {
            csrcValue = EMPTY_VALUE;
        }
        sma2Source.SetValue(pos, csrcValue);
        double sma2Value;
        if (!sma2.GetValue(pos, sma2Value)) {
            sma2Value = EMPTY_VALUE;
        }
        double cma = sma2Value;
        dev1Source.SetValue(pos, csrcValue);
        double dev1Value;
        if (!dev1.GetValue(pos, dev1Value)) {
            dev1Value = EMPTY_VALUE;
        }
        double cci = SafeDivide((SafeMinus(csrcValue, cma)), (SafeMultiply(0.015, dev1Value)));
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        
        // bool buySignal = (trend[pos] == 1) && (trend[pos + 1] == (-1)) && SafeGreater(cci, 100) && (PineStrategy::GetPositionSize() == 0);
        // bool buySignal = (trend[pos] == 1) && (trend[pos + 1] == (-1)) && SafeGreater(cci, 100);
        bool buySignal = (trend[pos] == 1) && (trend[pos + 1] == (-1));
        
        if (pos + 1 > (rates_total - 1)) {
            continue;
        }
        
        // bool sellSignal = (trend[pos] == (-1)) && (trend[pos + 1] == 1) && SafeLess(cci, (-100)) && (PineStrategy::GetPositionSize() == 0);
        // bool sellSignal = (trend[pos] == (-1)) && (trend[pos + 1] == 1) && SafeLess(cci, (-100));
        bool sellSignal = (trend[pos] == (-1)) && (trend[pos + 1] == 1);

      // NOTE: signals
        if (buySignal && (pos > 0)) {
            ArrowUp[pos] = low[pos];
            PineStrategy::Entry(_signaler, "Long", true);
            PineStrategy::Exit(_signaler, "exit", NULL);
        }
        if (sellSignal && (pos > 0)) {
            ArrowDn[pos] = high[pos];
            PineStrategy::Entry(_signaler, "Short", false);
            PineStrategy::Exit(_signaler, "exit", NULL);
        }
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