// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69049

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
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

double p[], s1[], s2[], s3[], r1[], r2[], r3[];

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
   IndicatorName = GenerateIndicatorName("Rolling Pivots Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(7);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, p);
   SetIndexLabel(0, "P");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, s1);
   SetIndexLabel(1, "S1");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, s2);
   SetIndexLabel(2, "S2");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, s3);
   SetIndexLabel(3, "S3");

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, r1);
   SetIndexLabel(4, "R1");

   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, r2);
   SetIndexLabel(5, "R2");

   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, r3);
   SetIndexLabel(6, "R3");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = iBarShift(_Symbol, _Period, Time[pos] - 86400);
      if (index < 0)
         continue;
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, index - pos, pos);
      double high = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, index - pos, pos);
      double low = iLow(_Symbol, _Period, lowestIndex);
      double open = Open[pos];
      double close = Close[pos];
      p[pos] = (high + low + close) / 3;
      r1[pos] = (2 * p[pos]) - low;
      s1[pos] = (2 * p[pos]) - high;
      r2[pos] = p[pos] + (high - low);
      s2[pos] = p[pos] - (high - low);
      r3[pos] = p[pos] + (high - low) * 2;
      s3[pos] = p[pos] - (high - low) * 2;
   } 
   return 0;
}