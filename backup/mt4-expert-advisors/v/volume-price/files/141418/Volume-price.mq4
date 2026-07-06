// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71065

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

input string symbol = "EURUSD"; // Symbol
input bool normilize = false; // Normalize
input int normalizationPeriod = 10; // Normalization period
input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}
double out[], src[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("volume-price");
   IndicatorShortName("Volume-price");

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Volume/Price");
   if (normilize)
   {
      SetIndexStyle(1, DRAW_NONE);
      SetIndexBuffer(1, src);
   }

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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
      ArrayInitialize(out, EMPTY_VALUE);
      ArrayInitialize(src, EMPTY_VALUE);
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

   int toSkip = normalizationPeriod;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int index = iBarShift(symbol, PERIOD_CURRENT, time[pos]);
      if (index < 0)
      {
         continue;
      }
      if (normilize)
      {
         src[pos] = iVolume(symbol, PERIOD_CURRENT, index) / iClose(symbol, PERIOD_CURRENT, index);
         int outLowestIndex = ArrayMinimum(src, normalizationPeriod, pos);
         double outLowest = out[outLowestIndex];
         int outHighestIndex = ArrayMaximum(src, normalizationPeriod, pos);
         double outHighest = src[outHighestIndex];
         double outRange = outHighest - outLowest;
         out[pos] = outRange == 0 ? 0 : (src[pos] - outLowest) / outRange;
      }
      else
      {
         out[pos] = iVolume(symbol, PERIOD_CURRENT, index) / iClose(symbol, PERIOD_CURRENT, index);
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
