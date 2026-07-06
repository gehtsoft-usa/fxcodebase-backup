//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160728#p160728
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 2

#property indicator_color1 clrRed
#property indicator_width1 1
#property indicator_type1 DRAW_ARROW

#property indicator_color2 clrBlue
#property indicator_width2 1
#property indicator_type2 DRAW_ARROW

input int FilterCandle = 12;
input bool   notificationsOn       = false;                  // Notifications
input bool   desktop_notifications = false;                  // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
//
double bufferUp[];
double bufferDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, bufferUp);
   SetIndexBuffer(1, bufferDown);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
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
   int limit;
   if(prev_calculated > 0)
      limit = rates_total - prev_calculated - 1;
   else
      limit = rates_total - 1;
   for(int i = limit; i >= 0; i--)
     {
      bufferUp[i] = 0;
      bufferDown[i] = 0;
      if(i + FilterCandle + 2 < rates_total)
        {
         if(isUp(i + 1, low, high, close))
           {
            bufferUp[i + 2] = low[i + 2];
           }
         if(isDown(i + 1, low, high, close))
           {
            bufferDown[i + 2] = high[i + 2];
           }
        }
     }
   if(notificationsOn && IsNewBar())
     {
      checkAlert();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isUp(int index, const double &low[], const double &high[], const double &close[])
  {
   bool flag = true;
   int preIndex = index + 1;
   if(
      low[index] > low[preIndex]
      && high[index] > high[preIndex]
      && close[index] > close[preIndex]
   )
     {
      int startIndex = preIndex + 1;
      int endIndex = preIndex + FilterCandle - 1;
      for(int i = startIndex; i <= endIndex; i++)
        {
         if(low[i] < low[preIndex])
           {
            flag = false;
            break;
           }
        }
     }
   else
     {
      flag = false;
     }
   return flag;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isDown(int index, const double &low[], const double &high[], const double &close[])
  {
   bool flag = true;
   int preIndex = index + 1;
   if(
      low[index] < low[preIndex]
      && high[index] < high[preIndex]
      && close[index] < close[preIndex]
   )
     {
      int start = preIndex + 1;
      int end = preIndex + FilterCandle - 1;
      for(int i = start; i <= end; i++)
        {
         if(high[i] > high[preIndex])
           {
            flag = false;
            break;
           }
        }
     }
   else
     {
      flag = false;
     }
   return flag;
  }
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
void checkAlert()
  {
   if(bufferUp[2] > 0)
     {
      Notify(1);
     }
   if(bufferDown[2] > 0)
     {
      Notify(2);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Reverse No Repaint: ";
   switch(type)
     {
      case 1:
         text += " Up arrow on - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Down arrow on - " + _Symbol + " " + GetTimeFrame(_Period);
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


//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160728#p160728
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
