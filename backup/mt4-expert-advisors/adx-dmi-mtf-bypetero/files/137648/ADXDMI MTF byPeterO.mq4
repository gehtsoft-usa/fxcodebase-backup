// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70442

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

//Converted from https://ar.tradingview.com/script/8XZnswIb-ADX-DMI-MTF-byPeterO/
//The goal of this study was to use ADX from Higher Timeframe - to determine trend direction
//Why? Because ADX is very sensitive, able to show trend ending without any delay, but not in the middle of it.
//Being able to see such immediate trend change on higher timeframe, is a great indicator of trend direction.
//Adding just security() calls to 'highest', 'lowest' and 'close' didn't seem right, because it produced some ugly ADX, D+ and D- plotlines.
//I wanted to see plotlines, which look exactly like those on actual higher timeframe.
//Therefore I modified the calculations.
//
//On top of all that, I added interpretation of DMI readings, because it is not as simple as plus>minus + ADXrising = uptrend.
//So GREEN background means higher timeframe uptrend and RED background means downtrend.

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 White

input int lenadx = 14; // DI Length
input int lensig = 14; // ADX Smoothing
input int mtf = 15; // MTF for ADX trend
input int bars_limit = 100000; // Bars limit

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

   virtual int Size()
   {
      return _source.Size();
   }
};

//RmaOnStream v1.0
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

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price) / _length;
      }
      val = _buffer[index];
      return true;
   }
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

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

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

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#define AStream_IMP
#endif

// IndicatorOutputStream v3.0
class IndicatorOutputStream : public AStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, _data);
      SetIndexLabel(id, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, _data);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValue(const int period, double& val)
   {
      if (_data[period] == EMPTY_VALUE)
         return false;
      val = _data[period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};

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

double plus_mtf[], minus_mtf[], adx_mtf[];
IndicatorOutputStream* tr_mtf;
IndicatorOutputStream* plusDM_mtf;
IndicatorOutputStream* minusDM_mtf;
IndicatorOutputStream* adx_mtf_source;
RmaOnStream* tr_mtf_rma;
RmaOnStream* plusDM_mtf_rma;
RmaOnStream* minusDM_mtf_rma;
RmaOnStream* adx_mtf_rma;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("adxdmi");
   IndicatorShortName("ADX DMI MTF By PeterO");

   IndicatorBuffers(7);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, plus_mtf);
   SetIndexLabel(0, "+DI MTF");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, minus_mtf);
   SetIndexLabel(1, "-DI MTF");
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, adx_mtf);
   SetIndexLabel(2, "ADX MTF");

   tr_mtf = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   tr_mtf.RegisterInternalStream(3);
   plusDM_mtf = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   plusDM_mtf.RegisterInternalStream(4);
   minusDM_mtf = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   minusDM_mtf.RegisterInternalStream(5);
   adx_mtf_source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   adx_mtf_source.RegisterInternalStream(6);
   tr_mtf_rma = new RmaOnStream(tr_mtf, lenadx * mtf);
   plusDM_mtf_rma = new RmaOnStream(plusDM_mtf, lenadx * mtf);
   minusDM_mtf_rma = new RmaOnStream(minusDM_mtf, lenadx * mtf);
   adx_mtf_rma = new RmaOnStream(adx_mtf_source, lenadx * mtf);

   return INIT_SUCCEEDED;
}

int deinit()
{
   tr_mtf_rma.Release();
   tr_mtf_rma = NULL;
   tr_mtf.Release();
   tr_mtf = NULL;
   plusDM_mtf.Release();
   plusDM_mtf = NULL;
   adx_mtf_source.Release();
   adx_mtf_source = NULL;
   adx_mtf_rma.Release();
   adx_mtf_rma = NULL;
   plusDM_mtf_rma.Release();
   plusDM_mtf_rma = NULL;
   minusDM_mtf.Release();
   minusDM_mtf = NULL;
   minusDM_mtf_rma.Release();
   minusDM_mtf_rma = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
      ArrayInitialize(plus_mtf, EMPTY_VALUE);
      ArrayInitialize(minus_mtf, EMPTY_VALUE);
      ArrayInitialize(adx_mtf, EMPTY_VALUE);
      tr_mtf.Clear(EMPTY_VALUE);
      minusDM_mtf.Clear(EMPTY_VALUE);
      plusDM_mtf.Clear(EMPTY_VALUE);
      adx_mtf_source.Clear(EMPTY_VALUE);
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

   int toSkip = mtf * 2;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, mtf, pos);
      int highestIndex2 = iHighest(_Symbol, _Period, MODE_HIGH, mtf, pos + mtf);
      double up_mtf = iHigh(_Symbol, _Period, highestIndex) - iHigh(_Symbol, _Period, highestIndex2);
      
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, mtf, pos);
      int lowestIndex2 = iLowest(_Symbol, _Period, MODE_LOW, mtf, pos + mtf);
      double down_mtf = iLow(_Symbol, _Period, lowestIndex) - iLow(_Symbol, _Period, lowestIndex2);

      plusDM_mtf._data[pos] = up_mtf > down_mtf && up_mtf > 0 ? up_mtf : 0;
      minusDM_mtf._data[pos] = down_mtf > up_mtf && down_mtf > 0 ? down_mtf : 0;

      tr_mtf._data[pos] = MathMax(MathMax(high[pos] - low[pos], MathAbs(high[pos] - close[pos + mtf])), MathAbs(low[pos] - close[pos + mtf]));
      double trur_mtf;
      if (!tr_mtf_rma.GetValue(pos, trur_mtf))
      {
         continue;
      }
      double plusDM_mtf_value;
      if (!plusDM_mtf_rma.GetValue(pos, plusDM_mtf_value))
      {
         continue;
      }
      double minusDM_mtf_value;
      if (!minusDM_mtf_rma.GetValue(pos, minusDM_mtf_value))
      {
         continue;
      }
      plus_mtf[pos] = trur_mtf == 0 ? 0 : 100 * plusDM_mtf_value / trur_mtf;
      minus_mtf[pos] = trur_mtf == 0 ? 0 : 100 * minusDM_mtf_value / trur_mtf;
      double sum_mtf = MathAbs(plus_mtf[pos]) + MathAbs(minus_mtf[pos]);
      adx_mtf_source._data[pos] = MathAbs(plus_mtf[pos] - minus_mtf[pos]) / (sum_mtf == 0 ? 1 : sum_mtf);
      double adx_mtf_value;
      if (!adx_mtf_rma.GetValue(pos, adx_mtf_value))
      {
         continue;
      }
      adx_mtf[pos] = 100 * adx_mtf_value;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
