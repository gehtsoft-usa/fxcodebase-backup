//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76232

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
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrLime
#property indicator_width1  4
#property indicator_color2  Red
#property indicator_width2  4
#property indicator_color3  clrLightSeaGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
#property indicator_color4  clrDeepPink
#property indicator_style4  STYLE_DASH
#property indicator_width4  1
#define RESET 0
#define PHASE_NONE 0
#define PHASE_BUY 1
#define PHASE_SELL -1
enum Mode
  {
   SuperTrend = 0,
   NewWay,
   Visual,
   ExpertSignal
  };
input Mode TrendMode = NewWay;
input uint ATR_Period = 10;
input double ATR_Multiplier = 3.0;
input int Shift = 0;
double UpBuffer[];
double DnBuffer[];
double BuyBuffer[];
double SellBuffer[];
int ATR_Handle;
int min_rates_total;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total = ATR_Period + 3;
   SetIndexBuffer(0, BuyBuffer);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 4, clrLime);
   SetIndexArrow(0, 167);
   SetIndexShift(0, Shift);
   SetIndexDrawBegin(0, min_rates_total);
   ArraySetAsSeries(BuyBuffer, true);
   SetIndexEmptyValue(0, 0);
   SetIndexBuffer(1, SellBuffer);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 4, Red);
   SetIndexArrow(1, 167);
   SetIndexShift(1, Shift);
   SetIndexDrawBegin(1, min_rates_total);
   ArraySetAsSeries(SellBuffer, true);
   SetIndexEmptyValue(1, 0);
   SetIndexBuffer(2, UpBuffer);
   SetIndexStyle(2, DRAW_LINE, STYLE_DASH, 1, clrLightSeaGreen);
   SetIndexShift(2, Shift);
   SetIndexDrawBegin(2, min_rates_total);
   ArraySetAsSeries(UpBuffer, true);
   SetIndexEmptyValue(2, 0);
   SetIndexBuffer(3, DnBuffer);
   SetIndexStyle(3, DRAW_LINE, STYLE_DASH, 1, clrDeepPink);
   SetIndexShift(3, Shift);
   SetIndexDrawBegin(3, min_rates_total);
   ArraySetAsSeries(DnBuffer, true);
   SetIndexEmptyValue(3, 0);
   string shortname;
   StringConcatenate(shortname, "SuperTrend(", ATR_Period, ", ", ATR_Multiplier, ", ", Shift, ")");
   IndicatorShortName(shortname);
   IndicatorDigits(_Digits);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double& high[],
                const double& low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < min_rates_total)
      return(RESET);
   double atr, band_upper, band_lower;
   int limit, bar, phase;
   static int phase_;
   if(prev_calculated > rates_total || prev_calculated <= 0)
     {
      limit = rates_total - min_rates_total - 1;
      phase_ = PHASE_NONE;
     }
   else
     {
      limit = rates_total - prev_calculated;
     }
   phase = phase_;
   for(bar = limit; bar >= 0 && !IsStopped(); bar--)
     {
      double mediane = (High[bar] + Low[bar]) / 2;
      atr = iATR(NULL, 0, ATR_Period, bar);
      atr *= ATR_Multiplier;
      band_upper = mediane + atr;
      band_lower = mediane - atr;
      UpBuffer[bar] = 0.0;
      DnBuffer[bar] = 0.0;
      BuyBuffer[bar] = 0.0;
      SellBuffer[bar] = 0.0;
      if(phase == PHASE_NONE)
        {
         UpBuffer[bar] = mediane;
         DnBuffer[bar] = mediane;
        }
      if(phase != PHASE_BUY && Close[bar] > DnBuffer[bar + 1] && DnBuffer[bar + 1])
        {
         phase = PHASE_BUY;
         UpBuffer[bar] = band_lower;
         if(TrendMode < Visual)
            UpBuffer[bar + 1] = DnBuffer[bar + 1];
         else
            if(TrendMode == Visual)
               DnBuffer[bar] = DnBuffer[bar + 1];
        }
      if(phase != PHASE_SELL && Close[bar] < UpBuffer[bar + 1] && UpBuffer[bar + 1])
        {
         phase = PHASE_SELL;
         DnBuffer[bar] = band_upper;
         if(TrendMode < Visual)
            DnBuffer[bar + 1] = UpBuffer[bar + 1];
         else
            if(TrendMode == Visual)
               UpBuffer[bar] = UpBuffer[bar + 1];
        }
      if(phase == PHASE_BUY && ((TrendMode == SuperTrend && UpBuffer[bar + 2]) || TrendMode > SuperTrend))
        {
         if(band_lower > UpBuffer[bar + 1] || (UpBuffer[bar] && TrendMode > NewWay))
            UpBuffer[bar] = band_lower;
         else
            UpBuffer[bar] = UpBuffer[bar + 1];
        }
      if(phase == PHASE_SELL && ((TrendMode == SuperTrend && DnBuffer[bar + 2]) || TrendMode > SuperTrend))
        {
         if(band_upper < DnBuffer[bar + 1] || (DnBuffer[bar] && TrendMode > NewWay))
            DnBuffer[bar] = band_upper;
         else
            DnBuffer[bar] = DnBuffer[bar + 1];
        }
      if(TrendMode != Visual)
        {
         if(DnBuffer[bar + 1] && UpBuffer[bar])
            BuyBuffer[bar] = UpBuffer[bar];
         if(UpBuffer[bar + 1] && DnBuffer[bar])
            SellBuffer[bar] = DnBuffer[bar];
        }
      else
        {
         if(!UpBuffer[bar + 1] && UpBuffer[bar])
            BuyBuffer[bar] = UpBuffer[bar];
         if(!DnBuffer[bar + 1] && DnBuffer[bar])
            SellBuffer[bar] = DnBuffer[bar];
        }
      if(bar == 1)
         phase_ = phase;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76232

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