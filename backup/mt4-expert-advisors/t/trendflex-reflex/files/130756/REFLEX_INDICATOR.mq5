// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69323

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

input int Length = 20; // Length

double a1, b1, c2, c3, c1;
double Oscillator[], Filt[], Slope[], MS[];

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 1

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

void OnInit()
{
   IndicatorName = GenerateIndicatorName("Reflex Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   a1 = MathExp(-1.414*3.14159 / (.5*Length));
	b1 = 2*a1*MathCos(1.414*180 / (.5*Length));
	c2 = b1;
	c3 = -a1*a1;
	c1 = 1 - c2 - c3;

   int id = 0;
   SetIndexBuffer(id + 0, Oscillator, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   SetIndexBuffer(1, Filt, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, Slope, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, MS, INDICATOR_CALCULATIONS);
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
      ArrayInitialize(Filt, EMPTY_VALUE);
      ArrayInitialize(Slope, EMPTY_VALUE);
      ArrayInitialize(MS, EMPTY_VALUE);
      ArrayInitialize(Oscillator, EMPTY_VALUE);
   }
   for (int i = MathMax(2, prev_calculated); i < rates_total; ++i)
   {
      double c2Val = Filt[i - 1] == EMPTY_VALUE ? 0 : c2 * Filt[i - 1];
      double c3Val = Filt[i - 2] == EMPTY_VALUE ? 0 : c3 * Filt[i - 2];
      Filt[i] = c1 * (close[i] + close[i - 1]) / 2 + c2Val + c3Val;
      if (i - Length < 2 || Filt[i - Length] == EMPTY_VALUE)
      {
         continue;
      }
      Slope[i] = (Filt[i - Length] - Filt[i]) / Length;
      double Sum = 0;
      for (int count = 1; count <= Length; count++)
      {
         Sum += (Filt[i] + count * Slope[i]) - Filt[i - count];
      }
      Sum = Sum / Length;
      
      MS[i] = .04 * Sum * Sum + (MS[i - 1] == EMPTY_VALUE ? 0 : .96 * MS[i - 1]);
      if (MS[i] != 0)
         Oscillator[i] = Sum / MathSqrt(MS[i]);
      else
         Oscillator[i] = 0;
   }
   return rates_total;
}