// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69107

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
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Red

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

input int FIR_N = 10; // FIR (LWMA) number of periods
input int S_N = 3; // Signal Line Smoothing Periods

double CG[], SIG[];

int init()
{
   IndicatorName = GenerateIndicatorName("John Ehlers' Center Of Gravity Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, CG);
   SetIndexLabel(0, "CG");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SIG);
   SetIndexLabel(1, "SIG");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1 - MathMax(FIR_N, S_N);
   for (int i = limit; i >= 0; i--)
   {
      double k = FIR_N;
      double s = 0;
      double w = 0;
      for (int ii = 0; ii < FIR_N; ++ii)
      {
         w = w + k * Close[i + ii];
         s = s + Close[i + ii];
         k = k - 1;
      }
      CG[i] = -w / s;
      SIG[i] = iMAOnArray(CG, 0, S_N, 0, MODE_SMA, i);
   }
   return 0;
}
