// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=63884&start=20

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Gann Swing"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrYellow
#property indicator_width1  2

input int bars = 2;               // Bars of max/min
input color GannSwing_Color = clrYellow;

double GannSwing[];
double us[];
double ds[];

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "GannSwing");
   SetIndexBuffer(0, GannSwing, INDICATOR_DATA);
   SetIndexBuffer(1, us, INDICATOR_DATA);
   SetIndexBuffer(2, ds, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, bars);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start = (prev_calculated > 0) ? prev_calculated - 1 : bars;
   for(int i = start; i < rates_total; i++)
     ResetBuffers(i);

   //--- calculate us/ds flags
   for(int i = start; i < rates_total; i++)
     {
      us[i] = 1;
      ds[i] = 1;
      for(int j = 0; j < bars; j++)
        {
         if(high[i-j] <= high[i-j-1]) us[i] = 0;
         if(low[i-j]  >= low[i-j-1])  ds[i] = 0;
        }
      if(us[i] == 0 && high[i] > high[i-1] && low[i] >= low[i-1]) us[i] = 1;
      if(ds[i] == 0 && high[i] <= high[i-1] && low[i] <  low[i-1]) ds[i] = 1;
     }

   //--- determine swing lines
   int swingDir = 0;
   for(int i = start; i < rates_total; i++)
     {
      if(us[i] == 1)
        {
         GannSwing[i] = high[i];
         swingDir = 1;
        }
      else if(ds[i] == 1)
        {
         GannSwing[i] = low[i];
         swingDir = -1;
        }
      else
        {
         if(high[i-1] > high[i-2] && low[i-1] < low[i-3])
           {
            if(high[i] > high[i-1] && low[i] >= low[i-1])
              {
               GannSwing[i] = low[i];
               swingDir = -1;
              }
            else if(high[i] <= high[i-1] && low[i] < low[i-1])
              {
               GannSwing[i] = high[i];
               swingDir = 1;
              }
           }
        }
     }

   //--- remove consecutive identical swings
   int lastDir = 0;
   int lastIdx = 0;
   for(int i = start; i < rates_total; i++)
     {
      if(GannSwing[i] == high[i])
        {
         if(lastDir == 1) GannSwing[lastIdx] = EMPTY_VALUE;
         lastDir = 1;
         lastIdx = i;
        }
      if(GannSwing[i] == low[i])
        {
         if(lastDir == -1) GannSwing[lastIdx] = EMPTY_VALUE;
         lastDir = -1;
         lastIdx = i;
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
void ResetBuffers(int idx)
  {
   GannSwing[idx] = EMPTY_VALUE;
   us[idx]        = EMPTY_VALUE;
   ds[idx]        = EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=63884&start=20

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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