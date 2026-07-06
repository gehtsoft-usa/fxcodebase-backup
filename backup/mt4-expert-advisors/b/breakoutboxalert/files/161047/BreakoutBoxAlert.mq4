//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160955#p160955
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
// #property indicator_buffers 0

#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------

input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:

extern string periodBegin = "03:00";
extern string periodEnd = "06:00";
extern string BoxEnd = "18:00";
extern color BoxHLColor = C'30,60,100';
extern color BoxPeriodColor = C'30,100,60';
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                  // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA); 
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(1, 234);
   if (!ArrowsOn)
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
   }

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
   double dummyval = iCustom(NULL, 0, "Breakout Box", periodBegin, periodEnd, BoxEnd, BoxHLColor, BoxPeriodColor, 0, 0);
   if(notificationsOn > 0)
     {
      checkAlert();
     }


   int i = rates_total - prev_calculated + 1;
   if (i >= rates_total) i = rates_total - 1;
   for (; i > 0; i--)
   {
         if (haveSignal(i) == 1)
         {
            ArrowUp[i] = Low[i];
         }
         if (haveSignal(i) == -1)
         {
            ArrowDn[i] = High[i];
         }
      }

   return(rates_total);
  }

int haveSignal(int i)
{
   // Breakout Up
   // double boxHigh = iCustom(NULL, 0, "Breakout Box", periodBegin, periodEnd, BoxEnd, BoxHLColor, BoxPeriodColor, 0, i);
   string obj;
   for(int n = ObjectsTotal() - 1; n >= 0; n--)
     {
      
      
      // if(StringFind(ObjectName(n), StringFormat("BoxPeriod  %d.%02d.%02d", TimeYear(TimeCurrent()), TimeMonth(TimeCurrent()), TimeDay(TimeCurrent()))) >= 0)
      if(StringFind(ObjectName(n), StringFormat("BoxPeriod  %d.%02d.%02d", TimeYear(Time[i]), TimeMonth(Time[i]), TimeDay(Time[i]))) >= 0)
        {
         obj = ObjectName(n);
        }
     }
   double boxHigh = ObjectGetDouble(0, obj, OBJPROP_PRICE1);
   double boxLow = ObjectGetDouble(0, obj, OBJPROP_PRICE2);
   

   if (boxHigh == EMPTY_VALUE) return false;
   if (boxLow == EMPTY_VALUE) return false;

   if (Close[i] > boxHigh && Open[i] <= boxHigh)
      return 1;

   if (Close[i] < boxLow && Open[i] >= boxLow)
      return -1;

   return 0;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   string obj;
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      if(StringFind(ObjectName(i), StringFormat("BoxPeriod  %d.%02d.%02d", TimeYear(TimeCurrent()), TimeMonth(TimeCurrent()), TimeDay(TimeCurrent()))) >= 0)
        {
         obj = ObjectName(i);
        }
     }
   double hPrice = ObjectGetDouble(0, obj, OBJPROP_PRICE1);
   double lPrice = ObjectGetDouble(0, obj, OBJPROP_PRICE2);
   if(notificationsOn == 1 && !alerted)
     {
      if(Close[0] > hPrice && Close[1] <= hPrice && Open[0] < hPrice)
        {
         Notify(1);
         alerted = true;         
        }
      if(Close[0] < lPrice && Close[1] >= lPrice && Open[0] > lPrice)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(Close[1] > hPrice && Close[2] <= hPrice && Open[1] < hPrice)
        {
         Notify(11);
        }
      if(Close[1] < lPrice && Close[2] >= lPrice && Open[1] > lPrice)
        {
         Notify(22);
        }
     }
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
   string text = "BreakoutBox: ";
   switch(type)
     {
      case 1:
         text += " Break UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Break DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Break UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Break DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
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
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160955#p160955
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