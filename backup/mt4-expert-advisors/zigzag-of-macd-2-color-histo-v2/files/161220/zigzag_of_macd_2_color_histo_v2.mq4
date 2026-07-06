 /*
── Project ─────────────────────────────────────────────────────────────────────

Name:        zigzag_of_macd_2_color_histo_v2
Version:     2.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161111#p161111
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "2.00"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  DeepSkyBlue
#property indicator_color2  DeepPink
#property indicator_color3  Gold
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
extern int FastEma = 12;
extern int SlowEma = 26;
extern int Price   = PRICE_CLOSE;
extern int ExtDepth = 12;
extern double ExtDeviation = 1;
extern int ExtBackstep = 3;
input color arrUpColor = clrBlue;
input color arrDoColor = clrRed;
input int arrUpCode = 233;
input int arrDoCode = 234;
input int arrWidth = 2;
input int Distance = 20; // Arrow distance from Hi/Lo
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
double UpH[];
double DnH[];
double ZigzagBuffer[];
double macd[];
double HighMapBuffer[];
double LowMapBuffer[];
double trend[];
int level = 3;
bool downloadhistory = false;
int last_direction = 0;
bool alerted = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
   SetIndexBuffer(0, UpH);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1, DnH);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2, ZigzagBuffer);
   SetIndexStyle(2, DRAW_SECTION);
   SetIndexEmptyValue(2, 0.0);
   SetIndexBuffer(3, macd);
   SetIndexBuffer(4, HighMapBuffer);
   SetIndexBuffer(5, LowMapBuffer);
   SetIndexBuffer(6, trend);
   IndicatorShortName("ZigZag(" + ExtDepth + "," + ExtDeviation + "," + ExtBackstep + ")");
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   int limit, counterZ, whatlookfor;
   int shift, back, lasthighpos, lastlowpos;
   double val, res;
   double curlow, curhigh, lasthigh, lastlow;
   if(counted_bars == 0 && downloadhistory)
     {
      ArrayInitialize(ZigzagBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
     }
   if(counted_bars == 0)
     {
      limit = Bars - ExtDepth;
      downloadhistory = true;
     }
   if(counted_bars > 0)
     {
      while(counterZ < level && i < 100)
        {
         res = ZigzagBuffer[i];
         if(res != 0)
            counterZ++;
         i++;
        }
      i--;
      limit = i;
      if(LowMapBuffer[i] != 0)
        {
         curlow = LowMapBuffer[i];
         whatlookfor = 1;
        }
      else
        {
         curhigh = HighMapBuffer[i];
         whatlookfor = -1;
        }
      for(i = limit - 1; i >= 0; i--)
        {
         ZigzagBuffer[i] = 0.0;
         LowMapBuffer[i] = 0.0;
         HighMapBuffer[i] = 0.0;
        }
     }
   for(shift = limit; shift >= 0; shift--)
     {
      macd[shift] = iMACD(NULL, 0, FastEma, SlowEma, 1, Price, MODE_MAIN, shift);
      val = macd[ArrayMinimum(macd, ExtDepth, shift)];
      if(val == lastlow)
         val = 0.0;
      else
        {
         lastlow = val;
         if((macd[shift] - val) > (ExtDeviation * Point))
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = LowMapBuffer[shift + back];
               if((res != 0) && (res > val))
                  LowMapBuffer[shift + back] = 0.0;
              }
           }
        }
      if(macd[shift] == val)
         LowMapBuffer[shift] = val;
      else
         LowMapBuffer[shift] = 0.0;
      val = macd[ArrayMaximum(macd, ExtDepth, shift)];
      if(val == lasthigh)
         val = 0.0;
      else
        {
         lasthigh = val;
         if((val - macd[shift]) > (ExtDeviation * Point))
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = HighMapBuffer[shift + back];
               if((res != 0) && (res < val))
                  HighMapBuffer[shift + back] = 0.0;
              }
           }
        }
      if(macd[shift] == val)
         HighMapBuffer[shift] = val;
      else
         HighMapBuffer[shift] = 0.0;
      UpH[shift] = EMPTY_VALUE;
      DnH[shift] = EMPTY_VALUE;
      trend[shift]  = trend[shift + 1];
      if(macd[shift] > 0)
         trend[shift] =  1;
      if(macd[shift] < 0)
         trend[shift] = -1;
      if(trend[shift] == 1)
         UpH[shift] = macd[shift];
      if(trend[shift] == -1)
         DnH[shift] = macd[shift];
     }
   if(whatlookfor == 0)
     {
      lastlow = 0;
      lasthigh = 0;
     }
   else
     {
      lastlow = curlow;
      lasthigh = curhigh;
     }
   for(shift = limit; shift >= 0; shift--)
     {
      res = 0.0;
      switch(whatlookfor)
        {
         case 0:
            if(lastlow == 0 && lasthigh == 0)
              {
               if(HighMapBuffer[shift] != 0)
                 {
                  lasthigh = macd[shift];
                  lasthighpos = shift;
                  whatlookfor = -1;
                  ZigzagBuffer[shift] = lasthigh;
                  res = 1;
                 }
               if(LowMapBuffer[shift] != 0)
                 {
                  lastlow = macd[shift];
                  lastlowpos = shift;
                  whatlookfor = 1;
                  ZigzagBuffer[shift] = lastlow;
                  res = 1;
                 }
              }
            break;
         case 1:
            if(LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < lastlow && HighMapBuffer[shift] == 0.0)
              {
               ZigzagBuffer[lastlowpos] = 0.0;
               lastlowpos = shift;
               lastlow = LowMapBuffer[shift];
               ZigzagBuffer[shift] = lastlow;
               res = 1;
              }
            if(HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0)
              {
               lasthigh = HighMapBuffer[shift];
               lasthighpos = shift;
               ZigzagBuffer[shift] = lasthigh;
               whatlookfor = -1;
               res = 1;
              }
            break;
         case -1:
            if(HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > lasthigh && LowMapBuffer[shift] == 0.0)
              {
               ZigzagBuffer[lasthighpos] = 0.0;
               lasthighpos = shift;
               lasthigh = HighMapBuffer[shift];
               ZigzagBuffer[shift] = lasthigh;
              }
            if(LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0)
              {
               lastlow = LowMapBuffer[shift];
               lastlowpos = shift;
               ZigzagBuffer[shift] = lastlow;
               whatlookfor = 1;
              }
            break;
         default:
            return 0;
        }
     }
   for(shift = limit; shift >= 0; shift--)
     {
      ObjectDelete(0, "arrU" + (string)shift);
      ObjectDelete(0, "arrD" + (string)shift);
     }
   for(shift = limit; shift >= 0; shift--)
     {
      if(ZigzagBuffer[shift] != 0.0)
        {
         int prevZigzagBar = shift + 1;
         while(prevZigzagBar < Bars && ZigzagBuffer[prevZigzagBar] == 0.0)
           {
            prevZigzagBar++;
           }
         if(prevZigzagBar < Bars && ZigzagBuffer[prevZigzagBar] != 0.0)
           {
            if(ZigzagBuffer[shift] > ZigzagBuffer[prevZigzagBar])
              {
               drawArrow(-1, shift);
              }
            else
               if(ZigzagBuffer[shift] < ZigzagBuffer[prevZigzagBar])
                 {
                  drawArrow(1, shift);
                 }
           }
         else
           {
            if(HighMapBuffer[shift] != 0.0)
              {
               drawArrow(-1, shift);
              }
            else
               if(LowMapBuffer[shift] != 0.0)
                 {
                  drawArrow(1, shift);
                 }
           }
        }
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      ObjectCreate(0, "arrD" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), High[bar] + Distance * Point);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_COLOR, arrDoColor);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrD" + (string)bar, OBJPROP_ARROWCODE, arrDoCode);
     }
   if(dir == 1)
     {
      ObjectCreate(0, "arrU" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), Low[bar] - Distance * Point);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_COLOR, arrUpColor);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_WIDTH, arrWidth);
      ObjectSetInteger(0, "arrU" + (string)bar, OBJPROP_ARROWCODE, arrUpCode);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   int current_direction = 0;
   for(int i = 0; i < 100; i++)
     {
      if(ZigzagBuffer[i] != 0.0)
        {
         int prevBar = i + 1;
         while(prevBar < Bars && ZigzagBuffer[prevBar] == 0.0)
           {
            prevBar++;
           }
         if(prevBar < Bars && ZigzagBuffer[prevBar] != 0.0)
           {
            if(ZigzagBuffer[i] > ZigzagBuffer[prevBar])
               current_direction = -1;
            else
               if(ZigzagBuffer[i] < ZigzagBuffer[prevBar])
                  current_direction = 1;
           }
         else
           {
            if(HighMapBuffer[i] != 0.0)
               current_direction = -1;
            else
               if(LowMapBuffer[i] != 0.0)
                  current_direction = 1;
           }
         break;
        }
     }
   if(current_direction != 0 && current_direction != last_direction)
     {
      if(notificationsOn == 1 && !alerted)
        {
         Notify(current_direction);
         alerted = true;
         last_direction = current_direction;
        }
      else
         if(notificationsOn == 2 && nb)
           {
            Notify(current_direction);
            last_direction = current_direction;
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
void Notify(int direction)
  {
   string text = "ZigZag: ";
   if(direction == 1)
      text += "Turn UP (BUY signal) - " + _Symbol + " " + GetTimeFrame(_Period);
   else
      if(direction == -1)
         text += "Turn DOWN (SELL signal) - " + _Symbol + " " + GetTimeFrame(_Period);
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader ZigZag Alert", text);
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

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        zigzag_of_macd_2_color_histo_v2
Version:     2.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161111#p161111
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
