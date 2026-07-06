// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67206

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 C'255, 255, 0'
#property indicator_label1 "ETVI"
#property indicator_color2 C'255, 0, 0'
#property indicator_label2 "Signal"

input int Period1 = 12; // Period 1
input int Period2 = 12; // Period 2
input int Period3 = 1; // Period 3
input int EPeriod1 = 5; // Ergodic period 1
input int EPeriod2 = 5; // Ergodic period 2
input int EPeriod3 = 5; // Ergodic period 3
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP

// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
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
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
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
#define AStream_IMP
#endif

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

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (ArrayRange(_stream, 0) != totalBars) 
      {
         ArrayResize(_stream, totalBars);
      }
      _stream[period] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      if (ArrayRange(_stream, 0) != totalBars) 
      {
         ArrayResize(_stream, totalBars);
      }
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif


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

double ETVI[], Signal[];

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

CustomStream* upTicks;
CustomStream* downTicks;
EMAOnStream* ema_up2;
EMAOnStream* ema_dn2;
EMAOnStream* etvi;
EMAOnStream* signal;
CustomStream* tv;

int init()
{
   IndicatorName = GenerateIndicatorName("Ergodic Tick volume indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(2);
   upTicks = new CustomStream(symbol, tf);
   downTicks = new CustomStream(symbol, tf);
   EMAOnStream* ema_up1 = new EMAOnStream(upTicks, Period1);
   EMAOnStream* ema_dn1 = new EMAOnStream(downTicks, Period1);
   ema_up2 = new EMAOnStream(ema_up1, Period2);
   ema_up1.Release();
   ema_dn2 = new EMAOnStream(ema_dn1, Period2);
   ema_dn1.Release();
   tv = new CustomStream(symbol, tf);
   EMAOnStream* tvi = new EMAOnStream(tv, Period3);
   EMAOnStream* ema_tvi1 = new EMAOnStream(tvi, EPeriod1);
   tvi.Release();
   etvi = new EMAOnStream(ema_tvi1, EPeriod2);
   ema_tvi1.Release();
   signal = new EMAOnStream(etvi, EPeriod3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ETVI);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Signal);

   return(0);
}

int deinit()
{
   signal.Release();
   signal = NULL;
   etvi.Release();
   etvi = NULL;
   tv.Release();
   tv = NULL;
   ema_dn2.Release();
   ema_dn2 = NULL;
   ema_up2.Release();
   ema_up2 = NULL;
   upTicks.Release();
   upTicks = NULL;
   downTicks.Release();
   downTicks = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;

   InstrumentInfo instrument(symbol);
   int counted_bars = IndicatorCounted();
   int toSkip = 0;
   for (int pos = Bars - 1 - MathMax(counted_bars, toSkip); pos >= 0; --pos)
   {
      int index = iBarShift(symbol, tf, Time[pos]);
      if (index < 0)
      {
         continue;
      }
      double upValue = (iVolume(symbol, tf, index) + (iClose(symbol, tf, index) - iOpen(symbol, tf, index)) / instrument.GetPipSize()) / 2;
      upTicks.SetValue(index, upValue);
      downTicks.SetValue(index, iVolume(symbol, tf, index) - upValue);
      double EMA_Up2, EMA_Dn2;
      if (!ema_up2.GetValue(index, EMA_Up2) || !ema_dn2.GetValue(index, EMA_Dn2))
      {
         continue;
      }
      double sum = EMA_Up2 + EMA_Dn2;
      tv.SetValue(index, sum != 0 ? 100 * (EMA_Up2 - EMA_Dn2) / sum : 0);

      double etviValue;
      if (!etvi.GetValue(index, etviValue))
      {
         continue;
      }
      ETVI[pos] = etviValue;
      double signalValue;
      if (!signal.GetValue(index, signalValue))
      {
         continue;
      }
      Signal[pos] = signalValue;
   } 
   return 0;
}

