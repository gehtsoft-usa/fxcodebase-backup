#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern ENUM_TIMEFRAMES base_timeframe = PERIOD_CURRENT; // Base timeframe
extern int timeframe_count = 1; // Number of bars

double signal[];

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

interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;
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

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
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
};

class CandleBodyBarStream : public IBarStream
{
   IBarStream *_source;
public:
   CandleBodyBarStream(IBarStream *__source)
   {
      _source = __source;
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

class CustomTimeframeBarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
   }

   virtual bool GetValue(const int period, double &val)
   {
      int startIndex, endIndex;
      if (!GetPeriods(period, startIndex, endIndex))
         return false;

      val = iClose(_symbol, _timeframe, endIndex);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int startIndex, endIndex;
      if (!GetPeriods(period, startIndex, endIndex))
         return false;
      
      open = iOpen(_symbol, _timeframe, startIndex);
      high = iHigh(_symbol, _timeframe, startIndex);
      low = iLow(_symbol, _timeframe, startIndex);
      close = iClose(_symbol, _timeframe, endIndex);
      for (int i = startIndex - 1; i >= endIndex; --i)
      {
         high = MathMax(high, iHigh(_symbol, _timeframe, startIndex));
         low = MathMin(low, iLow(_symbol, _timeframe, startIndex));
      }

      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int startIndex, endIndex;
      if (!GetPeriods(period, startIndex, endIndex))
         return false;
      
      low = iLow(_symbol, _timeframe, startIndex);
      for (int i = startIndex - 1; i >= endIndex; --i)
      {
         high = MathMax(high, iHigh(_symbol, _timeframe, startIndex));
         low = MathMin(low, iLow(_symbol, _timeframe, startIndex));
      }
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      int startIndex, endIndex;
      if (!GetPeriods(period, startIndex, endIndex))
         return false;

      res = iOpen(_symbol, _timeframe, startIndex) < iClose(_symbol, _timeframe, endIndex);
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      int startIndex, endIndex;
      if (!GetPeriods(period, startIndex, endIndex))
         return false;

      res = iOpen(_symbol, _timeframe, startIndex) > iClose(_symbol, _timeframe, endIndex);
      return true;
   }
private:
   bool GetPeriods(const int period, int &start, int &end)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      datetime barStart = (Time[period] / periodLength) * periodLength;
      start = iBarShift(_symbol, _timeframe, barStart);
      end = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      if (start < end)
         end = start;
      return true;
   }
};

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class ASidewaysBias : public ICondition
{
protected:
   IBarStream *_source;
   ASidewaysBias(IBarStream *__source)
   {
      _source = __source;
   }

   bool GetMove(const int period, double &high, double &low, int &last)
   {
      bool currentDirection;
      if (!_source.GetIsAscending(period, currentDirection))
         return false;
      
      if (!_source.GetHighLow(period, high, low))
         return false;

      bool direction;
      last = period;
      while (_source.GetIsAscending(last + 1, direction))
      {
         if (direction == currentDirection)
            return true;
         
         ++last;

         double currentHigh, currentLow;
         if (!_source.GetHighLow(last, currentHigh, currentLow))
            return false;

         if (high == EMPTY_VALUE || high < currentHigh)
            high = currentHigh;
         if (low == EMPTY_VALUE || low > currentLow)
            low = currentLow;
      }
      return false;
   }
};

class SidewaysBiasDown : public ASidewaysBias
{
public:
   SidewaysBiasDown(IBarStream *__source) : ASidewaysBias(__source)
   {
   }

   virtual bool IsPass(const int period)
   {
      bool isDescending;
      if (!_source.GetIsDescending(period, isDescending) || !isDescending)
         return false;

      double anchorHigh, anchorLow;
      int anchorLast;
      if (!GetMove(period, anchorHigh, anchorLow, anchorLast))
         return false;

      double high, low;
      int last;
      if (!GetMove(anchorLast + 1, high, low, last))
         return false;

      bool confirmed = anchorLow < low;
      if (confirmed)
         return false;
      
      double nextHigh, nextLow;
      int nextLast;
      if (!GetMove(last + 1, nextHigh, nextLow, nextLast))
         return false;

      bool sideways = high < nextHigh && low > nextLow;
      if (!sideways)
         return false;

      double currentHigh, currentLow;
      while (_source.GetHighLow(++last, currentHigh, currentLow))
      {
         bool down = currentHigh > high;
         if (down)
            return true;
         bool up = currentLow < low;
         if (up)
            return false;
      }
      return false;
   }
};

class SidewaysBiasUp : public ASidewaysBias
{
public:
   SidewaysBiasUp(IBarStream *__source) : ASidewaysBias(__source)
   {
   }

   virtual bool IsPass(const int period)
   {
      bool isAscending;
      if (!_source.GetIsAscending(period, isAscending) || !isAscending)
         return false;

      double anchorHigh, anchorLow;
      int anchorLast;
      if (!GetMove(period, anchorHigh, anchorLow, anchorLast))
         return false;

      double high, low;
      int last;
      if (!GetMove(anchorLast + 1, high, low, last))
         return false;

      bool confirmed = anchorLow < low;
      if (confirmed)
         return false;
      
      double nextHigh, nextLow;
      int nextLast;
      if (!GetMove(last + 1, nextHigh, nextLow, nextLast))
         return false;

      bool sideways = high < nextHigh && low > nextLow;
      if (!sideways)
         return false;

      double currentHigh, currentLow;
      while (_source.GetHighLow(++last, currentHigh, currentLow))
      {
         bool up = currentLow < low;
         if (up)
            return true;
         bool down = currentHigh > high;
         if (down)
            return false;
      }
      return false;
   }
};

class SidewaysBiasDownConfirmed : public ASidewaysBias
{
public:
   SidewaysBiasDownConfirmed(IBarStream *__source) : ASidewaysBias(__source)
   {
   }

   virtual bool IsPass(const int period)
   {
      bool isDescending;
      if (!_source.GetIsDescending(period, isDescending) || !isDescending)
         return false;

      double anchorHigh, anchorLow;
      int anchorLast;
      if (!GetMove(period, anchorHigh, anchorLow, anchorLast))
         return false;

      double high, low;
      int last;
      if (!GetMove(anchorLast + 1, high, low, last))
         return false;

      bool confirmed = anchorLow < low;
      if (!confirmed)
         return false;
      
      double nextHigh, nextLow;
      int nextLast;
      if (!GetMove(last + 1, nextHigh, nextLow, nextLast))
         return false;

      bool sideways = high < nextHigh && low > nextLow;
      if (!sideways)
         return false;

      double currentHigh, currentLow;
      while (_source.GetHighLow(++last, currentHigh, currentLow))
      {
         bool down = currentHigh > high;
         if (down)
            return true;
         bool up = currentLow < low;
         if (up)
            return false;
      }
      return false;
   }
};

class SidewaysBiasUpConfirmed : public ASidewaysBias
{
public:
   SidewaysBiasUpConfirmed(IBarStream *__source) : ASidewaysBias(__source)
   {
   }

   virtual bool IsPass(const int period)
   {
      bool isAscending;
      if (!_source.GetIsAscending(period, isAscending) || !isAscending)
         return false;

      double anchorHigh, anchorLow;
      int anchorLast;
      if (!GetMove(period, anchorHigh, anchorLow, anchorLast))
         return false;

      double high, low;
      int last;
      if (!GetMove(anchorLast + 1, high, low, last))
         return false;

      bool confirmed = anchorLow < low;
      if (confirmed)
         return false;
      
      double nextHigh, nextLow;
      int nextLast;
      if (!GetMove(last + 1, nextHigh, nextLow, nextLast))
         return false;

      bool sideways = high < nextHigh && low > nextLow;
      if (!sideways)
         return false;

      double currentHigh, currentLow;
      while (_source.GetHighLow(++last, currentHigh, currentLow))
      {
         bool up = currentLow < low;
         if (up)
            return true;
         bool down = currentHigh > high;
         if (down)
            return false;
      }
      return false;
   }
};

IBarStream *mainStream;
CandleBodyBarStream *source;
SidewaysBiasDown *sidewaysBiasDown;
SidewaysBiasUp *sidewaysBiasUp;
SidewaysBiasDownConfirmed *sidewaysBiasDownConfirmed;
SidewaysBiasUpConfirmed *sidewaysBiasUpConfirmed;

int init()
{
   IndicatorName = GenerateIndicatorName("Sideways Bias");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 2);
   SetIndexBuffer(0, signal);

   if (timeframe_count == 1)
      mainStream = new BarStream(_Symbol, base_timeframe == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : base_timeframe);
   else
      mainStream = new CustomTimeframeBarStream(_Symbol, base_timeframe == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : base_timeframe, timeframe_count);

   source = new CandleBodyBarStream(mainStream);
   sidewaysBiasDown = new SidewaysBiasDown(source);
   sidewaysBiasUp = new SidewaysBiasUp(source);
   sidewaysBiasDownConfirmed = new SidewaysBiasDownConfirmed(source);
   sidewaysBiasUpConfirmed = new SidewaysBiasUpConfirmed(source);
   
   return(0);
}

int deinit()
{
   delete sidewaysBiasUpConfirmed;
   delete sidewaysBiasDownConfirmed;
   delete sidewaysBiasUp;
   delete sidewaysBiasDown;
   delete source;
   delete mainStream;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return(-1);
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      if (sidewaysBiasUp.IsPass(pos))
         signal[pos] = 1;
      else if (sidewaysBiasUpConfirmed.IsPass(pos))
         signal[pos] = 2;
      else if (sidewaysBiasDown.IsPass(pos))
         signal[pos] = -1;
      else if (sidewaysBiasDownConfirmed.IsPass(pos))
         signal[pos] = -2;

      pos--;
   } 
   return(0);
}

