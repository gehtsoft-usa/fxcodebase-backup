// -- Project -------------------------------------------------------------------------------
/*
Name:        Fred Tam F1 Indicator with Alert V2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=31&p=160669#p160669
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
enum SingalMode
  {
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
  };
enum CrossType
  {
   CrossHighLow, // High/Low
   CrossClose // Close
  };
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input int Buy = 4; // Buy Signal Period
input int Sell = 4; // Sell Signal Period
input CrossType cross_type = CrossHighLow; // Cross Type
input SingalMode signal_mode = SingalModeLive; // Signal mode
input double shift_arrows_pips = 3; // Shift arrows in pips
input color up_color = Blue; // Up color
input color down_color = Red; // Down color
input int arrow_size = 2; // Arrow size
input int buy_arrow_code = 233; // Buy arrow code
input int sell_arrow_code = 234; // Sell arrow code
input alert notificationsOn = Current; // Notifications
input bool desktop_notifications = true; // Desktop MT4 notifications
input bool email_notifications = false; // Email notifications
input bool push_notifications = false; // Push mobile notifications
input bool sound_notifications = false; // Sound notifications
input string sound_file = "alert.wav"; // Choose a sound file for notifications
double BuyBuffer[];
double SellBuffer[];
double arrow_shift_points;
int last_signal = 0;
bool alerted = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BuyBuffer);
   SetIndexBuffer(1, SellBuffer);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, arrow_size, up_color);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, arrow_size, down_color);
   SetIndexArrow(0, buy_arrow_code);
   SetIndexArrow(1, sell_arrow_code);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel(0, "Buy Signal");
   SetIndexLabel(1, "Sell Signal");
   double pip_value = shift_arrows_pips;
   if(Digits == 5 || Digits == 3)
      arrow_shift_points = pip_value * 10 * Point;
   else
      arrow_shift_points = pip_value * Point;
   IndicatorShortName("Fred Tam F1 V2 (" + IntegerToString(Buy) + "," + IntegerToString(Sell) + ")");
   return(INIT_SUCCEEDED);
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
   int limit;
   if(prev_calculated == 0)
     {
      ArrayInitialize(BuyBuffer, 0.0);
      ArrayInitialize(SellBuffer, 0.0);
      last_signal = 0;
      limit = rates_total - MathMax(Buy, Sell) - 1;
     }
   else
     {
      if(signal_mode == SingalModeLive)
         limit = 1;
      else
         limit = 2;
     }
   if(prev_calculated > 0 && last_signal == 0)
     {
      for(int j = 1; j < rates_total; j++)
        {
         if(BuyBuffer[j] != 0.0)
           {
            last_signal = 1;
            break;
           }
         if(SellBuffer[j] != 0.0)
           {
            last_signal = -1;
            break;
           }
        }
     }
   for(int i = limit; i >= 0; i--)
     {
      BuyBuffer[i] = 0.0;
      SellBuffer[i] = 0.0;
      if(i >= rates_total - MathMax(Buy, Sell))
         continue;
      int check_bar = i;
      if(signal_mode == SingalModeOnBarClose && i == 0)
         continue;
      double current_value, buy_max, sell_min;
      if(cross_type == CrossClose)
        {
         current_value = close[check_bar];
         buy_max = close[check_bar + 1];
         for(int j = check_bar + 1; j <= check_bar + Buy && j < rates_total; j++)
           {
            if(close[j] > buy_max)
               buy_max = close[j];
           }
         sell_min = close[check_bar + 1];
         for(int k = check_bar + 1; k <= check_bar + Sell && k < rates_total; k++)
           {
            if(close[k] < sell_min)
               sell_min = close[k];
           }
        }
      else
        {
         current_value = close[check_bar];
         buy_max = high[check_bar + 1];
         for(int j = check_bar + 1; j <= check_bar + Buy && j < rates_total; j++)
           {
            if(high[j] > buy_max)
               buy_max = high[j];
           }
         sell_min = low[check_bar + 1];
         for(int k = check_bar + 1; k <= check_bar + Sell && k < rates_total; k++)
           {
            if(low[k] < sell_min)
               sell_min = low[k];
           }
        }
      if(current_value > buy_max)
        {
         if(last_signal != 1)
           {
            BuyBuffer[check_bar] = low[check_bar] - arrow_shift_points;
            last_signal = 1;
           }
        }
      if(current_value < sell_min)
        {
         if(last_signal != -1)
           {
            SellBuffer[check_bar] = high[check_bar] + arrow_shift_points;
            last_signal = -1;
           }
        }
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
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
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == Current && !alerted)
     {
      if(BuyBuffer[0] != 0.0)
        {
         Notify(1);
         alerted = true;
        }
      if(SellBuffer[0] != 0.0)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == Previous && nb)
     {
      if(BuyBuffer[1] != 0.0)
        {
         Notify(1);
        }
      if(SellBuffer[1] != 0.0)
        {
         Notify(2);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Fred Tam F1: ";
   switch(type)
     {
      case 1:
         text += "BUY Signal - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += "SELL Signal - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("Fred Tam F1 Notification", text);
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
