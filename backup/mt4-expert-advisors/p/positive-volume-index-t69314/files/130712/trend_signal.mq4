// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69314

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int m = 10;

string IndicatorName;
string IndicatorObjPrefix;
double pvi[], nvi[], marron[], verde[];

// Lowest low stream v1.0

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

class LowestLowStream : public IStream
{
   int _loopback;
   int _references;
   IStream* _source;
public:
   LowestLowStream(IStream* source, int loopback)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
   }

   ~LowestLowStream()
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

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }
};
// Highest high stream v1.0

class HighestHighStream : public IStream
{
   int _loopback;
   int _references;
   IStream* _source;
public:
   HighestHighStream(IStream* source, int loopback)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
   }

   ~HighestHighStream()
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

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }
};
// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP

// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

// Instrument info v.1.5
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

class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif

CustomStream* pvim;
CustomStream* nvim;

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

HighestHighStream* pvimax;
LowestLowStream* pvimin;
HighestHighStream* nvimax;
LowestLowStream* nvimin;

int init()
{
   double temp = iCustom(NULL, 0, "positive_volume_index", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'positive_volume_index' indicator");
      return INIT_FAILED;
   }
   temp = iCustom(NULL, 0, "negative_volume_index", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'negative_volume_index' indicator");
      return INIT_FAILED;
   }
   temp = iCustom(NULL, 0, "MFI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'MFI' indicator");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Trend signal");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   pvim = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   nvim = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);

   IndicatorBuffers(6);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, marron);
   SetIndexLabel(0, "MAROON");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, verde);
   SetIndexLabel(1, "VERDE");

   int index = 2;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, pvi);
   index++;
   index = pvim.RegisterInternalStream(index);
   pvimax = new HighestHighStream(pvim, 90);
   pvimin = new LowestLowStream(pvim, 90);
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, nvi);
   index++;
   index = nvim.RegisterInternalStream(index);
   nvimax = new HighestHighStream(nvim, 90);
   nvimin = new LowestLowStream(nvim, 90);
   
   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   pvim.Release();
   pvim = NULL;
   nvim.Release();
   nvim = NULL;
   pvimax.Release();
   pvimax = NULL;
   pvimin.Release();
   pvimin = NULL;
   nvimax.Release();
   nvimax = NULL;
   nvimin.Release();
   nvimin = NULL;
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      pvi[i] = iCustom(_Symbol, _Period, "positive_volume_index", 0, i);
      pvim._stream[i] = iMAOnArray(pvi, 0, m, 0, MODE_EMA, i);
      double pvimaxValue, pviminValue;
      if (!pvimax.GetValue(i, pvimaxValue) || !pvimin.GetValue(i, pviminValue))
      {
         continue;
      }
      double oscp = (pvimaxValue - pviminValue) == 0 ? 0 : (pvi[i] - pvim._stream[i]) * 100 / (pvimaxValue - pviminValue);
      nvi[i] = iCustom(_Symbol, _Period, "negative_volume_index", 0, i);
      nvim._stream[i] = iMAOnArray(nvi, 0, m, 0, MODE_EMA, i);
      double nvimaxValue, nviminValue;
      if (!nvimax.GetValue(i, nvimaxValue) || !nvimin.GetValue(i, nviminValue))
      {
         continue;
      }
      double azul = (nvimaxValue - nviminValue) == 0 ? 0 : (nvi[i] - nvim._stream[i]) * 100 / (nvimaxValue - nviminValue);
      double xmf = iCustom(_Symbol, _Period, "MFI", 14, 0, i);
      double bbUp = iBands(_Symbol, _Period, 25, 1, 0, PRICE_WEIGHTED, MODE_UPPER, i);
      double bbDown = iBands(_Symbol, _Period, 25, 1, 0, PRICE_WEIGHTED, MODE_LOWER, i);
      double OB1 = (bbUp + bbDown) / 2;
      double OB2 = (bbUp - bbDown);
      double TotalPrice = (High[i] + Low[i] + Close[i] * 2) / 4.0;
      double BollOsc = OB2 == 0 ? 0 : ((TotalPrice - OB1) / OB2) * 100;
      double xrsi = iRSI(_Symbol, _Period, 14, PRICE_WEIGHTED, i);
      double STOC = iStochastic(_Symbol, _Period, 21, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      marron[i] = (xrsi + xmf + BollOsc + (STOC / 3)) / 2;
      verde[i] = marron[i] + oscp;
   }
   return 0;
}
