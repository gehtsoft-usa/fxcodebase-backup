// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=75351

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_plots   1
//
#property indicator_type1   DRAW_LINE

#property indicator_color1  clrRed
#property indicator_width1  2

#property indicator_label1  "CUMULATIVE OBV"
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
input PriceType InpAppliedPrice = PriceClose; // Applied price
input int                MaxBars = 500;               // Max bars
//
double                   ExtOBVBuffer[];
int ptf;
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
// CustomStream v2.0
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
class StreamBuffer
{
public:
   double _data[];

   void EnsureSize(int size)
   {
      int currentSize = ArrayRange(_data, 0);
      if (currentSize != size) 
      {
         ArrayResize(_data, size);
         for (int i = currentSize; i < size; ++i)
         {
            _data[i] = EMPTY_VALUE;
         }
      }
   }
};

class CustomStream : public AStream
{
   StreamBuffer _data;
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void SetValue(int period, double value)
   {
      _data.EnsureSize(Size());
      _data._data[period] = value;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      _data.EnsureSize(size);
      for (int i = 0; i < count; ++i)
      {
         double value = _data._data[size - 1 - period + i];
         if (value == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      _data.EnsureSize(Size());
      int bars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

// OBV on stream v1.0

#ifndef OBVStream_IMP
#define OBVStream_IMP

class OBVStream : public AOnStream
{
   StreamBuffer* _buffer;
   IStream *_volumeSource;
public:
   OBVStream(IStream *source, IStream *volumeSource)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _volumeSource.AddRef();
      _buffer = new StreamBuffer();
   }

   ~OBVStream()
   {
      _volumeSource.Release();
      delete _buffer;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      _buffer.EnsureSize(size);
      int pos = size - 1 - period;

      double prices[2];
      double vol[1];
      if (!_source.GetSeriesValues(period, 2, prices) || !_volumeSource.GetSeriesValues(period, 1, vol))
      {
         return false;
      }
      if (pos == 0 || _buffer._data[pos - 1] == EMPTY_VALUE)
      {
         val = vol[0];
      }
      else if (prices[0] > prices[1])
      {
         val = _buffer._data[pos - 1] + vol[0];
      }
      else
      {
         val = _buffer._data[pos - 1] - vol[0];
      }

      _buffer._data[pos] = val;

      return true;
   }
};

#endif
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0



// IBarStream v1.0



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


// Price stream v3.1

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

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      int pos = Size() - 1 - period;
      return GetValues(pos, count, values);
   }

   virtual bool GetValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PriceClose:
               if (!_source.GetClose(period - i, val))
               {
                  return false;
               }
               break;
            case PriceOpen:
               if (!_source.GetOpen(period - i, val))
               {
                  return false;
               }
               break;
            case PriceHigh:
               if (!_source.GetHigh(period - i, val))
               {
                  return false;
               }
               break;
            case PriceLow:
               if (!_source.GetLow(period - i, val))
               {
                  return false;
               }
               break;
            case PriceMedian:
               {
                  double high, low;
                  if (!_source.GetHighLow(period - i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PriceTypical:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PriceWeighted:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period - i, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period - i, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period - i, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
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

#endif
// Bar stream v2.0



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
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
// VolumeStream v1.2

class VolumeStream : public AStream
{
public:
   VolumeStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - 1 - period, count, val);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iVolume(_symbol, _timeframe, period + i);
      }
      return true;
   }
};

OBVStream* obv;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(PERIOD_M1);
   IStream* source = PriceStreamFactory::Create(_Symbol, timeframe, InpAppliedPrice);
   IStream* volume = new VolumeStream(_Symbol, timeframe);
   obv = new OBVStream(source, volume);
   source.Release();
   volume.Release();
   ptf = PeriodSeconds(PERIOD_CURRENT) / PeriodSeconds(PERIOD_M1);
   string short_name = "Cumulative OBV";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//
   SetIndexBuffer(0, ExtOBVBuffer, INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME, "COBV");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MathMin(MaxBars, Bars(Symbol(), PERIOD_M1) / ptf));
//
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   obv.Release();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int c = 0;
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
   if(rates_total < 50 + 1)
      return(0);
   int limit, i, k;
   limit = MathMin(rates_total - 1100, MaxBars);
   if(limit > MaxBars)
      limit = MaxBars;
   for(i = limit; i > 0 && !IsStopped() && i < rates_total; i--)
     {
      ExtOBVBuffer[i] = EMPTY_VALUE;
     }
   double sumt = 0.0;
   int barstf = Bars(Symbol(), PERIOD_M1);
   for (int i = rates_total - limit - 1; i < rates_total && !IsStopped(); i++)
   {
      if(Period() == PERIOD_M1)
      {
         double val[1];
         if (obv.GetValues(i, 1, val))
         {
            ExtOBVBuffer[i] = val[0];
         }
      }
      else
      {
         double sum = 0.0;
         datetime d1 = iTime(Symbol(), Period(), rates_total - i - 1);
         datetime d2 = iTime(Symbol(), Period(), rates_total - i);
         int from = iBarShift(Symbol(), PERIOD_M1, d2);
         int to = i == 0 ? -1 : iBarShift(Symbol(), PERIOD_M1, d1);
         if (from == to)
         {
            ExtOBVBuffer[i] = EMPTY_VALUE;
         }
         else
         {
            for(k = from; k > to; k--)
            {
               double val[1];
               if (obv.GetSeriesValues(k, 1, val))
               {
                  sum = sum + val[0];
               }
            }
            ExtOBVBuffer[i] = sum;
         }
      }
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int btf(int b)
  {
   return iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(), Period(), b));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsValue(double val)
  {
   return val > 0 && val != EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
      default:
         return((string)PERIOD_CURRENT);
     }
   return IntegerToString(lPeriod);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }
//+------------------------------------------------------------------+

// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=75351

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+  