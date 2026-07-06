// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72126

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
#property indicator_chart_window
#property indicator_buffers 34
#property indicator_label1 "TMA"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_type5 DRAW_LINE
#property indicator_color5 Green
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_type6 DRAW_LINE
#property indicator_color6 Green
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_type7 DRAW_LINE
#property indicator_color7 Green
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_type8 DRAW_LINE
#property indicator_color8 Green
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_type9 DRAW_LINE
#property indicator_color9 Green
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_type10 DRAW_LINE
#property indicator_color10 Green
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_type11 DRAW_LINE
#property indicator_color11 Green
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_type12 DRAW_LINE
#property indicator_color12 Green
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_type13 DRAW_LINE
#property indicator_color13 Green
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_type14 DRAW_LINE
#property indicator_color14 Green
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_type15 DRAW_LINE
#property indicator_color15 Green
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_type16 DRAW_LINE
#property indicator_color16 Green
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_type17 DRAW_LINE
#property indicator_color17 Green
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_type18 DRAW_LINE
#property indicator_color18 Green
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1
#property indicator_label19 "TMA"
#property indicator_type19 DRAW_LINE
#property indicator_color19 Red
#property indicator_style19 STYLE_SOLID
#property indicator_width19 1
#property indicator_type20 DRAW_LINE
#property indicator_color20 Red
#property indicator_style20 STYLE_SOLID
#property indicator_width20 1
#property indicator_type21 DRAW_LINE
#property indicator_color21 Red
#property indicator_style21 STYLE_SOLID
#property indicator_width21 1
#property indicator_type22 DRAW_LINE
#property indicator_color22 Red
#property indicator_style22 STYLE_SOLID
#property indicator_width22 1
#property indicator_type23 DRAW_LINE
#property indicator_color23 Red
#property indicator_style23 STYLE_SOLID
#property indicator_width23 1
#property indicator_type24 DRAW_LINE
#property indicator_color24 Red
#property indicator_style24 STYLE_SOLID
#property indicator_width24 1
#property indicator_type25 DRAW_LINE
#property indicator_color25 Red
#property indicator_style25 STYLE_SOLID
#property indicator_width25 1
#property indicator_type26 DRAW_LINE
#property indicator_color26 Red
#property indicator_style26 STYLE_SOLID
#property indicator_width26 1
#property indicator_type27 DRAW_LINE
#property indicator_color27 Red
#property indicator_style27 STYLE_SOLID
#property indicator_width27 1
#property indicator_type28 DRAW_LINE
#property indicator_color28 Red
#property indicator_style28 STYLE_SOLID
#property indicator_width28 1
#property indicator_type29 DRAW_LINE
#property indicator_color29 Red
#property indicator_style29 STYLE_SOLID
#property indicator_width29 1
#property indicator_type30 DRAW_LINE
#property indicator_color30 Red
#property indicator_style30 STYLE_SOLID
#property indicator_width30 1
#property indicator_type31 DRAW_LINE
#property indicator_color31 Red
#property indicator_style31 STYLE_SOLID
#property indicator_width31 1
#property indicator_type32 DRAW_LINE
#property indicator_color32 Red
#property indicator_style32 STYLE_SOLID
#property indicator_width32 1
#property indicator_type33 DRAW_LINE
#property indicator_color33 Red
#property indicator_style33 STYLE_SOLID
#property indicator_width33 1
#property indicator_type34 DRAW_LINE
#property indicator_color34 Red
#property indicator_style34 STYLE_SOLID
#property indicator_width34 1

input int length = 30; // Length1
input int length2 = 30; // Length1
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[], plot7[], plot8[], plot9[], plot10[], plot11[], plot12[], plot13[], plot14[], plot15[], plot16[], plot17[], plot18[], plot19[], plot20[], plot21[], plot22[], plot23[], plot24[], plot25[], plot26[], plot27[], plot28[], plot29[], plot30[], plot31[], plot32[], plot33[], plot34[];
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

// Simple price stream v1.0

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
class funcStream
{
   int i;
   CustomStream* close;
   SimplePriceStream* sma4Source;
   IStream* sma4;
   IStream* sma3;
public:
   funcStream(int i)
   {
      sma4Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
      sma4 = new SmaOnStream(sma4Source, MathCeil((length - i) / 2));
      sma3 = new SmaOnStream(sma4, MathFloor((length - i) / 2) + 1);
      this.i = i;
      close = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~funcStream()
   {
      close.Release();
      sma4Source.Release();
      sma4.Release();
      sma3.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double sma3Value;
      if (!sma3.GetValue(period, sma3Value))
      {
         return false;
      }
      double x = sma3Value;
      double out = (x * (length - i) + iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period) * i) / length;
      __out1 = out;
      return true;
   }
};
class func2Stream
{
   int i2;
   CustomStream* close;
   SimplePriceStream* sma8Source;
   IStream* sma8;
   IStream* sma7;
public:
   func2Stream(int i2)
   {
      sma8Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
      sma8 = new SmaOnStream(sma8Source, MathCeil((length2 - i2) / 2));
      sma7 = new SmaOnStream(sma8, MathFloor((length2 - i2) / 2) + 1);
      this.i2 = i2;
      close = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~func2Stream()
   {
      close.Release();
      sma8Source.Release();
      sma8.Release();
      sma7.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double sma7Value;
      if (!sma7.GetValue(period, sma7Value))
      {
         return false;
      }
      double x2 = sma7Value;
      double out2 = (x2 * (length2 - i2) + iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period) * i2) / length2;
      __out1 = out2;
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

SimplePriceStream* sma2Source;
IStream* sma2;
IStream* sma1;
int ld;
int trs;
funcStream* funcFunc1;
funcStream* funcFunc2;
funcStream* funcFunc3;
funcStream* funcFunc4;
funcStream* funcFunc5;
funcStream* funcFunc6;
funcStream* funcFunc7;
funcStream* funcFunc8;
funcStream* funcFunc9;
funcStream* funcFunc10;
funcStream* funcFunc11;
funcStream* funcFunc12;
funcStream* funcFunc13;
funcStream* funcFunc14;
funcStream* funcFunc15;
funcStream* funcFunc16;
funcStream* funcFunc17;
SimplePriceStream* sma6Source;
IStream* sma6;
IStream* sma5;
func2Stream* func2Func18;
func2Stream* func2Func19;
func2Stream* func2Func20;
func2Stream* func2Func21;
func2Stream* func2Func22;
func2Stream* func2Func23;
func2Stream* func2Func24;
func2Stream* func2Func25;
func2Stream* func2Func26;
func2Stream* func2Func27;
func2Stream* func2Func28;
func2Stream* func2Func29;
func2Stream* func2Func30;
func2Stream* func2Func31;
func2Stream* func2Func32;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("TMA crossover(Lirshah)");
   IndicatorShortName(" TMA crossover");
   IndicatorBuffers(34);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, plot9);
   SetIndexBuffer(id++, plot10);
   SetIndexBuffer(id++, plot11);
   SetIndexBuffer(id++, plot12);
   SetIndexBuffer(id++, plot13);
   SetIndexBuffer(id++, plot14);
   SetIndexBuffer(id++, plot15);
   SetIndexBuffer(id++, plot16);
   SetIndexBuffer(id++, plot17);
   SetIndexBuffer(id++, plot18);
   SetIndexBuffer(id++, plot19);
   SetIndexBuffer(id++, plot20);
   SetIndexBuffer(id++, plot21);
   SetIndexBuffer(id++, plot22);
   SetIndexBuffer(id++, plot23);
   SetIndexBuffer(id++, plot24);
   SetIndexBuffer(id++, plot25);
   SetIndexBuffer(id++, plot26);
   SetIndexBuffer(id++, plot27);
   SetIndexBuffer(id++, plot28);
   SetIndexBuffer(id++, plot29);
   SetIndexBuffer(id++, plot30);
   SetIndexBuffer(id++, plot31);
   SetIndexBuffer(id++, plot32);
   SetIndexBuffer(id++, plot33);
   SetIndexBuffer(id++, plot34);
   sma2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   sma2 = new SmaOnStream(sma2Source, MathCeil(length / 2));
   sma1 = new SmaOnStream(sma2, MathFloor(length / 2) + 1);
   ld = 2;
   trs = 0;
   funcFunc1 = new funcStream(1);
   funcFunc2 = new funcStream(2);
   funcFunc3 = new funcStream(3);
   funcFunc4 = new funcStream(4);
   funcFunc5 = new funcStream(5);
   funcFunc6 = new funcStream(6);
   funcFunc7 = new funcStream(7);
   funcFunc8 = new funcStream(8);
   funcFunc9 = new funcStream(9);
   funcFunc10 = new funcStream(10);
   funcFunc11 = new funcStream(11);
   funcFunc12 = new funcStream(12);
   funcFunc13 = new funcStream(13);
   funcFunc14 = new funcStream(14);
   funcFunc15 = new funcStream(15);
   funcFunc16 = new funcStream(16);
   funcFunc17 = new funcStream(17);
   sma6Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   sma6 = new SmaOnStream(sma6Source, MathCeil(length2 / 2));
   sma5 = new SmaOnStream(sma6, MathFloor(length2 / 2) + 1);
   func2Func18 = new func2Stream(1);
   func2Func19 = new func2Stream(2);
   func2Func20 = new func2Stream(3);
   func2Func21 = new func2Stream(4);
   func2Func22 = new func2Stream(5);
   func2Func23 = new func2Stream(6);
   func2Func24 = new func2Stream(7);
   func2Func25 = new func2Stream(8);
   func2Func26 = new func2Stream(9);
   func2Func27 = new func2Stream(10);
   func2Func28 = new func2Stream(11);
   func2Func29 = new func2Stream(12);
   func2Func30 = new func2Stream(13);
   func2Func31 = new func2Stream(14);
   func2Func32 = new func2Stream(15);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   sma2Source.Release();
   sma2.Release();
   sma1.Release();
   delete funcFunc1;
   delete funcFunc2;
   delete funcFunc3;
   delete funcFunc4;
   delete funcFunc5;
   delete funcFunc6;
   delete funcFunc7;
   delete funcFunc8;
   delete funcFunc9;
   delete funcFunc10;
   delete funcFunc11;
   delete funcFunc12;
   delete funcFunc13;
   delete funcFunc14;
   delete funcFunc15;
   delete funcFunc16;
   delete funcFunc17;
   sma6Source.Release();
   sma6.Release();
   sma5.Release();
   delete func2Func18;
   delete func2Func19;
   delete func2Func20;
   delete func2Func21;
   delete func2Func22;
   delete func2Func23;
   delete func2Func24;
   delete func2Func25;
   delete func2Func26;
   delete func2Func27;
   delete func2Func28;
   delete func2Func29;
   delete func2Func30;
   delete func2Func31;
   delete func2Func32;
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
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ArrayInitialize(plot14, EMPTY_VALUE);
      ArrayInitialize(plot15, EMPTY_VALUE);
      ArrayInitialize(plot16, EMPTY_VALUE);
      ArrayInitialize(plot17, EMPTY_VALUE);
      ArrayInitialize(plot18, EMPTY_VALUE);
      ArrayInitialize(plot19, EMPTY_VALUE);
      ArrayInitialize(plot20, EMPTY_VALUE);
      ArrayInitialize(plot21, EMPTY_VALUE);
      ArrayInitialize(plot22, EMPTY_VALUE);
      ArrayInitialize(plot23, EMPTY_VALUE);
      ArrayInitialize(plot24, EMPTY_VALUE);
      ArrayInitialize(plot25, EMPTY_VALUE);
      ArrayInitialize(plot26, EMPTY_VALUE);
      ArrayInitialize(plot27, EMPTY_VALUE);
      ArrayInitialize(plot28, EMPTY_VALUE);
      ArrayInitialize(plot29, EMPTY_VALUE);
      ArrayInitialize(plot30, EMPTY_VALUE);
      ArrayInitialize(plot31, EMPTY_VALUE);
      ArrayInitialize(plot32, EMPTY_VALUE);
      ArrayInitialize(plot33, EMPTY_VALUE);
      ArrayInitialize(plot34, EMPTY_VALUE);
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
      int shift = (-15);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value))
      {
         continue;
      }
      double tma = sma1Value;
      color cl = Green;
      plot1[pos + shift] = tma;
      double funcFunc1Value;
      if (!funcFunc1.GetValue(pos, funcFunc1Value))
      {
         continue;
      }
      plot2[pos + 1] = funcFunc1Value;
      double funcFunc2Value;
      if (!funcFunc2.GetValue(pos, funcFunc2Value))
      {
         continue;
      }
      plot3[pos + 2] = funcFunc2Value;
      double funcFunc3Value;
      if (!funcFunc3.GetValue(pos, funcFunc3Value))
      {
         continue;
      }
      plot4[pos + 3] = funcFunc3Value;
      double funcFunc4Value;
      if (!funcFunc4.GetValue(pos, funcFunc4Value))
      {
         continue;
      }
      plot5[pos + 4] = funcFunc4Value;
      double funcFunc5Value;
      if (!funcFunc5.GetValue(pos, funcFunc5Value))
      {
         continue;
      }
      plot6[pos + 5] = funcFunc5Value;
      double funcFunc6Value;
      if (!funcFunc6.GetValue(pos, funcFunc6Value))
      {
         continue;
      }
      plot7[pos + 6] = funcFunc6Value;
      double funcFunc7Value;
      if (!funcFunc7.GetValue(pos, funcFunc7Value))
      {
         continue;
      }
      plot8[pos + 7] = funcFunc7Value;
      double funcFunc8Value;
      if (!funcFunc8.GetValue(pos, funcFunc8Value))
      {
         continue;
      }
      plot9[pos + 8] = funcFunc8Value;
      double funcFunc9Value;
      if (!funcFunc9.GetValue(pos, funcFunc9Value))
      {
         continue;
      }
      plot10[pos + 9] = funcFunc9Value;
      double funcFunc10Value;
      if (!funcFunc10.GetValue(pos, funcFunc10Value))
      {
         continue;
      }
      plot11[pos + 10] = funcFunc10Value;
      double funcFunc11Value;
      if (!funcFunc11.GetValue(pos, funcFunc11Value))
      {
         continue;
      }
      plot12[pos + 11] = funcFunc11Value;
      double funcFunc12Value;
      if (!funcFunc12.GetValue(pos, funcFunc12Value))
      {
         continue;
      }
      plot13[pos + 12] = funcFunc12Value;
      double funcFunc13Value;
      if (!funcFunc13.GetValue(pos, funcFunc13Value))
      {
         continue;
      }
      plot14[pos + 13] = funcFunc13Value;
      double funcFunc14Value;
      if (!funcFunc14.GetValue(pos, funcFunc14Value))
      {
         continue;
      }
      plot15[pos + 14] = funcFunc14Value;
      double funcFunc15Value;
      if (!funcFunc15.GetValue(pos, funcFunc15Value))
      {
         continue;
      }
      plot16[pos + 15] = funcFunc15Value;
      double funcFunc16Value;
      if (!funcFunc16.GetValue(pos, funcFunc16Value))
      {
         continue;
      }
      plot17[pos + 16] = funcFunc16Value;
      double funcFunc17Value;
      if (!funcFunc17.GetValue(pos, funcFunc17Value))
      {
         continue;
      }
      plot18[pos + 17] = funcFunc17Value;
      int shift2 = (-10);
      double sma5Value;
      if (!sma5.GetValue(pos, sma5Value))
      {
         continue;
      }
      double tma2 = sma5Value;
      color cl2 = Red;
      plot19[pos + shift2] = tma2;
      double func2Func18Value;
      if (!func2Func18.GetValue(pos, func2Func18Value))
      {
         continue;
      }
      plot20[pos + 1] = func2Func18Value;
      double func2Func19Value;
      if (!func2Func19.GetValue(pos, func2Func19Value))
      {
         continue;
      }
      plot21[pos + 2] = func2Func19Value;
      double func2Func20Value;
      if (!func2Func20.GetValue(pos, func2Func20Value))
      {
         continue;
      }
      plot22[pos + 3] = func2Func20Value;
      double func2Func21Value;
      if (!func2Func21.GetValue(pos, func2Func21Value))
      {
         continue;
      }
      plot23[pos + 4] = func2Func21Value;
      double func2Func22Value;
      if (!func2Func22.GetValue(pos, func2Func22Value))
      {
         continue;
      }
      plot24[pos + 5] = func2Func22Value;
      double func2Func23Value;
      if (!func2Func23.GetValue(pos, func2Func23Value))
      {
         continue;
      }
      plot25[pos + 6] = func2Func23Value;
      double func2Func24Value;
      if (!func2Func24.GetValue(pos, func2Func24Value))
      {
         continue;
      }
      plot26[pos + 7] = func2Func24Value;
      double func2Func25Value;
      if (!func2Func25.GetValue(pos, func2Func25Value))
      {
         continue;
      }
      plot27[pos + 8] = func2Func25Value;
      double func2Func26Value;
      if (!func2Func26.GetValue(pos, func2Func26Value))
      {
         continue;
      }
      plot28[pos + 9] = func2Func26Value;
      double func2Func27Value;
      if (!func2Func27.GetValue(pos, func2Func27Value))
      {
         continue;
      }
      plot29[pos + 10] = func2Func27Value;
      double func2Func28Value;
      if (!func2Func28.GetValue(pos, func2Func28Value))
      {
         continue;
      }
      plot30[pos + 11] = func2Func28Value;
      double func2Func29Value;
      if (!func2Func29.GetValue(pos, func2Func29Value))
      {
         continue;
      }
      plot31[pos + 12] = func2Func29Value;
      double func2Func30Value;
      if (!func2Func30.GetValue(pos, func2Func30Value))
      {
         continue;
      }
      plot32[pos + 13] = func2Func30Value;
      double func2Func31Value;
      if (!func2Func31.GetValue(pos, func2Func31Value))
      {
         continue;
      }
      plot33[pos + 14] = func2Func31Value;
      double func2Func32Value;
      if (!func2Func32.GetValue(pos, func2Func32Value))
      {
         continue;
      }
      plot34[pos + 15] = func2Func32Value;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
