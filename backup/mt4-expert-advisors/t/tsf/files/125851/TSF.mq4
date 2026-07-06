// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68365

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
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "TSF"

input int Period = 5; // Period

double TSF[];

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
   IndicatorName = GenerateIndicatorName("TSF");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TSF);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

void LinReg(const int period, double &a, double &b)
{
   int xSum = 0;
   double ySum = 0;
   for (int i = 0; i < Period; ++i)
   {
      xSum += i;
      ySum += Close[period + i];
   }

   double xAvg = xSum / Period;
   double yAvg = ySum / Period;
   double aSum1 = 0;
   double aSum2 = 0;
   for (int i = 0; i < Period; ++i)
   {
      aSum1 += (i - xAvg) * (Close[period + i] - yAvg);
      aSum2 += (i - xAvg) * (i - xAvg);
   }

   a = (aSum1 / aSum2);
   b = yAvg - (a * xAvg);
}

int start()
{
   if (Bars <= 1)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return(-1);
   int limit = Bars - 1 - Period;
   if (ExtCountedBars > 1)
      limit = MathMin(limit, Bars - ExtCountedBars - 1);
   int pos = limit;
   while (pos >= 0)
   {
      double a, b;
      LinReg(pos, a, b);
      TSF[pos] = b + (a * (Period - 1 - Period));
      pos--;
   } 
   return(0);
}
