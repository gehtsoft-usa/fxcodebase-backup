// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66947

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

string IndicatorName = "VPOC";

input int BoxSize = 5; // Size of price box in pips
input int Size = 8; // Font Size
input int mu = 10; // Size Multiplier (BTC use 1000)
input int candlesBack = 200;// Candles Back

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Gray
#property indicator_label1 "POC"

double marks[];
double BOX;

int OnInit()
{
   IndicatorShortName(IndicatorName);
   IndicatorDigits(_Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, marks);
   
   // double _mult = _Digits == 3 || Digits == 5 ? 10 : 1;
   // double _pipSize = _Point * _mult;
   
   double _pipSize = _Point * mu;
   
   BOX = BoxSize * _pipSize;
   
   //---
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { }
// ------------------------------------------------------------------


int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  int start, i;
  if (prev_calculated == 0)
  {
    start = candlesBack;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
   {
      datetime date = time[i];
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
      {
         continue;
      }
      MP(i, current_time.mon * 31 + current_time.day);
   } 
   return rates_total;
}

void MP(const int p, const int n)
{
   int dayPeriod = iBarShift(_Symbol, PERIOD_D1, Time[p]);
   if (dayPeriod < 0)
      return;
   datetime d1Start = iTime(_Symbol, PERIOD_D1, dayPeriod);
   int x = iBarShift(_Symbol, PERIOD_CURRENT, d1Start);
   if (x < 0)
      return;

   int y = p;
   double max = High[iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, x - y, x)];
   double min = Low[iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, x - y, x)];

   int POC = 0;
   int Profile[];
   for (int j = x; j > y; j--)
   {
      int Count = 0;
      
      for (double i = min; i < max; i+= BOX)
      {
         Count++;
         if (ArraySize(Profile) < Count)
            ArrayResize(Profile, Count);
         if ((i >= Low[j] && i + BOX <= High[j]) || (i <= Low[j] && i + BOX >= Low[j]) || (i <= High[j] && i + BOX >= High[j]))
            Profile[Count - 1] = Profile[Count - 1] + 1;
         if (i == min)
            POC = Count;
         else if (Profile[POC - 1] < Profile[Count - 1])
            POC = Count;
      }
      marks[j] = min + POC * BOX;
   }
}
