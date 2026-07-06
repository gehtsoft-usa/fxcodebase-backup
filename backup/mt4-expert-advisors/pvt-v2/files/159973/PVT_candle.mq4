// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76156&p=159929#p159929

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
#property indicator_plots 0
#property indicator_buffers 1

input int   InpBarLimit  = 400;       // Max bars to draw
input color InpBullColor = clrLime;   // Bull candle color
input color InpBearColor = clrRed;    // Bear candle color
input int ExtPVTAppliedPrice = 0;

double      DirBuffer[];

string indicatorName;
int    bodyWidth, wickWidth;
bool   initialDrawDone = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//
   SetIndexBuffer(0, DirBuffer);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexLabel(0, "PVT Direction");
//
   IndicatorDigits(Digits());
//
   indicatorName = "PVT";
   IndicatorShortName(indicatorName);
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
   double dCurrentPrice, dPreviousPrice;
   nLimit = MathMin(Bars, InpBarLimit);
//
   ArrayResize(DirBuffer, nLimit);
   ArrayInitialize(DirBuffer, EMPTY_VALUE);
//
   for(i = nLimit - 1; i >= 0; i--)
     {
      if(ArraySize(DirBuffer) <= i)
         break;
      if(i == nLimit - 1)
        {
         DirBuffer[i] = (double)Volume[i];
        }
      else
        {
         dCurrentPrice = GetAppliedPrice(ExtPVTAppliedPrice, i);
         dPreviousPrice = GetAppliedPrice(ExtPVTAppliedPrice, i + 1);
         DirBuffer[i] = DirBuffer[i + 1] + Volume[i] * (dCurrentPrice - dPreviousPrice) / dPreviousPrice;
        }
     }
   for(i = nLimit - 1; i >= 0; i--)
     {
      DrawCandle(i, Open[i], High[i], Low[i], Close[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawCandle(int i, double o, double h, double l, double c)
  {
   long t = iTime(Symbol(), Period(), i);
   string base = "SubCandle_" + IntegerToString(i);
   if(bodyWidth <= 0)
      bodyWidth = calculateBodyWidth();
   if(wickWidth <= 0)
      wickWidth = calculateWickWidth();
//
   string bName = base + "_BODY";
   if(ObjectFind(0, bName) >= 0)
      ObjectDelete(0, bName);
   ObjectCreate(0, bName, OBJ_TREND, 0, t, o, t, c);
   ObjectSetInteger(0, bName, OBJPROP_COLOR, (DirBuffer[i] >= DirBuffer[i + 1] ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, bName, OBJPROP_WIDTH, bodyWidth);
   ObjectSetInteger(0, bName, OBJPROP_RAY_RIGHT, false);
//
   string uName = base + "_WICK_UP";
   if(ObjectFind(0, uName) >= 0)
      ObjectDelete(0, uName);
   ObjectCreate(0, uName, OBJ_TREND, 0, t, MathMax(o, c), t, h);
   ObjectSetInteger(0, uName, OBJPROP_COLOR, (DirBuffer[i] >= DirBuffer[i + 1] ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, uName, OBJPROP_WIDTH, wickWidth);
   ObjectSetInteger(0, uName, OBJPROP_RAY_RIGHT, false);
//
   string lName = base + "_WICK_DN";
   if(ObjectFind(0, lName) >= 0)
      ObjectDelete(0, lName);
   ObjectCreate(0, lName, OBJ_TREND, 0, t, MathMin(o, c), t, l);
   ObjectSetInteger(0, lName, OBJPROP_COLOR, (DirBuffer[i] >= DirBuffer[i + 1] ? InpBullColor : InpBearColor));
   ObjectSetInteger(0, lName, OBJPROP_WIDTH, wickWidth);
   ObjectSetInteger(0, lName, OBJPROP_RAY_RIGHT, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:
         dPrice = Close[nIndex];
         break;
      case 1:
         dPrice = Open[nIndex];
         break;
      case 2:
         dPrice = High[nIndex];
         break;
      case 3:
         dPrice = Low[nIndex];
         break;
      case 4:
         dPrice = (High[nIndex] + Low[nIndex]) / 2.0;
         break;
      case 5:
         dPrice = (High[nIndex] + Low[nIndex] + Close[nIndex]) / 3.0;
         break;
      case 6:
         dPrice = (High[nIndex] + Low[nIndex] + 2 * Close[nIndex]) / 4.0;
         break;
      default:
         dPrice = 0.0;
     }
//----
   return(dPrice);
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
   bodyWidth = calculateBodyWidth();
   wickWidth = calculateWickWidth();
   drawBars();
   initialDrawDone = true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76156&p=159929#p159929

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