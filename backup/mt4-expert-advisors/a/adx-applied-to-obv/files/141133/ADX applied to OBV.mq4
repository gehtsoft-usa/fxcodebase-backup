// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70994


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
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

input int Period1 = 22; // Length
input int Period2 = 22; // Smoothing

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

double PLUS[], MINUS[], ADX[], OBV[], plusDM[], minusDM[], trur[], Data[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("indi_short");
   IndicatorShortName("...");

   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ADX);
   SetIndexLabel(0, "ADX");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, PLUS);
   SetIndexLabel(1, "PLUS");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, MINUS);
   SetIndexLabel(2, "MINUS");
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, OBV);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, plusDM);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, minusDM);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, trur);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, Data);

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
      ArrayInitialize(ADX, EMPTY_VALUE);
      ArrayInitialize(OBV, EMPTY_VALUE);
      ArrayInitialize(Data, EMPTY_VALUE);
      ArrayInitialize(plusDM, EMPTY_VALUE);
      ArrayInitialize(minusDM, EMPTY_VALUE);
      ArrayInitialize(PLUS, EMPTY_VALUE);
      ArrayInitialize(MINUS, EMPTY_VALUE);
      ArrayInitialize(trur, 0);
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

   int toSkip = Period1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      if (OBV[pos + 1] == EMPTY_VALUE)
      {
         OBV[pos] = tick_volume[pos];
      }
      else
      {
         if (close[pos] > close[pos + 1])
            OBV[pos] = OBV[pos + 1] + tick_volume[pos];
         else if (close[pos] < close[pos + 1])
            OBV[pos] = OBV[pos + 1] - tick_volume[pos];
         else
            OBV[pos] = OBV[pos + 1];
      }
      if (close[pos] > close[pos + 1])
         plusDM[pos] = tick_volume[pos];
      else
         minusDM[pos] = tick_volume[pos];
      
      double stdev = StDev(OBV, Period1, pos);
	   trur[pos] = ((trur[pos + 1] * (Period1 - 1)) + stdev) / Period1;
      PLUS[pos] = 100 * iMAOnArray(plusDM, 0, Period1, 0, MODE_EMA, pos) / trur[pos];
      MINUS[pos] = 100 * iMAOnArray(minusDM, 0, Period1, 0, MODE_EMA, pos) / trur[pos];
      
      if ((MINUS[pos] + PLUS[pos]) == 0)
         Data[pos] = MathAbs(PLUS[pos] - MINUS[pos]);
      else
         Data[pos] = MathAbs(PLUS[pos] - MINUS[pos]) / (MINUS[pos] + PLUS[pos]);
      
      ADX[pos] = 100 * iMAOnArray(Data, 0, Period2, 0, MODE_EMA, pos);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}