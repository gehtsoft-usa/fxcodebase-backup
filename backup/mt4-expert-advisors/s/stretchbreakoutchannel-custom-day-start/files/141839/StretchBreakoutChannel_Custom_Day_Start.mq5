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


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict



#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

//-- External variables
input int StPeriod   = 10;
input int HourStart = 17;

input int bars_limit = 1000; // Bars limit

// D1 bar with custom start hour v1.0
// ACustomBarStream v1.1

// IBarStream v1.0

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
   virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

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
      if (period >= _size || period < 0)
         return false;
      val = _close[period];
      return true;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      for (int i = 0; i < _size; ++i)
      {
         if (_dates[i] >= date)
         {
            period = MathMax(i, 0);
            return true;
         }
      }
      return false;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size || period < 0)
         return false;
      dt = _dates[period];
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (_size <= period || period < 0)
         return false;
      open = _open[period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (_size <= period || period < 0)
         return false;
      high = _high[period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (_size <= period || period < 0)
         return false;
      low = _low[period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (_size <= period || period < 0)
         return false;
      close = _close[period];
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      if (period >= _size || period < 0)
         return false;

      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      if (period >= _size || period < 0)
         return false;

      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (period >= _size || period < 0)
         return false;
      high = _high[period];
      low = _low[period];
      open = _open[period];
      close = _close[period];
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (period >= _size || period < 0)
         return false;
      close = _close[period];
      open = _open[period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (period >= _size || period < 0)
         return false;
      high = _high[period];
      low = _low[period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (period >= _size || period < 0)
         return false;
      res = _open[period] < _close[period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (period >= _size || period < 0)
         return false;
      res = _open[period] > _close[period];
      return true;
   }

   virtual int Size()
   {
      return _size;
   }
};
#endif

#ifndef D1CustomHourBarStream_IMP
#define D1CustomHourBarStream_IMP

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

      int periodLength = 24 * 3600;
      for (int i = start; i >= 0; --i)
      {
         datetime h1Time = iTime(_symbol, PERIOD_H1, i);
         datetime barStart = (h1Time / periodLength) * periodLength + _hour * 3600;
         if (barStart > h1Time)
         {
            barStart -= 24 * 3600;
         }
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

#endif

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

//-- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];
double buff[];
double buff_ma[];

D1CustomHourBarStream* stream;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("StretchBreakoutChannel_Custom_Day_Start");
   IndicatorSetString(INDICATOR_SHORTNAME, "Stretch Breakout Channel ("+ StPeriod +")");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, FextMapBuffer1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   SetIndexBuffer(1, FextMapBuffer2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   SetIndexBuffer(2, buff, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, buff_ma, INDICATOR_CALCULATIONS);

   stream = new D1CustomHourBarStream(_Symbol, HourStart);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete stream;
   stream = NULL;
}
#include <MovingAverages.mqh>
void MAOnArray(const int rates_total, const int prev_calculated, int sourceFirst, ENUM_MA_METHOD method, int period, double& in[], double& out[])
{
   if (period == 1)
   {
      for (int pos = sourceFirst; pos < rates_total; ++pos)
      {
         out[pos] = in[pos];
      }
      return;
   }
   int weightsum;
   switch (method)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out, weightsum);
         break;
   }
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
   stream.Refresh();
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(buff, EMPTY_VALUE);
      ArrayInitialize(FextMapBuffer1, EMPTY_VALUE);
      ArrayInitialize(FextMapBuffer2, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;

      int index;
      if (!stream.FindDatePeriod(time[pos], index))
         continue;
      double sum = 0;
      for(int i = 1; i <= StPeriod; i++)
      {
         double open, high, low, close;
         if (!stream.GetValues(index - i, open, high, low, close))
            continue;
         double oh = MathAbs(high - open);
         double ol = MathAbs(open - low);
         if (ol < oh) 
            sum += ol; 
         else 
            sum += oh;
      }
      buff[pos] = sum / StPeriod;
   }

   MAOnArray(rates_total, prev_calculated, rates_total - bars_limit + 12, MODE_SMA, 12, buff, buff_ma);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      double OPEN;
      int index;
      if (!stream.FindDatePeriod(time[pos], index))
         continue;
      if (!stream.GetOpen(index, OPEN))
      {
         continue;
      }

      FextMapBuffer1[pos] = OPEN + buff_ma[pos];
      FextMapBuffer2[pos] = OPEN - buff_ma[pos];
   }
   return rates_total;
}