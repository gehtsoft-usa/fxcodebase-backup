// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70003
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
#property link "http://fxcodebase.com"
#property version "1.1"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1 clrSandyBrown
#property indicator_color2 clrDeepSkyBlue
#property indicator_color3 clrDimGray

#property indicator_color4 clrWhite

// User input
input int MA_Period = 34;
input int MA_Shift = 0;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input int VolatilityPeriod = 14; // Volatality Period
input double multiplier = 2.0;   // Multiplier (default 2.0)
input int range = 10; // Normilization range

// Buffers
double VolBuffer3[]; // moving average

//----
int ExtCountedBars = 0;
int lastcolor = 0;

double LineBuffer[];

double buff1[], buff2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   int draw_begin;
   string short_name;

   IndicatorBuffers(4);

   // indicator buffers mapping, drawing settings and Shift
   // Moving average line white
   SetIndexBuffer(0, VolBuffer3);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexShift(0, MA_Shift);

   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));

   draw_begin = MA_Period - 1;

   switch (MA_Method)
   {
   case 1:
      short_name = "EMA(";
      draw_begin = 0;
      break;
   case 2:
      short_name = "SMMA(";
      break;
   case 3:
      short_name = "LWMA(";
      break;
   default:
      short_name = "SMA(";
   }
   IndicatorShortName(short_name + MA_Period + ")");

   SetIndexShift(1, 0);
	SetIndexDrawBegin(1, VolatilityPeriod);
	SetIndexBuffer(1, LineBuffer);
	SetIndexStyle(1, DRAW_LINE);
	SetIndexEmptyValue(1, EMPTY_VALUE);
	SetIndexLabel(1, "ATR Line");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, buff1);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, buff2);

   return (0);
}

//+------------------------------------------------------------------+
//| Main                                                             |
//+------------------------------------------------------------------+
int start()
{
   if (Bars <= MA_Period)
   {
      return (0);
   }
   ExtCountedBars = IndicatorCounted();

   // check for possible errors
   if (ExtCountedBars < 0)
   {
      return (-1);
   }

   // last counted bar will be recounted
   if (ExtCountedBars > 0)
   {
      ExtCountedBars--;
   }

   switch (MA_Method)
   {
   case 0:
      sma();
      break;
   case 1:
      ema();
      break;
   case 2:
      smma();
      break;
   case 3:
      lwma();
   }
   int limit = Bars - ExtCountedBars;
   for (int i = 0; i < limit; i++)
	{
		buff2[i] = (iMA(NULL, 0, VolatilityPeriod, 0, MODE_SMA, PRICE_HIGH, i) - iMA(NULL, 0, VolatilityPeriod, 0, MODE_SMA, PRICE_LOW, i)) * multiplier;
	}
   for (int pos = limit; pos >= 0; --pos)
   {
      double min1 = DBL_MAX;
      double min2 = DBL_MAX;
      double max1 = DBL_MAX;
      double max2 = DBL_MAX;
      for (i = pos; i < MathMin(Bars - 1, pos + range); ++i)
      {
         if (min1 == DBL_MAX || min1 > buff1[i])
         {
            min1 = buff1[i];
         }
         if (max1 == DBL_MAX || max1 < buff1[i])
         {
            max1 = buff1[i];
         }
         if (min2 == DBL_MAX || min2 > buff2[i])
         {
            min2 = buff2[i];
         }
         if (max2 == DBL_MAX || max2 < buff2[i])
         {
            max2 = buff2[i];
         }
      }
      LineBuffer[pos] = (max2 - min2) == 0 ? 0 : (buff2[pos] - min2) / (max2 - min2);
      VolBuffer3[pos] = (max1 - min1) == 0 ? 0 : (buff1[pos] - min1) / (max1 - min1);
   }
   return (0);
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
{
   double sum = 0;
   int i, pos = Bars - ExtCountedBars - 1;

   // initial accumulation
   if (pos < MA_Period)
      pos = MA_Period;
   for (i = 1; i < MA_Period; i++, pos--)
      sum += Volume[pos];

   while (pos >= 0)
   {
      sum += Volume[pos];
      buff1[pos] = sum / MA_Period;
      sum -= Volume[pos + MA_Period - 1];
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
{
   double pr = 2.0 / (MA_Period + 1);
   int pos = Bars - 2;

   if (ExtCountedBars > 2)
      pos = Bars - ExtCountedBars - 1;

   while (pos >= 0)
   {
      if (pos == Bars - 2)
         buff1[pos + 1] = Volume[pos + 1];
      buff1[pos] = Volume[pos] * pr + buff1[pos + 1] * (1 - pr);
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
{
   double sum = 0;
   int i, k, pos = Bars - ExtCountedBars + 1;

   pos = Bars - MA_Period;
   if (pos > Bars - ExtCountedBars)
      pos = Bars - ExtCountedBars;
   while (pos >= 0)
   {
      if (pos == Bars - MA_Period)
      {
         // initial accumulation
         for (i = 0, k = pos; i < MA_Period; i++, k++)
         {
            sum += Volume[k];
            // zero initial bars
            buff1[k] = 0;
         }
      }
      else
         sum = buff1[pos + 1] * (MA_Period - 1) + Volume[pos];
      buff1[pos] = sum / MA_Period;
      pos--;
   }
}

//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
{
   double sum = 0.0, lsum = 0.0;
   double price;
   int i, weight = 0, pos = Bars - ExtCountedBars - 1;
   //---- initial accumulation
   if (pos < MA_Period)
      pos = MA_Period;
   for (i = 1; i <= MA_Period; i++, pos--)
   {
      price = Volume[pos];
      sum += price * i;
      lsum += price;
      weight += i;
   }
   //---- main calculation loop
   pos++;
   i = pos + MA_Period;
   while (pos >= 0)
   {
      buff1[pos] = sum / weight;
      if (pos == 0)
         break;
      pos--;
      i--;
      price = Volume[pos];
      sum = sum - lsum + price * MA_Period;
      lsum -= Volume[i];
      lsum += price;
   }
   //---- zero initial bars
   if (ExtCountedBars < 1)
      for (i = 1; i < MA_Period; i++)
         buff1[Bars - i] = 0;
}
