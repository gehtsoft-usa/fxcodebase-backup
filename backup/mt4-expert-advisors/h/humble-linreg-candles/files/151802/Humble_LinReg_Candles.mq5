//https://fxcodebase.com/code/viewtopic.php?f=38&t=73973

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 White
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

input int signal_length = 11; // Signal Smoothing
input bool sma_signal = true; // Simple MA (Signal Line)
input bool lin_reg = true; // Lin Reg
input int linreg_length = 11; // Linear Regression Length
input int bars_limit = 1000; // Bars limit
double plot1[];

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

// AStream v1.1
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
//LinearRegressionOnStream v1.3

class LinearRegressionOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(IStream *source, const int length, int offset = 0)
      :AOnStream(source)
   {
      _offset = offset;
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period - _offset < 0)
      {
         return false;
      }
      int size = Size();
      int index = size - 1 - period;
      int range = ArrayRange(_buffer, 0);
      if (range < size)
      {
         ArrayResize(_buffer, size);
         for (int i = range; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double price[1];
      if (!_source.GetSeriesValues(period - _offset, 1, price))
      {
         return false;
      }
      if (index < _length || _buffer[index + 1 - _length] == 0)
      {
         _buffer[index] = price[0];
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price[0];
      double sma  = price[0];
      for (int i = 1; i < _length; ++i)
      {
         if (_buffer[index - i] == EMPTY_VALUE)
         {
            _buffer[index] = price[0];
            return false;
         }
         double weight = _length - i;
         lwmw += weight;
         lwma += weight * _buffer[index - i];  
         sma += _buffer[index - i];
      }
      _buffer[index] = (3.0 * lwma / lwmw - 2.0 * sma / _length);
      val = _buffer[index];
      return true;
   }
};
// CustomStream v2.0

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

//SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};


// EMA on stream v1.0

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 2.0 / (_length + 1.0);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current[0];
      _buffer[bufferIndex] = (1 - _k) * last + _k * current[0];
      val = _buffer[bufferIndex];
      return true;
   }
};
SimplePriceStream* linreg1Source;
IStream* linreg1;
SimplePriceStream* linreg2Source;
IStream* linreg2;
SimplePriceStream* linreg3Source;
IStream* linreg3;
SimplePriceStream* linreg4Source;
IStream* linreg4;
CustomStream* sma1Source;
IStream* sma1;
CustomStream* ema1Source;
IStream* ema1;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("LinReg Candles");
   IndicatorSetString(INDICATOR_SHORTNAME, "Humble LinReg Candles");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int id = 0;
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   linreg1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceOpen);
   linreg1 = new LinearRegressionOnStream(linreg1Source, linreg_length, 0);
   linreg2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   linreg2 = new LinearRegressionOnStream(linreg2Source, linreg_length, 0);
   linreg3Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   linreg3 = new LinearRegressionOnStream(linreg3Source, linreg_length, 0);
   linreg4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   linreg4 = new LinearRegressionOnStream(linreg4Source, linreg_length, 0);
   sma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, signal_length);
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, signal_length);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   linreg1Source.Release();
   linreg1.Release();
   linreg2Source.Release();
   linreg2.Release();
   linreg3Source.Release();
   linreg3.Release();
   linreg4Source.Release();
   linreg4.Release();
   sma1Source.Release();
   sma1.Release();
   ema1Source.Release();
   ema1.Release();
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
      ArrayInitialize(plot1, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double linreg1Value[1];
      if (!linreg1.GetValues(pos, 1, linreg1Value))
      {
         continue;
      }
      double bopen = (lin_reg ? linreg1Value[0] : open[pos]);
      double linreg2Value[1];
      if (!linreg2.GetValues(pos, 1, linreg2Value))
      {
         continue;
      }
      double bhigh = (lin_reg ? linreg2Value[0] : high[pos]);
      double linreg3Value[1];
      if (!linreg3.GetValues(pos, 1, linreg3Value))
      {
         continue;
      }
      double blow = (lin_reg ? linreg3Value[0] : low[pos]);
      double linreg4Value[1];
      if (!linreg4.GetValues(pos, 1, linreg4Value))
      {
         continue;
      }
      double bclose = (lin_reg ? linreg4Value[0] : close[pos]);
      bool r = (bopen < bclose);
      sma1Source.SetValue(pos, bclose);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value))
      {
         continue;
      }
      ema1Source.SetValue(pos, bclose);
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value))
      {
         continue;
      }
      double signal = (sma_signal ? sma1Value[0] : ema1Value[0]);
      plot1[pos] = signal;
   }
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+