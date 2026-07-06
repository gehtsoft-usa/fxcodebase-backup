// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74931

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
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 LimeGreen
#property indicator_color3 Gold
#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 5

//---- input parameters
extern int Minutes=60;
extern int MACD_Fast = 8;
extern int MACD_Slow = 21;
extern int MACD_MA = 9;
extern int nBar = 1000;
extern int BarWidth = 5;
extern bool SignalOnClosedCandle = false;
extern bool AlertOn = false;
extern bool EmailOn = false;
extern bool use_label = false;
extern int  Corner = 1;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double Ma;
double hhigh, llow;
double Psar;
double PADX,NADX;
string TimeFrameStr;
double MA1,MA2,MA3;
double MACD_Signal,MACD_Main;
int Trend=0,SignalCandle=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
  SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,Red);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth, LimeGreen);
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth, Gold);
  SetIndexBuffer(2,ExtMapBuffer3);

switch(Minutes)
   {
      case 1 : TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe"; Minutes=0;
   }
   IndicatorShortName("Flat Trend w MACD ("+TimeFrameStr+")");  
   if (SignalOnClosedCandle) SignalCandle=1;
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Trade");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----

for (int i = 0; i < nBar; i++){
   ExtMapBuffer1[i]=0;
   ExtMapBuffer2[i]=0;
   ExtMapBuffer3[i]=0;
   

   MACD_Signal=iMACD(NULL,Minutes,MACD_Fast,MACD_Slow,MACD_MA,PRICE_CLOSE,MODE_SIGNAL,i);
   MACD_Main  =iMACD(NULL,Minutes,MACD_Fast,MACD_Slow,MACD_MA,PRICE_CLOSE,MODE_MAIN,i);
   
   if(MACD_Signal < MACD_Main && MACD_Main > 0)ExtMapBuffer2[i] = 1;
   if(MACD_Signal > MACD_Main && MACD_Main < 0)ExtMapBuffer1[i] = 1;
   if(ExtMapBuffer1[i] == 0 && ExtMapBuffer2[i] == 0)
   {ExtMapBuffer3[i] = 1;}
  
   }
   if (ExtMapBuffer2[SignalCandle]>0 && Trend<1) {
      Trend=1;
      if (AlertOn) Alert("FlatTrend Buy Alert! "+Symbol()+" Period "+Period());
      if (EmailOn) SendMail("FlatTrend Buy Alert!",Symbol()+" Period "+Period()+" - Buy entry price "+NormalizeDouble(Bid,Digits));
      }
   else if (ExtMapBuffer1[SignalCandle]>0 && Trend>-1) {
      Trend=-1;
      if (AlertOn) Alert("FlatTrend Sell Alert! "+Symbol()+" Period "+Period());
      if (EmailOn) SendMail("FlatTrend Sell Alert!",Symbol()+" Period "+Period()+" - Sell entry price "+NormalizeDouble(Bid,Digits));
      }
   string OPstr;
   color OPclr;
   if (Trend>0) {
      OPstr = "BUY";
      OPclr = Green;
      }
   else if (Trend<0) {
      OPstr = "SELL";
      OPclr = Red;
      }
   else {
      OPstr = "NO Trade";
      OPclr = Red;
      }
      
    if(use_label && ObjectFind("Trade")==-1)
    {  
   ObjectCreate("Trade", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Trade", OPstr, 15, "Arial Bold", OPclr);
   ObjectSet("Trade", OBJPROP_CORNER, Corner);
   ObjectSet("Trade", OBJPROP_XDISTANCE, 20);
   ObjectSet("Trade", OBJPROP_YDISTANCE, 20);
    }

 
   
//----
   return(0);
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