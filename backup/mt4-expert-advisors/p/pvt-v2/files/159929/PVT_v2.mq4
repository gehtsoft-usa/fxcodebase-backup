// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76156

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
#property indicator_separate_window
#property indicator_buffers 4

input int   InpBarLimit  = 400;       // Max bars to draw
input color InpBullColor = clrLime;   // Bull candle color
input color InpBearColor = clrRed;    // Bear candle color
double      ExtOpenBuffer[];
double      ExtHighBuffer[];
double      ExtCloseBuffer[];
double      ExtLowBuffer[];

string indicatorName;
int    subWindowIndex = -1;
int    bodyWidth, wickWidth;
bool   initialDrawDone = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//
   SetIndexBuffer(0, ExtOpenBuffer);
   SetIndexBuffer(1, ExtHighBuffer);
   SetIndexBuffer(2, ExtCloseBuffer);
   SetIndexBuffer(3, ExtLowBuffer);
//
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
//
   SetIndexLabel(0, "PVT Open");
   SetIndexLabel(1, "PVT High");
   SetIndexLabel(2, "PVT Close");
   SetIndexLabel(3, "PVT Low");
//
   IndicatorDigits(Digits());
//
   indicatorName = "PVT";
   IndicatorShortName(indicatorName);
   subWindowIndex = -1;
   initialDrawDone = false;
   bodyWidth = calculateBodyWidth();
   wickWidth = calculateWickWidth();
   ObjectsDeleteAll(0, "SubCandle_");
   EventSetTimer(1);
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, "SubCandle_");
  }

//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   drawBars();
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawBars()
  {
   int i, nLimit;
   nLimit = MathMin(Bars, InpBarLimit);
//
   ArrayResize(ExtOpenBuffer, nLimit);
   ArrayResize(ExtCloseBuffer, nLimit);
   ArrayResize(ExtHighBuffer, nLimit);
   ArrayResize(ExtLowBuffer, nLimit);
//
   ArrayInitialize(ExtOpenBuffer, EMPTY_VALUE);
   ArrayInitialize(ExtCloseBuffer, EMPTY_VALUE);
   ArrayInitialize(ExtHighBuffer, EMPTY_VALUE);
   ArrayInitialize(ExtLowBuffer, EMPTY_VALUE);
   for(i = nLimit - 1; i >= 0; i--)
     {
      if(ArraySize(ExtOpenBuffer) <= i || ArraySize(ExtCloseBuffer) <= i ||
         ArraySize(ExtHighBuffer) <= i || ArraySize(ExtLowBuffer) <= i)
         break;
      if(i == nLimit - 1)
        {
         ExtOpenBuffer[i]  = (double)Volume[i];
         ExtHighBuffer[i]  = (double)Volume[i];
         ExtCloseBuffer[i] = (double)Volume[i];
         ExtLowBuffer[i]   = (double)Volume[i];
        }
      else
        {
         ExtOpenBuffer[i]  = ExtOpenBuffer[i + 1] + Volume[i] * (Open[i] - Open[i + 1]) / Open[i + 1];
         ExtHighBuffer[i]  = ExtHighBuffer[i + 1] + Volume[i] * (High[i] - High[i + 1]) / High[i + 1];
         ExtCloseBuffer[i] = ExtCloseBuffer[i + 1] + Volume[i] * (Close[i] - Close[i + 1]) / Close[i + 1];
         ExtLowBuffer[i]   = ExtLowBuffer[i + 1] + Volume[i] * (Low[i] - Low[i + 1]) / Low[i + 1];
        }
      DrawCandle(i, ExtOpenBuffer[i], ExtHighBuffer[i], ExtLowBuffer[i], ExtCloseBuffer[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawCandle(int i, double o, double h, double l, double c)
  {
   if(subWindowIndex < 0)
     {
      subWindowIndex = WindowFind(indicatorName);
      if(subWindowIndex < 0)
        {
         Print("SubwindowCandles: Subwindow not found for '", indicatorName, "'");
         return;
        }
     }
   long   t    = iTime(Symbol(), Period(), i);
   string base = "SubCandle_" + IntegerToString(i);
   if(bodyWidth <= 0)
      bodyWidth = calculateBodyWidth();
   if(wickWidth <= 0)
      wickWidth = calculateWickWidth();
//
   string bName = base + "_BODY";
   if(ObjectFind(0, bName) >= 0)
      ObjectDelete(0, bName); // Delete if exists
   ObjectCreate(0, bName, OBJ_TREND, subWindowIndex, t, o, t, c);
   ObjectSetInteger(0, bName, OBJPROP_COLOR, (c > o ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, bName, OBJPROP_WIDTH, bodyWidth);
   ObjectSetInteger(0, bName, OBJPROP_RAY_RIGHT, false);
//
   string uName = base + "_WICK_UP";
   if(ObjectFind(0, uName) >= 0)
      ObjectDelete(0, uName); // Delete if exists
   ObjectCreate(0, uName, OBJ_TREND, subWindowIndex, t, MathMax(o, c), t, h);
   ObjectSetInteger(0, uName, OBJPROP_COLOR, (c > o ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, uName, OBJPROP_WIDTH, wickWidth);
   ObjectSetInteger(0, uName, OBJPROP_RAY_RIGHT, false);
//
   string lName = base + "_WICK_DN";
   if(ObjectFind(0, lName) >= 0)
      ObjectDelete(0, lName); // Delete if exists
   ObjectCreate(0, lName, OBJ_TREND, subWindowIndex, t, MathMin(o, c), t, l);
   ObjectSetInteger(0, lName, OBJPROP_COLOR, (c > o ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, lName, OBJPROP_WIDTH, wickWidth);
   ObjectSetInteger(0, lName, OBJPROP_RAY_RIGHT, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int calculateBodyWidth()
  {
   int chartScale = (int)ChartGetInteger(0, CHART_SCALE, 0);
   switch(chartScale)
     {
      case 2:
         return (3);
         break;
      case 3:
         return (5);
         break;
      case 4:
         return (8);
         break;
      case 5:
         return (16);
         break;
     }
   return (chartScale);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int calculateWickWidth()
  {
   int chartScale = (int)ChartGetInteger(0, CHART_SCALE, 0);
   switch(chartScale)
     {
      case 1:
         return (1);
         break;
      case 2:
         return (1);
         break;
      case 3:
         return (1);
         break;
      case 4:
         return (2);
         break;
      case 5:
         return (2);
         break;
     }
   return (chartScale);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      subWindowIndex = -1;
      bodyWidth = calculateBodyWidth();
      wickWidth = calculateWickWidth();
      ObjectsDeleteAll(0, "SubCandle_");
      Sleep(100);
      drawBars();
      Comment((string)ChartGetInteger(0, CHART_SCALE, 0));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(subWindowIndex < 0)
     {
      subWindowIndex = WindowFind(indicatorName);
     }
   if(subWindowIndex >= 0)
     {
      bodyWidth = calculateBodyWidth();
      wickWidth = calculateWickWidth();
      drawBars();
      initialDrawDone = true;
      EventKillTimer();
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76156

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