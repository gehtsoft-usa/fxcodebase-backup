//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76272 

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
#property indicator_buffers 0
#property indicator_plots   0

#property indicator_chart_window
SetIndexBuffer(0,ED,INDICATOR_CALCULATIONS)
enum mode
  {
   Standard,
   Fibonacci,
   Camarilla,
   Woodie,
   Demark
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lbCorner
  {
   TopLeft     = 0,  // Top Left
   TopRight    = 3,  // Top Right
   BottomLeft  = 1,  // Bottom Left
   BottomRight = 2   // Bottom Right
  };
input mode            Pmode       = Standard;         // Pivot Mode
input ENUM_TIMEFRAMES inpPeriod   = PERIOD_D1;        // Pivot Time Frame
input bool            HLINE       = false;            // Full Horizontal Lines
input int             xShift      = 3;                // X-Axis Shift
input int             xLen        = 25;               // Line Length
input lbCorner        LabelCorner = TopRight;         // Label Corner
input int             LabelXOffset = 150;             // Label X offset
input int             LabelYOffset = 20;             // Label Y offset
input color           LevelPP     = SpringGreen;      // Pivot Point
input ENUM_LINE_STYLE StylePP     = STYLE_SOLID;      // Line Style
input int             WidthPP     = 1;                // Line Width
input color           LevelR1     = Crimson;          // R1
input ENUM_LINE_STYLE StyleR1     = STYLE_DASH;       // Line Style
input int             WidthR1     = 1;                // Line Width
input color           LevelR2     = Crimson;          // R2
input ENUM_LINE_STYLE StyleR2     = STYLE_DOT;        // Line Style
input int             WidthR2     = 1;                // Line Width
input color           LevelR3     = Crimson;          // R3
input ENUM_LINE_STYLE StyleR3     = STYLE_SOLID;      // Line Style
input int             WidthR3     = 1;                // Line Width
input color           LevelS1     = DodgerBlue;       // S1
input ENUM_LINE_STYLE StyleS1     = STYLE_DASH;       // Line Style
input int             WidthS1     = 1;                // Line Width
input color           LevelS2     = DodgerBlue;       // S2
input ENUM_LINE_STYLE StyleS2     = STYLE_DOT;        // Line Style
input int             WidthS2     = 1;                // Line Width
input color           LevelS3     = DodgerBlue;       // S3
input ENUM_LINE_STYLE StyleS3     = STYLE_SOLID;      // Line Style
input int             WidthS3     = 1;                // Line Width
input color           LevelYH     = MediumVioletRed;  // Yesterday's High
input ENUM_LINE_STYLE StyleYH     = STYLE_DASH;       // Line Style
input int             WidthYH     = 3;                // Line Width
input color           LevelYL     = MediumSlateBlue;  // Yesterday's Low
input ENUM_LINE_STYLE StyleYL     = STYLE_DASH;       // Line Style
input int             WidthYL     = 3;                // Line Width
input string          Font        = "Arial";          // Font
input int             FontSize    = 8;                // Font Size
input int             PivotBar    = 1;                // Bar (EXPERIMENTAL! current=0; default=1)

input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input int    hoursBetweenAlerts    = 4;                      // Hours Between Alerts

datetime     timeNextAlert         = 0;
double x, xR1, xR2, xR3, xS1, xS2, xS3, xPP;
int    LINE_TYPE;

double     prices[7];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   int xOffset = LabelXOffset;
   int yOffset = LabelYOffset;
   int Line    = 5 + FontSize;
   if(HLINE)
      LINE_TYPE = OBJ_HLINE;
   else
      LINE_TYPE = OBJ_TREND;
   if(LabelCorner == 0 || LabelCorner == 3)
     {
      ObjectMakeLabel("pInfo", xOffset, yOffset);
      ObjectMakeLabel("lbR3", xOffset, Line + yOffset);
      ObjectMakeLabel("lbR2", xOffset, 2 * Line + yOffset);
      ObjectMakeLabel("lbR1", xOffset, 3 * Line + yOffset);
      ObjectMakeLabel("lbPP", xOffset, 4 * Line + yOffset);
      ObjectMakeLabel("lbS1", xOffset, 5 * Line + yOffset);
      ObjectMakeLabel("lbS2", xOffset, 6 * Line + yOffset);
      ObjectMakeLabel("lbS3", xOffset, 7 * Line + yOffset);
     }
   else
     {
      ObjectMakeLabel("lbS3", xOffset, yOffset);
      ObjectMakeLabel("lbS2", xOffset, Line + yOffset);
      ObjectMakeLabel("lbS1", xOffset, 2 * Line + yOffset);
      ObjectMakeLabel("lbPP", xOffset, 3 * Line + yOffset);
      ObjectMakeLabel("lbR1", xOffset, 4 * Line + yOffset);
      ObjectMakeLabel("lbR2", xOffset, 5 * Line + yOffset);
      ObjectMakeLabel("lbR3", xOffset, 6 * Line + yOffset);
      ObjectMakeLabel("pInfo", 10, 7 * Line + yOffset);
     }
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DrawLevel("R3", 0.0, StyleR3, WidthR3, LevelR3);
   DrawLevel("R2", 0.0, StyleR2, WidthR2, LevelR2);
   DrawLevel("R1", 0.0, StyleR1, WidthR1, LevelR1);
   DrawLevel("PP", 0.0, StylePP, WidthPP, LevelPP);
   DrawLevel("S1", 0.0, StyleS1, WidthS1, LevelS1);
   DrawLevel("S2", 0.0, StyleS2, WidthS2, LevelS2);
   DrawLevel("S3", 0.0, StyleS3, WidthS3, LevelS3);
   DrawLevel("Yesterdays High", 0.0, StyleYH, WidthYH, LevelYH);
   DrawLevel("Yesterdays Low", 0.0, StyleYL, WidthYL, LevelYL);
   long chart_id = ChartID();
   ObjectDelete(chart_id, "pInfo");
   ObjectDelete(chart_id, "lbR3");
   ObjectDelete(chart_id, "lbR2");
   ObjectDelete(chart_id, "lbR1");
   ObjectDelete(chart_id, "lbPP");
   ObjectDelete(chart_id, "lbS1");
   ObjectDelete(chart_id, "lbS2");
   ObjectDelete(chart_id, "lbS3");
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
   double xYH = iHigh(_Symbol, PERIOD_D1, 1);
   double xYL = iLow(_Symbol, PERIOD_D1, 1);
   double xOpen  = iOpen(_Symbol, inpPeriod, PivotBar);
   double xClose = iClose(_Symbol, inpPeriod, PivotBar);
   double xHigh  = iHigh(_Symbol, inpPeriod, PivotBar);
   double xLow   = iLow(_Symbol, inpPeriod, PivotBar);
   xPP = (xHigh + xLow + xClose) / 3.0;
   double xRange = xHigh - xLow;
   if(Pmode == Standard)
     {
      xR1 = (2.0 * xPP) - xLow;
      xS1 = (2.0 * xPP) - xHigh;
      xR2 = xPP + xRange;
      xS2 = xPP - xRange;
      xR3 = xHigh + 2.0 * (xPP - xLow);
      xS3 = xLow - 2.0 * (xHigh - xPP);
     }
   else
      if(Pmode == Fibonacci)
        {
         xR1 = xPP + 0.382 * xRange;
         xR2 = xPP + 0.618 * xRange;
         xR3 = xPP + 1.000 * xRange;
         xS1 = xPP - 0.382 * xRange;
         xS2 = xPP - 0.618 * xRange;
         xS3 = xPP - 1.000 * xRange;
        }
      else
         if(Pmode == Camarilla)
           {
            xR1 = xClose + (0.275 * xRange);
            xR2 = xClose + (0.55  * xRange);
            xR3 = (xHigh / xLow) * xClose;
            xS1 = xClose - (0.275 * xRange);
            xS2 = xClose - (0.55  * xRange);
            xS3 = xClose - (xR3 - xClose);
           }
         else
            if(Pmode == Woodie)
              {
               xPP = (xHigh + xLow + 2.0 * xClose) / 4.0;
               xR1 = 2.0 * xPP - xLow;
               xR2 = xPP + xRange;
               xR3 = 0.0;
               xS1 = 2.0 * xPP - xHigh;
               xS2 = xPP - xRange;
               xS3 = 0.0;
              }
            else
               if(Pmode == Demark)
                 {
                  if(xClose < xOpen)
                     x = xHigh + (2.0 * xLow) + xClose;
                  else
                     if(xClose > xOpen)
                        x = (2.0 * xHigh) + xLow + xClose;
                     else
                        x = xHigh + xLow + (2.0 * xClose);
                  xPP = 0.0;
                  xR3 = x / 2.0 - xLow;
                  xS3 = x / 2.0 - xHigh;
                  xR1 = 0.0;
                  xR2 = 0.0;
                  xS1 = 0.0;
                  xS2 = 0.0;
                 }
   DisplayMode();
   if((int)inpPeriod >= Period())
     {
      if(Period() <= PERIOD_D1)
        {
         DrawLevel("Yesterdays High", xYH, StyleYH, WidthYH, LevelYH);
         DrawLevel("Yesterdays Low",  xYL, StyleYL, WidthYL, LevelYL);
        }
      DrawLevel("R3", xR3, StyleR3, WidthR3, LevelR3);
      DrawLevel("R2", xR2, StyleR2, WidthR2, LevelR2);
      DrawLevel("R1", xR1, StyleR1, WidthR1, LevelR1);
      DrawLevel("PP", xPP, StylePP, WidthPP, LevelPP);
      DrawLevel("S1", xS1, StyleS1, WidthS1, LevelS1);
      DrawLevel("S2", xS2, StyleS2, WidthS2, LevelS2);
      DrawLevel("S3", xS3, StyleS3, WidthS3, LevelS3);
     }
   else
     {
      DrawLevel("PP", xPP, StylePP, WidthPP, LevelPP);
     }
   prices[0] = xR3;
   prices[1] = xR2;
   prices[2] = xR1;
   prices[3] = xPP;
   prices[4] = xS1;
   prices[5] = xS2;
   prices[6] = xS3;
   checkPricesForAlerts();
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLevel(string a_name_0, double ad, ENUM_LINE_STYLE a_style, int Width, color a_color)
  {
   double l_price = ad;
   datetime l_timeA;
   datetime l_timeB;
   double   diff = PeriodSeconds(Period());
   l_timeA = (datetime)(iTime(_Symbol, Period(), 0) + xShift * diff);
   l_timeB = (datetime)(iTime(_Symbol, Period(), 0) - xLen - xShift * diff);
   long chart_id = ChartID();
   if(ad > 0.0)
     {
      if(ObjectFind(chart_id, a_name_0) == -1)
        {
         if(!ObjectCreate(chart_id, a_name_0, (ENUM_OBJECT)LINE_TYPE, 0, l_timeA, l_price, l_timeB, l_price))
            return;
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_RAY, false);
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_COLOR, a_color);
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_WIDTH, Width);
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_STYLE, a_style);
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(chart_id, a_name_0, OBJPROP_HIDDEN, true);
         return;
        }
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_RAY, false);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_TIME, 0, l_timeA);
      ObjectSetDouble(chart_id, a_name_0, OBJPROP_PRICE, 0, l_price);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_TIME, 1, l_timeB);
      ObjectSetDouble(chart_id, a_name_0, OBJPROP_PRICE, 1, l_price);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_COLOR, a_color);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_WIDTH, Width);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_STYLE, a_style);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(chart_id, a_name_0, OBJPROP_HIDDEN, true);
      return;
     }
   if(ObjectFind(chart_id, a_name_0) >= 0)
      ObjectDelete(chart_id, a_name_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectMakeLabel(string n, int xoff, int yoff)
  {
   long chart_id = ChartID();
   if(chart_id == 0)
      return(-1);
   if(!ObjectCreate(chart_id, n, OBJ_LABEL, 0, 0, 0))
      return(-1);
   ObjectSetInteger(chart_id, n, OBJPROP_CORNER, (int)LabelCorner);
   ObjectSetInteger(chart_id, n, OBJPROP_XDISTANCE, xoff);
   ObjectSetInteger(chart_id, n, OBJPROP_YDISTANCE, yoff);
   ObjectSetInteger(chart_id, n, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, n, OBJPROP_HIDDEN, true);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayMode()
  {
   string sR3, sR2, sR1, sPP, sS1, sS2, sS3, sPointer;
   sR3 = "";
   sR2 = "";
   sR1 = "";
   sPP = "";
   sS1 = "";
   sS2 = "";
   sS3 = "";
   if(LabelCorner < 2)
      sPointer = ">> ";
   else
      sPointer = "";
   double vbid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(vbid >= xR3)
     {
      sR3 = sPointer;
     }
   else
      if(vbid >= xR2)
        {
         sR2 = sPointer;
        }
      else
         if(vbid >= xR1)
           {
            sR1 = sPointer;
           }
         else
            if(vbid > xS1)
              {
               sPP = sPointer;
              }
            else
               if(vbid <= xS3)
                 {
                  sS3 = sPointer;
                 }
               else
                  if(vbid <= xS2)
                    {
                     sS2 = sPointer;
                    }
                  else
                     if(vbid <= xS1)
                       {
                        sS1 = sPointer;
                       }
   string pivPeriod = "M" + IntegerToString((int)inpPeriod);
   if(inpPeriod >= PERIOD_H1)
      pivPeriod = "H" + IntegerToString((int)(inpPeriod / PERIOD_H1));
   if(inpPeriod >= PERIOD_D1)
      pivPeriod = "D1";
   if(inpPeriod >= PERIOD_W1)
      pivPeriod = "WK";
   if(inpPeriod >= PERIOD_MN1)
      pivPeriod = "MN";
   string pivInfo = EnumToString(Pmode) + " (" + pivPeriod + ")";
   long chart_id = ChartID();
   if(LabelCorner < 2)
     {
      ObjectSetString(chart_id, "pInfo", OBJPROP_TEXT, pivInfo);
      ObjectSetInteger(chart_id, "pInfo", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "pInfo", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "pInfo", OBJPROP_COLOR, clrBlack);
      ObjectSetString(chart_id, "lbR3", OBJPROP_TEXT, sR3 + "R3 = " + DoubleToString(xR3, _Digits));
      ObjectSetInteger(chart_id, "lbR3", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR3", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR3", OBJPROP_COLOR, LevelR3);
      ObjectSetString(chart_id, "lbR2", OBJPROP_TEXT, sR2 + "R2 = " + DoubleToString(xR2, _Digits));
      ObjectSetInteger(chart_id, "lbR2", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR2", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR2", OBJPROP_COLOR, LevelR2);
      ObjectSetString(chart_id, "lbR1", OBJPROP_TEXT, sR1 + "R1 = " + DoubleToString(xR1, _Digits));
      ObjectSetInteger(chart_id, "lbR1", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR1", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR1", OBJPROP_COLOR, LevelR1);
      ObjectSetString(chart_id, "lbPP", OBJPROP_TEXT, sPP + "PP = " + DoubleToString(xPP, _Digits));
      ObjectSetInteger(chart_id, "lbPP", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbPP", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbPP", OBJPROP_COLOR, LevelPP);
      ObjectSetString(chart_id, "lbS1", OBJPROP_TEXT, sS1 + "S1 = " + DoubleToString(xS1, _Digits));
      ObjectSetInteger(chart_id, "lbS1", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS1", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS1", OBJPROP_COLOR, LevelS1);
      ObjectSetString(chart_id, "lbS2", OBJPROP_TEXT, sS2 + "S2 = " + DoubleToString(xS2, _Digits));
      ObjectSetInteger(chart_id, "lbS2", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS2", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS2", OBJPROP_COLOR, LevelS2);
      ObjectSetString(chart_id, "lbS3", OBJPROP_TEXT, sS3 + "S3 = " + DoubleToString(xS3, _Digits));
      ObjectSetInteger(chart_id, "lbS3", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS3", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS3", OBJPROP_COLOR, LevelS3);
     }
   else
     {
      ObjectSetString(chart_id, "pInfo", OBJPROP_TEXT, pivInfo);
      ObjectSetInteger(chart_id, "pInfo", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "pInfo", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "pInfo", OBJPROP_COLOR, clrBlack);
      ObjectSetString(chart_id, "lbR3", OBJPROP_TEXT, "R3 = " + DoubleToString(xR3, _Digits) + sR3);
      ObjectSetInteger(chart_id, "lbR3", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR3", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR3", OBJPROP_COLOR, LevelR3);
      ObjectSetString(chart_id, "lbR2", OBJPROP_TEXT, "R2 = " + DoubleToString(xR2, _Digits) + sR2);
      ObjectSetInteger(chart_id, "lbR2", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR2", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR2", OBJPROP_COLOR, LevelR2);
      ObjectSetString(chart_id, "lbR1", OBJPROP_TEXT, "R1 = " + DoubleToString(xR1, _Digits) + sR1);
      ObjectSetInteger(chart_id, "lbR1", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbR1", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbR1", OBJPROP_COLOR, LevelR1);
      ObjectSetString(chart_id, "lbPP", OBJPROP_TEXT, "PP = " + DoubleToString(xPP, _Digits) + sPP);
      ObjectSetInteger(chart_id, "lbPP", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbPP", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbPP", OBJPROP_COLOR, LevelPP);
      ObjectSetString(chart_id, "lbS1", OBJPROP_TEXT, "S1 = " + DoubleToString(xS1, _Digits) + sS1);
      ObjectSetInteger(chart_id, "lbS1", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS1", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS1", OBJPROP_COLOR, LevelS1);
      ObjectSetString(chart_id, "lbS2", OBJPROP_TEXT, "S2 = " + DoubleToString(xS2, _Digits) + sS2);
      ObjectSetInteger(chart_id, "lbS2", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS2", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS2", OBJPROP_COLOR, LevelS2);
      ObjectSetString(chart_id, "lbS3", OBJPROP_TEXT, "S3 = " + DoubleToString(xS3, _Digits) + sS3);
      ObjectSetInteger(chart_id, "lbS3", OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(chart_id, "lbS3", OBJPROP_FONT, Font);
      ObjectSetInteger(chart_id, "lbS3", OBJPROP_COLOR, LevelS3);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(double _price)
  {
   if(!notifications)
      return;
   string text = "PRICE TOUCHED PIVOT PRICE VALUE: " + (string)NormalizeDouble(_price, _Digits);
   text += "in: " + _Symbol;
   if(TimeCurrent() >= timeNextAlert)
     {
      if(desktop_notifications)
         Alert(text);
      if(push_notifications)
         SendNotification(text);
      if(email_notifications)
         SendMail("MetaTrader Notification", text);
      timeNextAlert = TimeCurrent() + hoursBetweenAlerts * 60 * 60;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkPricesForAlerts()
  {
   for(int i = 0; i < ArraySize(prices); i++)
     {
      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= prices[i] && SymbolInfoDouble(_Symbol, SYMBOL_BID) < prices[i])
        {
         Notifications(prices[i]);
        }
     }
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76272 

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