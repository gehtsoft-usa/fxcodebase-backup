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
#property indicator_buffers 15
#property indicator_plots 8
#property indicator_color1 Green
#property indicator_color2 LimeGreen
#property indicator_color3 Red
#property indicator_color4 FireBrick
#property indicator_color5 RoyalBlue
#property indicator_color6 IndianRed
#property indicator_color7 Turquoise
#property indicator_color8 OrangeRed

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_DOT
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
#property indicator_style8 STYLE_SOLID

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width6 2
#property indicator_width7 1
#property indicator_width8 1

//---- input parameters
input int  Fast = 12;
input int  Slow = 26;
input int  Smooth = 9;
input bool ZeroLag = true;
input color MacdColor = RoyalBlue;
input color AvgColor = IndianRed;
input color UpwardsAboveZeroColor = Green;
input color UpwardsBelowZeroColor = LimeGreen;
input color DownwardsAboveZeroColor = Red;
input color DownwardsBelowZeroColor = FireBrick;
input color MarkerColorUp = Turquoise;
input color MarkerColorDown = OrangeRed;

// ADDITIONAL TOOL FOR RENKO, RANGE ETC OFFLINE CHARTS ########################################################
 bool OfflineChart = false;
 
//---- buffers
double HistUpAbove[];      // = 0
double HistDnAbove[];      // = 1
double HistUpBelow[];      // = 2
double HistDnBelow[];      // = 3
double Macd[];             // = 4
double Avg[];              // = 5
double MarkersUp[];        // = 6
double MarkersDown[];      // = 7

// series arrays
double fastEma[];
double slowEma[];
double Diff[];
double avgEma[];   
double fastEmaEma[];
double slowEmaEma[];
double avgEmaEma[];

// various globals
int   Multiplier = 10;   // forex multiplier from Ninja version
int   LatestBarComplete = 0;  // remembers the latest bar processed.

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
   IndicatorObjPrefix = GenerateIndicatorPrefix("macdp");
   IndicatorSetString(INDICATOR_SHORTNAME, "MACD Platinum");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, HistUpAbove, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, UpwardsAboveZeroColor);
   ++id;

   SetIndexBuffer(id, HistDnAbove, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, DownwardsAboveZeroColor);
   ++id;

   SetIndexBuffer(id, HistUpBelow, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, UpwardsBelowZeroColor);
   ++id;

   SetIndexBuffer(id, HistDnBelow, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, DownwardsBelowZeroColor);
   ++id;

   SetIndexBuffer(id, Macd, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, MacdColor);
   ++id;

   SetIndexBuffer(id, Avg, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AvgColor);
   ++id;

   SetIndexBuffer(id, MarkersUp, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 108);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, MarkerColorUp);
   ++id;

   SetIndexBuffer(id, MarkersDown, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 108);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, MarkerColorDown);
   ++id;

   SetIndexBuffer(id++, fastEma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, slowEma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Diff, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, avgEma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, fastEmaEma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, slowEmaEma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, avgEmaEma, INDICATOR_CALCULATIONS);
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
      ArrayInitialize(HistUpAbove, EMPTY_VALUE);
      ArrayInitialize(HistDnAbove, EMPTY_VALUE);
      ArrayInitialize(HistUpBelow, EMPTY_VALUE);
      ArrayInitialize(HistDnBelow, EMPTY_VALUE);
      ArrayInitialize(Macd, EMPTY_VALUE);
      ArrayInitialize(Avg, EMPTY_VALUE);
      ArrayInitialize(MarkersUp, EMPTY_VALUE);
      ArrayInitialize(MarkersDown, EMPTY_VALUE);
   }
   int first = 2;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double macd = 0;
      double macdAvg = 0;
      
      if (!ZeroLag)
      {
         fastEma[pos] = ((2.0 / (1 + Fast)) * (Multiplier * close[pos]) + (1 - (2.0 / (1 + Fast))) * fastEma[pos - 1]);
         slowEma[pos] = ((2.0 / (1 + Slow)) * (Multiplier * close[pos]) + (1 - (2.0 / (1 + Slow))) * slowEma[pos - 1]);
         macd		= fastEma[pos] - slowEma[pos];
         macdAvg	= (2.0 / (1 + Smooth)) * macd + (1 - (2.0 / (1 + Smooth))) * Avg[pos - 1];
         Macd[pos] = (macd);
         Avg[pos] = (macdAvg);
         Diff[pos] = (macd - macdAvg);
      }
      else
      {	
         fastEma[pos] = ((2.0 / (1 + Fast)) * (Multiplier*close[pos]) + (1 - (2.0 / (1 + Fast))) * fastEma[pos - 1]);
         slowEma[pos] = ((2.0 / (1 + Slow)) * (Multiplier*close[pos]) + (1 - (2.0 / (1 + Slow))) * slowEma[pos - 1]);
         fastEmaEma[pos] = (2.0 / (1 + Fast)) * fastEma[pos] + (1 - (2.0 / (1 + Fast))) * fastEmaEma[pos - 1];
         slowEmaEma[pos] = (2.0 / (1 + Slow)) * slowEma[pos] + (1 - (2.0 / (1 + Slow))) * slowEmaEma[pos - 1];
         double differenceFast = fastEma[pos] - fastEmaEma[pos];
         double differenceSlow = slowEma[pos] - slowEmaEma[pos];
         macd = ((fastEma[pos]+differenceFast) - (slowEma[pos]+differenceSlow));
         Macd[pos] = (macd);
         avgEma[pos] = (2.0 / (1 + Smooth)) * Macd[pos]   + (1 - (2.0 / (1 + Smooth))) * avgEma[pos - 1];
         avgEmaEma[pos] = (2.0 / (1 + Smooth)) * avgEma[pos] + (1 - (2.0 / (1 + Smooth))) * avgEmaEma[pos - 1];
         double differenceAvg = avgEma[pos] - avgEmaEma[pos];
         macdAvg = avgEma[pos] + differenceAvg;
         Avg[pos] = (macdAvg);
         Diff[pos] = (macd-macdAvg);
      }
   }
   
   return rates_total;
}
