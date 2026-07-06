// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69603

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red

input int PeriodeA = 10;
input int nbChandelierA = 15;
input int PeriodeB = 20;
input int nbChandelierB = 35;

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

double angle[], pente[], trigger[];

int init()
{
   IndicatorName = GenerateIndicatorName("Arctan");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, angle);
   SetIndexLabel(0, "Angle");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, pente);
   SetIndexLabel(1, "Pente");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, trigger);
   SetIndexLabel(2, "Trigger");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   int minBars = MathMax(PeriodeA + nbChandelierA, PeriodeB + nbChandelierB + 5);
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      double MMA = iMA(_Symbol, 0, PeriodeA, 0, MODE_EMA, PRICE_CLOSE, i);
      double MMA2 = iMA(_Symbol, 0, PeriodeA, 0, MODE_EMA, PRICE_CLOSE, i + nbChandelierA);
      double ADJASUROPPO = (MMA - MMA2) / pipSize / nbChandelierA;
      angle[i] = MathTan(ADJASUROPPO);

      double MMB = iMA(_Symbol, 0, PeriodeB, 0, MODE_EMA, PRICE_CLOSE, i);
      double MMB2 = iMA(_Symbol, 0, PeriodeB, 0, MODE_EMA, PRICE_CLOSE, i + nbChandelierB);
      pente[i] = (MMB - MMB2) / pipSize / nbChandelierB;
      trigger[i] = iMAOnArray(pente, 0, PeriodeB, 0, MODE_EMA, i + 5);
   }
   return 0;
}
