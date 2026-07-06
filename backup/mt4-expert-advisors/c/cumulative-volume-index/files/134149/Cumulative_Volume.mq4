// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=17&t=42392

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
#property version   "1.3"
#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrMagenta
#property indicator_color2 Green
#property  indicator_width1  2
#property  indicator_width2  2
extern int Length=60;
extern bool Combined=true;
extern bool Relative=false;
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];

int init()
{
   IndicatorShortName("Cumulative Volume");
   IndicatorDigits(Digits);
   if (Combined)
   {
      SetIndexStyle(2,DRAW_LINE);
      SetIndexBuffer(0,Cumulative);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexBuffer(1,Positive);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,Negative);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,APos);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,ANeg);
   }
   else
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(0,Positive);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Negative);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,APos);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,ANeg);
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=Length) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   for (int pos = limit; pos >= 0; --pos)
   {
      if (_Period == timeframe || timeframe == PERIOD_CURRENT)
      {
         if (Close[pos] > Close[pos + 1])
         {
            APos[pos] = Volume[pos] / 100;
            ANeg[pos] = 0;
         }
         else
         {
            APos[pos] = 0;
            ANeg[pos] = Volume[pos] / 100;
         }
         double p = iMAOnArray(APos, 0, Length, 0, MODE_SMA, pos) * Length;
         double n = iMAOnArray(ANeg, 0, Length, 0, MODE_SMA, pos) * Length;
         if (pos > Bars - 1 - Length)
            continue;
         double SVolume = 0.;
         for (int i = 0; i < Length; i++)
         {
            SVolume = SVolume + Volume[pos + i];
         }
         SVolume = SVolume / 100;
         if (Combined)
         {
            if (Relative)
               Cumulative[pos] = (p - n) * 1000 / SVolume;
            else
               Cumulative[pos] = p - n;
         }
         else
         {
            if (Relative)
            {
               Positive[pos] = p * 1000 / SVolume;
               Negative[pos] = -n * 1000 / SVolume;
            }
            else
            {
               Positive[pos] = p;
               Negative[pos] = -n;
            }
         }
      }
      else
      {
         int index = iBarShift(_Symbol, timeframe, Time[pos]);
         if (index < 0)
            continue;
         if (Combined)
            Cumulative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative, 0, index);
         else
         {
            Positive[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative, 0, index);
            Negative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume v1.3", Length, Combined, Relative,1, index);
         }
      }
   }
   
   return(0);
}

