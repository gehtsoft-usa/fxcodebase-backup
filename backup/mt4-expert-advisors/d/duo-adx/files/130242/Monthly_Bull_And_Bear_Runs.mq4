// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69231

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
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Pink
#property indicator_color5 Pink

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

double diff[], flag[], maxup[], maxdown[], upave[], downave[];

int init()
{
   IndicatorName = GenerateIndicatorName("Monthly Bull And Bear Runs");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(6);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, flag);
   SetIndexLabel(0, "Month Up or Down");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, maxup);
   SetIndexLabel(1, "Longest ever up run");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, maxdown);
   SetIndexLabel(2, "Longest ever down run");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, upave);
   SetIndexLabel(3, "Avg months up before a down");

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, downave);
   SetIndexLabel(4, "Avg months down before an up");

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, diff);

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
   int limit = Bars - counted_bars - 2;
   double up, down, upcount, downcount;
   for (int i = limit; i >= 0; i--)
   {
      int index = iBarShift(_Symbol, PERIOD_MN1, Time[i]);
      if (index < 0)
      {
         continue;
      }
      double myopen = iOpen(_Symbol, PERIOD_MN1, index);
      double myclose = Close[i + 1];
      diff[i] = myclose - iOpen(_Symbol, PERIOD_MN1, index + 1);
      if (i == Bars - 2)
      {
         continue;
      }
      if (diff[i] > 0 && diff[i + 1] < 0)
      {
         flag[i] = 1;
      }
      else if (diff[i] < 0 && diff[i + 1] > 0)
      {
         flag[i] = -1;
      }
      else if (diff[i] > 0 && diff[i + 1] > 0)
      {
         if (flag[i + 1] != EMPTY_VALUE)
         {
            flag[i] = flag[i + 1] + 1;
         }
         else
         {
            flag[i] = 1;
         }
      }
      else if (diff[i] < 0 && diff[i + 1] < 0)
      {
         if (flag[i + 1] != EMPTY_VALUE)
         {
            flag[i] = flag[i + 1] - 1;
         }
         else
         {
            flag[i] = -1;
         }
      }
      else
      {
         flag[i] = flag[i + 1];
      }
      if (flag[i] == EMPTY_VALUE)
      {
         continue;
      }
      if (maxdown[i + 1] == EMPTY_VALUE)
      {
         maxdown[i] = flag[i];
         maxup[i] = flag[i];
      }
      else
      {
         maxdown[i] = MathMin(flag[i], maxdown[i + 1]);
         maxup[i] = MathMax(flag[i], maxup[i + 1]);
      }
      if (flag[i] < 0 && flag[i + 1] > 0)
      {
         up +=  flag[i + 1];
         upcount += 1;
      }
      
      if (flag[i] > 0 && flag[i + 1] < 0)
      {
         down += flag[i + 1];
         downcount += 1;
      }
      upave[i] = upcount == 0 ? 0 : up / upcount;
      downave[i] = downcount == 0 ? 0 : down / downcount;
   }
   return 0;
}