// More information about this indicator can be found at:
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=153200#p153200

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
#property indicator_buffers 28
#property indicator_level1 0

input int len = 34; // Length
input ENUM_TIMEFRAMES btf = PERIOD_CURRENT; // Bigger time frame
input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
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
#endif
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};



// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
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
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// Candles stream v.1.3
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};
int ref;
int sqzLen;
CustomStream* ema1Source;
IStream* ema1;
CustomStream* ema2Source;
IStream* ema2;
CustomStream* ema3Source;
IStream* ema3;
CandleStreams* candles1;
CandleStreams* candles5;
CandleStreams* candles9;
CandleStreams* candles13;
CandleStreams* candles17;
CandleStreams* candles21;
CandleStreams* candles25;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("MTrendSqueeze");
   IndicatorShortName("Madrid Trend Squeeze");
   IndicatorBuffers(28);
   int id = 0;
   candles1 = new CandleStreams();
   id = candles1.RegisterStreams(id, Aqua);
   candles5 = new CandleStreams();
   id = candles5.RegisterStreams(id, Fuchsia);
   candles9 = new CandleStreams();
   id = candles9.RegisterStreams(id, Lime);
   candles13 = new CandleStreams();
   id = candles13.RegisterStreams(id, Red);
   candles17 = new CandleStreams();
   id = candles17.RegisterStreams(id, Yellow);
   candles21 = new CandleStreams();
   id = candles21.RegisterStreams(id, Green);
   candles25 = new CandleStreams();
   id = candles25.RegisterStreams(id, Maroon);
   ref = 13;
   sqzLen = 5;
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, len);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, ref);
   ema3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, sqzLen);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   delete candles1;
   candles1 = NULL;
   delete candles5;
   candles5 = NULL;
   delete candles9;
   candles9 = NULL;
   delete candles13;
   candles13 = NULL;
   delete candles17;
   candles17 = NULL;
   delete candles21;
   candles21 = NULL;
   delete candles25;
   candles25 = NULL;
   return 0;
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
      candles1.Init();
      candles5.Init();
      candles9.Init();
      candles13.Init();
      candles17.Init();
      candles21.Init();
      candles25.Init();
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      if (btf != PERIOD_CURRENT)
      {
         int btfPos = iBarShift(_Symbol, btf, time[pos]);
         candles1.Clear(pos);
         candles5.Clear(pos);
         double value1 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 1, btfPos);
         if (value1 != EMPTY_VALUE)
         {
            candles1.Set(pos, 0, value1, 0, value1);
         }
         double value5 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 5, btfPos);
         if (value5 != EMPTY_VALUE)
         {
            candles5.Set(pos, 0, value5, 0, value5);
         }
         candles9.Clear(pos);
         candles13.Clear(pos);
         double value9 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 9, btfPos);
         if (value9 != EMPTY_VALUE)
         {
            candles9.Set(pos, 0, value9, 0, value9);
         }
         double value13 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 13, btfPos);
         if (value13 != EMPTY_VALUE)
         {
            candles13.Set(pos, 0, value13, 0, value13);
         }
         candles17.Clear(pos);
         double value17 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 17, btfPos);
         if (value17 != EMPTY_VALUE)
         {
            candles17.Set(pos, 0, value17, 0, value17);
         }
         candles21.Clear(pos);
         double value21 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 21, btfPos);
         if (value21 != EMPTY_VALUE)
         {
            candles21.Set(pos, 0, value21, 0, value21);
         }
         candles25.Clear(pos);
         double value25 = iCustom(_Symbol, btf, "Madrid_Trend_Squeeze_MTF", len, 25, btfPos);
         if (value25 != EMPTY_VALUE)
         {
            candles25.Set(pos, 0, value25, 0, value25);
         }
         
         continue;
      }
      double src = close[pos];
      ema1Source.SetValue(pos, src);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value))
      {
         continue;
      }
      double ma = ema1Value;
      double closema = close[pos] - ma;
      ema2Source.SetValue(pos, src);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value))
      {
         continue;
      }
      double refma = ema2Value - ma;
      ema3Source.SetValue(pos, src);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value))
      {
         continue;
      }
      double sqzma = ema3Value - ma;
0;
      candles1.Clear(pos);
      candles5.Clear(pos);
      switch (((closema >= 0) ? Aqua : Fuchsia))
      {
         case Aqua:
            candles1.Set(pos, 0, closema, 0, closema);
            break;
         case Fuchsia:
            candles5.Set(pos, 0, closema, 0, closema);
            break;
      }
      candles9.Clear(pos);
      candles13.Clear(pos);
      switch (((sqzma >= 0) ? Lime : Red))
      {
         case Lime:
            candles9.Set(pos, 0, sqzma, 0, sqzma);
            break;
         case Red:
            candles13.Set(pos, 0, sqzma, 0, sqzma);
            break;
      }
      candles17.Clear(pos);
      candles21.Clear(pos);
      candles25.Clear(pos);
      switch ((((((refma >= 0) && (closema < refma))) || (((refma < 0) && (closema > refma)))) ? Yellow : ((refma >= 0) ? Green : Maroon)))
      {
         case Yellow:
            candles17.Set(pos, 0, refma, 0, refma);
            break;
         case Green:
            candles21.Set(pos, 0, refma, 0, refma);
            break;
         case Maroon:
            candles25.Set(pos, 0, refma, 0, refma);
            break;
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
// More information about this indicator can be found at:
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=153200#p153200

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