//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75513

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property strict

#property indicator_separate_window
#property indicator_buffers 51
#property indicator_plots 24
#property indicator_label1 "Wave Trend - Positive Pressure"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Wave Trend - Negative Pressure"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "All 3 Trend Meters Now Align"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "All 3 Trend Meters Now Align"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "All 3 Trend Meters Now Align"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type7 DRAW_ARROW
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type8 DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Trend Meter 1"
#property indicator_type9 DRAW_ARROW
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Trend Meter 1"
#property indicator_type10 DRAW_ARROW
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Trend Meter 1"
#property indicator_type11 DRAW_ARROW
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Trend Meter 2"
#property indicator_type12 DRAW_ARROW
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "Trend Meter 2"
#property indicator_type13 DRAW_ARROW
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Trend Meter 2"
#property indicator_type14 DRAW_ARROW
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "Trend Meter 3"
#property indicator_type15 DRAW_ARROW
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "Trend Meter 3"
#property indicator_type16 DRAW_ARROW
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_label17 "Trend Meter 3"
#property indicator_type17 DRAW_ARROW
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_label18 "Trend Bar 1 - Thin Line"
#property indicator_type18 DRAW_COLOR_LINE
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1
#property indicator_label19 "Trend Bar 1 - Thick Line"
#property indicator_type19 DRAW_COLOR_LINE
#property indicator_style19 STYLE_SOLID
#property indicator_width19 1
#property indicator_label20 "Trend Bar 2 - Thin Line"
#property indicator_type20 DRAW_COLOR_LINE
#property indicator_style20 STYLE_SOLID
#property indicator_width20 1
#property indicator_label21 "Trend Bar 2 - Thick Line"
#property indicator_type21 DRAW_COLOR_LINE
#property indicator_style21 STYLE_SOLID
#property indicator_width21 1
#property indicator_type22 DRAW_LINE
#property indicator_style22 STYLE_SOLID
#property indicator_width22 1
#property indicator_type23 DRAW_LINE
#property indicator_style23 STYLE_SOLID
#property indicator_width23 1
#property indicator_type24 DRAW_FILLING
#property indicator_width24 1

#include <Streams/Custom/FloatStream.mqh>
#include <Streams/Oscillators/RSIStream.mqh>
#include <SafeMath.mqh>
#include <Streams/Averages/EMAOnStream.mqh>
#include <Streams/Averages/SMAOnStream.mqh>
#include <Streams/Condition/CrossStreamV2.mqh>
#include <PineScriptUtils.mqh>
#include <Streams/StDevStream.mqh>
#include <Streams/Oscillators/CorrelationStream.mqh>
#include <Signaler.mqh>
#include <Streams/Plots/ColoredPlot.mqh>
#include <Streams/ColoredFill.mqh>
input bool param1 = true; // Pos / Neg Pressure
input bool param2 = true; // Trend Meter Signal
input bool param3 = true; // Wave Trend Cross Aligns with Trend Meter Signal
input string param4 = "MACD Crossover - Fast - 8, 21, 5"; // Trend Meter 1
input string param5 = "RSI 13: > or < 50"; // Trend Meter 2
input string param6 = "RSI 5: > or < 50"; // Trend Meter 3
input bool param7 = true; // Trend Bar 1
input bool param8 = true; // Trend Bar 2
input string param9 = "MA Crossover"; // 
input string param10 = "MA Crossover"; // 
input int param11 = 5; // Fast MA
input string param12 = "EMA"; // 
input int param13 = 11; // Slow MA
input string param14 = "EMA"; // 
input int param15 = 13; // Fast MA
input string param16 = "EMA"; // 
input int param17 = 36; // Slow MA
input string param18 = "SMA"; // 
input int bars_limit = 1000; // Bars limit
Signaler* _signaler;
int PosNegPressure;
int TMSetups;
int TMSetupsANDWT;
string TrendBar1;
string TrendBar2;
string TrendBar3;
FloatStream* rsi1X;
RSIStream* rsi1;
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* cross1X;
FloatStream* cross1Y;
IBoolStream* cross1;
int ShowTrendBar1;
int ShowTrendBar2;
string TrendBar4;
string TrendBar5;
int MA1_Length;
string MA1_Type;
int MA2_Length;
string MA2_Type;
int MA3_Length;
string MA3_Type;
int MA4_Length;
string MA4_Type;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* ema4Source;
EMAOnStream* ema4;
FloatStream* sma3Source;
SmaOnStream* sma3;
FloatStream* ema5Source;
EMAOnStream* ema5;
FloatStream* sma4Source;
SmaOnStream* sma4;
FloatStream* ema6Source;
EMAOnStream* ema6;
FloatStream* sma5Source;
SmaOnStream* sma5;
FloatStream* ema7Source;
EMAOnStream* ema7;
double MA1[];
double MA1_DEFAULT_VALUE;
double MA2[];
double MA2_DEFAULT_VALUE;
double MA3[];
double MA3_DEFAULT_VALUE;
double MA4[];
double MA4_DEFAULT_VALUE;
double MA1Direction[];
double MA1Direction_DEFAULT_VALUE;
double MA2Direction[];
double MA2Direction_DEFAULT_VALUE;
double MA3Direction[];
double MA3Direction_DEFAULT_VALUE;
double MA4Direction[];
double MA4Direction_DEFAULT_VALUE;
FloatStream* ema8Source;
EMAOnStream* ema8;
FloatStream* ema9Source;
EMAOnStream* ema9;
FloatStream* ema10Source;
EMAOnStream* ema10;
FloatStream* ema11Source;
EMAOnStream* ema11;
FloatStream* ema12Source;
EMAOnStream* ema12;
FloatStream* ema13Source;
EMAOnStream* ema13;
FloatStream* ema14Source;
EMAOnStream* ema14;
FloatStream* ema15Source;
EMAOnStream* ema15;
FloatStream* ema16Source;
EMAOnStream* ema16;
double TopDogDad[];
double TopDogDad_DEFAULT_VALUE;
double haopen[];
double haopen_DEFAULT_VALUE;
double haclose[];
double haclose_DEFAULT_VALUE;
double ccolor[];
double ccolor_DEFAULT_VALUE;
FloatStream* rsi2X;
RSIStream* rsi2;
FloatStream* rsi3X;
RSIStream* rsi3;
FloatStream* sma6Source;
SmaOnStream* sma6;
FloatStream* sma7Source;
SmaOnStream* sma7;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* stdev2Source;
StDevStream* stdev2;
FloatStream* correlation1Source1;
FloatStream* correlation1Source2;
CorrelationStream* correlation1;
double LinReg1[];
double LinReg1_DEFAULT_VALUE;
double TrendBars3Positive[];
double TrendBars3Positive_DEFAULT_VALUE;
double TrendBars3Negative[];
double TrendBars3Negative_DEFAULT_VALUE;
double YellowWave[];
double YellowWave_DEFAULT_VALUE;
FloatStream* rsi4X;
RSIStream* rsi4;
double RSI14OB[];
double RSI14OB_DEFAULT_VALUE;
double RSI14OS[];
double RSI14OS_DEFAULT_VALUE;
double plot1[];
double plot2[];
double plot3_clr1[];
double plot3_clr2[];
double plot3_clr3[];
double Setplot3(int pos, double value, color clr)
{
   if (clr == 0x758a28) { plot3_clr1[pos] = value; return plot3_clr1[pos]; }
   else if (clr == Red) { plot3_clr2[pos] = value; return plot3_clr2[pos]; }
   else if (clr == INT_MIN) { plot3_clr3[pos] = value; return plot3_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot6_clr1[];
double plot6_clr2[];
double plot6_clr3[];
double Setplot6(int pos, double value, color clr)
{
   if (clr == 0x758a28) { plot6_clr1[pos] = value; return plot6_clr1[pos]; }
   else if (clr == Red) { plot6_clr2[pos] = value; return plot6_clr2[pos]; }
   else if (clr == INT_MIN) { plot6_clr3[pos] = value; return plot6_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot9_clr1[];
double plot9_clr2[];
double plot9_clr3[];
double Setplot9(int pos, double value, color clr)
{
   if (clr == INT_MIN) { plot9_clr1[pos] = value; return plot9_clr1[pos]; }
   else if (clr == 0x758a28) { plot9_clr2[pos] = value; return plot9_clr2[pos]; }
   else if (clr == Red) { plot9_clr3[pos] = value; return plot9_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot12_clr1[];
double plot12_clr2[];
double plot12_clr3[];
double Setplot12(int pos, double value, color clr)
{
   if (clr == INT_MIN) { plot12_clr1[pos] = value; return plot12_clr1[pos]; }
   else if (clr == 0x758a28) { plot12_clr2[pos] = value; return plot12_clr2[pos]; }
   else if (clr == Red) { plot12_clr3[pos] = value; return plot12_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot15_clr1[];
double plot15_clr2[];
double plot15_clr3[];
double Setplot15(int pos, double value, color clr)
{
   if (clr == INT_MIN) { plot15_clr1[pos] = value; return plot15_clr1[pos]; }
   else if (clr == 0x758a28) { plot15_clr2[pos] = value; return plot15_clr2[pos]; }
   else if (clr == Red) { plot15_clr3[pos] = value; return plot15_clr3[pos]; }
   return EMPTY_VALUE;
}
ColoredPlot* plot18;
ColoredPlot* plot19;
ColoredPlot* plot20;
ColoredPlot* plot21;
double plot22[];
double plot23[];
ColoredFill* fill24;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* ema17Source;
EMAOnStream* ema17;
FloatStream* ema18Source;
EMAOnStream* ema18;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* ema19Source;
EMAOnStream* ema19;
FloatStream* ema20Source;
EMAOnStream* ema20;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;
FloatStream* crossover3X;
FloatStream* crossover3Y;
IBoolStream* crossover3;
FloatStream* crossunder3X;
FloatStream* crossunder3Y;
IBoolStream* crossunder3;

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
   int id = 0;
   PosNegPressure = param1;
   TMSetups = param2;
   TMSetupsANDWT = param3;
   TrendBar1 = param4;
   TrendBar2 = param5;
   TrendBar3 = param6;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, 14);
   int n1 = 9;
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, n1);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, n1);
   int n2 = 12;
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, n2);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, 3);
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   ShowTrendBar1 = param7;
   ShowTrendBar2 = param8;
   TrendBar4 = param9;
   TrendBar5 = param10;
   MA1_Length = param11;
   MA1_Type = param12;
   MA2_Length = param13;
   MA2_Type = param14;
   MA3_Length = param15;
   MA3_Type = param16;
   MA4_Length = param17;
   MA4_Type = param18;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, MA1_Length);
   ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, MA1_Length);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, MA2_Length);
   ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, MA2_Length);
   sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, MA3_Length);
   ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema6 = new EMAOnStream(ema6Source, MA3_Length);
   sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma5 = new SmaOnStream(sma5Source, MA4_Length);
   ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema7 = new EMAOnStream(ema7Source, MA4_Length);
   int MACDfastMA = 12;
   ema8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema8 = new EMAOnStream(ema8Source, MACDfastMA);
   int MACDslowMA = 26;
   ema9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema9 = new EMAOnStream(ema9Source, MACDslowMA);
   int MACDsignalSmooth = 9;
   ema10Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema10 = new EMAOnStream(ema10Source, MACDsignalSmooth);
   int FastMACDfastMA = 8;
   ema11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema11 = new EMAOnStream(ema11Source, FastMACDfastMA);
   int FastMACDslowMA = 21;
   ema12Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema12 = new EMAOnStream(ema12Source, FastMACDslowMA);
   int FastMACDsignalSmooth = 5;
   ema13Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema13 = new EMAOnStream(ema13Source, FastMACDsignalSmooth);
   int TopDog_Fast_MA = 5;
   ema14Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema14 = new EMAOnStream(ema14Source, TopDog_Fast_MA);
   int TopDog_Slow_MA = 20;
   ema15Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema15 = new EMAOnStream(ema15Source, TopDog_Slow_MA);
   int TopDog_Sig = 30;
   ema16Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema16 = new EMAOnStream(ema16Source, TopDog_Sig);
   rsi2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi2 = new RSIStream(rsi2X, 5);
   rsi3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi3 = new RSIStream(rsi3X, 13);
   int SignalLineLength1 = 21;
   sma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma6 = new SmaOnStream(sma6Source, SignalLineLength1);
   sma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma7 = new SmaOnStream(sma7Source, SignalLineLength1);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, SignalLineLength1);
   stdev2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev2 = new StDevStream(stdev2Source, SignalLineLength1);
   correlation1Source1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   correlation1Source2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   correlation1 = new CorrelationStream(correlation1Source1, correlation1Source2, SignalLineLength1);
   rsi4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi4 = new RSIStream(rsi4X, 14);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_ARROW, 161);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, AddTransparency(0x758a28, 25));
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 161);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, AddTransparency(0x3C14DC, 32));
   ++id;
   SetIndexBuffer(id, plot3_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, 0x758a28);
   PlotIndexSetInteger(3, PLOT_ARROW, 161);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot3_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(4, PLOT_ARROW, 161);
   PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot3_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, INT_MIN);
   PlotIndexSetInteger(5, PLOT_ARROW, 161);
   PlotIndexSetInteger(5, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot6_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, 0x758a28);
   PlotIndexSetInteger(6, PLOT_ARROW, 253);
   PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot6_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(7, PLOT_ARROW, 253);
   PlotIndexSetInteger(7, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot6_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, INT_MIN);
   PlotIndexSetInteger(8, PLOT_ARROW, 253);
   PlotIndexSetInteger(8, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot9_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, INT_MIN);
   PlotIndexSetInteger(9, PLOT_ARROW, 161);
   PlotIndexSetInteger(9, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot9_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(10, PLOT_LINE_COLOR, 0x758a28);
   PlotIndexSetInteger(10, PLOT_ARROW, 161);
   PlotIndexSetInteger(10, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot9_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(11, PLOT_ARROW, 161);
   PlotIndexSetInteger(11, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot12_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, INT_MIN);
   PlotIndexSetInteger(12, PLOT_ARROW, 161);
   PlotIndexSetInteger(12, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot12_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, 0x758a28);
   PlotIndexSetInteger(13, PLOT_ARROW, 161);
   PlotIndexSetInteger(13, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot12_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(14, PLOT_ARROW, 161);
   PlotIndexSetInteger(14, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot15_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(15, PLOT_LINE_COLOR, INT_MIN);
   PlotIndexSetInteger(15, PLOT_ARROW, 161);
   PlotIndexSetInteger(15, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot15_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(16, PLOT_LINE_COLOR, 0x758a28);
   PlotIndexSetInteger(16, PLOT_ARROW, 161);
   PlotIndexSetInteger(16, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot15_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(17, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(17, PLOT_ARROW, 161);
   PlotIndexSetInteger(17, PLOT_ARROW_SHIFT, 5);
   ++id;
   plot18 = new ColoredPlot(17);
   plot18.AddColor(INT_MIN);
   plot18.AddColor(AddTransparency(Green, 15));
   plot18.AddColor(AddTransparency(Red, 20));
   plot18.SetOffset(0);
   id = plot18.RegisterStreams(id);
   plot19 = new ColoredPlot(18);
   plot19.AddColor(INT_MIN);
   plot19.AddColor(AddTransparency(Green, 15));
   plot19.AddColor(AddTransparency(Red, 20));
   plot19.SetOffset(0);
   id = plot19.RegisterStreams(id);
   plot20 = new ColoredPlot(19);
   plot20.AddColor(INT_MIN);
   plot20.AddColor(AddTransparency(Green, 15));
   plot20.AddColor(AddTransparency(Red, 20));
   plot20.SetOffset(0);
   id = plot20.RegisterStreams(id);
   plot21 = new ColoredPlot(20);
   plot21.AddColor(INT_MIN);
   plot21.AddColor(AddTransparency(Green, 15));
   plot21.AddColor(AddTransparency(Red, 20));
   plot21.SetOffset(0);
   id = plot21.RegisterStreams(id);
   SetIndexBuffer(id, plot22, INDICATOR_DATA);
   PlotIndexSetInteger(22, PLOT_LINE_COLOR, AddTransparency(White, 100));
   PlotIndexSetInteger(22, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(22, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   SetIndexBuffer(id, plot23, INDICATOR_DATA);
   PlotIndexSetInteger(23, PLOT_LINE_COLOR, AddTransparency(White, 100));
   PlotIndexSetInteger(23, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(23, PLOT_LINE_STYLE, STYLE_SOLID);
   ++id;
   fill24 = new ColoredFill(23);
   fill24.AddColor(Green);
   fill24.AddColor(Red);
   fill24.AddColor(INT_MIN);
   id = fill24.RegisterStreams(id);
   ema17Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema17 = new EMAOnStream(ema17Source, 5);
   ema18Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema18 = new EMAOnStream(ema18Source, 11);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   ema19Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema19 = new EMAOnStream(ema19Source, 5);
   ema20Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema20 = new EMAOnStream(ema20Source, 11);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   crossover3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3 = CrossStreamFactory::CreateCrossover(crossover3X, crossover3Y);
   crossunder3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3 = CrossStreamFactory::CreateCrossunder(crossunder3X, crossunder3Y);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trend Meter");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, MA1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA4, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA1Direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA2Direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA3Direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, MA4Direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, TopDogDad, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, haopen, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, haclose, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, ccolor, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, LinReg1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, TrendBars3Positive, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, TrendBars3Negative, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, YellowWave, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, RSI14OB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, RSI14OS, INDICATOR_CALCULATIONS);
   id = plot18.RegisterInternalStreams(id);
   id = plot19.RegisterInternalStreams(id);
   id = plot20.RegisterInternalStreams(id);
   id = plot21.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   rsi1X.Release();
   rsi1.Release();
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   sma1Source.Release();
   sma1.Release();
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   sma2Source.Release();
   sma2.Release();
   ema4Source.Release();
   ema4.Release();
   sma3Source.Release();
   sma3.Release();
   ema5Source.Release();
   ema5.Release();
   sma4Source.Release();
   sma4.Release();
   ema6Source.Release();
   ema6.Release();
   sma5Source.Release();
   sma5.Release();
   ema7Source.Release();
   ema7.Release();
   ema8Source.Release();
   ema8.Release();
   ema9Source.Release();
   ema9.Release();
   ema10Source.Release();
   ema10.Release();
   ema11Source.Release();
   ema11.Release();
   ema12Source.Release();
   ema12.Release();
   ema13Source.Release();
   ema13.Release();
   ema14Source.Release();
   ema14.Release();
   ema15Source.Release();
   ema15.Release();
   ema16Source.Release();
   ema16.Release();
   rsi2X.Release();
   rsi2.Release();
   rsi3X.Release();
   rsi3.Release();
   sma6Source.Release();
   sma6.Release();
   sma7Source.Release();
   sma7.Release();
   stdev1Source.Release();
   stdev1.Release();
   stdev2Source.Release();
   stdev2.Release();
   correlation1Source1.Release();
   correlation1Source2.Release();
   correlation1.Release();
   rsi4X.Release();
   rsi4.Release();
   delete plot18;
   delete plot19;
   delete plot20;
   delete plot21;
   delete fill24;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   ema17Source.Release();
   ema17.Release();
   ema18Source.Release();
   ema18.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   ema19Source.Release();
   ema19.Release();
   ema20Source.Release();
   ema20.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   crossover3X.Release();
   crossover3Y.Release();
   crossover3.Release();
   crossunder3X.Release();
   crossunder3Y.Release();
   crossunder3.Release();
   delete _signaler;
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
      rsi1X.Init();
      ema1Source.Init();
      ema2Source.Init();
      ema3Source.Init();
      sma1Source.Init();
      cross1X.Init();
      cross1Y.Init();
      sma2Source.Init();
      ema4Source.Init();
      sma3Source.Init();
      ema5Source.Init();
      sma4Source.Init();
      ema6Source.Init();
      sma5Source.Init();
      ema7Source.Init();
      MA1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA1, MA1_DEFAULT_VALUE);
      MA2_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA2, MA2_DEFAULT_VALUE);
      MA3_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA3, MA3_DEFAULT_VALUE);
      MA4_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA4, MA4_DEFAULT_VALUE);
      MA1Direction_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA1Direction, MA1Direction_DEFAULT_VALUE);
      MA2Direction_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA2Direction, MA2Direction_DEFAULT_VALUE);
      MA3Direction_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA3Direction, MA3Direction_DEFAULT_VALUE);
      MA4Direction_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(MA4Direction, MA4Direction_DEFAULT_VALUE);
      ema8Source.Init();
      ema9Source.Init();
      ema10Source.Init();
      ema11Source.Init();
      ema12Source.Init();
      ema13Source.Init();
      ema14Source.Init();
      ema15Source.Init();
      ema16Source.Init();
      TopDogDad_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(TopDogDad, TopDogDad_DEFAULT_VALUE);
      haopen_DEFAULT_VALUE = 0.0;
      ArrayInitialize(haopen, haopen_DEFAULT_VALUE);
      haclose_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(haclose, haclose_DEFAULT_VALUE);
      ccolor_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(ccolor, ccolor_DEFAULT_VALUE);
      rsi2X.Init();
      rsi3X.Init();
      sma6Source.Init();
      sma7Source.Init();
      stdev1Source.Init();
      stdev2Source.Init();
      correlation1Source1.Init();
      correlation1Source2.Init();
      LinReg1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(LinReg1, LinReg1_DEFAULT_VALUE);
      TrendBars3Positive_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(TrendBars3Positive, TrendBars3Positive_DEFAULT_VALUE);
      TrendBars3Negative_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(TrendBars3Negative, TrendBars3Negative_DEFAULT_VALUE);
      YellowWave_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(YellowWave, YellowWave_DEFAULT_VALUE);
      rsi4X.Init();
      RSI14OB_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(RSI14OB, RSI14OB_DEFAULT_VALUE);
      RSI14OS_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(RSI14OS, RSI14OS_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3_clr1, EMPTY_VALUE);
      ArrayInitialize(plot3_clr2, EMPTY_VALUE);
      ArrayInitialize(plot3_clr3, EMPTY_VALUE);
      ArrayInitialize(plot6_clr1, EMPTY_VALUE);
      ArrayInitialize(plot6_clr2, EMPTY_VALUE);
      ArrayInitialize(plot6_clr3, EMPTY_VALUE);
      ArrayInitialize(plot9_clr1, EMPTY_VALUE);
      ArrayInitialize(plot9_clr2, EMPTY_VALUE);
      ArrayInitialize(plot9_clr3, EMPTY_VALUE);
      ArrayInitialize(plot12_clr1, EMPTY_VALUE);
      ArrayInitialize(plot12_clr2, EMPTY_VALUE);
      ArrayInitialize(plot12_clr3, EMPTY_VALUE);
      ArrayInitialize(plot15_clr1, EMPTY_VALUE);
      ArrayInitialize(plot15_clr2, EMPTY_VALUE);
      ArrayInitialize(plot15_clr3, EMPTY_VALUE);
      plot18.Init();
      plot19.Init();
      plot20.Init();
      plot21.Init();
      ArrayInitialize(plot22, 113.7);
      ArrayInitialize(plot23, 131.3);
      fill24.Init();
      ema17Source.Init();
      ema18Source.Init();
      crossover1X.Init();
      crossover1Y.Init();
      ema19Source.Init();
      ema20Source.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
      crossover3X.Init();
      crossover3Y.Init();
      crossunder3X.Init();
      crossunder3Y.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      rsi1X.SetValue(pos, close[pos]);
      double rsi1Value[1];
      if (!rsi1.GetValues(pos, 1, rsi1Value)) { rsi1Value[0] = EMPTY_VALUE; }
      double RSIMC = rsi1Value[0];
      double ap = SafeDivide((high[pos] + low[pos] + close[pos]), 3);
      int n1 = 9;
      int n2 = 12;
      ema1Source.SetValue(pos, ap);
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
      double esa = ema1Value[0];
      ema2Source.SetValue(pos, SafeMathAbs(SafeMinus(ap, esa)));
      double ema2Value[1];
      if (!ema2.GetValues(pos, 1, ema2Value)) { ema2Value[0] = EMPTY_VALUE; }
      double de = ema2Value[0];
      double ci = SafeDivide((SafeMinus(ap, esa)), (SafeMultiply(0.015, de)));
      ema3Source.SetValue(pos, ci);
      double ema3Value[1];
      if (!ema3.GetValues(pos, 1, ema3Value)) { ema3Value[0] = EMPTY_VALUE; }
      double tci = ema3Value[0];
      double wt1 = tci;
      sma1Source.SetValue(pos, wt1);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      double wt2 = sma1Value[0];
      SetStream(YellowWave, pos, SafeMinus(wt1, wt2), YellowWave_DEFAULT_VALUE);
      int obLevel2 = 60;
      int obLevel = 50;
      int osLevel = (-50);
      int osLevel2 = (-60);
      cross1X.SetValue(pos, wt1);
      cross1Y.SetValue(pos, wt2);
      int cross1Value[1];
      if (!cross1.GetValues(pos, 1, cross1Value)) { cross1Value[0] = (-1); }
      int WTCross = cross1Value[0];
      int WTCrossUp = SafeLE(SafeMinus(wt2, wt1), 0);
      int WTCrossDown = SafeGE(SafeMinus(wt2, wt1), 0);
      int WTOverSold = SafeLE(wt2, osLevel2);
      int WTOverBought = SafeGE(wt2, obLevel2);
      double Close = close[pos];
      if ((MA1_Type == "SMA"))
      {
         sma2Source.SetValue(pos, Close);
         double sma2Value[1];
         if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
         SetStream(MA1, pos, sma2Value[0], MA1_DEFAULT_VALUE);
      }
      else
      {
         ema4Source.SetValue(pos, Close);
         double ema4Value[1];
         if (!ema4.GetValues(pos, 1, ema4Value)) { ema4Value[0] = EMPTY_VALUE; }
         SetStream(MA1, pos, ema4Value[0], MA1_DEFAULT_VALUE);
      }
      if ((MA2_Type == "SMA"))
      {
         sma3Source.SetValue(pos, Close);
         double sma3Value[1];
         if (!sma3.GetValues(pos, 1, sma3Value)) { sma3Value[0] = EMPTY_VALUE; }
         SetStream(MA2, pos, sma3Value[0], MA2_DEFAULT_VALUE);
      }
      else
      {
         ema5Source.SetValue(pos, Close);
         double ema5Value[1];
         if (!ema5.GetValues(pos, 1, ema5Value)) { ema5Value[0] = EMPTY_VALUE; }
         SetStream(MA2, pos, ema5Value[0], MA2_DEFAULT_VALUE);
      }
      if ((MA3_Type == "SMA"))
      {
         sma4Source.SetValue(pos, Close);
         double sma4Value[1];
         if (!sma4.GetValues(pos, 1, sma4Value)) { sma4Value[0] = EMPTY_VALUE; }
         SetStream(MA3, pos, sma4Value[0], MA3_DEFAULT_VALUE);
      }
      else
      {
         ema6Source.SetValue(pos, Close);
         double ema6Value[1];
         if (!ema6.GetValues(pos, 1, ema6Value)) { ema6Value[0] = EMPTY_VALUE; }
         SetStream(MA3, pos, ema6Value[0], MA3_DEFAULT_VALUE);
      }
      if ((MA4_Type == "SMA"))
      {
         sma5Source.SetValue(pos, Close);
         double sma5Value[1];
         if (!sma5.GetValues(pos, 1, sma5Value)) { sma5Value[0] = EMPTY_VALUE; }
         SetStream(MA4, pos, sma5Value[0], MA4_DEFAULT_VALUE);
      }
      else
      {
         ema7Source.SetValue(pos, Close);
         double ema7Value[1];
         if (!ema7.GetValues(pos, 1, ema7Value)) { ema7Value[0] = EMPTY_VALUE; }
         SetStream(MA4, pos, ema7Value[0], MA4_DEFAULT_VALUE);
      }
      int MACrossover1 = (SafeGreater(MA1[pos], MA2[pos]) ? 1 : 0);
      int MACrossover2 = (SafeGreater(MA3[pos], MA4[pos]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      SetStream(MA1Direction, pos, (SafeGreater(MA1[pos], MA1[pos - 1]) ? 1 : 0), MA1Direction_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(MA2Direction, pos, (SafeGreater(MA2[pos], MA2[pos - 1]) ? 1 : 0), MA2Direction_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(MA3Direction, pos, (SafeGreater(MA3[pos], MA3[pos - 1]) ? 1 : 0), MA3Direction_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(MA4Direction, pos, (SafeGreater(MA4[pos], MA4[pos - 1]) ? 1 : 0), MA4Direction_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      int MA1PositiveDirectionChange = (NumberToBool(MA1Direction[pos]) && !NumberToBool(MA1Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA2PositiveDirectionChange = (NumberToBool(MA2Direction[pos]) && !NumberToBool(MA2Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA3PositiveDirectionChange = (NumberToBool(MA3Direction[pos]) && !NumberToBool(MA3Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA4PositiveDirectionChange = (NumberToBool(MA4Direction[pos]) && !NumberToBool(MA4Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA1NegativeDirectionChange = (!NumberToBool(MA1Direction[pos]) && NumberToBool(MA1Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA2NegativeDirectionChange = (!NumberToBool(MA2Direction[pos]) && NumberToBool(MA2Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA3NegativeDirectionChange = (!NumberToBool(MA3Direction[pos]) && NumberToBool(MA3Direction[pos - 1]) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int MA4NegativeDirectionChange = (!NumberToBool(MA4Direction[pos]) && NumberToBool(MA4Direction[pos - 1]) ? 1 : 0);
      int MACDfastMA = 12;
      int MACDslowMA = 26;
      int MACDsignalSmooth = 9;
      ema8Source.SetValue(pos, close[pos]);
      double ema8Value[1];
      if (!ema8.GetValues(pos, 1, ema8Value)) { ema8Value[0] = EMPTY_VALUE; }
      ema9Source.SetValue(pos, close[pos]);
      double ema9Value[1];
      if (!ema9.GetValues(pos, 1, ema9Value)) { ema9Value[0] = EMPTY_VALUE; }
      double MACDLine = SafeMinus(ema8Value[0], ema9Value[0]);
      ema10Source.SetValue(pos, MACDLine);
      double ema10Value[1];
      if (!ema10.GetValues(pos, 1, ema10Value)) { ema10Value[0] = EMPTY_VALUE; }
      double SignalLine = ema10Value[0];
      double MACDHistogram = SafeMinus(MACDLine, SignalLine);
      int MACDHistogramCross = (SafeGreater(MACDHistogram, 0) ? 1 : 0);
      int MACDLineOverZero = (SafeGreater(MACDLine, 0) ? 1 : 0);
      int MACDLineOverZeroandHistogramCross = (NumberToBool(MACDHistogramCross) && NumberToBool(MACDLineOverZero) ? 1 : 0);
      int MACDLineUnderZeroandHistogramCross = (!NumberToBool(MACDHistogramCross) && !NumberToBool(MACDLineOverZero) ? 1 : 0);
      int FastMACDfastMA = 8;
      int FastMACDslowMA = 21;
      int FastMACDsignalSmooth = 5;
      ema11Source.SetValue(pos, close[pos]);
      double ema11Value[1];
      if (!ema11.GetValues(pos, 1, ema11Value)) { ema11Value[0] = EMPTY_VALUE; }
      ema12Source.SetValue(pos, close[pos]);
      double ema12Value[1];
      if (!ema12.GetValues(pos, 1, ema12Value)) { ema12Value[0] = EMPTY_VALUE; }
      double FastMACDLine = SafeMinus(ema11Value[0], ema12Value[0]);
      ema13Source.SetValue(pos, FastMACDLine);
      double ema13Value[1];
      if (!ema13.GetValues(pos, 1, ema13Value)) { ema13Value[0] = EMPTY_VALUE; }
      double FastSignalLine = ema13Value[0];
      double FastMACDHistogram = SafeMinus(FastMACDLine, FastSignalLine);
      int FastMACDHistogramCross = (SafeGreater(FastMACDHistogram, 0) ? 1 : 0);
      int FastMACDLineOverZero = (SafeGreater(FastMACDLine, 0) ? 1 : 0);
      int FastMACDLineOverZeroandHistogramCross = (NumberToBool(FastMACDHistogramCross) && NumberToBool(FastMACDLineOverZero) ? 1 : 0);
      int FastMACDLineUnderZeroandHistogramCross = (!NumberToBool(FastMACDHistogramCross) && !NumberToBool(FastMACDLineOverZero) ? 1 : 0);
      int TopDog_Fast_MA = 5;
      int TopDog_Slow_MA = 20;
      int TopDog_Sig = 30;
      ema14Source.SetValue(pos, close[pos]);
      double ema14Value[1];
      if (!ema14.GetValues(pos, 1, ema14Value)) { ema14Value[0] = EMPTY_VALUE; }
      ema15Source.SetValue(pos, close[pos]);
      double ema15Value[1];
      if (!ema15.GetValues(pos, 1, ema15Value)) { ema15Value[0] = EMPTY_VALUE; }
      double TopDogMom = SafeMinus(ema14Value[0], ema15Value[0]);
      ema16Source.SetValue(pos, TopDogMom);
      double ema16Value[1];
      if (!ema16.GetValues(pos, 1, ema16Value)) { ema16Value[0] = EMPTY_VALUE; }
      SetStream(TopDogDad, pos, ema16Value[0], TopDogDad_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      int TopDogDadDirection = (SafeGreater(TopDogDad[pos], TopDogDad[pos - 1]) ? 1 : 0);
      int TopDogMomOverDad = (SafeGreater(TopDogMom, TopDogDad[pos]) ? 1 : 0);
      int TopDogMomOverZero = (SafeGreater(TopDogMom, 0) ? 1 : 0);
      int TopDogDadDirectandMomOverZero = (NumberToBool(TopDogDadDirection) && NumberToBool(TopDogMomOverZero) ? 1 : 0);
      int TopDogDadDirectandMomUnderZero = (!NumberToBool(TopDogDadDirection) && !NumberToBool(TopDogMomOverZero) ? 1 : 0);
      SetStream(haclose, pos, SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4), haclose_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      SetStream(haopen, pos, (((haopen[pos - 1]) == EMPTY_VALUE) ? SafeDivide((open[pos] + close[pos]), 2) : SafeDivide((SafePlus(haopen[pos - 1], haclose[pos - 1])), 2)), haopen_DEFAULT_VALUE);
      SetStream(ccolor, pos, ((haclose[pos] - haopen[pos] > 0) ? 1 : 0), ccolor_DEFAULT_VALUE);
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      if (pos - 6 < 0) { continue; }
      int inside6 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 6], haclose[pos - 6])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 6], haclose[pos - 6])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 6], haclose[pos - 6])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 6], haclose[pos - 6])) ? 1 : 0);
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      int inside5 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 5], haclose[pos - 5])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 5], haclose[pos - 5])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 5], haclose[pos - 5])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 5], haclose[pos - 5])) ? 1 : 0);
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      int inside4 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 4], haclose[pos - 4])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 4], haclose[pos - 4])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 4], haclose[pos - 4])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 4], haclose[pos - 4])) ? 1 : 0);
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      int inside3 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 3], haclose[pos - 3])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 3], haclose[pos - 3])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 3], haclose[pos - 3])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 3], haclose[pos - 3])) ? 1 : 0);
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      int inside2 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 2], haclose[pos - 2])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 2], haclose[pos - 2])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 2], haclose[pos - 2])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 2], haclose[pos - 2])) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      int inside1 = (SafeLE(haopen[pos], SafeMathMax(haopen[pos - 1], haclose[pos - 1])) && SafeGE(haopen[pos], SafeMathMin(haopen[pos - 1], haclose[pos - 1])) && SafeLE(haclose[pos], SafeMathMax(haopen[pos - 1], haclose[pos - 1])) && SafeGE(haclose[pos], SafeMathMin(haopen[pos - 1], haclose[pos - 1])) ? 1 : 0);
      if (pos - 6 < 0) { continue; }
      if (pos - 5 < 0) { continue; }
      if (pos - 4 < 0) { continue; }
      if (pos - 3 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      int colorvalue = (NumberToBool(inside6) ? ccolor[pos - 6] : (NumberToBool(inside5) ? ccolor[pos - 5] : (NumberToBool(inside4) ? ccolor[pos - 4] : (NumberToBool(inside3) ? ccolor[pos - 3] : (NumberToBool(inside2) ? ccolor[pos - 2] : (NumberToBool(inside1) ? ccolor[pos - 1] : ccolor[pos]))))));
      uint TrendBarTrend_Candle_Color = (NumberToBool(colorvalue) ? 0x758a28 : Red);
      int TrendBarTrend_Candle = (NumberToBool(colorvalue) ? 1 : 0);
      rsi2X.SetValue(pos, close[pos]);
      double rsi2Value[1];
      if (!rsi2.GetValues(pos, 1, rsi2Value)) { rsi2Value[0] = EMPTY_VALUE; }
      double RSI5 = rsi2Value[0];
      int RSI5Above50 = (SafeGreater(RSI5, 50) ? 1 : 0);
      uint RSI5Color = (NumberToBool(RSI5Above50) ? 0x758a28 : Red);
      uint TrendBarRSI5Color = (NumberToBool(RSI5Above50) ? 0x758a28 : Red);
      rsi3X.SetValue(pos, close[pos]);
      double rsi3Value[1];
      if (!rsi3.GetValues(pos, 1, rsi3Value)) { rsi3Value[0] = EMPTY_VALUE; }
      double RSI13 = rsi3Value[0];
      int SignalLineLength1 = 21;
      int x = pos;
      double y = RSI13;
      sma6Source.SetValue(pos, x);
      double sma6Value[1];
      if (!sma6.GetValues(pos, 1, sma6Value)) { sma6Value[0] = EMPTY_VALUE; }
      double x_ = sma6Value[0];
      sma7Source.SetValue(pos, y);
      double sma7Value[1];
      if (!sma7.GetValues(pos, 1, sma7Value)) { sma7Value[0] = EMPTY_VALUE; }
      double y_ = sma7Value[0];
      stdev1Source.SetValue(pos, x);
      double stdev1Value[1];
      if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
      double mx = stdev1Value[0];
      stdev2Source.SetValue(pos, y);
      double stdev2Value[1];
      if (!stdev2.GetValues(pos, 1, stdev2Value)) { stdev2Value[0] = EMPTY_VALUE; }
      double my = stdev2Value[0];
      correlation1Source1.SetValue(pos, x);
      correlation1Source2.SetValue(pos, y);
      double correlation1Value[1];
      if (!correlation1.GetValues(pos, 1, correlation1Value)) { correlation1Value[0] = EMPTY_VALUE; }
      double c = correlation1Value[0];
      double slope = SafeMultiply(c, (SafeDivide(my, mx)));
      double inter = SafeMinus(y_, SafeMultiply(slope, x_));
      SetStream(LinReg1, pos, SafePlus(SafeMultiply(x, slope), inter), LinReg1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      int RSISigDirection = (SafeGreater(LinReg1[pos], LinReg1[pos - 1]) ? 1 : 0);
      int RSISigCross = (SafeGreater(RSI13, LinReg1[pos]) ? 1 : 0);
      int RSI13Above50 = (SafeGreater(RSI13, 50) ? 1 : 0);
      uint RSI13Color = (NumberToBool(RSI13Above50) ? 0x758a28 : Red);
      uint TrendBarRSI13Color = (NumberToBool(RSI13Above50) ? 0x758a28 : Red);
      uint TrendBarRSISigCrossColor = (NumberToBool(RSISigCross) ? 0x758a28 : Red);
      uint TrendBarMACDColor = (NumberToBool(MACDHistogramCross) ? 0x758a28 : Red);
      uint TrendBarFastMACDColor = (NumberToBool(FastMACDHistogramCross) ? 0x758a28 : Red);
      uint TrendBarMACrossColor = (NumberToBool(MACrossover1) ? 0x758a28 : Red);
      uint TrendBarMomOverDadColor = (NumberToBool(TopDogMomOverDad) ? 0x758a28 : Red);
      uint TrendBarDadDirectionColor = (NumberToBool(TopDogDadDirection) ? 0x758a28 : Red);
      int TrendBar1Result = ((TrendBar1 == "MA Crossover") ? MACrossover1 : ((TrendBar1 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar1 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar1 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar1 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar1 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar1 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar1 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar1 == "Trend Candles") ? TrendBarTrend_Candle : INT_MIN)))))))));
      int TrendBar2Result = ((TrendBar2 == "MA Crossover") ? MACrossover1 : ((TrendBar2 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar2 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar2 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar2 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar2 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar2 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar2 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar2 == "Trend Candles") ? TrendBarTrend_Candle : INT_MIN)))))))));
      int TrendBar3Result = ((TrendBar3 == "MA Crossover") ? MACrossover1 : ((TrendBar3 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar3 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar3 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar3 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar3 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar3 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar3 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar3 == "Trend Candles") ? TrendBarTrend_Candle : INT_MIN)))))))));
      int TrendBars2Positive = (((NumberToBool(TrendBar1Result) && NumberToBool(TrendBar2Result) || NumberToBool(TrendBar1Result) && NumberToBool(TrendBar3Result)) || NumberToBool(TrendBar2Result) && NumberToBool(TrendBar3Result)) ? 1 : 0);
      int TrendBars2Negative = (((!NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar2Result) || !NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar3Result)) || !NumberToBool(TrendBar2Result) && !NumberToBool(TrendBar3Result)) ? 1 : 0);
      SetStream(TrendBars3Positive, pos, (NumberToBool(TrendBar1Result) && NumberToBool(TrendBar2Result) && NumberToBool(TrendBar3Result) ? 1 : 0), TrendBars3Positive_DEFAULT_VALUE);
      SetStream(TrendBars3Negative, pos, (!NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar2Result) && !NumberToBool(TrendBar3Result) ? 1 : 0), TrendBars3Negative_DEFAULT_VALUE);
      int PositiveWaveTrendCross = WTCross && WTCrossUp;
      int NegativeWaveTrendCross = WTCross && WTCrossDown;
      if (pos - 1 < 0) { continue; }
      int BackgroundColorChangePositive = NumberToBool(TrendBars3Positive[pos]) && !NumberToBool(TrendBars3Positive[pos - 1]);
      if (pos - 1 < 0) { continue; }
      int BackgroundColorChangeNegative = NumberToBool(TrendBars3Negative[pos]) && !NumberToBool(TrendBars3Negative[pos - 1]);
      uint MSBar2Color = (BackgroundColorChangePositive ? 0x758a28 : (BackgroundColorChangeNegative ? Red : INT_MIN));
      uint TrendBar1Color = ((TrendBar1 == "N/A") ? INT_MIN : ((TrendBar1 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar1 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar1 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar1 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar1 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar1 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar1 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar1 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar1 == "MA Crossover") ? TrendBarMACrossColor : INT_MIN))))))))));
      uint TrendBar2Color = ((TrendBar2 == "N/A") ? INT_MIN : ((TrendBar2 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar2 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar2 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar2 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar2 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar2 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar2 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar2 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar2 == "MA Crossover") ? TrendBarMACrossColor : INT_MIN))))))))));
      uint TrendBar3Color = ((TrendBar3 == "N/A") ? INT_MIN : ((TrendBar3 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar3 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar3 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar3 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar3 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar3 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar3 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar3 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar3 == "MA Crossover") ? TrendBarMACrossColor : INT_MIN))))))))));
      int CrossoverType2 = ((TrendBar4 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar4 == "MACD Crossover") ? MACDHistogramCross : ((TrendBar4 == "MA Direction - Fast MA - TB1") ? MA1Direction[pos] : ((TrendBar4 == "MA Direction - Slow MA - TB1") ? MA2Direction[pos] : MACrossover1))));
      uint color_1 = AddTransparency(Green, 15);
      uint color_2 = AddTransparency(Red, 20);
      uint TrendBar4Color1 = ((TrendBar4 == "N/A") ? INT_MIN : (NumberToBool(CrossoverType2) ? color_1 : color_2));
      int CrossoverType3 = ((TrendBar5 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar5 == "MACD Crossover") ? MACDHistogramCross : ((TrendBar5 == "MA Direction - Fast MA - TB2") ? MA3Direction[pos] : ((TrendBar5 == "MA Direction - Slow MA - TB2") ? MA4Direction[pos] : MACrossover2))));
      uint color_3 = AddTransparency(Green, 15);
      uint color_4 = AddTransparency(Red, 20);
      uint TrendBar5Color1 = ((TrendBar5 == "N/A") ? INT_MIN : (NumberToBool(CrossoverType3) ? color_3 : color_4));
      int WTVOB = SafeGreater(wt1, 60);
      int WTVOS = SafeLess(wt1, (-60));
      if (pos - 1 < 0) { continue; }
      int YellowWavePointingUp = SafeGreater(YellowWave[pos], YellowWave[pos - 1]);
      rsi4X.SetValue(pos, close[pos]);
      double rsi4Value[1];
      if (!rsi4.GetValues(pos, 1, rsi4Value)) { rsi4Value[0] = EMPTY_VALUE; }
      double RSI14 = rsi4Value[0];
      SetStream(RSI14OB, pos, (SafeGreater(RSI14, 70) ? 1 : 0), RSI14OB_DEFAULT_VALUE);
      SetStream(RSI14OS, pos, (SafeLess(RSI14, 30) ? 1 : 0), RSI14OS_DEFAULT_VALUE);
      int RSI14OBOS = ((NumberToBool(RSI14OB[pos]) || NumberToBool(RSI14OS[pos])) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      int OBIndicatorsYellowPointingDown = ((NumberToBool(RSI14OB[pos]) || NumberToBool(RSI14OB[pos - 1]))) && WTVOB && !YellowWavePointingUp;
      if (pos - 1 < 0) { continue; }
      int OSIndicatorsYellowPointingUp = ((NumberToBool(RSI14OS[pos]) || NumberToBool(RSI14OS[pos - 1]))) && WTVOS && YellowWavePointingUp;
      uint plot1_color = AddTransparency(0x758a28, 25);
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = (PosNegPressure && OSIndicatorsYellowPointingUp ? 138.5 : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      uint plot2_color = AddTransparency(0x3C14DC, 32);
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = (PosNegPressure && OBIndicatorsYellowPointingDown ? 138.5 : EMPTY_VALUE); }
      else { plot2[pos] = EMPTY_VALUE; }
      if ((OBIndicatorsYellowPointingDown || OSIndicatorsYellowPointingUp)) { _signaler.SendNotifications(" -   Pos / Neg Pressure", "Pos / Neg Pressure - Trend Meter"); }
      double plot3Value = Setplot3(pos, (TMSetups ? 134.5 : EMPTY_VALUE), MSBar2Color);
      double plot6Value = Setplot6(pos, (TMSetupsANDWT && (((PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) || (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])))) ? 134.5 : EMPTY_VALUE), MSBar2Color);
      double plot9Value = Setplot9(pos, 128.5, TrendBar1Color);
      double plot12Value = Setplot12(pos, 122.5, TrendBar2Color);
      double plot15Value = Setplot15(pos, 116.5, TrendBar3Color);
      double plot18Value = plot18.Set(pos, (ShowTrendBar1 && ShowTrendBar2 ? 110 : EMPTY_VALUE), TrendBar4Color1);
      double plot19Value = plot19.Set(pos, (ShowTrendBar1 && !ShowTrendBar2 ? 110 : EMPTY_VALUE), TrendBar4Color1);
      double plot20Value = plot20.Set(pos, (ShowTrendBar2 && ShowTrendBar1 ? 104.5 : EMPTY_VALUE), TrendBar5Color1);
      double plot21Value = plot21.Set(pos, (ShowTrendBar2 && !ShowTrendBar1 ? 110 : EMPTY_VALUE), TrendBar5Color1);
      uint TrendBar3BarsSame = (NumberToBool(TrendBars3Positive[pos]) ? Green : (NumberToBool(TrendBars3Negative[pos]) ? Red : INT_MIN));
      double TMa = plot22[pos];
      double TMb = plot23[pos];
      double fill24_val1 = TMa;
      double fill24_val2 = TMb;
      fill24.Set(pos, fill24_val1, fill24_val2, TrendBar3BarsSame);
      if (BackgroundColorChangePositive) { _signaler.SendNotifications(" --  3 TMs Turn Green", "All 3 Trend Meters Turn  Green - Trend Meter"); }
      if (BackgroundColorChangeNegative) { _signaler.SendNotifications(" --  3 TMs Turn Red", "All 3 Trend Meters Turn  Red - Trend Meter"); }
      if ((BackgroundColorChangePositive || BackgroundColorChangeNegative)) { _signaler.SendNotifications(" -- 3 TMs Change to Same Color", "All 3 Trend Meters Change to Same Color - Trend Meter"); }
      if (PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("--- 3 TMs Turn Green & WaveTrend X", "Green - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("--- 3 TMs Turn Red & WaveTrend X", "Red - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (((PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) || (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("--- 3 TMs Change to Same Color & WT X", "Red / Green - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      int TrendMetersNoLongerAlign = ((((!NumberToBool(TrendBars3Positive[pos]) || !NumberToBool(TrendBars3Negative[pos]))) && NumberToBool(TrendBars3Positive[pos - 1])) || (((!NumberToBool(TrendBars3Positive[pos]) || !NumberToBool(TrendBars3Negative[pos]))) && NumberToBool(TrendBars3Negative[pos - 1])));
      if (TrendMetersNoLongerAlign) { _signaler.SendNotifications("---- 3 Trend Meters No Longer Align", "3 Trend Meters No Longer Align - Trend Meter"); }
      if (pos - 1 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      int RapidColorChangePositive = NumberToBool(TrendBars3Positive[pos]) && ((NumberToBool(TrendBars3Negative[pos - 1]) || NumberToBool(TrendBars3Negative[pos - 2])));
      if (pos - 1 < 0) { continue; }
      if (pos - 2 < 0) { continue; }
      int RapidColorChangeNegative = NumberToBool(TrendBars3Negative[pos]) && ((NumberToBool(TrendBars3Positive[pos - 1]) || NumberToBool(TrendBars3Positive[pos - 2])));
      if (RapidColorChangePositive) { _signaler.SendNotifications("All 3 TMs Rapid Change Red to Green", "All 3 Trend Meters Rapid Change Red to Green - Trend Meter"); }
      if (RapidColorChangeNegative) { _signaler.SendNotifications("All 3 TMs Rapid Change Green to Red", "All 3 Trend Meters Rapid Change Green to Red - Trend Meter"); }
      if ((RapidColorChangePositive || RapidColorChangeNegative)) { _signaler.SendNotifications("All 3 TMs Rapid Change to Same Color", "All 3 Trend Meters Rapid Change to Same Color - Trend Meter"); }
      ema17Source.SetValue(pos, Close);
      double ema17Value[1];
      if (!ema17.GetValues(pos, 1, ema17Value)) { ema17Value[0] = EMPTY_VALUE; }
      ema18Source.SetValue(pos, Close);
      double ema18Value[1];
      if (!ema18.GetValues(pos, 1, ema18Value)) { ema18Value[0] = EMPTY_VALUE; }
      crossover1X.SetValue(pos, ema17Value[0]);
      crossover1Y.SetValue(pos, ema18Value[0]);
      int crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = (-1); }
      int MaxValueMACrossUp = crossover1Value[0];
      ema19Source.SetValue(pos, Close);
      double ema19Value[1];
      if (!ema19.GetValues(pos, 1, ema19Value)) { ema19Value[0] = EMPTY_VALUE; }
      ema20Source.SetValue(pos, Close);
      double ema20Value[1];
      if (!ema20.GetValues(pos, 1, ema20Value)) { ema20Value[0] = EMPTY_VALUE; }
      crossunder1X.SetValue(pos, ema19Value[0]);
      crossunder1Y.SetValue(pos, ema20Value[0]);
      int crossunder1Value[1];
      if (!crossunder1.GetValues(pos, 1, crossunder1Value)) { crossunder1Value[0] = (-1); }
      int MaxValueMACrossDown = crossunder1Value[0];
      crossover2X.SetValue(pos, MA1[pos]);
      crossover2Y.SetValue(pos, MA2[pos]);
      int crossover2Value[1];
      if (!crossover2.GetValues(pos, 1, crossover2Value)) { crossover2Value[0] = (-1); }
      int TB1MACrossUp = crossover2Value[0];
      crossunder2X.SetValue(pos, MA1[pos]);
      crossunder2Y.SetValue(pos, MA2[pos]);
      int crossunder2Value[1];
      if (!crossunder2.GetValues(pos, 1, crossunder2Value)) { crossunder2Value[0] = (-1); }
      int TB1MACrossDown = crossunder2Value[0];
      if (TB1MACrossUp) { _signaler.SendNotifications("TB 1 Turns Green", "Trend Bar 1 - Turns Green - Trend Meter"); }
      if (TB1MACrossDown) { _signaler.SendNotifications("TB 1 Turns Red", "Trend Bar 1 - Turns Red - Trend Meter"); }
      if ((TB1MACrossUp || TB1MACrossDown)) { _signaler.SendNotifications("TB 1 Color Change", "Trend Bar 1 - Color Change - Trend Meter"); }
      crossover3X.SetValue(pos, MA3[pos]);
      crossover3Y.SetValue(pos, MA4[pos]);
      int crossover3Value[1];
      if (!crossover3.GetValues(pos, 1, crossover3Value)) { crossover3Value[0] = (-1); }
      int TB2MACrossUp = crossover3Value[0];
      crossunder3X.SetValue(pos, MA3[pos]);
      crossunder3Y.SetValue(pos, MA4[pos]);
      int crossunder3Value[1];
      if (!crossunder3.GetValues(pos, 1, crossunder3Value)) { crossunder3Value[0] = (-1); }
      int TB2MACrossDown = crossunder3Value[0];
      if (TB2MACrossUp) { _signaler.SendNotifications("TB 2 Turns Green", "Trend Bar 2 - Turns Green - Trend Meter"); }
      if (TB2MACrossDown) { _signaler.SendNotifications("TB 2 Turns Red", "Trend Bar 2 - Turns Red - Trend Meter"); }
      if ((TB2MACrossUp || TB2MACrossDown)) { _signaler.SendNotifications("TB 2 Color Change", "Trend Bar 2 - Color Change - Trend Meter"); }
      int TB1Green = SafeGreater(MA1[pos], MA2[pos]);
      int TB1Red = SafeLess(MA1[pos], MA2[pos]);
      int TB2Green = SafeGreater(MA3[pos], MA4[pos]);
      int TB2Red = SafeLess(MA3[pos], MA4[pos]);
      int TB12Green = TB1Green && TB2Green && ((TB1MACrossUp || TB2MACrossUp));
      int TB12Red = TB1Red && TB2Red && ((TB1MACrossDown || TB2MACrossDown));
      if (TB12Green) { _signaler.SendNotifications("TBs 1+2 Turn Green", "Trend Bars 1+2 - Turn Green - Trend Meter"); }
      if (TB12Red) { _signaler.SendNotifications("TBs 1+2 Turn Red", "Trend Bars 1+2 - Turn Red - Trend Meter"); }
      if ((TB12Green || TB12Red)) { _signaler.SendNotifications("TBs 1+2 Change to Same Color", "Trend Bars 1+2 - Change to Same Color - MAs Crossing - Trend Meter"); }
      if (TB12Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TBs 1+2 Turn Green with 3 TMs", "Trend Bars 1+2 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB12Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TBs 1+2 Turn Red with 3 TMs", "Trend Bars 1+2 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB12Green && NumberToBool(TrendBars3Positive[pos])) || (TB12Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TBs 1+2 Change to Same Color with 3 TMs", "Trend Bars 1+2 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (TB1Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TB 1 Turns Green with 3 TMs", "Trend Bar 1 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB1Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TB 1 Turns Red with 3 TMs", "Trend Bar 1 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB1Green && NumberToBool(TrendBars3Positive[pos])) || (TB1Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TB 1 Change to Same Color with 3 TMs", "Trend Bar 1 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (TB2Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TB 2 Turns Green with 3 TMs", "Trend Bar 2 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB2Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TB 2 Turns Red with 3 TMs", "Trend Bar 2 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB2Green && NumberToBool(TrendBars3Positive[pos])) || (TB2Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TB 2 Change to Same Color with 3 TMs", "Trend Bar 2 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (BackgroundColorChangePositive && TB1Green) { _signaler.SendNotifications("3 TMs Turn Green with TB 1", "All 3 Trend Meters Turn  Green with TB 1 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB1Red) { _signaler.SendNotifications("3 TMs Turn Red with TB 1", "All 3 Trend Meters Turn  Red with TB 1 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB1Green) || (BackgroundColorChangeNegative && TB1Red))) { _signaler.SendNotifications("3 TMs Change Color with TB 1", "All 3 Trend Meters Change Color with TB 1 - Trend Meter"); }
      if (BackgroundColorChangePositive && TB2Green) { _signaler.SendNotifications("3 TMs Turn Green with TB 2", "All 3 Trend Meters Turn  Green with TB 2 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB2Red) { _signaler.SendNotifications("3 TMs Turn Red with TB 2", "All 3 Trend Meters Turn  Red with TB 2 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB2Green) || (BackgroundColorChangeNegative && TB2Red))) { _signaler.SendNotifications("3 TMs Change Color with TB 2", "All 3 Trend Meters Change Color with TB 2 - Trend Meter"); }
      if (BackgroundColorChangePositive && TB1Green && TB2Green) { _signaler.SendNotifications("3 TMs Turn Green with TBs 1+2", "All 3 Trend Meters Turn  Green with Trend Bar 1+2 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB1Red && TB2Red) { _signaler.SendNotifications("3 TMs Turn Red with TBs 1+2", "All 3 Trend Meters Turn  Red with Trend Bar 1+2 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB1Green && TB2Green) || (BackgroundColorChangeNegative && TB1Red && TB2Red))) { _signaler.SendNotifications("3 TMs Change Color with TBs 1+2", "All 3 Trend Meters Change Color with Trend Bar 1+2 - Trend Meter"); }
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75513

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 