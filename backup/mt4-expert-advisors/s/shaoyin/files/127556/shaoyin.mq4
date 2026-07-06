// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68713

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
#property indicator_buffers 5
//==================================
extern int p=6;
extern int s=3;
extern int cb=300;
input color up_color = LightSkyBlue; // Up color
input color down_color = Pink; // Down color
input color reintegration_color = Yellow; // Reintegration color
input color inversion_color = Red; // Inversion color
//==================================
double ki;
int fs;

double fx[], za[];

// Colored stream v1.1

class ColoredStreamData
{
public:
   double Stream[];
};

class ColoredStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   int RegisterInternal(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id + 0, DRAW_LINE, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 0, _streams[size].Stream);
      SetIndexLabel(id + 0, label);
      return id + 1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (_streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }
};

ColoredStream _streams;

//**********************************
int init()
{
   IndicatorBuffers(7);

   int id = 0;
   id = _streams.RegisterStream(id, up_color, "Up");
   id = _streams.RegisterStream(id, down_color, "Down");
   id = _streams.RegisterStream(id, reintegration_color, "Reintegration");
   id = _streams.RegisterStream(id, inversion_color, "Inversion");
   id = _streams.RegisterInternal(id);
   SetIndexBuffer(id + 0, fx);
   SetIndexBuffer(id + 1, za);
   
   ki=2.0/(p+1);
   
   return(0);
}
//***************************************************************************
int start()
{
   SetIndexDrawBegin(0, Bars - cb);
   SetIndexDrawBegin(1, Bars - cb);

   for (int i = cb; i >= 0; i--)
   {
      fx[i] = Close[i];
   }

   for (int m = 0; m <= s; m++)
   {
      double z1 = fx[0];
      for (int i = 0; i <= cb; i++)
      {
         z1 = z1 + (fx[i] - z1) * ki; 
         za[i] = z1;
      }

      double z2 = fx[cb];
      for (int i = cb; i >= 0; i--)
      {
         z2 = z2 + (fx[i] - z2) * ki;
         fx[i] = (za[i] + z2) / 2;
      }
   }

   for (int i = cb; i >= 0; i--)
   {
      if (fx[i] > fx[i + 1]) 
         _streams.Set(fx[i], i, Close[i] < High[i + 1] ? 2 : (Close[i] > Low[i + 1] ? 3 : 0));
      else
         _streams.Set(fx[i], i, Close[i] > Low[i + 1] ? 2 : (Close[i] < High[i + 1] ? 3 : 1));
   }

   return(0);
}
