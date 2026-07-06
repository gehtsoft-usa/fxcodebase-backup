// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68574

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
#property indicator_color1 Green
#property indicator_label1 "Oscillator"

input int Period3 = 14; // 1. Period
input int Period1 = 14; // 2. Period
input int Period2 = 1; // 3. Period

double out[], Average[];

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
   IndicatorName = GenerateIndicatorName("Lagrange Interpolation forecasting Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexBuffer(1, Average);
   SetIndexShift(0, Period2);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      Average[pos] = iMA(_Symbol, _Period, Period3, 0, MODE_SMA, PRICE_CLOSE, pos);
      int period = Bars - 1 - pos;
      if (period > Period1 * 2)
      {
         out[pos] = LagrangeInterpolation(period + Period2, 
            period - Period1 * 2 + 1, 
            period - Period1 * 1 + 1, 
            period, 
            Average[pos + Period1 * 2 - 1], 
            Average[pos + Period1 * 1 - 1], 
            Average[pos]) - Average[pos];
      }
      pos--;
   } 
   return 0;
}

double LagrangeInterpolation(double x, double x1, double x2, double x3, double y1, double y2, double y3)
{
   double A = (y1 * (x - x2) * (x - x3)) / ((x1 - x2) * (x1 - x3));
   double B = (y2 * (x - x1) * (x - x3)) / ((x2 - x1) * (x2 - x3));
   double C = (y3 * (x - x1) * (x - x2)) / ((x3 - x1) * (x3 - x2));
   return A + B + C;
}
