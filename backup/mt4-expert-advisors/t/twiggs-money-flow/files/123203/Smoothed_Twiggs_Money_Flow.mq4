// Id:  
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61517

//+------------------------------------------------------------------+
//|                               Copyright � 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict
#property version   "1.1"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow;

extern int Length=21;
extern bool AddSmoothing = false; // Add smoothing
extern int SmoothingLength = 7; // Smoothing length
extern ENUM_MA_METHOD SmoothingType = MODE_EMA;//MA1 Type

double TMF_up[], TMF_down[], TMF[];
double ADV[], Vol[], WMA_ADV[], WMA_V[], Smoothing[];
double k;

int init()
{
   IndicatorShortName("Smoothed Twiggs Money Flow");
   IndicatorDigits(Digits);
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TMF_up);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TMF_down);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Smoothing);

   SetIndexBuffer(3,WMA_ADV);
   SetIndexBuffer(4,WMA_V);
   SetIndexBuffer(5,ADV);
   SetIndexBuffer(6,Vol);
   SetIndexBuffer(7, TMF);
   
   k=1./Length;

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos=limit;
   while(pos>=0)
   {
      double TRH=MathMax(High[pos], Close[pos+1]);
      double TRL=MathMin(Low[pos], Close[pos+1]);
      double TR=TRH-TRL;
      if (TR!=0.)
      {
         ADV[pos]=Volume[pos]*(2.*Close[pos]-TRL-TRH)/TR;
      }
      Vol[pos]=Volume[pos];

      pos--;
   } 
   
   pos=limit;
   while(pos>=0)
   {
      if (pos==Bars-2)
      {
         WMA_ADV[pos]=iMAOnArray(ADV, 0, Length, 0, MODE_SMA, pos);
         WMA_V[pos]=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
      }
      else
      {
         WMA_ADV[pos]=(ADV[pos]-WMA_ADV[pos+1])*k+WMA_ADV[pos+1];
         WMA_V[pos]=(Vol[pos]-WMA_V[pos+1])*k+WMA_V[pos+1];
      }
      
      if (WMA_V[pos]==0.)
      {
         TMF_up[pos] = EMPTY_VALUE;
         TMF_down[pos] = EMPTY_VALUE;
      }
      else
      {
         TMF[pos] = WMA_ADV[pos]/(WMA_V[pos]*Point);
         if (TMF[pos] >= 0)
         {
            TMF_up[pos] = TMF[pos];
            if (TMF_up[pos + 1] != EMPTY_VALUE)
               TMF_down[pos] = EMPTY_VALUE;
            else
               TMF_down[pos] = TMF_up[pos];
         }
         else
         {
            TMF_down[pos] = TMF[pos];
            if (TMF_down[pos + 1] != EMPTY_VALUE)
               TMF_up[pos] = EMPTY_VALUE;
            else
               TMF_up[pos] = TMF_down[pos];
         }
      }
      if (AddSmoothing && pos < Bars - 2 - SmoothingLength)
      {
         Smoothing[pos] = iMAOnArray(TMF, 0, SmoothingLength, 0, SmoothingType, pos);
      }
      
      pos--;
   }
      
   return(0);
}

