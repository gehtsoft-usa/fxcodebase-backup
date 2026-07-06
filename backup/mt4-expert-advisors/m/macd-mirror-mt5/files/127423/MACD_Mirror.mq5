// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68679

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
#property strict

//---- indicator settings
#property  indicator_separate_window
#property indicator_level1 0
#property indicator_levelcolor Yellow
#property  indicator_buffers 3
#property indicator_plots 3
#property  indicator_color2  Blue
#property  indicator_color3  Yellow
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
//---- indicator parameters
input int PeriodeEMA = 20;
input int SignalSMA = 9;
input color MACDColor = Red; // MACD color
double     Macd2Buffer[];
double     SignalBuffer[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

// IStream v.1.2
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

//AOnStream v1.0
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

   virtual bool GetValue(const int period, double &val) = 0;

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period + i, v))
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

//SMAOnStream v1.0

class SMAOnStream : public AOnStream
{
   double _length;
public:
   SMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};

// ABaseStream v1.0
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
};

// IndicatorOutputStream v1.0
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

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period + i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period + i];
      }
      return true;
   }
};

int ma_open, ma_close;
IndicatorOutputStream* MacdBuffer;
IStream* Signal;

void OnInit()
{
   IndicatorName = GenerateIndicatorName("MACD_Mirror");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   MacdBuffer = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = MacdBuffer.RegisterStream(id, MACDColor, "MACD");
   SetIndexBuffer(id + 0, Macd2Buffer, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id + 0, SignalBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);

   Signal = new SMAOnStream(MacdBuffer, SignalSMA);

   ma_open = iMA(NULL, 0, PeriodeEMA, 0, MODE_EMA, PRICE_OPEN);
   ma_close = iMA(NULL, 0, PeriodeEMA, 0, MODE_EMA, PRICE_CLOSE);
}

void OnDeinit(const int reason)
{
   delete MacdBuffer;
   MacdBuffer = NULL;
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(ma_open);
   IndicatorRelease(ma_close);
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
   for (int pos = prev_calculated; pos < rates_total; ++pos)
   {
      double o[1];
      double c[1];
      if (CopyBuffer(ma_open, 0, pos, 1, o) == 1 && CopyBuffer(ma_close, 0, pos, 1, c) == 1)
      {
         MacdBuffer._data[pos] = c[0] - o[0];
         Macd2Buffer[pos] = o[0] - c[0];
         double value[1];
         if (Signal.GetValues(pos, 1, value))
            SignalBuffer[pos] = value[0];
      }
   }
   return rates_total;
}