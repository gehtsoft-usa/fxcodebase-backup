// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=142879


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_separate_window
#property indicator_minimum - 100
#property indicator_maximum 100

#property indicator_buffers 5
#property indicator_plots 1
#property indicator_color1 Green

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#property indicator_level1 40
#property indicator_level2 - 40

extern int Period1 = 6;

double VZO[];
double VPA[];
double VA[];
double VP[];
double VOL[];

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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("VZO");
   IndicatorSetString(INDICATOR_SHORTNAME, "VZO");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, VZO, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id++, VPA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, VA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, VP, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, VOL, INDICATOR_CALCULATIONS);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

#include <MovingAverages.mqh>
void MAOnArray(const int rates_total, const int prev_calculated, int sourceFirst, ENUM_MA_METHOD method, int period, double& in[], double& out[])
{
   if (period == 1)
   {
      for (int pos = sourceFirst; pos < rates_total; ++pos)
      {
         out[pos] = in[pos];
      }
      return;
   }
   int weightsum;
   switch (method)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out, weightsum);
         break;
   }
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
      ArrayInitialize(VZO, EMPTY_VALUE);
      ArrayInitialize(VPA, EMPTY_VALUE);
      ArrayInitialize(VA, EMPTY_VALUE);
      ArrayInitialize(VP, EMPTY_VALUE);
      ArrayInitialize(VOL, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      VOL[pos] = tick_volume[pos];
      if (close[pos] > close[pos - 1])
      {
         VP[pos] = tick_volume[pos];
      }
      else
      {
         VP[pos] = -tick_volume[pos];
      }
   }

   MAOnArray(rates_total, prev_calculated, rates_total - bars_limit + Period1 + 1, 1, Period1, VP, VPA);
   MAOnArray(rates_total, prev_calculated, rates_total - bars_limit + Period1 + 1, 1, Period1, VOL, VA);
   
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      if (VA[pos] != 0)
         VZO[pos] = (VPA[pos] / VA[pos]) * 100;
   }
   return rates_total;
}
