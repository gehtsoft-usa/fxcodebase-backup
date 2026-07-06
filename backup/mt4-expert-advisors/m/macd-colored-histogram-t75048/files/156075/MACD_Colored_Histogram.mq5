// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75048

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots 3

#property indicator_label1 "Main"
#property indicator_type1  DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Signal"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3  "Histogram" 
#property  indicator_type3   DRAW_COLOR_HISTOGRAM 
#property indicator_color3  clrRed,clrPink,clrLimeGreen,clrGreen
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1 

#define Section_MACD
#ifdef Section_MACD

input string tmacd       = "== MACD Setup =="; // ————————————————————————
input int    macd_fast   = 12;                 // Fast
input int    macd_slow   = 26;                 // Slow
input int    macd_signal = 9;                  // Signal

int  handle_macd = 0;
void setHandleMACD() { handle_macd = iMACD(NULL, 0, macd_fast, macd_slow, macd_signal, PRICE_CLOSE); }

double macd_main(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int    shift = candle;
    int    copy  = CopyBuffer(handle_macd, MAIN_LINE, shift, 1, value);

    if (copy > 0) { return value[0]; }
    return -1;
}

double macd_signal(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int    shift = candle;
    int    copy  = CopyBuffer(handle_macd, SIGNAL_LINE, shift, 1, value);

    if (copy > 0) { return value[0]; }
    return -1;
}

#endif


// ------------------------------------------------------------------
//--- indicator buffers
double bu_main[];
double bu_signal[];
double bu_histogram[];
double bu_colors_histogram[];


// ------------------------------------------------------------------
void OnInit()
{
    setHandleMACD();
  
  //--- indicator short name
  string short_name = "MACD colored histogram";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  
	//--- Buffers 
	SetIndexBuffer(0, bu_main,INDICATOR_DATA);
    SetIndexBuffer(1, bu_signal,INDICATOR_DATA);
    SetIndexBuffer(2, bu_histogram, INDICATOR_DATA);
    SetIndexBuffer(3, bu_colors_histogram, INDICATOR_COLOR_INDEX);
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

  int start;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = macd_slow + 1; }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    bu_main[i] = macd_main(i);
    bu_signal[i] = macd_signal(i);
    bu_histogram[i] = bu_main[i]-bu_signal[i];

    if (bu_histogram[i]>0)
    {
        bu_colors_histogram[i]=3;
        if (bu_histogram[i]>bu_histogram[i-1])
        {
            bu_colors_histogram[i]=2;
        }     
    } else
    {
        bu_colors_histogram[i]=1;
        if (bu_histogram[i]<bu_histogram[i-1])
        {
            bu_colors_histogram[i]=0;
        }     
    }
    
    
  }

  return (rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 