//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75521

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
#property indicator_color1 Orange
#property indicator_color2 Aqua
//#property indicator_color3 Magenta
//#property indicator_color4 DodgerBlue

datetime PreBarTime;
bool NotSameBar = True;

extern bool DoAlert = true;
extern bool EachTickMode = False;
extern int Fast_MA_Period = 1;
extern int Slow_MA_Period = 34;
extern int  Signal_period = 5;
double      Buffer1[],
            Buffer2[],
            b2[],
            b3[];
int LastTm;
double BuySignal, SellSignal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
// two additional buffers used for counting
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(0, 242); // down  226 234  242
// SetIndexStyle(0,DRAW_LINE,EMPTY,3);
   SetIndexBuffer(0, b2);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(1, 241);  //UP   225  233 241
//  SetIndexStyle(1,DRAW_LINE,EMPTY,3);
   SetIndexBuffer(1, b3);
// These buffers are not plotted, just used to determine arrows
//SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2, Buffer1);
//SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3, Buffer2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i, counted_bars = IndicatorCounted();
   double MA5, MA34;
   int limit = Bars - counted_bars;
// Print(" print limit = ", limit);
   if(counted_bars > 0)
      limit++;
   if(PreBarTime != Time[0])
     {
      NotSameBar = True;
      PreBarTime = Time[0];
     }
// Main line
   for(i = 0; i < limit; i++)
     {
      MA5 = iMA(NULL, 0, Fast_MA_Period, 0, MODE_SMA, PRICE_MEDIAN, i);
      MA34 = iMA(NULL, 0, Slow_MA_Period, 0, MODE_SMA, PRICE_MEDIAN, i);
      Buffer1[i] = MA5  - MA34;
     }
     {
      // Signal line
      for(i = 0; i < limit; i++)
        {
         Buffer2[i] = iMAOnArray(Buffer1, Bars, Signal_period, 0, MODE_LWMA, i);
        }//end for
      // Displaying Arrows
      for(i = 0; i < limit; i++)
        {
         if(Buffer1[i] > Buffer2[i] && Buffer1[i + 1] < Buffer2[i + 1])
           {
            b2[i] = High[i] + 5 * Point;
            if(b2[i] != EMPTY_VALUE && b2[i] != BuySignal)
              {
               BuySignal = b2[i];
               Print(TimeToStr(TimeCurrent(), TIME_MINUTES) + ", Indicator Send Sell Signal");
               if(DoAlert)
                 {
                  if(i == 0 && LastTm < Time[0])
                    {
                     Alert("SMA Cross " + Symbol() + " SELL");
                     LastTm = Time[0];
                    }
                 }
              }
           }
         if(Buffer1[i] < Buffer2[i] && Buffer1[i + 1] > Buffer2[i + 1])
           {
            b3[i] = Low[i] - 5 * Point;
            if(b3[i] != EMPTY_VALUE && b3[i] != SellSignal)
              {
               SellSignal = b3[i];
               if(b3[i] != EMPTY_VALUE)
                  Print(TimeToStr(TimeCurrent(), TIME_MINUTES) + ", Indicator Send Buy Signal");
               if(DoAlert)
                 {
                  if(i == 0 && LastTm < Time[0])
                    {
                     Alert("SMA Cross " + Symbol() + " BUY");
                     LastTm = Time[0];
                    }
                 }
              }
           }
        }//end for
      //Print("Time:" + TimeToStr(TimeCurrent(),TIME_MINUTES));
      NotSameBar = False;
     }
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75521

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