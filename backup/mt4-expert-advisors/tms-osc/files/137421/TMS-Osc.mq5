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

#property strict
#property version    "1.600"
#property description "Oscillator for the 'Trading Made Simple' system."
#property description "Same as the TDI RSI Signal Line and Trade Signal Line."
#property description " "
#property description "Troubleshooting: Check the 'Journal' and 'Expert' tabs in the terminal window for errors."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 CLR_NONE
#property indicator_width1 1
#property indicator_color2 CLR_NONE
#property indicator_width2 1
#property indicator_color3 Red
#property indicator_width3 2
#property indicator_color4 Green
#property indicator_width4 2
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray

#define INDICATOR_NAME "TMS-Osc"

input int                RSI_Period=13;             
input ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE;     
input int                RSISignal_Period=2;        
input ENUM_MA_METHOD     RSISignal_Method=MODE_SMA;   
input int                TradeSignal_Period=7;      
input ENUM_MA_METHOD     TradeSignal_Method=MODE_SMA; 
input int                MarketBase_Period=34;      
input ENUM_MA_METHOD     MarketBase_Method=MODE_SMA;  

// Global module varables
double gadRSI[];
double gadRSISig[];
double gadTradeSig[];
double gadMktBase[];

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
int rsi, ma1, ma2, ma3;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("TMS-Osc");
   IndicatorSetString(INDICATOR_SHORTNAME, "TMS-Osc");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   SetIndexBuffer(0, gadRSI, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);

   SetIndexBuffer(1, gadMktBase, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(1, PLOT_LABEL, "Market Base");
   
   SetIndexBuffer(2, gadTradeSig, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "Trade Signal");

   SetIndexBuffer(3, gadRSISig, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(3, PLOT_LABEL, "RSI Signal");

   rsi = iRSI(_Symbol, _Period, RSI_Period, RSI_Price);
   ma1 = iMA(_Symbol, _Period, RSISignal_Period, 0, RSISignal_Method, rsi);
   ma2 = iMA(_Symbol, _Period, TradeSignal_Period, 0, TradeSignal_Method, rsi);
   ma3 = iMA(_Symbol, _Period, MarketBase_Period, 0, MarketBase_Method, rsi);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(rsi);
   IndicatorRelease(ma1);
   IndicatorRelease(ma2);
   IndicatorRelease(ma3);
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
      ArrayInitialize(gadRSI, EMPTY_VALUE);
      ArrayInitialize(gadMktBase, EMPTY_VALUE);
      ArrayInitialize(gadTradeSig, EMPTY_VALUE);
      ArrayInitialize(gadRSISig, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double buffer[1];
      if (CopyBuffer(rsi, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      gadRSI[pos] = buffer[0];
      if (CopyBuffer(ma1, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      gadRSISig[pos] = buffer[0];
      if (CopyBuffer(ma2, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      gadTradeSig[pos] = buffer[0];
      if (CopyBuffer(ma3, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      gadMktBase[pos] = buffer[0];
   }
   return rates_total;
}


