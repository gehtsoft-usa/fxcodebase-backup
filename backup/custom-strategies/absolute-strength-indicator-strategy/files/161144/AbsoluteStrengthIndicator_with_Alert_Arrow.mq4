/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        AbsoluteStrengthIndicator_with_Alert+Arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=3848&start=10
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
#property version   "1.00"

#property strict
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow
#property indicator_color4 Blue
enum Method
  {
   RSI,
   Stoch,
   ADX
  };
input Method method = RSI; // Method
input ENUM_MA_METHOD Method1 = MODE_SMA; // Smoothing method
input int Length = 10; // Period for Evaluation
input int Signal = 5; // Period for Signal
input int Smoothing = 5; // Period for Smoothing
input int maxbar = 300; // Maximum bars to calculate (optimization)
input double OverBought = 0; // OverBought
input double OverSold = 0; // OverSold
input bool ShowBulls = true; // Show Bulls
input bool ShowBears = true; // Show Bears
input string   ArrowSection             = ""; // == Arrow Settings ==
input bool     ShowArrows               = true; // Show Arrows on Chart
input color    arrUpColor               = clrBlue; // Arrow Up Color
input color    arrDoColor               = clrRed; // Arrow Down Color
input int      arrUpCode                = 233; // Arrow Up Code
input int      arrDoCode                = 234; // Arrow Down Code
input int      arrWidth                 = 2; // Arrow Width
input int      Distance                 = 20; // Arrow distance from Hi/Lo
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";
#import "AdvancedNotificationsLib.dll"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ShellExecuteW(int hwnd, string Operation, string File, string Parameters, string Directory, int ShowCmd);
#import
class Signaler
  {
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   string            _prefix;
public:

                     Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
     {
      _symbol = symbol;
      _timeframe = timeframe;
     }

   void              SetMessagePrefix(string prefix)
     {
      _prefix = prefix;
     }

   string            GetSymbol()
     {
      return _symbol;
     }

   ENUM_TIMEFRAMES   GetTimeframe()
     {
      return _timeframe;
     }

   string            GetTimeframeStr()
     {
      switch(_timeframe)
        {
         case PERIOD_M1:
            return "M1";
         case PERIOD_M5:
            return "M5";
         case PERIOD_D1:
            return "D1";
         case PERIOD_H1:
            return "H1";
         case PERIOD_H4:
            return "H4";
         case PERIOD_M15:
            return "M15";
         case PERIOD_M30:
            return "M30";
         case PERIOD_MN1:
            return "MN1";
         case PERIOD_W1:
            return "W1";
        }
      return "M1";
     }

   void              SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
     {
      if(message == NULL)
         message = subject;
      if(_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if(symbol == NULL)
         symbol = _symbol;
      if(timeframe == NULL)
         timeframe = GetTimeframeStr();
      if(start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if(popup_alert)
         Alert(message);
      if(email_alert)
         SendMail(subject, message);
      if(play_sound)
         PlaySound(sound_file);
      if(notification_alert)
         SendNotification(message);
      if(advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, symbol, timeframe);
     }
  };
string IndicatorName;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   string name = target;
   int try
         = 2;
   while(WindowFind(name) != -1)
     {
      name = target + " #" + IntegerToString(try
                                                ++);
     }
   return name;
  }
Signaler* signaler;
double Bulls[], SignalBulls[], Bears[], SignalBears[], BullsTemp[], BearsTemp[], BearsAVG[], BullsAVG[];
double ArrowUpBuffer[], ArrowDownBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   if(!IsDllsAllowed() && advanced_alert)
     {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
     }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");
   IndicatorName = GenerateIndicatorName("Absolute Strength Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(10);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Bulls);
   SetIndexLabel(0, "Bulls");
   SetIndexDrawBegin(0, maxbar);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SignalBulls);
   SetIndexLabel(1, "Signal Bulls");
   SetIndexDrawBegin(1, maxbar);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Bears);
   SetIndexLabel(2, "Bears");
   SetIndexDrawBegin(2, maxbar);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, SignalBears);
   SetIndexLabel(3, "Signal Bears");
   SetIndexDrawBegin(3, maxbar);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, BullsTemp);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, BearsTemp);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, BullsAVG);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, BearsAVG);
   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, ArrowUpBuffer);
   SetIndexLabel(8, "Arrow Up");
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(9, ArrowDownBuffer);
   SetIndexLabel(9, "Arrow Down");
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
   return 0;
  }
datetime _last_signal;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = Bars - counted_bars - 1;
   int required_bars = maxbar + Length + Smoothing + Signal;
   if(limit > required_bars)
      limit = required_bars;
   for(int i = limit; i >= 0; i--)
     {
      double ma0 = iMA(_Symbol, _Period, 2, 0, MODE_SMA, PRICE_CLOSE, i);
      double ma1 = iMA(_Symbol, _Period, 2, 0, MODE_SMA, PRICE_CLOSE, i + 1);
      if(method == RSI)
        {
         BullsTemp[i] = 0.5 * (MathAbs(ma0 - ma1) + (ma0 - ma1));
         BearsTemp[i] = 0.5 * (MathAbs(ma0 - ma1) - (ma0 - ma1));
        }
      else
         if(method == Stoch)
           {
            int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Length, i);
            double min = iLow(_Symbol, _Period, lowestIndex);
            int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Length, i);
            double max = iHigh(_Symbol, _Period, highestIndex);
            BullsTemp[i] = ma0 - min;
            BearsTemp[i] = max - ma0;
           }
         else
            if(method == ADX)
              {
               BullsTemp[i] = 0.5 * (MathAbs(High[i] - High[i + 1]) + (High[i] - High[i + 1]));
               BearsTemp[i] = 0.5 * (MathAbs(Low[i + 1] - Low[i]) + (Low[i + 1] - Low[i]));
              }
      if(i > Bars - 2 - Length)
        {
         continue;
        }
      BullsAVG[i] = iMAOnArray(BullsTemp, 0, Length, 0, Method1, i);
      BearsAVG[i] = iMAOnArray(BearsTemp, 0, Length, 0, Method1, i);
      if(i <= maxbar && i <= Bars - 2 - Length - Smoothing)
        {
         Bulls[i] = iMAOnArray(BullsAVG, 0, Smoothing, 0, Method1, i);
         Bears[i] = iMAOnArray(BearsAVG, 0, Smoothing, 0, Method1, i);
        }
      else
         if(i > maxbar)
           {
            Bulls[i] = EMPTY_VALUE;
            Bears[i] = EMPTY_VALUE;
           }
      if(i > maxbar)
        {
         SignalBulls[i] = EMPTY_VALUE;
         SignalBears[i] = EMPTY_VALUE;
         continue;
        }
      if(OverBought > 0 && OverSold > 0)
        {
         SignalBulls[i] = OverBought / 100 * (Bulls[i] + Bears[i]);
         SignalBears[i] = OverSold / 100 * (Bulls[i] + Bears[i]);
        }
      else
        {
         if(i > Bars - 2 - Length - Signal)
           {
            continue;
           }
         SignalBulls[i] = iMAOnArray(BullsAVG, 0, Signal, 0, Method1, i);
         SignalBears[i] = iMAOnArray(BearsAVG, 0, Signal, 0, Method1, i);
        }
      if(i <= maxbar && i < Bars - 1)
        {
         ArrowUpBuffer[i] = EMPTY_VALUE;
         ArrowDownBuffer[i] = EMPTY_VALUE;
         bool bullCross = SignalBulls[i] >= SignalBears[i] && SignalBulls[i + 1] < SignalBears[i + 1];
         bool bearCross = SignalBulls[i] <= SignalBears[i] && SignalBulls[i + 1] > SignalBears[i + 1];
         if(bullCross)
           {
            ArrowUpBuffer[i] = Low[i] - Distance * Point;
            if(ShowArrows)
               drawArrow(1, i);
            else
               drawArrow(11, i);
           }
         else
           {
            drawArrow(11, i);
           }
         if(bearCross)
           {
            ArrowDownBuffer[i] = High[i] + Distance * Point;
            if(ShowArrows)
               drawArrow(-1, i);
            else
               drawArrow(-11, i);
           }
         else
           {
            drawArrow(-11, i);
           }
        }
     }
   if(_last_signal != Time[0])
     {
      if(SignalBulls[0] >= SignalBears[0] && SignalBulls[1] < SignalBears[1])
        {
         signaler.SendNotifications("Bulls > Bears");
         _last_signal = Time[0];
        }
      else
         if(SignalBulls[0] <= SignalBears[0] && SignalBulls[1] > SignalBears[1])
           {
            signaler.SendNotifications("Bulls < Bears");
            _last_signal = Time[0];
           }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int dir, int bar)
  {
   string obj_name;
   if(dir == 11)
     {
      obj_name = "arrU" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      return;
     }
   if(dir == -11)
     {
      obj_name = "arrD" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      return;
     }
   datetime bar_time = Time[bar];
   if(dir == -1)
     {
      obj_name = "arrD" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      double arrow_price = High[bar] + Distance * Point;
      if(ObjectCreate(0, obj_name, OBJ_ARROW, 0, bar_time, arrow_price))
        {
         ObjectSet(obj_name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
         ObjectSet(obj_name, OBJPROP_COLOR, arrDoColor);
         ObjectSet(obj_name, OBJPROP_WIDTH, arrWidth);
         ObjectSet(obj_name, OBJPROP_ARROWCODE, arrDoCode);
         ObjectSet(obj_name, OBJPROP_BACK, false);
         ObjectSet(obj_name, OBJPROP_SELECTABLE, false);
         ObjectSet(obj_name, OBJPROP_SELECTED, false);
         ObjectSet(obj_name, OBJPROP_HIDDEN, true);
        }
     }
   if(dir == 1)
     {
      obj_name = "arrU" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      double arrow_price = Low[bar] - Distance * Point;
      if(ObjectCreate(0, obj_name, OBJ_ARROW, 0, bar_time, arrow_price))
        {
         ObjectSet(obj_name, OBJPROP_COLOR, arrUpColor);
         ObjectSet(obj_name, OBJPROP_WIDTH, arrWidth);
         ObjectSet(obj_name, OBJPROP_ARROWCODE, arrUpCode);
         ObjectSet(obj_name, OBJPROP_BACK, false);
         ObjectSet(obj_name, OBJPROP_SELECTABLE, false);
         ObjectSet(obj_name, OBJPROP_SELECTED, false);
         ObjectSet(obj_name, OBJPROP_HIDDEN, true);
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        AbsoluteStrengthIndicator_with_Alert+Arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=3848&start=10
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
