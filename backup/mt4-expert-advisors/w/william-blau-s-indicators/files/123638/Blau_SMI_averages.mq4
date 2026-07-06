// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60201

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
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
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=5;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

// Averages v. 1.0
enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   //ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   //ma_hull,    // Hull moving average
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   //ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo     // Smoother
};

extern MATypes SmoothingType = ma_ema; // Smoothing type

interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};
class AveragesStreamFactory
{
public:
   static IStream *Create(IStream *source, const int length, const MATypes type)
   {
      switch (type)
      {
         case ma_sma:
            return new SmaOnStream(source, length);
         case ma_ema:
            return new EmaOnStream(source, length);
         //case 2  : return(iDsema(price,length,r,instanceNo));
         // case 3  : return(iDema(price,length,r,instanceNo));
         // case 4  : return(iTema(price,length,r,instanceNo));
         // case 5  : return(iSmma(price,length,r,instanceNo));
         case ma_lwma:
            return new LwmaOnStream(source, length);
         // case 7  : return(iLwmp(price,length,r,instanceNo));
         // case 8  : return(iAlex(price,length,r,instanceNo));
         case ma_vwma:
            return new VwmaOnStream(source, length);
         // case 10 : return(iHull(price,length,r,instanceNo));
         // case 11 : return(iTma(price,length,r,instanceNo));
         // case 12 : return(iSineWMA(price,(int)length,r,instanceNo));
         // case 13 : return(iLinr(price,length,r,instanceNo));
         // case 14 : return(iIe2(price,length,r,instanceNo));
         // case 15 : return(iNonLagMa(price,length,r,instanceNo));
         // case 16 : return(iZeroLag(price,length,r,instanceNo));
         // case 17 : return(iLeader(price,length,r,instanceNo));
         // case 18 : return(iSsm(price,length,r,instanceNo));
         // case 19 : return(iSmooth(price,(int)length,r,instanceNo));
         // default : return(0);
      }
      return NULL;
   }
};

class ArrayStream : public IStream
{
public:
   double Buffer[];
   ArrayStream(const int streamId)
   {
      SetIndexBuffer(streamId, Buffer);
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= Bars)
         return false;
      val = Buffer[period];
      return true;
   }
};

class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
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
      if (period > totalBars - _length)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = 0; 
         for(int i = 0; i < _length; i++) 
         {
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

            _buffer[bufferIndex] += current;
         }
         _buffer[bufferIndex] /= _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};

class LwmaOnStream : public IStream
{
   IStream *_source;
   int _length;
public:
   LwmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      double sumw = _length;
      double sum = _length * price;
      for(int i = 1; i < _length; i++)
      {
         double weight = _length - i;
         sumw += weight;
         if (!_source.GetValue(period + i, price))
            return false;
         sum += weight * price;
      }
      val = sum / sumw;
      return true;
   }
};

class VwmaOnStream : public IStream
{
   IStream *_source;
   int _length;
public:
   VwmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = Volume[period];
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

class EmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   double _alpha;
public:
   EmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _length = length;
      _alpha = 2.0 / (1.0 + _length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - 1)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (price - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

ArrayStream *Half_HH;
ArrayStream *HH;
IStream *EMA1;
IStream *Half_EMA1;
IStream *EMA2;
IStream *Half_EMA2;
IStream *EMA3;
IStream *Half_EMA3;

double Blau_SMI[];

int init()
{
   IndicatorShortName("William Blau Stochastic Momentum Index");
   IndicatorDigits(Digits);
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Blau_SMI);
   HH = new ArrayStream(1);
   Half_HH = new ArrayStream(2);
   EMA1 = AveragesStreamFactory::Create(HH, Smooth_Length1, SmoothingType);
   Half_EMA1 = AveragesStreamFactory::Create(Half_HH, Smooth_Length1, SmoothingType);
   EMA2 = AveragesStreamFactory::Create(EMA1, Smooth_Length2, SmoothingType);
   Half_EMA2 = AveragesStreamFactory::Create(Half_EMA1, Smooth_Length2, SmoothingType);
   EMA3 = AveragesStreamFactory::Create(EMA2, Smooth_Length3, SmoothingType);
   Half_EMA3 = AveragesStreamFactory::Create(Half_EMA2, Smooth_Length3, SmoothingType);

   return(0);
}

int deinit()
{
   delete Half_HH;
   delete HH;
   delete EMA1;
   delete Half_EMA1;
   delete EMA2;
   delete Half_EMA2;
   delete EMA3;
   delete Half_EMA3;
   return(0);
}

int start()
{
   if(Bars<=Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   double Min, Max;
   int pos = limit;
   while(pos>=0)
   {
      Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
      Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
      HH.Buffer[pos] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - (Max + Min) / 2.;
      Half_HH.Buffer[pos] = (Max - Min) / 2.;
      pos--;
   } 
   
   pos=limit;
   while(pos>=0)
   {
      double val_Ea3;
      double val_Half_EMA3;
      if (EMA3.GetValue(pos, val_Ea3) && Half_EMA3.GetValue(pos, val_Half_EMA3))
         Blau_SMI[pos] = val_Half_EMA3 > 0 ? 100. * val_Ea3 / val_Half_EMA3 : 0;
      pos--;
   }  
   return(0);
}

