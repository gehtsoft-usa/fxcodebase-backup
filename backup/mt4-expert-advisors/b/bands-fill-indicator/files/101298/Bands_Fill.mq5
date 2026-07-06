// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=62403


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
#property version   "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 4
#property indicator_type1  DRAW_LINE
#property indicator_color1 Blue
#property indicator_label1 "Top"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Blue
#property indicator_label2 "Bottom"
#property indicator_type3  DRAW_LINE
#property indicator_color3 Blue
#property indicator_label3 "Middle"
#property indicator_type4  DRAW_COLOR_HISTOGRAM2
#property indicator_color4 Green,Red,Yellow

input int bb_period = 20; // BB length
input double bb_deviation = 2; // BB deviation
input int bb_shift = 0; // BB shift
input ENUM_APPLIED_PRICE bb_price = PRICE_CLOSE; // BB Price type
input int bars_limit = 1000; // Bars limit

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

double top[], bottom[], middle[], clr[], histu[], histd[];
int indi;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("bf");
   IndicatorSetString(INDICATOR_SHORTNAME, "bf");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   indi = iBands(_Symbol, _Period, bb_period, bb_shift, bb_deviation, bb_price);

   int id = 0;
   SetIndexBuffer(id, top, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, bottom, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, middle, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, histu, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, histd, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, clr, INDICATOR_COLOR_INDEX);
   ++id;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(indi);
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
      ArrayInitialize(top, EMPTY_VALUE);
      ArrayInitialize(bottom, EMPTY_VALUE);
      ArrayInitialize(middle, EMPTY_VALUE);
      ArrayInitialize(clr, 0);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double buffer[1];
      if (CopyBuffer(indi, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      top[pos] = buffer[0];
      if (CopyBuffer(indi, 1, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      bottom[pos] = buffer[0];
      middle[pos] = (top[pos] + bottom[pos]) / 2;
      histu[pos] = top[pos];
      histd[pos] = bottom[pos];
      if (clr[pos - 1] == 0 && close[pos] < middle[pos])
         clr[pos] = 2;
      else if (clr[pos - 1] == 1 && close[pos] > middle[pos])
         clr[pos] = 0;
      if (close[pos] >= top[pos])
         clr[pos] = 0;
      else if (close[pos] <= bottom[pos])
         clr[pos] = 1;
   }
   return rates_total;
}