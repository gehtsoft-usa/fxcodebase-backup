// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75222

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//|                                                        https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

// Mark: buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------

input string             trsi                  = "== RSI Setups ==";    // ————————————————————————
input bool               same_time_on          = true;                  // Cross Levels at same time?
enum mode
  {
   Level = 0,  // Levels
   RSI = 1     // Each Other
  };
input mode crossMode = 1;                                               // Cross by
input ENUM_APPLIED_PRICE applied               = PRICE_CLOSE;           // Applied price:
input int                rsi1_periods          = 7;                     // RSI 1 periods:
input int                rsi2_periods          = 14;                    // RSI 2 periods:
input int                rsi3_periods          = 21;                    // RSI 3 periods:
input double             up_level              = 70;                    // Up Level:
input double             dn_level              = 30;                    // Dn Level:
input string             T1                    = "== Notifications =="; // === Notifications ===
input bool               notifications         = false;                 // Notifications On?
input bool               desktop_notifications = false;                 // Desktop MT4 Notifications
input bool               email_notifications   = false;                 // Email Notifications
input bool               push_notifications    = false;                 // Push Mobile Notifications
string                   T3                    = "== Set Arrows ==";    // Set Arrows
bool                     ArrowsOn              = true;                  // Arrows On?
color                    ArrowUpClr            = clrBlue;               // Arrow Up Color:
color                    ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
  {
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexLabel(0, "Arrow Up");
   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(1, 234);
   SetIndexLabel(1, "Arrow Dn");
   return (INIT_SUCCEEDED);
  }

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int start, i;
   if(prev_calculated == 0)
     {
      start = rates_total - rsi3_periods;
     }
   else
     {
      start = rates_total - (prev_calculated - 1);
     }
   for(i = start; i >= 0; i--)
     {
      if(haveSignalUp(i))
        {
         ArrowUp[i] = Low[i];
         notify(0);
        }
      if(haveSignalDown(i))
        {
         ArrowDn[i] = High[i];
         notify(1);
        }
     }
   return (rates_total);
  }

bool ConditionsToLineUp(int i) { return true; }

bool ConditionsToLineDn(int i) { return true; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool haveSignalUp(int i)
  {
   if(crossMode == Level)
     {
      if(!same_time_on)
        {
         double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
         double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
         double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
         double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
         return (rsi1 > up_level && rsi2 > up_level && rsi3 > up_level && rsi3_prev <= up_level);
        }
      if(same_time_on)
        {
         double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
         double rsi1_prev = iRSI(NULL, 0, rsi1_periods, applied, i + 2);
         double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
         double rsi2_prev = iRSI(NULL, 0, rsi2_periods, applied, i + 2);
         double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
         double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
         return (rsi1 > up_level && rsi2 > up_level && rsi3 > up_level && rsi1_prev <= up_level && rsi2_prev <= up_level && rsi3_prev <= up_level);
        }
     }
   if(crossMode == RSI)
     {
      double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
      double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
      double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
      double rsi1_prev = iRSI(NULL, 0, rsi1_periods, applied, i + 2);
      double rsi2_prev = iRSI(NULL, 0, rsi2_periods, applied, i + 2);
      double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
      return (rsi1 >= rsi2 && rsi1 >= rsi3 && (rsi1_prev < rsi2_prev || rsi1_prev < rsi3_prev));
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool haveSignalDown(int i)
  {
   if(crossMode == Level)
     {
      if(!same_time_on)
        {
         double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
         double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
         double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
         double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
         return (rsi1 < dn_level && rsi2 < dn_level && rsi3 < dn_level && rsi3_prev >= dn_level);
        }
      if(same_time_on)
        {
         double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
         double rsi1_prev = iRSI(NULL, 0, rsi1_periods, applied, i + 2);
         double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
         double rsi2_prev = iRSI(NULL, 0, rsi2_periods, applied, i + 2);
         double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
         double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
         return (rsi1 < dn_level && rsi2 < dn_level && rsi3 < dn_level && rsi1_prev >= dn_level && rsi2_prev >= dn_level && rsi3_prev >= dn_level);
        }
     }
   if(crossMode == RSI)
     {
      double rsi1      = iRSI(NULL, 0, rsi1_periods, applied, i + 1);
      double rsi2      = iRSI(NULL, 0, rsi2_periods, applied, i + 1);
      double rsi3      = iRSI(NULL, 0, rsi3_periods, applied, i + 1);
      double rsi1_prev = iRSI(NULL, 0, rsi1_periods, applied, i + 2);
      double rsi2_prev = iRSI(NULL, 0, rsi2_periods, applied, i + 2);
      double rsi3_prev = iRSI(NULL, 0, rsi3_periods, applied, i + 2);
      return (rsi1 <= rsi2 && rsi1 <= rsi3 && (rsi1_prev > rsi2_prev || rsi1_prev > rsi3_prev));
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void notify(int type)
  {
// if (IsNewCandle()) {
   Notifications(type);
// }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
   text += " ";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
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
     }
   return IntegerToString(lPeriod);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
   static datetime last;
   datetime        current = iTime(NULL, 0, 1);
   if(last != current)
     {
      last = current;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+
