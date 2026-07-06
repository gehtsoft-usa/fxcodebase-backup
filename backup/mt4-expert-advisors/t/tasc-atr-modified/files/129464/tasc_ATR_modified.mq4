// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69066

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
#property indicator_color2 Green

input int period = 5; // ATR period
input double atrfact = 3.5; // ATR multiplication

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
   IndicatorName = GenerateIndicatorName("TASC Modified Average True Range");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, atrmod);
   SetIndexLabel(0, "ATR Mod");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, plot2);
   SetIndexLabel(1, "ATR");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, MidPrice);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, diff2);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double MidPrice[], diff2[], atrmod[], plot2[];

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
      MidPrice[pos] = High[pos] - Low[pos];
      if (pos + period + 1 >= Bars)
         continue;
      double maValue = iMAOnArray(MidPrice, 0, period, 0, MODE_SMA, pos);
      double HiLo = 1.5 * maValue;
      double Href = Low[pos] <= High[pos + 1] ? High[pos] - Close[pos + 1] : ((High[pos] - Close[pos + 1]) - (Low[pos + 1] - High[pos])) / 2;
      double Lref = High[pos] >= Low[pos + 1] ? Close[pos + 1] - Low[pos] : ((Close[pos + 1] - Low[pos]) - (Low[pos + 1] - High[pos])) / 2;
      double diff1 = MathMax(HiLo, Href);
      diff2[pos] = MathMax(diff1, Lref);
      if (diff2[pos + period] == EMPTY_VALUE)
         continue;
      double maValue2 = iMAOnArray(diff2, 0, period, 0, MODE_EMA, pos);
      atrmod[pos] = diff2[pos] / period + ((period - 1) / period) * maValue2;
      double loss = atrfact * atrmod[pos];
      if (plot2[pos + 1] != EMPTY_VALUE && Close[pos] > plot2[pos + 1] && Close[pos + 1] > plot2[pos + 1])
         plot2[pos] = MathMax(plot2[pos + 1], Close[pos] - loss);
      else if (plot2[pos + 1] != EMPTY_VALUE && Close[pos] < plot2[pos + 1] && Close[pos + 1] < plot2[pos + 1])
         plot2[pos] = MathMin(plot2[pos + 1], Close[pos] + loss);
      else if (Close[pos] > plot2[pos + 1])
         plot2[pos] = Close[pos] - loss;
      else
         plot2[pos] = Close[pos] + loss;
   } 
   return 0;
}