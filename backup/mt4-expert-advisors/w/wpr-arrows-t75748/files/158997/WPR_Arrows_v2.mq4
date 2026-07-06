//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=158936#p158936

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

#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrGreen
#property indicator_color2 clrRed

//--- input parameters
input int    N          = 14;       // Period for WPR
input int    Period     = 14;       // Period for MA
input double overbought = -20;      // Overbought level
input double oversold   = -80;      // Oversold level

//--- indicator buffers
double WPRBuffer[];
double MABuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Indicator buffers mapping
   SetIndexBuffer(0, WPRBuffer);
   SetIndexBuffer(1, MABuffer);
// Indicator properties
   IndicatorShortName("Williams Percent Range (WPR) with MA");
   SetIndexLabel(0, "WPR");
   SetIndexLabel(1, "MA");
// Set levels
   SetLevelValue(0, overbought);
   SetLevelValue(1, oversold);
   SetLevelStyle(STYLE_DOT, 1, clrGray);
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int start, i;
   if(prev_calculated == 0)
     {
      start = rates_total - N;
     }
   else
     {
      start = rates_total - (prev_calculated - 1);
     }
   for(i = start; i >= 0; i--)
     {
      double maxHigh = high[iHighest(NULL, 0, MODE_HIGH, N, i)];
      double minLow  = low[iLowest(NULL, 0, MODE_LOW, N, i)];
      WPRBuffer[i]   = -100 * (maxHigh - close[i]) / (maxHigh - minLow);
      double sum = 0;
      for(int j = 0; j < Period; j++)
        {
         sum += WPRBuffer[i + j];
        }
      MABuffer[i] = sum / Period;
     }
//
   for(i = start; i >= 0; i--)
     {
      if(WPRBuffer[i + 1] < MABuffer[i + 1] && WPRBuffer[i] >= MABuffer[i])
         drawArrow(1, i);
      else
         drawArrow(11, i);
      if(WPRBuffer[i + 1] > MABuffer[i + 1] && WPRBuffer[i] <= MABuffer[i])
         drawArrow(-1, i);
      else
         drawArrow(-11, i);
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input color arrUpColor = clrBlue;
input color arrDoColor = clrRed;
input int arrUpCode = 233;
input int arrDoCode = 234;
input int arrWidth = 2;
input int Distance = 20; // Arrow distance from Hi/Lo
void drawArrow(int dir, int bar)
  {
   if(dir == 11)
     {
      ObjectDelete(0, "arrU" + (string)bar);
     }
   if(dir == -11)
     {
      ObjectDelete(0, "arrD" + (string)bar);
     }
   if(dir == -1)
     {
      ObjectCreate(0, "arrD" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), High[bar] + Distance * Point());
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_COLOR, arrDoColor);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ARROWCODE, arrDoCode);
     }
   if(dir == 1)
     {
      ObjectCreate(0, "arrU" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), Low[bar] - Distance * Point());
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_COLOR, arrUpColor);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_ARROWCODE, arrUpCode);
     }
  }

//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=158936#p158936

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
