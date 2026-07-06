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

double out[], globalz[];

int init()
{
   IndicatorName = GenerateIndicatorName("Multi Z-Score analysis");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Multi Z-Score analysis");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, globalz);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int period = 20;

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
      globalz[pos] = 0;
      for (int i = 1; i < 100; ++i)
      {
         double avg = iMA(_Symbol, _Period, period * i, 0, MODE_SMA, PRICE_CLOSE, pos);
         if (period * i >= Bars - pos)
            continue;
         double st = StDev(period * i, pos);
         double zscore = (Close[pos] - avg) / st;
         globalz[pos] = (globalz[pos] + zscore * i) / 100;
      }
      out[pos] = iMAOnArray(globalz, 0, period, 0, MODE_SMA, pos);
   } 
   return 0;
}

double StDev(int Per, int pos)
{
   return MathSqrt(Variance(Per, pos));
}

double Variance(int Per, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < Per; i++)
   {
      sum += Close[pos + i];
      ssum += MathPow(Close[pos + i], 2);
   }
   return (ssum * Per - sum * sum) / (Per * (Per - 1));
}

