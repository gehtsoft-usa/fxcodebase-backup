// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67208

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
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "Oscillator"

extern double FreeFloat = 1000000; // Free float
extern int BarsCount = 100; // Aantal bars weergeven

double sAB[];

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

int init()
{
   IndicatorName = GenerateIndicatorName("Pascal Willain Active Boundaries");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, sAB);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = MathMin(BarsCount, limit);
   while (pos >= 0)
   {
      long tv = Volume[pos];
      int j = pos;
      double TROI = 0;
      while (j < Bars && tv < FreeFloat)
      {
         tv += Volume[j];
         double sAvgPrice = (Open[j] + Close[j] + Low[j] + High[j]) / 4;
         TROI += Volume[j] * (Close[pos] - sAvgPrice) / sAvgPrice;
         ++j;
      }
      if (tv != 0)
         sAB[pos] = 100 * TROI / tv;

      pos--;
   } 
   return 0;
}

