// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=25&t=70049

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots 5

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE

#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow
#property indicator_color4 Cyan
#property indicator_color5 Magenta

//--- indicator buffers
double Upper[], U75[], Middle[], L25[], Lower[];

input int  Length     = 20;
input int  Mode       = 1;     // 0 - Close 1 - High/Low
input bool show_inter = true;  // Show 25% and 75% levels?

// ------------------------------------------------------------------
void OnInit()
{
  IndicatorSetInteger(INDICATOR_DIGITS, 2);

  SetIndexBuffer(0, Upper);
  SetIndexBuffer(1, U75);
  SetIndexBuffer(2, Middle);
  SetIndexBuffer(3, L25);
  SetIndexBuffer(4, Lower);

  for (int i = 0; i < 5; i++)
    PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);

  for (int i = 0; i < 5; i++)
    PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, Length);

  if (!show_inter) {
    for (int i = 1; i < 4; i++)
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  //--- indicator short name
  string short_name = "Donchian Channel";
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
  // clang-format off
  if (rates_total < Length) return (0);

  int start;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = Length + 1; }
  // clang-format on

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    if (Mode == 0) {
      int start = i - Length;
      Upper[i]  = close[ArrayMaximum(close, start, Length)];
      Lower[i]  = close[ArrayMinimum(close, start, Length)];
    } else {
      int start = i - Length;
      Upper[i]  = high[ArrayMaximum(high, start, Length)];
      Lower[i]  = low[ArrayMinimum(low, start, Length)];
    }

    Middle[i] = (Upper[i] + Lower[i]) / 2;
    U75[i]    = (Upper[i] + Middle[i]) / 2;
    L25[i]    = (Middle[i] + Lower[i]) / 2;
  }

  return (rates_total);
}
//+------------------------------------------------------------------+
