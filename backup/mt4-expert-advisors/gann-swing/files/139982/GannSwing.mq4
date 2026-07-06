// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=63884
//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property indicator_buffers 1
#property indicator_chart_window

input int bars = 2; // Bars of max/min
input color GannSwing_Color = clrYellow;

double GannSwing[];
double us[];
double ds[];

int init()
{
   IndicatorShortName("GannSwing");

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 2, clrYellow);
   SetIndexBuffer(0, GannSwing);
   SetIndexLabel(0, "Gann Swing");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, us);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, ds);

   return (0);
}

int deinit()
{
   ObjectsDeleteAll();
   return (0);
}

int start()
{
   int i;
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;

   for (i = limit; i > 0; i--)
   {
      ResetBuffers(i);
   }

   for (i = limit; i > 0; i--)
   {
      ds[i] = 1;
      us[i] = 1;
      bool hh = true;
      bool ll = true;
      for (int ii = 0; ii < bars; ++ii)
      {
         if (High[i + ii] <= High[i + ii + 1])
         {
            us[i] = 0;
         }
         if (Low[i + ii] >= Low[i + ii + 1])
         {
            ds[i] = 0;
         }
      }
      
      // 4.If the next bar has a higher high and a higher low (or the same low) when
      // compared to the previous bar, then the swing line goes up connecting the high of the next bar
      if (us[i] == 0 && High[i] > High[i + 1] && Low[i] >= Low[i + 1])
      {
         us[i] = 1; // Up
      }

      // 5. If the next bar has a lower high (or same high) and a
      // lower low when compared to the previous bar, then the swing line goes down connecting the low of the next bar
      if (ds[i] == 0 && High[i] <= High[i + 1] && Low[i] < Low[i + 1])
      {
         ds[i] = 1; // Up
      }
   }

   int swingDir = 0;
   for (i = limit; i > 0; i--)
   {
      if (us[i] == 1)
      {
         if (swingDir == 1)
         {
            GannSwing[i] = High[i];
         }
         else if (swingDir == -1)
         {
            GannSwing[i] = High[i];
            swingDir = 1;
         }
         else
         {
            swingDir = 1;
            GannSwing[i] = High[i];
         }
      }
      else if (ds[i] == 1)
      {
         if (swingDir == -1)
         {
            GannSwing[i] = Low[i];
         }
         else if (swingDir == 1)
         {
            GannSwing[i] = Low[i];
            swingDir = -1;
         }
         else
         {
            swingDir = -1;
            GannSwing[i] = Low[i];
         }
      }
      else
      {
         if (High[i + 1] > High[i + 2] && Low[i + 1] < Low[i + 3])
         {
            if (High[i] > High[i + 1] && Low[i] >= Low[i + 1])
            {
               if (swingDir == -1)
               {
                  GannSwing[i] = Low[i];
               }
               else if (swingDir == 1)
               {
                  GannSwing[i] = Low[i];
                  swingDir = -1;
               }
            }
            else if (High[i] <= High[i + 1] && Low[i] < Low[i + 1])
            {
               if (swingDir == 1)
               {
                  GannSwing[i] = High[i];
               }
               else if (swingDir == -1)
               {
                  GannSwing[i] = High[i];
                  swingDir = 1;
               }
            }
         }
      }
   }
   int Last = 0;
   int LastIndex = 0;
   for (i = limit; i > 0; i--)
   {
      if (GannSwing[i] == High[i])
      {
         if (Last == 1)
         {
            GannSwing[LastIndex] = EMPTY_VALUE;
         }
         Last = 1;
         LastIndex = i;
      }

      if (GannSwing[i] == Low[i])
      {
         if (Last == -1)
         {
            GannSwing[LastIndex] = EMPTY_VALUE;
         }
         Last = -1;
         LastIndex = i;
      }
   }
   //----
   return (0);
}

void ResetBuffers(int shift)
{
   GannSwing[shift] = EMPTY_VALUE;
   us[shift] = EMPTY_VALUE;
   ds[shift] = EMPTY_VALUE;
   return;
}