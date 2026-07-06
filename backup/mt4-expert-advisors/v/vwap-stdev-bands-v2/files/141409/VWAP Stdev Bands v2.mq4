// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71062

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
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_label1 "VWAP"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "VWAP Upper"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "VWAP Lower"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "VWAP Upper (2)"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "VWAP Lower (2)"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "VWAP Upper (3)"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Teal
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "VWAP Lower (3)"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Teal
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_type8 DRAW_LINE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

input int devUp1 = 2; // Stdev above (1)
input int devDn1 = 2; // Stdev below (1)
input double devUp2 = 1.28; // Stdev above (2)
input double devDn2 = 1.28; // Stdev below (2)
input double devUp3 = 3.09; // Stdev above (3)
input double devDn3 = 3.09; // Stdev below (3)
input bool showDv2 = false; // Show second group of bands?
input bool showDv3 = false; // Show third group of bands?
input bool showPrevVWAP = false; // Show previous VWAP close
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[], plot7[], plot8[];
double vwapsum[], volumesum[], v2sum[], prevwap[];

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
   IndicatorShortName("VWAP Stdev Bands v2");
   IndicatorBuffers(12);
   SetIndexBuffer(0, plot1);
   SetIndexBuffer(1, plot2);
   SetIndexBuffer(2, plot3);
   SetIndexBuffer(3, plot4);
   SetIndexBuffer(4, plot5);
   SetIndexBuffer(5, plot6);
   SetIndexBuffer(6, plot7);
   SetIndexBuffer(7, plot8);
   SetIndexBuffer(8, vwapsum);
   SetIndexBuffer(9, volumesum);
   SetIndexBuffer(10, v2sum);
   SetIndexBuffer(11, prevwap);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double iff(bool cond, double trueVal, double falseVal)
{
   return cond ? trueVal : falseVal;
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
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(vwapsum, 0);
      ArrayInitialize(volumesum, 0);
      ArrayInitialize(v2sum, 0);
      ArrayInitialize(prevwap, 0);
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

   int toSkip = 1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int index = iBarShift(_Symbol, PERIOD_D1, time[pos]);
      if (index < 0)
      {
         continue;
      }
      bool newSession = time[pos] == iTime(_Symbol, PERIOD_D1, index);
      double hl2 = (high[pos] + low[pos]) / 2;
      vwapsum[pos] = iff(newSession, hl2 * tick_volume[pos], vwapsum[pos + 1] + hl2 * tick_volume[pos]);
      volumesum[pos] = iff(newSession, tick_volume[pos], volumesum[pos + 1] + tick_volume[pos]);
      v2sum[pos] = iff(newSession, tick_volume[pos] * hl2 * hl2, v2sum[pos + 1] + tick_volume[pos] * hl2 * hl2);
      double myvwap = vwapsum[pos] / volumesum[pos];
      double dev = MathSqrt(MathMax(v2sum[pos] / volumesum[pos] - myvwap * myvwap, 0));

      plot1[pos] = myvwap;
      plot2[pos] = myvwap + devUp1 * dev;
      plot3[pos] = myvwap - devDn1 * dev;
      plot4[pos] = showDv2 ? myvwap + devUp2 * dev : EMPTY_VALUE;
      plot5[pos] = showDv2 ? myvwap - devDn2 * dev : EMPTY_VALUE;
      plot6[pos] = showDv3 ? myvwap + devUp3 * dev : EMPTY_VALUE;
      plot7[pos] = showDv3 ? myvwap - devDn3 * dev : EMPTY_VALUE;
      prevwap[pos] = iff(newSession, volumesum[pos + 1] == 0 ? 0 : vwapsum[pos + 1] / volumesum[pos + 1], prevwap[pos + 1]);
      plot8[pos] = showPrevVWAP ? prevwap[pos] : EMPTY_VALUE;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
