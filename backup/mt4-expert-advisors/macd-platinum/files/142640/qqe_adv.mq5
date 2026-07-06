// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71305

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

#property indicator_buffers 6
#property indicator_plots 2

#property indicator_color1 Navy
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_color2 Navy
#property indicator_style2 STYLE_DOT

input int SF = 1;      //5;
input int RSI_Period = 8;     //14;
input int DARFACTOR=3; //4.236;

int Wilders_Period;
int StartBar;

double TrLevelSlow[];
double AtrRsi[];
double MaAtrRsi[];
double Rsi[];
double RsiMa[];

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
   Wilders_Period = RSI_Period * 2 - 1;
   if (Wilders_Period < SF)
      StartBar = SF;
   else
      StartBar = Wilders_Period;

   IndicatorObjPrefix = GenerateIndicatorPrefix("qqe_adv");
   IndicatorSetString(INDICATOR_SHORTNAME, "QQE Adv");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, RsiMa, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, TrLevelSlow, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, AtrRsi, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, MaAtrRsi, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, Rsi, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   rsi_i = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
   rsi_ma_i = iMA(_Symbol, _Period, SF, 0, MODE_EMA, rsi_i);
}

int rsi_i, rsi_ma_i;

void OnDeinit(const int reason)
{
   IndicatorRelease(rsi_i);
   IndicatorRelease(rsi_ma_i);
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
      ArrayInitialize(RsiMa, EMPTY_VALUE);
      ArrayInitialize(TrLevelSlow, EMPTY_VALUE);
      ArrayInitialize(AtrRsi, EMPTY_VALUE);
      ArrayInitialize(MaAtrRsi, EMPTY_VALUE);
      ArrayInitialize(Rsi, EMPTY_VALUE);
   }
   int first = StartBar;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double buffer[1];
      if (CopyBuffer(rsi_i, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      Rsi[pos] = buffer[0];
      if (CopyBuffer(rsi_ma_i, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      RsiMa[pos] = buffer[0];
      AtrRsi[pos] = MathAbs(RsiMa[pos - 1] - RsiMa[pos]);
   }
   MAOnArray(rates_total, prev_calculated, StartBar, MODE_EMA, Wilders_Period, AtrRsi, MaAtrRsi);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {      
      double tr = TrLevelSlow[pos];
      double dar = RsiMa[pos] * DARFACTOR;

      double dv = tr;
      if (Rsi[pos] < tr)
      {
         tr = Rsi[pos] + dar;
         if (Rsi[pos - 1] < dv)
               if (tr > dv)
                  tr = dv;
      }
      else if (Rsi[pos] > tr)
      {
         tr = Rsi[pos] - dar;
         if (Rsi[pos - 1] > dv)
               if (tr < dv)
                  tr = dv;
      }
      TrLevelSlow[pos] = tr;
   }
   return rates_total;
}

