// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69323

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

input int Length = 20; // Length
 
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

double a1, b1, c2, c3, c1;
double Oscillator[], Filt[], Slope[], MS[];

int init()
{
   IndicatorName = GenerateIndicatorName("Reflex Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   a1 = MathExp(-1.414*3.14159 / (.5*Length));
	b1 = 2*a1*MathCos(1.414*180 / (.5*Length));
	c2 = b1;
	c3 = -a1*a1;
	c1 = 1 - c2 - c3;

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Oscillator);
   SetIndexLabel(0, "Oscillator");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, Filt);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, Slope);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, MS);

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
   int limit = MathMin(Bars - 1 - 2, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double c2Val = Filt[i + 1] == EMPTY_VALUE ? 0 : c2 * Filt[i + 1];
      double c3Val = Filt[i + 2] == EMPTY_VALUE ? 0 : c3 * Filt[i + 2];
      Filt[i] = c1 * (Close[i] + Close[i + 1]) / 2 + c2Val + c3Val;
      if (i + Length > Bars - 3 || Filt[i + Length] == EMPTY_VALUE)
      {
         continue;
      }
      Slope[i] = (Filt[i + Length] - Filt[i]) / Length;
      double Sum = 0;
      for (int count = 1; count <= Length; count++)
      {
         Sum += (Filt[i] + count * Slope[i]) - Filt[i + count];
      }
      Sum = Sum / Length;
      
      MS[i] = .04 * Sum * Sum + .96 * MS[i + 1];
      if (MS[i] != 0)
         Oscillator[i] = Sum / MathSqrt(MS[i]);
      else
         Oscillator[i] = 0;
   }
   return 0;
}
