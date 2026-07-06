// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69080

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
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Green

input int period = 10; // Period

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

double indexes[];
double out[];
double out2[];
double out3[];

int init()
{
   IndicatorName = GenerateIndicatorName("Intraday Average Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Out");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out2);
   SetIndexLabel(1, "Up");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, out3);
   SetIndexLabel(2, "Down");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, indexes);

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
      int dayStartIndex = iBarShift(_Symbol, PERIOD_D1, Time[pos]);
      if (dayStartIndex < 0)
         continue;
      datetime dayStart = iTime(_Symbol, PERIOD_D1, dayStartIndex);
      indexes[pos] = iBarShift(_Symbol, _Period, dayStart) - pos;
      if (indexes[pos] < 0)
      {
         indexes[pos] = EMPTY_VALUE;
         continue;
      }
      if (pos > Bars - 145)
         continue;

      double delta = 0;
      for (int i = 0; i < 144; ++i)
      {
         if (indexes[pos + i] > delta && indexes[pos + i] != EMPTY_VALUE)
            delta = indexes[pos + i];
      }
      if (pos + (int)(period * delta) >= Bars)
         continue;
      
      double somma = 0;
      double sc = 0;
      out[pos] = somma / period;
      for (int i = 1; i <= period; ++i)
      {
         double val = Volume[pos + (int)(i * delta)];
         somma += val;
         sc = sc + (val - out[pos]) * (val - out[pos]);
      }
      double scar = MathSqrt(sc / period);
      out2[pos] = out[pos] + scar;
      out3[pos] = out[pos] - scar;
   } 
   return 0;
}