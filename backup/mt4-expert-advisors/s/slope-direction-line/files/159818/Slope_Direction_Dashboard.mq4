// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=159133#p159133

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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
#property indicator_plots   1
#property indicator_buffers 1
#property strict

extern int       period=20; 
extern ENUM_MA_METHOD       method=2;                         // MA Mode:
extern ENUM_APPLIED_PRICE       price=0;                          // Price: 

 


//
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite;
input color    Confirmed_Up_Color       = clrGreen; // Confirmed up color
input color    Confirmed_Dn_Color       = clrRed; // Confirmed down color
input color    Neutral_Color            = clrDarkGray;
input int      x_shift                  = 100; // X coordinate
input int      y_shift                  = 50;  // Y coordinate

enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 0;                      // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

enum DisplayMode { Horizontal, Vertical };
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height

#define MAX_TIMEFRAMES 9
ENUM_TIMEFRAMES timeframes[MAX_TIMEFRAMES] =
  {
   PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30,
   PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1
  };
bool includes[MAX_TIMEFRAMES];
string shortName;
long chart_id = 0;
string fileName;
int iCustom_handle;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   includes[0] = Include_M1;
   includes[1] = Include_M5;
   includes[2] = Include_M15;
   includes[3] = Include_M30;
   includes[4] = Include_H1;
   includes[5] = Include_H4;
   includes[6] = Include_D1;
   includes[7] = Include_W1;
   includes[8] = Include_MN1;
//
   shortName = "FollowLine_Dashboard";
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
   chart_id = ChartID();
   EventSetTimer(1);
//
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(chart_id, shortName);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   DrawDashboard();
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(MQLInfoInteger(MQL_TESTER) == 0)
      DrawDashboard();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeframeStr(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
     }
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   ObjectsDeleteAll(chart_id, shortName);
   string pairList[];
   StringSplit(Pairs, ',', pairList);
   int rows = 0;
   int col = 0;
   int shiftX = x_shift;
   int shiftY = y_shift;
   int tf_count = 0;
   string sym, tf;
   double val0;
   int i, j, c;
   for(i = 0; i < MAX_TIMEFRAMES; i++)
     {
      if(!includes[i])
         continue;
      tf_count++;
     }
//
   if(display_mode == Vertical)
     {
      rows = ArraySize(pairList);
      col = 0;
      for(j = 0; j < rows; j++)
        {
         sym = pairList[j];
         DrawLabel(shortName + "_label_row_" + sym, sym, shiftX - cell_width, shiftY + cell_height * j, Labels_Color);
        }
      for(i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         tf = GetTimeframeStr(timeframes[i]);
         DrawLabel(shortName + "_label_" + tf, GetTimeframeStr(timeframes[i]), shiftX + cell_width * col, shiftY - cell_height, Labels_Color);
         col++;
        }
     }
   else
     {
      rows = 0;
      col = ArraySize(pairList);
      for(j = 0; j < col; j++)
        {
         sym = pairList[j];
         DrawLabel(shortName + "_label_row_" + sym, sym, shiftX + cell_width * j, shiftY - cell_height, Labels_Color);
        }
      for(i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         tf = GetTimeframeStr(timeframes[i]);
         DrawLabel(shortName + "_label_row_" + tf, GetTimeframeStr(timeframes[i]), shiftX - cell_width, shiftY + cell_height * rows, Labels_Color);
         rows++;
        }
     }
   if(display_mode == Horizontal)
     {
      int tf_index = 0;
      for(i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         tf = EnumToString(timeframes[i]);
         for(j = 0; j < ArraySize(pairList); j++)
           {
            sym = pairList[j];
            val0 = 0;
            c = 0;
            if(maCalc(sym, timeframes[i]) > 0)
              {
               val0 = 1;
              }
            if(maCalc(sym, timeframes[i]) < 0)
              {
               val0 = -1;
              }
            string label = (val0 == 1) ? "Buy" : (val0 == -1) ? "Sell" : "-";
            state += (label == "Buy") ? "b" : (label == "Sell") ? "s" : "-";
            color clr = (val0 == 1) ? Confirmed_Up_Color : (val0 == -1) ? Confirmed_Dn_Color : Neutral_Color;
            string name = shortName + "_h_" + tf + "_" + sym;
            int x = shiftX + cell_width * j;
            int y = shiftY + cell_height * tf_index;
            DrawLabel(name, label, x, y, clr);
           }
         tf_index++;
        }
     }
   else
     {
      int row = 0;
      for(j = 0; j < rows; j++)
        {
         sym = pairList[j];
         col = 0;
         for(i = 0; i < MAX_TIMEFRAMES; i++)
           {
            if(!includes[i])
               continue;
            tf = EnumToString(timeframes[i]);
            val0 = 0;
            c = 0;
            if(maCalc(sym, timeframes[i]) > 0)
              {
               val0 = 1;
              }
            if(maCalc(sym, timeframes[i]) < 0)
              {
               val0 = -1;
              }
            string label = (val0 == 1) ? "Buy" : (val0 == -1) ? "Sell" : "-";
            state += (label == "Buy") ? "b" : (label == "Sell") ? "s" : "-";
            color clr = (val0 == 1) ? Confirmed_Up_Color : (val0 == -1) ? Confirmed_Dn_Color : Neutral_Color;
            string name = shortName + "_v_" + tf + "_" + sym;
            int x = shiftX + cell_width * col;
            int y = shiftY + cell_height * row;
            DrawLabel(name, label, x, y, clr);
            col++;
           }
         row++;
        }
     }
   ChartRedraw(chart_id);
   if(notificationsOn > 0)
      checkAlert(state);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int maCalc(string sym, ENUM_TIMEFRAMES tf)
  {
#define PARAM sym, tf, "Slope Direction Line", period, method, price
   if(iCustom(PARAM, 0, 0) <= iClose(sym, tf, 0))
      return 1;
   else
      return -1;
   return 0;
  }

bool alerted;
static string oldState = "";
static string state;
void checkAlert(string state2)
  {
   if(oldState == "")
     {
      oldState = state2;
      return;
     }
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(oldState != state2)
        {
         Notify(1);
         oldState = state2;
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(oldState != state2)
        {
         Notify(11);
         oldState = state2;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Slope Direction: ";
   switch(type)
     {
      case 1:
         text += " BUY / SELL states changes before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " BUY / SELL states changed after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
      default:
         return((string)PERIOD_CURRENT);
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(string name, string text, int x, int y, color clr)
  {
   int subwindow = ChartWindowFind(chart_id, shortName);
   ObjectDelete(chart_id, name);
   ObjectCreate(chart_id, name, OBJ_LABEL, subwindow, 0, 0);
   ObjectSetInteger(chart_id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_id, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, true);
   ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=159133#p159133

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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