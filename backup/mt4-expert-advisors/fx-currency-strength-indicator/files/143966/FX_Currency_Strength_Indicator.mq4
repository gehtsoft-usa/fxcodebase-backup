// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71579

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property strict
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_label1 "EUR"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "GBP"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Olive
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "AUD"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "NZD"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Orange
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "USD"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "CAD"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Teal
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "CHF"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Fuchsia
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "JPY"
#property indicator_type8 DRAW_LINE
#property indicator_color8 Maroon
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

enum Mode
{
   MO1, // Relative Strength Index
   MO2, // True Strength Index
   MO3, // Rate Of Change
   MO4, // Absolute Strength Index
   MO5, // Regression Slope
   MO6, // Z-Score
   MO7 // Mataf
};

input bool dummy_1 = true; // ═════════════ General Settings
input Mode mode = MO1; // Calculation
input ENUM_APPLIED_PRICE src = PRICE_CLOSE; // Source
input bool ShowLabels = true; // Show Labels
input bool ShowEUR = true; // Show EUR
input bool ShowGBP = true; // Show GBP
input bool ShowAUD = true; // Show AUD
input bool ShowNZD = true; // Show NZD
input bool ShowUSD = true; // Show USD
input bool ShowCAD = true; // Show CAD
input bool ShowCHF = true; // Show CHF
input bool ShowJPY = true; // Show JPY
input bool dummy_2 = true; // ═════════════ Regression Slope
input int linregLen = 5; // Linear Regression Period
input int slopeLen = 1; // Slope
input bool dummy_3 = true; // ═════════════ True Strength Index
input int fastlen = 5; // TSI Fast Length
input int slowlen = 10; // TSI Slow Length
input bool dummy_4 = true; // ═════════════ Relative Strength Index
input int rsiLen = 5; // RSI Length
input bool dummy_5 = true; // ═════════════ Rate Of Change Index
input int rocLen = 1; // Rate of Change Period
input bool dummy_6 = true; // ═════════════ Absolute Strength Index
input int ASIlen = 10; // Absolute Strength Length
input bool dummy_7 = true; // ═════════════ Z-Score
input int zsLen = 10; // Z-Score Length
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[], plot7[], plot8[];
double linreg[];
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
//LinearRegressionOnStream v1.0

class LinearRegressionOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   LinearRegressionOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      int index = size - 1 - period;
      if (ArrayRange(_buffer, 0) < size)
      {
         ArrayResize(_buffer, size);
      }

      double price;
      if (!_source.GetValue(period, price))
      {
         return false;
      }
      if (index < _length)
      {
         _buffer[index] = price;
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price;
      double sma  = price;
      for (int i = 0; i < _length; ++i)
      {
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

class LRSStream
{
   IStream* _src;
   IStream* linreg1;
public:
   LRSStream(IStream* _src)
   {
      this._src = _src;
      _src.AddRef();
      linreg1 = new LinearRegressionOnStream(_src, linregLen);
   }
   ~LRSStream()
   {
      _src.Release();
      linreg1.Release();
   }
   void Release()
   {
      delete &this;
   }
   bool GetValue(const int pos, double &__out1)
   {
      double linreg1Value;
      if (!linreg1.GetValue(pos, linreg1Value))
      {
         return false;
      }
      double linreg2Value;
      if (!linreg1.GetValue(pos + slopeLen, linreg2Value))
      {
         return false;
      }
      linreg[pos] = linreg1Value;
      double slope = (linreg1Value - linreg2Value) / slopeLen;
      __out1 = slope;
      return true;
   }
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
// Custom stream with a size of a parent stream v1.0

class CustomStreamOnStream : public AStreamBase
{
   IStream* _source;
   double _stream[];
public:
   CustomStreamOnStream(IStream* stream)
   {
      _source = stream;
      _source.AddRef();
   }
   ~CustomStreamOnStream()
   {
      _source.Release();
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return _source.Size();
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      EnsureStreamHasProperSize(totalBars);
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
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

class calc_abssioStream
{
   IStream* src;
   CustomStreamOnStream* A;
   CustomStreamOnStream* M;
   CustomStreamOnStream* D;
public:
   calc_abssioStream(IStream* src)
   {
      this.src = src;
      src.AddRef();
      A = new CustomStreamOnStream(src);
      M = new CustomStreamOnStream(src);
      D = new CustomStreamOnStream(src);
   }
   ~calc_abssioStream()
   {
      src.Release();
      A.Release();
      M.Release();
      D.Release();
   }
   void Release()
   {
      delete &this;
   }
   bool GetValue(const int period, double &__out1)
   {
      double current, last;
      if (!src.GetValue(period, current))
      {
         return false;
      }
      if (!src.GetValue(period + 1, last))
      {
         return false;
      }
      double lastA;
      double lastM;
      double lastD;
      bool hasA = A.GetValue(period + 1, lastA);
      bool hasM = M.GetValue(period + 1, lastM);
      bool hasD = D.GetValue(period + 1, lastD);
      double currA = (current > last) ? (hasA ? 0 : lastA) + last == 0 ? 0 : (current / last) : (hasA ? 0 : lastA);
      double currM = (current == last) ? (hasM ? 0 : lastM) + 1.0 / ASIlen : (hasM ? 0 : lastM);
      double currD = (current < last) ? (hasD ? 0 : lastD) + current == 0 ? 0 : (last / current) : (hasD ? 0 : lastD);
      A.SetValue(period, currA);
      M.SetValue(period, currM);
      D.SetValue(period, currD);
      __out1 = (currD + (currM / 2 == 0) ? 100 : 100 - 100 / (1 + (currA + currM / 2) / (currD + currM / 2)));
      return true;
   }
};



// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current_;
            if (!_source.GetValue(period + i, current_))
               return false;

           summ += current_;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif


// StDev stream v1.2

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(IStream* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }
   
   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < _period; i++)
      {
         double __data;
         if (!_source.GetValue(period + i, __data))
            return false;
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

class ZSStream
{
   IStream* _src;
   IStream* sma1;
   IStream* stdev2;
public:
   ZSStream(IStream* _src)
   {
      this._src = _src;
      _src.AddRef();
      sma1 = new SmaOnStream(_src, zsLen);
      stdev2 = new StDevStream(_src, zsLen);
   }
   ~ZSStream()
   {
      _src.Release();
      sma1.Release();
      stdev2.Release();
   }
   void Release()
   {
      delete &this;
   }
   bool GetValue(const int pos, double &__out1)
   {
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value))
      {
         return false;
      }
      double stdev2Value;
      if (!stdev2.GetValue(pos, stdev2Value))
      {
         return false;
      }
      double _src2Value;
      if (!_src.GetValue(pos, _src2Value))
      {
         return false;
      }
      __out1 = stdev2Value == 0 ? 0 : (_src2Value - sma1Value) / stdev2Value;
      return true;
   }
};
class functionStream
{
   IStream* pair;
   double _close;
public:
   functionStream(IStream* pair)
   {
      this.pair = pair;
      pair.AddRef();
   }
   ~functionStream()
   {
      pair.Release();
   }
   void Release()
   {
      delete &this;
   }
   bool GetValue(const int pos, double &__out1)
   {
      double pairValue;
      if (!pair.GetValue(pos, pairValue))
      {
         return false;
      }
      if (_close == 0)
      {
         _close = pairValue;
      }
      double variation = _close == 0 ? 0 : (_close - pairValue) / _close * 100;
      double index = 100 - variation;
      __out1 = index;
      return true;
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


// RSI stream v1.0

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


//AbsStream v1.0
class AbsStream : public AOnStream
{
public:
   AbsStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
      {
         return false;
      }
      val = MathAbs(price);
      return true;
   }
};


//TSIOnStream v1.0
class TSIOnStream : public AOnStream
{
   double _length;
   ChangeStream* delta;
   AbsStream* absDelta;
   RmaOnStream* ema_r1;
   RmaOnStream* ema_r2;
   RmaOnStream* ema_s1;
   RmaOnStream* ema_s2;
public:
   TSIOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      delta = new ChangeStream(source);
      absDelta = new AbsStream(delta);
      ema_r1 = new RmaOnStream(delta, length);
      ema_r2 = new RmaOnStream(absDelta, length);
      ema_s1 = new RmaOnStream(ema_r1, length);
      ema_s2 = new RmaOnStream(ema_r2, length);
   }

   ~TSIOnStream()
   {
      delta.Release();
      absDelta.Release();
      ema_r1.Release();
      ema_r2.Release();
      ema_s1.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double s2;
      if (!ema_s2.GetValue(period, s2))
      {
         return false;
      }
      double s1;
      if (!ema_s1.GetValue(period, s1))
      {
         return false;
      }
      val = s2 == 0 ? 0 : 100 * s1 / s2;
      return true;
   }
};



// RSI stream v1.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSIStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSIStream(IStream* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff;
      if (period == totalBars - 1 || _pos[period + 1])
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValue(period + i, diff))
            {
               return false;
            }
            if (diff >= 0)
            {
               sump = sump + diff;
            }
            else
            {
               sumn = sumn - diff;
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValue(period, diff))
         {
            return false;
         }
         if (diff > 0)
         {
            sump = diff;
         }
         else
         {
            sumn = -diff;
         }
         positive = (_pos[period + 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period + 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};

#endif


// Rate of change stream v1.0

class ROCOnStream : public AOnStream
{
   double _length;
public:
   ROCOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   ~ROCOnStream()
   {
   }

   bool GetValue(const int period, double &val)
   {
      double pr;
      if (!_source.GetValue(period + _length, pr) || pr == 0)
      {
         val = 0;
         return true;
      }
      double currPrice;
      if (!_source.GetValue(period, currPrice))
      {
         val = 0;
         return true;
      }
      val = (currPrice / pr - 1) * 100;
      return true;
   }
};
IndicatorOutputStream* tsi29Source;
IStream* tsi29;
IndicatorOutputStream* tsi30Source;
IStream* tsi30;
IndicatorOutputStream* tsi31Source;
IStream* tsi31;
IndicatorOutputStream* tsi32Source;
IStream* tsi32;
IndicatorOutputStream* tsi33Source;
IStream* tsi33;
IndicatorOutputStream* tsi34Source;
IStream* tsi34;
IndicatorOutputStream* tsi35Source;
IStream* tsi35;
IndicatorOutputStream* tsi36Source;
IStream* tsi36;
IndicatorOutputStream* tsi37Source;
IStream* tsi37;
IndicatorOutputStream* tsi38Source;
IStream* tsi38;
IndicatorOutputStream* tsi39Source;
IStream* tsi39;
IndicatorOutputStream* tsi40Source;
IStream* tsi40;
IndicatorOutputStream* tsi41Source;
IStream* tsi41;
IndicatorOutputStream* tsi42Source;
IStream* tsi42;
IndicatorOutputStream* tsi43Source;
IStream* tsi43;
IndicatorOutputStream* tsi44Source;
IStream* tsi44;
IndicatorOutputStream* tsi45Source;
IStream* tsi45;
IndicatorOutputStream* tsi46Source;
IStream* tsi46;
IndicatorOutputStream* tsi47Source;
IStream* tsi47;
IndicatorOutputStream* tsi48Source;
IStream* tsi48;
IndicatorOutputStream* tsi49Source;
IStream* tsi49;
IndicatorOutputStream* tsi50Source;
IStream* tsi50;
IndicatorOutputStream* tsi51Source;
IStream* tsi51;
IndicatorOutputStream* tsi52Source;
IStream* tsi52;
IndicatorOutputStream* tsi53Source;
IStream* tsi53;
IndicatorOutputStream* tsi54Source;
IStream* tsi54;
IndicatorOutputStream* tsi55Source;
IStream* tsi55;
IndicatorOutputStream* tsi56Source;
IStream* tsi56;
IndicatorOutputStream* tsi57Source;
IStream* tsi57;
IndicatorOutputStream* tsi58Source;
IStream* tsi58;
IndicatorOutputStream* tsi59Source;
IStream* tsi59;
IndicatorOutputStream* tsi60Source;
IStream* tsi60;
IndicatorOutputStream* tsi61Source;
IStream* tsi61;
IndicatorOutputStream* tsi62Source;
IStream* tsi62;
IndicatorOutputStream* tsi63Source;
IStream* tsi63;
IndicatorOutputStream* tsi64Source;
IStream* tsi64;
IndicatorOutputStream* tsi65Source;
IStream* tsi65;
IndicatorOutputStream* tsi66Source;
IStream* tsi66;
IndicatorOutputStream* tsi67Source;
IStream* tsi67;
IndicatorOutputStream* tsi68Source;
IStream* tsi68;
IndicatorOutputStream* tsi69Source;
IStream* tsi69;
IndicatorOutputStream* tsi70Source;
IStream* tsi70;
IndicatorOutputStream* tsi71Source;
IStream* tsi71;
IndicatorOutputStream* tsi72Source;
IStream* tsi72;
IndicatorOutputStream* tsi73Source;
IStream* tsi73;
IndicatorOutputStream* tsi74Source;
IStream* tsi74;
IndicatorOutputStream* tsi75Source;
IStream* tsi75;
IndicatorOutputStream* tsi76Source;
IStream* tsi76;
IndicatorOutputStream* tsi77Source;
IStream* tsi77;
IndicatorOutputStream* tsi78Source;
IStream* tsi78;
IndicatorOutputStream* tsi79Source;
IStream* tsi79;
IndicatorOutputStream* tsi80Source;
IStream* tsi80;
IndicatorOutputStream* tsi81Source;
IStream* tsi81;
IndicatorOutputStream* tsi82Source;
IStream* tsi82;
IndicatorOutputStream* tsi83Source;
IStream* tsi83;
IndicatorOutputStream* tsi84Source;
IStream* tsi84;
IndicatorOutputStream* rsi85X;
IStream* rsi85;
IndicatorOutputStream* rsi86X;
IStream* rsi86;
IndicatorOutputStream* rsi87X;
IStream* rsi87;
IndicatorOutputStream* rsi88X;
IStream* rsi88;
IndicatorOutputStream* rsi89X;
IStream* rsi89;
IndicatorOutputStream* rsi90X;
IStream* rsi90;
IndicatorOutputStream* rsi91X;
IStream* rsi91;
IndicatorOutputStream* rsi92X;
IStream* rsi92;
IndicatorOutputStream* rsi93X;
IStream* rsi93;
IndicatorOutputStream* rsi94X;
IStream* rsi94;
IndicatorOutputStream* rsi95X;
IStream* rsi95;
IndicatorOutputStream* rsi96X;
IStream* rsi96;
IndicatorOutputStream* rsi97X;
IStream* rsi97;
IndicatorOutputStream* rsi98X;
IStream* rsi98;
IndicatorOutputStream* rsi99X;
IStream* rsi99;
IndicatorOutputStream* rsi100X;
IStream* rsi100;
IndicatorOutputStream* rsi101X;
IStream* rsi101;
IndicatorOutputStream* rsi102X;
IStream* rsi102;
IndicatorOutputStream* rsi103X;
IStream* rsi103;
IndicatorOutputStream* rsi104X;
IStream* rsi104;
IndicatorOutputStream* rsi105X;
IStream* rsi105;
IndicatorOutputStream* rsi106X;
IStream* rsi106;
IndicatorOutputStream* rsi107X;
IStream* rsi107;
IndicatorOutputStream* rsi108X;
IStream* rsi108;
IndicatorOutputStream* rsi109X;
IStream* rsi109;
IndicatorOutputStream* rsi110X;
IStream* rsi110;
IndicatorOutputStream* rsi111X;
IStream* rsi111;
IndicatorOutputStream* rsi112X;
IStream* rsi112;
IndicatorOutputStream* rsi113X;
IStream* rsi113;
IndicatorOutputStream* rsi114X;
IStream* rsi114;
IndicatorOutputStream* rsi115X;
IStream* rsi115;
IndicatorOutputStream* rsi116X;
IStream* rsi116;
IndicatorOutputStream* rsi117X;
IStream* rsi117;
IndicatorOutputStream* rsi118X;
IStream* rsi118;
IndicatorOutputStream* rsi119X;
IStream* rsi119;
IndicatorOutputStream* rsi120X;
IStream* rsi120;
IndicatorOutputStream* rsi121X;
IStream* rsi121;
IndicatorOutputStream* rsi122X;
IStream* rsi122;
IndicatorOutputStream* rsi123X;
IStream* rsi123;
IndicatorOutputStream* rsi124X;
IStream* rsi124;
IndicatorOutputStream* rsi125X;
IStream* rsi125;
IndicatorOutputStream* rsi126X;
IStream* rsi126;
IndicatorOutputStream* rsi127X;
IStream* rsi127;
IndicatorOutputStream* rsi128X;
IStream* rsi128;
IndicatorOutputStream* rsi129X;
IStream* rsi129;
IndicatorOutputStream* rsi130X;
IStream* rsi130;
IndicatorOutputStream* rsi131X;
IStream* rsi131;
IndicatorOutputStream* rsi132X;
IStream* rsi132;
IndicatorOutputStream* rsi133X;
IStream* rsi133;
IndicatorOutputStream* rsi134X;
IStream* rsi134;
IndicatorOutputStream* rsi135X;
IStream* rsi135;
IndicatorOutputStream* rsi136X;
IStream* rsi136;
IndicatorOutputStream* rsi137X;
IStream* rsi137;
IndicatorOutputStream* rsi138X;
IStream* rsi138;
IndicatorOutputStream* rsi139X;
IStream* rsi139;
IndicatorOutputStream* rsi140X;
IStream* rsi140;
IndicatorOutputStream* roc141Source;
IStream* roc141;
IndicatorOutputStream* roc142Source;
IStream* roc142;
IndicatorOutputStream* roc143Source;
IStream* roc143;
IndicatorOutputStream* roc144Source;
IStream* roc144;
IndicatorOutputStream* roc145Source;
IStream* roc145;
IndicatorOutputStream* roc146Source;
IStream* roc146;
IndicatorOutputStream* roc147Source;
IStream* roc147;
IndicatorOutputStream* roc148Source;
IStream* roc148;
IndicatorOutputStream* roc149Source;
IStream* roc149;
IndicatorOutputStream* roc150Source;
IStream* roc150;
IndicatorOutputStream* roc151Source;
IStream* roc151;
IndicatorOutputStream* roc152Source;
IStream* roc152;
IndicatorOutputStream* roc153Source;
IStream* roc153;
IndicatorOutputStream* roc154Source;
IStream* roc154;
IndicatorOutputStream* roc155Source;
IStream* roc155;
IndicatorOutputStream* roc156Source;
IStream* roc156;
IndicatorOutputStream* roc157Source;
IStream* roc157;
IndicatorOutputStream* roc158Source;
IStream* roc158;
IndicatorOutputStream* roc159Source;
IStream* roc159;
IndicatorOutputStream* roc160Source;
IStream* roc160;
IndicatorOutputStream* roc161Source;
IStream* roc161;
IndicatorOutputStream* roc162Source;
IStream* roc162;
IndicatorOutputStream* roc163Source;
IStream* roc163;
IndicatorOutputStream* roc164Source;
IStream* roc164;
IndicatorOutputStream* roc165Source;
IStream* roc165;
IndicatorOutputStream* roc166Source;
IStream* roc166;
IndicatorOutputStream* roc167Source;
IStream* roc167;
IndicatorOutputStream* roc168Source;
IStream* roc168;
IndicatorOutputStream* roc169Source;
IStream* roc169;
IndicatorOutputStream* roc170Source;
IStream* roc170;
IndicatorOutputStream* roc171Source;
IStream* roc171;
IndicatorOutputStream* roc172Source;
IStream* roc172;
IndicatorOutputStream* roc173Source;
IStream* roc173;
IndicatorOutputStream* roc174Source;
IStream* roc174;
IndicatorOutputStream* roc175Source;
IStream* roc175;
IndicatorOutputStream* roc176Source;
IStream* roc176;
IndicatorOutputStream* roc177Source;
IStream* roc177;
IndicatorOutputStream* roc178Source;
IStream* roc178;
IndicatorOutputStream* roc179Source;
IStream* roc179;
IndicatorOutputStream* roc180Source;
IStream* roc180;
IndicatorOutputStream* roc181Source;
IStream* roc181;
IndicatorOutputStream* roc182Source;
IStream* roc182;
IndicatorOutputStream* roc183Source;
IStream* roc183;
IndicatorOutputStream* roc184Source;
IStream* roc184;
IndicatorOutputStream* roc185Source;
IStream* roc185;
IndicatorOutputStream* roc186Source;
IStream* roc186;
IndicatorOutputStream* roc187Source;
IStream* roc187;
IndicatorOutputStream* roc188Source;
IStream* roc188;
IndicatorOutputStream* roc189Source;
IStream* roc189;
IndicatorOutputStream* roc190Source;
IStream* roc190;
IndicatorOutputStream* roc191Source;
IStream* roc191;
IndicatorOutputStream* roc192Source;
IStream* roc192;
IndicatorOutputStream* roc193Source;
IStream* roc193;
IndicatorOutputStream* roc194Source;
IStream* roc194;
IndicatorOutputStream* roc195Source;
IStream* roc195;
IndicatorOutputStream* roc196Source;
IStream* roc196;
IndicatorOutputStream* LRSFunc1param1;
LRSStream* LRSFunc1;
IndicatorOutputStream* LRSFunc2param1;
LRSStream* LRSFunc2;
IndicatorOutputStream* LRSFunc3param1;
LRSStream* LRSFunc3;
IndicatorOutputStream* LRSFunc4param1;
LRSStream* LRSFunc4;
IndicatorOutputStream* LRSFunc5param1;
LRSStream* LRSFunc5;
IndicatorOutputStream* LRSFunc6param1;
LRSStream* LRSFunc6;
IndicatorOutputStream* LRSFunc7param1;
LRSStream* LRSFunc7;
IndicatorOutputStream* LRSFunc8param1;
LRSStream* LRSFunc8;
IndicatorOutputStream* LRSFunc9param1;
LRSStream* LRSFunc9;
IndicatorOutputStream* LRSFunc10param1;
LRSStream* LRSFunc10;
IndicatorOutputStream* LRSFunc11param1;
LRSStream* LRSFunc11;
IndicatorOutputStream* LRSFunc12param1;
LRSStream* LRSFunc12;
IndicatorOutputStream* LRSFunc13param1;
LRSStream* LRSFunc13;
IndicatorOutputStream* LRSFunc14param1;
LRSStream* LRSFunc14;
IndicatorOutputStream* LRSFunc15param1;
LRSStream* LRSFunc15;
IndicatorOutputStream* LRSFunc16param1;
LRSStream* LRSFunc16;
IndicatorOutputStream* LRSFunc17param1;
LRSStream* LRSFunc17;
IndicatorOutputStream* LRSFunc18param1;
LRSStream* LRSFunc18;
IndicatorOutputStream* LRSFunc19param1;
LRSStream* LRSFunc19;
IndicatorOutputStream* LRSFunc20param1;
LRSStream* LRSFunc20;
IndicatorOutputStream* LRSFunc21param1;
LRSStream* LRSFunc21;
IndicatorOutputStream* LRSFunc22param1;
LRSStream* LRSFunc22;
IndicatorOutputStream* LRSFunc23param1;
LRSStream* LRSFunc23;
IndicatorOutputStream* LRSFunc24param1;
LRSStream* LRSFunc24;
IndicatorOutputStream* LRSFunc25param1;
LRSStream* LRSFunc25;
IndicatorOutputStream* LRSFunc26param1;
LRSStream* LRSFunc26;
IndicatorOutputStream* LRSFunc27param1;
LRSStream* LRSFunc27;
IndicatorOutputStream* LRSFunc28param1;
LRSStream* LRSFunc28;
IndicatorOutputStream* LRSFunc29param1;
LRSStream* LRSFunc29;
IndicatorOutputStream* LRSFunc30param1;
LRSStream* LRSFunc30;
IndicatorOutputStream* LRSFunc31param1;
LRSStream* LRSFunc31;
IndicatorOutputStream* LRSFunc32param1;
LRSStream* LRSFunc32;
IndicatorOutputStream* LRSFunc33param1;
LRSStream* LRSFunc33;
IndicatorOutputStream* LRSFunc34param1;
LRSStream* LRSFunc34;
IndicatorOutputStream* LRSFunc35param1;
LRSStream* LRSFunc35;
IndicatorOutputStream* LRSFunc36param1;
LRSStream* LRSFunc36;
IndicatorOutputStream* LRSFunc37param1;
LRSStream* LRSFunc37;
IndicatorOutputStream* LRSFunc38param1;
LRSStream* LRSFunc38;
IndicatorOutputStream* LRSFunc39param1;
LRSStream* LRSFunc39;
IndicatorOutputStream* LRSFunc40param1;
LRSStream* LRSFunc40;
IndicatorOutputStream* LRSFunc41param1;
LRSStream* LRSFunc41;
IndicatorOutputStream* LRSFunc42param1;
LRSStream* LRSFunc42;
IndicatorOutputStream* LRSFunc43param1;
LRSStream* LRSFunc43;
IndicatorOutputStream* LRSFunc44param1;
LRSStream* LRSFunc44;
IndicatorOutputStream* LRSFunc45param1;
LRSStream* LRSFunc45;
IndicatorOutputStream* LRSFunc46param1;
LRSStream* LRSFunc46;
IndicatorOutputStream* LRSFunc47param1;
LRSStream* LRSFunc47;
IndicatorOutputStream* LRSFunc48param1;
LRSStream* LRSFunc48;
IndicatorOutputStream* LRSFunc49param1;
LRSStream* LRSFunc49;
IndicatorOutputStream* LRSFunc50param1;
LRSStream* LRSFunc50;
IndicatorOutputStream* LRSFunc51param1;
LRSStream* LRSFunc51;
IndicatorOutputStream* LRSFunc52param1;
LRSStream* LRSFunc52;
IndicatorOutputStream* LRSFunc53param1;
LRSStream* LRSFunc53;
IndicatorOutputStream* LRSFunc54param1;
LRSStream* LRSFunc54;
IndicatorOutputStream* LRSFunc55param1;
LRSStream* LRSFunc55;
IndicatorOutputStream* LRSFunc56param1;
LRSStream* LRSFunc56;
IndicatorOutputStream* calc_abssioFunc57param1;
calc_abssioStream* calc_abssioFunc57;
IndicatorOutputStream* calc_abssioFunc58param1;
calc_abssioStream* calc_abssioFunc58;
IndicatorOutputStream* calc_abssioFunc59param1;
calc_abssioStream* calc_abssioFunc59;
IndicatorOutputStream* calc_abssioFunc60param1;
calc_abssioStream* calc_abssioFunc60;
IndicatorOutputStream* calc_abssioFunc61param1;
calc_abssioStream* calc_abssioFunc61;
IndicatorOutputStream* calc_abssioFunc62param1;
calc_abssioStream* calc_abssioFunc62;
IndicatorOutputStream* calc_abssioFunc63param1;
calc_abssioStream* calc_abssioFunc63;
IndicatorOutputStream* calc_abssioFunc64param1;
calc_abssioStream* calc_abssioFunc64;
IndicatorOutputStream* calc_abssioFunc65param1;
calc_abssioStream* calc_abssioFunc65;
IndicatorOutputStream* calc_abssioFunc66param1;
calc_abssioStream* calc_abssioFunc66;
IndicatorOutputStream* calc_abssioFunc67param1;
calc_abssioStream* calc_abssioFunc67;
IndicatorOutputStream* calc_abssioFunc68param1;
calc_abssioStream* calc_abssioFunc68;
IndicatorOutputStream* calc_abssioFunc69param1;
calc_abssioStream* calc_abssioFunc69;
IndicatorOutputStream* calc_abssioFunc70param1;
calc_abssioStream* calc_abssioFunc70;
IndicatorOutputStream* calc_abssioFunc71param1;
calc_abssioStream* calc_abssioFunc71;
IndicatorOutputStream* calc_abssioFunc72param1;
calc_abssioStream* calc_abssioFunc72;
IndicatorOutputStream* calc_abssioFunc73param1;
calc_abssioStream* calc_abssioFunc73;
IndicatorOutputStream* calc_abssioFunc74param1;
calc_abssioStream* calc_abssioFunc74;
IndicatorOutputStream* calc_abssioFunc75param1;
calc_abssioStream* calc_abssioFunc75;
IndicatorOutputStream* calc_abssioFunc76param1;
calc_abssioStream* calc_abssioFunc76;
IndicatorOutputStream* calc_abssioFunc77param1;
calc_abssioStream* calc_abssioFunc77;
IndicatorOutputStream* calc_abssioFunc78param1;
calc_abssioStream* calc_abssioFunc78;
IndicatorOutputStream* calc_abssioFunc79param1;
calc_abssioStream* calc_abssioFunc79;
IndicatorOutputStream* calc_abssioFunc80param1;
calc_abssioStream* calc_abssioFunc80;
IndicatorOutputStream* calc_abssioFunc81param1;
calc_abssioStream* calc_abssioFunc81;
IndicatorOutputStream* calc_abssioFunc82param1;
calc_abssioStream* calc_abssioFunc82;
IndicatorOutputStream* calc_abssioFunc83param1;
calc_abssioStream* calc_abssioFunc83;
IndicatorOutputStream* calc_abssioFunc84param1;
calc_abssioStream* calc_abssioFunc84;
IndicatorOutputStream* calc_abssioFunc85param1;
calc_abssioStream* calc_abssioFunc85;
IndicatorOutputStream* calc_abssioFunc86param1;
calc_abssioStream* calc_abssioFunc86;
IndicatorOutputStream* calc_abssioFunc87param1;
calc_abssioStream* calc_abssioFunc87;
IndicatorOutputStream* calc_abssioFunc88param1;
calc_abssioStream* calc_abssioFunc88;
IndicatorOutputStream* calc_abssioFunc89param1;
calc_abssioStream* calc_abssioFunc89;
IndicatorOutputStream* calc_abssioFunc90param1;
calc_abssioStream* calc_abssioFunc90;
IndicatorOutputStream* calc_abssioFunc91param1;
calc_abssioStream* calc_abssioFunc91;
IndicatorOutputStream* calc_abssioFunc92param1;
calc_abssioStream* calc_abssioFunc92;
IndicatorOutputStream* calc_abssioFunc93param1;
calc_abssioStream* calc_abssioFunc93;
IndicatorOutputStream* calc_abssioFunc94param1;
calc_abssioStream* calc_abssioFunc94;
IndicatorOutputStream* calc_abssioFunc95param1;
calc_abssioStream* calc_abssioFunc95;
IndicatorOutputStream* calc_abssioFunc96param1;
calc_abssioStream* calc_abssioFunc96;
IndicatorOutputStream* calc_abssioFunc97param1;
calc_abssioStream* calc_abssioFunc97;
IndicatorOutputStream* calc_abssioFunc98param1;
calc_abssioStream* calc_abssioFunc98;
IndicatorOutputStream* calc_abssioFunc99param1;
calc_abssioStream* calc_abssioFunc99;
IndicatorOutputStream* calc_abssioFunc100param1;
calc_abssioStream* calc_abssioFunc100;
IndicatorOutputStream* calc_abssioFunc101param1;
calc_abssioStream* calc_abssioFunc101;
IndicatorOutputStream* calc_abssioFunc102param1;
calc_abssioStream* calc_abssioFunc102;
IndicatorOutputStream* calc_abssioFunc103param1;
calc_abssioStream* calc_abssioFunc103;
IndicatorOutputStream* calc_abssioFunc104param1;
calc_abssioStream* calc_abssioFunc104;
IndicatorOutputStream* calc_abssioFunc105param1;
calc_abssioStream* calc_abssioFunc105;
IndicatorOutputStream* calc_abssioFunc106param1;
calc_abssioStream* calc_abssioFunc106;
IndicatorOutputStream* calc_abssioFunc107param1;
calc_abssioStream* calc_abssioFunc107;
IndicatorOutputStream* calc_abssioFunc108param1;
calc_abssioStream* calc_abssioFunc108;
IndicatorOutputStream* calc_abssioFunc109param1;
calc_abssioStream* calc_abssioFunc109;
IndicatorOutputStream* calc_abssioFunc110param1;
calc_abssioStream* calc_abssioFunc110;
IndicatorOutputStream* calc_abssioFunc111param1;
calc_abssioStream* calc_abssioFunc111;
IndicatorOutputStream* calc_abssioFunc112param1;
calc_abssioStream* calc_abssioFunc112;
IndicatorOutputStream* ZSFunc113param1;
ZSStream* ZSFunc113;
IndicatorOutputStream* ZSFunc114param1;
ZSStream* ZSFunc114;
IndicatorOutputStream* ZSFunc115param1;
ZSStream* ZSFunc115;
IndicatorOutputStream* ZSFunc116param1;
ZSStream* ZSFunc116;
IndicatorOutputStream* ZSFunc117param1;
ZSStream* ZSFunc117;
IndicatorOutputStream* ZSFunc118param1;
ZSStream* ZSFunc118;
IndicatorOutputStream* ZSFunc119param1;
ZSStream* ZSFunc119;
IndicatorOutputStream* ZSFunc120param1;
ZSStream* ZSFunc120;
IndicatorOutputStream* ZSFunc121param1;
ZSStream* ZSFunc121;
IndicatorOutputStream* ZSFunc122param1;
ZSStream* ZSFunc122;
IndicatorOutputStream* ZSFunc123param1;
ZSStream* ZSFunc123;
IndicatorOutputStream* ZSFunc124param1;
ZSStream* ZSFunc124;
IndicatorOutputStream* ZSFunc125param1;
ZSStream* ZSFunc125;
IndicatorOutputStream* ZSFunc126param1;
ZSStream* ZSFunc126;
IndicatorOutputStream* ZSFunc127param1;
ZSStream* ZSFunc127;
IndicatorOutputStream* ZSFunc128param1;
ZSStream* ZSFunc128;
IndicatorOutputStream* ZSFunc129param1;
ZSStream* ZSFunc129;
IndicatorOutputStream* ZSFunc130param1;
ZSStream* ZSFunc130;
IndicatorOutputStream* ZSFunc131param1;
ZSStream* ZSFunc131;
IndicatorOutputStream* ZSFunc132param1;
ZSStream* ZSFunc132;
IndicatorOutputStream* ZSFunc133param1;
ZSStream* ZSFunc133;
IndicatorOutputStream* ZSFunc134param1;
ZSStream* ZSFunc134;
IndicatorOutputStream* ZSFunc135param1;
ZSStream* ZSFunc135;
IndicatorOutputStream* ZSFunc136param1;
ZSStream* ZSFunc136;
IndicatorOutputStream* ZSFunc137param1;
ZSStream* ZSFunc137;
IndicatorOutputStream* ZSFunc138param1;
ZSStream* ZSFunc138;
IndicatorOutputStream* ZSFunc139param1;
ZSStream* ZSFunc139;
IndicatorOutputStream* ZSFunc140param1;
ZSStream* ZSFunc140;
IndicatorOutputStream* ZSFunc141param1;
ZSStream* ZSFunc141;
IndicatorOutputStream* ZSFunc142param1;
ZSStream* ZSFunc142;
IndicatorOutputStream* ZSFunc143param1;
ZSStream* ZSFunc143;
IndicatorOutputStream* ZSFunc144param1;
ZSStream* ZSFunc144;
IndicatorOutputStream* ZSFunc145param1;
ZSStream* ZSFunc145;
IndicatorOutputStream* ZSFunc146param1;
ZSStream* ZSFunc146;
IndicatorOutputStream* ZSFunc147param1;
ZSStream* ZSFunc147;
IndicatorOutputStream* ZSFunc148param1;
ZSStream* ZSFunc148;
IndicatorOutputStream* ZSFunc149param1;
ZSStream* ZSFunc149;
IndicatorOutputStream* ZSFunc150param1;
ZSStream* ZSFunc150;
IndicatorOutputStream* ZSFunc151param1;
ZSStream* ZSFunc151;
IndicatorOutputStream* ZSFunc152param1;
ZSStream* ZSFunc152;
IndicatorOutputStream* ZSFunc153param1;
ZSStream* ZSFunc153;
IndicatorOutputStream* ZSFunc154param1;
ZSStream* ZSFunc154;
IndicatorOutputStream* ZSFunc155param1;
ZSStream* ZSFunc155;
IndicatorOutputStream* ZSFunc156param1;
ZSStream* ZSFunc156;
IndicatorOutputStream* ZSFunc157param1;
ZSStream* ZSFunc157;
IndicatorOutputStream* ZSFunc158param1;
ZSStream* ZSFunc158;
IndicatorOutputStream* ZSFunc159param1;
ZSStream* ZSFunc159;
IndicatorOutputStream* ZSFunc160param1;
ZSStream* ZSFunc160;
IndicatorOutputStream* ZSFunc161param1;
ZSStream* ZSFunc161;
IndicatorOutputStream* ZSFunc162param1;
ZSStream* ZSFunc162;
IndicatorOutputStream* ZSFunc163param1;
ZSStream* ZSFunc163;
IndicatorOutputStream* ZSFunc164param1;
ZSStream* ZSFunc164;
IndicatorOutputStream* ZSFunc165param1;
ZSStream* ZSFunc165;
IndicatorOutputStream* ZSFunc166param1;
ZSStream* ZSFunc166;
IndicatorOutputStream* ZSFunc167param1;
ZSStream* ZSFunc167;
IndicatorOutputStream* ZSFunc168param1;
ZSStream* ZSFunc168;
IndicatorOutputStream* functionFunc169param1;
functionStream* functionFunc169;
IndicatorOutputStream* functionFunc170param1;
functionStream* functionFunc170;
IndicatorOutputStream* functionFunc171param1;
functionStream* functionFunc171;
IndicatorOutputStream* functionFunc172param1;
functionStream* functionFunc172;
IndicatorOutputStream* functionFunc173param1;
functionStream* functionFunc173;
IndicatorOutputStream* functionFunc174param1;
functionStream* functionFunc174;
IndicatorOutputStream* functionFunc175param1;
functionStream* functionFunc175;
IndicatorOutputStream* functionFunc176param1;
functionStream* functionFunc176;
IndicatorOutputStream* functionFunc177param1;
functionStream* functionFunc177;
IndicatorOutputStream* functionFunc178param1;
functionStream* functionFunc178;
IndicatorOutputStream* functionFunc179param1;
functionStream* functionFunc179;
IndicatorOutputStream* functionFunc180param1;
functionStream* functionFunc180;
IndicatorOutputStream* functionFunc181param1;
functionStream* functionFunc181;
IndicatorOutputStream* functionFunc182param1;
functionStream* functionFunc182;
IndicatorOutputStream* functionFunc183param1;
functionStream* functionFunc183;
IndicatorOutputStream* functionFunc184param1;
functionStream* functionFunc184;
IndicatorOutputStream* functionFunc185param1;
functionStream* functionFunc185;
IndicatorOutputStream* functionFunc186param1;
functionStream* functionFunc186;
IndicatorOutputStream* functionFunc187param1;
functionStream* functionFunc187;
IndicatorOutputStream* functionFunc188param1;
functionStream* functionFunc188;
IndicatorOutputStream* functionFunc189param1;
functionStream* functionFunc189;
IndicatorOutputStream* functionFunc190param1;
functionStream* functionFunc190;
IndicatorOutputStream* functionFunc191param1;
functionStream* functionFunc191;
IndicatorOutputStream* functionFunc192param1;
functionStream* functionFunc192;
IndicatorOutputStream* functionFunc193param1;
functionStream* functionFunc193;
IndicatorOutputStream* functionFunc194param1;
functionStream* functionFunc194;
IndicatorOutputStream* functionFunc195param1;
functionStream* functionFunc195;
IndicatorOutputStream* functionFunc196param1;
functionStream* functionFunc196;
IndicatorOutputStream* functionFunc197param1;
functionStream* functionFunc197;
IndicatorOutputStream* functionFunc198param1;
functionStream* functionFunc198;
IndicatorOutputStream* functionFunc199param1;
functionStream* functionFunc199;
IndicatorOutputStream* functionFunc200param1;
functionStream* functionFunc200;
IndicatorOutputStream* functionFunc201param1;
functionStream* functionFunc201;
IndicatorOutputStream* functionFunc202param1;
functionStream* functionFunc202;
IndicatorOutputStream* functionFunc203param1;
functionStream* functionFunc203;
IndicatorOutputStream* functionFunc204param1;
functionStream* functionFunc204;
IndicatorOutputStream* functionFunc205param1;
functionStream* functionFunc205;
IndicatorOutputStream* functionFunc206param1;
functionStream* functionFunc206;
IndicatorOutputStream* functionFunc207param1;
functionStream* functionFunc207;
IndicatorOutputStream* functionFunc208param1;
functionStream* functionFunc208;
IndicatorOutputStream* functionFunc209param1;
functionStream* functionFunc209;
IndicatorOutputStream* functionFunc210param1;
functionStream* functionFunc210;
IndicatorOutputStream* functionFunc211param1;
functionStream* functionFunc211;
IndicatorOutputStream* functionFunc212param1;
functionStream* functionFunc212;
IndicatorOutputStream* functionFunc213param1;
functionStream* functionFunc213;
IndicatorOutputStream* functionFunc214param1;
functionStream* functionFunc214;
IndicatorOutputStream* functionFunc215param1;
functionStream* functionFunc215;
IndicatorOutputStream* functionFunc216param1;
functionStream* functionFunc216;
IndicatorOutputStream* functionFunc217param1;
functionStream* functionFunc217;
IndicatorOutputStream* functionFunc218param1;
functionStream* functionFunc218;
IndicatorOutputStream* functionFunc219param1;
functionStream* functionFunc219;
IndicatorOutputStream* functionFunc220param1;
functionStream* functionFunc220;
IndicatorOutputStream* functionFunc221param1;
functionStream* functionFunc221;
IndicatorOutputStream* functionFunc222param1;
functionStream* functionFunc222;
IndicatorOutputStream* functionFunc223param1;
functionStream* functionFunc223;
IndicatorOutputStream* functionFunc224param1;
functionStream* functionFunc224;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("CSI");
   IndicatorShortName("FX Currency Strength Indicator");
   IndicatorBuffers(401);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, linreg);
   tsi29Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi29Source.RegisterInternalStream(id);
   tsi29 = new TSIOnStream(tsi29Source, fastlen);
   tsi30Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi30Source.RegisterInternalStream(id);
   tsi30 = new TSIOnStream(tsi30Source, fastlen);
   tsi31Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi31Source.RegisterInternalStream(id);
   tsi31 = new TSIOnStream(tsi31Source, fastlen);
   tsi32Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi32Source.RegisterInternalStream(id);
   tsi32 = new TSIOnStream(tsi32Source, fastlen);
   tsi33Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi33Source.RegisterInternalStream(id);
   tsi33 = new TSIOnStream(tsi33Source, fastlen);
   tsi34Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi34Source.RegisterInternalStream(id);
   tsi34 = new TSIOnStream(tsi34Source, fastlen);
   tsi35Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi35Source.RegisterInternalStream(id);
   tsi35 = new TSIOnStream(tsi35Source, fastlen);
   tsi36Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi36Source.RegisterInternalStream(id);
   tsi36 = new TSIOnStream(tsi36Source, fastlen);
   tsi37Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi37Source.RegisterInternalStream(id);
   tsi37 = new TSIOnStream(tsi37Source, fastlen);
   tsi38Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi38Source.RegisterInternalStream(id);
   tsi38 = new TSIOnStream(tsi38Source, fastlen);
   tsi39Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi39Source.RegisterInternalStream(id);
   tsi39 = new TSIOnStream(tsi39Source, fastlen);
   tsi40Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi40Source.RegisterInternalStream(id);
   tsi40 = new TSIOnStream(tsi40Source, fastlen);
   tsi41Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi41Source.RegisterInternalStream(id);
   tsi41 = new TSIOnStream(tsi41Source, fastlen);
   tsi42Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi42Source.RegisterInternalStream(id);
   tsi42 = new TSIOnStream(tsi42Source, fastlen);
   tsi43Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi43Source.RegisterInternalStream(id);
   tsi43 = new TSIOnStream(tsi43Source, fastlen);
   tsi44Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi44Source.RegisterInternalStream(id);
   tsi44 = new TSIOnStream(tsi44Source, fastlen);
   tsi45Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi45Source.RegisterInternalStream(id);
   tsi45 = new TSIOnStream(tsi45Source, fastlen);
   tsi46Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi46Source.RegisterInternalStream(id);
   tsi46 = new TSIOnStream(tsi46Source, fastlen);
   tsi47Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi47Source.RegisterInternalStream(id);
   tsi47 = new TSIOnStream(tsi47Source, fastlen);
   tsi48Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi48Source.RegisterInternalStream(id);
   tsi48 = new TSIOnStream(tsi48Source, fastlen);
   tsi49Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi49Source.RegisterInternalStream(id);
   tsi49 = new TSIOnStream(tsi49Source, fastlen);
   tsi50Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi50Source.RegisterInternalStream(id);
   tsi50 = new TSIOnStream(tsi50Source, fastlen);
   tsi51Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi51Source.RegisterInternalStream(id);
   tsi51 = new TSIOnStream(tsi51Source, fastlen);
   tsi52Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi52Source.RegisterInternalStream(id);
   tsi52 = new TSIOnStream(tsi52Source, fastlen);
   tsi53Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi53Source.RegisterInternalStream(id);
   tsi53 = new TSIOnStream(tsi53Source, fastlen);
   tsi54Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi54Source.RegisterInternalStream(id);
   tsi54 = new TSIOnStream(tsi54Source, fastlen);
   tsi55Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi55Source.RegisterInternalStream(id);
   tsi55 = new TSIOnStream(tsi55Source, fastlen);
   tsi56Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi56Source.RegisterInternalStream(id);
   tsi56 = new TSIOnStream(tsi56Source, fastlen);
   tsi57Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi57Source.RegisterInternalStream(id);
   tsi57 = new TSIOnStream(tsi57Source, fastlen);
   tsi58Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi58Source.RegisterInternalStream(id);
   tsi58 = new TSIOnStream(tsi58Source, fastlen);
   tsi59Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi59Source.RegisterInternalStream(id);
   tsi59 = new TSIOnStream(tsi59Source, fastlen);
   tsi60Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi60Source.RegisterInternalStream(id);
   tsi60 = new TSIOnStream(tsi60Source, fastlen);
   tsi61Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi61Source.RegisterInternalStream(id);
   tsi61 = new TSIOnStream(tsi61Source, fastlen);
   tsi62Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi62Source.RegisterInternalStream(id);
   tsi62 = new TSIOnStream(tsi62Source, fastlen);
   tsi63Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi63Source.RegisterInternalStream(id);
   tsi63 = new TSIOnStream(tsi63Source, fastlen);
   tsi64Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi64Source.RegisterInternalStream(id);
   tsi64 = new TSIOnStream(tsi64Source, fastlen);
   tsi65Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi65Source.RegisterInternalStream(id);
   tsi65 = new TSIOnStream(tsi65Source, fastlen);
   tsi66Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi66Source.RegisterInternalStream(id);
   tsi66 = new TSIOnStream(tsi66Source, fastlen);
   tsi67Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi67Source.RegisterInternalStream(id);
   tsi67 = new TSIOnStream(tsi67Source, fastlen);
   tsi68Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi68Source.RegisterInternalStream(id);
   tsi68 = new TSIOnStream(tsi68Source, fastlen);
   tsi69Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi69Source.RegisterInternalStream(id);
   tsi69 = new TSIOnStream(tsi69Source, fastlen);
   tsi70Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi70Source.RegisterInternalStream(id);
   tsi70 = new TSIOnStream(tsi70Source, fastlen);
   tsi71Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi71Source.RegisterInternalStream(id);
   tsi71 = new TSIOnStream(tsi71Source, fastlen);
   tsi72Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi72Source.RegisterInternalStream(id);
   tsi72 = new TSIOnStream(tsi72Source, fastlen);
   tsi73Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi73Source.RegisterInternalStream(id);
   tsi73 = new TSIOnStream(tsi73Source, fastlen);
   tsi74Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi74Source.RegisterInternalStream(id);
   tsi74 = new TSIOnStream(tsi74Source, fastlen);
   tsi75Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi75Source.RegisterInternalStream(id);
   tsi75 = new TSIOnStream(tsi75Source, fastlen);
   tsi76Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi76Source.RegisterInternalStream(id);
   tsi76 = new TSIOnStream(tsi76Source, fastlen);
   tsi77Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi77Source.RegisterInternalStream(id);
   tsi77 = new TSIOnStream(tsi77Source, fastlen);
   tsi78Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi78Source.RegisterInternalStream(id);
   tsi78 = new TSIOnStream(tsi78Source, fastlen);
   tsi79Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi79Source.RegisterInternalStream(id);
   tsi79 = new TSIOnStream(tsi79Source, fastlen);
   tsi80Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi80Source.RegisterInternalStream(id);
   tsi80 = new TSIOnStream(tsi80Source, fastlen);
   tsi81Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi81Source.RegisterInternalStream(id);
   tsi81 = new TSIOnStream(tsi81Source, fastlen);
   tsi82Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi82Source.RegisterInternalStream(id);
   tsi82 = new TSIOnStream(tsi82Source, fastlen);
   tsi83Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi83Source.RegisterInternalStream(id);
   tsi83 = new TSIOnStream(tsi83Source, fastlen);
   tsi84Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = tsi84Source.RegisterInternalStream(id);
   tsi84 = new TSIOnStream(tsi84Source, fastlen);
   rsi85X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi85X.RegisterInternalStream(id);
   rsi85 = new RSIStream(rsi85X, rsiLen);
   rsi86X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi86X.RegisterInternalStream(id);
   rsi86 = new RSIStream(rsi86X, rsiLen);
   rsi87X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi87X.RegisterInternalStream(id);
   rsi87 = new RSIStream(rsi87X, rsiLen);
   rsi88X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi88X.RegisterInternalStream(id);
   rsi88 = new RSIStream(rsi88X, rsiLen);
   rsi89X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi89X.RegisterInternalStream(id);
   rsi89 = new RSIStream(rsi89X, rsiLen);
   rsi90X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi90X.RegisterInternalStream(id);
   rsi90 = new RSIStream(rsi90X, rsiLen);
   rsi91X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi91X.RegisterInternalStream(id);
   rsi91 = new RSIStream(rsi91X, rsiLen);
   rsi92X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi92X.RegisterInternalStream(id);
   rsi92 = new RSIStream(rsi92X, rsiLen);
   rsi93X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi93X.RegisterInternalStream(id);
   rsi93 = new RSIStream(rsi93X, rsiLen);
   rsi94X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi94X.RegisterInternalStream(id);
   rsi94 = new RSIStream(rsi94X, rsiLen);
   rsi95X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi95X.RegisterInternalStream(id);
   rsi95 = new RSIStream(rsi95X, rsiLen);
   rsi96X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi96X.RegisterInternalStream(id);
   rsi96 = new RSIStream(rsi96X, rsiLen);
   rsi97X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi97X.RegisterInternalStream(id);
   rsi97 = new RSIStream(rsi97X, rsiLen);
   rsi98X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi98X.RegisterInternalStream(id);
   rsi98 = new RSIStream(rsi98X, rsiLen);
   rsi99X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi99X.RegisterInternalStream(id);
   rsi99 = new RSIStream(rsi99X, rsiLen);
   rsi100X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi100X.RegisterInternalStream(id);
   rsi100 = new RSIStream(rsi100X, rsiLen);
   rsi101X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi101X.RegisterInternalStream(id);
   rsi101 = new RSIStream(rsi101X, rsiLen);
   rsi102X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi102X.RegisterInternalStream(id);
   rsi102 = new RSIStream(rsi102X, rsiLen);
   rsi103X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi103X.RegisterInternalStream(id);
   rsi103 = new RSIStream(rsi103X, rsiLen);
   rsi104X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi104X.RegisterInternalStream(id);
   rsi104 = new RSIStream(rsi104X, rsiLen);
   rsi105X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi105X.RegisterInternalStream(id);
   rsi105 = new RSIStream(rsi105X, rsiLen);
   rsi106X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi106X.RegisterInternalStream(id);
   rsi106 = new RSIStream(rsi106X, rsiLen);
   rsi107X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi107X.RegisterInternalStream(id);
   rsi107 = new RSIStream(rsi107X, rsiLen);
   rsi108X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi108X.RegisterInternalStream(id);
   rsi108 = new RSIStream(rsi108X, rsiLen);
   rsi109X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi109X.RegisterInternalStream(id);
   rsi109 = new RSIStream(rsi109X, rsiLen);
   rsi110X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi110X.RegisterInternalStream(id);
   rsi110 = new RSIStream(rsi110X, rsiLen);
   rsi111X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi111X.RegisterInternalStream(id);
   rsi111 = new RSIStream(rsi111X, rsiLen);
   rsi112X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi112X.RegisterInternalStream(id);
   rsi112 = new RSIStream(rsi112X, rsiLen);
   rsi113X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi113X.RegisterInternalStream(id);
   rsi113 = new RSIStream(rsi113X, rsiLen);
   rsi114X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi114X.RegisterInternalStream(id);
   rsi114 = new RSIStream(rsi114X, rsiLen);
   rsi115X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi115X.RegisterInternalStream(id);
   rsi115 = new RSIStream(rsi115X, rsiLen);
   rsi116X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi116X.RegisterInternalStream(id);
   rsi116 = new RSIStream(rsi116X, rsiLen);
   rsi117X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi117X.RegisterInternalStream(id);
   rsi117 = new RSIStream(rsi117X, rsiLen);
   rsi118X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi118X.RegisterInternalStream(id);
   rsi118 = new RSIStream(rsi118X, rsiLen);
   rsi119X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi119X.RegisterInternalStream(id);
   rsi119 = new RSIStream(rsi119X, rsiLen);
   rsi120X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi120X.RegisterInternalStream(id);
   rsi120 = new RSIStream(rsi120X, rsiLen);
   rsi121X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi121X.RegisterInternalStream(id);
   rsi121 = new RSIStream(rsi121X, rsiLen);
   rsi122X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi122X.RegisterInternalStream(id);
   rsi122 = new RSIStream(rsi122X, rsiLen);
   rsi123X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi123X.RegisterInternalStream(id);
   rsi123 = new RSIStream(rsi123X, rsiLen);
   rsi124X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi124X.RegisterInternalStream(id);
   rsi124 = new RSIStream(rsi124X, rsiLen);
   rsi125X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi125X.RegisterInternalStream(id);
   rsi125 = new RSIStream(rsi125X, rsiLen);
   rsi126X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi126X.RegisterInternalStream(id);
   rsi126 = new RSIStream(rsi126X, rsiLen);
   rsi127X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi127X.RegisterInternalStream(id);
   rsi127 = new RSIStream(rsi127X, rsiLen);
   rsi128X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi128X.RegisterInternalStream(id);
   rsi128 = new RSIStream(rsi128X, rsiLen);
   rsi129X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi129X.RegisterInternalStream(id);
   rsi129 = new RSIStream(rsi129X, rsiLen);
   rsi130X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi130X.RegisterInternalStream(id);
   rsi130 = new RSIStream(rsi130X, rsiLen);
   rsi131X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi131X.RegisterInternalStream(id);
   rsi131 = new RSIStream(rsi131X, rsiLen);
   rsi132X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi132X.RegisterInternalStream(id);
   rsi132 = new RSIStream(rsi132X, rsiLen);
   rsi133X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi133X.RegisterInternalStream(id);
   rsi133 = new RSIStream(rsi133X, rsiLen);
   rsi134X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi134X.RegisterInternalStream(id);
   rsi134 = new RSIStream(rsi134X, rsiLen);
   rsi135X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi135X.RegisterInternalStream(id);
   rsi135 = new RSIStream(rsi135X, rsiLen);
   rsi136X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi136X.RegisterInternalStream(id);
   rsi136 = new RSIStream(rsi136X, rsiLen);
   rsi137X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi137X.RegisterInternalStream(id);
   rsi137 = new RSIStream(rsi137X, rsiLen);
   rsi138X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi138X.RegisterInternalStream(id);
   rsi138 = new RSIStream(rsi138X, rsiLen);
   rsi139X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi139X.RegisterInternalStream(id);
   rsi139 = new RSIStream(rsi139X, rsiLen);
   rsi140X = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = rsi140X.RegisterInternalStream(id);
   rsi140 = new RSIStream(rsi140X, rsiLen);
   roc141Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc141Source.RegisterInternalStream(id);
   roc141 = new ROCOnStream(roc141Source, rocLen);
   roc142Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc142Source.RegisterInternalStream(id);
   roc142 = new ROCOnStream(roc142Source, rocLen);
   roc143Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc143Source.RegisterInternalStream(id);
   roc143 = new ROCOnStream(roc143Source, rocLen);
   roc144Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc144Source.RegisterInternalStream(id);
   roc144 = new ROCOnStream(roc144Source, rocLen);
   roc145Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc145Source.RegisterInternalStream(id);
   roc145 = new ROCOnStream(roc145Source, rocLen);
   roc146Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc146Source.RegisterInternalStream(id);
   roc146 = new ROCOnStream(roc146Source, rocLen);
   roc147Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc147Source.RegisterInternalStream(id);
   roc147 = new ROCOnStream(roc147Source, rocLen);
   roc148Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc148Source.RegisterInternalStream(id);
   roc148 = new ROCOnStream(roc148Source, rocLen);
   roc149Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc149Source.RegisterInternalStream(id);
   roc149 = new ROCOnStream(roc149Source, rocLen);
   roc150Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc150Source.RegisterInternalStream(id);
   roc150 = new ROCOnStream(roc150Source, rocLen);
   roc151Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc151Source.RegisterInternalStream(id);
   roc151 = new ROCOnStream(roc151Source, rocLen);
   roc152Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc152Source.RegisterInternalStream(id);
   roc152 = new ROCOnStream(roc152Source, rocLen);
   roc153Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc153Source.RegisterInternalStream(id);
   roc153 = new ROCOnStream(roc153Source, rocLen);
   roc154Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc154Source.RegisterInternalStream(id);
   roc154 = new ROCOnStream(roc154Source, rocLen);
   roc155Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc155Source.RegisterInternalStream(id);
   roc155 = new ROCOnStream(roc155Source, rocLen);
   roc156Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc156Source.RegisterInternalStream(id);
   roc156 = new ROCOnStream(roc156Source, rocLen);
   roc157Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc157Source.RegisterInternalStream(id);
   roc157 = new ROCOnStream(roc157Source, rocLen);
   roc158Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc158Source.RegisterInternalStream(id);
   roc158 = new ROCOnStream(roc158Source, rocLen);
   roc159Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc159Source.RegisterInternalStream(id);
   roc159 = new ROCOnStream(roc159Source, rocLen);
   roc160Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc160Source.RegisterInternalStream(id);
   roc160 = new ROCOnStream(roc160Source, rocLen);
   roc161Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc161Source.RegisterInternalStream(id);
   roc161 = new ROCOnStream(roc161Source, rocLen);
   roc162Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc162Source.RegisterInternalStream(id);
   roc162 = new ROCOnStream(roc162Source, rocLen);
   roc163Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc163Source.RegisterInternalStream(id);
   roc163 = new ROCOnStream(roc163Source, rocLen);
   roc164Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc164Source.RegisterInternalStream(id);
   roc164 = new ROCOnStream(roc164Source, rocLen);
   roc165Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc165Source.RegisterInternalStream(id);
   roc165 = new ROCOnStream(roc165Source, rocLen);
   roc166Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc166Source.RegisterInternalStream(id);
   roc166 = new ROCOnStream(roc166Source, rocLen);
   roc167Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc167Source.RegisterInternalStream(id);
   roc167 = new ROCOnStream(roc167Source, rocLen);
   roc168Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc168Source.RegisterInternalStream(id);
   roc168 = new ROCOnStream(roc168Source, rocLen);
   roc169Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc169Source.RegisterInternalStream(id);
   roc169 = new ROCOnStream(roc169Source, rocLen);
   roc170Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc170Source.RegisterInternalStream(id);
   roc170 = new ROCOnStream(roc170Source, rocLen);
   roc171Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc171Source.RegisterInternalStream(id);
   roc171 = new ROCOnStream(roc171Source, rocLen);
   roc172Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc172Source.RegisterInternalStream(id);
   roc172 = new ROCOnStream(roc172Source, rocLen);
   roc173Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc173Source.RegisterInternalStream(id);
   roc173 = new ROCOnStream(roc173Source, rocLen);
   roc174Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc174Source.RegisterInternalStream(id);
   roc174 = new ROCOnStream(roc174Source, rocLen);
   roc175Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc175Source.RegisterInternalStream(id);
   roc175 = new ROCOnStream(roc175Source, rocLen);
   roc176Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc176Source.RegisterInternalStream(id);
   roc176 = new ROCOnStream(roc176Source, rocLen);
   roc177Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc177Source.RegisterInternalStream(id);
   roc177 = new ROCOnStream(roc177Source, rocLen);
   roc178Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc178Source.RegisterInternalStream(id);
   roc178 = new ROCOnStream(roc178Source, rocLen);
   roc179Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc179Source.RegisterInternalStream(id);
   roc179 = new ROCOnStream(roc179Source, rocLen);
   roc180Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc180Source.RegisterInternalStream(id);
   roc180 = new ROCOnStream(roc180Source, rocLen);
   roc181Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc181Source.RegisterInternalStream(id);
   roc181 = new ROCOnStream(roc181Source, rocLen);
   roc182Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc182Source.RegisterInternalStream(id);
   roc182 = new ROCOnStream(roc182Source, rocLen);
   roc183Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc183Source.RegisterInternalStream(id);
   roc183 = new ROCOnStream(roc183Source, rocLen);
   roc184Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc184Source.RegisterInternalStream(id);
   roc184 = new ROCOnStream(roc184Source, rocLen);
   roc185Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc185Source.RegisterInternalStream(id);
   roc185 = new ROCOnStream(roc185Source, rocLen);
   roc186Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc186Source.RegisterInternalStream(id);
   roc186 = new ROCOnStream(roc186Source, rocLen);
   roc187Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc187Source.RegisterInternalStream(id);
   roc187 = new ROCOnStream(roc187Source, rocLen);
   roc188Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc188Source.RegisterInternalStream(id);
   roc188 = new ROCOnStream(roc188Source, rocLen);
   roc189Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc189Source.RegisterInternalStream(id);
   roc189 = new ROCOnStream(roc189Source, rocLen);
   roc190Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc190Source.RegisterInternalStream(id);
   roc190 = new ROCOnStream(roc190Source, rocLen);
   roc191Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc191Source.RegisterInternalStream(id);
   roc191 = new ROCOnStream(roc191Source, rocLen);
   roc192Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc192Source.RegisterInternalStream(id);
   roc192 = new ROCOnStream(roc192Source, rocLen);
   roc193Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc193Source.RegisterInternalStream(id);
   roc193 = new ROCOnStream(roc193Source, rocLen);
   roc194Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc194Source.RegisterInternalStream(id);
   roc194 = new ROCOnStream(roc194Source, rocLen);
   roc195Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc195Source.RegisterInternalStream(id);
   roc195 = new ROCOnStream(roc195Source, rocLen);
   roc196Source = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = roc196Source.RegisterInternalStream(id);
   roc196 = new ROCOnStream(roc196Source, rocLen);
   LRSFunc1param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc1param1.RegisterInternalStream(id);
   LRSFunc1 = new LRSStream(LRSFunc1param1);
   LRSFunc2param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc2param1.RegisterInternalStream(id);
   LRSFunc2 = new LRSStream(LRSFunc2param1);
   LRSFunc3param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc3param1.RegisterInternalStream(id);
   LRSFunc3 = new LRSStream(LRSFunc3param1);
   LRSFunc4param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc4param1.RegisterInternalStream(id);
   LRSFunc4 = new LRSStream(LRSFunc4param1);
   LRSFunc5param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc5param1.RegisterInternalStream(id);
   LRSFunc5 = new LRSStream(LRSFunc5param1);
   LRSFunc6param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc6param1.RegisterInternalStream(id);
   LRSFunc6 = new LRSStream(LRSFunc6param1);
   LRSFunc7param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc7param1.RegisterInternalStream(id);
   LRSFunc7 = new LRSStream(LRSFunc7param1);
   LRSFunc8param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc8param1.RegisterInternalStream(id);
   LRSFunc8 = new LRSStream(LRSFunc8param1);
   LRSFunc9param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc9param1.RegisterInternalStream(id);
   LRSFunc9 = new LRSStream(LRSFunc9param1);
   LRSFunc10param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc10param1.RegisterInternalStream(id);
   LRSFunc10 = new LRSStream(LRSFunc10param1);
   LRSFunc11param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc11param1.RegisterInternalStream(id);
   LRSFunc11 = new LRSStream(LRSFunc11param1);
   LRSFunc12param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc12param1.RegisterInternalStream(id);
   LRSFunc12 = new LRSStream(LRSFunc12param1);
   LRSFunc13param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc13param1.RegisterInternalStream(id);
   LRSFunc13 = new LRSStream(LRSFunc13param1);
   LRSFunc14param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc14param1.RegisterInternalStream(id);
   LRSFunc14 = new LRSStream(LRSFunc14param1);
   LRSFunc15param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc15param1.RegisterInternalStream(id);
   LRSFunc15 = new LRSStream(LRSFunc15param1);
   LRSFunc16param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc16param1.RegisterInternalStream(id);
   LRSFunc16 = new LRSStream(LRSFunc16param1);
   LRSFunc17param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc17param1.RegisterInternalStream(id);
   LRSFunc17 = new LRSStream(LRSFunc17param1);
   LRSFunc18param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc18param1.RegisterInternalStream(id);
   LRSFunc18 = new LRSStream(LRSFunc18param1);
   LRSFunc19param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc19param1.RegisterInternalStream(id);
   LRSFunc19 = new LRSStream(LRSFunc19param1);
   LRSFunc20param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc20param1.RegisterInternalStream(id);
   LRSFunc20 = new LRSStream(LRSFunc20param1);
   LRSFunc21param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc21param1.RegisterInternalStream(id);
   LRSFunc21 = new LRSStream(LRSFunc21param1);
   LRSFunc22param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc22param1.RegisterInternalStream(id);
   LRSFunc22 = new LRSStream(LRSFunc22param1);
   LRSFunc23param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc23param1.RegisterInternalStream(id);
   LRSFunc23 = new LRSStream(LRSFunc23param1);
   LRSFunc24param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc24param1.RegisterInternalStream(id);
   LRSFunc24 = new LRSStream(LRSFunc24param1);
   LRSFunc25param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc25param1.RegisterInternalStream(id);
   LRSFunc25 = new LRSStream(LRSFunc25param1);
   LRSFunc26param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc26param1.RegisterInternalStream(id);
   LRSFunc26 = new LRSStream(LRSFunc26param1);
   LRSFunc27param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc27param1.RegisterInternalStream(id);
   LRSFunc27 = new LRSStream(LRSFunc27param1);
   LRSFunc28param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc28param1.RegisterInternalStream(id);
   LRSFunc28 = new LRSStream(LRSFunc28param1);
   LRSFunc29param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc29param1.RegisterInternalStream(id);
   LRSFunc29 = new LRSStream(LRSFunc29param1);
   LRSFunc30param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc30param1.RegisterInternalStream(id);
   LRSFunc30 = new LRSStream(LRSFunc30param1);
   LRSFunc31param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc31param1.RegisterInternalStream(id);
   LRSFunc31 = new LRSStream(LRSFunc31param1);
   LRSFunc32param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc32param1.RegisterInternalStream(id);
   LRSFunc32 = new LRSStream(LRSFunc32param1);
   LRSFunc33param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc33param1.RegisterInternalStream(id);
   LRSFunc33 = new LRSStream(LRSFunc33param1);
   LRSFunc34param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc34param1.RegisterInternalStream(id);
   LRSFunc34 = new LRSStream(LRSFunc34param1);
   LRSFunc35param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc35param1.RegisterInternalStream(id);
   LRSFunc35 = new LRSStream(LRSFunc35param1);
   LRSFunc36param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc36param1.RegisterInternalStream(id);
   LRSFunc36 = new LRSStream(LRSFunc36param1);
   LRSFunc37param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc37param1.RegisterInternalStream(id);
   LRSFunc37 = new LRSStream(LRSFunc37param1);
   LRSFunc38param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc38param1.RegisterInternalStream(id);
   LRSFunc38 = new LRSStream(LRSFunc38param1);
   LRSFunc39param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc39param1.RegisterInternalStream(id);
   LRSFunc39 = new LRSStream(LRSFunc39param1);
   LRSFunc40param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc40param1.RegisterInternalStream(id);
   LRSFunc40 = new LRSStream(LRSFunc40param1);
   LRSFunc41param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc41param1.RegisterInternalStream(id);
   LRSFunc41 = new LRSStream(LRSFunc41param1);
   LRSFunc42param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc42param1.RegisterInternalStream(id);
   LRSFunc42 = new LRSStream(LRSFunc42param1);
   LRSFunc43param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc43param1.RegisterInternalStream(id);
   LRSFunc43 = new LRSStream(LRSFunc43param1);
   LRSFunc44param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc44param1.RegisterInternalStream(id);
   LRSFunc44 = new LRSStream(LRSFunc44param1);
   LRSFunc45param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc45param1.RegisterInternalStream(id);
   LRSFunc45 = new LRSStream(LRSFunc45param1);
   LRSFunc46param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc46param1.RegisterInternalStream(id);
   LRSFunc46 = new LRSStream(LRSFunc46param1);
   LRSFunc47param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc47param1.RegisterInternalStream(id);
   LRSFunc47 = new LRSStream(LRSFunc47param1);
   LRSFunc48param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc48param1.RegisterInternalStream(id);
   LRSFunc48 = new LRSStream(LRSFunc48param1);
   LRSFunc49param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc49param1.RegisterInternalStream(id);
   LRSFunc49 = new LRSStream(LRSFunc49param1);
   LRSFunc50param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc50param1.RegisterInternalStream(id);
   LRSFunc50 = new LRSStream(LRSFunc50param1);
   LRSFunc51param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc51param1.RegisterInternalStream(id);
   LRSFunc51 = new LRSStream(LRSFunc51param1);
   LRSFunc52param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc52param1.RegisterInternalStream(id);
   LRSFunc52 = new LRSStream(LRSFunc52param1);
   LRSFunc53param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc53param1.RegisterInternalStream(id);
   LRSFunc53 = new LRSStream(LRSFunc53param1);
   LRSFunc54param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc54param1.RegisterInternalStream(id);
   LRSFunc54 = new LRSStream(LRSFunc54param1);
   LRSFunc55param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc55param1.RegisterInternalStream(id);
   LRSFunc55 = new LRSStream(LRSFunc55param1);
   LRSFunc56param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = LRSFunc56param1.RegisterInternalStream(id);
   LRSFunc56 = new LRSStream(LRSFunc56param1);
   calc_abssioFunc57param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc57param1.RegisterInternalStream(id);
   calc_abssioFunc57 = new calc_abssioStream(calc_abssioFunc57param1);
   calc_abssioFunc58param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc58param1.RegisterInternalStream(id);
   calc_abssioFunc58 = new calc_abssioStream(calc_abssioFunc58param1);
   calc_abssioFunc59param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc59param1.RegisterInternalStream(id);
   calc_abssioFunc59 = new calc_abssioStream(calc_abssioFunc59param1);
   calc_abssioFunc60param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc60param1.RegisterInternalStream(id);
   calc_abssioFunc60 = new calc_abssioStream(calc_abssioFunc60param1);
   calc_abssioFunc61param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc61param1.RegisterInternalStream(id);
   calc_abssioFunc61 = new calc_abssioStream(calc_abssioFunc61param1);
   calc_abssioFunc62param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc62param1.RegisterInternalStream(id);
   calc_abssioFunc62 = new calc_abssioStream(calc_abssioFunc62param1);
   calc_abssioFunc63param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc63param1.RegisterInternalStream(id);
   calc_abssioFunc63 = new calc_abssioStream(calc_abssioFunc63param1);
   calc_abssioFunc64param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc64param1.RegisterInternalStream(id);
   calc_abssioFunc64 = new calc_abssioStream(calc_abssioFunc64param1);
   calc_abssioFunc65param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc65param1.RegisterInternalStream(id);
   calc_abssioFunc65 = new calc_abssioStream(calc_abssioFunc65param1);
   calc_abssioFunc66param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc66param1.RegisterInternalStream(id);
   calc_abssioFunc66 = new calc_abssioStream(calc_abssioFunc66param1);
   calc_abssioFunc67param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc67param1.RegisterInternalStream(id);
   calc_abssioFunc67 = new calc_abssioStream(calc_abssioFunc67param1);
   calc_abssioFunc68param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc68param1.RegisterInternalStream(id);
   calc_abssioFunc68 = new calc_abssioStream(calc_abssioFunc68param1);
   calc_abssioFunc69param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc69param1.RegisterInternalStream(id);
   calc_abssioFunc69 = new calc_abssioStream(calc_abssioFunc69param1);
   calc_abssioFunc70param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc70param1.RegisterInternalStream(id);
   calc_abssioFunc70 = new calc_abssioStream(calc_abssioFunc70param1);
   calc_abssioFunc71param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc71param1.RegisterInternalStream(id);
   calc_abssioFunc71 = new calc_abssioStream(calc_abssioFunc71param1);
   calc_abssioFunc72param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc72param1.RegisterInternalStream(id);
   calc_abssioFunc72 = new calc_abssioStream(calc_abssioFunc72param1);
   calc_abssioFunc73param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc73param1.RegisterInternalStream(id);
   calc_abssioFunc73 = new calc_abssioStream(calc_abssioFunc73param1);
   calc_abssioFunc74param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc74param1.RegisterInternalStream(id);
   calc_abssioFunc74 = new calc_abssioStream(calc_abssioFunc74param1);
   calc_abssioFunc75param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc75param1.RegisterInternalStream(id);
   calc_abssioFunc75 = new calc_abssioStream(calc_abssioFunc75param1);
   calc_abssioFunc76param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc76param1.RegisterInternalStream(id);
   calc_abssioFunc76 = new calc_abssioStream(calc_abssioFunc76param1);
   calc_abssioFunc77param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc77param1.RegisterInternalStream(id);
   calc_abssioFunc77 = new calc_abssioStream(calc_abssioFunc77param1);
   calc_abssioFunc78param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc78param1.RegisterInternalStream(id);
   calc_abssioFunc78 = new calc_abssioStream(calc_abssioFunc78param1);
   calc_abssioFunc79param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc79param1.RegisterInternalStream(id);
   calc_abssioFunc79 = new calc_abssioStream(calc_abssioFunc79param1);
   calc_abssioFunc80param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc80param1.RegisterInternalStream(id);
   calc_abssioFunc80 = new calc_abssioStream(calc_abssioFunc80param1);
   calc_abssioFunc81param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc81param1.RegisterInternalStream(id);
   calc_abssioFunc81 = new calc_abssioStream(calc_abssioFunc81param1);
   calc_abssioFunc82param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc82param1.RegisterInternalStream(id);
   calc_abssioFunc82 = new calc_abssioStream(calc_abssioFunc82param1);
   calc_abssioFunc83param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc83param1.RegisterInternalStream(id);
   calc_abssioFunc83 = new calc_abssioStream(calc_abssioFunc83param1);
   calc_abssioFunc84param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc84param1.RegisterInternalStream(id);
   calc_abssioFunc84 = new calc_abssioStream(calc_abssioFunc84param1);
   calc_abssioFunc85param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc85param1.RegisterInternalStream(id);
   calc_abssioFunc85 = new calc_abssioStream(calc_abssioFunc85param1);
   calc_abssioFunc86param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc86param1.RegisterInternalStream(id);
   calc_abssioFunc86 = new calc_abssioStream(calc_abssioFunc86param1);
   calc_abssioFunc87param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc87param1.RegisterInternalStream(id);
   calc_abssioFunc87 = new calc_abssioStream(calc_abssioFunc87param1);
   calc_abssioFunc88param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc88param1.RegisterInternalStream(id);
   calc_abssioFunc88 = new calc_abssioStream(calc_abssioFunc88param1);
   calc_abssioFunc89param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc89param1.RegisterInternalStream(id);
   calc_abssioFunc89 = new calc_abssioStream(calc_abssioFunc89param1);
   calc_abssioFunc90param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc90param1.RegisterInternalStream(id);
   calc_abssioFunc90 = new calc_abssioStream(calc_abssioFunc90param1);
   calc_abssioFunc91param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc91param1.RegisterInternalStream(id);
   calc_abssioFunc91 = new calc_abssioStream(calc_abssioFunc91param1);
   calc_abssioFunc92param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc92param1.RegisterInternalStream(id);
   calc_abssioFunc92 = new calc_abssioStream(calc_abssioFunc92param1);
   calc_abssioFunc93param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc93param1.RegisterInternalStream(id);
   calc_abssioFunc93 = new calc_abssioStream(calc_abssioFunc93param1);
   calc_abssioFunc94param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc94param1.RegisterInternalStream(id);
   calc_abssioFunc94 = new calc_abssioStream(calc_abssioFunc94param1);
   calc_abssioFunc95param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc95param1.RegisterInternalStream(id);
   calc_abssioFunc95 = new calc_abssioStream(calc_abssioFunc95param1);
   calc_abssioFunc96param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc96param1.RegisterInternalStream(id);
   calc_abssioFunc96 = new calc_abssioStream(calc_abssioFunc96param1);
   calc_abssioFunc97param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc97param1.RegisterInternalStream(id);
   calc_abssioFunc97 = new calc_abssioStream(calc_abssioFunc97param1);
   calc_abssioFunc98param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc98param1.RegisterInternalStream(id);
   calc_abssioFunc98 = new calc_abssioStream(calc_abssioFunc98param1);
   calc_abssioFunc99param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc99param1.RegisterInternalStream(id);
   calc_abssioFunc99 = new calc_abssioStream(calc_abssioFunc99param1);
   calc_abssioFunc100param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc100param1.RegisterInternalStream(id);
   calc_abssioFunc100 = new calc_abssioStream(calc_abssioFunc100param1);
   calc_abssioFunc101param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc101param1.RegisterInternalStream(id);
   calc_abssioFunc101 = new calc_abssioStream(calc_abssioFunc101param1);
   calc_abssioFunc102param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc102param1.RegisterInternalStream(id);
   calc_abssioFunc102 = new calc_abssioStream(calc_abssioFunc102param1);
   calc_abssioFunc103param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc103param1.RegisterInternalStream(id);
   calc_abssioFunc103 = new calc_abssioStream(calc_abssioFunc103param1);
   calc_abssioFunc104param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc104param1.RegisterInternalStream(id);
   calc_abssioFunc104 = new calc_abssioStream(calc_abssioFunc104param1);
   calc_abssioFunc105param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc105param1.RegisterInternalStream(id);
   calc_abssioFunc105 = new calc_abssioStream(calc_abssioFunc105param1);
   calc_abssioFunc106param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc106param1.RegisterInternalStream(id);
   calc_abssioFunc106 = new calc_abssioStream(calc_abssioFunc106param1);
   calc_abssioFunc107param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc107param1.RegisterInternalStream(id);
   calc_abssioFunc107 = new calc_abssioStream(calc_abssioFunc107param1);
   calc_abssioFunc108param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc108param1.RegisterInternalStream(id);
   calc_abssioFunc108 = new calc_abssioStream(calc_abssioFunc108param1);
   calc_abssioFunc109param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc109param1.RegisterInternalStream(id);
   calc_abssioFunc109 = new calc_abssioStream(calc_abssioFunc109param1);
   calc_abssioFunc110param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc110param1.RegisterInternalStream(id);
   calc_abssioFunc110 = new calc_abssioStream(calc_abssioFunc110param1);
   calc_abssioFunc111param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc111param1.RegisterInternalStream(id);
   calc_abssioFunc111 = new calc_abssioStream(calc_abssioFunc111param1);
   calc_abssioFunc112param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = calc_abssioFunc112param1.RegisterInternalStream(id);
   calc_abssioFunc112 = new calc_abssioStream(calc_abssioFunc112param1);
   ZSFunc113param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc113param1.RegisterInternalStream(id);
   ZSFunc113 = new ZSStream(ZSFunc113param1);
   ZSFunc114param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc114param1.RegisterInternalStream(id);
   ZSFunc114 = new ZSStream(ZSFunc114param1);
   ZSFunc115param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc115param1.RegisterInternalStream(id);
   ZSFunc115 = new ZSStream(ZSFunc115param1);
   ZSFunc116param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc116param1.RegisterInternalStream(id);
   ZSFunc116 = new ZSStream(ZSFunc116param1);
   ZSFunc117param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc117param1.RegisterInternalStream(id);
   ZSFunc117 = new ZSStream(ZSFunc117param1);
   ZSFunc118param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc118param1.RegisterInternalStream(id);
   ZSFunc118 = new ZSStream(ZSFunc118param1);
   ZSFunc119param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc119param1.RegisterInternalStream(id);
   ZSFunc119 = new ZSStream(ZSFunc119param1);
   ZSFunc120param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc120param1.RegisterInternalStream(id);
   ZSFunc120 = new ZSStream(ZSFunc120param1);
   ZSFunc121param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc121param1.RegisterInternalStream(id);
   ZSFunc121 = new ZSStream(ZSFunc121param1);
   ZSFunc122param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc122param1.RegisterInternalStream(id);
   ZSFunc122 = new ZSStream(ZSFunc122param1);
   ZSFunc123param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc123param1.RegisterInternalStream(id);
   ZSFunc123 = new ZSStream(ZSFunc123param1);
   ZSFunc124param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc124param1.RegisterInternalStream(id);
   ZSFunc124 = new ZSStream(ZSFunc124param1);
   ZSFunc125param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc125param1.RegisterInternalStream(id);
   ZSFunc125 = new ZSStream(ZSFunc125param1);
   ZSFunc126param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc126param1.RegisterInternalStream(id);
   ZSFunc126 = new ZSStream(ZSFunc126param1);
   ZSFunc127param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc127param1.RegisterInternalStream(id);
   ZSFunc127 = new ZSStream(ZSFunc127param1);
   ZSFunc128param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc128param1.RegisterInternalStream(id);
   ZSFunc128 = new ZSStream(ZSFunc128param1);
   ZSFunc129param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc129param1.RegisterInternalStream(id);
   ZSFunc129 = new ZSStream(ZSFunc129param1);
   ZSFunc130param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc130param1.RegisterInternalStream(id);
   ZSFunc130 = new ZSStream(ZSFunc130param1);
   ZSFunc131param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc131param1.RegisterInternalStream(id);
   ZSFunc131 = new ZSStream(ZSFunc131param1);
   ZSFunc132param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc132param1.RegisterInternalStream(id);
   ZSFunc132 = new ZSStream(ZSFunc132param1);
   ZSFunc133param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc133param1.RegisterInternalStream(id);
   ZSFunc133 = new ZSStream(ZSFunc133param1);
   ZSFunc134param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc134param1.RegisterInternalStream(id);
   ZSFunc134 = new ZSStream(ZSFunc134param1);
   ZSFunc135param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc135param1.RegisterInternalStream(id);
   ZSFunc135 = new ZSStream(ZSFunc135param1);
   ZSFunc136param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc136param1.RegisterInternalStream(id);
   ZSFunc136 = new ZSStream(ZSFunc136param1);
   ZSFunc137param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc137param1.RegisterInternalStream(id);
   ZSFunc137 = new ZSStream(ZSFunc137param1);
   ZSFunc138param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc138param1.RegisterInternalStream(id);
   ZSFunc138 = new ZSStream(ZSFunc138param1);
   ZSFunc139param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc139param1.RegisterInternalStream(id);
   ZSFunc139 = new ZSStream(ZSFunc139param1);
   ZSFunc140param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc140param1.RegisterInternalStream(id);
   ZSFunc140 = new ZSStream(ZSFunc140param1);
   ZSFunc141param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc141param1.RegisterInternalStream(id);
   ZSFunc141 = new ZSStream(ZSFunc141param1);
   ZSFunc142param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc142param1.RegisterInternalStream(id);
   ZSFunc142 = new ZSStream(ZSFunc142param1);
   ZSFunc143param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc143param1.RegisterInternalStream(id);
   ZSFunc143 = new ZSStream(ZSFunc143param1);
   ZSFunc144param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc144param1.RegisterInternalStream(id);
   ZSFunc144 = new ZSStream(ZSFunc144param1);
   ZSFunc145param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc145param1.RegisterInternalStream(id);
   ZSFunc145 = new ZSStream(ZSFunc145param1);
   ZSFunc146param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc146param1.RegisterInternalStream(id);
   ZSFunc146 = new ZSStream(ZSFunc146param1);
   ZSFunc147param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc147param1.RegisterInternalStream(id);
   ZSFunc147 = new ZSStream(ZSFunc147param1);
   ZSFunc148param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc148param1.RegisterInternalStream(id);
   ZSFunc148 = new ZSStream(ZSFunc148param1);
   ZSFunc149param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc149param1.RegisterInternalStream(id);
   ZSFunc149 = new ZSStream(ZSFunc149param1);
   ZSFunc150param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc150param1.RegisterInternalStream(id);
   ZSFunc150 = new ZSStream(ZSFunc150param1);
   ZSFunc151param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc151param1.RegisterInternalStream(id);
   ZSFunc151 = new ZSStream(ZSFunc151param1);
   ZSFunc152param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc152param1.RegisterInternalStream(id);
   ZSFunc152 = new ZSStream(ZSFunc152param1);
   ZSFunc153param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc153param1.RegisterInternalStream(id);
   ZSFunc153 = new ZSStream(ZSFunc153param1);
   ZSFunc154param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc154param1.RegisterInternalStream(id);
   ZSFunc154 = new ZSStream(ZSFunc154param1);
   ZSFunc155param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc155param1.RegisterInternalStream(id);
   ZSFunc155 = new ZSStream(ZSFunc155param1);
   ZSFunc156param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc156param1.RegisterInternalStream(id);
   ZSFunc156 = new ZSStream(ZSFunc156param1);
   ZSFunc157param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc157param1.RegisterInternalStream(id);
   ZSFunc157 = new ZSStream(ZSFunc157param1);
   ZSFunc158param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc158param1.RegisterInternalStream(id);
   ZSFunc158 = new ZSStream(ZSFunc158param1);
   ZSFunc159param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc159param1.RegisterInternalStream(id);
   ZSFunc159 = new ZSStream(ZSFunc159param1);
   ZSFunc160param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc160param1.RegisterInternalStream(id);
   ZSFunc160 = new ZSStream(ZSFunc160param1);
   ZSFunc161param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc161param1.RegisterInternalStream(id);
   ZSFunc161 = new ZSStream(ZSFunc161param1);
   ZSFunc162param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc162param1.RegisterInternalStream(id);
   ZSFunc162 = new ZSStream(ZSFunc162param1);
   ZSFunc163param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc163param1.RegisterInternalStream(id);
   ZSFunc163 = new ZSStream(ZSFunc163param1);
   ZSFunc164param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc164param1.RegisterInternalStream(id);
   ZSFunc164 = new ZSStream(ZSFunc164param1);
   ZSFunc165param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc165param1.RegisterInternalStream(id);
   ZSFunc165 = new ZSStream(ZSFunc165param1);
   ZSFunc166param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc166param1.RegisterInternalStream(id);
   ZSFunc166 = new ZSStream(ZSFunc166param1);
   ZSFunc167param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc167param1.RegisterInternalStream(id);
   ZSFunc167 = new ZSStream(ZSFunc167param1);
   ZSFunc168param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ZSFunc168param1.RegisterInternalStream(id);
   ZSFunc168 = new ZSStream(ZSFunc168param1);
   functionFunc169param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc169param1.RegisterInternalStream(id);
   functionFunc169 = new functionStream(functionFunc169param1);
   functionFunc170param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc170param1.RegisterInternalStream(id);
   functionFunc170 = new functionStream(functionFunc170param1);
   functionFunc171param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc171param1.RegisterInternalStream(id);
   functionFunc171 = new functionStream(functionFunc171param1);
   functionFunc172param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc172param1.RegisterInternalStream(id);
   functionFunc172 = new functionStream(functionFunc172param1);
   functionFunc173param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc173param1.RegisterInternalStream(id);
   functionFunc173 = new functionStream(functionFunc173param1);
   functionFunc174param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc174param1.RegisterInternalStream(id);
   functionFunc174 = new functionStream(functionFunc174param1);
   functionFunc175param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc175param1.RegisterInternalStream(id);
   functionFunc175 = new functionStream(functionFunc175param1);
   functionFunc176param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc176param1.RegisterInternalStream(id);
   functionFunc176 = new functionStream(functionFunc176param1);
   functionFunc177param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc177param1.RegisterInternalStream(id);
   functionFunc177 = new functionStream(functionFunc177param1);
   functionFunc178param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc178param1.RegisterInternalStream(id);
   functionFunc178 = new functionStream(functionFunc178param1);
   functionFunc179param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc179param1.RegisterInternalStream(id);
   functionFunc179 = new functionStream(functionFunc179param1);
   functionFunc180param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc180param1.RegisterInternalStream(id);
   functionFunc180 = new functionStream(functionFunc180param1);
   functionFunc181param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc181param1.RegisterInternalStream(id);
   functionFunc181 = new functionStream(functionFunc181param1);
   functionFunc182param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc182param1.RegisterInternalStream(id);
   functionFunc182 = new functionStream(functionFunc182param1);
   functionFunc183param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc183param1.RegisterInternalStream(id);
   functionFunc183 = new functionStream(functionFunc183param1);
   functionFunc184param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc184param1.RegisterInternalStream(id);
   functionFunc184 = new functionStream(functionFunc184param1);
   functionFunc185param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc185param1.RegisterInternalStream(id);
   functionFunc185 = new functionStream(functionFunc185param1);
   functionFunc186param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc186param1.RegisterInternalStream(id);
   functionFunc186 = new functionStream(functionFunc186param1);
   functionFunc187param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc187param1.RegisterInternalStream(id);
   functionFunc187 = new functionStream(functionFunc187param1);
   functionFunc188param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc188param1.RegisterInternalStream(id);
   functionFunc188 = new functionStream(functionFunc188param1);
   functionFunc189param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc189param1.RegisterInternalStream(id);
   functionFunc189 = new functionStream(functionFunc189param1);
   functionFunc190param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc190param1.RegisterInternalStream(id);
   functionFunc190 = new functionStream(functionFunc190param1);
   functionFunc191param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc191param1.RegisterInternalStream(id);
   functionFunc191 = new functionStream(functionFunc191param1);
   functionFunc192param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc192param1.RegisterInternalStream(id);
   functionFunc192 = new functionStream(functionFunc192param1);
   functionFunc193param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc193param1.RegisterInternalStream(id);
   functionFunc193 = new functionStream(functionFunc193param1);
   functionFunc194param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc194param1.RegisterInternalStream(id);
   functionFunc194 = new functionStream(functionFunc194param1);
   functionFunc195param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc195param1.RegisterInternalStream(id);
   functionFunc195 = new functionStream(functionFunc195param1);
   functionFunc196param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc196param1.RegisterInternalStream(id);
   functionFunc196 = new functionStream(functionFunc196param1);
   functionFunc197param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc197param1.RegisterInternalStream(id);
   functionFunc197 = new functionStream(functionFunc197param1);
   functionFunc198param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc198param1.RegisterInternalStream(id);
   functionFunc198 = new functionStream(functionFunc198param1);
   functionFunc199param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc199param1.RegisterInternalStream(id);
   functionFunc199 = new functionStream(functionFunc199param1);
   functionFunc200param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc200param1.RegisterInternalStream(id);
   functionFunc200 = new functionStream(functionFunc200param1);
   functionFunc201param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc201param1.RegisterInternalStream(id);
   functionFunc201 = new functionStream(functionFunc201param1);
   functionFunc202param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc202param1.RegisterInternalStream(id);
   functionFunc202 = new functionStream(functionFunc202param1);
   functionFunc203param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc203param1.RegisterInternalStream(id);
   functionFunc203 = new functionStream(functionFunc203param1);
   functionFunc204param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc204param1.RegisterInternalStream(id);
   functionFunc204 = new functionStream(functionFunc204param1);
   functionFunc205param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc205param1.RegisterInternalStream(id);
   functionFunc205 = new functionStream(functionFunc205param1);
   functionFunc206param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc206param1.RegisterInternalStream(id);
   functionFunc206 = new functionStream(functionFunc206param1);
   functionFunc207param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc207param1.RegisterInternalStream(id);
   functionFunc207 = new functionStream(functionFunc207param1);
   functionFunc208param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc208param1.RegisterInternalStream(id);
   functionFunc208 = new functionStream(functionFunc208param1);
   functionFunc209param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc209param1.RegisterInternalStream(id);
   functionFunc209 = new functionStream(functionFunc209param1);
   functionFunc210param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc210param1.RegisterInternalStream(id);
   functionFunc210 = new functionStream(functionFunc210param1);
   functionFunc211param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc211param1.RegisterInternalStream(id);
   functionFunc211 = new functionStream(functionFunc211param1);
   functionFunc212param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc212param1.RegisterInternalStream(id);
   functionFunc212 = new functionStream(functionFunc212param1);
   functionFunc213param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc213param1.RegisterInternalStream(id);
   functionFunc213 = new functionStream(functionFunc213param1);
   functionFunc214param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc214param1.RegisterInternalStream(id);
   functionFunc214 = new functionStream(functionFunc214param1);
   functionFunc215param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc215param1.RegisterInternalStream(id);
   functionFunc215 = new functionStream(functionFunc215param1);
   functionFunc216param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc216param1.RegisterInternalStream(id);
   functionFunc216 = new functionStream(functionFunc216param1);
   functionFunc217param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc217param1.RegisterInternalStream(id);
   functionFunc217 = new functionStream(functionFunc217param1);
   functionFunc218param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc218param1.RegisterInternalStream(id);
   functionFunc218 = new functionStream(functionFunc218param1);
   functionFunc219param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc219param1.RegisterInternalStream(id);
   functionFunc219 = new functionStream(functionFunc219param1);
   functionFunc220param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc220param1.RegisterInternalStream(id);
   functionFunc220 = new functionStream(functionFunc220param1);
   functionFunc221param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc221param1.RegisterInternalStream(id);
   functionFunc221 = new functionStream(functionFunc221param1);
   functionFunc222param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc222param1.RegisterInternalStream(id);
   functionFunc222 = new functionStream(functionFunc222param1);
   functionFunc223param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc223param1.RegisterInternalStream(id);
   functionFunc223 = new functionStream(functionFunc223param1);
   functionFunc224param1 = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = functionFunc224param1.RegisterInternalStream(id);
   functionFunc224 = new functionStream(functionFunc224param1);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   tsi29Source.Release();
   tsi29.Release();
   tsi30Source.Release();
   tsi30.Release();
   tsi31Source.Release();
   tsi31.Release();
   tsi32Source.Release();
   tsi32.Release();
   tsi33Source.Release();
   tsi33.Release();
   tsi34Source.Release();
   tsi34.Release();
   tsi35Source.Release();
   tsi35.Release();
   tsi36Source.Release();
   tsi36.Release();
   tsi37Source.Release();
   tsi37.Release();
   tsi38Source.Release();
   tsi38.Release();
   tsi39Source.Release();
   tsi39.Release();
   tsi40Source.Release();
   tsi40.Release();
   tsi41Source.Release();
   tsi41.Release();
   tsi42Source.Release();
   tsi42.Release();
   tsi43Source.Release();
   tsi43.Release();
   tsi44Source.Release();
   tsi44.Release();
   tsi45Source.Release();
   tsi45.Release();
   tsi46Source.Release();
   tsi46.Release();
   tsi47Source.Release();
   tsi47.Release();
   tsi48Source.Release();
   tsi48.Release();
   tsi49Source.Release();
   tsi49.Release();
   tsi50Source.Release();
   tsi50.Release();
   tsi51Source.Release();
   tsi51.Release();
   tsi52Source.Release();
   tsi52.Release();
   tsi53Source.Release();
   tsi53.Release();
   tsi54Source.Release();
   tsi54.Release();
   tsi55Source.Release();
   tsi55.Release();
   tsi56Source.Release();
   tsi56.Release();
   tsi57Source.Release();
   tsi57.Release();
   tsi58Source.Release();
   tsi58.Release();
   tsi59Source.Release();
   tsi59.Release();
   tsi60Source.Release();
   tsi60.Release();
   tsi61Source.Release();
   tsi61.Release();
   tsi62Source.Release();
   tsi62.Release();
   tsi63Source.Release();
   tsi63.Release();
   tsi64Source.Release();
   tsi64.Release();
   tsi65Source.Release();
   tsi65.Release();
   tsi66Source.Release();
   tsi66.Release();
   tsi67Source.Release();
   tsi67.Release();
   tsi68Source.Release();
   tsi68.Release();
   tsi69Source.Release();
   tsi69.Release();
   tsi70Source.Release();
   tsi70.Release();
   tsi71Source.Release();
   tsi71.Release();
   tsi72Source.Release();
   tsi72.Release();
   tsi73Source.Release();
   tsi73.Release();
   tsi74Source.Release();
   tsi74.Release();
   tsi75Source.Release();
   tsi75.Release();
   tsi76Source.Release();
   tsi76.Release();
   tsi77Source.Release();
   tsi77.Release();
   tsi78Source.Release();
   tsi78.Release();
   tsi79Source.Release();
   tsi79.Release();
   tsi80Source.Release();
   tsi80.Release();
   tsi81Source.Release();
   tsi81.Release();
   tsi82Source.Release();
   tsi82.Release();
   tsi83Source.Release();
   tsi83.Release();
   tsi84Source.Release();
   tsi84.Release();
   rsi85X.Release();
   rsi85.Release();
   rsi86X.Release();
   rsi86.Release();
   rsi87X.Release();
   rsi87.Release();
   rsi88X.Release();
   rsi88.Release();
   rsi89X.Release();
   rsi89.Release();
   rsi90X.Release();
   rsi90.Release();
   rsi91X.Release();
   rsi91.Release();
   rsi92X.Release();
   rsi92.Release();
   rsi93X.Release();
   rsi93.Release();
   rsi94X.Release();
   rsi94.Release();
   rsi95X.Release();
   rsi95.Release();
   rsi96X.Release();
   rsi96.Release();
   rsi97X.Release();
   rsi97.Release();
   rsi98X.Release();
   rsi98.Release();
   rsi99X.Release();
   rsi99.Release();
   rsi100X.Release();
   rsi100.Release();
   rsi101X.Release();
   rsi101.Release();
   rsi102X.Release();
   rsi102.Release();
   rsi103X.Release();
   rsi103.Release();
   rsi104X.Release();
   rsi104.Release();
   rsi105X.Release();
   rsi105.Release();
   rsi106X.Release();
   rsi106.Release();
   rsi107X.Release();
   rsi107.Release();
   rsi108X.Release();
   rsi108.Release();
   rsi109X.Release();
   rsi109.Release();
   rsi110X.Release();
   rsi110.Release();
   rsi111X.Release();
   rsi111.Release();
   rsi112X.Release();
   rsi112.Release();
   rsi113X.Release();
   rsi113.Release();
   rsi114X.Release();
   rsi114.Release();
   rsi115X.Release();
   rsi115.Release();
   rsi116X.Release();
   rsi116.Release();
   rsi117X.Release();
   rsi117.Release();
   rsi118X.Release();
   rsi118.Release();
   rsi119X.Release();
   rsi119.Release();
   rsi120X.Release();
   rsi120.Release();
   rsi121X.Release();
   rsi121.Release();
   rsi122X.Release();
   rsi122.Release();
   rsi123X.Release();
   rsi123.Release();
   rsi124X.Release();
   rsi124.Release();
   rsi125X.Release();
   rsi125.Release();
   rsi126X.Release();
   rsi126.Release();
   rsi127X.Release();
   rsi127.Release();
   rsi128X.Release();
   rsi128.Release();
   rsi129X.Release();
   rsi129.Release();
   rsi130X.Release();
   rsi130.Release();
   rsi131X.Release();
   rsi131.Release();
   rsi132X.Release();
   rsi132.Release();
   rsi133X.Release();
   rsi133.Release();
   rsi134X.Release();
   rsi134.Release();
   rsi135X.Release();
   rsi135.Release();
   rsi136X.Release();
   rsi136.Release();
   rsi137X.Release();
   rsi137.Release();
   rsi138X.Release();
   rsi138.Release();
   rsi139X.Release();
   rsi139.Release();
   rsi140X.Release();
   rsi140.Release();
   roc141Source.Release();
   roc141.Release();
   roc142Source.Release();
   roc142.Release();
   roc143Source.Release();
   roc143.Release();
   roc144Source.Release();
   roc144.Release();
   roc145Source.Release();
   roc145.Release();
   roc146Source.Release();
   roc146.Release();
   roc147Source.Release();
   roc147.Release();
   roc148Source.Release();
   roc148.Release();
   roc149Source.Release();
   roc149.Release();
   roc150Source.Release();
   roc150.Release();
   roc151Source.Release();
   roc151.Release();
   roc152Source.Release();
   roc152.Release();
   roc153Source.Release();
   roc153.Release();
   roc154Source.Release();
   roc154.Release();
   roc155Source.Release();
   roc155.Release();
   roc156Source.Release();
   roc156.Release();
   roc157Source.Release();
   roc157.Release();
   roc158Source.Release();
   roc158.Release();
   roc159Source.Release();
   roc159.Release();
   roc160Source.Release();
   roc160.Release();
   roc161Source.Release();
   roc161.Release();
   roc162Source.Release();
   roc162.Release();
   roc163Source.Release();
   roc163.Release();
   roc164Source.Release();
   roc164.Release();
   roc165Source.Release();
   roc165.Release();
   roc166Source.Release();
   roc166.Release();
   roc167Source.Release();
   roc167.Release();
   roc168Source.Release();
   roc168.Release();
   roc169Source.Release();
   roc169.Release();
   roc170Source.Release();
   roc170.Release();
   roc171Source.Release();
   roc171.Release();
   roc172Source.Release();
   roc172.Release();
   roc173Source.Release();
   roc173.Release();
   roc174Source.Release();
   roc174.Release();
   roc175Source.Release();
   roc175.Release();
   roc176Source.Release();
   roc176.Release();
   roc177Source.Release();
   roc177.Release();
   roc178Source.Release();
   roc178.Release();
   roc179Source.Release();
   roc179.Release();
   roc180Source.Release();
   roc180.Release();
   roc181Source.Release();
   roc181.Release();
   roc182Source.Release();
   roc182.Release();
   roc183Source.Release();
   roc183.Release();
   roc184Source.Release();
   roc184.Release();
   roc185Source.Release();
   roc185.Release();
   roc186Source.Release();
   roc186.Release();
   roc187Source.Release();
   roc187.Release();
   roc188Source.Release();
   roc188.Release();
   roc189Source.Release();
   roc189.Release();
   roc190Source.Release();
   roc190.Release();
   roc191Source.Release();
   roc191.Release();
   roc192Source.Release();
   roc192.Release();
   roc193Source.Release();
   roc193.Release();
   roc194Source.Release();
   roc194.Release();
   roc195Source.Release();
   roc195.Release();
   roc196Source.Release();
   roc196.Release();
   LRSFunc1param1.Release();
   LRSFunc1.Release();
   LRSFunc2param1.Release();
   LRSFunc2.Release();
   LRSFunc3param1.Release();
   LRSFunc3.Release();
   LRSFunc4param1.Release();
   LRSFunc4.Release();
   LRSFunc5param1.Release();
   LRSFunc5.Release();
   LRSFunc6param1.Release();
   LRSFunc6.Release();
   LRSFunc7param1.Release();
   LRSFunc7.Release();
   LRSFunc8param1.Release();
   LRSFunc8.Release();
   LRSFunc9param1.Release();
   LRSFunc9.Release();
   LRSFunc10param1.Release();
   LRSFunc10.Release();
   LRSFunc11param1.Release();
   LRSFunc11.Release();
   LRSFunc12param1.Release();
   LRSFunc12.Release();
   LRSFunc13param1.Release();
   LRSFunc13.Release();
   LRSFunc14param1.Release();
   LRSFunc14.Release();
   LRSFunc15param1.Release();
   LRSFunc15.Release();
   LRSFunc16param1.Release();
   LRSFunc16.Release();
   LRSFunc17param1.Release();
   LRSFunc17.Release();
   LRSFunc18param1.Release();
   LRSFunc18.Release();
   LRSFunc19param1.Release();
   LRSFunc19.Release();
   LRSFunc20param1.Release();
   LRSFunc20.Release();
   LRSFunc21param1.Release();
   LRSFunc21.Release();
   LRSFunc22param1.Release();
   LRSFunc22.Release();
   LRSFunc23param1.Release();
   LRSFunc23.Release();
   LRSFunc24param1.Release();
   LRSFunc24.Release();
   LRSFunc25param1.Release();
   LRSFunc25.Release();
   LRSFunc26param1.Release();
   LRSFunc26.Release();
   LRSFunc27param1.Release();
   LRSFunc27.Release();
   LRSFunc28param1.Release();
   LRSFunc28.Release();
   LRSFunc29param1.Release();
   LRSFunc29.Release();
   LRSFunc30param1.Release();
   LRSFunc30.Release();
   LRSFunc31param1.Release();
   LRSFunc31.Release();
   LRSFunc32param1.Release();
   LRSFunc32.Release();
   LRSFunc33param1.Release();
   LRSFunc33.Release();
   LRSFunc34param1.Release();
   LRSFunc34.Release();
   LRSFunc35param1.Release();
   LRSFunc35.Release();
   LRSFunc36param1.Release();
   LRSFunc36.Release();
   LRSFunc37param1.Release();
   LRSFunc37.Release();
   LRSFunc38param1.Release();
   LRSFunc38.Release();
   LRSFunc39param1.Release();
   LRSFunc39.Release();
   LRSFunc40param1.Release();
   LRSFunc40.Release();
   LRSFunc41param1.Release();
   LRSFunc41.Release();
   LRSFunc42param1.Release();
   LRSFunc42.Release();
   LRSFunc43param1.Release();
   LRSFunc43.Release();
   LRSFunc44param1.Release();
   LRSFunc44.Release();
   LRSFunc45param1.Release();
   LRSFunc45.Release();
   LRSFunc46param1.Release();
   LRSFunc46.Release();
   LRSFunc47param1.Release();
   LRSFunc47.Release();
   LRSFunc48param1.Release();
   LRSFunc48.Release();
   LRSFunc49param1.Release();
   LRSFunc49.Release();
   LRSFunc50param1.Release();
   LRSFunc50.Release();
   LRSFunc51param1.Release();
   LRSFunc51.Release();
   LRSFunc52param1.Release();
   LRSFunc52.Release();
   LRSFunc53param1.Release();
   LRSFunc53.Release();
   LRSFunc54param1.Release();
   LRSFunc54.Release();
   LRSFunc55param1.Release();
   LRSFunc55.Release();
   LRSFunc56param1.Release();
   LRSFunc56.Release();
   calc_abssioFunc57param1.Release();
   calc_abssioFunc57.Release();
   calc_abssioFunc58param1.Release();
   calc_abssioFunc58.Release();
   calc_abssioFunc59param1.Release();
   calc_abssioFunc59.Release();
   calc_abssioFunc60param1.Release();
   calc_abssioFunc60.Release();
   calc_abssioFunc61param1.Release();
   calc_abssioFunc61.Release();
   calc_abssioFunc62param1.Release();
   calc_abssioFunc62.Release();
   calc_abssioFunc63param1.Release();
   calc_abssioFunc63.Release();
   calc_abssioFunc64param1.Release();
   calc_abssioFunc64.Release();
   calc_abssioFunc65param1.Release();
   calc_abssioFunc65.Release();
   calc_abssioFunc66param1.Release();
   calc_abssioFunc66.Release();
   calc_abssioFunc67param1.Release();
   calc_abssioFunc67.Release();
   calc_abssioFunc68param1.Release();
   calc_abssioFunc68.Release();
   calc_abssioFunc69param1.Release();
   calc_abssioFunc69.Release();
   calc_abssioFunc70param1.Release();
   calc_abssioFunc70.Release();
   calc_abssioFunc71param1.Release();
   calc_abssioFunc71.Release();
   calc_abssioFunc72param1.Release();
   calc_abssioFunc72.Release();
   calc_abssioFunc73param1.Release();
   calc_abssioFunc73.Release();
   calc_abssioFunc74param1.Release();
   calc_abssioFunc74.Release();
   calc_abssioFunc75param1.Release();
   calc_abssioFunc75.Release();
   calc_abssioFunc76param1.Release();
   calc_abssioFunc76.Release();
   calc_abssioFunc77param1.Release();
   calc_abssioFunc77.Release();
   calc_abssioFunc78param1.Release();
   calc_abssioFunc78.Release();
   calc_abssioFunc79param1.Release();
   calc_abssioFunc79.Release();
   calc_abssioFunc80param1.Release();
   calc_abssioFunc80.Release();
   calc_abssioFunc81param1.Release();
   calc_abssioFunc81.Release();
   calc_abssioFunc82param1.Release();
   calc_abssioFunc82.Release();
   calc_abssioFunc83param1.Release();
   calc_abssioFunc83.Release();
   calc_abssioFunc84param1.Release();
   calc_abssioFunc84.Release();
   calc_abssioFunc85param1.Release();
   calc_abssioFunc85.Release();
   calc_abssioFunc86param1.Release();
   calc_abssioFunc86.Release();
   calc_abssioFunc87param1.Release();
   calc_abssioFunc87.Release();
   calc_abssioFunc88param1.Release();
   calc_abssioFunc88.Release();
   calc_abssioFunc89param1.Release();
   calc_abssioFunc89.Release();
   calc_abssioFunc90param1.Release();
   calc_abssioFunc90.Release();
   calc_abssioFunc91param1.Release();
   calc_abssioFunc91.Release();
   calc_abssioFunc92param1.Release();
   calc_abssioFunc92.Release();
   calc_abssioFunc93param1.Release();
   calc_abssioFunc93.Release();
   calc_abssioFunc94param1.Release();
   calc_abssioFunc94.Release();
   calc_abssioFunc95param1.Release();
   calc_abssioFunc95.Release();
   calc_abssioFunc96param1.Release();
   calc_abssioFunc96.Release();
   calc_abssioFunc97param1.Release();
   calc_abssioFunc97.Release();
   calc_abssioFunc98param1.Release();
   calc_abssioFunc98.Release();
   calc_abssioFunc99param1.Release();
   calc_abssioFunc99.Release();
   calc_abssioFunc100param1.Release();
   calc_abssioFunc100.Release();
   calc_abssioFunc101param1.Release();
   calc_abssioFunc101.Release();
   calc_abssioFunc102param1.Release();
   calc_abssioFunc102.Release();
   calc_abssioFunc103param1.Release();
   calc_abssioFunc103.Release();
   calc_abssioFunc104param1.Release();
   calc_abssioFunc104.Release();
   calc_abssioFunc105param1.Release();
   calc_abssioFunc105.Release();
   calc_abssioFunc106param1.Release();
   calc_abssioFunc106.Release();
   calc_abssioFunc107param1.Release();
   calc_abssioFunc107.Release();
   calc_abssioFunc108param1.Release();
   calc_abssioFunc108.Release();
   calc_abssioFunc109param1.Release();
   calc_abssioFunc109.Release();
   calc_abssioFunc110param1.Release();
   calc_abssioFunc110.Release();
   calc_abssioFunc111param1.Release();
   calc_abssioFunc111.Release();
   calc_abssioFunc112param1.Release();
   calc_abssioFunc112.Release();
   ZSFunc113param1.Release();
   ZSFunc113.Release();
   ZSFunc114param1.Release();
   ZSFunc114.Release();
   ZSFunc115param1.Release();
   ZSFunc115.Release();
   ZSFunc116param1.Release();
   ZSFunc116.Release();
   ZSFunc117param1.Release();
   ZSFunc117.Release();
   ZSFunc118param1.Release();
   ZSFunc118.Release();
   ZSFunc119param1.Release();
   ZSFunc119.Release();
   ZSFunc120param1.Release();
   ZSFunc120.Release();
   ZSFunc121param1.Release();
   ZSFunc121.Release();
   ZSFunc122param1.Release();
   ZSFunc122.Release();
   ZSFunc123param1.Release();
   ZSFunc123.Release();
   ZSFunc124param1.Release();
   ZSFunc124.Release();
   ZSFunc125param1.Release();
   ZSFunc125.Release();
   ZSFunc126param1.Release();
   ZSFunc126.Release();
   ZSFunc127param1.Release();
   ZSFunc127.Release();
   ZSFunc128param1.Release();
   ZSFunc128.Release();
   ZSFunc129param1.Release();
   ZSFunc129.Release();
   ZSFunc130param1.Release();
   ZSFunc130.Release();
   ZSFunc131param1.Release();
   ZSFunc131.Release();
   ZSFunc132param1.Release();
   ZSFunc132.Release();
   ZSFunc133param1.Release();
   ZSFunc133.Release();
   ZSFunc134param1.Release();
   ZSFunc134.Release();
   ZSFunc135param1.Release();
   ZSFunc135.Release();
   ZSFunc136param1.Release();
   ZSFunc136.Release();
   ZSFunc137param1.Release();
   ZSFunc137.Release();
   ZSFunc138param1.Release();
   ZSFunc138.Release();
   ZSFunc139param1.Release();
   ZSFunc139.Release();
   ZSFunc140param1.Release();
   ZSFunc140.Release();
   ZSFunc141param1.Release();
   ZSFunc141.Release();
   ZSFunc142param1.Release();
   ZSFunc142.Release();
   ZSFunc143param1.Release();
   ZSFunc143.Release();
   ZSFunc144param1.Release();
   ZSFunc144.Release();
   ZSFunc145param1.Release();
   ZSFunc145.Release();
   ZSFunc146param1.Release();
   ZSFunc146.Release();
   ZSFunc147param1.Release();
   ZSFunc147.Release();
   ZSFunc148param1.Release();
   ZSFunc148.Release();
   ZSFunc149param1.Release();
   ZSFunc149.Release();
   ZSFunc150param1.Release();
   ZSFunc150.Release();
   ZSFunc151param1.Release();
   ZSFunc151.Release();
   ZSFunc152param1.Release();
   ZSFunc152.Release();
   ZSFunc153param1.Release();
   ZSFunc153.Release();
   ZSFunc154param1.Release();
   ZSFunc154.Release();
   ZSFunc155param1.Release();
   ZSFunc155.Release();
   ZSFunc156param1.Release();
   ZSFunc156.Release();
   ZSFunc157param1.Release();
   ZSFunc157.Release();
   ZSFunc158param1.Release();
   ZSFunc158.Release();
   ZSFunc159param1.Release();
   ZSFunc159.Release();
   ZSFunc160param1.Release();
   ZSFunc160.Release();
   ZSFunc161param1.Release();
   ZSFunc161.Release();
   ZSFunc162param1.Release();
   ZSFunc162.Release();
   ZSFunc163param1.Release();
   ZSFunc163.Release();
   ZSFunc164param1.Release();
   ZSFunc164.Release();
   ZSFunc165param1.Release();
   ZSFunc165.Release();
   ZSFunc166param1.Release();
   ZSFunc166.Release();
   ZSFunc167param1.Release();
   ZSFunc167.Release();
   ZSFunc168param1.Release();
   ZSFunc168.Release();
   functionFunc169param1.Release();
   functionFunc169.Release();
   functionFunc170param1.Release();
   functionFunc170.Release();
   functionFunc171param1.Release();
   functionFunc171.Release();
   functionFunc172param1.Release();
   functionFunc172.Release();
   functionFunc173param1.Release();
   functionFunc173.Release();
   functionFunc174param1.Release();
   functionFunc174.Release();
   functionFunc175param1.Release();
   functionFunc175.Release();
   functionFunc176param1.Release();
   functionFunc176.Release();
   functionFunc177param1.Release();
   functionFunc177.Release();
   functionFunc178param1.Release();
   functionFunc178.Release();
   functionFunc179param1.Release();
   functionFunc179.Release();
   functionFunc180param1.Release();
   functionFunc180.Release();
   functionFunc181param1.Release();
   functionFunc181.Release();
   functionFunc182param1.Release();
   functionFunc182.Release();
   functionFunc183param1.Release();
   functionFunc183.Release();
   functionFunc184param1.Release();
   functionFunc184.Release();
   functionFunc185param1.Release();
   functionFunc185.Release();
   functionFunc186param1.Release();
   functionFunc186.Release();
   functionFunc187param1.Release();
   functionFunc187.Release();
   functionFunc188param1.Release();
   functionFunc188.Release();
   functionFunc189param1.Release();
   functionFunc189.Release();
   functionFunc190param1.Release();
   functionFunc190.Release();
   functionFunc191param1.Release();
   functionFunc191.Release();
   functionFunc192param1.Release();
   functionFunc192.Release();
   functionFunc193param1.Release();
   functionFunc193.Release();
   functionFunc194param1.Release();
   functionFunc194.Release();
   functionFunc195param1.Release();
   functionFunc195.Release();
   functionFunc196param1.Release();
   functionFunc196.Release();
   functionFunc197param1.Release();
   functionFunc197.Release();
   functionFunc198param1.Release();
   functionFunc198.Release();
   functionFunc199param1.Release();
   functionFunc199.Release();
   functionFunc200param1.Release();
   functionFunc200.Release();
   functionFunc201param1.Release();
   functionFunc201.Release();
   functionFunc202param1.Release();
   functionFunc202.Release();
   functionFunc203param1.Release();
   functionFunc203.Release();
   functionFunc204param1.Release();
   functionFunc204.Release();
   functionFunc205param1.Release();
   functionFunc205.Release();
   functionFunc206param1.Release();
   functionFunc206.Release();
   functionFunc207param1.Release();
   functionFunc207.Release();
   functionFunc208param1.Release();
   functionFunc208.Release();
   functionFunc209param1.Release();
   functionFunc209.Release();
   functionFunc210param1.Release();
   functionFunc210.Release();
   functionFunc211param1.Release();
   functionFunc211.Release();
   functionFunc212param1.Release();
   functionFunc212.Release();
   functionFunc213param1.Release();
   functionFunc213.Release();
   functionFunc214param1.Release();
   functionFunc214.Release();
   functionFunc215param1.Release();
   functionFunc215.Release();
   functionFunc216param1.Release();
   functionFunc216.Release();
   functionFunc217param1.Release();
   functionFunc217.Release();
   functionFunc218param1.Release();
   functionFunc218.Release();
   functionFunc219param1.Release();
   functionFunc219.Release();
   functionFunc220param1.Release();
   functionFunc220.Release();
   functionFunc221param1.Release();
   functionFunc221.Release();
   functionFunc222param1.Release();
   functionFunc222.Release();
   functionFunc223param1.Release();
   functionFunc223.Release();
   functionFunc224param1.Release();
   functionFunc224.Release();
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
      ArrayInitialize(linreg, EMPTY_VALUE);
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
      double eurgbp = iClose("EURGBP", 0, pos);
      double euraud = iClose("EURAUD", 0, pos);
      double eurnzd = iClose("EURNZD", 0, pos);
      double eurusd = iClose("EURUSD", 0, pos);
      double eurcad = iClose("EURCAD", 0, pos);
      double eurchf = iClose("EURCHF", 0, pos);
      double eurjpy = iClose("EURJPY", 0, pos) / 100;

      double gbpeur = eurgbp == 0 ? 0 : 1 / eurgbp;
      double gbpaud = iClose("GBPAUD", 0, pos);
      double gbpnzd = iClose("GBPNZD", 0, pos);
      double gbpusd = iClose("GBPUSD", 0, pos);
      double gbpcad = iClose("GBPCAD", 0, pos);
      double gbpchf = iClose("GBPCHF", 0, pos);
      double gbpjpy = iClose("GBPJPY", 0, pos) / 100;

      double audeur = euraud == 0 ? 0 : 1 / euraud;
      double audgbp = gbpaud == 0 ? 0 : 1 / gbpaud;
      double audnzd = iClose("AUDNZD", 0, pos);
      double audusd = iClose("AUDUSD", 0, pos);
      double audcad = iClose("AUDCAD", 0, pos);
      double audchf = iClose("AUDCHF", 0, pos);
      double audjpy = iClose("AUDJPY", 0, pos) / 100;

      double nzdeur = eurnzd == 0 ? 0 : 1 / eurnzd;
      double nzdgbp = gbpnzd == 0 ? 0 : 1 / gbpnzd;
      double nzdaud = audnzd == 0 ? 0 : 1 / audnzd;
      double nzdusd = iClose("NZDUSD", 0, pos);
      double nzdcad = iClose("NZDCAD", 0, pos);
      double nzdchf = iClose("NZDCHF", 0, pos);
      double nzdjpy = iClose("NZDJPY", 0, pos) / 100;

      double usdeur = eurusd == 0 ? 0 : 1 / eurusd;
      double usdgbp = gbpusd == 0 ? 0 : 1 / gbpusd;
      double usdaud = audusd == 0 ? 0 : 1 / audusd;
      double usdnzd = nzdusd == 0 ? 0 : 1 / nzdusd;
      double usdcad = iClose("USDCAD", 0, pos);
      double usdchf = iClose("USDCHF", 0, pos);
      double usdjpy = iClose("USDJPY", 0, pos) / 100;

      double cadeur = eurcad == 0 ? 0 : 1 / eurcad;
      double cadgbp = gbpcad == 0 ? 0 : 1 / gbpcad;
      double cadnzd = nzdcad == 0 ? 0 : 1 / nzdcad;
      double cadusd = usdcad == 0 ? 0 : 1 / usdcad;
      double cadaud = audcad == 0 ? 0 : 1 / audcad;
      double cadchf = iClose("CADCHF", 0, pos);
      double cadjpy = iClose("CADJPY", 0, pos) / 100;

      double chfeur = eurchf == 0 ? 0 : 1 / eurchf;
      double chfgbp = gbpchf == 0 ? 0 : 1 / gbpchf;
      double chfnzd = nzdchf == 0 ? 0 : 1 / nzdchf;
      double chfusd = usdchf == 0 ? 0 : 1 / usdchf;
      double chfcad = cadchf == 0 ? 0 : 1 / cadchf;
      double chfaud = audchf == 0 ? 0 : 1 / audchf;
      double chfjpy = iClose("CHFJPY", 0, pos) / 100;

      double jpyeur = eurjpy == 0 ? 0 : 1 / eurjpy * 100;
      double jpygbp = gbpjpy == 0 ? 0 : 1 / gbpjpy * 100;
      double jpynzd = nzdjpy == 0 ? 0 : 1 / nzdjpy * 100;
      double jpyusd = usdjpy == 0 ? 0 : 1 / usdjpy * 100;
      double jpycad = cadjpy == 0 ? 0 : 1 / cadjpy * 100;
      double jpyaud = audjpy == 0 ? 0 : 1 / audjpy * 100;
      double jpychf = chfjpy == 0 ? 0 : 1 / chfjpy * 100;

      LRSFunc1param1._data[pos] = eurgbp;
      double LRSFunc1Value;
      if (!LRSFunc1.GetValue(pos, LRSFunc1Value))
      {
         continue;
      }
      LRSFunc2param1._data[pos] = euraud;
      double LRSFunc2Value;
      if (!LRSFunc2.GetValue(pos, LRSFunc2Value))
      {
         continue;
      }
      LRSFunc3param1._data[pos] = eurnzd;
      double LRSFunc3Value;
      if (!LRSFunc3.GetValue(pos, LRSFunc3Value))
      {
         continue;
      }
      LRSFunc4param1._data[pos] = eurusd;
      double LRSFunc4Value;
      if (!LRSFunc4.GetValue(pos, LRSFunc4Value))
      {
         continue;
      }
      LRSFunc5param1._data[pos] = eurcad;
      double LRSFunc5Value;
      if (!LRSFunc5.GetValue(pos, LRSFunc5Value))
      {
         continue;
      }
      LRSFunc6param1._data[pos] = eurchf;
      double LRSFunc6Value;
      if (!LRSFunc6.GetValue(pos, LRSFunc6Value))
      {
         continue;
      }
      LRSFunc7param1._data[pos] = eurjpy;
      double LRSFunc7Value;
      if (!LRSFunc7.GetValue(pos, LRSFunc7Value))
      {
         continue;
      }
      double LRSeur = (LRSFunc1Value + LRSFunc2Value + LRSFunc3Value + LRSFunc4Value + LRSFunc5Value + LRSFunc6Value + LRSFunc7Value);
      LRSFunc8param1._data[pos] = gbpeur;
      double LRSFunc8Value;
      if (!LRSFunc8.GetValue(pos, LRSFunc8Value))
      {
         continue;
      }
      LRSFunc9param1._data[pos] = gbpaud;
      double LRSFunc9Value;
      if (!LRSFunc9.GetValue(pos, LRSFunc9Value))
      {
         continue;
      }
      LRSFunc10param1._data[pos] = gbpnzd;
      double LRSFunc10Value;
      if (!LRSFunc10.GetValue(pos, LRSFunc10Value))
      {
         continue;
      }
      LRSFunc11param1._data[pos] = gbpusd;
      double LRSFunc11Value;
      if (!LRSFunc11.GetValue(pos, LRSFunc11Value))
      {
         continue;
      }
      LRSFunc12param1._data[pos] = gbpcad;
      double LRSFunc12Value;
      if (!LRSFunc12.GetValue(pos, LRSFunc12Value))
      {
         continue;
      }
      LRSFunc13param1._data[pos] = gbpchf;
      double LRSFunc13Value;
      if (!LRSFunc13.GetValue(pos, LRSFunc13Value))
      {
         continue;
      }
      LRSFunc14param1._data[pos] = gbpjpy;
      double LRSFunc14Value;
      if (!LRSFunc14.GetValue(pos, LRSFunc14Value))
      {
         continue;
      }
      double LRSgbp = (LRSFunc8Value + LRSFunc9Value + LRSFunc10Value + LRSFunc11Value + LRSFunc12Value + LRSFunc13Value + LRSFunc14Value);
      LRSFunc15param1._data[pos] = audeur;
      double LRSFunc15Value;
      if (!LRSFunc15.GetValue(pos, LRSFunc15Value))
      {
         continue;
      }
      LRSFunc16param1._data[pos] = audgbp;
      double LRSFunc16Value;
      if (!LRSFunc16.GetValue(pos, LRSFunc16Value))
      {
         continue;
      }
      LRSFunc17param1._data[pos] = audnzd;
      double LRSFunc17Value;
      if (!LRSFunc17.GetValue(pos, LRSFunc17Value))
      {
         continue;
      }
      LRSFunc18param1._data[pos] = audusd;
      double LRSFunc18Value;
      if (!LRSFunc18.GetValue(pos, LRSFunc18Value))
      {
         continue;
      }
      LRSFunc19param1._data[pos] = audcad;
      double LRSFunc19Value;
      if (!LRSFunc19.GetValue(pos, LRSFunc19Value))
      {
         continue;
      }
      LRSFunc20param1._data[pos] = audchf;
      double LRSFunc20Value;
      if (!LRSFunc20.GetValue(pos, LRSFunc20Value))
      {
         continue;
      }
      LRSFunc21param1._data[pos] = audjpy;
      double LRSFunc21Value;
      if (!LRSFunc21.GetValue(pos, LRSFunc21Value))
      {
         continue;
      }
      double LRSaud = (LRSFunc15Value + LRSFunc16Value + LRSFunc17Value + LRSFunc18Value + LRSFunc19Value + LRSFunc20Value + LRSFunc21Value);
      LRSFunc22param1._data[pos] = nzdeur;
      double LRSFunc22Value;
      if (!LRSFunc22.GetValue(pos, LRSFunc22Value))
      {
         continue;
      }
      LRSFunc23param1._data[pos] = nzdgbp;
      double LRSFunc23Value;
      if (!LRSFunc23.GetValue(pos, LRSFunc23Value))
      {
         continue;
      }
      LRSFunc24param1._data[pos] = nzdaud;
      double LRSFunc24Value;
      if (!LRSFunc24.GetValue(pos, LRSFunc24Value))
      {
         continue;
      }
      LRSFunc25param1._data[pos] = nzdusd;
      double LRSFunc25Value;
      if (!LRSFunc25.GetValue(pos, LRSFunc25Value))
      {
         continue;
      }
      LRSFunc26param1._data[pos] = nzdcad;
      double LRSFunc26Value;
      if (!LRSFunc26.GetValue(pos, LRSFunc26Value))
      {
         continue;
      }
      LRSFunc27param1._data[pos] = nzdchf;
      double LRSFunc27Value;
      if (!LRSFunc27.GetValue(pos, LRSFunc27Value))
      {
         continue;
      }
      LRSFunc28param1._data[pos] = nzdjpy;
      double LRSFunc28Value;
      if (!LRSFunc28.GetValue(pos, LRSFunc28Value))
      {
         continue;
      }
      double LRSnzd = (LRSFunc22Value + LRSFunc23Value + LRSFunc24Value + LRSFunc25Value + LRSFunc26Value + LRSFunc27Value + LRSFunc28Value);
      LRSFunc29param1._data[pos] = usdeur;
      double LRSFunc29Value;
      if (!LRSFunc29.GetValue(pos, LRSFunc29Value))
      {
         continue;
      }
      LRSFunc30param1._data[pos] = usdgbp;
      double LRSFunc30Value;
      if (!LRSFunc30.GetValue(pos, LRSFunc30Value))
      {
         continue;
      }
      LRSFunc31param1._data[pos] = usdaud;
      double LRSFunc31Value;
      if (!LRSFunc31.GetValue(pos, LRSFunc31Value))
      {
         continue;
      }
      LRSFunc32param1._data[pos] = usdnzd;
      double LRSFunc32Value;
      if (!LRSFunc32.GetValue(pos, LRSFunc32Value))
      {
         continue;
      }
      LRSFunc33param1._data[pos] = usdcad;
      double LRSFunc33Value;
      if (!LRSFunc33.GetValue(pos, LRSFunc33Value))
      {
         continue;
      }
      LRSFunc34param1._data[pos] = usdchf;
      double LRSFunc34Value;
      if (!LRSFunc34.GetValue(pos, LRSFunc34Value))
      {
         continue;
      }
      LRSFunc35param1._data[pos] = usdjpy;
      double LRSFunc35Value;
      if (!LRSFunc35.GetValue(pos, LRSFunc35Value))
      {
         continue;
      }
      double LRSusd = (LRSFunc29Value + LRSFunc30Value + LRSFunc31Value + LRSFunc32Value + LRSFunc33Value + LRSFunc34Value + LRSFunc35Value);
      LRSFunc36param1._data[pos] = cadeur;
      double LRSFunc36Value;
      if (!LRSFunc36.GetValue(pos, LRSFunc36Value))
      {
         continue;
      }
      LRSFunc37param1._data[pos] = cadgbp;
      double LRSFunc37Value;
      if (!LRSFunc37.GetValue(pos, LRSFunc37Value))
      {
         continue;
      }
      LRSFunc38param1._data[pos] = cadaud;
      double LRSFunc38Value;
      if (!LRSFunc38.GetValue(pos, LRSFunc38Value))
      {
         continue;
      }
      LRSFunc39param1._data[pos] = cadnzd;
      double LRSFunc39Value;
      if (!LRSFunc39.GetValue(pos, LRSFunc39Value))
      {
         continue;
      }
      LRSFunc40param1._data[pos] = cadusd;
      double LRSFunc40Value;
      if (!LRSFunc40.GetValue(pos, LRSFunc40Value))
      {
         continue;
      }
      LRSFunc41param1._data[pos] = cadchf;
      double LRSFunc41Value;
      if (!LRSFunc41.GetValue(pos, LRSFunc41Value))
      {
         continue;
      }
      LRSFunc42param1._data[pos] = cadjpy;
      double LRSFunc42Value;
      if (!LRSFunc42.GetValue(pos, LRSFunc42Value))
      {
         continue;
      }
      double LRScad = (LRSFunc36Value + LRSFunc37Value + LRSFunc38Value + LRSFunc39Value + LRSFunc40Value + LRSFunc41Value + LRSFunc42Value);
      LRSFunc43param1._data[pos] = chfeur;
      double LRSFunc43Value;
      if (!LRSFunc43.GetValue(pos, LRSFunc43Value))
      {
         continue;
      }
      LRSFunc44param1._data[pos] = chfgbp;
      double LRSFunc44Value;
      if (!LRSFunc44.GetValue(pos, LRSFunc44Value))
      {
         continue;
      }
      LRSFunc45param1._data[pos] = chfaud;
      double LRSFunc45Value;
      if (!LRSFunc45.GetValue(pos, LRSFunc45Value))
      {
         continue;
      }
      LRSFunc46param1._data[pos] = chfnzd;
      double LRSFunc46Value;
      if (!LRSFunc46.GetValue(pos, LRSFunc46Value))
      {
         continue;
      }
      LRSFunc47param1._data[pos] = chfusd;
      double LRSFunc47Value;
      if (!LRSFunc47.GetValue(pos, LRSFunc47Value))
      {
         continue;
      }
      LRSFunc48param1._data[pos] = chfcad;
      double LRSFunc48Value;
      if (!LRSFunc48.GetValue(pos, LRSFunc48Value))
      {
         continue;
      }
      LRSFunc49param1._data[pos] = chfjpy;
      double LRSFunc49Value;
      if (!LRSFunc49.GetValue(pos, LRSFunc49Value))
      {
         continue;
      }
      double LRSchf = (LRSFunc43Value + LRSFunc44Value + LRSFunc45Value + LRSFunc46Value + LRSFunc47Value + LRSFunc48Value + LRSFunc49Value);
      LRSFunc50param1._data[pos] = jpyeur;
      double LRSFunc50Value;
      if (!LRSFunc50.GetValue(pos, LRSFunc50Value))
      {
         continue;
      }
      LRSFunc51param1._data[pos] = jpygbp;
      double LRSFunc51Value;
      if (!LRSFunc51.GetValue(pos, LRSFunc51Value))
      {
         continue;
      }
      LRSFunc52param1._data[pos] = jpyaud;
      double LRSFunc52Value;
      if (!LRSFunc52.GetValue(pos, LRSFunc52Value))
      {
         continue;
      }
      LRSFunc53param1._data[pos] = jpynzd;
      double LRSFunc53Value;
      if (!LRSFunc53.GetValue(pos, LRSFunc53Value))
      {
         continue;
      }
      LRSFunc54param1._data[pos] = jpyusd;
      double LRSFunc54Value;
      if (!LRSFunc54.GetValue(pos, LRSFunc54Value))
      {
         continue;
      }
      LRSFunc55param1._data[pos] = jpycad;
      double LRSFunc55Value;
      if (!LRSFunc55.GetValue(pos, LRSFunc55Value))
      {
         continue;
      }
      LRSFunc56param1._data[pos] = jpychf;
      double LRSFunc56Value;
      if (!LRSFunc56.GetValue(pos, LRSFunc56Value))
      {
         continue;
      }
      double LRSjpy = (LRSFunc50Value + LRSFunc51Value + LRSFunc52Value + LRSFunc53Value + LRSFunc54Value + LRSFunc55Value + LRSFunc56Value);

      tsi29Source._data[pos] = eurgbp;
      double tsi29Value;
      if (!tsi29.GetValue(pos, tsi29Value))
      {
         continue;
      }
      tsi30Source._data[pos] = euraud;
      double tsi30Value;
      if (!tsi30.GetValue(pos, tsi30Value))
      {
         continue;
      }
      tsi31Source._data[pos] = eurnzd;
      double tsi31Value;
      if (!tsi31.GetValue(pos, tsi31Value))
      {
         continue;
      }
      tsi32Source._data[pos] = eurusd;
      double tsi32Value;
      if (!tsi32.GetValue(pos, tsi32Value))
      {
         continue;
      }
      tsi33Source._data[pos] = eurcad;
      double tsi33Value;
      if (!tsi33.GetValue(pos, tsi33Value))
      {
         continue;
      }
      tsi34Source._data[pos] = eurchf;
      double tsi34Value;
      if (!tsi34.GetValue(pos, tsi34Value))
      {
         continue;
      }
      tsi35Source._data[pos] = eurjpy;
      double tsi35Value;
      if (!tsi35.GetValue(pos, tsi35Value))
      {
         continue;
      }
      double TSIeur = (tsi29Value + tsi30Value + tsi31Value + tsi32Value + tsi33Value + tsi34Value + tsi35Value) / 7;
      tsi36Source._data[pos] = gbpeur;
      double tsi36Value;
      if (!tsi36.GetValue(pos, tsi36Value))
      {
         continue;
      }
      tsi37Source._data[pos] = gbpaud;
      double tsi37Value;
      if (!tsi37.GetValue(pos, tsi37Value))
      {
         continue;
      }
      tsi38Source._data[pos] = gbpnzd;
      double tsi38Value;
      if (!tsi38.GetValue(pos, tsi38Value))
      {
         continue;
      }
      tsi39Source._data[pos] = gbpusd;
      double tsi39Value;
      if (!tsi39.GetValue(pos, tsi39Value))
      {
         continue;
      }
      tsi40Source._data[pos] = gbpcad;
      double tsi40Value;
      if (!tsi40.GetValue(pos, tsi40Value))
      {
         continue;
      }
      tsi41Source._data[pos] = gbpchf;
      double tsi41Value;
      if (!tsi41.GetValue(pos, tsi41Value))
      {
         continue;
      }
      tsi42Source._data[pos] = gbpjpy;
      double tsi42Value;
      if (!tsi42.GetValue(pos, tsi42Value))
      {
         continue;
      }
      double TSIgbp = (tsi36Value + tsi37Value + tsi38Value + tsi39Value + tsi40Value + tsi41Value + tsi42Value) / 7;
      tsi43Source._data[pos] = audeur;
      double tsi43Value;
      if (!tsi43.GetValue(pos, tsi43Value))
      {
         continue;
      }
      tsi44Source._data[pos] = audgbp;
      double tsi44Value;
      if (!tsi44.GetValue(pos, tsi44Value))
      {
         continue;
      }
      tsi45Source._data[pos] = audnzd;
      double tsi45Value;
      if (!tsi45.GetValue(pos, tsi45Value))
      {
         continue;
      }
      tsi46Source._data[pos] = audusd;
      double tsi46Value;
      if (!tsi46.GetValue(pos, tsi46Value))
      {
         continue;
      }
      tsi47Source._data[pos] = audcad;
      double tsi47Value;
      if (!tsi47.GetValue(pos, tsi47Value))
      {
         continue;
      }
      tsi48Source._data[pos] = audchf;
      double tsi48Value;
      if (!tsi48.GetValue(pos, tsi48Value))
      {
         continue;
      }
      tsi49Source._data[pos] = audjpy;
      double tsi49Value;
      if (!tsi49.GetValue(pos, tsi49Value))
      {
         continue;
      }
      double TSIaud = (tsi43Value + tsi44Value + tsi45Value + tsi46Value + tsi47Value + tsi48Value + tsi49Value) / 7;
      tsi50Source._data[pos] = nzdeur;
      double tsi50Value;
      if (!tsi50.GetValue(pos, tsi50Value))
      {
         continue;
      }
      tsi51Source._data[pos] = nzdgbp;
      double tsi51Value;
      if (!tsi51.GetValue(pos, tsi51Value))
      {
         continue;
      }
      tsi52Source._data[pos] = nzdaud;
      double tsi52Value;
      if (!tsi52.GetValue(pos, tsi52Value))
      {
         continue;
      }
      tsi53Source._data[pos] = nzdusd;
      double tsi53Value;
      if (!tsi53.GetValue(pos, tsi53Value))
      {
         continue;
      }
      tsi54Source._data[pos] = nzdcad;
      double tsi54Value;
      if (!tsi54.GetValue(pos, tsi54Value))
      {
         continue;
      }
      tsi55Source._data[pos] = nzdchf;
      double tsi55Value;
      if (!tsi55.GetValue(pos, tsi55Value))
      {
         continue;
      }
      tsi56Source._data[pos] = nzdjpy;
      double tsi56Value;
      if (!tsi56.GetValue(pos, tsi56Value))
      {
         continue;
      }
      double TSInzd = (tsi50Value + tsi51Value + tsi52Value + tsi53Value + tsi54Value + tsi55Value + tsi56Value) / 7;
      tsi57Source._data[pos] = usdeur;
      double tsi57Value;
      if (!tsi57.GetValue(pos, tsi57Value))
      {
         continue;
      }
      tsi58Source._data[pos] = usdgbp;
      double tsi58Value;
      if (!tsi58.GetValue(pos, tsi58Value))
      {
         continue;
      }
      tsi59Source._data[pos] = usdaud;
      double tsi59Value;
      if (!tsi59.GetValue(pos, tsi59Value))
      {
         continue;
      }
      tsi60Source._data[pos] = usdnzd;
      double tsi60Value;
      if (!tsi60.GetValue(pos, tsi60Value))
      {
         continue;
      }
      tsi61Source._data[pos] = usdcad;
      double tsi61Value;
      if (!tsi61.GetValue(pos, tsi61Value))
      {
         continue;
      }
      tsi62Source._data[pos] = usdchf;
      double tsi62Value;
      if (!tsi62.GetValue(pos, tsi62Value))
      {
         continue;
      }
      tsi63Source._data[pos] = usdjpy;
      double tsi63Value;
      if (!tsi63.GetValue(pos, tsi63Value))
      {
         continue;
      }
      double TSIusd = (tsi57Value + tsi58Value + tsi59Value + tsi60Value + tsi61Value + tsi62Value + tsi63Value) / 7;
      tsi64Source._data[pos] = cadeur;
      double tsi64Value;
      if (!tsi64.GetValue(pos, tsi64Value))
      {
         continue;
      }
      tsi65Source._data[pos] = cadgbp;
      double tsi65Value;
      if (!tsi65.GetValue(pos, tsi65Value))
      {
         continue;
      }
      tsi66Source._data[pos] = cadaud;
      double tsi66Value;
      if (!tsi66.GetValue(pos, tsi66Value))
      {
         continue;
      }
      tsi67Source._data[pos] = cadnzd;
      double tsi67Value;
      if (!tsi67.GetValue(pos, tsi67Value))
      {
         continue;
      }
      tsi68Source._data[pos] = cadusd;
      double tsi68Value;
      if (!tsi68.GetValue(pos, tsi68Value))
      {
         continue;
      }
      tsi69Source._data[pos] = cadchf;
      double tsi69Value;
      if (!tsi69.GetValue(pos, tsi69Value))
      {
         continue;
      }
      tsi70Source._data[pos] = cadjpy;
      double tsi70Value;
      if (!tsi70.GetValue(pos, tsi70Value))
      {
         continue;
      }
      double TSIcad = (tsi64Value + tsi65Value + tsi66Value + tsi67Value + tsi68Value + tsi69Value + tsi70Value) / 7;
      tsi71Source._data[pos] = chfeur;
      double tsi71Value;
      if (!tsi71.GetValue(pos, tsi71Value))
      {
         continue;
      }
      tsi72Source._data[pos] = chfgbp;
      double tsi72Value;
      if (!tsi72.GetValue(pos, tsi72Value))
      {
         continue;
      }
      tsi73Source._data[pos] = chfaud;
      double tsi73Value;
      if (!tsi73.GetValue(pos, tsi73Value))
      {
         continue;
      }
      tsi74Source._data[pos] = chfnzd;
      double tsi74Value;
      if (!tsi74.GetValue(pos, tsi74Value))
      {
         continue;
      }
      tsi75Source._data[pos] = chfusd;
      double tsi75Value;
      if (!tsi75.GetValue(pos, tsi75Value))
      {
         continue;
      }
      tsi76Source._data[pos] = chfcad;
      double tsi76Value;
      if (!tsi76.GetValue(pos, tsi76Value))
      {
         continue;
      }
      tsi77Source._data[pos] = chfjpy;
      double tsi77Value;
      if (!tsi77.GetValue(pos, tsi77Value))
      {
         continue;
      }
      double TSIchf = (tsi71Value + tsi72Value + tsi73Value + tsi74Value + tsi75Value + tsi76Value + tsi77Value) / 7;
      tsi78Source._data[pos] = jpyeur;
      double tsi78Value;
      if (!tsi78.GetValue(pos, tsi78Value))
      {
         continue;
      }
      tsi79Source._data[pos] = jpygbp;
      double tsi79Value;
      if (!tsi79.GetValue(pos, tsi79Value))
      {
         continue;
      }
      tsi80Source._data[pos] = jpyaud;
      double tsi80Value;
      if (!tsi80.GetValue(pos, tsi80Value))
      {
         continue;
      }
      tsi81Source._data[pos] = jpynzd;
      double tsi81Value;
      if (!tsi81.GetValue(pos, tsi81Value))
      {
         continue;
      }
      tsi82Source._data[pos] = jpyusd;
      double tsi82Value;
      if (!tsi82.GetValue(pos, tsi82Value))
      {
         continue;
      }
      tsi83Source._data[pos] = jpycad;
      double tsi83Value;
      if (!tsi83.GetValue(pos, tsi83Value))
      {
         continue;
      }
      tsi84Source._data[pos] = jpychf;
      double tsi84Value;
      if (!tsi84.GetValue(pos, tsi84Value))
      {
         continue;
      }
      double TSIjpy = (tsi78Value + tsi79Value + tsi80Value + tsi81Value + tsi82Value + tsi83Value + tsi84Value) / 7;

      rsi85X._data[pos] = eurgbp;
      double rsi85Value;
      if (!rsi85.GetValue(pos, rsi85Value))
      {
         continue;
      }
      rsi86X._data[pos] = euraud;
      double rsi86Value;
      if (!rsi86.GetValue(pos, rsi86Value))
      {
         continue;
      }
      rsi87X._data[pos] = eurnzd;
      double rsi87Value;
      if (!rsi87.GetValue(pos, rsi87Value))
      {
         continue;
      }
      rsi88X._data[pos] = eurusd;
      double rsi88Value;
      if (!rsi88.GetValue(pos, rsi88Value))
      {
         continue;
      }
      rsi89X._data[pos] = eurcad;
      double rsi89Value;
      if (!rsi89.GetValue(pos, rsi89Value))
      {
         continue;
      }
      rsi90X._data[pos] = eurchf;
      double rsi90Value;
      if (!rsi90.GetValue(pos, rsi90Value))
      {
         continue;
      }
      rsi91X._data[pos] = eurjpy;
      double rsi91Value;
      if (!rsi91.GetValue(pos, rsi91Value))
      {
         continue;
      }
      double RSIeur = (rsi85Value + rsi86Value + rsi87Value + rsi88Value + rsi89Value + rsi90Value + rsi91Value) / 7;
      rsi92X._data[pos] = gbpeur;
      double rsi92Value;
      if (!rsi92.GetValue(pos, rsi92Value))
      {
         continue;
      }
      rsi93X._data[pos] = gbpaud;
      double rsi93Value;
      if (!rsi93.GetValue(pos, rsi93Value))
      {
         continue;
      }
      rsi94X._data[pos] = gbpnzd;
      double rsi94Value;
      if (!rsi94.GetValue(pos, rsi94Value))
      {
         continue;
      }
      rsi95X._data[pos] = gbpusd;
      double rsi95Value;
      if (!rsi95.GetValue(pos, rsi95Value))
      {
         continue;
      }
      rsi96X._data[pos] = gbpcad;
      double rsi96Value;
      if (!rsi96.GetValue(pos, rsi96Value))
      {
         continue;
      }
      rsi97X._data[pos] = gbpchf;
      double rsi97Value;
      if (!rsi97.GetValue(pos, rsi97Value))
      {
         continue;
      }
      rsi98X._data[pos] = gbpjpy;
      double rsi98Value;
      if (!rsi98.GetValue(pos, rsi98Value))
      {
         continue;
      }
      double RSIgbp = (rsi92Value + rsi93Value + rsi94Value + rsi95Value + rsi96Value + rsi97Value + rsi98Value) / 7;
      rsi99X._data[pos] = audeur;
      double rsi99Value;
      if (!rsi99.GetValue(pos, rsi99Value))
      {
         continue;
      }
      rsi100X._data[pos] = audgbp;
      double rsi100Value;
      if (!rsi100.GetValue(pos, rsi100Value))
      {
         continue;
      }
      rsi101X._data[pos] = audnzd;
      double rsi101Value;
      if (!rsi101.GetValue(pos, rsi101Value))
      {
         continue;
      }
      rsi102X._data[pos] = audusd;
      double rsi102Value;
      if (!rsi102.GetValue(pos, rsi102Value))
      {
         continue;
      }
      rsi103X._data[pos] = audcad;
      double rsi103Value;
      if (!rsi103.GetValue(pos, rsi103Value))
      {
         continue;
      }
      rsi104X._data[pos] = audchf;
      double rsi104Value;
      if (!rsi104.GetValue(pos, rsi104Value))
      {
         continue;
      }
      rsi105X._data[pos] = audjpy;
      double rsi105Value;
      if (!rsi105.GetValue(pos, rsi105Value))
      {
         continue;
      }
      double RSIaud = (rsi99Value + rsi100Value + rsi101Value + rsi102Value + rsi103Value + rsi104Value + rsi105Value) / 7;
      rsi106X._data[pos] = nzdeur;
      double rsi106Value;
      if (!rsi106.GetValue(pos, rsi106Value))
      {
         continue;
      }
      rsi107X._data[pos] = nzdgbp;
      double rsi107Value;
      if (!rsi107.GetValue(pos, rsi107Value))
      {
         continue;
      }
      rsi108X._data[pos] = nzdaud;
      double rsi108Value;
      if (!rsi108.GetValue(pos, rsi108Value))
      {
         continue;
      }
      rsi109X._data[pos] = nzdusd;
      double rsi109Value;
      if (!rsi109.GetValue(pos, rsi109Value))
      {
         continue;
      }
      rsi110X._data[pos] = nzdcad;
      double rsi110Value;
      if (!rsi110.GetValue(pos, rsi110Value))
      {
         continue;
      }
      rsi111X._data[pos] = nzdchf;
      double rsi111Value;
      if (!rsi111.GetValue(pos, rsi111Value))
      {
         continue;
      }
      rsi112X._data[pos] = nzdjpy;
      double rsi112Value;
      if (!rsi112.GetValue(pos, rsi112Value))
      {
         continue;
      }
      double RSInzd = (rsi106Value + rsi107Value + rsi108Value + rsi109Value + rsi110Value + rsi111Value + rsi112Value) / 7;
      rsi113X._data[pos] = usdeur;
      double rsi113Value;
      if (!rsi113.GetValue(pos, rsi113Value))
      {
         continue;
      }
      rsi114X._data[pos] = usdgbp;
      double rsi114Value;
      if (!rsi114.GetValue(pos, rsi114Value))
      {
         continue;
      }
      rsi115X._data[pos] = usdaud;
      double rsi115Value;
      if (!rsi115.GetValue(pos, rsi115Value))
      {
         continue;
      }
      rsi116X._data[pos] = usdnzd;
      double rsi116Value;
      if (!rsi116.GetValue(pos, rsi116Value))
      {
         continue;
      }
      rsi117X._data[pos] = usdcad;
      double rsi117Value;
      if (!rsi117.GetValue(pos, rsi117Value))
      {
         continue;
      }
      rsi118X._data[pos] = usdchf;
      double rsi118Value;
      if (!rsi118.GetValue(pos, rsi118Value))
      {
         continue;
      }
      rsi119X._data[pos] = usdjpy;
      double rsi119Value;
      if (!rsi119.GetValue(pos, rsi119Value))
      {
         continue;
      }
      double RSIusd = (rsi113Value + rsi114Value + rsi115Value + rsi116Value + rsi117Value + rsi118Value + rsi119Value) / 7;
      rsi120X._data[pos] = cadeur;
      double rsi120Value;
      if (!rsi120.GetValue(pos, rsi120Value))
      {
         continue;
      }
      rsi121X._data[pos] = cadgbp;
      double rsi121Value;
      if (!rsi121.GetValue(pos, rsi121Value))
      {
         continue;
      }
      rsi122X._data[pos] = cadaud;
      double rsi122Value;
      if (!rsi122.GetValue(pos, rsi122Value))
      {
         continue;
      }
      rsi123X._data[pos] = cadnzd;
      double rsi123Value;
      if (!rsi123.GetValue(pos, rsi123Value))
      {
         continue;
      }
      rsi124X._data[pos] = cadusd;
      double rsi124Value;
      if (!rsi124.GetValue(pos, rsi124Value))
      {
         continue;
      }
      rsi125X._data[pos] = cadchf;
      double rsi125Value;
      if (!rsi125.GetValue(pos, rsi125Value))
      {
         continue;
      }
      rsi126X._data[pos] = cadjpy;
      double rsi126Value;
      if (!rsi126.GetValue(pos, rsi126Value))
      {
         continue;
      }
      double RSIcad = (rsi120Value + rsi121Value + rsi122Value + rsi123Value + rsi124Value + rsi125Value + rsi126Value) / 7;
      rsi127X._data[pos] = chfeur;
      double rsi127Value;
      if (!rsi127.GetValue(pos, rsi127Value))
      {
         continue;
      }
      rsi128X._data[pos] = chfgbp;
      double rsi128Value;
      if (!rsi128.GetValue(pos, rsi128Value))
      {
         continue;
      }
      rsi129X._data[pos] = chfaud;
      double rsi129Value;
      if (!rsi129.GetValue(pos, rsi129Value))
      {
         continue;
      }
      rsi130X._data[pos] = chfnzd;
      double rsi130Value;
      if (!rsi130.GetValue(pos, rsi130Value))
      {
         continue;
      }
      rsi131X._data[pos] = chfusd;
      double rsi131Value;
      if (!rsi131.GetValue(pos, rsi131Value))
      {
         continue;
      }
      rsi132X._data[pos] = chfcad;
      double rsi132Value;
      if (!rsi132.GetValue(pos, rsi132Value))
      {
         continue;
      }
      rsi133X._data[pos] = chfjpy;
      double rsi133Value;
      if (!rsi133.GetValue(pos, rsi133Value))
      {
         continue;
      }
      double RSIchf = (rsi127Value + rsi128Value + rsi129Value + rsi130Value + rsi131Value + rsi132Value + rsi133Value) / 7;
      rsi134X._data[pos] = jpyeur;
      double rsi134Value;
      if (!rsi134.GetValue(pos, rsi134Value))
      {
         continue;
      }
      rsi135X._data[pos] = jpygbp;
      double rsi135Value;
      if (!rsi135.GetValue(pos, rsi135Value))
      {
         continue;
      }
      rsi136X._data[pos] = jpyaud;
      double rsi136Value;
      if (!rsi136.GetValue(pos, rsi136Value))
      {
         continue;
      }
      rsi137X._data[pos] = jpynzd;
      double rsi137Value;
      if (!rsi137.GetValue(pos, rsi137Value))
      {
         continue;
      }
      rsi138X._data[pos] = jpyusd;
      double rsi138Value;
      if (!rsi138.GetValue(pos, rsi138Value))
      {
         continue;
      }
      rsi139X._data[pos] = jpycad;
      double rsi139Value;
      if (!rsi139.GetValue(pos, rsi139Value))
      {
         continue;
      }
      rsi140X._data[pos] = jpychf;
      double rsi140Value;
      if (!rsi140.GetValue(pos, rsi140Value))
      {
         continue;
      }
      double RSIjpy = (rsi134Value + rsi135Value + rsi136Value + rsi137Value + rsi138Value + rsi139Value + rsi140Value) / 7;


      roc141Source._data[pos] = eurgbp;
      double roc141Value;
      if (!roc141.GetValue(pos, roc141Value))
      {
         continue;
      }
      roc142Source._data[pos] = euraud;
      double roc142Value;
      if (!roc142.GetValue(pos, roc142Value))
      {
         continue;
      }
      roc143Source._data[pos] = eurnzd;
      double roc143Value;
      if (!roc143.GetValue(pos, roc143Value))
      {
         continue;
      }
      roc144Source._data[pos] = eurusd;
      double roc144Value;
      if (!roc144.GetValue(pos, roc144Value))
      {
         continue;
      }
      roc145Source._data[pos] = eurcad;
      double roc145Value;
      if (!roc145.GetValue(pos, roc145Value))
      {
         continue;
      }
      roc146Source._data[pos] = eurchf;
      double roc146Value;
      if (!roc146.GetValue(pos, roc146Value))
      {
         continue;
      }
      roc147Source._data[pos] = eurjpy;
      double roc147Value;
      if (!roc147.GetValue(pos, roc147Value))
      {
         continue;
      }
      double ROCeur = (roc141Value + roc142Value + roc143Value + roc144Value + roc145Value + roc146Value + roc147Value) / 7;
      roc148Source._data[pos] = gbpeur;
      double roc148Value;
      if (!roc148.GetValue(pos, roc148Value))
      {
         continue;
      }
      roc149Source._data[pos] = gbpaud;
      double roc149Value;
      if (!roc149.GetValue(pos, roc149Value))
      {
         continue;
      }
      roc150Source._data[pos] = gbpnzd;
      double roc150Value;
      if (!roc150.GetValue(pos, roc150Value))
      {
         continue;
      }
      roc151Source._data[pos] = gbpusd;
      double roc151Value;
      if (!roc151.GetValue(pos, roc151Value))
      {
         continue;
      }
      roc152Source._data[pos] = gbpcad;
      double roc152Value;
      if (!roc152.GetValue(pos, roc152Value))
      {
         continue;
      }
      roc153Source._data[pos] = gbpchf;
      double roc153Value;
      if (!roc153.GetValue(pos, roc153Value))
      {
         continue;
      }
      roc154Source._data[pos] = gbpjpy;
      double roc154Value;
      if (!roc154.GetValue(pos, roc154Value))
      {
         continue;
      }
      double ROCgbp = (roc148Value + roc149Value + roc150Value + roc151Value + roc152Value + roc153Value + roc154Value) / 7;
      roc155Source._data[pos] = audeur;
      double roc155Value;
      if (!roc155.GetValue(pos, roc155Value))
      {
         continue;
      }
      roc156Source._data[pos] = audgbp;
      double roc156Value;
      if (!roc156.GetValue(pos, roc156Value))
      {
         continue;
      }
      roc157Source._data[pos] = audnzd;
      double roc157Value;
      if (!roc157.GetValue(pos, roc157Value))
      {
         continue;
      }
      roc158Source._data[pos] = audusd;
      double roc158Value;
      if (!roc158.GetValue(pos, roc158Value))
      {
         continue;
      }
      roc159Source._data[pos] = audcad;
      double roc159Value;
      if (!roc159.GetValue(pos, roc159Value))
      {
         continue;
      }
      roc160Source._data[pos] = audchf;
      double roc160Value;
      if (!roc160.GetValue(pos, roc160Value))
      {
         continue;
      }
      roc161Source._data[pos] = audjpy;
      double roc161Value;
      if (!roc161.GetValue(pos, roc161Value))
      {
         continue;
      }
      double ROCaud = (roc155Value + roc156Value + roc157Value + roc158Value + roc159Value + roc160Value + roc161Value) / 7;
      roc162Source._data[pos] = nzdeur;
      double roc162Value;
      if (!roc162.GetValue(pos, roc162Value))
      {
         continue;
      }
      roc163Source._data[pos] = nzdgbp;
      double roc163Value;
      if (!roc163.GetValue(pos, roc163Value))
      {
         continue;
      }
      roc164Source._data[pos] = nzdaud;
      double roc164Value;
      if (!roc164.GetValue(pos, roc164Value))
      {
         continue;
      }
      roc165Source._data[pos] = nzdusd;
      double roc165Value;
      if (!roc165.GetValue(pos, roc165Value))
      {
         continue;
      }
      roc166Source._data[pos] = nzdcad;
      double roc166Value;
      if (!roc166.GetValue(pos, roc166Value))
      {
         continue;
      }
      roc167Source._data[pos] = nzdchf;
      double roc167Value;
      if (!roc167.GetValue(pos, roc167Value))
      {
         continue;
      }
      roc168Source._data[pos] = nzdjpy;
      double roc168Value;
      if (!roc168.GetValue(pos, roc168Value))
      {
         continue;
      }
      double ROCnzd = (roc162Value + roc163Value + roc164Value + roc165Value + roc166Value + roc167Value + roc168Value) / 7;
      roc169Source._data[pos] = usdeur;
      double roc169Value;
      if (!roc169.GetValue(pos, roc169Value))
      {
         continue;
      }
      roc170Source._data[pos] = usdgbp;
      double roc170Value;
      if (!roc170.GetValue(pos, roc170Value))
      {
         continue;
      }
      roc171Source._data[pos] = usdaud;
      double roc171Value;
      if (!roc171.GetValue(pos, roc171Value))
      {
         continue;
      }
      roc172Source._data[pos] = usdnzd;
      double roc172Value;
      if (!roc172.GetValue(pos, roc172Value))
      {
         continue;
      }
      roc173Source._data[pos] = usdcad;
      double roc173Value;
      if (!roc173.GetValue(pos, roc173Value))
      {
         continue;
      }
      roc174Source._data[pos] = usdchf;
      double roc174Value;
      if (!roc174.GetValue(pos, roc174Value))
      {
         continue;
      }
      roc175Source._data[pos] = usdjpy;
      double roc175Value;
      if (!roc175.GetValue(pos, roc175Value))
      {
         continue;
      }
      double ROCusd = (roc169Value + roc170Value + roc171Value + roc172Value + roc173Value + roc174Value + roc175Value) / 7;
      roc176Source._data[pos] = cadeur;
      double roc176Value;
      if (!roc176.GetValue(pos, roc176Value))
      {
         continue;
      }
      roc177Source._data[pos] = cadgbp;
      double roc177Value;
      if (!roc177.GetValue(pos, roc177Value))
      {
         continue;
      }
      roc178Source._data[pos] = cadaud;
      double roc178Value;
      if (!roc178.GetValue(pos, roc178Value))
      {
         continue;
      }
      roc179Source._data[pos] = cadnzd;
      double roc179Value;
      if (!roc179.GetValue(pos, roc179Value))
      {
         continue;
      }
      roc180Source._data[pos] = cadusd;
      double roc180Value;
      if (!roc180.GetValue(pos, roc180Value))
      {
         continue;
      }
      roc181Source._data[pos] = cadchf;
      double roc181Value;
      if (!roc181.GetValue(pos, roc181Value))
      {
         continue;
      }
      roc182Source._data[pos] = cadjpy;
      double roc182Value;
      if (!roc182.GetValue(pos, roc182Value))
      {
         continue;
      }
      double ROCcad = (roc176Value + roc177Value + roc178Value + roc179Value + roc180Value + roc181Value + roc182Value) / 7;
      roc183Source._data[pos] = chfeur;
      double roc183Value;
      if (!roc183.GetValue(pos, roc183Value))
      {
         continue;
      }
      roc184Source._data[pos] = chfgbp;
      double roc184Value;
      if (!roc184.GetValue(pos, roc184Value))
      {
         continue;
      }
      roc185Source._data[pos] = chfaud;
      double roc185Value;
      if (!roc185.GetValue(pos, roc185Value))
      {
         continue;
      }
      roc186Source._data[pos] = chfnzd;
      double roc186Value;
      if (!roc186.GetValue(pos, roc186Value))
      {
         continue;
      }
      roc187Source._data[pos] = chfusd;
      double roc187Value;
      if (!roc187.GetValue(pos, roc187Value))
      {
         continue;
      }
      roc188Source._data[pos] = chfcad;
      double roc188Value;
      if (!roc188.GetValue(pos, roc188Value))
      {
         continue;
      }
      roc189Source._data[pos] = chfjpy;
      double roc189Value;
      if (!roc189.GetValue(pos, roc189Value))
      {
         continue;
      }
      double ROCchf = (roc183Value + roc184Value + roc185Value + roc186Value + roc187Value + roc188Value + roc189Value) / 7;
      roc190Source._data[pos] = jpyeur;
      double roc190Value;
      if (!roc190.GetValue(pos, roc190Value))
      {
         continue;
      }
      roc191Source._data[pos] = jpygbp;
      double roc191Value;
      if (!roc191.GetValue(pos, roc191Value))
      {
         continue;
      }
      roc192Source._data[pos] = jpyaud;
      double roc192Value;
      if (!roc192.GetValue(pos, roc192Value))
      {
         continue;
      }
      roc193Source._data[pos] = jpynzd;
      double roc193Value;
      if (!roc193.GetValue(pos, roc193Value))
      {
         continue;
      }
      roc194Source._data[pos] = jpyusd;
      double roc194Value;
      if (!roc194.GetValue(pos, roc194Value))
      {
         continue;
      }
      roc195Source._data[pos] = jpycad;
      double roc195Value;
      if (!roc195.GetValue(pos, roc195Value))
      {
         continue;
      }
      roc196Source._data[pos] = jpychf;
      double roc196Value;
      if (!roc196.GetValue(pos, roc196Value))
      {
         continue;
      }
      double ROCjpy = (roc190Value + roc191Value + roc192Value + roc193Value + roc194Value + roc195Value + roc196Value) / 7;


      calc_abssioFunc57param1._data[pos] = eurgbp;
      double calc_abssioFunc57Value;
      if (!calc_abssioFunc57.GetValue(pos, calc_abssioFunc57Value))
      {
         continue;
      }
      calc_abssioFunc58param1._data[pos] = euraud;
      double calc_abssioFunc58Value;
      if (!calc_abssioFunc58.GetValue(pos, calc_abssioFunc58Value))
      {
         continue;
      }
      calc_abssioFunc59param1._data[pos] = eurnzd;
      double calc_abssioFunc59Value;
      if (!calc_abssioFunc59.GetValue(pos, calc_abssioFunc59Value))
      {
         continue;
      }
      calc_abssioFunc60param1._data[pos] = eurusd;
      double calc_abssioFunc60Value;
      if (!calc_abssioFunc60.GetValue(pos, calc_abssioFunc60Value))
      {
         continue;
      }
      calc_abssioFunc61param1._data[pos] = eurcad;
      double calc_abssioFunc61Value;
      if (!calc_abssioFunc61.GetValue(pos, calc_abssioFunc61Value))
      {
         continue;
      }
      calc_abssioFunc62param1._data[pos] = eurchf;
      double calc_abssioFunc62Value;
      if (!calc_abssioFunc62.GetValue(pos, calc_abssioFunc62Value))
      {
         continue;
      }
      calc_abssioFunc63param1._data[pos] = eurjpy;
      double calc_abssioFunc63Value;
      if (!calc_abssioFunc63.GetValue(pos, calc_abssioFunc63Value))
      {
         continue;
      }
      double ASIeur = (calc_abssioFunc57Value + calc_abssioFunc58Value + calc_abssioFunc59Value + calc_abssioFunc60Value + calc_abssioFunc61Value + calc_abssioFunc62Value + calc_abssioFunc63Value) / 7;
      calc_abssioFunc64param1._data[pos] = gbpeur;
      double calc_abssioFunc64Value;
      if (!calc_abssioFunc64.GetValue(pos, calc_abssioFunc64Value))
      {
         continue;
      }
      calc_abssioFunc65param1._data[pos] = gbpaud;
      double calc_abssioFunc65Value;
      if (!calc_abssioFunc65.GetValue(pos, calc_abssioFunc65Value))
      {
         continue;
      }
      calc_abssioFunc66param1._data[pos] = gbpnzd;
      double calc_abssioFunc66Value;
      if (!calc_abssioFunc66.GetValue(pos, calc_abssioFunc66Value))
      {
         continue;
      }
      calc_abssioFunc67param1._data[pos] = gbpusd;
      double calc_abssioFunc67Value;
      if (!calc_abssioFunc67.GetValue(pos, calc_abssioFunc67Value))
      {
         continue;
      }
      calc_abssioFunc68param1._data[pos] = gbpcad;
      double calc_abssioFunc68Value;
      if (!calc_abssioFunc68.GetValue(pos, calc_abssioFunc68Value))
      {
         continue;
      }
      calc_abssioFunc69param1._data[pos] = gbpchf;
      double calc_abssioFunc69Value;
      if (!calc_abssioFunc69.GetValue(pos, calc_abssioFunc69Value))
      {
         continue;
      }
      calc_abssioFunc70param1._data[pos] = gbpjpy;
      double calc_abssioFunc70Value;
      if (!calc_abssioFunc70.GetValue(pos, calc_abssioFunc70Value))
      {
         continue;
      }
      double ASIgbp = (calc_abssioFunc64Value + calc_abssioFunc65Value + calc_abssioFunc66Value + calc_abssioFunc67Value + calc_abssioFunc68Value + calc_abssioFunc69Value + calc_abssioFunc70Value) / 7;
      calc_abssioFunc71param1._data[pos] = audeur;
      double calc_abssioFunc71Value;
      if (!calc_abssioFunc71.GetValue(pos, calc_abssioFunc71Value))
      {
         continue;
      }
      calc_abssioFunc72param1._data[pos] = audgbp;
      double calc_abssioFunc72Value;
      if (!calc_abssioFunc72.GetValue(pos, calc_abssioFunc72Value))
      {
         continue;
      }
      calc_abssioFunc73param1._data[pos] = audnzd;
      double calc_abssioFunc73Value;
      if (!calc_abssioFunc73.GetValue(pos, calc_abssioFunc73Value))
      {
         continue;
      }
      calc_abssioFunc74param1._data[pos] = audusd;
      double calc_abssioFunc74Value;
      if (!calc_abssioFunc74.GetValue(pos, calc_abssioFunc74Value))
      {
         continue;
      }
      calc_abssioFunc75param1._data[pos] = audcad;
      double calc_abssioFunc75Value;
      if (!calc_abssioFunc75.GetValue(pos, calc_abssioFunc75Value))
      {
         continue;
      }
      calc_abssioFunc76param1._data[pos] = audchf;
      double calc_abssioFunc76Value;
      if (!calc_abssioFunc76.GetValue(pos, calc_abssioFunc76Value))
      {
         continue;
      }
      calc_abssioFunc77param1._data[pos] = audjpy;
      double calc_abssioFunc77Value;
      if (!calc_abssioFunc77.GetValue(pos, calc_abssioFunc77Value))
      {
         continue;
      }
      double ASIaud = (calc_abssioFunc71Value + calc_abssioFunc72Value + calc_abssioFunc73Value + calc_abssioFunc74Value + calc_abssioFunc75Value + calc_abssioFunc76Value + calc_abssioFunc77Value) / 7;
      calc_abssioFunc78param1._data[pos] = nzdeur;
      double calc_abssioFunc78Value;
      if (!calc_abssioFunc78.GetValue(pos, calc_abssioFunc78Value))
      {
         continue;
      }
      calc_abssioFunc79param1._data[pos] = nzdgbp;
      double calc_abssioFunc79Value;
      if (!calc_abssioFunc79.GetValue(pos, calc_abssioFunc79Value))
      {
         continue;
      }
      calc_abssioFunc80param1._data[pos] = nzdaud;
      double calc_abssioFunc80Value;
      if (!calc_abssioFunc80.GetValue(pos, calc_abssioFunc80Value))
      {
         continue;
      }
      calc_abssioFunc81param1._data[pos] = nzdusd;
      double calc_abssioFunc81Value;
      if (!calc_abssioFunc81.GetValue(pos, calc_abssioFunc81Value))
      {
         continue;
      }
      calc_abssioFunc82param1._data[pos] = nzdcad;
      double calc_abssioFunc82Value;
      if (!calc_abssioFunc82.GetValue(pos, calc_abssioFunc82Value))
      {
         continue;
      }
      calc_abssioFunc83param1._data[pos] = nzdchf;
      double calc_abssioFunc83Value;
      if (!calc_abssioFunc83.GetValue(pos, calc_abssioFunc83Value))
      {
         continue;
      }
      calc_abssioFunc84param1._data[pos] = nzdjpy;
      double calc_abssioFunc84Value;
      if (!calc_abssioFunc84.GetValue(pos, calc_abssioFunc84Value))
      {
         continue;
      }
      double ASInzd = (calc_abssioFunc78Value + calc_abssioFunc79Value + calc_abssioFunc80Value + calc_abssioFunc81Value + calc_abssioFunc82Value + calc_abssioFunc83Value + calc_abssioFunc84Value) / 7;
      calc_abssioFunc85param1._data[pos] = usdeur;
      double calc_abssioFunc85Value;
      if (!calc_abssioFunc85.GetValue(pos, calc_abssioFunc85Value))
      {
         continue;
      }
      calc_abssioFunc86param1._data[pos] = usdgbp;
      double calc_abssioFunc86Value;
      if (!calc_abssioFunc86.GetValue(pos, calc_abssioFunc86Value))
      {
         continue;
      }
      calc_abssioFunc87param1._data[pos] = usdaud;
      double calc_abssioFunc87Value;
      if (!calc_abssioFunc87.GetValue(pos, calc_abssioFunc87Value))
      {
         continue;
      }
      calc_abssioFunc88param1._data[pos] = usdnzd;
      double calc_abssioFunc88Value;
      if (!calc_abssioFunc88.GetValue(pos, calc_abssioFunc88Value))
      {
         continue;
      }
      calc_abssioFunc89param1._data[pos] = usdcad;
      double calc_abssioFunc89Value;
      if (!calc_abssioFunc89.GetValue(pos, calc_abssioFunc89Value))
      {
         continue;
      }
      calc_abssioFunc90param1._data[pos] = usdchf;
      double calc_abssioFunc90Value;
      if (!calc_abssioFunc90.GetValue(pos, calc_abssioFunc90Value))
      {
         continue;
      }
      calc_abssioFunc91param1._data[pos] = usdjpy;
      double calc_abssioFunc91Value;
      if (!calc_abssioFunc91.GetValue(pos, calc_abssioFunc91Value))
      {
         continue;
      }
      double ASIusd = (calc_abssioFunc85Value + calc_abssioFunc86Value + calc_abssioFunc87Value + calc_abssioFunc88Value + calc_abssioFunc89Value + calc_abssioFunc90Value + calc_abssioFunc91Value) / 7;
      calc_abssioFunc92param1._data[pos] = cadeur;
      double calc_abssioFunc92Value;
      if (!calc_abssioFunc92.GetValue(pos, calc_abssioFunc92Value))
      {
         continue;
      }
      calc_abssioFunc93param1._data[pos] = cadgbp;
      double calc_abssioFunc93Value;
      if (!calc_abssioFunc93.GetValue(pos, calc_abssioFunc93Value))
      {
         continue;
      }
      calc_abssioFunc94param1._data[pos] = cadaud;
      double calc_abssioFunc94Value;
      if (!calc_abssioFunc94.GetValue(pos, calc_abssioFunc94Value))
      {
         continue;
      }
      calc_abssioFunc95param1._data[pos] = cadnzd;
      double calc_abssioFunc95Value;
      if (!calc_abssioFunc95.GetValue(pos, calc_abssioFunc95Value))
      {
         continue;
      }
      calc_abssioFunc96param1._data[pos] = cadusd;
      double calc_abssioFunc96Value;
      if (!calc_abssioFunc96.GetValue(pos, calc_abssioFunc96Value))
      {
         continue;
      }
      calc_abssioFunc97param1._data[pos] = cadchf;
      double calc_abssioFunc97Value;
      if (!calc_abssioFunc97.GetValue(pos, calc_abssioFunc97Value))
      {
         continue;
      }
      calc_abssioFunc98param1._data[pos] = cadjpy;
      double calc_abssioFunc98Value;
      if (!calc_abssioFunc98.GetValue(pos, calc_abssioFunc98Value))
      {
         continue;
      }
      double ASIcad = (calc_abssioFunc92Value + calc_abssioFunc93Value + calc_abssioFunc94Value + calc_abssioFunc95Value + calc_abssioFunc96Value + calc_abssioFunc97Value + calc_abssioFunc98Value) / 7;
      calc_abssioFunc99param1._data[pos] = chfeur;
      double calc_abssioFunc99Value;
      if (!calc_abssioFunc99.GetValue(pos, calc_abssioFunc99Value))
      {
         continue;
      }
      calc_abssioFunc100param1._data[pos] = chfgbp;
      double calc_abssioFunc100Value;
      if (!calc_abssioFunc100.GetValue(pos, calc_abssioFunc100Value))
      {
         continue;
      }
      calc_abssioFunc101param1._data[pos] = chfaud;
      double calc_abssioFunc101Value;
      if (!calc_abssioFunc101.GetValue(pos, calc_abssioFunc101Value))
      {
         continue;
      }
      calc_abssioFunc102param1._data[pos] = chfnzd;
      double calc_abssioFunc102Value;
      if (!calc_abssioFunc102.GetValue(pos, calc_abssioFunc102Value))
      {
         continue;
      }
      calc_abssioFunc103param1._data[pos] = chfusd;
      double calc_abssioFunc103Value;
      if (!calc_abssioFunc103.GetValue(pos, calc_abssioFunc103Value))
      {
         continue;
      }
      calc_abssioFunc104param1._data[pos] = chfcad;
      double calc_abssioFunc104Value;
      if (!calc_abssioFunc104.GetValue(pos, calc_abssioFunc104Value))
      {
         continue;
      }
      calc_abssioFunc105param1._data[pos] = chfjpy;
      double calc_abssioFunc105Value;
      if (!calc_abssioFunc105.GetValue(pos, calc_abssioFunc105Value))
      {
         continue;
      }
      double ASIchf = (calc_abssioFunc99Value + calc_abssioFunc100Value + calc_abssioFunc101Value + calc_abssioFunc102Value + calc_abssioFunc103Value + calc_abssioFunc104Value + calc_abssioFunc105Value) / 7;
      calc_abssioFunc106param1._data[pos] = jpyeur;
      double calc_abssioFunc106Value;
      if (!calc_abssioFunc106.GetValue(pos, calc_abssioFunc106Value))
      {
         continue;
      }
      calc_abssioFunc107param1._data[pos] = jpygbp;
      double calc_abssioFunc107Value;
      if (!calc_abssioFunc107.GetValue(pos, calc_abssioFunc107Value))
      {
         continue;
      }
      calc_abssioFunc108param1._data[pos] = jpyaud;
      double calc_abssioFunc108Value;
      if (!calc_abssioFunc108.GetValue(pos, calc_abssioFunc108Value))
      {
         continue;
      }
      calc_abssioFunc109param1._data[pos] = jpynzd;
      double calc_abssioFunc109Value;
      if (!calc_abssioFunc109.GetValue(pos, calc_abssioFunc109Value))
      {
         continue;
      }
      calc_abssioFunc110param1._data[pos] = jpyusd;
      double calc_abssioFunc110Value;
      if (!calc_abssioFunc110.GetValue(pos, calc_abssioFunc110Value))
      {
         continue;
      }
      calc_abssioFunc111param1._data[pos] = jpycad;
      double calc_abssioFunc111Value;
      if (!calc_abssioFunc111.GetValue(pos, calc_abssioFunc111Value))
      {
         continue;
      }
      calc_abssioFunc112param1._data[pos] = jpychf;
      double calc_abssioFunc112Value;
      if (!calc_abssioFunc112.GetValue(pos, calc_abssioFunc112Value))
      {
         continue;
      }
      double ASIjpy = (calc_abssioFunc106Value + calc_abssioFunc107Value + calc_abssioFunc108Value + calc_abssioFunc109Value + calc_abssioFunc110Value + calc_abssioFunc111Value + calc_abssioFunc112Value) / 7;


      ZSFunc113param1._data[pos] = eurgbp;
      double ZSFunc113Value;
      if (!ZSFunc113.GetValue(pos, ZSFunc113Value))
      {
         continue;
      }
      ZSFunc114param1._data[pos] = euraud;
      double ZSFunc114Value;
      if (!ZSFunc114.GetValue(pos, ZSFunc114Value))
      {
         continue;
      }
      ZSFunc115param1._data[pos] = eurnzd;
      double ZSFunc115Value;
      if (!ZSFunc115.GetValue(pos, ZSFunc115Value))
      {
         continue;
      }
      ZSFunc116param1._data[pos] = eurusd;
      double ZSFunc116Value;
      if (!ZSFunc116.GetValue(pos, ZSFunc116Value))
      {
         continue;
      }
      ZSFunc117param1._data[pos] = eurcad;
      double ZSFunc117Value;
      if (!ZSFunc117.GetValue(pos, ZSFunc117Value))
      {
         continue;
      }
      ZSFunc118param1._data[pos] = eurchf;
      double ZSFunc118Value;
      if (!ZSFunc118.GetValue(pos, ZSFunc118Value))
      {
         continue;
      }
      ZSFunc119param1._data[pos] = eurjpy;
      double ZSFunc119Value;
      if (!ZSFunc119.GetValue(pos, ZSFunc119Value))
      {
         continue;
      }
      double ZSeur = (ZSFunc113Value + ZSFunc114Value + ZSFunc115Value + ZSFunc116Value + ZSFunc117Value + ZSFunc118Value + ZSFunc119Value) / 7;
      ZSFunc120param1._data[pos] = gbpeur;
      double ZSFunc120Value;
      if (!ZSFunc120.GetValue(pos, ZSFunc120Value))
      {
         continue;
      }
      ZSFunc121param1._data[pos] = gbpaud;
      double ZSFunc121Value;
      if (!ZSFunc121.GetValue(pos, ZSFunc121Value))
      {
         continue;
      }
      ZSFunc122param1._data[pos] = gbpnzd;
      double ZSFunc122Value;
      if (!ZSFunc122.GetValue(pos, ZSFunc122Value))
      {
         continue;
      }
      ZSFunc123param1._data[pos] = gbpusd;
      double ZSFunc123Value;
      if (!ZSFunc123.GetValue(pos, ZSFunc123Value))
      {
         continue;
      }
      ZSFunc124param1._data[pos] = gbpcad;
      double ZSFunc124Value;
      if (!ZSFunc124.GetValue(pos, ZSFunc124Value))
      {
         continue;
      }
      ZSFunc125param1._data[pos] = gbpchf;
      double ZSFunc125Value;
      if (!ZSFunc125.GetValue(pos, ZSFunc125Value))
      {
         continue;
      }
      ZSFunc126param1._data[pos] = gbpjpy;
      double ZSFunc126Value;
      if (!ZSFunc126.GetValue(pos, ZSFunc126Value))
      {
         continue;
      }
      double ZSgbp = (ZSFunc120Value + ZSFunc121Value + ZSFunc122Value + ZSFunc123Value + ZSFunc124Value + ZSFunc125Value + ZSFunc126Value) / 7;
      ZSFunc127param1._data[pos] = audeur;
      double ZSFunc127Value;
      if (!ZSFunc127.GetValue(pos, ZSFunc127Value))
      {
         continue;
      }
      ZSFunc128param1._data[pos] = audgbp;
      double ZSFunc128Value;
      if (!ZSFunc128.GetValue(pos, ZSFunc128Value))
      {
         continue;
      }
      ZSFunc129param1._data[pos] = audnzd;
      double ZSFunc129Value;
      if (!ZSFunc129.GetValue(pos, ZSFunc129Value))
      {
         continue;
      }
      ZSFunc130param1._data[pos] = audusd;
      double ZSFunc130Value;
      if (!ZSFunc130.GetValue(pos, ZSFunc130Value))
      {
         continue;
      }
      ZSFunc131param1._data[pos] = audcad;
      double ZSFunc131Value;
      if (!ZSFunc131.GetValue(pos, ZSFunc131Value))
      {
         continue;
      }
      ZSFunc132param1._data[pos] = audchf;
      double ZSFunc132Value;
      if (!ZSFunc132.GetValue(pos, ZSFunc132Value))
      {
         continue;
      }
      ZSFunc133param1._data[pos] = audjpy;
      double ZSFunc133Value;
      if (!ZSFunc133.GetValue(pos, ZSFunc133Value))
      {
         continue;
      }
      double ZSaud = (ZSFunc127Value + ZSFunc128Value + ZSFunc129Value + ZSFunc130Value + ZSFunc131Value + ZSFunc132Value + ZSFunc133Value) / 7;
      ZSFunc134param1._data[pos] = nzdeur;
      double ZSFunc134Value;
      if (!ZSFunc134.GetValue(pos, ZSFunc134Value))
      {
         continue;
      }
      ZSFunc135param1._data[pos] = nzdgbp;
      double ZSFunc135Value;
      if (!ZSFunc135.GetValue(pos, ZSFunc135Value))
      {
         continue;
      }
      ZSFunc136param1._data[pos] = nzdaud;
      double ZSFunc136Value;
      if (!ZSFunc136.GetValue(pos, ZSFunc136Value))
      {
         continue;
      }
      ZSFunc137param1._data[pos] = nzdusd;
      double ZSFunc137Value;
      if (!ZSFunc137.GetValue(pos, ZSFunc137Value))
      {
         continue;
      }
      ZSFunc138param1._data[pos] = nzdcad;
      double ZSFunc138Value;
      if (!ZSFunc138.GetValue(pos, ZSFunc138Value))
      {
         continue;
      }
      ZSFunc139param1._data[pos] = nzdchf;
      double ZSFunc139Value;
      if (!ZSFunc139.GetValue(pos, ZSFunc139Value))
      {
         continue;
      }
      ZSFunc140param1._data[pos] = nzdjpy;
      double ZSFunc140Value;
      if (!ZSFunc140.GetValue(pos, ZSFunc140Value))
      {
         continue;
      }
      double ZSnzd = (ZSFunc134Value + ZSFunc135Value + ZSFunc136Value + ZSFunc137Value + ZSFunc138Value + ZSFunc139Value + ZSFunc140Value) / 7;
      ZSFunc141param1._data[pos] = usdeur;
      double ZSFunc141Value;
      if (!ZSFunc141.GetValue(pos, ZSFunc141Value))
      {
         continue;
      }
      ZSFunc142param1._data[pos] = usdgbp;
      double ZSFunc142Value;
      if (!ZSFunc142.GetValue(pos, ZSFunc142Value))
      {
         continue;
      }
      ZSFunc143param1._data[pos] = usdaud;
      double ZSFunc143Value;
      if (!ZSFunc143.GetValue(pos, ZSFunc143Value))
      {
         continue;
      }
      ZSFunc144param1._data[pos] = usdnzd;
      double ZSFunc144Value;
      if (!ZSFunc144.GetValue(pos, ZSFunc144Value))
      {
         continue;
      }
      ZSFunc145param1._data[pos] = usdcad;
      double ZSFunc145Value;
      if (!ZSFunc145.GetValue(pos, ZSFunc145Value))
      {
         continue;
      }
      ZSFunc146param1._data[pos] = usdchf;
      double ZSFunc146Value;
      if (!ZSFunc146.GetValue(pos, ZSFunc146Value))
      {
         continue;
      }
      ZSFunc147param1._data[pos] = usdjpy;
      double ZSFunc147Value;
      if (!ZSFunc147.GetValue(pos, ZSFunc147Value))
      {
         continue;
      }
      double ZSusd = (ZSFunc141Value + ZSFunc142Value + ZSFunc143Value + ZSFunc144Value + ZSFunc145Value + ZSFunc146Value + ZSFunc147Value) / 7;
      ZSFunc148param1._data[pos] = cadeur;
      double ZSFunc148Value;
      if (!ZSFunc148.GetValue(pos, ZSFunc148Value))
      {
         continue;
      }
      ZSFunc149param1._data[pos] = cadgbp;
      double ZSFunc149Value;
      if (!ZSFunc149.GetValue(pos, ZSFunc149Value))
      {
         continue;
      }
      ZSFunc150param1._data[pos] = cadaud;
      double ZSFunc150Value;
      if (!ZSFunc150.GetValue(pos, ZSFunc150Value))
      {
         continue;
      }
      ZSFunc151param1._data[pos] = cadnzd;
      double ZSFunc151Value;
      if (!ZSFunc151.GetValue(pos, ZSFunc151Value))
      {
         continue;
      }
      ZSFunc152param1._data[pos] = cadusd;
      double ZSFunc152Value;
      if (!ZSFunc152.GetValue(pos, ZSFunc152Value))
      {
         continue;
      }
      ZSFunc153param1._data[pos] = cadchf;
      double ZSFunc153Value;
      if (!ZSFunc153.GetValue(pos, ZSFunc153Value))
      {
         continue;
      }
      ZSFunc154param1._data[pos] = cadjpy;
      double ZSFunc154Value;
      if (!ZSFunc154.GetValue(pos, ZSFunc154Value))
      {
         continue;
      }
      double ZScad = (ZSFunc148Value + ZSFunc149Value + ZSFunc150Value + ZSFunc151Value + ZSFunc152Value + ZSFunc153Value + ZSFunc154Value) / 7;
      ZSFunc155param1._data[pos] = chfeur;
      double ZSFunc155Value;
      if (!ZSFunc155.GetValue(pos, ZSFunc155Value))
      {
         continue;
      }
      ZSFunc156param1._data[pos] = chfgbp;
      double ZSFunc156Value;
      if (!ZSFunc156.GetValue(pos, ZSFunc156Value))
      {
         continue;
      }
      ZSFunc157param1._data[pos] = chfaud;
      double ZSFunc157Value;
      if (!ZSFunc157.GetValue(pos, ZSFunc157Value))
      {
         continue;
      }
      ZSFunc158param1._data[pos] = chfnzd;
      double ZSFunc158Value;
      if (!ZSFunc158.GetValue(pos, ZSFunc158Value))
      {
         continue;
      }
      ZSFunc159param1._data[pos] = chfusd;
      double ZSFunc159Value;
      if (!ZSFunc159.GetValue(pos, ZSFunc159Value))
      {
         continue;
      }
      ZSFunc160param1._data[pos] = chfcad;
      double ZSFunc160Value;
      if (!ZSFunc160.GetValue(pos, ZSFunc160Value))
      {
         continue;
      }
      ZSFunc161param1._data[pos] = chfjpy;
      double ZSFunc161Value;
      if (!ZSFunc161.GetValue(pos, ZSFunc161Value))
      {
         continue;
      }
      double ZSchf = (ZSFunc155Value + ZSFunc156Value + ZSFunc157Value + ZSFunc158Value + ZSFunc159Value + ZSFunc160Value + ZSFunc161Value) / 7;
      ZSFunc162param1._data[pos] = jpyeur;
      double ZSFunc162Value;
      if (!ZSFunc162.GetValue(pos, ZSFunc162Value))
      {
         continue;
      }
      ZSFunc163param1._data[pos] = jpygbp;
      double ZSFunc163Value;
      if (!ZSFunc163.GetValue(pos, ZSFunc163Value))
      {
         continue;
      }
      ZSFunc164param1._data[pos] = jpyaud;
      double ZSFunc164Value;
      if (!ZSFunc164.GetValue(pos, ZSFunc164Value))
      {
         continue;
      }
      ZSFunc165param1._data[pos] = jpynzd;
      double ZSFunc165Value;
      if (!ZSFunc165.GetValue(pos, ZSFunc165Value))
      {
         continue;
      }
      ZSFunc166param1._data[pos] = jpyusd;
      double ZSFunc166Value;
      if (!ZSFunc166.GetValue(pos, ZSFunc166Value))
      {
         continue;
      }
      ZSFunc167param1._data[pos] = jpycad;
      double ZSFunc167Value;
      if (!ZSFunc167.GetValue(pos, ZSFunc167Value))
      {
         continue;
      }
      ZSFunc168param1._data[pos] = jpychf;
      double ZSFunc168Value;
      if (!ZSFunc168.GetValue(pos, ZSFunc168Value))
      {
         continue;
      }
      double ZSjpy = (ZSFunc162Value + ZSFunc163Value + ZSFunc164Value + ZSFunc165Value + ZSFunc166Value + ZSFunc167Value + ZSFunc168Value) / 7;



      functionFunc169param1._data[pos] = eurgbp;
      double functionFunc169Value;
      if (!functionFunc169.GetValue(pos, functionFunc169Value))
      {
         continue;
      }
      functionFunc170param1._data[pos] = euraud;
      double functionFunc170Value;
      if (!functionFunc170.GetValue(pos, functionFunc170Value))
      {
         continue;
      }
      functionFunc171param1._data[pos] = eurnzd;
      double functionFunc171Value;
      if (!functionFunc171.GetValue(pos, functionFunc171Value))
      {
         continue;
      }
      functionFunc172param1._data[pos] = eurusd;
      double functionFunc172Value;
      if (!functionFunc172.GetValue(pos, functionFunc172Value))
      {
         continue;
      }
      functionFunc173param1._data[pos] = eurcad;
      double functionFunc173Value;
      if (!functionFunc173.GetValue(pos, functionFunc173Value))
      {
         continue;
      }
      functionFunc174param1._data[pos] = eurchf;
      double functionFunc174Value;
      if (!functionFunc174.GetValue(pos, functionFunc174Value))
      {
         continue;
      }
      functionFunc175param1._data[pos] = eurjpy;
      double functionFunc175Value;
      if (!functionFunc175.GetValue(pos, functionFunc175Value))
      {
         continue;
      }
      double Meur = (functionFunc169Value + functionFunc170Value + functionFunc171Value + functionFunc172Value + functionFunc173Value + functionFunc174Value + functionFunc175Value) / 7;
      functionFunc176param1._data[pos] = gbpeur;
      double functionFunc176Value;
      if (!functionFunc176.GetValue(pos, functionFunc176Value))
      {
         continue;
      }
      functionFunc177param1._data[pos] = gbpaud;
      double functionFunc177Value;
      if (!functionFunc177.GetValue(pos, functionFunc177Value))
      {
         continue;
      }
      functionFunc178param1._data[pos] = gbpnzd;
      double functionFunc178Value;
      if (!functionFunc178.GetValue(pos, functionFunc178Value))
      {
         continue;
      }
      functionFunc179param1._data[pos] = gbpusd;
      double functionFunc179Value;
      if (!functionFunc179.GetValue(pos, functionFunc179Value))
      {
         continue;
      }
      functionFunc180param1._data[pos] = gbpcad;
      double functionFunc180Value;
      if (!functionFunc180.GetValue(pos, functionFunc180Value))
      {
         continue;
      }
      functionFunc181param1._data[pos] = gbpchf;
      double functionFunc181Value;
      if (!functionFunc181.GetValue(pos, functionFunc181Value))
      {
         continue;
      }
      functionFunc182param1._data[pos] = gbpjpy;
      double functionFunc182Value;
      if (!functionFunc182.GetValue(pos, functionFunc182Value))
      {
         continue;
      }
      double Mgbp = (functionFunc176Value + functionFunc177Value + functionFunc178Value + functionFunc179Value + functionFunc180Value + functionFunc181Value + functionFunc182Value) / 7;
      functionFunc183param1._data[pos] = audeur;
      double functionFunc183Value;
      if (!functionFunc183.GetValue(pos, functionFunc183Value))
      {
         continue;
      }
      functionFunc184param1._data[pos] = audgbp;
      double functionFunc184Value;
      if (!functionFunc184.GetValue(pos, functionFunc184Value))
      {
         continue;
      }
      functionFunc185param1._data[pos] = audnzd;
      double functionFunc185Value;
      if (!functionFunc185.GetValue(pos, functionFunc185Value))
      {
         continue;
      }
      functionFunc186param1._data[pos] = audusd;
      double functionFunc186Value;
      if (!functionFunc186.GetValue(pos, functionFunc186Value))
      {
         continue;
      }
      functionFunc187param1._data[pos] = audcad;
      double functionFunc187Value;
      if (!functionFunc187.GetValue(pos, functionFunc187Value))
      {
         continue;
      }
      functionFunc188param1._data[pos] = audchf;
      double functionFunc188Value;
      if (!functionFunc188.GetValue(pos, functionFunc188Value))
      {
         continue;
      }
      functionFunc189param1._data[pos] = audjpy;
      double functionFunc189Value;
      if (!functionFunc189.GetValue(pos, functionFunc189Value))
      {
         continue;
      }
      double Maud = (functionFunc183Value + functionFunc184Value + functionFunc185Value + functionFunc186Value + functionFunc187Value + functionFunc188Value + functionFunc189Value) / 7;
      functionFunc190param1._data[pos] = nzdeur;
      double functionFunc190Value;
      if (!functionFunc190.GetValue(pos, functionFunc190Value))
      {
         continue;
      }
      functionFunc191param1._data[pos] = nzdgbp;
      double functionFunc191Value;
      if (!functionFunc191.GetValue(pos, functionFunc191Value))
      {
         continue;
      }
      functionFunc192param1._data[pos] = nzdaud;
      double functionFunc192Value;
      if (!functionFunc192.GetValue(pos, functionFunc192Value))
      {
         continue;
      }
      functionFunc193param1._data[pos] = nzdusd;
      double functionFunc193Value;
      if (!functionFunc193.GetValue(pos, functionFunc193Value))
      {
         continue;
      }
      functionFunc194param1._data[pos] = nzdcad;
      double functionFunc194Value;
      if (!functionFunc194.GetValue(pos, functionFunc194Value))
      {
         continue;
      }
      functionFunc195param1._data[pos] = nzdchf;
      double functionFunc195Value;
      if (!functionFunc195.GetValue(pos, functionFunc195Value))
      {
         continue;
      }
      functionFunc196param1._data[pos] = nzdjpy;
      double functionFunc196Value;
      if (!functionFunc196.GetValue(pos, functionFunc196Value))
      {
         continue;
      }
      double Mnzd = (functionFunc190Value + functionFunc191Value + functionFunc192Value + functionFunc193Value + functionFunc194Value + functionFunc195Value + functionFunc196Value) / 7;
      functionFunc197param1._data[pos] = usdeur;
      double functionFunc197Value;
      if (!functionFunc197.GetValue(pos, functionFunc197Value))
      {
         continue;
      }
      functionFunc198param1._data[pos] = usdgbp;
      double functionFunc198Value;
      if (!functionFunc198.GetValue(pos, functionFunc198Value))
      {
         continue;
      }
      functionFunc199param1._data[pos] = usdaud;
      double functionFunc199Value;
      if (!functionFunc199.GetValue(pos, functionFunc199Value))
      {
         continue;
      }
      functionFunc200param1._data[pos] = usdnzd;
      double functionFunc200Value;
      if (!functionFunc200.GetValue(pos, functionFunc200Value))
      {
         continue;
      }
      functionFunc201param1._data[pos] = usdcad;
      double functionFunc201Value;
      if (!functionFunc201.GetValue(pos, functionFunc201Value))
      {
         continue;
      }
      functionFunc202param1._data[pos] = usdchf;
      double functionFunc202Value;
      if (!functionFunc202.GetValue(pos, functionFunc202Value))
      {
         continue;
      }
      functionFunc203param1._data[pos] = usdjpy;
      double functionFunc203Value;
      if (!functionFunc203.GetValue(pos, functionFunc203Value))
      {
         continue;
      }
      double Musd = (functionFunc197Value + functionFunc198Value + functionFunc199Value + functionFunc200Value + functionFunc201Value + functionFunc202Value + functionFunc203Value) / 7;
      functionFunc204param1._data[pos] = cadeur;
      double functionFunc204Value;
      if (!functionFunc204.GetValue(pos, functionFunc204Value))
      {
         continue;
      }
      functionFunc205param1._data[pos] = cadgbp;
      double functionFunc205Value;
      if (!functionFunc205.GetValue(pos, functionFunc205Value))
      {
         continue;
      }
      functionFunc206param1._data[pos] = cadaud;
      double functionFunc206Value;
      if (!functionFunc206.GetValue(pos, functionFunc206Value))
      {
         continue;
      }
      functionFunc207param1._data[pos] = cadnzd;
      double functionFunc207Value;
      if (!functionFunc207.GetValue(pos, functionFunc207Value))
      {
         continue;
      }
      functionFunc208param1._data[pos] = cadusd;
      double functionFunc208Value;
      if (!functionFunc208.GetValue(pos, functionFunc208Value))
      {
         continue;
      }
      functionFunc209param1._data[pos] = cadchf;
      double functionFunc209Value;
      if (!functionFunc209.GetValue(pos, functionFunc209Value))
      {
         continue;
      }
      functionFunc210param1._data[pos] = cadjpy;
      double functionFunc210Value;
      if (!functionFunc210.GetValue(pos, functionFunc210Value))
      {
         continue;
      }
      double Mcad = (functionFunc204Value + functionFunc205Value + functionFunc206Value + functionFunc207Value + functionFunc208Value + functionFunc209Value + functionFunc210Value) / 7;
      functionFunc211param1._data[pos] = chfeur;
      double functionFunc211Value;
      if (!functionFunc211.GetValue(pos, functionFunc211Value))
      {
         continue;
      }
      functionFunc212param1._data[pos] = chfgbp;
      double functionFunc212Value;
      if (!functionFunc212.GetValue(pos, functionFunc212Value))
      {
         continue;
      }
      functionFunc213param1._data[pos] = chfaud;
      double functionFunc213Value;
      if (!functionFunc213.GetValue(pos, functionFunc213Value))
      {
         continue;
      }
      functionFunc214param1._data[pos] = chfnzd;
      double functionFunc214Value;
      if (!functionFunc214.GetValue(pos, functionFunc214Value))
      {
         continue;
      }
      functionFunc215param1._data[pos] = chfusd;
      double functionFunc215Value;
      if (!functionFunc215.GetValue(pos, functionFunc215Value))
      {
         continue;
      }
      functionFunc216param1._data[pos] = chfcad;
      double functionFunc216Value;
      if (!functionFunc216.GetValue(pos, functionFunc216Value))
      {
         continue;
      }
      functionFunc217param1._data[pos] = chfjpy;
      double functionFunc217Value;
      if (!functionFunc217.GetValue(pos, functionFunc217Value))
      {
         continue;
      }
      double Mchf = (functionFunc211Value + functionFunc212Value + functionFunc213Value + functionFunc214Value + functionFunc215Value + functionFunc216Value + functionFunc217Value) / 7;
      functionFunc218param1._data[pos] = jpyeur;
      double functionFunc218Value;
      if (!functionFunc218.GetValue(pos, functionFunc218Value))
      {
         continue;
      }
      functionFunc219param1._data[pos] = jpygbp;
      double functionFunc219Value;
      if (!functionFunc219.GetValue(pos, functionFunc219Value))
      {
         continue;
      }
      functionFunc220param1._data[pos] = jpyaud;
      double functionFunc220Value;
      if (!functionFunc220.GetValue(pos, functionFunc220Value))
      {
         continue;
      }
      functionFunc221param1._data[pos] = jpynzd;
      double functionFunc221Value;
      if (!functionFunc221.GetValue(pos, functionFunc221Value))
      {
         continue;
      }
      functionFunc222param1._data[pos] = jpyusd;
      double functionFunc222Value;
      if (!functionFunc222.GetValue(pos, functionFunc222Value))
      {
         continue;
      }
      functionFunc223param1._data[pos] = jpycad;
      double functionFunc223Value;
      if (!functionFunc223.GetValue(pos, functionFunc223Value))
      {
         continue;
      }
      functionFunc224param1._data[pos] = jpychf;
      double functionFunc224Value;
      if (!functionFunc224.GetValue(pos, functionFunc224Value))
      {
         continue;
      }
      double Mjpy = (functionFunc218Value + functionFunc219Value + functionFunc220Value + functionFunc221Value + functionFunc222Value + functionFunc223Value + functionFunc224Value) / 7;



      double EUR = ((mode == MO1) ? RSIeur : ((mode == MO2) ? TSIeur : ((mode == MO3) ? ROCeur : ((mode == MO4) ? ASIeur : ((mode == MO5) ? LRSeur : ((mode == MO6) ? ZSeur : ((mode == MO7) ? Meur : EMPTY_VALUE)))))));
      double GBP = ((mode == MO1) ? RSIgbp : ((mode == MO2) ? TSIgbp : ((mode == MO3) ? ROCgbp : ((mode == MO4) ? ASIgbp : ((mode == MO5) ? LRSgbp : ((mode == MO6) ? ZSgbp : ((mode == MO7) ? Mgbp : EMPTY_VALUE)))))));
      double AUD = ((mode == MO1) ? RSIaud : ((mode == MO2) ? TSIaud : ((mode == MO3) ? ROCaud : ((mode == MO4) ? ASIaud : ((mode == MO5) ? LRSaud : ((mode == MO6) ? ZSaud : ((mode == MO7) ? Maud : EMPTY_VALUE)))))));
      double NZD = ((mode == MO1) ? RSInzd : ((mode == MO2) ? TSInzd : ((mode == MO3) ? ROCnzd : ((mode == MO4) ? ASInzd : ((mode == MO5) ? LRSnzd : ((mode == MO6) ? ZSnzd : ((mode == MO7) ? Mnzd : EMPTY_VALUE)))))));
      double USD = ((mode == MO1) ? RSIusd : ((mode == MO2) ? TSIusd : ((mode == MO3) ? ROCusd : ((mode == MO4) ? ASIusd : ((mode == MO5) ? LRSusd : ((mode == MO6) ? ZSusd : ((mode == MO7) ? Musd : EMPTY_VALUE)))))));
      double CAD = ((mode == MO1) ? RSIcad : ((mode == MO2) ? TSIcad : ((mode == MO3) ? ROCcad : ((mode == MO4) ? ASIcad : ((mode == MO5) ? LRScad : ((mode == MO6) ? ZScad : ((mode == MO7) ? Mcad : EMPTY_VALUE)))))));
      double CHF = ((mode == MO1) ? RSIchf : ((mode == MO2) ? TSIchf : ((mode == MO3) ? ROCchf : ((mode == MO4) ? ASIchf : ((mode == MO5) ? LRSchf : ((mode == MO6) ? ZSchf : ((mode == MO7) ? Mchf : EMPTY_VALUE)))))));
      double JPY = ((mode == MO1) ? RSIjpy : ((mode == MO2) ? TSIjpy : ((mode == MO3) ? ROCjpy : ((mode == MO4) ? ASIjpy : ((mode == MO5) ? LRSjpy : ((mode == MO6) ? ZSjpy : ((mode == MO7) ? Mjpy : EMPTY_VALUE)))))));

      plot1[pos] = (ShowEUR ? EUR : EMPTY_VALUE);
      plot2[pos] = (ShowGBP ? GBP : EMPTY_VALUE);
      plot3[pos] = (ShowAUD ? AUD : EMPTY_VALUE);
      plot4[pos] = (ShowNZD ? NZD : EMPTY_VALUE);
      plot5[pos] = (ShowUSD ? USD : EMPTY_VALUE);
      plot6[pos] = (ShowCAD ? CAD : EMPTY_VALUE);
      plot7[pos] = (ShowCHF ? CHF : EMPTY_VALUE);
      plot8[pos] = (ShowJPY ? JPY : EMPTY_VALUE);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
