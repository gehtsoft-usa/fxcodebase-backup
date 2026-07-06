// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67170

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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_level1 0

#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
//
#property indicator_label1 "Volume Accumulation Oscillator"
input int maxBars = 500;   // Maximum bars (0 = unlimited)
double VAO[];
double Median[];
string IndicatorName;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   string name = target;
   int try
         = 2;
   while(WindowFind(name) != -1)
     {
      name = target + " #" + IntegerToString(try
                                                ++);
     }
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName = GenerateIndicatorName("Volume Accumulation Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VAO);
   SetIndexLabel(0, "Volume Accumulation Oscillator");
   SetIndexDrawBegin(0, maxBars);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, Median);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars <= 1)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if(ExtCountedBars < 0)
      return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1)
      limit = Bars - ExtCountedBars - 1;
   if(maxBars > 0)
      limit =  MathMin(limit, maxBars);
   int pos = limit;
   while(pos >= 0)
     {
      Median[pos] = (Close[pos] - ((High[pos] + Low[pos]) / 2)) * Volume[pos];
      pos--;
     }
   pos = limit;
   while(pos >= 0)
     {
      VAO[pos] = Calculate(pos)  ;
      pos--;
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Calculate(int pos)
  {
   double Sum = 0;
   int limit = Bars - 1;
   if(maxBars > 0)
      limit =  MathMin(limit, maxBars);
   int i;
   for(i = pos; i <= limit; i++)
     {
      Sum = Sum + Median[i];
     }
   return (Sum);
  }
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