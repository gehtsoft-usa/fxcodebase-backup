// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=144225

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
#property indicator_minimum - 100
#property indicator_maximum 100

#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#property indicator_level1 40
#property indicator_level2 - 40

extern int Period1 = 6;
input string ExtSymbol = ""; // Other symbol

double VZO[];
double VPA[];
double VA[];
double VP[];
double VOL[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

int init()
{

   IndicatorBuffers(5);

   IndicatorName = GenerateIndicatorName("VZO");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorDigits(Digits);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VZO);
   SetIndexLabel(0, "VZO");

   SetIndexBuffer(1, VPA);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, VA);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(3, VP);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(4, VOL);
   SetIndexStyle(4, DRAW_NONE);

   return (0);
}

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (0);

   int limit = Bars;

   int i;

   if (ExtSymbol != "")
   {
      for (i = limit - 1; i >= 0; i--)
      {
         int btfPos = iBarShift(ExtSymbol, _Period, Time[i]);
         VZO[i] = iCustom(ExtSymbol, _Period, "VZO", Period1, 0, btfPos);
      }
      return 0;
   }
   for (i = limit - 1; i >= 0; i--)
   {
      VOL[i] = Volume[i];
   }

   for (i = limit - 1; i >= 0; i--)
   {
      if (Close[i] > Close[i + 1])
      {
         VP[i] = Volume[i];
      }
      else
      {
         VP[i] = -Volume[i];
      }
   }

   for (i = limit - 1; i >= 0; i--)
   {

      VPA[i] = iMAOnArray(VP, 0, Period1, 0, 1, i);
   }

   for (i = limit - 1; i >= 0; i--)
   {

      VA[i] = iMAOnArray(VOL, 0, Period1, 0, 1, i);
   }

   for (i = limit - Period1 * 2; i >= 0; i--)
   {
      if (VA[i] != 0)
         VZO[i] = (VPA[i] / VA[i]) * 100;
   }

   return (0);
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=144225

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
