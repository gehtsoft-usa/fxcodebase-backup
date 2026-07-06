//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75023

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
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 White
#property indicator_color2 White
#property indicator_color3 Lime
#property indicator_width3 1
#property indicator_color4 Red
#property indicator_width4 1

extern int CountBars = 300;
extern string FS = " ** Filter sensitivity: High <-[1..3]-> Low ** ";
extern int Sensitivity = 2;
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
int gi_unused_108 = -1;

int init() {
   IndicatorBuffers(4);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 236);
   SetIndexBuffer(2, g_ibuf_92);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 238);
   SetIndexBuffer(3, g_ibuf_96);
   //SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 3, White);
   SetIndexBuffer(0, g_ibuf_100);
  // SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 3, White);
   SetIndexBuffer(1, g_ibuf_104);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   SetIndexEmptyValue(2, 0);
   SetIndexEmptyValue(3, 0);
   SetIndexLabel(2, "Buy Signal");
   SetIndexLabel(3, "Sell Signal");
   SetIndexLabel(0, "High");
   SetIndexLabel(1, "Low");
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   string ls_0 = "Scalper Signal";
   IndicatorShortName(ls_0);
   if (Sensitivity < 1) Sensitivity = 1;
   if (Sensitivity > 3) Sensitivity = 3;
   return (0);
}

int deinit() {
   return (0);
}

double sellSignal(int ai_0) {
   bool li_4 = TRUE;
   if (Sensitivity > 2)
      if (iHigh(Symbol(), Period(), ai_0 + 6) >= iHigh(Symbol(), Period(), ai_0 + 5)) li_4 = FALSE;
   if (Sensitivity > 1)
      if (iHigh(Symbol(), Period(), ai_0 + 5) >= iHigh(Symbol(), Period(), ai_0 + 4)) li_4 = FALSE;
   if (Sensitivity > 0)
      if (iHigh(Symbol(), Period(), ai_0 + 4) >= iHigh(Symbol(), Period(), ai_0 + 3)) li_4 = FALSE;
   if (li_4) {
      if (iClose(Symbol(), Period(), ai_0 + 2) < iHigh(Symbol(), Period(), ai_0 + 3))
         if (iClose(Symbol(), Period(), ai_0 + 1) < iLow(Symbol(), Period(), ai_0 + 3)) return (iHigh(Symbol(), Period(), ai_0 + 1) + 10.0 * Point);
   }
   return (0);
}

double buySignal(int ai_0) {
   bool li_4 = TRUE;
   if (Sensitivity > 2)
      if (iLow(Symbol(), Period(), ai_0 + 6) <= iLow(Symbol(), Period(), ai_0 + 5)) li_4 = FALSE;
   if (Sensitivity > 1)
      if (iLow(Symbol(), Period(), ai_0 + 5) <= iLow(Symbol(), Period(), ai_0 + 4)) li_4 = FALSE;
   if (Sensitivity > 0)
      if (iLow(Symbol(), Period(), ai_0 + 4) <= iLow(Symbol(), Period(), ai_0 + 3)) li_4 = FALSE;
   if (li_4) {
      if (iClose(Symbol(), Period(), ai_0 + 2) > iLow(Symbol(), Period(), ai_0 + 3))
         if (iClose(Symbol(), Period(), ai_0 + 1) > iHigh(Symbol(), Period(), ai_0 + 3)) return (iLow(Symbol(), Period(), ai_0 + 1) - 10.0 * Point);
   }
   return (0);
}

int start() {
   
   int li_0 = IndicatorCounted();
   if (li_0 < 0) return (-1);
   if (li_0 > 0) li_0--;
   int li_4 = Bars - li_0;
   for (int l_count_8 = 0; l_count_8 < li_4; l_count_8++) {
      g_ibuf_92[l_count_8 + 1] = buySignal(l_count_8);
      g_ibuf_96[l_count_8 + 1] = sellSignal(l_count_8);
      if (buySignal(l_count_8) > 0.0 || sellSignal(l_count_8) > 0.0) {
         g_ibuf_100[l_count_8 + 1] = iHigh(Symbol(), Period(), l_count_8 + 1);
         g_ibuf_104[l_count_8 + 1] = iLow(Symbol(), Period(), l_count_8 + 1);
      }
   }
   return (0);
}


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
