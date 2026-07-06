
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69190

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

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

input int Period = 30; // Period

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

double LF[], LFI[];

int init()
{
   IndicatorName = GenerateIndicatorName("Linearregressionintercept");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, LF);
   SetIndexLabel(0, "LF`");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, LFI);
   SetIndexLabel(1, "LFI");

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
   int limit = Bars - counted_bars - 1 - Period;
   for (int pos = limit; pos >= 0; pos--)
   {
      double sumx = 0, sumx2 = 0, sumy = 0, sumxy = 0;

      for (int i = 1; i <= Period; i++)
      {
         sumx += i;
         sumx2 += i * i;
         sumy += Close[pos + Period - i];
         sumxy += Close[pos + Period - i] * i;
      }

      double m = (Period * sumxy - sumx * sumy) / (Period * sumx2 - sumx * sumx);
      double b = (sumy - m * sumx) / Period;
      LF[pos] = Period * m + b;
      LFI[pos] = b;
   }
   return 0;
}