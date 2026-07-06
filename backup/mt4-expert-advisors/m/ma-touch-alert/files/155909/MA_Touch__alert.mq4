// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75005&p=155909#p155909

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//
#property indicator_label1  "MA"
#property indicator_type1  DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//
input int ma_period = 50;
input ENUM_MA_METHOD ma_method = MODE_EMA;
input ENUM_APPLIED_PRICE ma_price = PRICE_CLOSE;
//
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 2;                      // Notifications
input double hours_alert           = 2;                      // Hours between alerts
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
//
double MABuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, MABuffer);
   IndicatorSetString(INDICATOR_SHORTNAME, "MA_Touch");
   IndicatorDigits(Digits);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int limit = (prev_calculated > 0) ? rates_total - prev_calculated : rates_total - 1;
//
   for(int i = 0; i < limit && !IsStopped(); i++)
     {
      MABuffer[i] = iMA(Symbol(), Period(), ma_period, 0, ma_method, ma_price, i);
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool alerted;
datetime last_alert;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(Open[0] < MABuffer[0] && Close[0] >= MABuffer[0])
        {
         Notify(1);
         alerted = true;
        }
      if(Open[0] > MABuffer[0] && Close[0] <= MABuffer[0])
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(Open[1] < MABuffer[0] && Close[1] >= MABuffer[0])
        {
         Notify(11);
        }
      if(Open[1] > MABuffer[0] && Close[1] <= MABuffer[0])
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsValue(double val)
  {
   return val > 0 && val != EMPTY_VALUE;
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
void Notify(int type)
  {
   if(TimeCurrent() < last_alert + hours_alert * 3600)
      return;
   last_alert = TimeCurrent();
   string text = "MA_Touch: ";
   switch(type)
     {
      case 1:
         text += " Touch UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Touch DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Touch UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Touch DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
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
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
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