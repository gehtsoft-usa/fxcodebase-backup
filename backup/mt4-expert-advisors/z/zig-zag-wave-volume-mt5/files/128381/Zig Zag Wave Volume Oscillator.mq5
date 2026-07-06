// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68835

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_color1 Green
#property indicator_color2 Red

input int      ExtDepth=12;
input int      ExtDeviation=5;
input int      ExtBackstep=3;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double zzUp[], zzDown[], zz[];
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
      ArrayInitialize(zzUp, EMPTY_VALUE);
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
               if (zz[last_zz_pos] > zz[pos])
                  zzDown[pos] = (double)tick_volume[pos];
               else
                  zzUp[pos] = (double)tick_volume[pos];
            }
            last_zz_pos = pos;
         }
         else
         {
            zzDown[pos] = EMPTY_VALUE;
            zzUp[pos] = EMPTY_VALUE;
            if (zzUp[pos - 1] != EMPTY_VALUE)
               zzUp[pos] = zzUp[pos - 1] + tick_volume[pos];
            else
               zzDown[pos] = zzDown[pos - 1] + tick_volume[pos];
         }
      }
   }
   return rates_total;
}