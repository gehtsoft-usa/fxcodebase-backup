// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71160


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

//-- External variables
extern int StPeriod   = 10;
input int HourStart = 17;
input int bars_limit = 1000;

//-- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];
double buff[];

// D1 custom hour bar stream v1.0
// ACustomBarStream v1.1

// IBarStream v1.2

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

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

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif

#ifndef ACustomBarStream_IMP
#define ACustomBarStream_IMP

class ACustomBarStream : public IBarStream
{
protected:
   int _references;

   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;

   ACustomBarStream()
   {
      _size = 0;
      _references = 1;
   }
public:
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

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      for (int i = 0; i < _size; ++i)
      {
         if (_dates[_size - 1 - i] <= date)
         {
            period = MathMax(i, 0);
            return true;
         }
      }
      return false;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
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
};
#endif
class D1CustomHourBarStream : public ACustomBarStream
{
   string _symbol;
   int _hour;
public:
   D1CustomHourBarStream(const string symbol, int hour)
   {
      _symbol = symbol;
      _hour = hour;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, PERIOD_H1) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, PERIOD_H1, _dates[_size - 1]);

      int periodLength = (int)PERIOD_H1 * 24 * 60;
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, PERIOD_H1, i) / periodLength) * periodLength + _hour * 3600;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, PERIOD_H1, i);
            _high[_size - 1] = iHigh(_symbol, PERIOD_H1, i);
            _low[_size - 1] = iLow(_symbol, PERIOD_H1, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, PERIOD_H1, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, PERIOD_H1, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, PERIOD_H1, i);
      }
   }
};


D1CustomHourBarStream* stream;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, FextMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,FextMapBuffer2);        
   IndicatorShortName("Stretch Breakout Channel ("+ StPeriod +")");
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, buff);

   stream = new D1CustomHourBarStream(_Symbol, HourStart);
   return 0;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   delete stream;
   stream = NULL;
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) 
      return(-1);

   stream.Refresh();
   int limit = MathMin(bars_limit, Bars - 1 - counted_bars);
   for(int pos = limit; pos >= 0; pos--)
   {
      int index;
      if (!stream.FindDatePeriod(Time[pos], index))
         continue;
      double sum = 0;
      for(int i = index + 1; i <= index + StPeriod; i++)
      {
         double open, high, low, close;
         if (!stream.GetValues(i, open, high, low, close))
            continue;
         double oh = MathAbs(high - open);
         double ol = MathAbs(open - low);
         if (ol < oh) 
            sum += ol; 
         else 
            sum += oh;
      }
      buff[pos] = sum / StPeriod;
      double stretch = iMAOnArray(buff, Bars, 12, 0, 2, pos);
      
      double OPEN;
      if (!stream.GetOpen(index, OPEN))
         continue;

      FextMapBuffer1[pos] = OPEN + stretch;
      FextMapBuffer2[pos] = OPEN - stretch;
   }
   return(0);
}