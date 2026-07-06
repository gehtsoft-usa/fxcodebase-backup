// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66621

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int Period = 14; // Period
extern int Smooth = 5; // Smooth
extern double K = 4.236; // K

double TS[];
double UP[];
double DN[];
double alpha;
double delta1[];
double delta2[];
double upband[];
double loband[];
double trend[];

int init()
{
   IndicatorShortName("Trend Strength 2 oscillator");
   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexLabel(0, "Trend Strength");
   SetIndexBuffer(0, TS);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, "Up Trend");
   SetIndexBuffer(1, UP);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexLabel(2, "Down Trend");
   SetIndexBuffer(2, DN);
   alpha = 1.0 / Period;
   SetIndexBuffer(3, delta1);
   SetIndexBuffer(4, delta2);
   SetIndexBuffer(5, upband);
   SetIndexBuffer(6, loband);
   SetIndexBuffer(7, trend);

   return(0);
}
int deinit()
{
   return(0);
}

int start()
{
   if (Bars <= 1)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      bool firstValue = TS[pos + 1] == EMPTY_VALUE;
      if (firstValue)
      {
         TS[pos] = 2 / (Smooth + 1) * (iRSI(NULL, 0, Period, PRICE_CLOSE, pos));
         delta1[pos] = 0;
         delta2[pos] = 0;
         upband[pos] = TS[pos];
         loband[pos] = TS[pos];
         trend[pos] = 0;
      }
      else
      {
         double rsi = iRSI(NULL, 0, Period, PRICE_CLOSE, pos);
         TS[pos] = TS[pos + 1] + 2.0 / (Smooth + 1) * (rsi - TS[pos + 1]);
         double hiRSI = MathMax(TS[pos], TS[pos + 1]);
         double loRSI = MathMin(TS[pos], TS[pos + 1]);
         double rangeRSI = hiRSI - loRSI;
         delta1[pos] = delta1[pos + 1] + alpha * (rangeRSI - delta1[pos + 1]);
         delta2[pos] = delta2[pos + 1] + alpha * (delta1[pos] - delta2[pos + 1]);
         upband[pos] = TS[pos] + K * delta2[pos];
         loband[pos] = TS[pos] - K * delta2[pos];
         trend[pos] = trend[pos + 1];
         if (TS[pos] > upband[pos + 1])
            trend[pos] = 1;
         else if (TS[pos] < loband[pos + 1])
            trend[pos] = -1;
         
         if (trend[pos] == 1)
         {
            if (loband[pos] < loband[pos + 1])
               loband[pos] = loband[pos + 1];
            
            UP[pos] = loband[pos];
            DN[pos] = EMPTY_VALUE;
         }
         else
         {
            if (upband[pos] > upband[pos + 1])
               upband[pos] = upband[pos + 1];
            DN[pos] = upband[pos];
            UP[pos] = EMPTY_VALUE;
         }
      }
      
      pos--;
   }
   
   return Bars;
}
 
