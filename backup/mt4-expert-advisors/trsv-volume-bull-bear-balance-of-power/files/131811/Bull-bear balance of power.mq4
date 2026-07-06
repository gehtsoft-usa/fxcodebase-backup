// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69512

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
#property indicator_buffers 1
#property indicator_color1 Red

string IndicatorName;
string IndicatorObjPrefix;
double bop[];

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
   IndicatorName = GenerateIndicatorName("Bull-bear balance of power");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, bop);
   SetIndexLabel(0, "BOP");

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
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double BullPower = 0;
      if (Close[i] < Open[i])
      {
         if (Close[i + 1] < Open[i])
         {
            BullPower = MathMax(High[i] - Close[i + 1], Close[i] - Low[i]);
         }
         else
         {
            BullPower = MathMax(High[i] - Open[i], Close[i] - Low[i]);
         }
      }
      else if (Close[i] > Open[i])
      {
         if (Close[i + 1] > Open[i])
         {
            BullPower = High[i] - Low[i];
         }
         else
         {
            BullPower = MathMax(Open[i] - Close[i + 1], High[i] - Low[i]);
         }
      }
      else if (High[i] - Close[i] > Close[i] - Low[i])
      {
         if (Close[i + 1] < Open[i])
         {
            BullPower = MathMax(High[i] - Close[i + 1], Close[i] - Low[i]);
         }
         else
         {
            BullPower = High[i] - Open[i];
         }
      }
      else if (High[i] - Close[i] < Close[i] - Low[i])
      {
         if (Close[i + 1] > Open[i])
         {
            BullPower = High[i] - Low[i];
         }
         else
         {
            BullPower = MathMax(Open[i] - Close[i + 1], High[i] - Low[i]);
         }
      }
      else if (Close[i + 1] > Open[i])
      {
         BullPower = MathMax(High[i] - Open[i], Close[i] - Low[i]);
      }
      else if (Close[i + 1] < Open[i])
      {
         BullPower = MathMax(Open[i] - Close[i + 1], High[i] - Low[i]);
      }
      else
      {
         BullPower = High[i] - Low[i];
      }

      double BearPower = 0;
      if (Close[i] < Open[i])
      {
         if (Close[i + 1] > Open[i])
         {
            BearPower = MathMax(Close[i + 1] - Open[i], High[i] - Low[i]);
         }
         else
         {
            BearPower = High[i] - Low[i];
         }
      }
      else if (Close[i] > Open[i])
      {
         if (Close[i + 1] > Open[i])
         {
            BearPower = MathMax(Close[i + 1] - Low[i], High[i] - Close[i]);
         }
         else
         {
            BearPower = MathMax(Open[i] - Low[i], High[i] - Close[i]);
         }
      }
      else if (High[i] - Close[i] > Close[i] - Low[i])
      {
         if (Close[i + 1] < Open[i])
         {
            BearPower = MathMax(Close[i] - Open[i], High[i] - Low[i]);
         }
         else
         {
            BearPower = High[i] - Low[i];
         }
      }
      else if (High[i] - Close[i] < Close[i] - Low[i])
      {
         if (Close[i + 1] > Open[i])
         {
            BearPower = MathMax(Close[i] - Low[i], High[i] - Close[i]);
         }
         else
         {
            BearPower = Open[i] - Low[i];
         }
      }
      else if (Close[i + 1] > Open[i])
      {
         BearPower = MathMax(Close[i] - Open[i], High[i] - Low[i]);
      }
      else if (Close[i + 1] < Open[i])
      {
         BearPower = MathMax(Open[i] - Low[i], High[i] - Close[i]);
      }
      else
      {
         BearPower = High[i] - Low[i];
      }
      if (BearPower != 0)
      {
         bop[i] = BullPower / BearPower;
      }
   }
   return 0;
}
