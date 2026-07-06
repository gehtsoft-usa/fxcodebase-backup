// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=144289
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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern bool Use_Pre_Smoothing=false;
extern int Pre_Length=14;
extern int Pre_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int CCI_Length=14;
extern bool Use_Post_Smoothing=false;
extern int Post_Length=14;                          
extern int Post_Method=0;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern double Overbought_Level=100.;
extern double Oversold_Level=-100.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
input ENUM_TIMEFRAMES htf = PERIOD_CURRENT; // Higher timeframe

double SCCI[];
double Source[], Res[];

int init()
{
 IndicatorShortName("Smoothed CCI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SCCI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Source);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Res);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
   if (htf != PERIOD_CURRENT)
   {
      while (pos >= 0)
      {
         int btfPos = iBarShift(_Symbol, htf, Time[pos]);
         SCCI[pos] = iCustom(_Symbol, htf, "Smoothed_CCI", Use_Pre_Smoothing, Pre_Length, Pre_Method, CCI_Length, Use_Post_Smoothing, 
            Post_Length, Post_Method, Overbought_Level, Oversold_Level, Price, 0, btfPos);
         pos--;
      }
      return 0;
   }

 while(pos>=0)
 {
  if (Use_Pre_Smoothing)
  {
   Source[pos]=iMA(NULL, 0, Pre_Length, 0, Pre_Method, Price, pos);
  }
  else
  {
   Source[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Res[pos]=iCCIOnArray(Source, 0, CCI_Length, pos);
  
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  if (Use_Post_Smoothing)
  {
   SCCI[pos]=iMAOnArray(Res, 0, Post_Length, 0, Post_Method, pos);
  }
  else
  {
   SCCI[pos]=Res[pos];
  }

  pos--;
 }
     
 return(0);
}

// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=144289
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