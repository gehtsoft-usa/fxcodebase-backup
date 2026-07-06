// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68983

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
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 Red
#property indicator_color2 Green

input int Period = 20; // Period
input int Predict = 3; // Predict
input double Bandwidth = 0.25; // Bandwidth

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double Filt[], Voss[];
void OnInit()
{
   IndicatorName = GenerateIndicatorName("Voss Predictive Filter");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id + 0, Filt, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);

   ++id;
   SetIndexBuffer(id + 0, Voss, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

#define Pi 3.14159265358979323846
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
   double F1 = MathCos(2 * Pi / Period);
   double G1 = MathCos(Bandwidth * 2 * Pi / Period);
   double S1 = 1.0 / G1 - MathSqrt(1.0 / (G1 * G1) - 1);
   int Order = 3 * Predict;
   if (prev_calculated == 0)
   {
      ArrayInitialize(Voss, EMPTY_VALUE);
      ArrayInitialize(Filt, EMPTY_VALUE);
   }

   for (int pos = MathMax(Order, MathMax(0, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      if (Filt[pos - 2] != EMPTY_VALUE)
         Filt[pos] = 0.5 * (1 - S1) * (close[pos] - close[pos - 2]) + F1 * (1 + S1) * Filt[pos - 1] - S1 * Filt[pos - 2];
      else if (Filt[pos - 1] != EMPTY_VALUE)
         Filt[pos] = 0.5 * (1 - S1) * (close[pos] - close[pos - 2]) + F1 * (1 + S1) * Filt[pos - 1];
      else
         Filt[pos] = 0.5 * (1 - S1) * (close[pos] - close[pos - 2]);
      double SumC = 0;
      for (int count = 0; count <= Order - 1; count++)
      {
         if (Voss[pos - Order + count] != EMPTY_VALUE)
            SumC += ((count + 1) / Order) * Voss[pos - Order + count];
      }

      Voss[pos] = ((3 + Order) / 2) * Filt[pos] - SumC;
   }
   return rates_total;
}
