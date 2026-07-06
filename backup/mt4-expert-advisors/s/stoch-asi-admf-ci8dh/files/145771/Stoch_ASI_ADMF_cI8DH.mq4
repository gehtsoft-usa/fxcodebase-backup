// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72110


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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
 
#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_label1 "Upper"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x888888
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Lower"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0x888888
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "ASI (%K)"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0xaa00bb
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "ASI %D"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x55bb00
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "ADMF (%K)"
#property indicator_type5 DRAW_LINE
#property indicator_color5 0x0099ff
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "ADMF %D"
#property indicator_type6 DRAW_LINE
#property indicator_color6 0xff9900
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Record low/high ASI"
#property indicator_type7 DRAW_LINE
#property indicator_color7 0xcc00ff
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Record low/high ADMF"
#property indicator_type8 DRAW_LINE
#property indicator_color8 0x0000ff
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

input string ind = "Money Flow (ADMF)"; // Indicator
input int len = 14; // Length
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
input PriceType src = PriceClose; // Source
input bool price_enable = false; // Factor Price in ADMF
input bool show_ind = false; // Show indicators (hides stochastic)
input bool historical = false; // Historical Stoch? (unchecked = standard stoch)
input int len_stoch = 14; // Stoch Length (has effect only in standard mode)
input int smoothK = 2; // Stoch Smoothing
input int periodD = 2; // Stoch %D (1: disable)
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[], plot7[], plot8[];
double lowest_ASI[], highest_ASI[], lowest_ADMF[], highest_ADMF[];
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
// Stream base v1.0



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

class _lowestStream
{
   IStream* _src;
   CustomStream* l;
public:
   _lowestStream(IStream* _src)
   {
      this._src = _src;
      _src.AddRef();
      l = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~_lowestStream()
   {
      _src.Release();
      l.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double _srcValue;
      if (!_src.GetValue(period, _srcValue))
      {
         return false;
      }
      l.SetValue(period, _srcValue);
      double lValue_1;
      if (!l.GetValue(period + 1, lValue_1))
      {
         return false;
      }
      if ((_srcValue < nzfloat(lValue_1, _srcValue)))
      {
         l.SetValue(period, _srcValue);
      }
      else
      {
         l.SetValue(period, nzfloat(lValue_1, _srcValue));
      }
      double lValue;
      if (!l.GetValue(period, lValue))
      {
         return false;
      }
      __out1 = lValue;
      return true;
   }
};
class _highestStream
{
   IStream* _src;
   CustomStream* h;
public:
   _highestStream(IStream* _src)
   {
      this._src = _src;
      _src.AddRef();
      h = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~_highestStream()
   {
      _src.Release();
      h.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double _srcValue;
      if (!_src.GetValue(period, _srcValue))
      {
         return false;
      }
      h.SetValue(period, _srcValue);
      double hValue_1;
      if (!h.GetValue(period + 1, hValue_1))
      {
         return false;
      }
      if ((_srcValue > nzfloat(hValue_1, _srcValue)))
      {
         h.SetValue(period, _srcValue);
      }
      else
      {
         h.SetValue(period, nzfloat(hValue_1, _srcValue));
      }
      double hValue;
      if (!h.GetValue(period, hValue))
      {
         return false;
      }
      __out1 = hValue;
      return true;
   }
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
// IBarStream v2.1



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

   virtual void Refresh() = 0;
};
#endif


// Price stream v2.0

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

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};


#endif


// Highest high stream v1.2

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
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




// Lowest low stream v1.2

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
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

// Stochastics on stream v1.0

class StochOnStream : public AStreamBase
{
   IStream* _closeStream;
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
   int _period;
public:
   StochOnStream(IStream* closeStream, IStream* highStream, IStream* lowStream, int period)
      :AStreamBase()
   {
      _period = period;
      _closeStream = closeStream;
      _closeStream.AddRef();
      _highest = new HighestHighStream(highStream, period);
      _lowest = new LowestLowStream(lowStream, period);
   }

   ~StochOnStream()
   {
      _closeStream.Release();
      _highest.Release();
      _lowest.Release();
   }
   
   virtual int Size()
   {
      return _closeStream.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double close;
      if (!_closeStream.GetValue(period, close))
      {
         return false;
      }
      double lowest;
      if (!_lowest.GetValue(period, lowest))
      {
         return false;
      }
      double highest;
      if (!_highest.GetValue(period, highest))
      {
         return false;
      }
      double diff = (highest - lowest);
      val = diff == 0 ? 0 : 100 * (close - lowest) / diff;
      return true;
   }
};

class stochasticStream
{
   IStream* _src;
   IStream* _lowest;
   IStream* _highest;
   CustomStream* stoch1Source;
   CustomStream* stoch1High;
   CustomStream* stoch1Low;
   IStream* stoch1;
public:
   stochasticStream(IStream* _src, IStream* _lowest, IStream* _highest)
   {
      stoch1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1High = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1Low = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stoch1 = new StochOnStream(stoch1Source, stoch1High, stoch1Low, len_stoch);
      this._src = _src;
      _src.AddRef();
      this._lowest = _lowest;
      _lowest.AddRef();
      this._highest = _highest;
      _highest.AddRef();
   }
   ~stochasticStream()
   {
      _src.Release();
      _lowest.Release();
      _highest.Release();
      stoch1Source.Release();
      stoch1High.Release();
      stoch1Low.Release();
      stoch1.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      int _stoch;
      if (historical)
      {
         double _srcValue;
         if (!_src.GetValue(period, _srcValue))
         {
            return false;
         }
         double _lowestValue;
         if (!_lowest.GetValue(period, _lowestValue))
         {
            return false;
         }
         double _highestValue;
         if (!_highest.GetValue(period, _highestValue))
         {
            return false;
         }
         _stoch = 100 * (_srcValue - _lowestValue) / (_highestValue - _lowestValue);
      }
      else
      {
         double _srcValue;
         if (!_src.GetValue(period, _srcValue))
         {
            return false;
         }
         stoch1Source.SetValue(period, _srcValue);
         stoch1High.SetValue(period, _srcValue);
         stoch1Low.SetValue(period, _srcValue);
         double stoch1Value;
         if (!stoch1.GetValue(period, stoch1Value))
         {
            return false;
         }
         _stoch = stoch1Value;
      }
      __out1 = _stoch;
      return true;
   }
};
double nzfloat(double val, double replacement = 0)
{
   return val == EMPTY_VALUE ? replacement : val;
}

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



// True range stream v2.1

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         if (_handleNa)
         {
            val = CalcFirst(pos);
            return true;
         }
         return false;
      }
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iClose(_symbol, _timeframe, pos + 1));

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
private:
   double CalcFirst(int pos)
   {
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));

      return MathMax(lc, MathMax(hl, hc));
   }
};
#endif
IStream* tr1;
// Simple price stream v1.0



class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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


// Change stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double src1, src2;
      if (!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
      {
         return false;
      }
      val = src1 - src2;
      return true;
   }
};

#endif


//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

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

#endif
SimplePriceStream* srcInputstream;
CustomStream* change1Source;
IStream* change1;
CustomStream* rma1Source;
IStream* rma1;
SimplePriceStream* change2Source;
IStream* change2;
CustomStream* rma2Source;
IStream* rma2;
CustomStream* _lowestFunc1param1;
_lowestStream* _lowestFunc1;
CustomStream* _highestFunc2param1;
_highestStream* _highestFunc2;
CustomStream* _lowestFunc3param1;
_lowestStream* _lowestFunc3;
CustomStream* _highestFunc4param1;
_highestStream* _highestFunc4;
CustomStream* rma3Source;
CustomStream* stochasticFunc5param1;
CustomStream* stochasticFunc5param2;
CustomStream* stochasticFunc5param3;
stochasticStream* stochasticFunc5;
IStream* rma3;
CustomStream* rma4Source;
IStream* rma4;
CustomStream* rma5Source;
CustomStream* stochasticFunc6param1;
CustomStream* stochasticFunc6param2;
CustomStream* stochasticFunc6param3;
stochasticStream* stochasticFunc6;
IStream* rma5;
CustomStream* rma6Source;
IStream* rma6;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("(Stoch) ASI ADMF [cI8DH]");
   IndicatorShortName("Stoch Money Flow (ADMF) & Absolute Strength Index (ASI) [cI8DH]");
   IndicatorBuffers(12);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, lowest_ASI);
   SetIndexBuffer(id++, highest_ASI);
   SetIndexBuffer(id++, lowest_ADMF);
   SetIndexBuffer(id++, highest_ADMF);
   srcInputstream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, src);
   change1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   rma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma1 = new RmaOnStream(rma1Source, len);
   change2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   change2 = new ChangeStream(change2Source, 1);
   rma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma2 = new RmaOnStream(rma2Source, len);
   _lowestFunc1param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _lowestFunc1 = new _lowestStream(_lowestFunc1param1);
   _highestFunc2param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _highestFunc2 = new _highestStream(_highestFunc2param1);
   _lowestFunc3param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _lowestFunc3 = new _lowestStream(_lowestFunc3param1);
   _highestFunc4param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _highestFunc4 = new _highestStream(_highestFunc4param1);
   rma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc5param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc5param2 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc5param3 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc5 = new stochasticStream(stochasticFunc5param1, stochasticFunc5param2, stochasticFunc5param3);
   rma3 = new RmaOnStream(rma3Source, smoothK);
   rma4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma4 = new RmaOnStream(rma4Source, periodD);
   rma5Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc6param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc6param2 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc6param3 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stochasticFunc6 = new stochasticStream(stochasticFunc6param1, stochasticFunc6param2, stochasticFunc6param3);
   rma5 = new RmaOnStream(rma5Source, smoothK);
   rma6Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma6 = new RmaOnStream(rma6Source, periodD);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   tr1.Release();
   srcInputstream.Release();
   change1Source.Release();
   change1.Release();
   rma1Source.Release();
   rma1.Release();
   change2Source.Release();
   change2.Release();
   rma2Source.Release();
   rma2.Release();
   _lowestFunc1param1.Release();
   delete _lowestFunc1;
   _highestFunc2param1.Release();
   delete _highestFunc2;
   _lowestFunc3param1.Release();
   delete _lowestFunc3;
   _highestFunc4param1.Release();
   delete _highestFunc4;
   stochasticFunc5param1.Release();
   stochasticFunc5param2.Release();
   stochasticFunc5param3.Release();
   delete stochasticFunc5;
   rma3Source.Release();
   rma3.Release();
   rma4Source.Release();
   rma4.Release();
   stochasticFunc6param1.Release();
   stochasticFunc6param2.Release();
   stochasticFunc6param3.Release();
   delete stochasticFunc6;
   rma5Source.Release();
   rma5.Release();
   rma6Source.Release();
   rma6.Release();
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(lowest_ASI, EMPTY_VALUE);
      ArrayInitialize(highest_ASI, EMPTY_VALUE);
      ArrayInitialize(lowest_ADMF, EMPTY_VALUE);
      ArrayInitialize(highest_ADMF, EMPTY_VALUE);
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

   int toSkip = 1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double h0 = plot1[pos] = ((historical || show_ind) ? EMPTY_VALUE : 80);
      double h1 = plot2[pos] = ((historical || show_ind) ? EMPTY_VALUE : 20);
      double ASI;
      if (((ind == "Absolute Strength Index (ASI)") || (ind == "ASI and ADMF")))
      {
         double srcInputstreamValue;
         if (!srcInputstream.GetValue(pos, srcInputstreamValue))
         {
            continue;
         }
         change1Source.SetValue(pos, srcInputstreamValue);
         double change1Value;
         if (!change1.GetValue(pos, change1Value))
         {
            continue;
         }
         double srcInputstreamValue_1;
         if (!srcInputstream.GetValue(pos + 1, srcInputstreamValue_1))
         {
            continue;
         }
         int gain_loss = 10000 * change1Value / nzfloat((srcInputstreamValue_1 + srcInputstreamValue) / 2, 0.0000000001);
         rma1Source.SetValue(pos, gain_loss);
         double rma1Value;
         if (!rma1.GetValue(pos, rma1Value))
         {
            continue;
         }
         ASI = rma1Value;
      }
      double ADMF;
      if (((ind == "Money Flow (ADMF)") || (ind == "ASI and ADMF")))
      {
         double trl = MathMin(low[pos], close[pos + 1]);
         double trh = MathMax(high[pos], close[pos + 1]);
         double change2Value;
         if (!change2.GetValue(pos, change2Value))
         {
            continue;
         }
         double tr1Value;
         if (!tr1.GetValue(pos, tr1Value))
         {
            continue;
         }
         double AD_ratio = change2Value / nzfloat(tr1Value, 0.00000001);
         double vol;
         if (price_enable)
         {
            vol = tick_volume[pos] * (close[pos + 1] + close[pos] + trl + trh) / 4;
         }
         else
         {
            vol = tick_volume[pos];
         };
         rma2Source.SetValue(pos, vol * AD_ratio);
         double rma2Value;
         if (!rma2.GetValue(pos, rma2Value))
         {
            continue;
         }
         ADMF = rma2Value;
      }
      _lowestFunc1param1.SetValue(pos, ASI);
      double _lowestFunc1Value;
      if (!_lowestFunc1.GetValue(pos, _lowestFunc1Value))
      {
         continue;
      }
      lowest_ASI[pos] = _lowestFunc1Value;
      _highestFunc2param1.SetValue(pos, ASI);
      double _highestFunc2Value;
      if (!_highestFunc2.GetValue(pos, _highestFunc2Value))
      {
         continue;
      }
      highest_ASI[pos] = _highestFunc2Value;
      _lowestFunc3param1.SetValue(pos, ADMF);
      double _lowestFunc3Value;
      if (!_lowestFunc3.GetValue(pos, _lowestFunc3Value))
      {
         continue;
      }
      lowest_ADMF[pos] = _lowestFunc3Value;
      _highestFunc4param1.SetValue(pos, ADMF);
      double _highestFunc4Value;
      if (!_highestFunc4.GetValue(pos, _highestFunc4Value))
      {
         continue;
      }
      highest_ADMF[pos] = _highestFunc4Value;
      stochasticFunc5param1.SetValue(pos, ASI);
      stochasticFunc5param2.SetValue(pos, lowest_ASI[pos]);
      stochasticFunc5param3.SetValue(pos, highest_ASI[pos]);
      double stochasticFunc5Value;
      if (!stochasticFunc5.GetValue(pos, stochasticFunc5Value))
      {
         continue;
      }
      rma3Source.SetValue(pos, stochasticFunc5Value);
      double rma3Value;
      if (!rma3.GetValue(pos, rma3Value))
      {
         continue;
      }
      double stoch_ASI = rma3Value;
      rma4Source.SetValue(pos, stoch_ASI);
      double rma4Value;
      if (!rma4.GetValue(pos, rma4Value))
      {
         continue;
      }
      double stoch_ADI_D = ((periodD == 1) ? EMPTY_VALUE : rma4Value);
      stochasticFunc6param1.SetValue(pos, ADMF);
      stochasticFunc6param2.SetValue(pos, lowest_ADMF[pos]);
      stochasticFunc6param3.SetValue(pos, highest_ADMF[pos]);
      double stochasticFunc6Value;
      if (!stochasticFunc6.GetValue(pos, stochasticFunc6Value))
      {
         continue;
      }
      rma5Source.SetValue(pos, stochasticFunc6Value);
      double rma5Value;
      if (!rma5.GetValue(pos, rma5Value))
      {
         continue;
      }
      double stoch_ADMF = rma5Value;
      rma6Source.SetValue(pos, stoch_ADMF);
      double rma6Value;
      if (!rma6.GetValue(pos, rma6Value))
      {
         continue;
      }
      double stoch_ADMF_D = ((periodD == 1) ? EMPTY_VALUE : rma6Value);
      plot3[pos] = (show_ind ? ASI : stoch_ASI);
      plot4[pos] = (show_ind ? EMPTY_VALUE : stoch_ADI_D);
      plot5[pos] = (show_ind ? ADMF : stoch_ADMF);
      plot6[pos] = (show_ind ? EMPTY_VALUE : stoch_ADMF_D);
      plot7[pos] = (((lowest_ASI[pos] < lowest_ASI[pos + 1]) || (highest_ASI[pos] > highest_ASI[pos + 1])) ? ((show_ind ? ASI : stoch_ASI)) : EMPTY_VALUE);
      plot8[pos] = (((lowest_ADMF[pos] < lowest_ADMF[pos + 1]) || (highest_ADMF[pos] > highest_ADMF[pos + 1])) ? ((show_ind ? ADMF : stoch_ADMF)) : EMPTY_VALUE);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
