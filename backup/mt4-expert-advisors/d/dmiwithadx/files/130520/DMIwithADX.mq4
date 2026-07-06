// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69282

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

input int ADXF = 14; // ADX Number of periods
input int DMIF = 14; // DMI Number of periods

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue

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

double DIP[], DIM[], ADX[], avgPlusDM[], avgMinusDM[], buffer[];

int init()
{
   IndicatorName = GenerateIndicatorName("DMIwithADX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(6);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, DIP);
   SetIndexLabel(0, "DIP");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, DIM);
   SetIndexLabel(1, "DIM");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, ADX);
   SetIndexLabel(2, "ADX");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, avgPlusDM);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, avgMinusDM);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, buffer);

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
   for (int i = limit; i >= 0; i--)
   {
      double upperMove = MathMax(0, High[i] - High[i + 1]);
      double lowerMove = MathMax(0, Low[i + 1] - Low[i]);
      if (upperMove == lowerMove)
      {
         upperMove = 0;
         lowerMove = 0;
      }
      else if (upperMove < lowerMove)
         upperMove = 0;
      else if (lowerMove < upperMove)
         lowerMove = 0;
      double TR = MathMax(MathMax(MathAbs(High[i] - Low[i]), MathAbs(High[i] - Close[i + 1])), MathAbs(Close[i + 1] - Low[i]));
      if (TR == 0)
      {
         avgPlusDM[i] = 0;
         avgMinusDM[i] = 0;
      }
      else
      {
         avgPlusDM[i] = 100 * upperMove / TR;
         avgMinusDM[i] = 100 * lowerMove / TR;
      }
      DIP[i] = iMAOnArray(avgPlusDM, 0, DMIF, 0, MODE_EMA, i);
      DIM[i] = iMAOnArray(avgMinusDM, 0, DMIF, 0, MODE_EMA, i);
      double div = DIP[i] + DIM[i];
      if (div == 0)
         buffer[i] = 0;
      else
         buffer[i] = 100 * (MathAbs(DIP[i] - DIM[i]) / div);

      ADX[i] = iMAOnArray(buffer, 0, ADXF, 0, MODE_EMA, i);
   }
   return 0;
}
