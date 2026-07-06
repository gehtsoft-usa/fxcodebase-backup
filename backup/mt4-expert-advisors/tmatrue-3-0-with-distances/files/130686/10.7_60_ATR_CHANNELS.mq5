// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69307

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property  indicator_buffers 7
#property indicator_plots 7
#property  indicator_color1  Aqua //Moving Average
#property  indicator_color2  Black//DeepSkyBlue // Lower band 1
#property  indicator_color3  Black//DeepSkyBlue // Upper band 1
#property  indicator_color4  Maroon // Lower band 2
#property  indicator_color5  Maroon // Upper band 2
#property  indicator_color6  Black // Lower band 3
#property  indicator_color7  Black // Upper band 3
//---- indicator buffers
double     MA_Buffer0[];
double     Ch1up_Buffer1[];
double     Ch1dn_Buffer2[];
double     Ch2up_Buffer3[];
double     Ch2dn_Buffer4[];
double     Ch3up_Buffer5[];
double     Ch3dn_Buffer6[];

//---- input parameters
input int       PeriodsATR=500;
input int       MA_Periods=240;
input ENUM_MA_METHOD MA_type = MODE_LWMA; // Smoothing method
input double       Mult_Factor1= 3.2;
input double       Mult_Factor2= 6.4;
input double       Mult_Factor3= 9.6;

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

int atr, ma;

int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("ATR Channels");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   atr = iATR(_Symbol, _Period, PeriodsATR);
   ma = iMA(_Symbol, _Period, MA_Periods, 0, MA_type, PRICE_OPEN);

   SetIndexBuffer(0, MA_Buffer0, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);

   SetIndexBuffer(1, Ch1up_Buffer1, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(1, PLOT_LABEL, "ATRu " + PeriodsATR + ", " + Mult_Factor1);

   SetIndexBuffer(2, Ch1dn_Buffer2, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "ATRd " + PeriodsATR + ", " + Mult_Factor1);

   SetIndexBuffer(3, Ch2up_Buffer3, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(3, PLOT_LABEL, "ATRu " + PeriodsATR + ", " + Mult_Factor2);

   SetIndexBuffer(4, Ch2dn_Buffer4, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(4, PLOT_LABEL, "ATRd " + PeriodsATR + ", " + Mult_Factor2);

   SetIndexBuffer(5, Ch3up_Buffer5, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(5, PLOT_LABEL, "ATRu " + PeriodsATR + ", " + Mult_Factor3);

   SetIndexBuffer(6, Ch3dn_Buffer6, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(6, PLOT_LABEL, "ATRd " + PeriodsATR + ", " + Mult_Factor3);

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(atr);
   IndicatorRelease(ma);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   for (int i = prev_calculated; i < rates_total; ++i)
   {
      double atrValues[1];
      if (CopyBuffer(atr, 0, rates_total - 1 - i, 1, atrValues) != 1)
      {
         continue;
      }
      double maValues[1];
      if (CopyBuffer(ma, 0, rates_total - 1 - i, 1, maValues) != 1)
      {
         continue;
      }
      MA_Buffer0[i] = maValues[0];
      Ch1up_Buffer1[i] = maValues[0] + atrValues[0] * Mult_Factor1;
      Ch1dn_Buffer2[i] = maValues[0] - atrValues[0] * Mult_Factor1;
      
      Ch2up_Buffer3[i] = maValues[0] + atrValues[0] * Mult_Factor2;
      Ch2dn_Buffer4[i] = maValues[0] - atrValues[0] * Mult_Factor2;
      
      Ch3up_Buffer5[i] = maValues[0] + atrValues[0] * Mult_Factor3;
      Ch3dn_Buffer6[i] = maValues[0] - atrValues[0] * Mult_Factor3;
   }
   return rates_total;
}
