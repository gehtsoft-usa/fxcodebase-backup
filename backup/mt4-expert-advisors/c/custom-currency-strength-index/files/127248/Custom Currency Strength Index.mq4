// Id: 25469
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68636

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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int loopback = 50; // Loopback period
input string currency_a = "EUR"; // Currency A
input string currency_b = "USD"; // Currency B

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

// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
};


// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

// Lowest low stream v1.0

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


// More templates and snippets on https://github.com/sibvic/mq4-templates

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

class CustomIndicatorStream : public AStream
{
   int _streamIndex;
public:
   CustomIndicatorStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const int streamIndex)
      :AStream(symbol, timeframe)
   {
      _streamIndex = streamIndex;
   }

   bool GetValue(const int period, double &val)
   {
      val = iCustom(_instrument.GetSymbol(), _timeframe, "Strength_waves_all_daily_101", true, _streamIndex, period);
      if (val <= 0)
         return false;
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};

IStream* source_1;
IStream* hh_1;
IStream* ll_1;
IStream* source_2;
IStream* hh_2;
IStream* ll_2;

int GetIndex(string curr)
{
   if (curr == "AUD")
      return 0;
   if (curr == "CAD")
      return 1;
   if (curr == "CHF")
      return 2;
   if (curr == "EUR")
      return 3;
   if (curr == "GBP")
      return 4;
   if (curr == "JPY")
      return 5;
   if (curr == "NZD")
      return 6;
   if (curr == "USD")
      return 7;
   return -1;
}

double out_1[];
double out_2[];

int init()
{
       double temp = iCustom(NULL, 0, "Strength_waves_all_daily_101", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Strength_waves_all_daily_101' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Custom Currency Strength Index");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   int index = GetIndex(currency_a);
   if (index == -1)
      return INIT_FAILED;
   source_1 = new CustomIndicatorStream(_Symbol, (ENUM_TIMEFRAMES)_Period, index);
   hh_1 = new HighestHighStream(source_1, loopback);
   ll_1 = new LowestLowStream(source_1, loopback);

   index = GetIndex(currency_b);
   if (index == -1)
      return INIT_FAILED;
   source_2 = new CustomIndicatorStream(_Symbol, (ENUM_TIMEFRAMES)_Period, index);
   hh_2 = new HighestHighStream(source_2, loopback);
   ll_2 = new LowestLowStream(source_2, loopback);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out_1);
   SetIndexLabel(0, "Currency A");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out_2);
   SetIndexLabel(1, "Currency B");

   return 0;
}

int deinit()
{
   source_1.Release();
   source_1 = NULL;
   hh_1.Release();
   hh_1 = NULL;
   ll_1.Release();
   ll_1 = NULL;

   source_2.Release();
   source_2 = NULL;
   hh_2.Release();
   hh_2 = NULL;
   ll_2.Release();
   ll_2 = NULL;

   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = MathMin(1000, ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      double x, h, l;
      if (!source_1.GetValue(pos, x) || !hh_1.GetValue(pos, h) || !ll_1.GetValue(pos, l))
         continue;
      out_1[pos] = h - l == 0 ? 0 : 100.0 * (x - l) / (h - l);

      if (!source_2.GetValue(pos, x) || !hh_2.GetValue(pos, h) || !ll_2.GetValue(pos, l))
         continue;
      out_2[pos] = h - l == 0 ? 0 : 100.0 * (x - l) / (h - l);
   } 
   return 0;
}