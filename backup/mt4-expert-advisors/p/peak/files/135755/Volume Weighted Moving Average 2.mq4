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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

#property indicator_label1 "Oscillator"

input ENUM_MA_METHOD MA_Type = MODE_SMA; // Smoothing method
input int Price_MA_Period = 50;
input int Volume_MA_Period = 70;
input ENUM_APPLIED_PRICE price = PRICE_CLOSE; // Price type

double PV[];
double VWMA[];
double PMA[];
double VolumeArray[];
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int
   try
      = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try ++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("Volume Weighted Moving Average");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);
   IndicatorDigits(Digits);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VWMA);
   SetIndexLabel(0, "VWMA");
   SetIndexDrawBegin(0, Volume_MA_Period);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, PMA);
   SetIndexLabel(1, "PMA");
   SetIndexDrawBegin(1, Price_MA_Period);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, PV);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, VolumeArray);

   return (0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

int start()
{
   if (Bars <= 1)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars - 1;
   if (ExtCountedBars > 1)
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      PV[pos] = Close[pos] * Volume[pos];
      switch (price)
      {
         case PRICE_CLOSE:
            PV[pos] = Close[pos] * Volume[pos];
            break;
         case PRICE_OPEN:
            PV[pos] = Open[pos] * Volume[pos];
            break;
         case PRICE_HIGH:
            PV[pos] = High[pos] * Volume[pos];
            break;
         case PRICE_LOW:
            PV[pos] = Low[pos] * Volume[pos];
            break;
         case PRICE_MEDIAN:
            PV[pos] = (High[pos] + Low[pos]) / 2.0 * Volume[pos];
            break;
         case PRICE_TYPICAL:
            PV[pos] = (High[pos] + Low[pos] + Close[pos]) / 3.0 * Volume[pos];
            break;
         case PRICE_WEIGHTED:
            PV[pos] = (High[pos] + Low[pos] + Close[pos] * 2) / 4.0 * Volume[pos];
            break;
      }

      PMA[pos] = iMA(NULL, 0, Price_MA_Period, 0, (MA_Type - 1), PRICE_CLOSE, pos);

      VolumeArray[pos] = Volume[pos];

      pos--;
   }

   double VSum = 0;
   double PVSum = 0;

   pos = limit;
   while (pos >= 0)
   {
      PVSum = iMAOnArray(PV, 0, Volume_MA_Period, 0, MODE_SMA, pos) * Volume_MA_Period;
      VSum = iMAOnArray(VolumeArray, 0, Volume_MA_Period, 0, MODE_SMA, pos) * Volume_MA_Period;

      if (VSum != 0)
      {
         VWMA[pos] = PVSum / VSum;
      }

      pos--;
   }

   return (0);
}
