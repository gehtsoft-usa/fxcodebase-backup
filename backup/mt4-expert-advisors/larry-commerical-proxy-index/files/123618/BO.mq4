 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59355

//+------------------------------------------------------------------+
//|                               Copyright � 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright � 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

// Averages v. 1.0
enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   //ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   //ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   //ma_vwma,    // Volume weighted moving average - VWMA
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
extern int Length=8;
extern MATypes SmoothingType1 = ma_sma; // Smoothing type 1
extern MATypes SmoothingType2 = ma_sma; // Smoothing type 2

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
         //case 1  : return(iEma(price,length,r,instanceNo));
         //case 2  : return(iDsema(price,length,r,instanceNo));
         // case 3  : return(iDema(price,length,r,instanceNo));
         // case 4  : return(iTema(price,length,r,instanceNo));
         // case 5  : return(iSmma(price,length,r,instanceNo));
         case ma_lwma:
            return new LwmaOnStream(source, length);
         // case 7  : return(iLwmp(price,length,r,instanceNo));
         // case 8  : return(iAlex(price,length,r,instanceNo));
         // case 9  : return(iWwma(price,length,r,instanceNo));
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

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT

double BO[];
ArrayStream *smoothingSource1;
ArrayStream *smoothingSource2;
IStream *smoothing1;
IStream *smoothing2;

int init()
{
   IndicatorShortName("Blast Off");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BO);
   smoothingSource1 = new ArrayStream(1);
   SetIndexStyle(1,DRAW_NONE);
   smoothingSource2 = new ArrayStream(2);
   SetIndexStyle(2,DRAW_NONE);
   smoothing1 = AveragesStreamFactory::Create(smoothingSource1, Length, SmoothingType1);
   smoothing2 = AveragesStreamFactory::Create(smoothingSource2, Length, SmoothingType2);

   return(0);
}

int deinit()
{
   delete smoothingSource1;
   delete smoothing1;
   delete smoothingSource2;
   delete smoothing2;
   return(0);
}

int start()
{
   if(Bars<=Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos;
   pos=limit;
   while(pos>=0)
   {
      smoothingSource1.Buffer[pos]=Close[pos]-Open[pos];
      smoothingSource2.Buffer[pos]=High[pos]-Low[pos];
      pos--;
   } 
   
   double MA1, MA2;
   pos=limit;
   while(pos>=0)
   {
      if (smoothing1.GetValue(pos, MA1) && smoothing2.GetValue(pos, MA2))
      {
         BO[pos] = MA2!=0 ? 100*MA1/MA2 : 0;
      }
      pos--;
   }  
   return(0);
}

