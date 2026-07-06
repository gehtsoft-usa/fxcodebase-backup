// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Orange
#property indicator_color3 Brown

extern int BB_Length=20;
extern double BB_Deviation=2;
extern int Keltner_Length=20;
extern int Keltner_Smooth_Length=20;
extern int Keltner_Smooth_Method=0;  // 0 - SMA
                                     // 1 - EMA
                                     // 2 - SMMA
                                     // 3 - LWMA
extern double Keltner_Deviation=2;
extern int momPeriod = 12; // Momemtum Period
extern int momEMA = 5; // Momentum EMA Period

input color bearish_color = Red; // Bearish color
input color bullish_color = Green; // Bullish color

double TTMS_Up[], TTMS_Dn[], TTMS_N[], momHist[];

// Regilar bearish divergence condition v1.0

#ifndef RegularBearishDivergenceCondition_IMP
#define RegularBearishDivergenceCondition_IMP

// Trough Condition v1.0

#ifndef TroughCondition_IMP
#define TroughCondition_IMP

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

class TroughCondition : public ICondition
{
   IStream* _source;
   int _bars;
public:
   TroughCondition(IStream* source, int bars)
   {
      _source = source;
      _source.AddRef();
      _bars = bars;
   }

   ~TroughCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period)
   {
      double centerValue;
      if (!_source.GetValue(period + _bars, centerValue))
         return false;

      for (int i = 0; i < _bars; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _bars + i + 1, leftValue) || leftValue < centerValue)
            return false;
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue < centerValue)
            return false;
      }
      return true;
   }
};

#endif
// Peak Condition v1.0

#ifndef PeakCondition_IMP
#define PeakCondition_IMP

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

class PeakCondition : public ICondition
{
   IStream* _source;
   int _bars;
public:
   PeakCondition(IStream* source, int bars)
   {
      _source = source;
      _source.AddRef();
      _bars = bars;
   }

   ~PeakCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period)
   {
      double centerValue;
      if (!_source.GetValue(period + _bars, centerValue))
         return false;

      for (int i = 0; i < _bars; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _bars + i + 1, leftValue) || leftValue > centerValue)
            return false;
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue > centerValue)
            return false;
      }
      return true;
   }
};

#endif
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

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

class PriceStream : public AStream
{
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period);
               if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                  val = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};
#endif

class RegularBearishDivergenceCondition : public ICondition
{
   TroughCondition* _trough;
   PeakCondition* _pricePeak;
public:
   RegularBearishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _trough = new TroughCondition(stream, 2);
      PriceStream* high = new PriceStream(symbol, timeframe, PriceHigh);
      _pricePeak = new PeakCondition(high, 2);
      high.Release();
   }

   ~RegularBearishDivergenceCondition()
   {
      delete _pricePeak;
      delete _trough;
   }

   virtual bool IsPass(const int period)
   {
      return _trough.IsPass(period) && _pricePeak.IsPass(period);
   }
};

#endif
// Regilar bullush divergence condition v1.0

#ifndef RegularBullishDivergenceCondition_IMP
#define RegularBullishDivergenceCondition_IMP

class RegularBullishDivergenceCondition : public ICondition
{
   TroughCondition* _priceTrough;
   PeakCondition* _peak;
public:
   RegularBullishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _peak = new PeakCondition(stream, 2);
      PriceStream* low = new PriceStream(symbol, timeframe, PriceLow);
      _priceTrough = new TroughCondition(low, 2);
      low.Release();
   }

   ~RegularBullishDivergenceCondition()
   {
      delete _priceTrough;
      delete _peak;
   }

   virtual bool IsPass(const int period)
   {
      return _peak.IsPass(period) && _priceTrough.IsPass(period);
   }
};

#endif

class DivergenceLine
{
   RegularBearishDivergenceCondition* _regularBearishDivergence;
   RegularBullishDivergenceCondition* _regularBullishDivergence;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IStream* _stream;
public:
   DivergenceLine(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _stream = stream;
      _stream.AddRef();
      _regularBearishDivergence = new RegularBearishDivergenceCondition(stream, symbol, timeframe);
      _regularBullishDivergence = new RegularBullishDivergenceCondition(stream, symbol, timeframe);

      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~DivergenceLine()
   {
      _stream.Release();
      delete _regularBearishDivergence;
      delete _regularBullishDivergence;
   }

   void Update(int period)
   {
      if (_regularBullishDivergence.IsPass(period))
      {
         for (int i = period + 1; i < iBars(_symbol, _timeframe) - 2; ++i)
         {
            if (_regularBearishDivergence.IsPass(i))
            {
               ResetLastError();
               double price1, price2;
               if (!_stream.GetValue(i + 2, price1) || !_stream.GetValue(period + 2, price2))
                  return;
               datetime from = iTime(_symbol, _timeframe, i + 2);
               string id = IndicatorObjPrefix + "rblValue" + TimeToString(from);
               CreateLine(id, from, price1, iTime(_symbol, _timeframe, period + 2), price2, bullish_color);
               return;
            }
         }
      }
      else if (_regularBearishDivergence.IsPass(period))
      {
         for (int i = period + 1; i < iBars(_symbol, _timeframe) - 2; ++i)
         {
            if (_regularBullishDivergence.IsPass(i))
            {
               ResetLastError();
               double price1, price2;
               if (!_stream.GetValue(i + 2, price1) || !_stream.GetValue(period + 2, price2))
                  return;
               datetime from = iTime(_symbol, _timeframe, i + 2);
               string id = IndicatorObjPrefix + "rbrValue" + TimeToString(from);
               CreateLine(id, from, price1, iTime(_symbol, _timeframe, period + 2), price2, bearish_color);
               return;
            }
         }
      }
   }
private:
   void CreateLine(string id, datetime from, double price1, datetime to, double price2, color clr)
   {
      long current_chart_id = ChartID();
      if (ObjectFind(current_chart_id, id) == -1)
      {
         int WindowNumber = MathMax(0, WindowFind(IndicatorName));
         if (!ObjectCreate(current_chart_id, id, OBJ_TREND, WindowNumber, from, price1, to, price2))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(current_chart_id, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(current_chart_id, id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(current_chart_id, id, OBJPROP_WIDTH, 1);
         ObjectSetInteger(current_chart_id, id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(current_chart_id, id, OBJPROP_PRICE1, price1);
      ObjectSetDouble(current_chart_id, id, OBJPROP_PRICE2, price2);
      ObjectSetInteger(current_chart_id, id, OBJPROP_TIME1, from);
      ObjectSetInteger(current_chart_id, id, OBJPROP_TIME2, to);
   }
};

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP



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

DivergenceLine* divergenceLine;
CustomStream* stream;

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

int init()
{
   IndicatorName = GenerateIndicatorName("TTMS Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(5);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,TTMS_Up);
   SetIndexLabel(0, "TTM Squeeze - Momentum Up");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,TTMS_Dn);
   SetIndexLabel(1, "TTM Squeeze - Momentum Down");
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,TTMS_N);
   SetIndexLabel(2, "TTM Squeeze - Momentum Mid");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, momHist);

   stream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stream.RegisterStream(4, Red, 1, 1, "ddd");

   divergenceLine = new DivergenceLine(stream, _Symbol, (ENUM_TIMEFRAMES)_Period);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   stream.Release();
   delete divergenceLine;
   divergenceLine = NULL;
   return(0);
}

int start()
{
   if(Bars<=3) 
      return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit = Bars - 2 - momPeriod;
   if(ExtCountedBars>2) 
      limit = MathMin(limit, Bars - ExtCountedBars - 1);
   int pos=limit;
   while (pos >= 0)
   {
      double ATR=iATR(NULL, 0, Keltner_Smooth_Length, pos);
      double MA=iMA(NULL, 0, Keltner_Length, 0, Keltner_Smooth_Method, PRICE_CLOSE, pos);
      double H=MA+ATR*Keltner_Deviation;
      double L=MA-ATR*Keltner_Deviation;
      double ML=iMA(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double D=iStdDev(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double TL=ML+BB_Deviation*D;
      double BL=ML-BB_Deviation*D;
      momHist[pos] = Close[pos] - Close[pos + momPeriod];
      double momHistVal = iMAOnArray(momHist, 0, momEMA, 0, MODE_EMA, pos);
      if (TL > H && momHistVal > 0)
      {
         TTMS_Up[pos] = momHistVal;
         TTMS_Dn[pos] = 0;
         TTMS_N[pos] = 0;
      }
      else if (TL < H && momHistVal < 0)
      {
         TTMS_Up[pos] = 0;
         TTMS_Dn[pos] = momHistVal;
         TTMS_N[pos] = 0;
      }
      else
      {
         TTMS_Up[pos] = 0;
         TTMS_Dn[pos] = 0;
         TTMS_N[pos] = momHistVal;
      }
      stream._stream[pos] = momHistVal;
      divergenceLine.Update(pos);
      pos--;
   } 
   return(0);
}

