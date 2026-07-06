// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69107

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
#property indicator_color1 Green
#property indicator_color2 Red

input string cog_section = ""; // == Center Of Gravity Oscillator Calculation ==
input int FIR_N = 10; // FIR (LWMA) number of periods
input int S_N = 3; // Signal Line Smoothing Periods

input string dps_section = ""; // == Dinapoli Preferred Stochastic Calculation ==
input int K = 10; // Number of periods for %K
input int SD = 5; // %D slowing periods
input int D = 5; // Number of periods for %D

input string cci_ma_section = ""; // == CCI MA Difference ==
input int CCI_Period = 14; // CCI Period
input int MA_Period = 14; // MA Period
input ENUM_MA_METHOD MA_Method = MODE_EMA; // Smoothing method
input int ema_Period = 14; // EMA Period

input string kri_section = ""; // KRI
input int KRI_period = 10; // Period
input int KRI_ema_period = 10; // EMA Period

input int bar_limit = 1000; // Bars limit

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double up[], down[], cci[], kri[];

int init()
{
   IndicatorName = GenerateIndicatorName("Modified Dinapoli Preferred Stochastic Center Of Gravity Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, up);
   SetIndexLabel(0, "Up");

   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, down);
   SetIndexLabel(1, "Down");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, cci);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, kri);

   double temp = iCustom(NULL, 0, "JECOG", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'JECOG' indicator");
      return INIT_FAILED;
   }

   temp = iCustom(NULL, 0, "Dinapoli_Preferred_Stochastic", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Dinapoli_Preferred_Stochastic' indicator");
      return INIT_FAILED;
   }

   temp = iCustom(NULL, 0, "CCI_MA_Difference", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'CCI MA Difference' indicator");
      return INIT_FAILED;
   }

   temp = iCustom(NULL, 0, "KRI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'KRI' indicator");
      return INIT_FAILED;
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(bar_limit, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      up[i] = EMPTY_VALUE;
      down[i] = EMPTY_VALUE;
      double jecog0 = iCustom(_Symbol, _Period, "JECOG", FIR_N, S_N, 0, i);
      double jecog1 = iCustom(_Symbol, _Period, "JECOG", FIR_N, S_N, 1, i);
      double k = iCustom(_Symbol, _Period, "Dinapoli_Preferred_Stochastic", K, SD, D, 0, i);
      double d = iCustom(_Symbol, _Period, "Dinapoli_Preferred_Stochastic", K, SD, D, 1, i);
      cci[i] = iCustom(_Symbol, _Period, "CCI_MA_Difference", CCI_Period, MA_Period, MA_Method, 0, i);
      double cci_ema = iMAOnArray(cci, 0, ema_Period, 0, MODE_EMA, i);
      kri[i] = iCustom(_Symbol, _Period, "KRI", KRI_period, 0, i);
      double kri_ema = iMAOnArray(kri, 0, KRI_ema_period, 0, MODE_EMA, i);
      if (jecog0 > jecog1 && k > d && cci[i] > cci_ema && kri[i] > kri_ema)
      {
         up[i] = 1;
      }
      else if (jecog0 < jecog1 && k < d && cci[i] < cci_ema && kri[i] < kri_ema)
      {
         down[i] = -1;
      }
   }
   return 0;
}
