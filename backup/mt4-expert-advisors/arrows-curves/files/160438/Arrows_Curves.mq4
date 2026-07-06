//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76288

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 RoyalBlue
#property indicator_color4 RoyalBlue
//---- input parameters
extern int SSP       = 6;     
extern int CountBars = 2250;  
extern int SkyCh     = 13;    
                              
int    i;
double high,low,smin,smax;
double val1[];      
double val2[];       
double TopLine[];
double LowLine[];
bool   uptrend,old;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 233);   
   SetIndexBuffer(0, val1); 
   SetIndexDrawBegin(0,2*SSP);
//
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 234);   
   SetIndexBuffer(1, val2); 
   SetIndexDrawBegin(1,2*SSP);
//
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,TopLine);
   SetIndexLabel(2,"High");
   SetIndexDrawBegin(2,2*SSP);
//
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LowLine);
   SetIndexLabel(3,"Low");
   SetIndexDrawBegin(3,2*SSP);
//----
   return(0);
  }

  int start()
  {
   if(Bars<=SSP+1) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+SSP;

//---- initial zero
   uptrend       =false;
   old           =false;
   GlobalVariableSet("goSELL", 0); 
   GlobalVariableSet("goBUY", 0);  
//----
   for(i=limit-SSP; i>=0; i--)
     {
      high= High[iHighest(Symbol(),0,MODE_HIGH,SSP,i)];
      low = Low[iLowest(Symbol(),0,MODE_LOW,SSP,i)];
      smax = high - (high - low)*SkyCh / 100; 
      smin = low + (high - low)*SkyCh / 100;  
      val1[i] = 0;
      val2[i] = 0;
      if(Close[i]<smin && i!=0) 
        {
         uptrend=false;
        }
      if(Close[i]>smax && i!=0) 
        {
         uptrend=true;
        }
      if(uptrend!=old && uptrend==false)
        {
         val2[i]=high; 
         if(i==0) GlobalVariableSet("goBUY",1);
        }
      if(uptrend!=old && uptrend==true)
        {
         val1[i]=low; 
         if(i==0) GlobalVariableSet("goSELL",1);
        }
      old=uptrend;
      TopLine[i]=high - (high - low)*SkyCh / 100;
      LowLine[i]=low +  (high - low)*SkyCh / 100;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76288

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+