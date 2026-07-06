// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70981

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
#property indicator_buffers 4
#property indicator_label1 "CCI Turbo Histogram"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "CCI Turbo Histogram"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "CCI Turbo"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "CCI 14"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

input int cciTurboLength = 6; // CCI Turbo Length
input int cci14Length = 14; // CCI 14 Length
input int bars_limit = 100000; // Bars limit
double plot1[], plot4[], plot2[], plot3[];

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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Woodies CCI");
   IndicatorBuffers(4);
   SetIndexBuffer(0, plot1);
   SetIndexBuffer(1, plot2);
   SetIndexBuffer(2, plot3);
   SetIndexBuffer(3, plot4);
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
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

   int toSkip = MathMax(cciTurboLength, cci14Length);
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      plot3[pos] = iCCI(_Symbol, _Period, cciTurboLength, PRICE_TYPICAL, pos);
      plot4[pos] = iCCI(_Symbol, _Period, cci14Length, PRICE_TYPICAL, pos);
      bool last5IsDown = plot4[pos + 5] < 0 && plot4[pos + 4] < 0 && plot4[pos + 3] < 0 && plot4[pos + 2] < 0 && plot4[pos + 1] < 0;
      bool last5IsUp = plot4[pos + 5] > 0 && plot4[pos + 4] > 0 && plot4[pos + 3] > 0 && plot4[pos + 2] > 0 && plot4[pos + 1] > 0;
      if (last5IsUp)
      {
         plot1[pos] = plot4[pos];
      }
      else if (last5IsDown)
      {
         plot2[pos] = plot4[pos];
      }
      else if (plot4[pos] < 0)
      {
         plot1[pos] = plot4[pos];
      }
      else
      {
         plot2[pos] = plot4[pos];
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
