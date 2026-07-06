//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75699

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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 OrangeRed

double CrossUp[];
double CrossDown[];
double prevtime;
double Range, AvgRange;
double LimeRmonow, LimeRmoprevious;
double GoldRmonow, GoldRmoprevious;

extern string  Pair1      = "EURJPY";
extern int  SoundAlert    = 0; //0=disabled

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Iteration                                                        |
//+------------------------------------------------------------------+
int start()
 {
   int limit, i, counter;
   int counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   
   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++)
   {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      
      double LPair1a      = iLow(Pair1,0,i+2);
      double LPair1      = iLow(Pair1,0,i+1);
      double LPairCa      = iLow(Symbol(),0,i+2);
      double LPairC      = iLow(Symbol(),0,i+1);
      double HPair1a      = iHigh(Pair1,0,i+2);
      double HPair1      = iHigh(Pair1,0,i+1);
      double HPairCa      = iHigh(Symbol(),0,i+2);
      double HPairC      = iHigh(Symbol(),0,i+1);
      
      if(LPair1<LPair1a && LPairC>LPairCa)
      {
         CrossUp[i] = Low[i] - Range*0.5;
       }
       
      if (HPair1>HPair1a && HPairC<HPairCa)
      {
         CrossDown[i] = High[i] + Range*0.5;
      }
   }
   if((CrossUp[0] > 2000) && (CrossDown[0] > 2000)) { prevtime = 0; }
   if((CrossUp[0] == Low[0] - Range*0.5) && (prevtime != Time[0]) && (SoundAlert != 0))
   {
      prevtime = Time[0];
      Alert(Symbol()," Divergence Up @  Hour ",Hour(),"  Minute ",Minute());
   } 
   if((CrossDown[0] == High[0] + Range*0.5) && (prevtime != Time[0]) && (SoundAlert != 0))
   {
      prevtime = Time[0];
      Alert(Symbol()," Divergence Down @  Hour ",Hour(),"  Minute ",Minute());
   }
   return(0);
 }

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75699

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