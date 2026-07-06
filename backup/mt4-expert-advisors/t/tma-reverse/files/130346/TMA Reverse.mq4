// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69246

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

input int HalfLength = 141; // Half length
input int AtrLength = 141; // ATR length
input double AtrMultiplier = 2.4; // ATR multiplier

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red

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

double middleband[], lowerband[], upperband[];

int init()
{
   IndicatorName = GenerateIndicatorName("TMA Reverse");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, middleband);
   SetIndexLabel(0, "middleband");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, lowerband);
   SetIndexLabel(1, "lowerband");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, upperband);
   SetIndexLabel(2, "upperband");

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
   int limit = MathMax(0, Bars - counted_bars - 1 - HalfLength);
   for (int i = limit; i >= 0; i--)
   {
      double sum = (HalfLength + 1) * Close[i];
      double sumw = (HalfLength + 1);
      int k = HalfLength;
      for (int j = 1; j <= HalfLength; ++j)
      {
         k = k - 1;
         sum = sum + (k * Close[i + j]);
         sumw = sumw + k;
      }
      double myrange = iATR(_Symbol, _Period, AtrLength, i) * AtrMultiplier;
      middleband[i] = sum / sumw;
      lowerband[i] = middleband[i] - myrange;
      upperband[i] = middleband[i] + myrange;
   }
   return 0;
}

