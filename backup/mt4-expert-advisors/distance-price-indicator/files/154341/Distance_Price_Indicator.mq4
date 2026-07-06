//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74606

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
// clang-format off
#property indicator_label1 "Line Up1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Up2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "Line Dn1"
#property  indicator_type3  DRAW_LINE
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_label4 "Line Dn2"
#property  indicator_type4  DRAW_LINE
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

//--- indicator buffers
double LineUp1[];
double LineUp2[];
double LineDn1[];
double LineDn2[];

// ------------------------------------------------------------------
input string T2                    = "== Set Lines ==";      // ————————————
input double distance1 = 10; // Distance 1:
input double distance2 = 15; // Distance 2:
input color  Line1Clr             = clrBlue;                // Line 1 Color:
input color  Line2Clr             = clrRed;                 // Line 2 Color:

// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp1, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, Line1Clr);
  SetIndexBuffer(1, LineUp2, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, Line2Clr);
  SetIndexBuffer(2, LineDn1, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_LINE, EMPTY, 1, Line1Clr);
  SetIndexBuffer(3, LineDn2, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_LINE, EMPTY, 1, Line2Clr);
  
  //---
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { }
// ------------------------------------------------------------------

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
  for (int i = 10; i >= 0; i--)
  {

        LineUp1[i] = Bid + distance1 *10* _Point;
        LineUp2[i] = Bid + distance2 *10* _Point;
        LineDn1[i] = Bid - distance1 *10* _Point;
        LineDn2[i] = Bid - distance2 *10* _Point;

  }
    return (rates_total);
}

// ------------------------------------------------------------------
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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