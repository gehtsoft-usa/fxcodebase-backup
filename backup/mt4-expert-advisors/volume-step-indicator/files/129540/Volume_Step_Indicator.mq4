// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69083

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
#property indicator_color2 Green

input int p = 10; // Period

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

double VolStep[], avg[];

int init()
{
   IndicatorName = GenerateIndicatorName("Volume Step Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VolStep);
   SetIndexLabel(0, "VolStep");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, avg);
   SetIndexLabel(1, "Avg");

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
      if (VolStep[pos + 1] != EMPTY_VALUE)
      {
         double sRange = (High[pos] - Low[pos]);
         if (High[pos] < High[pos + 1] && Low[pos] < Low[pos + 1])
            VolStep[pos] = VolStep[pos + 1] - sRange * Volume[pos];
         else if (High[pos] > High[pos + 1] && Low[pos] > Low[pos + 1] && VolStep[pos + 1] != EMPTY_VALUE)
            VolStep[pos] = VolStep[pos + 1] + sRange * Volume[pos];
         else
            VolStep[pos] = VolStep[pos + 1];
      }
      else
         VolStep[pos] = 0;

      avg[pos] = iMAOnArray(VolStep, 0, p, 0, MODE_EMA, pos);
   }
   return 0;
}