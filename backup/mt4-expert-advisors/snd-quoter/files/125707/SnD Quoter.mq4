// Id: 24667
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68330

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
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 6
#property strict
enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8, Quoter=9, Year=10 };
input e_cycles       BTF                        = Min_240;
ENUM_TIMEFRAMES       TimeFrame                        = PERIOD_CURRENT;
input bool                  DrawZones                        = true;
input bool                  SolidZones                       = true;
input bool                  SolidRetouch                     = false;
input bool                  RecolorRetouch                   = true;
input bool                  RecolorWeakRetouch               = false;
input bool                  ZoneStrength                     = true;
input bool                  NoWeakZones                      = true;
input bool                  DrawEdgePrice                    = true;
input int                   ZoneWidth                        = 2;
input bool                  ZoneFibs                         = false;
input int                   FibStyle                         = 0;
input bool                  HUDOn                            = true;
input int                   LayerZone                        = 0;
input bool                  AlertOn                          = true;
input bool                  AlertPopup                       = true;
input string                AlertSound                       = "alert.wav";
input color                 ColorSupStrong                   = clrDarkGreen;
input color                 ColorSupWeak                     = clrSlateBlue;
input color                 ColorSupRetouch                  = clrSteelBlue;
input color                 ColorDemStrong                   = clrDarkRed;
input color                 ColorDemWeak                     = clrLightCoral;
input color                 ColorDemRetouch                  = clrSaddleBrown;
input color                 ColorFib                         = clrDodgerBlue;
input color                 ColorHUDTF                       = clrNavy;
input color                 ColorArrowUp                     = clrSeaGreen;
input color                 ColorArrowDn                     = clrCrimson;
input color                 ColorTimerBack                   = clrDarkGray;
input color                 ColorTimerBar                    = clrRed;
input color                 ColorShadow                      = clrDarkSlateGray;
input bool                  LimitZoneVis                     = false;
input bool                  SameTFVis                        = true;
input bool                  ShowOnM1                         = false;
input bool                  ShowOnM5                         = true;
input bool                  ShowOnM15                        = false;
input bool                  ShowOnM30                        = false;
input bool                  ShowOnH1                         = false;
input bool                  ShowOnH4                         = false;
input bool                  ShowOnD1                         = false;
input bool                  ShowOnW1                         = false;
input bool                  ShowOnMN                         = false;
input int                   PriceWidth                       = 1;
input int                   TimeOffset                       = 0;
input bool                  GlobalVars                       = false;

double BufferSupport1[];
double BufferResistance1[];

double SupRR[4];
double DemRR[4];
double SupWidth,DemWidth;

string lzone;
int LayerZone0;
int ArrowUP = 0x70;
int ArrowDN = 0x71;
string FontArrow = "WingDings 3";
int FontArrowSize = 40;
int FontPairSize = 8;

int visible;
int lenbase;
string s_base="|||||||||||||||||||||||";
string TimerFont="Arial";
int SizeTimerFont=8;

int iPeriod = 3; 
int Dev = 2;
int Step = 2;
double p1,p2;
string pair;
double point;
int digits;
string TAG;

double FibSup,FibDem;
int SupCount,DemCount;
int SupAlert,DemAlert;
double UpCur,DnCur;
double FibLevelArray[13]={0,0.236,0.386,0.5,0.618,0.786,1,1.276,1.618,2.058,2.618,3.33,4.236};
string FibLevelDesc[13]={"0","23.6%","38.6%","50%","61.8%","78.6%","100%","127.6%","161.8%","205.8%","261.80%","333%","423.6%"};

int HUDtimersX,HUDtimersY;

// Stream v.1.1
interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

struct CandleData
{
   double Open;
   double High;
   double Low;
   double Close;
   datetime Date;
};

interface IBarStreamIterator
{
public:
   virtual bool Next() = 0;
   virtual IBarStreamIterator *CreateForwardIterator() = 0;
   virtual IBarStreamIterator *CreateReverseIterator() = 0;

   virtual datetime GetDate() = 0;

   virtual double GetOpen() = 0;
   virtual double GetHigh() = 0;
   virtual double GetLow() = 0;
   virtual double GetClose() = 0;
   virtual void GetData(CandleData &candle) = 0;
};

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual double GetOpen(const int period, double &open) = 0;
   virtual double GetHigh(const int period, double &high) = 0;
   virtual double GetLow(const int period, double &low) = 0;
   virtual double GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;

   virtual IBarStreamIterator *CreateForwardIterator() = 0;
   virtual IBarStreamIterator *CreateReverseIterator() = 0;
};

class BarStreamIterator : public IBarStreamIterator 
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _index;
   bool _forward;
public:
   BarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const bool forward)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _index = -1;
      _forward = forward;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _index);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _index);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, _index);
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, _index);
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _index);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = iTime(_symbol, _timeframe, _index);
      candle.Open = iOpen(_symbol, _timeframe, _index);
      candle.High = iHigh(_symbol, _timeframe, _index);
      candle.Low = iLow(_symbol, _timeframe, _index);
      candle.Close = iClose(_symbol, _timeframe, _index);
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, true);
      copy._index = _index;
      if (!copy.MoveBackward())
         copy._index = -1;
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, false);
      copy._index = _index;
      if (!copy.MoveForward())
         copy._index = -1;
      return copy;
   }
   
   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_index == 0)
         return false;
      if (_index == -1)
         _index = iBars(_symbol, _timeframe) - 1;
      else
         --_index;
      return true;
   }

   bool MoveBackward()
   {
      if (iBars(_symbol, _timeframe) - 1 <= _index)
         return false;
      ++_index;
      return true;
   }
};

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      return new BarStreamIterator(_symbol, _timeframe, true);
   }

   virtual IBarStreamIterator *CreateReverseIterator()
   {
      return new BarStreamIterator(_symbol, _timeframe, false);
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

   virtual double GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetClose(const int period, double &close)
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

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) < iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh() { }
};

class CandleBodyBarStream : public IBarStream
{
   IBarStream *_source;
public:
   CandleBodyBarStream(IBarStream *source)
   {
      _source = source;
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _source.GetValue(period, val);
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (!_source.GetValues(period, open, high, low, close))
         return false;

      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      double open, close;
      if (!_source.GetValues(period, open, high, low, close))
         return false;
      
      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      return _source.GetIsAscending(period, res);
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      return _source.GetIsDescending(period, res);
   }
};

class CustomTimeframeBarStreamIterator : public IBarStreamIterator
{
private:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   int _startIndex;
   int _endIndex;
   bool _forward;
public:
   CustomTimeframeBarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const int timeframeMult, const bool forward)
   {
      _forward = forward;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
      _startIndex = -1;
      _endIndex = -1;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _startIndex);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _startIndex);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, iHighest(_symbol, _timeframe, MODE_HIGH, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, iLowest(_symbol, _timeframe, MODE_LOW, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _endIndex);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = GetDate();
      candle.Open = GetOpen();
      candle.High = GetHigh();
      candle.Low = GetLow();
      candle.Close = GetClose();
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, true);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, false);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }

   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_endIndex == 0)
         return false;
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      if (_startIndex == -1)
      {
         datetime barStart = (Time[iBars(_symbol, _timeframe)] / periodLength) * periodLength;
         _startIndex = iBarShift(_symbol, _timeframe, barStart);
         if (_startIndex == -1)
         {
            barStart += periodLength;
            _startIndex = iBarShift(_symbol, _timeframe, barStart);
            if (_startIndex == -1)
               return false;
         }
         _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
         return true;
      }
      --_endIndex;
      
      datetime barStart = (Time[_endIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }

   bool MoveBackward()
   {
      int maxIndex = iBars(_symbol, _timeframe) - 1;
      if (maxIndex <= _startIndex)
         return false;
      ++_startIndex;

      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      datetime barStart = (Time[_startIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      if (_startIndex == -1)
      {
         _startIndex = maxIndex;
         return false;
      }
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }
};

class CustomTimeframeBarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   
   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _size = 0;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      return new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, true);
   }

   virtual IBarStreamIterator *CreateReverseIterator()
   {
      return new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, false);
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual double GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual double GetClose(const int period, double &close)
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

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
      {
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);
      }
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, _timeframe, i) / periodLength) * periodLength;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, _timeframe, i);
            _high[_size - 1] = iHigh(_symbol, _timeframe, i);
            _low[_size - 1] = iLow(_symbol, _timeframe, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, _timeframe, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, _timeframe, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, _timeframe, i);
         while (barStart == _dates[_size - 1] && i >= 0)
         {
            barStart = (iTime(_symbol, _timeframe, --i) / periodLength) * periodLength;
         }
      }
   }
};

class TakeIterator : public IBarStreamIterator
{
   IBarStreamIterator *_iter;
   int _take;
   int _taken;
public:
   TakeIterator(IBarStreamIterator *iter, const int take)
   {
      _iter = iter;
      _take = take;
      _taken = 0;
   }
   ~TakeIterator()
   {
      delete _iter;
   }

   virtual bool Next()
   {
      if (_taken == 0)
      {
         ++_taken;
         return _iter.Next();   
      }
      if (_taken == _take)
         return false;
      if (!_iter.Next())
         return false;
      ++_taken;
      return true;
   }
   virtual IBarStreamIterator *CreateForwardIterator() { return NULL; }
   virtual IBarStreamIterator *CreateReverseIterator() { return NULL; }
   virtual datetime GetDate() { return _iter.GetDate(); }
   virtual double GetOpen() { return _iter.GetOpen(); }
   virtual double GetHigh() { return _iter.GetHigh(); }
   virtual double GetLow() { return _iter.GetLow(); }
   virtual double GetClose() { return _iter.GetClose(); }
   virtual void GetData(CandleData &candle) { _iter.GetData(candle); }
};

class BarStreamIteratorWrapper : public IBarStreamIterator
{
   IBarStream *_stream;
   int _index;
public:
   BarStreamIteratorWrapper(IBarStream *stream, const int start)
   {
      _stream = stream;
      _index = start - 1;
   }
   virtual bool Next()
   {
      if (_stream.Size() - 1 <= _index)
         return false;
      ++_index;
      return true;
   }

   virtual IBarStreamIterator *CreateForwardIterator() { return NULL; }
   virtual IBarStreamIterator *CreateReverseIterator() { return NULL; }

   virtual datetime GetDate()
   {
      datetime dt;
      if (!_stream.GetDate(_index, dt))
         return 0;
      return dt;
   }

   virtual double GetOpen()
   {
      double val;
      if (!_stream.GetOpen(_index, val))
         return 0;
      return val;
   }

   virtual double GetHigh()
   {
      double val;
      if (!_stream.GetHigh(_index, val))
         return 0;
      return val;
   }

   virtual double GetLow()
   {
      double val;
      if (!_stream.GetLow(_index, val))
         return 0;
      return val;
   }

   virtual double GetClose()
   {
      double val;
      if (!_stream.GetClose(_index, val))
         return 0;
      return val;
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = GetDate();
      candle.Open = GetOpen();
      candle.High = GetHigh();
      candle.Low = GetLow();
      candle.Close = GetClose();
   }
};

class Linq
{
   IBarStreamIterator *_iter;
public:
   Linq(IBarStreamIterator *iter)
   {
      _iter = iter.CreateForwardIterator();
   }

   Linq(IBarStream *stream, const int start = 0)
   {
      _iter = new BarStreamIteratorWrapper(stream, start);
   }

   ~Linq()
   {
      delete _iter;
   }

   Linq *Take(const int count)
   {
      _iter = new TakeIterator(_iter, count);
      return &this;
   }

   double Highest()
   {
      double highest = -DBL_MAX;
      while (_iter.Next())
      {
         double high = _iter.GetHigh();
         if (highest < high)
            highest = high;
      }
      return highest;
   }

   double Lowest()
   {
      double lowest = DBL_MAX;
      while (_iter.Next())
      {
         double low = _iter.GetLow();
         if (lowest > low)
            lowest = low;
      }
      return lowest;
   }
};

IBarStream *_data;

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


void OnInit()
{
   switch (BTF)
   {
      case Min_5:
         _data = new BarStream(_Symbol, PERIOD_M5);
         TimeFrame = PERIOD_M5;
         break;
      case Min_15:
         _data = new BarStream(_Symbol, PERIOD_M15);
         TimeFrame = PERIOD_M15;
         break;
      case Min_30:
         _data = new BarStream(_Symbol, PERIOD_M30);
         TimeFrame = PERIOD_M30;
         break;
      case Min_60: 
         _data = new BarStream(_Symbol, PERIOD_H1);
         TimeFrame = PERIOD_H1;
         break;
      case Min_240:
         _data = new BarStream(_Symbol, PERIOD_H4);
         TimeFrame = PERIOD_H4;
         break;
      case Daily:
         _data = new BarStream(_Symbol, PERIOD_D1);
         TimeFrame = PERIOD_D1;
         break;
      case Weekly:
         _data = new BarStream(_Symbol, PERIOD_W1);
         TimeFrame = PERIOD_W1;
         break;
      case Monthly:
         _data = new BarStream(_Symbol, PERIOD_MN1);
         TimeFrame = PERIOD_MN1;
         break;
      case Quoter:
         _data = new CustomTimeframeBarStream(_Symbol, PERIOD_MN1, 3);
         TimeFrame = PERIOD_MN1;
         break;
      case Year:
         _data = new CustomTimeframeBarStream(_Symbol, PERIOD_MN1, 12);
         TimeFrame = PERIOD_MN1;
         break;
   }

   IndicatorName = GenerateIndicatorName("SnD Quoter");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   LayerZone0=MathMin(LayerZone,25);   
   lzone = CharToStr((uchar)(0x61+LayerZone0));
   pair=Symbol(); 
     
   point = Point;
   digits = (int)MarketInfo(Symbol(), MODE_DIGITS);  //Digits;
   if(digits == 3 || digits == 5) point*=10;
   
   if(HUDOn && !DrawZones) 
      TAG = "II_HUD" + IntegerToString(BTF);
   else 
      TAG = "II_SupDem" + IntegerToString(BTF);
   lenbase=StringLen(s_base);
   
   if(LimitZoneVis) setVisibility();
   ObDeleteObjectsByPrefix(lzone+TAG);
}

void OnDeinit(const int reason)
{
   delete _data;
   ObDeleteObjectsByPrefix(lzone+TAG);
   Comment("");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return;
}

int start()
{
   _data.Refresh();
   ArrayResize(BufferResistance1, _data.Size());
   ArrayResize(BufferSupport1, _data.Size());
   if (NewBar())
   {
      SupAlert = 1;
      DemAlert = 1;
      ObDeleteObjectsByPrefix(lzone+TAG);
      CountZZ(iPeriod, Dev, Step);
      GetValid();
      Draw();
   }
   if(AlertOn)
      CheckAlert();
   return(0);
}

void CheckAlert()
{
   double price = ObjectGet(IndicatorObjPrefix + lzone+TAG+"UPAR"+ IntegerToString(SupAlert), OBJPROP_PRICE1);
   if(Close[0] > price && price > point){
      if(AlertPopup) Alert(pair+" "+TimeFrameToString(BTF)+" Supply Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(AlertSound);
      SupAlert++;
   }
   price = ObjectGet(IndicatorObjPrefix + lzone+TAG+"DNAR"+ IntegerToString(DemAlert), OBJPROP_PRICE1);
   if(Close[0] < price){
      Alert(pair+" "+TimeFrameToString(BTF)+" Demand Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(AlertSound);
      DemAlert++;
   }
}

int CountWeakLow(const double val, const int i, const bool retouch, bool &draw, color &c)
{
   if(ZoneStrength && (retouch || !RecolorRetouch))
   {
      int countstrong=0;
      int countweak=0;
      for (int j = i; j < 1000000; j++)
      {
         double low;
         if (!_data.GetLow(j + 1, low))
            return 0;
         if (low > p2) 
            countstrong++;
         if (low < val) 
            countweak++;
         if (countstrong > 1) 
            return countweak;
         else if (countweak > 1)
         {
            if (NoWeakZones) 
               draw = false;
            c = ColorDemWeak;
            return countweak;
         }                 
      }
   }
   return 0;
}

int CountWeakHigh(const double val, const int i, const bool retouch, bool &draw, color &c)
{
   if(ZoneStrength && (retouch || !RecolorRetouch))
   {
      int countstrong=0;
      int countweak=0;
      for (int j = i; j < 1000000; j++)
      {
         double high;
         if (!_data.GetHigh(j + 1, high))
            return 0;
         if (high < p2) 
            countstrong++;
         if (high > val) 
            countweak++;
         if (countstrong > 1) 
            return countweak;
         else if (countweak > 1)
         {
            c=ColorSupWeak;
            if (NoWeakZones) 
               draw = false;
            return countweak;
         }                 
      }
   }
   return 0;
}

void DrawPrice(const string s, const color c)
{
   ObjectCreate(IndicatorObjPrefix + s,OBJ_ARROW,0,0,0);
   ObjectSet(IndicatorObjPrefix + s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
   ObjectSet(IndicatorObjPrefix + s, OBJPROP_TIME1, Time[0]);
   ObjectSet(IndicatorObjPrefix + s, OBJPROP_PRICE1, p2);
   ObjectSet(IndicatorObjPrefix + s,OBJPROP_COLOR,c);
   ObjectSet(IndicatorObjPrefix + s,OBJPROP_WIDTH,PriceWidth);
   if(LimitZoneVis) 
      ObjectSet(IndicatorObjPrefix + s,OBJPROP_TIMEFRAMES,visible);
}

bool RetouchHigh(const int i, bool &draw)
{
   if (RecolorRetouch || !SolidRetouch)
   {
      bool exit = false;
      for (int j = i; j >= 0; j--)
      {
         double high;
         if (!_data.GetHigh(j, high))
            return false;
         if (!exit && high < p2) 
         {
            exit=true; 
            continue;
         }
         if(exit && high > p2) 
         {
            if(ZoneFibs && FibSup == 0)
               FibSup = p2;
            return true;
         }
      }
      if (!exit)
         draw = false;
   }
   return false;
}

bool RetouchLow(const int i, bool &draw)
{
   if (RecolorRetouch || !SolidRetouch)
   {
      bool exit = false;
      for (int j = i; j >= 0; j--)
      {
         double low;
         if (!_data.GetLow(j, low))
            return false;
         if (!exit && low > p2)
         {
            exit = true;
            continue;
         }
         if (exit && low < p2)
         {
            if (ZoneFibs && FibDem == 0)
               FibDem = p2;
            return true;
         }
      }
      if (!exit)
         draw = false;
   }
   return false;
}

void Draw()
{
   int sc=0,dc=0; 
   double val;
   bool fhe=false;
   bool fle=false;
   SupCount=0;
   DemCount=0;
   FibSup=0;
   FibDem=0;
   int index = 0;
   for (int i = 0; i < _data.Size(); i++)
   {
      datetime dt;
      if (!_data.GetDate(i, dt))
         continue;
      if (BufferResistance1[_data.Size() - 1 - i] > point)
      {
         double open, close;
         if (!_data.GetOpen(i, open) || !_data.GetClose(i, close))
            continue;
         p2 = MathMin(open, close);
         if (i > 0)
         {
            double low1, low2;
            if (!_data.GetOpen(i - 1, low1) || !_data.GetClose(i + 1, low2))
               continue;
            p2 = MathMax(p2, MathMax(open, close));
            if (!_data.GetOpen(i - 1, open) || !_data.GetClose(i - 1, close))
               continue;
            p2 = MathMax(p2, MathMin(open, close));
         }
         if (!_data.GetOpen(i + 1, open) || !_data.GetClose(i + 1, close))
            continue;
         p2 = MathMax(p2, MathMin(open, close));
         
         bool draw = true;
         bool retouch = RetouchHigh(i, draw);
         if (SupCount != 0) 
            val = ObjectGet(IndicatorObjPrefix + TAG+"UPZONE"+ IntegerToString(SupCount), OBJPROP_PRICE2); //final sema cull
         else 
            val = 0;
         if (draw && BufferResistance1[_data.Size() - 1 - i] != val) 
         {
            color c = ColorSupStrong;
            int countweak = CountWeakHigh(BufferResistance1[_data.Size() - 1 - i], i, retouch, draw, c);
            if(DrawZones && draw)
            {
               if(RecolorRetouch && retouch && countweak<2) 
                  c = ColorSupRetouch;
               else if(RecolorWeakRetouch && retouch && countweak>1) 
                  c = ColorSupRetouch;
               SupCount++;
               if(DrawEdgePrice)
                  DrawPrice(lzone+TAG+"UPAR"+IntegerToString(SupCount), c);
               string s = IndicatorObjPrefix + lzone+TAG+"UPZONE"+IntegerToString(SupCount);
               ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
               ObjectSet(s,OBJPROP_TIME1, dt);
               ObjectSet(s,OBJPROP_PRICE1,BufferResistance1[_data.Size() - 1 - i]);
               ObjectSet(s,OBJPROP_TIME2,Time[0]);
               ObjectSet(s,OBJPROP_PRICE2,p2);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_BACK,true);
               if(LimitZoneVis) 
                  ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
               if(!SolidZones)
               {
                  ObjectSet(s,OBJPROP_BACK,false);
                  ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);
               }
               if(!SolidRetouch && retouch)
               {
                  ObjectSet(s,OBJPROP_BACK,false);
                  ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);
               }
               if(GlobalVars)
               {
                  GlobalVariableSet(TAG+"S.PH"+IntegerToString(SupCount), BufferResistance1[_data.Size() - 1 - i]);
                  GlobalVariableSet(TAG+"S.PL"+IntegerToString(SupCount),p2);
                  GlobalVariableSet(TAG+"S.T"+IntegerToString(SupCount), dt);
               }
               if(!fhe && c!=ColorDemRetouch)
               {
                  fhe=true;
                  GlobalVariableSet(TAG+"GOSHORT",p2);
               }
            }
            if(draw && sc<4 && HUDOn)
            {
               if(sc==0)
                  SupWidth = BufferResistance1[_data.Size() - 1 - i] - p2;
               SupRR[sc] = p2;
               sc++;
            }
         }
      }
      
      if (BufferSupport1[_data.Size() - 1 - i] > point)
      {
         double open, close;
         if (!_data.GetOpen(i, open) || !_data.GetClose(i, close))
            continue;
         p2 = MathMax(open, close);
         if (i > 0)
         {
            double high1, high2;
            if (!_data.GetHigh(i - 1, high1) || !_data.GetHigh(i + 1, high2))
               continue;
            p2 = MathMin(p2, MathMin(high1, high2));
            if (!_data.GetOpen(i - 1, open) || !_data.GetClose(i - 1, close))
               continue;
            p2 = MathMin(p2, MathMax(open, close));
         }
         if (!_data.GetOpen(i + 1, open) || !_data.GetClose(i + 1, close))
            continue;
         p2 = MathMin(p2, MathMax(open, close));
         
         bool draw = true;
         bool retouch = RetouchLow(i, draw);
         if (DemCount != 0) 
            val = ObjectGet(TAG+"DNZONE"+IntegerToString(DemCount),OBJPROP_PRICE2); //final sema cull
         else 
            val=0;
         if(draw && BufferSupport1[_data.Size() - 1 - i]!=val)
         {
            color c = ColorDemStrong;
            int countweak = CountWeakLow(BufferSupport1[_data.Size() - 1 - i], i, retouch, draw, c);
            if(DrawZones && draw)
            {
               if(RecolorRetouch && retouch && countweak<2) 
                  c = ColorDemRetouch;
               else if(RecolorWeakRetouch && retouch && countweak>1) 
                  c = ColorDemRetouch;

               DemCount++;
               if(DrawEdgePrice)
                  DrawPrice(lzone+TAG+"DNAR"+IntegerToString(DemCount), c);
               string s = IndicatorObjPrefix + lzone+TAG+"DNZONE"+IntegerToString(DemCount);
               ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
               ObjectSet(s,OBJPROP_TIME1, dt);
               ObjectSet(s,OBJPROP_PRICE1,p2);
               ObjectSet(s,OBJPROP_TIME2,Time[0]);
               ObjectSet(s,OBJPROP_PRICE2,BufferSupport1[_data.Size() - 1 - i]);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_BACK,true);
               if(LimitZoneVis)
                  ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
               if(!SolidZones)
               {
                  ObjectSet(s,OBJPROP_BACK,false);
                  ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);
               }
               if(!SolidRetouch && retouch)
               {
                  ObjectSet(s,OBJPROP_BACK,false);
                  ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);
               }
               if(GlobalVars)
               {
                  GlobalVariableSet(TAG+"D.PL"+IntegerToString(DemCount),BufferSupport1[_data.Size() - 1 - i]);
                  GlobalVariableSet(TAG+"D.PH"+IntegerToString(DemCount),p2);
                  GlobalVariableSet(TAG+"D.T"+IntegerToString(DemCount), dt);
               }
               if(!fle && c!=ColorDemRetouch)
               {
                  fle=true;
                  GlobalVariableSet(TAG+"GOLONG",p2);
               }
            }
            if(draw && dc<4 && HUDOn)
            {
               if(dc==0) 
                  DemWidth = p2-BufferSupport1[_data.Size() - 1 - i];
               DemRR[dc] = p2;
               dc++;
            }
         }
      }
      ++index;
   }
   if (ZoneFibs)
      DrawFibZone();
}

void DrawFibZone()
{
   int dr=0;
   int sr=0;
   double a,b;
   int i = 0;
   IBarStreamIterator *it = _data.CreateReverseIterator();
   while (it.Next())
   {
      if (it.GetHigh() > FibSup && sr==0) 
         sr = i;
      if (it.GetLow() < FibDem && dr==0) 
         dr = i;
      if (sr != 0 && dr != 0) 
         break;
      ++i;
   }
   delete it;
   if(dr<sr)
   {
      b = FibDem;
      a = SupRR[0];
   }
   else
   {
      b = FibSup;
      a = DemRR[0];
   }

   string s = IndicatorObjPrefix + lzone+TAG+"FIBO";
   ObjectCreate(s, OBJ_FIBO, 0,Time[0],a,Time[0],b);
   ObjectSet(s, OBJPROP_COLOR, CLR_NONE);
   ObjectSet(s, OBJPROP_STYLE, FibStyle);
   ObjectSet(s, OBJPROP_RAY, true);
   ObjectSet(s, OBJPROP_BACK, true);
   if(LimitZoneVis) 
      ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
   int level_count=ArraySize(FibLevelArray);

   ObjectSet(s, OBJPROP_FIBOLEVELS, level_count);
   ObjectSet(s, OBJPROP_LEVELCOLOR, ColorFib);

   for(int j=0; j<level_count; j++)
   {
      ObjectSet(s, OBJPROP_FIRSTLEVEL+j, FibLevelArray[j]);
      ObjectSetFiboDescription(s,j,FibLevelDesc[j]);
   }
}

bool NewBar() 
{
	static datetime LastTime = 0;
   datetime dt;
   if (!_data.GetDate(0, dt))
      return false;
   if (dt + TimeOffset != LastTime)
   {
		LastTime = dt + TimeOffset;		
		return (true);
	} 
   
   return (false);
}

void ObDeleteObjectsByPrefix(string Prefix){
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal()) {
      string ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix) {
         i++;
         continue;
      }
      ObjectDelete(ObjName);
   }
}

void CountZZ(int ExtDepth, int ExtDeviation, int ExtBackstep )
{
   int    t1, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh;
   double lasthigh = 0;
   double lastlow = 0;
   int count = _data.Size() - 1 - ExtDepth;

   for (t1 = count; t1>=0; t1--)
   {
      double low;
      if (!_data.GetLow(t1, low))
         continue;
      Linq linq(_data, t1);
      val = linq.Take(ExtDepth).Lowest();
      if(val==lastlow) 
         val=0.0;
      else
      { 
         lastlow = val; 
         if (low - val > ExtDeviation * point) 
            val = 0.0;
         else
         {
            for(back=1; back<=ExtBackstep; back++)
            {
               res=BufferSupport1[_data.Size() - 1 - (t1+back)];
               if((res!=0)&&(res>val)) 
                  BufferSupport1[_data.Size() - 1 - (t1+back)]=0.0; 
            }
         }
      } 

      BufferSupport1[_data.Size() - 1 - t1]=val;
      double high;
      if (!_data.GetHigh(t1, high))
         continue;
      Linq linq2(_data, t1);
      val = linq2.Take(ExtDepth).Highest();
      if(val==lasthigh)
         val=0.0;
      else 
      {
         lasthigh=val;
         if (val - high > ExtDeviation * point) 
            val=0.0;
         else
         {
            for(back=1; back<=ExtBackstep; back++)
            {
               res=BufferResistance1[_data.Size() - 1 - (t1+back)];
               if((res!=0)&&(res<val)) 
                  BufferResistance1[_data.Size() - 1 - (t1+back)]=0.0; 
            } 
         }
      }
      BufferResistance1[_data.Size() - 1 - t1]=val;
   }
   // final cutting 
   lasthigh=-1;
   lasthighpos=-1;
   lastlow=-1;
   lastlowpos=-1;

   for(t1=count; t1>=0; t1--)
   {
      curlow=BufferSupport1[_data.Size() - 1 - t1];
      curhigh=BufferResistance1[_data.Size() - 1 - t1];
      if((curlow==0)&&(curhigh==0)) 
         continue;
      //---
      if(curhigh!=0){
         if(lasthigh>0) {
            if(lasthigh<curhigh) BufferResistance1[_data.Size() - 1 - lasthighpos]=0;
            else BufferResistance1[_data.Size() - 1 - t1]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0){
            lasthigh=curhigh;
            lasthighpos=t1;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0){
         if(lastlow>0){
            if(lastlow>curlow) BufferSupport1[_data.Size() - 1 - lastlowpos]=0;
            else BufferSupport1[_data.Size() - 1 - t1]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0)){
            lastlow=curlow;
            lastlowpos=t1;
           } 
         lasthigh=-1;
        }
     }
}
 
void GetValid()
{
   UpCur = 0;
   int upbar = 0;
   DnCur = 0;
   int dnbar = 0;
   double CurHi = 0;
   double CurLo = 0;
   double LastUp = 0;
   double LastDn = 0;
   double LowDn = 0;
   double HiUp = 0;
   int i;
   for(i=0;i<_data.Size(); i++)
   {
      if(BufferSupport1[_data.Size() - 1 - i] > 0)
      {
         UpCur = BufferSupport1[_data.Size() - 1 - i];
         CurLo = BufferSupport1[_data.Size() - 1 - i];
         LastUp = CurLo;
         break;
      }
   }
   for (i = 0; i < _data.Size(); i++)
   {
      if(BufferResistance1[_data.Size() - 1 - i] > 0)
      {
         DnCur = BufferResistance1[_data.Size() - 1 - i];
         CurHi = BufferResistance1[_data.Size() - 1 - i];
         LastDn = CurHi;
         break;
      }
   }

   for (i = 0; i < _data.Size(); i++) // remove higher lows and lower highs
   {
      if(BufferResistance1[_data.Size() - 1 - i] >= LastDn) 
      {
         LastDn = BufferResistance1[_data.Size() - 1 - i];
         dnbar = i;
      }
      else 
         BufferResistance1[_data.Size() - 1 - i] = 0.0;
      if (BufferResistance1[_data.Size() - 1 - i] <= DnCur && BufferSupport1[_data.Size() - 1 - i] > 0.0)
         BufferResistance1[_data.Size() - 1 - i] = 0.0;
      if (BufferSupport1[_data.Size() - 1 - i] <= LastUp && BufferSupport1[_data.Size() - 1 - i] > 0)
      {
         LastUp = BufferSupport1[_data.Size() - 1 - i];
         upbar = i;
      }
      else 
         BufferSupport1[_data.Size() - 1 - i] = 0.0;
      if (BufferSupport1[_data.Size() - 1 - i] > UpCur) 
         BufferSupport1[_data.Size() - 1 - i] = 0.0;
   }
   double open, close;
   if (!_data.GetOpen(dnbar, open) || !_data.GetClose(dnbar, close))
      return;
   LowDn = MathMin(open, close);
   if (!_data.GetOpen(upbar, open) || !_data.GetClose(upbar, close))
      return;
   HiUp = MathMax(open, close);         
   for (i=MathMax(upbar,dnbar);i>=0;i--)
   {
      // work back to zero and remove reentries into s/d
      if(BufferResistance1[_data.Size() - 1 - i] > LowDn && BufferResistance1[_data.Size() - 1 - i] != LastDn)
         BufferResistance1[_data.Size() - 1 - i] = 0.0;
      else if(BufferResistance1[_data.Size() - 1 - i] > 0) 
      {
         LastDn = BufferResistance1[_data.Size() - 1 - i];
         if (!_data.GetOpen(i, open) || !_data.GetClose(i, close))
            continue;
         LowDn = MathMin(open, close);
         if (i > 0)
         {
            double low, low2;
            if (!_data.GetLow(i - 1, low) || !_data.GetLow(i + 1, low2))
               continue;
            LowDn = MathMax(LowDn,MathMax(low, low2));
            if (!_data.GetOpen(i - 1, open) || !_data.GetClose(i - 1, close))
               continue;
            LowDn = MathMax(LowDn,MathMin(open, close));
         }
         if (!_data.GetOpen(i + 1, open) || !_data.GetClose(i + 1, close))
            continue;
         LowDn = MathMax(LowDn,MathMin(open, close));
      }
      if(BufferSupport1[_data.Size() - 1 - i] <= HiUp && BufferSupport1[_data.Size() - 1 - i] > 0 && BufferSupport1[_data.Size() - 1 - i] != LastUp)
         BufferSupport1[_data.Size() - 1 - i] = 0.0;
      else if(BufferSupport1[_data.Size() - 1 - i] > 0)
      {
         LastUp = BufferSupport1[_data.Size() - 1 - i];
         if (!_data.GetOpen(i, open) || !_data.GetClose(i, close))
            continue;
         HiUp = MathMax(open, close);
         if (i > 0)
         {
            double high, high2;
            if (!_data.GetHigh(i + 1, high) || !_data.GetHigh(i + 1, high2))
               continue;
            HiUp = MathMin(HiUp,MathMin(high, high2));
            if (!_data.GetOpen(i - 1, open) || !_data.GetClose(i - 1, close))
               continue;
            HiUp = MathMin(HiUp,MathMax(open, close));
         }
         if (!_data.GetOpen(i + 1, open) || !_data.GetClose(i + 1, close))
            continue;
         HiUp = MathMin(HiUp,MathMax(open, close));
      }
   }
}

string TimeFrameToString(int x1) //code by TRO
{
   switch(x1)
   {
      case Min_5:
         return "M5";
      case Min_15:
         return "M15";
      case Min_30:
         return "M30";
      case Min_60:
         return "H1";
      case Min_240:
         return "H4";
      case Daily:
         return "D1";
      case Weekly:
         return "W1";
      case Monthly:
         return "MN";
      case Quoter:
         return "Q";
      case Year:
         return "Y";
   }
   return "";
}

void setVisibility()
{
   int per = Period();
   visible=0;
   if(SameTFVis)
   {
  	   if(TimeFrame == per || TimeFrame == 0)
      {
  	      switch(per)
         {
            case PERIOD_M1:  visible= 0x0001 ; break;
            case PERIOD_M5:  visible= 0x0002 ; break;
            case PERIOD_M15: visible= 0x0004 ; break;
            case PERIOD_M30: visible= 0x0008 ; break;
            case PERIOD_H1:  visible= 0x0010 ; break;
            case PERIOD_H4:  visible= 0x0020 ; break;
            case PERIOD_D1:  visible= 0x0040 ; break;
            case PERIOD_W1:  visible= 0x0080 ; break;
            case PERIOD_MN1: visible= 0x0100 ;  	   
  	      }
  	   }
  	} 
   else 
   {
      if(ShowOnM1) visible += 0x0001;
      if(ShowOnM5) visible += 0x0002;
      if(ShowOnM15) visible += 0x0004;
      if(ShowOnM30) visible += 0x0008;
      if(ShowOnH1) visible += 0x0010;
      if(ShowOnH4) visible += 0x0020;
      if(ShowOnD1) visible += 0x0040;
      if(ShowOnW1) visible += 0x0080;
      if(ShowOnMN) visible += 0x0100;
   }
}