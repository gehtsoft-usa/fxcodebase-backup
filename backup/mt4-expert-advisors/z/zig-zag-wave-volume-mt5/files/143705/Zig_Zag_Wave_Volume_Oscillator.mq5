// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68835

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
#property version   "1.2"

#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 Green
#property indicator_color2 Red

input int      ExtDepth=12;
input int      ExtDeviation=5;
input int      ExtBackstep=3;
input bool cumulative = true; // Cumulative volume (true) or average (false)
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double zzUp[], zzDown[], zz[], count[];
int zigzag_handle;

int OnInit()
{
   IndicatorName = GenerateIndicatorName("Zig Zag Wave Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   zigzag_handle = iCustom(_Symbol, _Period, "Examples\\ZigZag", ExtDepth, ExtDeviation, ExtBackstep);
   if (zigzag_handle == -1)
   {
      zigzag_handle = iCustom(_Symbol, _Period, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep);
      if (zigzag_handle == -1)
      {
         Alert("Please, install the 'ZigZag' indicator");
         return INIT_FAILED;
      }
   }
   int id = 0;
   SetIndexBuffer(id + 0, zzUp, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetDouble(id + 0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   ++id;
   
   SetIndexBuffer(id + 0, zzDown, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetDouble(id + 0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(id + 1, PLOT_DRAW_TYPE, DRAW_NONE);
   SetIndexBuffer(id + 1, zz);

   PlotIndexSetInteger(id + 2, PLOT_DRAW_TYPE, DRAW_NONE);
   SetIndexBuffer(id + 2, count);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(zigzag_handle);
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
   int last_zz_pos = -1;
   if (prev_calculated == 0)
   {
      ArrayInitialize(zzUp, EMPTY_VALUE);
      ArrayInitialize(count, EMPTY_VALUE);
   }
   else
   {
      for (int pos = prev_calculated - 1; pos >= 0; --pos)
      {
         if (zz[pos] != EMPTY_VALUE)
         {
            last_zz_pos = pos;
            break;
         }
      }
   }
   
   for (int pos = prev_calculated - 1; pos < rates_total; ++pos)
   {
      double buffer[1];
      if (CopyBuffer(zigzag_handle, 0, rates_total - pos - 1, 1, buffer) == 1)
      {
         if (buffer[0] > 0 || pos == 0)
         {
            zz[pos] = buffer[0];
            if (last_zz_pos != -1)
            {
               zzDown[pos] = EMPTY_VALUE;
               zzUp[pos] = EMPTY_VALUE;
               if (zz[last_zz_pos] < zz[pos])
                  zzDown[pos] = (double)tick_volume[pos];
               else
                  zzUp[pos] = (double)tick_volume[pos];
               count[pos] = 1;
            }
            last_zz_pos = pos;
         }
         else
         {
            zzDown[pos] = EMPTY_VALUE;
            zzUp[pos] = EMPTY_VALUE;
            if (cumulative)
            {
               count[pos] = 1;
            }
            else
            {
               count[pos] = count[pos - 1] + 1;
            }
            if (zzUp[pos - 1] != EMPTY_VALUE)
            {
               zzUp[pos] = (zzUp[pos - 1] + tick_volume[pos]) / count[pos];
            }
            else
            {
               zzDown[pos] = (zzDown[pos - 1] + tick_volume[pos]) / count[pos];
            }
         }
      }
   }
   return rates_total;
}