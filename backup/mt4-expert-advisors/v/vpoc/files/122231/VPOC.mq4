// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66947

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

string IndicatorName = "VPOC";

extern int BoxSize = 5; // Size of price box in pips
extern int Size = 8; // Font Size

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Gray
#property indicator_label1 "POC"

double marks[];

int init()
{
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 108);
   SetIndexBuffer(0, marks);
   double _mult = Digits == 3 || Digits == 5 ? 10 : 1;
   double _pipSize = Point * _mult;
   
   BOX = BoxSize * _pipSize;
   
   return(0);
}

int deinit()
{
   return(0);
}

double BOX;

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      datetime date = Time[pos];
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
      {
         pos--;
         continue;
      }
      MP(pos, current_time.mon * 31 + current_time.day);
      pos--;
   } 
   return(0);
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
   datetime d1End = iTime(_Symbol, PERIOD_D1, dayPeriod - 1);
   int y = iBarShift(_Symbol, PERIOD_CURRENT, d1End);
   if (y < 0 || p > y)
      return;
   if (d1Start == d1End)
      return;

   double max = High[iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, y - x, x)];
   double min = Low[iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, y - x, x)];

   int POC = 0;
   int Profile[];
   for (int j = x; j < y; j++)
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

         marks[j] = min + POC * BOX;
      }
   }
}
