// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61609

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
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

extern int Slow_Length=50;
extern int Fast_Length=10;
extern int        Bollinger_Bands_Periods       = 20;
extern double     Bollinger_Bands_Deviations    = 2;

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   int _references;
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
   }

   ~SmaOnStream()
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
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};

class StDevStream : public IStream
{
   int _references;
   IStream* _source;
   int _period;
public:
   StDevStream(IStream* __source, int period)
   {
      _references = 1;
      _source = __source;
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

class BoilingerBandStream : public IStream
{
   double _dev;
   int _references;
   IStream* _sma;
   IStream* _stdev;
   bool _up;
public:
   BoilingerBandStream(IStream* __source, int length, double dev, bool up)
   {
      _references = 1;
      _sma = new SmaOnStream(__source, length);
      _stdev = new StDevStream(__source, length);
      _dev = dev;
      _up = up;
   }

   ~BoilingerBandStream()
   {
      _sma.Release();
      _stdev.Release();
   }

   virtual bool GetValue(const int period, double &val)
   {
      double basis;
      if (!_sma.GetValue(period, basis))
         return false;
      double stdev;
      if (!_stdev.GetValue(period, stdev))
         return false;

      val = _up ? basis + _dev * stdev : basis - _dev * stdev;
      return true;
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

CustomStream* VPCI;

double Vol[], CV[];
double bb_up[], bb_down[];
BoilingerBandStream* upBB;
BoilingerBandStream* dnBB;

int init()
{
   IndicatorShortName("Volume price confirmation indicator");
   IndicatorDigits(Digits);
   IndicatorBuffers(5);
   VPCI = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   VPCI.RegisterStream(0, Yellow, 1, STYLE_SOLID, "VPCI");
   upBB = new BoilingerBandStream(VPCI, Bollinger_Bands_Periods, Bollinger_Bands_Deviations, true);
   dnBB = new BoilingerBandStream(VPCI, Bollinger_Bands_Periods, Bollinger_Bands_Deviations, false);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, bb_up);
   SetIndexLabel(1, "BB Top");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, bb_down);
   SetIndexLabel(2, "BB Bottom");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, Vol);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, CV);

   return(0);
}

int deinit()
{
   VPCI.Release();
   upBB.Release();
   dnBB.Release();
   return(0);
}

int start()
{
   if (Bars <= 3) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return(-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      Vol[pos] = Volume[pos];
      CV[pos] = Close[pos] * Volume[pos];
      pos--;
   } 
   
   double Volume_Slow, Volume_Fast, VWMA_Slow, VWMA_Fast, SMA_Slow, SMA_Fast;
   double VPC, VPR, VM;
   pos = limit;
   while(pos >= 0)
   {
      Volume_Slow = iMAOnArray(Vol, 0, Slow_Length, 0, MODE_SMA, pos)*Slow_Length;
      Volume_Fast = iMAOnArray(Vol, 0, Fast_Length, 0, MODE_SMA, pos)*Fast_Length;
      if (Volume_Slow!=0.)
      {
         VWMA_Slow=iMAOnArray(CV, 0, Slow_Length, 0, MODE_SMA, pos)*Slow_Length/Volume_Slow;
      }
      else
      {
         VWMA_Slow=0.;
      } 
      if (Volume_Fast!=0.)
      {
         VWMA_Fast=iMAOnArray(CV, 0, Fast_Length, 0, MODE_SMA, pos)*Fast_Length/Volume_Fast;
      }
      else
      {
         VWMA_Fast=0.;
      } 
      SMA_Slow=iMA(NULL, 0, Slow_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      SMA_Fast=iMA(NULL, 0, Fast_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      
      VPC=VWMA_Slow-SMA_Slow;
      VPR=1.;
      if (SMA_Fast!=0.)
      {
         VPR=VWMA_Fast/SMA_Fast;
      }
      
      VM=1.;
      if (Volume_Slow!=0.)
      {
         VM=(Volume_Fast*Slow_Length)/(Volume_Slow*Fast_Length);
      }
      
      VPCI._stream[pos]=VPC*VPR*VM/(Point*Point);
      double value;
      if (upBB.GetValue(pos, value))
         bb_up[pos] = value;
      if (dnBB.GetValue(pos, value))
         bb_down[pos] = value;

      pos--;
   }
      
   return(0);
}

