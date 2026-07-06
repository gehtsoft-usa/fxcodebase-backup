// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69079

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
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red

input int period = 21; // Period

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
   IndicatorName = GenerateIndicatorName("Advanced Price Action Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ttperc);
   SetIndexLabel(0, "APAI");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ppperc);
   SetIndexLabel(1, "P APAI");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, ptperc);
   SetIndexLabel(2, "APAI Main");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, rsup);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, rres);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, tot);

   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, res);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, sup);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double rsup[], rres[], tot[], res[], sup[], ttperc[], ppperc[], ptperc[];

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 3;
   for (int pos = limit; pos >= 1; --pos)
   {
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, 2, pos);
      double lowest = iLow(_Symbol, _Period, lowestIndex);
      if (Low[pos + 1] < Low[pos + 2] && Low[pos + 1] == lowest)
         sup[pos] = sup[pos] + 1;

      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, 2, pos);
      double highest = iHigh(_Symbol, _Period, highestIndex);
      if (High[pos + 1] > High[pos + 2] && High[pos + 1] == highest)
         res[pos] = res[pos] + 1;

      if (Bars - 1 < pos + period - 1)
         continue;

      rsup[pos] = (sup[pos] - sup[pos + period - 1]) * 2;
      rres[pos] = (res[pos] - res[pos + period - 1]) * 2;
      tot[pos] = (rsup[pos] + rres[pos]) / 2;
      double ata = ((res[pos] + sup[pos]) / (Bars - pos)) * period;

      double tt = iMAOnArray(rsup, 0, period, 0, MODE_LWMA, pos);
      double pp = iMAOnArray(rres, 0, period, 0, MODE_LWMA, pos);
      double pt = iMAOnArray(tot, 0, period, 0, MODE_LWMA, pos);

      ttperc[pos] = ((tt / ata) * 100);
      ppperc[pos] = ((pp / ata) * 100);
      ptperc[pos] = ((pt / ata) * 100);
   } 
   return 0;
}