//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74341

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


//+------------------------------------------------------------------+
//|  Sixth Screen v3.8z(Zurathustra MOD) based on the original       |
//|  Thirds.MQ4 by Magnumfreak                                       |
//|                                                     Zurathustra  |
//|                                                                  |
//|  This indicator finds the range of the highest high and the      |
//|  lowest low of the past 120 bars of the current chart.  It then  |
//|  splits the range into six equal parts and draws 5 lines on the  |
//|  chart at equal distances to indicate the division.  It also     |
//|  calculates a take profic value based on one seventh of the      |
//|  high low range ((Highest High - Lowest Low) / 7).               |
//|                                                                  |
//|                                                     Zurathustra  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 5
extern int BarCount = 120;
extern color A_High = Red;
extern color B_High = White;
extern color Center = Red;
extern color B_Low = White;
extern color A_Low = Red;

double AH[], BH[], C[], AL[], BL[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   ObjectCreate("A Low", 1, 0, TimeCurrent(), Low[BarCount]);
   ObjectSet("A Low", OBJPROP_COLOR, A_Low);
   ObjectSet("A Low", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("A Low", OBJPROP_WIDTH, 2);
   ObjectSet("A Low", OBJPROP_FONTSIZE, 20);
   ObjectCreate("B Low", 1, 0, TimeCurrent(), Low[BarCount]);
   ObjectSet("B Low", OBJPROP_COLOR, B_Low);
   ObjectSet("B Low", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("B Low", OBJPROP_WIDTH, 2);
   ObjectCreate("Center", 1, 0, TimeCurrent(), Low[BarCount]);
   ObjectSet("Center", OBJPROP_COLOR, Center);
   ObjectSet("Center", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Center", OBJPROP_WIDTH, 2);
   ObjectCreate("B High", 1, 0, TimeCurrent(), Low[BarCount]);
   ObjectSet("B High", OBJPROP_COLOR, B_High);
   ObjectSet("B High", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("B High", OBJPROP_WIDTH, 2);
   ObjectCreate("A High", 1, 0, TimeCurrent(), Low[BarCount]);
   ObjectSet("A High", OBJPROP_COLOR, A_High);
   ObjectSet("A High", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("A High", OBJPROP_WIDTH, 2);
//
   SetIndexBuffer(0, AL);
   SetIndexBuffer(1, BL);
   SetIndexBuffer(2, C);
   SetIndexBuffer(3, BH);
   SetIndexBuffer(4, AH);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   double value = High[iHighest(NULL, 0, MODE_HIGH, BarCount, 1)] - Low[iLowest(NULL, 0, MODE_LOW, BarCount, 1)]; //value top of the chart - value bottom
   double sixth = value / 6;
   double valueSTEMP = (value * (MathPow(10, Digits)));
   double valueS = NormalizeDouble(valueSTEMP, 0);
   double sixthSTEMP = (sixth * (MathPow(10, Digits)));
   double sixthS = NormalizeDouble(sixthSTEMP, 0);
   double seventh = value / 7;
   double seventhSTEMP = (seventh * (MathPow(10, Digits)));
   double seventhS = NormalizeDouble(seventhSTEMP, 0);
   if(ObjectFind("A High") == -1)
      init();
//Comment(ObjectFind("sixth"));
   double v = Low[iLowest(NULL, 0, MODE_LOW, BarCount, 1)];
   ObjectMove("A Low", 0, TimeCurrent(), v + sixth);
   ObjectMove("B Low", 0, TimeCurrent(), v + sixth * 2);
   ObjectMove("Center", 0, TimeCurrent(), v + sixth * 3);
   ObjectMove("B High", 0, TimeCurrent(), v + sixth * 4);
   ObjectMove("A High", 0, TimeCurrent(), v + sixth * 5);
   for(int i = 0; i < BarCount; i++)
     {
      AL[i] = v + sixth;
      BL[i] = v + sixth * 2;
      C[i] = v + sixth * 3;
      BH[i] = v + sixth * 4;
      AH[i] = v + sixth * 5;
     }
   Comment("High = ", High[iHighest(NULL, 0, MODE_HIGH, BarCount, 1)], "\n", "Low = ", Low[iLowest(NULL, 0, MODE_LOW, BarCount, 1)], "\n", "High to Low = ", (valueS), " pips", "\n", "Take Profit = ", (seventhS), " pips", "\n", "Line pip Distance = ", (sixthS), " pips");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

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
