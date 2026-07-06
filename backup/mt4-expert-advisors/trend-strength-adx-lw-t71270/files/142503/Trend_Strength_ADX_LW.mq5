// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71270

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

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 5
#property indicator_label1 "Trend Strength"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Chop Zone"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Black
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Mendoza Line"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 " Extreme Zone"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Red
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

input int LWadxlength = 8; // ADX period
input int LWdilength = 9; // DMI Length
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[];

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

// ABaseStream v1.1
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
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
class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
#endif

// IndicatorOutputStream v3.0

#ifndef IndicatorOutputStream_IMP
#define IndicatorOutputStream_IMP

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};
#endif


#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public ABaseStream
{
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double hl = MathAbs(iHigh(_symbol, _timeframe, size - 1 - period - i) - iLow(_symbol, _timeframe, size - 1 - period - i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, size - 1 - period - i) - iClose(_symbol, _timeframe, size - 1 - period - i - 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, size - 1 - period - i) - iClose(_symbol, _timeframe, size - 1 - period - i - 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};
#endif


//AOnStream v2.0
class AOnStream : public IStream
{
protected:
   IStream *_source;
   int _references;
public:
   AOnStream(IStream *source)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
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

//RmaOnStream v2.1
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price[0]) / _length;
      }
      val = _buffer[index];
      return true;
   }
};


void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Trend Strength ADX LW");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trend Strength/ADX Leaf_West style");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, plot5, INDICATOR_DATA);
   ++id;

   tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   plusSource = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   minusSource = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   adxSource = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plusSource.RegisterInternalStream(id);
   id = minusSource.RegisterInternalStream(id);
   id = adxSource.RegisterInternalStream(id);
   plusRma = new RmaOnStream(plusSource, LWdilength);
   minusRma = new RmaOnStream(minusSource, LWdilength);
   adxRma = new RmaOnStream(adxSource, LWadxlength);
}

void OnDeinit(const int reason)
{
   tr.Release();
   minusRma.Release();
   plusRma.Release();
   adxRma.Release();
   plusSource.Release();
   adxSource.Release();
   minusSource.Release();
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

IndicatorOutputStream* plusSource;
IndicatorOutputStream* adxSource;
RmaOnStream* plusRma;
IndicatorOutputStream* minusSource;
RmaOnStream* minusRma;
RmaOnStream* adxRma;
TrueRangeStream* tr;

bool dirmov(int pos, double& plus, double& minus)
{
	double truerange[1];
   int tspos = tr.Size() - 1 - pos;
   if (!tr.GetSeriesValues(tspos, 1, truerange) || truerange[0] == 0)
   {
      return false;
   }
   double up = iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, tspos) - iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, tspos + 1);
	double down = iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, tspos + 1) - iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, tspos);
   plusSource._data[pos] = up > down && up > 0 ? up : 0;
   minusSource._data[pos] = up < down && down > 0 ? down : 0;
   double plusVal[1];
   double minusVal[1];
   if (!plusRma.GetSeriesValues(tspos, 1, plusVal) || !minusRma.GetSeriesValues(tspos, 1, minusVal))
   {
      return false;
   }
	plus = 100 * plusVal[0] / truerange[0];
	minus = 100 * minusVal[0] / truerange[0];
   return true;
}

bool adx(int pos, double& adx)
{ 
	double plus, minus;
   int tspos = adxSource.Size() - 1 - pos;
   if (!dirmov(pos, plus, minus))
   {
      return false;
   }
	double sum = plus + minus;
   adxSource._data[pos] = MathAbs(plus - minus) / (sum == 0 ? 1 : sum);
   double adxVal[1];
   if (!adxRma.GetSeriesValues(tspos, 1, adxVal))
   {
      return false;
   }
	adx = 100 * adxVal[0];
	return true;
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
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double LWADX;
      if (!adx(pos, LWADX))
      {
         continue;
      }
      plot1[pos] = LWADX;
      plot2[pos] = LWADX;
      plot3[pos] = 0;
      plot4[pos] = 20;
      plot5[pos] = 100;
   }
   return rates_total;
}