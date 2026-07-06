// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69099

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
#property indicator_color2 Red

input int period = 4; // Period

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

double top[], bottom[];

int init()
{
   IndicatorName = GenerateIndicatorName("Fractal Forex Trader");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, top);
   SetIndexLabel(0, "Top");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, bottom);
   SetIndexLabel(1, "Bottom");

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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 2;
   for (int pos = limit; pos >= 0; --pos)
   {
      int hh_index = iHighest(_Symbol, _Period, MODE_HIGH, period, pos);
      double hh = iHigh(_Symbol, _Period, hh_index);
      int hh_indexPrevious = iHighest(_Symbol, _Period, MODE_HIGH, period, pos + 1);
      double hhPrevious = iHigh(_Symbol, _Period, hh_indexPrevious);
      int ll_index = iLowest(_Symbol, _Period, MODE_LOW, period, pos);
      double ll = iLow(_Symbol, _Period, ll_index);
      int ll_indexPrevious = iLowest(_Symbol, _Period, MODE_LOW, period, pos + 1);
      double llPrevious = iLow(_Symbol, _Period, ll_indexPrevious);

      top[pos] = hh != hhPrevious ? High[pos] : top[pos + 1];
      bottom[pos] = ll != llPrevious ? Low[pos] : bottom[pos + 1];
   } 
   return 0;
}