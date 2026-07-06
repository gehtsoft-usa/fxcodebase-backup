// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68443

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
#property version   "1.1"
#property strict

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 3
#property indicator_color1 clrAqua
#property indicator_color2 clrNONE
#property indicator_color3 clrAqua

input ENUM_TIMEFRAMES TF = PERIOD_M1; // Timeframe
input int BandsPeriod = 20; // Bands period
input int BandsShift = 0; // Bands shift
input double BandsDeviations = 2; // Bands deviations

double Up[], Center[], Down[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int _handle;
void OnInit()
{
   _handle = iBands(_Symbol, TF, BandsPeriod, BandsShift, BandsDeviations, PRICE_CLOSE); 
   IndicatorName = GenerateIndicatorName("LTFBB");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, Up, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(1, Center, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(2, Down, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(_handle);
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
   if (prev_calculated == 0)
   {
      ArrayInitialize(Up, EMPTY_VALUE);
      ArrayInitialize(Down, EMPTY_VALUE);
      ArrayInitialize(Center, EMPTY_VALUE);
   }
   bool filled = false;
   for (int pos = MathMax(0, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int period = pos == rates_total - 1 ? 0 : iBarShift(NULL, TF, time[pos], true);
      if (period == -1)
         continue;
      double up[1];
      if (CopyBuffer(_handle, UPPER_BAND, period, 1, up) == 1)
      {
         Up[pos] = up[0];
         filled = true;
      }
      double down[1];
      if (CopyBuffer(_handle, LOWER_BAND, period, 1, down) == 1)
      {
         Down[pos] = down[0];
         filled = true;
      }
      double center[1];
      if (CopyBuffer(_handle, BASE_LINE, period, 1, center) == 1)
      {
         Center[pos] = center[0];
         filled = true;
      }
   }
   return filled ? rates_total : prev_calculated;
}

