// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73223

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
 
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_NONE
#property indicator_type3   DRAW_NONE
#property indicator_type4   DRAW_NONE
#property indicator_type5   DRAW_NONE
#property indicator_type6   DRAW_NONE
#property indicator_type7   DRAW_NONE
#property indicator_type8   DRAW_NONE

extern string TimeFrame = "Current time frame";
extern string SymbolsPrefix = "";
extern string SymbolsSuffix = "";
extern int    MaMethod  = 3;
extern int    MaFast    = 3;
extern int    MaSlow    = 5;
extern int    Price     = 6;
extern bool   USD       = true;
extern bool   EUR       = true;
extern bool   GBP       = true;
extern bool   CHF       = true;
extern bool   JPY       = true;
extern bool   AUD       = true;
extern bool   CAD       = true;
extern bool   NZD       = true;
extern bool   showOnlySymbolOnChart = true;
extern int xdist = 10;
extern int ydist = 10;
extern int dist = 130;
extern ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER;
extern int fontsize = 12;
extern string font = "Arial bold";
extern color  Color_USD = Red;
extern color  Color_EUR = Aqua;
extern color  Color_GBP = DodgerBlue;
extern color  Color_CHF = Orange;
extern color  Color_JPY = Yellow;
extern color  Color_AUD = Lime;
extern color  Color_CAD = MediumOrchid;
extern color  Color_NZD = White;
extern double LevelUp2  =  0.010;
extern double LevelUp1  =  0.005;
extern double LevelDn1  = -0.005;
extern double LevelDn2  = -0.010;
extern int    Line_Thickness = 1;
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsOnLevelCross  = false;
extern bool   alertsOnLevelRevert = true;
extern bool   alertsOnSlopeChange = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern string Indicator_Name  = "CC: ";
extern int    StartPos        = 0;

//
//
//
//
//

extern int mn_per   = 12;
extern int mn_fast  = 3;
extern int w_per    = 9;
extern int w_fast   = 3;
extern int d_per    = 5;
extern int d_fast   = 3;
extern int h4_per   = 18;
extern int h4_fast  = 6;
extern int h1_per   = 24;
extern int h1_fast  = 8;
extern int m30_per  = 16;
extern int m30_fast = 2;
extern int m15_per  = 16;
extern int m15_fast = 4;
extern int m5_per   = 12;
extern int m5_fast  = 3;
extern int m1_per   = 30;
extern int m1_fast  = 10;

extern bool Interpolate = true;

//
//
//
//
//

double arrUSD[];
double arrEUR[];
double arrGBP[];
double arrCHF[];
double arrJPY[];
double arrAUD[];
double arrCAD[];
double arrNZD[];

string symbol[] = {"", "", "", "", "", "", "", "", "GBPJPY"};
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame = 0;

string names[8];
int    colors[8];

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(6);
   SetIndexBuffer(0, arrUSD);
   SetIndexBuffer(1, arrEUR);
   SetIndexBuffer(2, arrGBP);
   SetIndexBuffer(3, arrCHF);
   SetIndexBuffer(4, arrJPY);
   SetIndexBuffer(5, arrAUD);
   SetIndexBuffer(6, arrCAD);
   SetIndexBuffer(7, arrNZD);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);
//
//
//
//
//
   indicatorFileName = WindowExpertName();
   returnBars        = (TimeFrame == "returnBars");
   if(returnBars)
      return(0);
   calculateValue    = (TimeFrame == "calculateValue");
   if(calculateValue)
      return(0);
   timeFrame         = stringToTimeFrame(TimeFrame);
   switch(timeFrame)
     {
      case PERIOD_M1:
         MaSlow = m1_per;
         MaFast = m1_fast;
         break;
      case PERIOD_M5:
         MaSlow = m5_per;
         MaFast = m5_fast;
         break;
      case PERIOD_M15:
         MaSlow = m15_per;
         MaFast = m15_fast;
         break;
      case PERIOD_M30:
         MaSlow = m30_per;
         MaFast = m30_fast;
         break;
      case PERIOD_H1:
         MaSlow = h1_per;
         MaFast = h1_fast;
         break;
      case PERIOD_H4:
         MaSlow = h4_per;
         MaFast = h4_fast;
         break;
      case PERIOD_D1:
         MaSlow = d_per;
         MaFast = d_fast;
         break;
      case PERIOD_W1:
         MaSlow = w_per;
         MaFast = w_fast;
         break;
      case PERIOD_MN1:
         MaSlow = mn_per;
         MaFast = mn_fast;
         break;
     }
   SetLevelValue(0, LevelUp2);
   SetLevelValue(1, LevelUp1);
   SetLevelValue(2, LevelDn1);
   SetLevelValue(3, LevelDn2);
//
//
//
//
//
   USD = check("USD", USD);
   EUR = check("EUR", EUR);
   GBP = check("GBP", GBP);
   CHF = check("CHF", CHF);
   JPY = check("JPY", JPY);
   AUD = check("AUD", AUD);
   CAD = check("CAD", CAD);
   NZD = check("NZD", NZD);
   if(USD)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " USD");
      names[0] = "USD";
      colors[0] = Color_USD;
     }
   if(EUR)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " EUR");
      names[1] = "EUR";
      colors[1] = Color_EUR;
     }
   if(GBP)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " GBP");
      names[2] = "GBP";
      colors[2] = Color_GBP;
     }
   if(CHF)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " CHF");
      names[3] = "CHF";
      colors[3] = Color_CHF;
     }
   if(JPY)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " JPY");
      names[4] = "JPY";
      colors[4] = Color_JPY;
     }
   if(AUD)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " AUD");
      names[5] = "AUD";
      colors[5] = Color_AUD;
     }
   if(CAD)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " CAD");
      names[6] = "CAD";
      colors[6] = Color_CAD;
     }
   if(NZD)
     {
      Indicator_Name = StringConcatenate(Indicator_Name, " NZD");
      names[7] = "NZD";
      colors[7] = Color_NZD;
     }
   IndicatorShortName(Indicator_Name);
   return(0);
  }

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

string symbols[];
void addSymbol(string tsymbol)
  {
   ArrayResize(symbols, ArraySize(symbols) + 1);
   symbols[ArraySize(symbols) - 1] = SymbolsPrefix + tsymbol + SymbolsSuffix;
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getLimit(int limit, string tsymbol)
  {
   if(tsymbol != Symbol())
      limit = MathMax(MathMin(Bars - 1, iCustom(tsymbol, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()), limit);
   return(limit);
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = 0; i < 8; i++)
      ObjectDelete(Indicator_Name + i);
   for(i = 0; i < 8; i++)
      ObjectDelete(Indicator_Name + ":" + i);
   for(i = 0; i < 8; i++)
      ObjectDelete(Indicator_Name + ":n" + i);
   return(0);
  }

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

double values[8];
double valuea[8];
double trends[][64];
double trendl[][8][5];
int start()
  {
   int i, r, counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if(returnBars)
     {
      arrUSD[0] = limit;
      return(0);
     }
//
//
//
//
//
   static bool initialized = false;
   if(!initialized)
     {
      initialized = true;
      int cur = StartPos;
      int st = 23;
      if(USD)
        {
         sl(0, "~", cur, Color_USD, "USD");
         cur += st;
        }
      if(EUR)
        {
         sl(1, "~", cur, Color_EUR, "EUR");
         cur += st;
         addSymbol("EURUSD");
        }
      if(GBP)
        {
         sl(2, "~", cur, Color_GBP, "GBP");
         cur += st;
         addSymbol("GBPUSD");
        }
      if(CHF)
        {
         sl(3, "~", cur, Color_CHF, "CHF");
         cur += st;
         addSymbol("USDCHF");
        }
      if(JPY)
        {
         sl(4, "~", cur, Color_JPY, "JPY");
         cur += st;
         addSymbol("USDJPY");
        }
      if(AUD)
        {
         sl(5, "~", cur, Color_AUD, "AUD");
         cur += st;
         addSymbol("AUDUSD");
        }
      if(CAD)
        {
         sl(6, "~", cur, Color_CAD, "CAD");
         cur += st;
         addSymbol("USDCAD");
        }
      if(NZD)
        {
         sl(7, "~", cur, Color_NZD, "NZD");
         cur += st;
         addSymbol("NZDUSD");
        }
     }
   for(int t = 0; t < ArraySize(symbols); t++)
      limit = getLimit(limit, symbols[t]);
   if(ArrayRange(trends, 0) != Bars)
      ArrayResize(trends, Bars);
   if(ArrayRange(trendl, 0) != Bars)
      ArrayResize(trendl, Bars);
//
//
//
//
//
   ArrayInitialize(values, -1);
   if(calculateValue || timeFrame == Period())
     {
      for(i = 0, r = Bars - 1; i < limit; i++, r--)
        {
         if(EUR)
           {
            double EURUSD_Fast = ma("EURUSD", MaFast, MaMethod, Price, i);
            double EURUSD_Slow = ma("EURUSD", MaSlow, MaMethod, Price, i);
            if(!EURUSD_Fast || !EURUSD_Slow)
               break;
           }
         if(GBP)
           {
            double GBPUSD_Fast = ma("GBPUSD", MaFast, MaMethod, Price, i);
            double GBPUSD_Slow = ma("GBPUSD", MaSlow, MaMethod, Price, i);
            if(!GBPUSD_Fast || !GBPUSD_Slow)
               break;
           }
         if(AUD)
           {
            double AUDUSD_Fast = ma("AUDUSD", MaFast, MaMethod, Price, i);
            double AUDUSD_Slow = ma("AUDUSD", MaSlow, MaMethod, Price, i);
            if(!AUDUSD_Fast || !AUDUSD_Slow)
               break;
           }
         if(NZD)
           {
            double NZDUSD_Fast = ma("NZDUSD", MaFast, MaMethod, Price, i);
            double NZDUSD_Slow = ma("NZDUSD", MaSlow, MaMethod, Price, i);
            if(!NZDUSD_Fast || !NZDUSD_Slow)
               break;
           }
         if(CAD)
           {
            double USDCAD_Fast = ma("USDCAD", MaFast, MaMethod, Price, i);
            double USDCAD_Slow = ma("USDCAD", MaSlow, MaMethod, Price, i);
            if(!USDCAD_Fast || !USDCAD_Slow)
               break;
           }
         if(CHF)
           {
            double USDCHF_Fast = ma("USDCHF", MaFast, MaMethod, Price, i);
            double USDCHF_Slow = ma("USDCHF", MaSlow, MaMethod, Price, i);
            if(!USDCHF_Fast || !USDCHF_Slow)
               break;
           }
         if(JPY)
           {
            double USDJPY_Fast = ma("USDJPY", MaFast, MaMethod, Price, i) / 100.0;
            double USDJPY_Slow = ma("USDJPY", MaSlow, MaMethod, Price, i) / 100.0;
            if(!USDJPY_Fast || !USDJPY_Slow)
               break;
           }
         //
         //
         //
         //
         //
         if(USD)
           {
            arrUSD[i] = 0;
            if(EUR)
               arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
            if(GBP)
               arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
            if(AUD)
               arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
            if(NZD)
               arrUSD[i] += NZDUSD_Slow - NZDUSD_Fast;
            if(CHF)
               arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
            if(CAD)
               arrUSD[i] += USDCAD_Fast - USDCAD_Slow;
            if(JPY)
               arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
            values[0] = arrUSD[i];
           }
         if(EUR)
           {
            arrEUR[i] = 0;
            if(USD)
               arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
            if(GBP)
               arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
            if(AUD)
               arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
            if(NZD)
               arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / NZDUSD_Slow;
            if(CHF)
               arrEUR[i] += EURUSD_Fast * USDCHF_Fast - EURUSD_Slow * USDCHF_Slow;
            if(CAD)
               arrEUR[i] += EURUSD_Fast * USDCAD_Fast - EURUSD_Slow * USDCAD_Slow;
            if(JPY)
               arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
            values[1] = arrEUR[i];
           }
         if(GBP)
           {
            arrGBP[i] = 0;
            if(USD)
               arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
            if(EUR)
               arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
            if(AUD)
               arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
            if(NZD)
               arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / NZDUSD_Slow;
            if(CHF)
               arrGBP[i] += GBPUSD_Fast * USDCHF_Fast - GBPUSD_Slow * USDCHF_Slow;
            if(CAD)
               arrGBP[i] += GBPUSD_Fast * USDCAD_Fast - GBPUSD_Slow * USDCAD_Slow;
            if(JPY)
               arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
            values[2] = arrGBP[i];
           }
         if(AUD)
           {
            arrAUD[i] = 0;
            if(USD)
               arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
            if(EUR)
               arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
            if(GBP)
               arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
            if(NZD)
               arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / NZDUSD_Slow;
            if(CHF)
               arrAUD[i] += AUDUSD_Fast * USDCHF_Fast - AUDUSD_Slow * USDCHF_Slow;
            if(CAD)
               arrAUD[i] += AUDUSD_Fast * USDCAD_Fast - AUDUSD_Slow * USDCAD_Slow;
            if(JPY)
               arrAUD[i] += AUDUSD_Fast * USDJPY_Fast - AUDUSD_Slow * USDJPY_Slow;
            values[5] = arrAUD[i];
           }
         if(NZD)
           {
            arrNZD[i] = 0;
            if(USD)
               arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
            if(EUR)
               arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / NZDUSD_Fast;
            if(GBP)
               arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / NZDUSD_Fast;
            if(AUD)
               arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / NZDUSD_Fast;
            if(CHF)
               arrNZD[i] += NZDUSD_Fast * USDCHF_Fast - NZDUSD_Slow * USDCHF_Slow;
            if(CAD)
               arrNZD[i] += NZDUSD_Fast * USDCAD_Fast - NZDUSD_Slow * USDCAD_Slow;
            if(JPY)
               arrNZD[i] += NZDUSD_Fast * USDJPY_Fast - NZDUSD_Slow * USDJPY_Slow;
            values[7] = arrNZD[i];
           }
         if(CAD)
           {
            arrCAD[i] = 0;
            if(USD)
               arrCAD[i] += USDCAD_Slow - USDCAD_Fast;
            if(EUR)
               arrCAD[i] += EURUSD_Slow * USDCAD_Slow - EURUSD_Fast * USDCAD_Fast;
            if(GBP)
               arrCAD[i] += GBPUSD_Slow * USDCAD_Slow - GBPUSD_Fast * USDCAD_Fast;
            if(AUD)
               arrCAD[i] += AUDUSD_Slow * USDCAD_Slow - AUDUSD_Fast * USDCAD_Fast;
            if(NZD)
               arrCAD[i] += NZDUSD_Slow * USDCAD_Slow - NZDUSD_Fast * USDCAD_Fast;
            if(CHF)
               arrCAD[i] += USDCHF_Fast / USDCAD_Fast - USDCHF_Slow / USDCAD_Slow;
            if(JPY)
               arrCAD[i] += USDJPY_Fast / USDCAD_Fast - USDJPY_Slow / USDCAD_Slow;
            values[6] = arrCAD[i];
           }
         if(CHF)
           {
            arrCHF[i] = 0;
            if(USD)
               arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
            if(EUR)
               arrCHF[i] += EURUSD_Slow * USDCHF_Slow - EURUSD_Fast * USDCHF_Fast;
            if(GBP)
               arrCHF[i] += GBPUSD_Slow * USDCHF_Slow - GBPUSD_Fast * USDCHF_Fast;
            if(AUD)
               arrCHF[i] += AUDUSD_Slow * USDCHF_Slow - AUDUSD_Fast * USDCHF_Fast;
            if(NZD)
               arrCHF[i] += NZDUSD_Slow * USDCHF_Slow - NZDUSD_Fast * USDCHF_Fast;
            if(CAD)
               arrCHF[i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
            if(JPY)
               arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
            values[3] = arrCHF[i];
           }
         if(JPY)
           {
            arrJPY[i] = 0;
            if(USD)
               arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
            if(EUR)
               arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
            if(GBP)
               arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
            if(AUD)
               arrJPY[i] += AUDUSD_Slow * USDJPY_Slow - AUDUSD_Fast * USDJPY_Fast;
            if(NZD)
               arrJPY[i] += NZDUSD_Slow * USDJPY_Slow - NZDUSD_Fast * USDJPY_Fast;
            if(CAD)
               arrJPY[i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
            if(CHF)
               arrJPY[i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
            values[4] = arrJPY[i];
           }
         for(int k = 0;   k < 7; k++)
            for(int j = k + 1; j < 8; j++)
              {
               if(values[k] > values[j])
                  trends[r][k * 8 + j] =  1;
               if(values[k] < values[j])
                  trends[r][k * 8 + j] = -1;
              }
         if(i == 0)
            ArrayCopy(valuea, values);
         for(k = 0; k < 8; k++)
           {
            if(values[k] > LevelUp2)
               trendl[r][k][0] =  1;
            if(values[k] < LevelUp2)
               trendl[r][k][0] = -1;
            if(values[k] > LevelUp1)
               trendl[r][k][1] =  1;
            if(values[k] < LevelUp1)
               trendl[r][k][1] = -1;
            if(values[k] > LevelDn1)
               trendl[r][k][2] =  1;
            if(values[k] < LevelDn1)
               trendl[r][k][2] = -1;
            if(values[k] > LevelDn2)
               trendl[r][k][3] =  1;
            if(values[k] < LevelDn2)
               trendl[r][k][3] = -1;
           }
        }
      for(r = Bars - i - 1; i >= 0; i--, r++)
        {
         if(arrUSD[i] > arrUSD[i + 1])
            trendl[r][0][4] =  1;
         if(arrUSD[i] < arrUSD[i + 1])
            trendl[r][0][4] = -1;
         if(arrEUR[i] > arrEUR[i + 1])
            trendl[r][1][4] =  1;
         if(arrEUR[i] < arrEUR[i + 1])
            trendl[r][1][4] = -1;
         if(arrGBP[i] > arrGBP[i + 1])
            trendl[r][2][4] =  1;
         if(arrGBP[i] < arrGBP[i + 1])
            trendl[r][2][4] = -1;
         if(arrCHF[i] > arrCHF[i + 1])
            trendl[r][3][4] =  1;
         if(arrCHF[i] < arrCHF[i + 1])
            trendl[r][3][4] = -1;
         if(arrJPY[i] > arrJPY[i + 1])
            trendl[r][4][4] =  1;
         if(arrJPY[i] < arrJPY[i + 1])
            trendl[r][4][4] = -1;
         if(arrAUD[i] > arrAUD[i + 1])
            trendl[r][5][4] =  1;
         if(arrAUD[i] < arrAUD[i + 1])
            trendl[r][5][4] = -1;
         if(arrCAD[i] > arrCAD[i + 1])
            trendl[r][6][4] =  1;
         if(arrCAD[i] < arrCAD[i + 1])
            trendl[r][6][4] = -1;
         if(arrNZD[i] > arrNZD[i + 1])
            trendl[r][7][4] =  1;
         if(arrNZD[i] < arrNZD[i + 1])
            trendl[r][7][4] = -1;
        }
      manageAlerts();
      manageDisplay();
      return(0);
     }
//
//
//
//
//
   for(i = limit, r = Bars - i - 1; i >= 0; i--, r++)
     {
      int y = iBarShift(NULL, timeFrame, Time[i]);
      if(USD)
         arrUSD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 0, y);
      if(EUR)
         arrEUR[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 1, y);
      if(GBP)
         arrGBP[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 2, y);
      if(CHF)
         arrCHF[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 3, y);
      if(JPY)
         arrJPY[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 4, y);
      if(AUD)
         arrAUD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 5, y);
      if(CAD)
         arrCAD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 6, y);
      if(NZD)
         arrNZD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, Price, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, 7, y);
      if(USD)
         values[0] = arrUSD[i];
      if(EUR)
         values[1] = arrEUR[i];
      if(GBP)
         values[2] = arrGBP[i];
      if(CHF)
         values[3] = arrCHF[i];
      if(JPY)
         values[4] = arrJPY[i];
      if(AUD)
         values[5] = arrAUD[i];
      if(CAD)
         values[6] = arrCAD[i];
      if(NZD)
         values[7] = arrNZD[i];
      for(k = 0;   k < 7; k++)
         for(j = k + 1; j < 8; j++)
           {
            if(values[k] > values[j])
               trends[r][k * 8 + j] =  1;
            if(values[k] < values[j])
               trends[r][k * 8 + j] = -1;
           }
      for(k = 0; k < 8; k++)
        {
         if(values[k] > LevelUp2)
            trendl[r][k][0] =  1;
         if(values[k] < LevelUp2)
            trendl[r][k][0] = -1;
         if(values[k] > LevelUp1)
            trendl[r][k][1] =  1;
         if(values[k] < LevelUp1)
            trendl[r][k][1] = -1;
         if(values[k] > LevelDn1)
            trendl[r][k][2] =  1;
         if(values[k] < LevelDn1)
            trendl[r][k][2] = -1;
         if(values[k] > LevelDn2)
            trendl[r][k][3] =  1;
         if(values[k] < LevelDn2)
            trendl[r][k][3] = -1;
        }
      if(arrUSD[i] > arrUSD[i + 1])
         trendl[r][0][4] =  1;
      if(arrUSD[i] < arrUSD[i + 1])
         trendl[r][0][4] = -1;
      if(arrEUR[i] > arrEUR[i + 1])
         trendl[r][1][4] =  1;
      if(arrEUR[i] < arrEUR[i + 1])
         trendl[r][1][4] = -1;
      if(arrGBP[i] > arrGBP[i + 1])
         trendl[r][2][4] =  1;
      if(arrGBP[i] < arrGBP[i + 1])
         trendl[r][2][4] = -1;
      if(arrCHF[i] > arrCHF[i + 1])
         trendl[r][3][4] =  1;
      if(arrCHF[i] < arrCHF[i + 1])
         trendl[r][3][4] = -1;
      if(arrJPY[i] > arrJPY[i + 1])
         trendl[r][4][4] =  1;
      if(arrJPY[i] < arrJPY[i + 1])
         trendl[r][4][4] = -1;
      if(arrAUD[i] > arrAUD[i + 1])
         trendl[r][5][4] =  1;
      if(arrAUD[i] < arrAUD[i + 1])
         trendl[r][5][4] = -1;
      if(arrCAD[i] > arrCAD[i + 1])
         trendl[r][6][4] =  1;
      if(arrCAD[i] < arrCAD[i + 1])
         trendl[r][6][4] = -1;
      if(arrNZD[i] > arrNZD[i + 1])
         trendl[r][7][4] =  1;
      if(arrNZD[i] < arrNZD[i + 1])
         trendl[r][7][4] = -1;
      if(i == 0)
         ArrayCopy(valuea, values);
      if(!Interpolate || y == iBarShift(NULL, timeFrame, Time[i - 1]))
         continue;
      //
      //
      //
      //
      //
      if(USD)
         interpolate(arrUSD, iTime(NULL, timeFrame, y), i);
      if(EUR)
         interpolate(arrEUR, iTime(NULL, timeFrame, y), i);
      if(GBP)
         interpolate(arrGBP, iTime(NULL, timeFrame, y), i);
      if(JPY)
         interpolate(arrJPY, iTime(NULL, timeFrame, y), i);
      if(CHF)
         interpolate(arrCHF, iTime(NULL, timeFrame, y), i);
      if(AUD)
         interpolate(arrAUD, iTime(NULL, timeFrame, y), i);
      if(CAD)
         interpolate(arrCAD, iTime(NULL, timeFrame, y), i);
      if(NZD)
         interpolate(arrNZD, iTime(NULL, timeFrame, y), i);
     }
   manageAlerts();
   manageDisplay();
   return(0);
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageDisplay()
  {
   double tempV[8];
   ArrayCopy(tempV, valuea);
   string tempN[8];
   ArrayCopy(tempN, names);
   int    tempC[8];
   ArrayCopy(tempC, colors);
   for(int i = 0;   i < 7; i++)
      for(int k = i + 1; k < 8; k++)
         if(tempV[k] > tempV[i])
           {
            double v = tempV[i];
            string n = tempN[i];
            int    c = tempC[i];
            tempV[i] = tempV[k];
            tempN[i] = tempN[k];
            tempC[i] = tempC[k];
            tempV[k] = v;
            tempN[k] = n;
            tempC[k] = c;
           }
//
//
//
//
//

   k = 0;
   int window = 0;
   for(i = 0; i < 8; i++)
     {
      if(tempV[i] != -1)
        {
         string name = Indicator_Name + ":" + i;
         ObjectCreate(name, OBJ_LABEL, window, 0, 0);
         ObjectSet(name, OBJPROP_XDISTANCE, xdist + dist * k);
         ObjectSet(name, OBJPROP_YDISTANCE, ydist);
         ObjectSet(name, OBJPROP_BACK, FALSE);
         ObjectSet(name, OBJPROP_CORNER, corner);
         ObjectSetText(name, tempN[i] + ": " + DoubleToStr(tempV[i], 6), fontsize, font, tempC[i]);
        
         k++;
        }
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool check(string what, bool otherwise)
  {
   if(showOnlySymbolOnChart)
      if(StringFind(Symbol(), what) != -1)
         return(true);
      else
         return(false);
   return(otherwise);
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

datetime times[104];
string   kinds[104];
void manageAlerts()
  {
   if(!calculateValue && alertsOn)
     {
      if(alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      whichBar = iBarShift(NULL, 0, iTime(NULL, timeFrame, whichBar));
      whichBar = Bars - whichBar - 1;
      //
      //
      //
      //
      //
      for(int k = 0;   k < 7; k++)
         for(int j = k + 1; j < 8; j++)
            if(trends[whichBar][k * 8 + j] != trends[whichBar - 1][k * 8 + j])
              {
               if(trends[whichBar][k * 8 + j] ==  1)
                  doAlert(k * 8 + j, names[k] + " crossed " + names[j] + " up");
               if(trends[whichBar][k * 8 + j] == -1)
                  doAlert(k * 8 + j, names[k] + " crossed " + names[j] + " down");
              }
      for(k = 0; k < 7; k++)
        {
         if(trendl[whichBar][k][0] != trendl[whichBar - 1][k][0])
           {
            if(alertsOnLevelCross  && trendl[whichBar][k][0] ==  1)
               doAlert(64 + k * 5 + 0, names[k] + " crossed " + DoubleToStr(LevelUp2, 4) + " up");
            if(alertsOnLevelRevert && trendl[whichBar][k][0] == -1)
               doAlert(64 + k * 5 + 0, names[k] + " crossed " + DoubleToStr(LevelUp2, 4) + " down");
           }
         if(trendl[whichBar][k][1] != trendl[whichBar - 1][k][1])
           {
            if(alertsOnLevelCross  && trendl[whichBar][k][1] ==  1)
               doAlert(64 + k * 5 + 1, names[k] + " crossed " + DoubleToStr(LevelUp1, 4) + " up");
            if(alertsOnLevelRevert && trendl[whichBar][k][1] == -1)
               doAlert(64 + k * 5 + 1, names[k] + " crossed " + DoubleToStr(LevelUp1, 4) + " down");
           }
         if(trendl[whichBar][k][2] != trendl[whichBar - 1][k][2])
           {
            if(alertsOnLevelRevert && trendl[whichBar][k][2] ==  1)
               doAlert(64 + k * 5 + 2, names[k] + " crossed " + DoubleToStr(LevelDn1, 4) + " up");
            if(alertsOnLevelCross  && trendl[whichBar][k][2] == -1)
               doAlert(64 + k * 5 + 2, names[k] + " crossed " + DoubleToStr(LevelDn1, 4) + " down");
           }
         if(trendl[whichBar][k][3] != trendl[whichBar - 1][k][3])
           {
            if(alertsOnLevelRevert && trendl[whichBar][k][3] ==  1)
               doAlert(64 + k * 5 + 3, names[k] + " crossed " + DoubleToStr(LevelDn2, 4) + " up");
            if(alertsOnLevelCross  && trendl[whichBar][k][3] == -1)
               doAlert(64 + k * 5 + 3, names[k] + " crossed " + DoubleToStr(LevelDn2, 4) + " down");
           }
         if(alertsOnSlopeChange && trendl[whichBar][k][4] != trendl[whichBar - 1][k][4])
           {
            if(trendl[whichBar][k][4] ==  1)
               doAlert(64 + k * 5 + 4, names[k] + " slope changed to up");
            if(trendl[whichBar][k][4] == -1)
               doAlert(64 + k * 5 + 4, names[k] + " slope changed to down");
           }
        }
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forWhat, string doWhat)
  {
   string message;
   if(kinds[forWhat] != doWhat || times[forWhat] != Time[0])
     {
      kinds[forWhat]  = doWhat;
      times[forWhat]  = Time[0];
      //
      //
      //
      //
      //
      message =  StringConcatenate(timeFrameToString(timeFrame), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " " + doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), "CC"), message);
      if(alertsSound)
         PlaySound("alert2.wav");
     }
  }

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void interpolate(double& buffer[], datetime time, int i)
  {
   for(int n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
      continue;
//
//
//
//
//
   if(buffer[i] == EMPTY_VALUE || buffer[i + n] == EMPTY_VALUE)
      n = -1;
   double increment = (buffer[i + n] - buffer[i]) / n;
   for(int k = 1; k < n; k++)
      buffer[i + k] = buffer[i] + k * increment;
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ma(string sym, int per, int Mode, int tPrice, int i)
  {
   return(iMA(SymbolsPrefix + sym + SymbolsSuffix, 0, per, 0, Mode, tPrice, i));
  }


//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sl(int buffNo, string sym, int x, color col, string buffLabel)
  {
   /*
   int    window = 0;
   string ID = Indicator_Name + buffNo;
   if(ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
      ObjectSet(ID, OBJPROP_XDISTANCE, x + 25);
   ObjectSet(ID, OBJPROP_YDISTANCE, 5);
   ObjectSetText(ID, sym, 18, "Arial Black", col);
   SetIndexStyle(buffNo, DRAW_LINE, STYLE_SOLID, Line_Thickness, col);
   SetIndexLabel(buffNo, buffLabel);*/
  }

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
  {
   tfs = stringUpperCase(tfs);
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return(MathMax(iTfTable[i], Period()));
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tf == iTfTable[i])
         return(sTfTable[i]);
   return("");
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringUpperCase(string str)
  {
   string   s = str;
   for(int length = StringLen(str) - 1; length >= 0; length--)
     {
      int tchar = StringGetChar(s, length);
      if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
         s = StringSetChar(s, length, tchar - 32);
      else
         if(tchar > -33 && tchar < 0)
            s = StringSetChar(s, length, tchar + 224);
     }
   return(s);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
