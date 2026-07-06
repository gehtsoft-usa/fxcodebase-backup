 

// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68578

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
#property indicator_buffers 1
#property indicator_color1 Red

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

double mp[], u[], d[];

int init()
{
   IndicatorName = GenerateIndicatorName("Momentum Pinball");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, mp);
   SetIndexLabel(0, "Momentum Pinball");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, u);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, d);

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
      int index = iBarShift(_Symbol, PERIOD_D1, Time[pos]);
      if (index < 0)
         continue;
      double diff = iClose(_Symbol, PERIOD_D1, index) - iClose(_Symbol, PERIOD_D1, index + 1);
      double diff1 = iClose(_Symbol, PERIOD_D1, index + 1) - iClose(_Symbol, PERIOD_D1, index + 2);
      if (diff - diff1 >= 0)
      {
         u[pos] = diff - diff1;
         d[pos] = 0;
      }
      else
      {
         u[pos] = 0;
         d[pos] = diff1 - diff;
      }
      double upAvg = iMAOnArray(u, 0, 14, 0, MODE_EMA, pos);
      double downAvg = iMAOnArray(d, 0, 14, 0, MODE_EMA, pos);
      double rate = downAvg == 0 ? 0 : upAvg / downAvg;

      mp[pos] = 100 - (100 / (1 + rate));
   } 
   return 0;
}