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
//
extern string             button_note1_         = "------------------------------";
extern int                btn_Subwindow         = 0;                               // What window to put the button on.  If <0, the button will use the same sub-window as the indicator.
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;               // button corner on chart for anchoring
extern string             btn_text              = "WPR";                           // a button name
extern string             btn_Font              = "Arial";                         // button font name
extern int                btn_FontSize          = 9;                               // button font size
extern color              btn_text_ON_color     = clrLime;                         // ON color when the button is turned on
extern color              btn_text_OFF_color    = clrRed;                          // OFF color when the button is turned off
extern color              btn_background_color  = clrDimGray;                      // background color of the button
extern color              btn_border_color      = clrBlack;                        // border color the button
extern int                button_x              = 20;                              // x coordinate of the button
extern int                button_y              = 25;                              // y coordinate of the button
extern int                btn_Width             = 80;                              // button width
extern int                btn_Height            = 20;                              // button height
extern string             UniqueButtonID        = "WPRobos";                       // Unique ID for each button
extern string             button_note2          = "------------------------------";

//--- indicator buffers
double WPRBuffer[];
double MABuffer[];
bool show_data, recalc = false;
string IndicatorObjPrefix, buttonId;
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
   IndicatorObjPrefix = "__" + btn_text + "__";
// The leading "_" gives buttonId a *unique* prefix.  Furthermore, prepending the swin is usually unique unless >2+ of THIS indy are displayed in the SAME sub-window. (But, if >2 used, be sure to shift the buttonId position)
   buttonId = "_" + UniqueButtonID + IndicatorObjPrefix + "_BT_";
   if(ObjectFind(buttonId) < 0)
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   OnInit2();
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit2()
  {
   if(show_data)
     {
      ObjectSetInteger(0, buttonId, OBJPROP_COLOR, btn_text_ON_color);
      SetLevelValue(0, oversold);
      SetLevelValue(1, overbought);
      SetIndexStyle(0, DRAW_LINE);
      SetIndexStyle(1, DRAW_LINE);
     }
   else
     {
      ObjectSetInteger(0, buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      SetLevelValue(0, EMPTY_VALUE);
      SetLevelValue(1, EMPTY_VALUE);
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createButton(string buttonID, string buttonText, int width2, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(0, buttonID);
   ObjectCreate(0, buttonID, OBJ_BUTTON, btn_Subwindow, 0, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width2);
   ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(0, buttonID, OBJPROP_FONT, font);
   ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
// Upon creation, set the initial state to "true" which is "on", so one will see the indicator by default
   ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// If just changing a TF', the button need not be deleted, therefore the 'OBJPROP_STATE' is also preserved.
   if(reason != REASON_CHARTCHANGE)
      ObjectDelete(buttonId);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit2()
  {
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long & lparam,
                  const double & dparam,
                  const string & sparam)
  {
// If another indy on the same chart has enabled events for create/delete/mouse-move, just skip this events up front because they aren't
//    needed, AND in the worst case, this indy might cause MT4 to hang!!  Skipping the events seems to help, along with other (major) changes to the code below.
   if(id == CHARTEVENT_OBJECT_CREATE || id == CHARTEVENT_OBJECT_DELETE)
      return; // This appears to make this indy compatible with other programs that enabled CHART_EVENT_OBJECT_CREATE and/or CHART_EVENT_OBJECT_DELETE
   if(id == CHARTEVENT_MOUSE_MOVE    || id == CHARTEVENT_MOUSE_WHEEL)
      return; // If this, or another program, enabled mouse-events, these are not needed below, so skip it unless actually needed.
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
     {
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      if(show_data)
        {
         ObjectSetInteger(0, buttonId, OBJPROP_COLOR, btn_text_ON_color);
         OnInit2();
         SetLevelValue(0, overbought);
         SetLevelValue(1, oversold);
         // Is it a problem to call 'start()' ??  Possibly it makes no difference, but now calling "mystart()" instead of "start()"; and "start()" simply runs "mystart()", so should be same as before.
         recalc = true;
         myStart(true);
        }
      else
        {
         ObjectSetInteger(0, buttonId, OBJPROP_COLOR, btn_text_OFF_color);
         for(int ForexStation = 0; ForexStation < indicator_buffers; ForexStation++)
            SetIndexStyle(ForexStation, DRAW_NONE);
         SetLevelValue(0, EMPTY_VALUE);
         SetLevelValue(1, EMPTY_VALUE);
         deinit2();
        }
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime & time[], const double & open[], const double & high[], const double & low[], const double & close[], const long & tick_volume[], const long & volume[], const int &spread[])
  {
   myStart(false);
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int myStart(bool fr)
  {
   int start, i;
   if(IndicatorCounted() == 0 || fr)
     {
      start = Bars - N;
     }
   else
     {
      start = Bars - (IndicatorCounted() - 1);
     }
   for(i = start; i >= 0; i--)
     {
      double maxHigh = iHigh(Symbol(), Period(), iHighest(NULL, 0, MODE_HIGH, N, i));
      double minLow  = iLow(Symbol(), Period(), iLowest(NULL, 0, MODE_LOW, N, i));
      WPRBuffer[i]   = -100 * (maxHigh - iClose(Symbol(), Period(), i)) / (maxHigh - minLow);
      double sum = 0;
      for(int j = 0; j < Period; j++)
        {
         sum += WPRBuffer[i + j];
        }
      MABuffer[i] = sum / Period;
     }
//
   if(show_data)
     {
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
     }
   return 0;
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

//+------------------------------------------------------------------+
