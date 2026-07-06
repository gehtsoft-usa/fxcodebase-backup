// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70673

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
//#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 OrangeRed
#property indicator_width1 2
#property indicator_width2 2

enum PriceType
{
   PriceClose = PRICE_CLOSE, // Close
   PriceOpen = PRICE_OPEN, // Open
   PriceHigh = PRICE_HIGH, // High
   PriceLow = PRICE_LOW, // Low
   PriceMedian = PRICE_MEDIAN, // Median
   PriceTypical = PRICE_TYPICAL, // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody, // Median (body)
   PriceAverage, // Average
   PriceTrendBiased, // Trend biased
   PriceVolume, // Volume
};
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input PriceType Price = PriceClose; //
input bool use_ha = true; // Use HA prices
input int Length = 14;          //
input double Sigma = 6.0;       //Sigma parameter
input double Offset = 0.85;     //Offset of Gaussian distribution (0...1)
input double DampingFactor = 1; //0...1.0(ex.0.7)
input double PctFilter = 0;     //Dynamic filter in decimal
input int Shift = 0;            //
input int ColorMode = 0;        //
input int ColorBarBack = 1;     //
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

double ind_buffer0Up[];
double ind_buffer0Down[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("hullalmtf");
   IndicatorShortName("Hull AL MTF");

   IndicatorBuffers(3);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, ind_buffer0Up);
   SetIndexLabel(id, "HullALMA Uptrend");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, ind_buffer0Down);
   SetIndexLabel(id, "HullALMA Dntrend");
   ++id;

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
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int index = pos == 0 ? 0 : iBarShift(_Symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      ind_buffer0Up[pos] = iCustom(_Symbol, tf, "hull_al", Price, use_ha, Length, Sigma, Offset, DampingFactor, PctFilter, Shift, 0, index);
      ind_buffer0Down[pos] = iCustom(_Symbol, tf, "hull_al", Price, use_ha, Length, Sigma, Offset, DampingFactor, PctFilter, Shift, 1, index);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
