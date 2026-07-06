// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68929

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

input int N = 180; // Number of bars
input int O = 3; // Order
input double E = 1.61803399; // Eccart value

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

double L1[], L2[], L3[], L4[], L5[], L6[], L7[];

int init()
{
   IndicatorName = GenerateIndicatorName("Belkhayate's Center Of Gravity");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(7);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, L1);
   SetIndexLabel(0, "L1");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, L2);
   SetIndexLabel(1, "L2");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, L3);
   SetIndexLabel(2, "L3");
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, L4);
   SetIndexLabel(3, "L4");
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, L5);
   SetIndexLabel(4, "L5");
   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, L6);
   SetIndexLabel(5, "L6");
   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, L7);
   SetIndexLabel(6, "L7");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

datetime prevCandle;

double StDev(int Per)
{
   return(MathSqrt(Variance(Per)));
}
double Variance(int Per)
{
   double sum = 0;
   double ssum = 0;
   for (int i=0; i<Per; i++)
   {
      sum += High[i];
      ssum += MathPow(High[i],2);
   }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   if (Time[0] == prevCandle)
      return 0;
   prevCandle = Time[0];

   int pos = 0;
   int s = O + 1;
   double a1[], a2[], a3[], a4[];
   ArrayResize(a1, s * s);
   ArrayResize(a2, (s - 1) * 2 + 1);
   ArrayResize(a3, s);
   ArrayResize(a4, s);
   a2[0] = N + 1;
   for (int i = 1; i <= (s - 1) * 2; ++i)
   {
      a2[i] = 0;
      for (int j = 0; j <= N; ++j)
      {
         a2[i] += MathPow(j, i);
      }
   }

   for (int j = 1; j <= s; ++j)
   {
      for (int i = 0; i <= N; ++i)
      {
         if (j == 1)
            a3[j - 1] += (High[pos + i] + Low[pos + i]) / 2;
         else
            a3[j - 1] += (High[pos + i] + Low[pos + i]) / 2 * (MathPow(i, j - 1));
      }
   }

   for (int j = 1; j <= s; ++j)
   {
      for (int i = 1; i <= s; ++i)
      {
         a1[(i - 1) * s + j - 1] = a2[i + j - 2];
      }
   }

   for (int i = 1; i <= s - 1; ++i)
   {
      int si = 0;
      int v1 = 0;
      for (int j = i; j <= s; ++j)
      {
         if (MathAbs(a1[(j - 1) * s + i - 1]) > v1)
         {
            v1 = MathAbs(a1[(j - 1) * s + i - 1]);
            si = j;
         }
      }
      if (si == 0)
         continue;

      if (si != i)
      {
         for (int j = 1; j <= s; ++j)
         {
            double t = a1[(i - 1) * s + j - 1];
            a1[(i - 1) * s + j - 1] = a1[(si - 1) * s + j - 1];
            a1[(si - 1) * s + j - 1] = t;
         }
         double t = a3[i - 1];
         a3[i - 1] = a3[si - 1];
         a3[si - 1] = t;
      }

      for (int j = i + 1; j <= s; ++j)
      {
         double v1 = a1[(j - 1) * s + i - 1] / a1[(i - 1) * s + i - 1];
         for (int k = 1; k <= s; ++k)
         {
            if (k == i)
               a1[(j - 1) * s + k - 1] = 0;
            else
               a1[(j - 1) * s + k - 1] = a1[(j - 1) * s + k - 1] - v1 * a1[(i - 1) * s + k - 1];
         }
         a3[j - 1] = a3[j - 1] - v1 * a3[i - 1];
      }
   }

   a4[s - 1] = a3[s - 1] / a1[(s - 1) * s + s - 1];

   for (int i = s - 1; i >= 1; --i)
   {
      double v1 = 0;
      for (int j = 1; j <= s - i; ++j)
      {
         v1 = v1 + (a1[(i - 1) * s + i + j - 1]) * (a4[i + j - 1]);
         a4[i - 1] = 1 / a1[(i - 1) * s + i - 1] * (a3[i - 1] - v1);
      }
   }

   for (int i = 0; i <= N; ++i)
   {
      double v1 = 0;
      for (int j = 1; j <= O; ++j)
      {
         v1 = v1 + (a4[j + 1 - 1]) * MathPow(i, j);
      }
      L1[pos + i] = a4[1 - 1] + v1;
   }

   double v2 = StDev(N) * E;
   for (int i = 0; i <= N; ++i)
   {
      L4[pos + i] = L1[pos + i] + v2;
      L3[pos + i] = L1[pos + i] + (L4[pos + i] - L1[pos + i]) / 1.382;
      L2[pos + i] = L1[pos + i] + (L3[pos + i] - L1[pos + i]) / 1.618;
      L7[pos + i] = L1[pos + i] - v2;
      L6[pos + i] = L1[pos + i] - (L1[pos + i] - L7[pos + i]) / 1.382;
      L5[pos + i] = L1[pos + i] - (L1[pos + i] - L6[pos + i]) / 1.618;
   }
   for (int i = N + 1; i <= N + 10; ++i)
   {
      L1[pos + i] = EMPTY_VALUE;
      L2[pos + i] = EMPTY_VALUE;
      L3[pos + i] = EMPTY_VALUE;
      L4[pos + i] = EMPTY_VALUE;
      L5[pos + i] = EMPTY_VALUE;
      L6[pos + i] = EMPTY_VALUE;
      L7[pos + i] = EMPTY_VALUE;
   }
   return 0;
}