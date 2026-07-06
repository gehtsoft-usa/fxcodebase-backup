
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72590

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#include <Math/Stat/Stat.mqh>

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 3
#property indicator_type1  DRAW_LINE
#property indicator_color1 Navy
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Spike"
//--- top desv
#property indicator_type2  DRAW_LINE
#property indicator_color2 LimeGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Top Desv"
//--- bottom desv
#property indicator_type3  DRAW_LINE
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label3 "Bottom Desv"

//--- indicator buffers
double Spike[];
double TopDesv[];
double BtDesv[];

//--- indicator input
input int Period = 50;  // Indicator Periods

// ------------------------------------------------------------------
void OnInit()
{
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  SetIndexBuffer(0, Spike);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(1, TopDesv);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(2, BtDesv);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, Period);
  //--- indicator short name
  string short_name = "Volatility Oscillator";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  //--- checking for bars count
  if (rates_total < Period) return (0);

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = Period + 1;
  }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    Spike[i] = close[i] - open[i];

    //--- St Desviation:
    double values[];
    ArrayResize(values, Period);

    for (int j = Period - 1; j >= 0; j--) {
      values[j] = Spike[i - j];
    }
    TopDesv[i] = MathStandardDeviation(values);
    BtDesv[i]  = -TopDesv[i];
  }

  return (rates_total);
}
//+------------------------------------------------------------------+
