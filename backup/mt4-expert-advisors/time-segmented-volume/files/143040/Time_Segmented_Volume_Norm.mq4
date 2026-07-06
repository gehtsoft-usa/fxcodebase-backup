// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=65882


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

input int Period=14;
input int NormPeriod = 14; // Normalization period
input int bars_limit = 1000; // Bars limit

double UP[], DN[];
double Temp[];
double Raw[];
double RawNorm[];

int init()
{
   IndicatorShortName("Time Segmented Volume");
   IndicatorDigits(Digits);
   
   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,UP);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DN);
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Temp);

   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,Raw);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, RawNorm);
   
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

   int toSkip = Period;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      Temp[pos]=0;
      
      if(Close[pos]> Close[pos+1]) 
      {
         Temp[pos]=  Volume[pos] * (Close[pos]- Close[pos+1]);
      }
      if(Close[pos]< Close[pos+1]) 
      {
         Temp[pos]=  -1* Volume[pos] * (Close[pos+1]- Close[pos]);
      }
      Raw[pos] = iMAOnArray(Temp,0,Period,0,MODE_SMA,pos)*Period;
      if (pos + NormPeriod > rates_total - 1 || Raw[pos + NormPeriod] == EMPTY_VALUE)
      {
         continue;
      }

      int RawLowestIndex = ArrayMinimum(Raw, NormPeriod, pos);
      double RawLowest = Raw[RawLowestIndex];
      int RawHighestIndex = ArrayMaximum(Raw, NormPeriod, pos);
      double RawHighest = Raw[RawHighestIndex];
      double RawRange = RawHighest - RawLowest;
      double RawNormilized = RawRange == 0 ? 0 : (Raw[pos] - RawLowest) / RawRange;
      RawNorm[pos] = RawNormilized;

      if (RawNorm[pos] > RawNorm[pos + 1])
      {
         UP[pos] = RawNorm[pos];
         DN[pos] = 0;
      }
      else
      {
         DN[pos] = RawNorm[pos];
         UP[pos] = 0;
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}