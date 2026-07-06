// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76254

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
#property indicator_buffers 13
#property indicator_plots   13

#property indicator_label1  "SellEntry"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrTomato
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label2  "BuyEntry"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
#property indicator_label3  "SellExit"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
#property indicator_label4  "BuyExit"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDeepSkyBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3

extern int      EntryKC_MA_Period      = 74;        // Keltner entry center MA period
extern int      EntryKC_ATR_Period     = 37;        // Keltner entry ATR period
extern double   EntryKC_ATR_Mult       = 3.0;       // Keltner entry ATR multiplier
extern int      EntryKC_MA_Method      = MODE_EMA;  // MA method for center line
extern int      EntryKC_AppliedPrice   = PRICE_CLOSE; // Applied price for center line

extern int      ExitKC_MA_Period       = 68;        // Keltner exit center MA period
extern int      ExitKC_ATR_Period      = 49;        // Keltner exit ATR period
extern double   ExitKC_ATR_Mult        = 9.0;       // Keltner exit ATR multiplier
extern int      ExitKC_MA_Method       = MODE_LWMA; // MA method for exit channel center
extern int      ExitKC_AppliedPrice    = PRICE_CLOSE; // Applied price

extern int      MA1_Period             = 186;
extern int      MA1_Shift              = 1;
extern int      MA1_Method             = MODE_EMA;
extern int      MA1_AppliedPrice       = PRICE_WEIGHTED;

extern int      MA2_Period             = 19;
extern int      MA2_Shift              = 194;
extern int      MA2_Method             = MODE_SMMA;
extern int      MA2_AppliedPrice       = PRICE_OPEN;

extern int      MA3_Period             = 23;
extern int      MA3_Shift              = 2;
extern int      MA3_Method             = MODE_SMA;
extern int      MA3_AppliedPrice       = PRICE_OPEN;

extern int      ArrowCode_SellEntry    = 234;   // Arrow code for sell entry
extern int      ArrowCode_BuyEntry     = 233;   // Arrow code for buy entry
extern int      ArrowCode_SellExit     = 172;   // Arrow code for sell exit
extern int      ArrowCode_BuyExit      = 171;   // Arrow code for buy exit
extern double   Arrow_Offset_Points    = 50;    // Arrow distance (points)

extern int      MaxBarsBack            = 2000;  // Limit of bars
extern bool     OnlyNewBarSignals      = true;  // Place arrows only when bar just formed
extern bool     BackfillHistoricalSignals = true; // Draw historical signals
extern bool     RequireBandTouchForEntry = true;   // Require touching the Keltner band for entry
extern double   TouchTolerancePoints     = 5;      // Tolerance in points for band touch
extern bool     ShowEntryKeltner       = true;
extern bool     ShowExitKeltner        = true;
extern bool     ShowMAs                = true;

extern color    Col_EntryKC_Upper      = clrDarkOrange;
extern color    Col_EntryKC_Middle     = clrSandyBrown;
extern color    Col_EntryKC_Lower      = clrDarkOrange;
extern color    Col_ExitKC_Upper       = clrTeal;
extern color    Col_ExitKC_Middle      = clrAquamarine;
extern color    Col_ExitKC_Lower       = clrTeal;
extern color    Col_MA1                = clrDodgerBlue;
extern color    Col_MA2                = clrMagenta;
extern color    Col_MA3                = clrSilver;

double SellEntryBuffer[];
double BuyEntryBuffer[];
double SellExitBuffer[];
double BuyExitBuffer[];

double EntryKC_Upper[];
double EntryKC_Middle[];
double EntryKC_Lower[];

double ExitKC_Upper[];
double ExitKC_Middle[];
double ExitKC_Lower[];

double MA1_Buffer[];
double MA2_Buffer[];
double MA3_Buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, SellEntryBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, ArrowCode_SellEntry);
   SetIndexBuffer(1, BuyEntryBuffer);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, ArrowCode_BuyEntry);
   SetIndexBuffer(2, SellExitBuffer);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, ArrowCode_SellExit);
   SetIndexBuffer(3, BuyExitBuffer);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, ArrowCode_BuyExit);
   SetIndexBuffer(4, EntryKC_Upper);
   SetIndexLabel(4, "EntryKC_Upper");
   SetIndexBuffer(5, EntryKC_Middle);
   SetIndexLabel(5, "EntryKC_Middle");
   SetIndexBuffer(6, EntryKC_Lower);
   SetIndexLabel(6, "EntryKC_Lower");
   SetIndexBuffer(7, ExitKC_Upper);
   SetIndexLabel(7, "ExitKC_Upper");
   SetIndexBuffer(8, ExitKC_Middle);
   SetIndexLabel(8, "ExitKC_Middle");
   SetIndexBuffer(9, ExitKC_Lower);
   SetIndexLabel(9, "ExitKC_Lower");
   SetIndexBuffer(10, MA1_Buffer);
   SetIndexLabel(10, "MA1");
   SetIndexBuffer(11, MA2_Buffer);
   SetIndexLabel(11, "MA2");
   SetIndexBuffer(12, MA3_Buffer);
   SetIndexLabel(12, "MA3");
   if(ShowEntryKeltner)
     {
      SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, Col_EntryKC_Upper);
      SetIndexStyle(5, DRAW_LINE, STYLE_DOT,   1, Col_EntryKC_Middle);
      SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1, Col_EntryKC_Lower);
     }
   else
     {
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
      SetIndexStyle(6, DRAW_NONE);
     }
   if(ShowExitKeltner)
     {
      SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 1, Col_ExitKC_Upper);
      SetIndexStyle(8, DRAW_LINE, STYLE_DOT,   1, Col_ExitKC_Middle);
      SetIndexStyle(9, DRAW_LINE, STYLE_SOLID, 1, Col_ExitKC_Lower);
     }
   else
     {
      SetIndexStyle(7, DRAW_NONE);
      SetIndexStyle(8, DRAW_NONE);
      SetIndexStyle(9, DRAW_NONE);
     }
   if(ShowMAs)
     {
      SetIndexStyle(10, DRAW_LINE, STYLE_SOLID, 1, Col_MA1);
      SetIndexStyle(11, DRAW_LINE, STYLE_DASH,  1, Col_MA2);
      SetIndexStyle(12, DRAW_LINE, STYLE_DOT,   1, Col_MA3);
     }
   else
     {
      SetIndexStyle(10, DRAW_NONE);
      SetIndexStyle(11, DRAW_NONE);
      SetIndexStyle(12, DRAW_NONE);
     }
   IndicatorShortName("Keltner+MA EntryExit Arrows");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   if(rates_total < MathMax(MathMax(EntryKC_MA_Period, ExitKC_MA_Period), MathMax(MA1_Period, MathMax(MA2_Period, MA3_Period))) + 10)
      return(prev_calculated);
   int start = 0;
   if(prev_calculated > 0)
      start = prev_calculated - 1;
   int bars_limit = MathMin(rates_total - 1, MaxBarsBack);
   if(start < rates_total - bars_limit - 1)
      start = rates_total - bars_limit - 1;
   for(int i = start; i >= 0; i--)
     {
      double entry_ma = iMA(NULL, 0, EntryKC_MA_Period, 0, EntryKC_MA_Method, EntryKC_AppliedPrice, i);
      double entry_atr = iATR(NULL, 0, EntryKC_ATR_Period, i);
      double entry_offset = entry_atr * EntryKC_ATR_Mult;
      EntryKC_Middle[i] = entry_ma;
      EntryKC_Upper[i]  = entry_ma + entry_offset;
      EntryKC_Lower[i]  = entry_ma - entry_offset;
      double exit_ma = iMA(NULL, 0, ExitKC_MA_Period, 0, ExitKC_MA_Method, ExitKC_AppliedPrice, i);
      double exit_atr = iATR(NULL, 0, ExitKC_ATR_Period, i);
      double exit_offset = exit_atr * ExitKC_ATR_Mult;
      ExitKC_Middle[i] = exit_ma;
      ExitKC_Upper[i]  = exit_ma + exit_offset;
      ExitKC_Lower[i]  = exit_ma - exit_offset;
      MA1_Buffer[i] = iMA(NULL, 0, MA1_Period, MA1_Shift, MA1_Method, MA1_AppliedPrice, i);
      MA2_Buffer[i] = iMA(NULL, 0, MA2_Period, MA2_Shift, MA2_Method, MA2_AppliedPrice, i);
      MA3_Buffer[i] = iMA(NULL, 0, MA3_Period, MA3_Shift, MA3_Method, MA3_AppliedPrice, i);
      SellEntryBuffer[i] = EMPTY_VALUE;
      BuyEntryBuffer[i]  = EMPTY_VALUE;
      SellExitBuffer[i]  = EMPTY_VALUE;
      BuyExitBuffer[i]   = EMPTY_VALUE;
     }
   int first_bar = (OnlyNewBarSignals ? 1 : 0);
   int signal_start = BackfillHistoricalSignals ? start : first_bar;
   if(!BackfillHistoricalSignals)
      signal_start = first_bar;
   for(int b = signal_start; b >= first_bar; b--)
     {
      if(b + 1 >= rates_total)
         continue;
      double price = 0.0, arrow_price = 0.0;
      double ma1_now = MA1_Buffer[b];
      double ma1_prev = MA1_Buffer[b + 1];
      double ma2_now = MA2_Buffer[b];
      double ma2_prev = MA2_Buffer[b + 1];
      double ma3_now = MA3_Buffer[b];
      double o_now = open[b];
      double o_prev = open[b + 1];
      bool ma1_falling = (ma1_now < ma1_prev);
      bool cross_down_ma2 = (o_prev > ma2_prev && o_now < ma2_now);
      bool open_below_ma3 = (o_now < ma3_now);
      bool band_touch_long = (!RequireBandTouchForEntry) || (open[b] <= EntryKC_Lower[b] + TouchTolerancePoints * Point || low[b] <= EntryKC_Lower[b] + TouchTolerancePoints * Point);
      if(ma1_falling && cross_down_ma2 && open_below_ma3 && band_touch_long)
        {
         price = Low[b];
         arrow_price = price - Arrow_Offset_Points * Point;
         BuyEntryBuffer[b] = arrow_price;
        }
      bool ma1_rising = (ma1_now > ma1_prev);
      bool cross_up_ma2 = (o_prev < ma2_prev && o_now > ma2_now);
      bool open_above_ma3 = (o_now > ma3_now);
      bool band_touch_short = (!RequireBandTouchForEntry) || (open[b] >= EntryKC_Upper[b] - TouchTolerancePoints * Point || high[b] >= EntryKC_Upper[b] - TouchTolerancePoints * Point);
      if(ma1_rising && cross_up_ma2 && open_above_ma3 && band_touch_short)
        {
         price = High[b];
         arrow_price = price + Arrow_Offset_Points * Point;
         SellEntryBuffer[b] = arrow_price;
        }
      if(high[b] >= ExitKC_Upper[b])
        {
         arrow_price = High[b] + Arrow_Offset_Points * Point;
         SellExitBuffer[b] = arrow_price;
        }
      if(low[b] <= ExitKC_Lower[b])
        {
         arrow_price = Low[b] - Arrow_Offset_Points * Point;
         BuyExitBuffer[b] = arrow_price;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76254

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
