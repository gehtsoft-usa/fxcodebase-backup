// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70247

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
#property indicator_buffers 5
#property indicator_color1 Silver
#property indicator_color2 Orange
#property indicator_color3 Orange
#property indicator_color4 Red
#property indicator_color5 Aqua

//---- input parameters
input int RSIPeriod = 14;
input int BandPeriod = 20;
input int EMA_val = 5;
input double SD_Coeff = 1.3185;

//---- buffers
double Buffer[];
double UpZone[], DnZone[];
double bufMA[], bufEMA[];

input int iPeriod = 1;

int init()
{
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Buffer);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(1, UpZone);
   SetIndexBuffer(2, DnZone);
   SetIndexBuffer(3, bufMA);
   SetIndexBuffer(4, bufEMA);

   return (0);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(Buffer, EMPTY_VALUE);
      ArrayInitialize(UpZone, EMPTY_VALUE);
      ArrayInitialize(DnZone, EMPTY_VALUE);
      ArrayInitialize(bufMA, EMPTY_VALUE);
      ArrayInitialize(bufEMA, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int limit, i;
   int counted_bars = IndicatorCounted();
   double HD, LD, amplitude;

   double MA, RSI[];
   ArrayResize(RSI, BandPeriod);

   int toSkip = BandPeriod;
   for (int i = rates_total - 1 - MathMax(prev_calculated, toSkip); i >= 0 && !IsStopped(); --i)
   {
      HD = high[Highest(NULL, 0, MODE_HIGH, (iPeriod * 20), i)];
      LD = low[Lowest(NULL, 0, MODE_LOW, (iPeriod * 20), i)];
      amplitude = HD - LD;
      Buffer[i] = amplitude == 0 ? 0 : ((close[i] - (HD - (amplitude / 2))) / amplitude) * iPeriod;
      MA = 0;
      for (int j = i; j < i + BandPeriod; j++)
      {
         RSI[j - i] = Buffer[j];
         MA += Buffer[j] / BandPeriod;
      }
      UpZone[i] = MA + (SD_Coeff * StDev(RSI, BandPeriod));
      DnZone[i] = MA - (SD_Coeff * StDev(RSI, BandPeriod));
      bufMA[i] = MA;
      bufEMA[i] = iMAOnArray(Buffer, 0, EMA_val, 0, MODE_EMA, i);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

double StDev(double &Data[], int Per)
{
   return (MathSqrt(Variance(Data, Per)));
}

double Variance(double &Data[], int Per)
{
   double sum, ssum;
   for (int i = 0; i < Per; i++)
   {
      sum += Data[i];
      ssum += MathPow(Data[i], 2);
   }
   return ((ssum * Per - sum * sum) / (Per * (Per - 1)));
}
