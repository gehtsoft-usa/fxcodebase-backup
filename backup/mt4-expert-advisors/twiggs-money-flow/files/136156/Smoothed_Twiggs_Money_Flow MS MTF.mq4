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
#property strict
#property version   "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow;

input int Length=21;
input bool AddSmoothing = false; // Add smoothing
input int SmoothingLength = 7; // Smoothing length
input ENUM_MA_METHOD SmoothingType = MODE_EMA;//MA1 Type
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

double TMF_up[], TMF_down[], TMF[];
double ADV[], Vol[], WMA_ADV[], WMA_V[], Smoothing[];
double k;

int init()
{
   IndicatorShortName("Smoothed Twiggs Money Flow");
   IndicatorDigits(Digits);
   IndicatorBuffers(3);
   double temp = iCustom(NULL, 0, "Smoothed_Twiggs_Money_Flow", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Smoothed_Twiggs_Money_Flow' indicator");
      return INIT_FAILED;
   }
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TMF_up);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, TMF_down);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Smoothing);
   
   k=1./Length;

   return(0);
}

int deinit()
{
   return(0);
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
      ArrayInitialize(TMF_up, EMPTY_VALUE);
      ArrayInitialize(TMF_down, EMPTY_VALUE);
      ArrayInitialize(Smoothing, EMPTY_VALUE);
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

   int toSkip = 0;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      int index = iBarShift(symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      TMF_up[pos] = iCustom(symbol, tf, "Smoothed_Twiggs_Money_Flow", Length, AddSmoothing, SmoothingLength, SmoothingType, 0, index);
      TMF_down[pos] = iCustom(symbol, tf, "Smoothed_Twiggs_Money_Flow", Length, AddSmoothing, SmoothingLength, SmoothingType, 1, index);
      Smoothing[pos] = iCustom(symbol, tf, "Smoothed_Twiggs_Money_Flow", Length, AddSmoothing, SmoothingLength, SmoothingType, 2, index);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
