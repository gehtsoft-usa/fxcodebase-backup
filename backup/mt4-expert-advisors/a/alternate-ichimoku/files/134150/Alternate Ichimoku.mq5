// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69891

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

input int SSP = 75; // Period Priority Line
input int SSK = 75; // Tolerance Second Line
input bool M = false; // Additional Lines

#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_type1  DRAW_FILLING
#property indicator_color1 Red,Blue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "SA"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Blue
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "SB"
#property indicator_type3  DRAW_LINE
#property indicator_color3 C'255,255,0'
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID
#property indicator_label3 "SL"
#property indicator_type4  DRAW_LINE
#property indicator_color4 C'0,255,255'
#property indicator_width4 1
#property indicator_style4 STYLE_SOLID
#property indicator_label4 "ML"
#property indicator_type5  DRAW_LINE
#property indicator_color5 C'0,255,0'
#property indicator_width5 1
#property indicator_style5 STYLE_SOLID
#property indicator_label5 "CS"

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

double SA[], SB[], SL[], ML[], CS[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("aich");
   IndicatorSetString(INDICATOR_SHORTNAME, "Alternate Ichimoku");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, SA, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, SB, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, SL, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, ML, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, CS, INDICATOR_DATA);
   ++id;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(SA, EMPTY_VALUE);
      ArrayInitialize(SB, EMPTY_VALUE);
      ArrayInitialize(SL, EMPTY_VALUE);
      ArrayInitialize(ML, EMPTY_VALUE);
      ArrayInitialize(CS, EMPTY_VALUE);
   }
   int first = SSK + SSP;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int highestIndex = ArrayMaximum(high, pos, SSP);
      double SsMax = high[highestIndex];
      int lowestIndex = ArrayMinimum(low, pos, SSP);
      double SsMin = low[lowestIndex];
      highestIndex = ArrayMaximum(high, pos - SSK, SSP);
      double SsMax05 = high[highestIndex];
      lowestIndex = ArrayMinimum(low, pos - SSK, SSP);
      double SsMin05 = low[lowestIndex];
      
      SA[pos] = (SsMax + SsMin) / 2;
      SB[pos] = (SsMax05 + SsMin05) / 2;
      highestIndex = ArrayMaximum(high, pos, (int)(SSP * 1.62));
      double Tsmax = high[highestIndex];
      lowestIndex = ArrayMinimum(low, pos, (int)(SSP * 1.62));
      double Tsmin = low[lowestIndex];
      SL[pos] = (Tsmax + Tsmin) / 2;
      ML[pos] = ((SsMax + SsMin) / 2 + (SsMax05 + SsMin05) / 2) / 2;
      CS[pos - SSP] = close[pos];
   }
   return rates_total;
}