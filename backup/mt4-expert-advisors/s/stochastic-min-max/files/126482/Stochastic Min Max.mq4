// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68493

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
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "Max"
#property indicator_label2 "Min"

extern int      K_periods      = 5; // K Periods
extern int      D_periods      = 3; // D Periods
extern int      Slowing        = 3; // Slowing
extern ENUM_MA_METHOD DS = MODE_SMA; // Smoothing type
extern bool TrendFilter = true; // Use Trend Filter

double Trend[], buy[], sell[];

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
   IndicatorName = GenerateIndicatorName("Stochastic Min Max");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, Trend);
   
   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int Find(int start) 
{
   for (int period = start + 1; period < Bars; ++period)
      if (Trend[period] == 1 || Trend[period] == -1)
         return period;

   return -1;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      double k_0  = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_MAIN, pos);
      double d_0  = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_SIGNAL, pos);
      double k_1  = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_MAIN, pos + 1);
      double d_1  = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_SIGNAL, pos + 1);
      if (k_0 > d_0 && k_1 <= d_1)
         Trend[pos] = 1;	
      else if (k_0 < d_0 && k_1 >= d_1)
         Trend[pos] = -1;

      if (Trend[pos] == 1 || Trend[pos] == -1)
      {
         int from = Find(pos);
         if (from != -1)
         {
            int maxpos = iHighest(_Symbol, _Period, MODE_HIGH, from - pos, pos);
            int minpos = iLowest(_Symbol, _Period, MODE_LOW, from - pos, pos);
            double min = Low[minpos];
            double max = High[maxpos];
            if ((Trend[pos] != 1 && TrendFilter) || !TrendFilter)
            {
               buy[maxpos] = max;
               sell[maxpos] = EMPTY_VALUE;
            }
            if ((Trend[pos] != -1 && TrendFilter) || !TrendFilter)
            {
               sell[minpos] = min;
               buy[minpos] = EMPTY_VALUE;
            }
         }
      }

      pos--;
   } 
   return 0;
}

