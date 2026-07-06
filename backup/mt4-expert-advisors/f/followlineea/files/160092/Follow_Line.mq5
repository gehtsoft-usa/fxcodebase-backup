// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76203

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
#property indicator_buffers 8
#property indicator_plots 4

#define INDICATOR_NAME "FollowLine"
//
#property indicator_label1  "BuySignal"
#property indicator_color1  clrBlue
#property indicator_width1  1
#property indicator_label2  "SellSignal"
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_label3  "BuyLine"
#property indicator_color3  clrBlue
#property indicator_width3  2
#property indicator_label4  "SellLine"
#property indicator_color4  clrRed
#property indicator_width4  2

//
input ENUM_TIMEFRAMES tframe         = PERIOD_CURRENT;  // Multi-timeframe source
input int            ATRperiod       = 5;
input int            BBperiod        = 21;
input double         BBdeviation     = 1.0;
input bool           UseATRfilter    = true;
input bool           showsignals     = true;
input int            MaxBars         = 1000;
enum alert
  {
   Off = 0,
   Current = 1,
   Previous = 2
  };
input alert          notificationsOn = Current;
input bool           desktop_notifications = true;
input bool           email_notifications   = false;
input bool           push_notifications    = false;
input bool           sound_notifications   = false;
input string         sound_file            = "Tick.wav";
//
input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER;    // btn_corner
input string             btn_text              = "Show/Hide";
input string             btn_Font              = "Impact";
input int                btn_FontSize          = 8;                    //btn_font size
input color              btn_text_ON_color     = clrWhite;
input color              btn_text_OFF_color    = clrWhite;
input color              btn_background_color  = C'41,50,56';
input color              btn_border_color      = C'41,50,56';
input int                button_x              = 104;                  //btn__x
input int                button_y              = 20;                   //btn__y
input int                btn_Width             = 80;                   //btn__width
input int                btn_Height            = 20;                   //btn__height
input string             UniquebuttonId        = "KAF";
input int                btn_Subwindow         = 0;
input string             button_note2          = "------------------------------";

double BuyBuffer[];
double SellBuffer[];
double BuyLine[];
double SellLine[];
double BBUpperBuffer[];
double BBLowerBuffer[];
double TrendBuffer[];
double FollowLineBuffer[];

string buttonId;
bool recalc = true;
bool show_data = true;
int OnInit()
  {
   EventSetTimer(1);
   IndicatorSetString(INDICATOR_SHORTNAME, INDICATOR_NAME);
   double val;
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = INDICATOR_NAME + UniquebuttonId;
   if(GlobalVariableGet(buttonId + "_visibility", val))
      show_data = val != 0;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);
   init2();
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init2()
  {
//
   SetIndexBuffer(0, BuyBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BuyLine, INDICATOR_DATA);
   SetIndexBuffer(3, SellLine, INDICATOR_DATA);
   SetIndexBuffer(4, BBUpperBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, BBLowerBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, TrendBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, FollowLineBuffer, INDICATOR_CALCULATIONS);
//
   ArraySetAsSeries(BuyBuffer, true);
   ArraySetAsSeries(SellBuffer, true);
   ArraySetAsSeries(BuyLine, true);
   ArraySetAsSeries(SellLine, true);
   ArraySetAsSeries(BBUpperBuffer, true);
   ArraySetAsSeries(BBLowerBuffer, true);
   ArraySetAsSeries(TrendBuffer, true);
   ArraySetAsSeries(FollowLineBuffer, true);
//
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
//
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, BBperiod);
   PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, BBperiod);
   PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, 1);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_NONE);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(ChartID(), buttonID);
   ObjectCreate(ChartID(), buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(ChartID(), buttonID, OBJPROP_FONT, font);
   ObjectSetString(ChartID(), buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YDISTANCE, 9999);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(buttonId + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start1();
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   start1();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,  
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   handleButtonClicks();
  }

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
   start1();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start1()
  {
   handleButtonClicks();
   recalc = false;
   start2();
   if(show_data)
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
      init2();
     }
   else
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      for(int i = 0; i < indicator_buffers; i++)
         PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start2()
  {
   if(iBars(Symbol(), Period()) < BBperiod || iBars(Symbol(), Period()) < ATRperiod)
      return;
   int limit = MathMin(iBars(Symbol(), Period()) - 2, MaxBars);
   for(int i = limit; i >= 0; i--)
     {
      //
      datetime t = iTime(Symbol(), Period(), i);
      int shift = iBarShift(NULL, tframe, t, true);
      if(shift < 0 || shift > limit)
         continue;
      //
      double upper = iBandsMQL4(NULL, tframe, BBperiod, BBdeviation, 0, PRICE_CLOSE, 1, shift);
      double lower = iBandsMQL4(NULL, tframe, BBperiod, BBdeviation, 0, PRICE_CLOSE, 2, shift);
      double atr   = iATRMQL4(NULL,   tframe, ATRperiod, shift);
      BBUpperBuffer[i] = upper;
      BBLowerBuffer[i] = lower;
      //
      int bbSignal = (iClose(Symbol(), Period(), i) > upper ? 1 : (iClose(Symbol(), Period(), i) < lower ? -1 : 0));
      if(bbSignal == 1)
        {
         FollowLineBuffer[i] = UseATRfilter ? iLow(Symbol(), Period(), i) - atr : iLow(Symbol(), Period(), i);
         if(i < limit && FollowLineBuffer[i] < FollowLineBuffer[i + 1])
            FollowLineBuffer[i] = FollowLineBuffer[i + 1];
        }
      else
         if(bbSignal == -1)
           {
            FollowLineBuffer[i] = UseATRfilter ? iHigh(Symbol(), Period(), i) + atr : iHigh(Symbol(), Period(), i);
            if(i < limit && FollowLineBuffer[i] > FollowLineBuffer[i + 1])
               FollowLineBuffer[i] = FollowLineBuffer[i + 1];
           }
         else
           {
            FollowLineBuffer[i] = (i < limit ? FollowLineBuffer[i + 1] : EMPTY_VALUE);
           }
      //
      if(i < limit)
         TrendBuffer[i] = (FollowLineBuffer[i] > FollowLineBuffer[i + 1] ? 1 :
                           (FollowLineBuffer[i] < FollowLineBuffer[i + 1] ? -1 : TrendBuffer[i + 1]));
      else
         TrendBuffer[i] = 0;
      //
      if(TrendBuffer[i] == 1)
        {
         BuyLine[i] = FollowLineBuffer[i];
         BuyLine[i + 1] = FollowLineBuffer[i + 1];
         SellLine[i] = EMPTY_VALUE;
        }
      else
         if(TrendBuffer[i] == -1)
           {
            SellLine[i] = FollowLineBuffer[i];
            SellLine[i + 1] = FollowLineBuffer[i + 1];
            BuyLine[i] = EMPTY_VALUE;
           }
         else
           {
            BuyLine[i] = EMPTY_VALUE;
            SellLine[i] = EMPTY_VALUE;
           }
      //
      BuyBuffer[i] = SellBuffer[i] = EMPTY_VALUE;
      if(showsignals && i < limit)
        {
         if(TrendBuffer[i + 1] == -1 && TrendBuffer[i] == 1)
            BuyBuffer[i] = FollowLineBuffer[i] - atr;
         if(TrendBuffer[i + 1] == 1  && TrendBuffer[i] == -1)
            SellBuffer[i] = FollowLineBuffer[i] + atr;
        }
     }
//
   if(notificationsOn != Off)
      checkAlert();
  }

//+------------------------------------------------------------------+
bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == Current && !alerted)
     {
      if(BuyBuffer[0]  != EMPTY_VALUE)
        {
         Notify(1);
         alerted = true;
        }
      if(SellBuffer[0] != EMPTY_VALUE)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == Previous && nb)
     {
      if(BuyBuffer[1]  != EMPTY_VALUE)
         Notify(11);
      if(SellBuffer[1] != EMPTY_VALUE)
         Notify(22);
     }
  }
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string txt = "Follow Line:";
   switch(type)
     {
      case 1:
         txt += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         txt += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         txt += " Turn UP after close - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         txt += " Turn DOWN after close - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   txt += " - " + _Symbol + " " + EnumToString(tframe);
   if(desktop_notifications)
      Alert(txt);
   if(push_notifications)
      SendNotification(txt);
   if(email_notifications)
      SendMail("MetaTrader Notification", txt);
   if(sound_notifications)
      PlaySound(sound_file);
  }
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
double iBandsMQL4(string symbol, int tf, int period, double deviation, int bands_shift, int method, int mode, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   int handle = iBands(symbol, timeframe, period,
                       bands_shift, deviation, ma_method);
   if(handle < 0)
     {
      Print("The iBands object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, mode, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iATRMQL4(string symbol, int tf, int period, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iATR(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iATR object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76203

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