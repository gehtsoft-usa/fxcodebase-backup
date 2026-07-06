/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Elise_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75311&p=160182#p160182
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

#property description "======Elise-GOLD EA====="
#property description "=Minimum Deposit 500$/Pair TF M30"
#property description "=Minimum Deposit 2000$/Pair TF M15"
#property description "=Minimum Deposit 5000$/Pair TF M5"
#property description "=Recommended Pair EURUSD, GBPUSD, XAUUSD="
#property description "=TF M5~H1="
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/SymbolInfo.mqh>
CTrade trade;
CPositionInfo positionInfo;
CSymbolInfo symbolInfo;
int rsi_handle = INVALID_HANDLE;
input string Licence         = "************ ELISE GOLD EA LICENSE ************"; // ===== Expert Name =====
input double Lots            = 0.01;
input double LotExponent     = 1.2; // Layer Multiplier
int           lotdecimal      = 2;
input double PipStep         = 210.0; // PipStep
input double MaxLots         = 2;
bool          MM              = false;
input double TakeProfit      = 300.0; // Take Profit points
input bool    useSl           = true;  // Stop Loss On?
input double StopLoss        = 300.0; // Stop Loss points
bool          UseEquityStop   = false;
double        TotalEquityRisk = 20.0;
input bool   UseTrailingStop = false;
input double TrailStart      = 13.0;
input double TrailStop       = 3.0;
input double slip            = 5.0;
input string x              = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
input string ATURANFIBO     = "SETTINGS ORDER SELL";              // Setting Order Sell
input int    MaxTrades_Hilo = 50;                                 // Maxtrade Order Sell
bool          gi_184         = false;
double        gd_188         = 48.0;
double        g_pips_196     = 40.0;
double        g_slippage_204;
input int    MagicNumber_Hilo = 852791; // Magic Order Sell
double        g_price_216;
double        gd_224;
double        gd_unused_232;
double        gd_unused_240;
double        gd_248;
double        gd_256;
double        g_price_264;
double        g_bid_272;
double        g_ask_280;
double        gd_288;
double        gd_296;
double        gd_304;
bool          gi_312;
string        gs_316 = "[Elise-EA-Sell]";
int           gi_324 = 0;
int           gi_328;
int           gi_332 = 0;
double        gd_336;
int           g_pos_344 = 0;
int           gi_348;
double        gd_352 = 0.0;
bool          gi_360 = false;
bool          gi_364 = false;
bool          gi_368 = false;
int           gi_372;
bool          gi_376 = false;
double        gd_380;
double        gd_388;
input string xx              = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
input string ATURANAFSCALPER = "SETTINGS ORDER BUY/SELL";          // Setting Order Buy/Sell
input int    MaxTrades_15    = 50;                                 // Maxtrade Order Buy/Sell
ENUM_TIMEFRAMES           g_timeframe_408 = PERIOD_H1;
double        g_pips_412      = 40.0;
bool          gi_420          = false;
double        gd_424          = 48.0;
double        g_slippage_432;
input int    g_magic_176_15 = 852792; // Magic Order Buy/Sell
double        g_price_444;
double        gd_452;
double        gd_unused_460;
double        gd_unused_468;
double        g_price_476;
double        g_bid_484;
double        g_ask_492;
double        gd_500;
double        gd_508;
double        gd_516;
bool          gi_524;
string        gs_528 = "[@EliseTrendEA]";
int           gi_536 = 0;
int           gi_540;
int           gi_544 = 0;
double        gd_548;
int           g_pos_556 = 0;
int           gi_560;
double        gd_564 = 0.0;
bool          gi_572 = false;
bool          gi_576 = false;
bool          gi_580 = false;
int           gi_584;
bool          gi_588 = false;
double        gd_592;
double        gd_600;
int           g_datetime_608 = 1;
input string xxx               = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
input string ATURANTRENDKILLER = "SETTINGS ORDER BUY";               // Setting Order Buy
input int    MaxTrades_16      = 50;                                 // Maxtrade Order Buy
ENUM_TIMEFRAMES           g_timeframe_624   = PERIOD_M1;
double        g_pips_628        = 40.0;
bool          gi_636            = false;
double        gd_640            = 48.0;
double        g_slippage_648;
input int    g_magic_176_16 = 852793; // Magic Order Buy
bool          UseNewsFilter  = false;
double        g_price_660;
double        gd_668;
double        gd_unused_676;
double        gd_unused_684;
double        g_price_692;
double        g_bid_700;
double        g_ask_708;
double        gd_716;
double        gd_724;
double        gd_732;
bool          gi_740;
string        gs_744 = "[Elise-EA-Buy]";
int           gi_752 = 0;
int           gi_756;
int           gi_760 = 0;
double        gd_764;
int           g_pos_772 = 0;
int           gi_776;
double        gd_780 = 0.0;
bool          gi_788 = false;
bool          gi_792 = false;
bool          gi_796 = false;
int           gi_800;
bool          gi_804 = false;
bool          cg     = false;
double        gd_808;
double        gd_816;
int           g_datetime_824      = 1;
ENUM_TIMEFRAMES           g_timeframe_828     = PERIOD_M1;
ENUM_TIMEFRAMES           g_timeframe_832     = PERIOD_M5;
ENUM_TIMEFRAMES           g_timeframe_836     = PERIOD_M15;
ENUM_TIMEFRAMES           g_timeframe_840     = PERIOD_M30;
ENUM_TIMEFRAMES           g_timeframe_844     = PERIOD_H1;
ENUM_TIMEFRAMES           g_timeframe_848     = PERIOD_H4;
ENUM_TIMEFRAMES           g_timeframe_852     = PERIOD_D1;
bool          g_corner_856        = true;
int           gi_860              = 0;
int           gi_864              = 10;
int           g_window_868        = 0;
bool          gi_872              = true;
bool          gi_unused_876       = true;
bool          gi_880              = false;
int           g_color_884         = clrGray;
int           g_color_888         = clrGray;
int           g_color_892         = clrGray;
int           g_color_896         = clrDarkOrange;
int           gi_unused_900       = 36095;
int           g_color_904         = clrLime;
int           g_color_908         = clrOrangeRed;
int           gi_912              = 65280;
int           gi_916              = 17919;
int           g_color_920         = clrLime;
int           g_color_924         = clrRed;
int           g_color_928         = clrOrange;
int           g_period_932        = 8;
int           g_period_936        = 17;
int           g_period_940        = 9;
int           g_applied_price_944 = PRICE_CLOSE;
int           g_color_948         = clrLime;
int           g_color_952         = clrTomato;
int           g_color_956         = clrGreen;
int           g_color_960         = clrRed;
string        gs_dummy_1088;
string        g_text_1096;
string        g_text_1104;
string        g_dbl2str_1112           = "";
string        g_dbl2str_1120           = "";
int           g_color_1128             = clrForestGreen;
input string ManagementProfitTarget   = "***** Management Floating Loss *****"; // Management Floating Loss
input bool   UseFloatingLoss_Target   = false;                                  // Use stop a maximum floating loss
input double FloatingLoss_Target      = 0;                                      // Maximum Floating Loss (example input: -500)
string        button_close_basket_Prof = "btn_Close Prof";
string        button_close_Profit      = "btn_Close Profit";
int           x_axis                   = 0;
int           y_axis                   = 70;
int    BeforeMin = 15;
int    FontSize  = 10;
string FontName  = "Arial";
int    ShiftX    = 250;
int    ShiftY    = 70;
int    Corner    = 0;
int magico = MagicNumber_Hilo;
input string tdailylimits     = "== Daily Limits Setup =="; // ������������������������
input bool   daily_limits_on  = false;                      // Daily Limits On?
input double daily_win_limit  = 500;                        // Daily Win Limit:
input double daily_loss_limit = 500;                        // Daily Loss Limit:
class ConditionDayLimit
  {
public:

   bool              evaluate()
     {
      if(!daily_limits_on)
        {
         return true;
        }
      bool   r      = true;
      double result = 0;
      datetime start_time = iTime(_Symbol, PERIOD_D1, 0);
      if(!HistorySelect(start_time, TimeCurrent()))
         return true;
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
        {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
           {
            string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
            long magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
            long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
            if(symbol == _Symbol && magic == magico && entry == DEAL_ENTRY_OUT)
              {
               result += HistoryDealGetDouble(ticket, DEAL_PROFIT);
               result += HistoryDealGetDouble(ticket, DEAL_SWAP);
               result += HistoryDealGetDouble(ticket, DEAL_COMMISSION);
              }
           }
        }
      if(result >= daily_win_limit || result <= -daily_loss_limit)
        {
         r = false;
        }
      return r;
     }
  };
ConditionDayLimit cdDayLimit;

enum enumDays { sunday, monday, tuesday, wednesday, thursday, friday, saturday, EA_OFF };
input string T1             = "== Trading Sessions =="; // ������������������������
input bool   sessioncontrol = false;                    // Timer On:
input string timeStart      = "00:00:00";               // Time Start GMT
input string timeEnd        = "23:59:59";               // Time End GMT
class Session
  {
   int               _iniTime;
   int               _endTime;
   int               _dayNumber;
public:

                     Session(string iniTime, string endTime, int dayNumber = 0)
     {
      _iniTime   = secondsFromZeroHour(iniTime);
      _endTime   = secondsFromZeroHour(endTime);
      _dayNumber = dayNumber;
     };

                    ~Session() {}

   int               iniTime() { return _iniTime; }

   int               endTime() { return _endTime; }

   int               dayNumber() { return _dayNumber; }

   int               secondsFromZeroHour(string time)
     {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);
      return (hh * 3600) + (mm * 60);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ScheduleController
  {
   Session           *schedules[];
   Session           *_actualSession;
   int               _actualIndex;
   int               _currentDay;
   double            _timeZone;
public:

                     ScheduleController() { setCurrentDay(); };

                    ~ScheduleController() { ClearShchedules(); }

   Session           *at() { return _actualSession; }

   void              setTimeZone(double hs) { _timeZone = hs * 60 * 60; }

   void              setCurrentDay()
     {
      int tzOffset = (int)_timeZone;
      datetime adjTime = datetime(TimeGMT() + tzOffset);
      MqlDateTime dt;
      TimeToStruct(adjTime, dt);
      _currentDay = dt.day;
     }

   bool              isNewDay()
     {
      int tzOffset = (int)_timeZone;
      datetime adjTime = datetime(TimeGMT() + tzOffset);
      MqlDateTime dt;
      TimeToStruct(adjTime, dt);
      if(dt.day != _currentDay)
        {
         setCurrentDay();
         return true;
        }
      return false;
     }

   void              setActualSession(int index)
     {
      _actualIndex = index;
      if(index > -1)
        {
         _actualSession = schedules[index];
        }
     }

   int               qnt() { return ArraySize(schedules); }

   bool              AddSession(string ini, string end, int day = 0)
     {
      Session *sc = new Session(ini, end, day);
      int      t  = qnt();
      if(ArrayResize(schedules, t + 1))
        {
         schedules[t] = sc;
         return true;
        }
      return false;
     }

   bool              ClearShchedules()
     {
      for(int i = 0; i < qnt(); i++)
        {
         delete schedules[i];
        }
      ArrayFree(schedules);
      return true;
     }

   bool              evaluate()
     {
      if(!sessioncontrol)
        {
         Comment("Timer Control - EA ON");
         return true;
        }
      Comment("Timer Control - EA OFF");
      int tzOffset = (int)_timeZone;
      datetime adjTime = datetime(TimeGMT() + tzOffset);
      MqlDateTime dt;
      TimeToStruct(adjTime, dt);
      int actual = (dt.hour * 3600) + (dt.min * 60);
      for(int i = 0; i < qnt(); i++)
        {
         if(schedules[i].dayNumber() == EA_OFF)
           {
            continue;
           }
         if(schedules[i].dayNumber() != 0)
           {
            if(schedules[i].dayNumber() == dt.day_of_week)
              {
               if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
                 {
                  setActualSession(i);
                  Comment("Daily Control - EA ON");
                  return true;
                 }
              }
           }
         if(schedules[i].dayNumber() == 0)
           {
            if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
              {
               setActualSession(i);
               Comment("Daily Control - EA ON");
               return true;
              }
           }
        }
      setActualSession(-1);
      return false;
     }
  };
ScheduleController sesionControl;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void oninitTimer()
  {
   sesionControl.AddSession(timeStart, timeEnd);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool evaluateTimer()
  {
   if(!sessioncontrol)
      return true;
   if(sesionControl.isNewDay())
     {
      sesionControl.ClearShchedules();
      sesionControl.AddSession(timeStart, timeEnd);
     }
   return sesionControl.evaluate();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   rsi_handle = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
   if(rsi_handle == INVALID_HANDLE)
     {
      Print("Failed to create RSI indicator");
      return INIT_FAILED;
     }
   trade.SetDeviationInPoints((ulong)slip);
   trade.SetAsyncMode(false);
   symbolInfo.Name(_Symbol);
   symbolInfo.Refresh();
   gd_304 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_516 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_732 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_304 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_516 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_732 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   ObjectCreate(0, "Lable1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable1", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, "Lable1", OBJPROP_XDISTANCE, 400);
   ObjectSetInteger(0, "Lable1", OBJPROP_YDISTANCE, 80);
   g_text_1104 = "Elise clrGold EA  2024";
   ObjectSetString(0, "Lable1", OBJPROP_TEXT, g_text_1104);
   ObjectSetString(0, "Lable1", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable1", OBJPROP_FONTSIZE, 30);
   ObjectSetInteger(0, "Lable1", OBJPROP_COLOR, clrAqua);
   ObjectCreate(0, "Lable", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, "Lable", OBJPROP_XDISTANCE, 400);
   ObjectSetInteger(0, "Lable", OBJPROP_YDISTANCE, 50);
   g_text_1096 = "Join our Telegram Group : [https://t.me/EliseTrendEA]";
   ObjectSetString(0, "Lable", OBJPROP_TEXT, g_text_1096);
   ObjectSetString(0, "Lable", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable", OBJPROP_FONTSIZE, 20);
   ObjectSetInteger(0, "Lable", OBJPROP_COLOR, clrDeepSkyBlue);
   Create_Button(button_close_basket_Prof, "Close Order", 70, 18, 330, 20, C'231,247,14', clrBlack);
   Create_Button(button_close_Profit, "Close Profit", 70, 18, 330, 55, C'1,173,18', clrBlack);
   RemoveGrid();
   oninitTimer();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(rsi_handle != INVALID_HANDLE)
      IndicatorRelease(rsi_handle);
   Comment("[https://t.me/EliseRenard]");
   ObjectsDeleteAll(0, -1, -1);
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   static int tickCounter = 0;
   tickCounter++;
   if(tickCounter % 100 == 0)
     {
      Print("OnTick counter: ", tickCounter, " | Positions: ", PositionsTotal());
     }
   double Total_FloatingLoss = AccountInfoDouble(ACCOUNT_PROFIT);
   if(UseFloatingLoss_Target == true && Total_FloatingLoss < FloatingLoss_Target)
     {
      return;
     }
   if(!evaluateTimer())
     {
      Comment("Timer Control - EA OFF");
      return;
     }
   OpenBuyOrder();
   OpenSellOrder();
   SetTakeProfit();
   Loadtext();
   int    li_0;
   int    li_4;
   int    li_8;
   int    li_12;
   int    li_16;
   int    li_20;
   int    li_24;
   string ls_unused_56;
   string ls_unused_96;
   double ihigh_112;
   double ilow_120;
   double iclose_128;
   double iclose_136;
   double ld_144;
   double ld_152;
   double ld_160;
   int    li_168;
   int    count_172;
   double ld_176;
   double ld_184;
   int    li_192;
   int    count_196;
   int    ind_counted_200 = 0;
   double currentLots = Lots;
   if(currentLots > MaxLots)
      currentLots = MaxLots;
   Comment("\n" + "\n" + "ELISE EA" + "\n" + "___________________________________________________" + "\n" + "Broker                           :" + AccountInfoString(ACCOUNT_COMPANY) + "\n" +
           "Brokers Time                     :" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n" + "___________________________________________________" + "\n" +
           "Name                             :" + AccountInfoString(ACCOUNT_NAME) + "\n" + "Account Number                   :" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n" + "Account Currency                 :" + AccountInfoString(ACCOUNT_CURRENCY) +
           "\n" + "____________________________________________________" + "\n" + "Open Orders Sell        :" + IntegerToString(CountTrades_Hilo()) + "\n" + "Open Orders Auto        :" + IntegerToString(CountTrades_15()) + "\n" +
           "Open Orders Buy        :" + IntegerToString(CountTrades_16()) + "\n" + "ALL ORDERS                       :" + IntegerToString(PositionsTotal()) + "\n" + "_____________________________________________________" + "\n" +
           "Account BALANCE                  :" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n" + "Account EQUITY                   :" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n" +
           "_____________________________________________________" + "\n" + "https://t.me/EliseRenard");
   gd_248 = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   gd_256 = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   if(gd_256 >= 5.0 * (gd_248 / 6.0))
      g_color_1128 = clrDodgerBlue;
   if(gd_256 >= 4.0 * (gd_248 / 6.0) && gd_256 < 5.0 * (gd_248 / 6.0))
      g_color_1128 = clrDeepSkyBlue;
   if(gd_256 >= 3.0 * (gd_248 / 6.0) && gd_256 < 4.0 * (gd_248 / 6.0))
      g_color_1128 = clrGold;
   if(gd_256 >= 2.0 * (gd_248 / 6.0) && gd_256 < 3.0 * (gd_248 / 6.0))
      g_color_1128 = clrOrangeRed;
   if(gd_256 >= gd_248 / 6.0 && gd_256 < 2.0 * (gd_248 / 6.0))
      g_color_1128 = clrCrimson;
   if(gd_256 < gd_248 / 5.0)
      g_color_1128 = clrRed;
   int    ind_counted_204 = 0;
   string text_208        = "";
   string text_216        = "";
   string text_224        = "";
   string text_232        = "";
   string text_240        = "";
   string text_248        = "";
   string text_256        = "";
   if(g_timeframe_828 == PERIOD_M1)
      text_208 = "M1";
   if(g_timeframe_828 == PERIOD_M5)
      text_208 = "M5";
   if(g_timeframe_828 == PERIOD_M15)
      text_208 = "M15";
   if(g_timeframe_828 == PERIOD_M30)
      text_208 = "M30";
   if(g_timeframe_828 == PERIOD_H1)
      text_208 = "H1";
   if(g_timeframe_828 == PERIOD_H4)
      text_208 = "H4";
   if(g_timeframe_828 == PERIOD_D1)
      text_208 = "D1";
   if(g_timeframe_828 == PERIOD_W1)
      text_208 = "W1";
   if(g_timeframe_828 == PERIOD_MN1)
      text_208 = "MN";
   if(g_timeframe_832 == PERIOD_M1)
      text_216 = "M1";
   if(g_timeframe_832 == PERIOD_M5)
      text_216 = "M5";
   if(g_timeframe_832 == PERIOD_M15)
      text_216 = "M15";
   if(g_timeframe_832 == PERIOD_M30)
      text_216 = "M30";
   if(g_timeframe_832 == PERIOD_H1)
      text_216 = "H1";
   if(g_timeframe_832 == PERIOD_H4)
      text_216 = "H4";
   if(g_timeframe_832 == PERIOD_D1)
      text_216 = "D1";
   if(g_timeframe_832 == PERIOD_W1)
      text_216 = "W1";
   if(g_timeframe_832 == PERIOD_MN1)
      text_216 = "MN";
   if(g_timeframe_836 == PERIOD_M1)
      text_224 = "M1";
   if(g_timeframe_836 == PERIOD_M5)
      text_224 = "M5";
   if(g_timeframe_836 == PERIOD_M15)
      text_224 = "M15";
   if(g_timeframe_836 == PERIOD_M30)
      text_224 = "M30";
   if(g_timeframe_836 == PERIOD_H1)
      text_224 = "H1";
   if(g_timeframe_836 == PERIOD_H4)
      text_224 = "H4";
   if(g_timeframe_836 == PERIOD_D1)
      text_224 = "D1";
   if(g_timeframe_836 == PERIOD_W1)
      text_224 = "W1";
   if(g_timeframe_836 == PERIOD_MN1)
      text_224 = "MN";
   if(g_timeframe_840 == PERIOD_M1)
      text_232 = "M1";
   if(g_timeframe_840 == PERIOD_M5)
      text_232 = "M5";
   if(g_timeframe_840 == PERIOD_M15)
      text_232 = "M15";
   if(g_timeframe_840 == PERIOD_M30)
      text_232 = "M30";
   if(g_timeframe_840 == PERIOD_H1)
      text_232 = "H1";
   if(g_timeframe_840 == PERIOD_H4)
      text_232 = "H4";
   if(g_timeframe_840 == PERIOD_D1)
      text_232 = "D1";
   if(g_timeframe_840 == PERIOD_W1)
      text_232 = "W1";
   if(g_timeframe_840 == PERIOD_MN1)
      text_232 = "MN";
   if(g_timeframe_844 == PERIOD_M1)
      text_240 = "M1";
   if(g_timeframe_844 == PERIOD_M5)
      text_240 = "M5";
   if(g_timeframe_844 == PERIOD_M15)
      text_240 = "M15";
   if(g_timeframe_844 == PERIOD_M30)
      text_240 = "M30";
   if(g_timeframe_844 == PERIOD_H1)
      text_240 = "H1";
   if(g_timeframe_844 == PERIOD_H4)
      text_240 = "H4";
   if(g_timeframe_844 == PERIOD_D1)
      text_240 = "D1";
   if(g_timeframe_844 == PERIOD_W1)
      text_240 = "W1";
   if(g_timeframe_844 == PERIOD_MN1)
      text_240 = "MN";
   if(g_timeframe_848 == PERIOD_M1)
      text_248 = "M1";
   if(g_timeframe_848 == PERIOD_M5)
      text_248 = "M5";
   if(g_timeframe_848 == PERIOD_M15)
      text_248 = "M15";
   if(g_timeframe_848 == PERIOD_M30)
      text_248 = "M30";
   if(g_timeframe_848 == PERIOD_H1)
      text_248 = "H1";
   if(g_timeframe_848 == PERIOD_H4)
      text_248 = "H4";
   if(g_timeframe_848 == PERIOD_D1)
      text_248 = "D1";
   if(g_timeframe_848 == PERIOD_W1)
      text_248 = "W1";
   if(g_timeframe_848 == PERIOD_MN1)
      text_248 = "MN";
   if(g_timeframe_852 == PERIOD_M1)
      text_256 = "M1";
   if(g_timeframe_852 == PERIOD_M5)
      text_256 = "M5";
   if(g_timeframe_852 == PERIOD_M15)
      text_256 = "M15";
   if(g_timeframe_852 == PERIOD_M30)
      text_256 = "M30";
   if(g_timeframe_852 == PERIOD_H1)
      text_256 = "H1";
   if(g_timeframe_852 == PERIOD_H4)
      text_256 = "H4";
   if(g_timeframe_852 == PERIOD_D1)
      text_256 = "D1";
   if(g_timeframe_852 == PERIOD_W1)
      text_256 = "W1";
   if(g_timeframe_852 == PERIOD_MN1)
      text_256 = "MN";
   if(g_timeframe_828 == PERIOD_M15)
      li_0 = -2;
   if(g_timeframe_828 == PERIOD_M30)
      li_0 = -2;
   if(g_timeframe_832 == PERIOD_M15)
      li_4 = -2;
   if(g_timeframe_832 == PERIOD_M30)
      li_4 = -2;
   if(g_timeframe_836 == PERIOD_M15)
      li_8 = -2;
   if(g_timeframe_836 == PERIOD_M30)
      li_8 = -2;
   if(g_timeframe_840 == PERIOD_M15)
      li_12 = -2;
   if(g_timeframe_840 == PERIOD_M30)
      li_12 = -2;
   if(g_timeframe_844 == PERIOD_M15)
      li_16 = -2;
   if(g_timeframe_844 == PERIOD_M30)
      li_16 = -2;
   if(g_timeframe_848 == PERIOD_M15)
      li_20 = -2;
   if(g_timeframe_848 == PERIOD_M30)
      li_20 = -2;
   if(g_timeframe_852 == PERIOD_M15)
      li_24 = -2;
   if(g_timeframe_848 == PERIOD_M30)
      li_24 = -2;
   if(gi_860 < 0)
      return;
   double ld_1060   = LotExponent;
   int    li_1068   = lotdecimal;
   double ld_1072   = TakeProfit;
   bool   bool_1080 = UseEquityStop;
   double ld_1084   = TotalEquityRisk;
   bool   bool_1092 = UseTrailingStop;
   double ld_1096   = TrailStart;
   double ld_1104   = TrailStop;
   double ld_1112   = PipStep;
   double ld_1120   = slip;
   if(MM == true)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_144 = Lots;
      else
         ld_144 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   else
      ld_144 = Lots;
   if(bool_1092)
      TrailingAlls_Hilo(ld_1096, ld_1104, g_price_264);
   if(gi_184)
     {
      if(TimeCurrent() >= gi_328)
        {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to TimeOut");
        }
     }
   datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(gi_324 == barTime)
     {
      Print("[Hilo] Bar filter: SAME BAR - exiting early. gi_324=", gi_324, " barTime=", barTime);
      return;
     }
   gi_324 = barTime;
   double ld_1128 = CalculateProfit_Hilo();
   if(bool_1080)
     {
      if(ld_1128 < 0.0 && MathAbs(ld_1128) > ld_1084 / 100.0 * AccountEquityHigh_Hilo())
        {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to Stop Out");
         gi_376 = false;
        }
     }
   gi_348 = CountTrades_Hilo();
   if(gi_348 == 0)
      gi_312 = false;
   for(g_pos_344 = PositionsTotal() - 1; g_pos_344 >= 0; g_pos_344--)
     {
      if(!positionInfo.SelectByIndex(g_pos_344))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_BUY)
           {
            gi_364 = true;
            gi_368 = false;
            break;
           }
        }
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_SELL)
           {
            gi_364 = false;
            gi_368 = true;
            break;
           }
        }
     }
   if(gi_348 > 0 && gi_348 <= MaxTrades_Hilo)
     {
      gd_288 = FindLastBuyPrice_Hilo();
      gd_296 = FindLastSellPrice_Hilo();
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double pipStepPoints = ld_1112 * _Point;
      if(gi_364 && gd_288 - askPrice >= pipStepPoints)
         gi_360 = true;
      if(gi_368 && bidPrice - gd_296 >= pipStepPoints)
         gi_360 = true;
     }
   if(gi_348 < 1)
     {
      gi_368 = false;
      gi_364 = false;
      gi_360 = true;
      gd_224 = AccountInfoDouble(ACCOUNT_EQUITY);
     }
   if(gi_360)
     {
      gd_288 = FindLastBuyPrice_Hilo();
      gd_296 = FindLastSellPrice_Hilo();
      if(gi_368)
        {
         gi_332 = gi_348;
         gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
         if(gd_336 > MaxLots)
            gd_336 = MaxLots;
         gi_372 = OpenPendingOrder_Hilo(1, gd_336, SymbolInfoDouble(_Symbol, SYMBOL_BID), ld_1120, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, gs_316 + "-" + gi_332, MagicNumber_Hilo, 0, clrHotPink);
         if(gi_372 < 0)
           {
            Print("Error: ", GetLastError());
            return;
           }
         gd_296 = FindLastSellPrice_Hilo();
         gi_360 = false;
         gi_376 = true;
        }
      else
        {
         if(gi_364)
           {
            gi_332 = gi_348;
            gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
            if(gd_336 > MaxLots)
               gd_336 = MaxLots;
            gi_372 = OpenPendingOrder_Hilo(1, gd_336, SymbolInfoDouble(_Symbol, SYMBOL_BID), ld_1120, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, gs_316 + "-" + gi_332, MagicNumber_Hilo, 0, clrLime);
            if(gi_372 < 0)
              {
               Print("Error: ", GetLastError());
               return;
              }
            gd_288 = FindLastBuyPrice_Hilo();
            gi_360 = false;
            gi_376 = true;
           }
        }
     }
   if(gi_360 && gi_348 < 1)
     {
      ihigh_112 = iHigh(_Symbol, 0, 1);
      ilow_120  = iLow(_Symbol, 0, 2);
      g_bid_272 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      g_ask_280 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if((!gi_368) && !gi_364)
        {
         gi_332 = gi_348;
         gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
         if(gd_336 > MaxLots)
            gd_336 = MaxLots;
         if(ihigh_112 > ilow_120)
           {
            double rsi_buffer[];
            ArraySetAsSeries(rsi_buffer, true);
            if(CopyBuffer(rsi_handle, 0, 0, 2, rsi_buffer) == 2 && rsi_buffer[1] > 50.0)
              {
               gi_372 = OpenPendingOrder_Hilo(1, gd_336, g_bid_272, ld_1120, g_ask_280, 0, 0, gs_316 + "-" + gi_332, MagicNumber_Hilo, 0, clrHotPink);
               if(gi_372 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_288 = FindLastBuyPrice_Hilo();
               gi_376 = true;
              }
           }
         else
           {
            double rsi_buffer[];
            ArraySetAsSeries(rsi_buffer, true);
            if(CopyBuffer(rsi_handle, 0, 0, 2, rsi_buffer) == 2 && rsi_buffer[1] < 50.0)
              {
               gi_372 = OpenPendingOrder_Hilo(1, gd_336, g_bid_272, ld_1120, g_ask_280, 0, 0, gs_316 + "-" + gi_332, MagicNumber_Hilo, 0, clrLime);
               if(gi_372 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_296 = FindLastSellPrice_Hilo();
               gi_376 = true;
              }
           }
         if(gi_372 > 0)
            gi_328 = TimeCurrent() + 60.0 * (60.0 * gd_188);
         gi_360 = false;
        }
     }
   gi_348         = CountTrades_Hilo();
   g_price_264    = 0;
   double ld_1136 = 0;
   for(g_pos_344 = PositionsTotal() - 1; g_pos_344 >= 0; g_pos_344--)
     {
      if(!positionInfo.SelectByIndex(g_pos_344))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
           {
            g_price_264 += positionInfo.PriceOpen() * positionInfo.Volume();
            ld_1136 += positionInfo.Volume();
           }
        }
     }
   if(gi_348 > 0)
      g_price_264 = NormalizeDouble(g_price_264 / ld_1136, _Digits);
   if(gi_376)
     {
      for(g_pos_344 = PositionsTotal() - 1; g_pos_344 >= 0; g_pos_344--)
        {
         if(!positionInfo.SelectByIndex(g_pos_344))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
              {
               g_price_216   = g_price_264 + ld_1072 * _Point;
               gd_unused_232 = g_price_216;
               gd_352        = g_price_264 - g_pips_196 * _Point;
               gi_312        = true;
              }
           }
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               g_price_216   = g_price_264 - ld_1072 * _Point;
               gd_unused_240 = g_price_216;
               gd_352        = g_price_264 + g_pips_196 * _Point;
               gi_312        = true;
              }
           }
        }
     }
   if(gi_376)
     {
      if(gi_312 == true)
        {
         int last_pos_index = -1;
         for(g_pos_344 = PositionsTotal() - 1; g_pos_344 >= 0; g_pos_344--)
           {
            if(!positionInfo.SelectByIndex(g_pos_344))
               continue;
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
               continue;
            if(last_pos_index == -1)
               last_pos_index = g_pos_344;
            break;
           }
         if(last_pos_index >= 0)
           {
            if(!positionInfo.SelectByIndex(last_pos_index))
              {
               gi_376 = false;
              }
            else
               if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
                 {
                  trade.PositionModify(positionInfo.Ticket(), positionInfo.StopLoss(), g_price_216);
                  gi_376 = false;
                 }
           }
        }
     }
   double ld_1144   = LotExponent;
   int    li_1152   = lotdecimal;
   double ld_1156   = TakeProfit;
   bool   bool_1164 = UseEquityStop;
   double ld_1168   = TotalEquityRisk;
   bool   bool_1176 = UseTrailingStop;
   double ld_1180   = TrailStart;
   double ld_1188   = TrailStop;
   double ld_1196   = PipStep;
   double ld_1204   = slip;
   if(MM == true)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_152 = Lots;
      else
         ld_152 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   else
      ld_152 = Lots;
   if(bool_1176)
      TrailingAlls_15(ld_1180, ld_1188, g_price_476);
   if(gi_420)
     {
      if(TimeCurrent() >= gi_540)
        {
         CloseThisSymbolAll_15();
         Print("Closed All due to TimeOut");
        }
     }
   if(gi_536 != iTime(_Symbol, PERIOD_CURRENT, 0))
     {
      gi_536 = iTime(_Symbol, PERIOD_CURRENT, 0);
      ld_160 = CalculateProfit_15();
      if(bool_1164)
        {
         if(ld_160 < 0.0 && MathAbs(ld_160) > ld_1168 / 100.0 * AccountEquityHigh_15())
           {
            CloseThisSymbolAll_15();
            Print("Closed All due to Stop Out");
            gi_588 = false;
           }
        }
      gi_560 = CountTrades_15();
      if(gi_560 == 0)
         gi_524 = false;
      for(g_pos_556 = PositionsTotal() - 1; g_pos_556 >= 0; g_pos_556--)
        {
         if(!positionInfo.SelectByIndex(g_pos_556))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
              {
               gi_576 = true;
               gi_580 = false;
               break;
              }
           }
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               gi_576 = false;
               gi_580 = true;
               break;
              }
           }
        }
      if(gi_560 > 0 && gi_560 <= MaxTrades_15)
        {
         gd_500 = FindLastBuyPrice_15();
         gd_508 = FindLastSellPrice_15();
         if(gi_576 && gd_500 - SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= ld_1196 * _Point)
            gi_572 = true;
         if(gi_580 && SymbolInfoDouble(_Symbol, SYMBOL_BID) - gd_508 >= ld_1196 * _Point)
            gi_572 = true;
        }
      if(gi_560 < 1)
        {
         gi_580 = false;
         gi_576 = false;
         gi_572 = true;
         gd_452 = AccountInfoDouble(ACCOUNT_EQUITY);
        }
      if(gi_572)
        {
         gd_500 = FindLastBuyPrice_15();
         gd_508 = FindLastSellPrice_15();
         if(gi_580)
           {
            gi_544 = gi_560;
            gd_548 = NormalizeDouble(ld_152 * MathPow(ld_1144, gi_544), li_1152);
            if(gd_548 > MaxLots)
               gd_548 = MaxLots;
            gi_584 = OpenPendingOrder_15(1, gd_548, SymbolInfoDouble(_Symbol, SYMBOL_BID), ld_1204, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, gs_528 + "-" + gi_544, g_magic_176_15, 0, clrHotPink);
            if(gi_584 < 0)
              {
               Print("Error: ", GetLastError());
               return;
              }
            gd_508 = FindLastSellPrice_15();
            gi_572 = false;
            gi_588 = true;
           }
         else
           {
            if(gi_576)
              {
               gi_544 = gi_560;
               gd_548 = NormalizeDouble(ld_152 * MathPow(ld_1144, gi_544), li_1152);
               if(gd_548 > MaxLots)
                  gd_548 = MaxLots;
               gi_584 = OpenPendingOrder_15(0, gd_548, SymbolInfoDouble(_Symbol, SYMBOL_ASK), ld_1204, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, gs_528 + "-" + gi_544, g_magic_176_15, 0, clrLime);
               if(gi_584 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_500 = FindLastBuyPrice_15();
               gi_572 = false;
               gi_588 = true;
              }
           }
        }
     }
   if(g_datetime_608 != iTime(_Symbol, g_timeframe_408, 0))
     {
      li_168    = PositionsTotal();
      count_172 = 0;
      for(int li_1212 = li_168; li_1212 >= 1; li_1212--)
        {
         if(!positionInfo.SelectByIndex(li_1212 - 1))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
            count_172++;
        }
      if((li_168 == 0 || count_172 < 1))
        {
         iclose_128 = iClose(_Symbol, 0, 2);
         iclose_136 = iClose(_Symbol, 0, 1);
         g_bid_484  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         g_ask_492  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         gi_544     = gi_560;
         gd_548     = ld_152;
         if(iclose_128 > iclose_136)
           {
            gi_584 = OpenPendingOrder_15(1, gd_548, g_bid_484, ld_1204, g_ask_492, 0, 0, gs_528 + "-" + gi_544, g_magic_176_15, 0, clrHotPink);
            if(gi_584 < 0)
              {
               Print("Error: ", GetLastError());
               return;
              }
            gd_500 = FindLastBuyPrice_15();
            gi_588 = true;
           }
         else
           {
            gi_584 = OpenPendingOrder_15(0, gd_548, g_ask_492, ld_1204, g_bid_484, 0, 0, gs_528 + "-" + gi_544, g_magic_176_15, 0, clrLime);
            if(gi_584 < 0)
              {
               Print("Error: ", GetLastError());
               return;
              }
            gd_508 = FindLastSellPrice_15();
            gi_588 = true;
           }
         if(gi_584 > 0)
            gi_540 = TimeCurrent() + 60.0 * (60.0 * gd_424);
         gi_572 = false;
        }
      g_datetime_608 = iTime(_Symbol, g_timeframe_408, 0);
     }
   gi_560         = CountTrades_15();
   g_price_476    = 0;
   double ld_1216 = 0;
   for(g_pos_556 = PositionsTotal() - 1; g_pos_556 >= 0; g_pos_556--)
     {
      if(!positionInfo.SelectByIndex(g_pos_556))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
           {
            g_price_476 += positionInfo.PriceOpen() * positionInfo.Volume();
            ld_1216 += positionInfo.Volume();
           }
        }
     }
   if(gi_560 > 0)
      g_price_476 = NormalizeDouble(g_price_476 / ld_1216, _Digits);
   if(gi_588)
     {
      for(g_pos_556 = PositionsTotal() - 1; g_pos_556 >= 0; g_pos_556--)
        {
         if(!positionInfo.SelectByIndex(g_pos_556))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
              {
               g_price_444   = g_price_476 + ld_1156 * _Point;
               gd_unused_460 = g_price_444;
               gd_564        = g_price_476 - g_pips_412 * _Point;
               gi_524        = true;
              }
           }
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               g_price_444   = g_price_476 - ld_1156 * _Point;
               gd_unused_468 = g_price_444;
               gd_564        = g_price_476 + g_pips_412 * _Point;
               gi_524        = true;
              }
           }
        }
     }
   if(gi_588)
     {
      if(gi_524 == true)
        {
         int last_pos_index = -1;
         for(g_pos_556 = PositionsTotal() - 1; g_pos_556 >= 0; g_pos_556--)
           {
            if(!positionInfo.SelectByIndex(g_pos_556))
               continue;
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
               continue;
            if(last_pos_index == -1)
               last_pos_index = g_pos_556;
            break;
           }
         if(last_pos_index >= 0)
           {
            if(!positionInfo.SelectByIndex(last_pos_index))
              {
               gi_588 = false;
              }
            else
               if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
                 {
                  trade.PositionModify(positionInfo.Ticket(), positionInfo.StopLoss(), g_price_444);
                  gi_588 = false;
                 }
           }
        }
     }
   double ld_1224   = LotExponent;
   int    li_1232   = lotdecimal;
   double ld_1236   = TakeProfit;
   bool   bool_1244 = UseEquityStop;
   double ld_1248   = TotalEquityRisk;
   bool   bool_1256 = UseTrailingStop;
   double ld_1260   = TrailStart;
   double ld_1268   = TrailStop;
   double ld_1276   = PipStep;
   double ld_1284   = slip;
   if(MM == true)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_176 = Lots;
      else
         ld_176 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   else
      ld_176 = Lots;
   if(bool_1256)
      TrailingAlls_16(ld_1260, ld_1268, g_price_692);
   if(gi_636)
     {
      if(TimeCurrent() >= gi_756)
        {
         CloseThisSymbolAll_16();
         Print("Closed All due to TimeOut");
        }
     }
   if(gi_752 != iTime(_Symbol, PERIOD_CURRENT, 0))
     {
      gi_752 = iTime(_Symbol, PERIOD_CURRENT, 0);
      ld_184 = CalculateProfit_16();
      if(bool_1244)
        {
         if(ld_184 < 0.0 && MathAbs(ld_184) > ld_1248 / 100.0 * AccountEquityHigh_16())
           {
            CloseThisSymbolAll_16();
            Print("Closed All due to Stop Out");
            gi_804 = false;
           }
        }
      gi_776 = CountTrades_16();
      if(gi_776 == 0)
         gi_740 = false;
      for(g_pos_772 = PositionsTotal() - 1; g_pos_772 >= 0; g_pos_772--)
        {
         if(!positionInfo.SelectByIndex(g_pos_772))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
              {
               gi_792 = true;
               gi_796 = false;
               break;
              }
           }
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               gi_792 = false;
               gi_796 = true;
               break;
              }
           }
        }
      if(gi_776 > 0 && gi_776 <= MaxTrades_16)
        {
         gd_716 = FindLastBuyPrice_16();
         gd_724 = FindLastSellPrice_16();
         if(gi_792 && gd_716 - SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= ld_1276 * _Point)
            gi_788 = true;
         if(gi_796 && SymbolInfoDouble(_Symbol, SYMBOL_BID) - gd_724 >= ld_1276 * _Point)
            gi_788 = true;
        }
      if(gi_776 < 1)
        {
         gi_796 = false;
         gi_792 = false;
         gd_668 = AccountInfoDouble(ACCOUNT_EQUITY);
        }
      if(gi_788)
        {
         gd_716 = FindLastBuyPrice_16();
         gd_724 = FindLastSellPrice_16();
         if(gi_796)
           {
            gi_760 = gi_776;
            gd_764 = NormalizeDouble(ld_176 * MathPow(ld_1224, gi_760), li_1232);
            if(gd_764 > MaxLots)
               gd_764 = MaxLots;
            gi_800 = OpenPendingOrder_16(0, gd_764, SymbolInfoDouble(_Symbol, SYMBOL_ASK), ld_1284, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, gs_744 + "-" + gi_760, g_magic_176_16, 0, clrHotPink);
            if(gi_800 < 0)
              {
               Print("Error: ", GetLastError());
               return;
              }
            gd_724 = FindLastSellPrice_16();
            gi_788 = false;
            gi_804 = true;
           }
         else
           {
            if(gi_792)
              {
               gi_760 = gi_776;
               gd_764 = NormalizeDouble(ld_176 * MathPow(ld_1224, gi_760), li_1232);
               if(gd_764 > MaxLots)
                  gd_764 = MaxLots;
               gi_800 = OpenPendingOrder_16(0, gd_764, SymbolInfoDouble(_Symbol, SYMBOL_ASK), ld_1284, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, gs_744 + "-" + gi_760, g_magic_176_16, 0, clrLime);
               if(gi_800 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_716 = FindLastBuyPrice_16();
               gi_788 = false;
               gi_804 = true;
              }
           }
        }
     }
   if(g_datetime_824 != iTime(_Symbol, g_timeframe_624, 0))
     {
      li_192    = PositionsTotal();
      count_196 = 0;
      for(int li_1292 = li_192; li_1292 >= 1; li_1292--)
        {
         if(!positionInfo.SelectByIndex(li_1292 - 1))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
            count_196++;
        }
      if((li_192 == 0 || count_196 < 1))
        {
         iclose_128 = iClose(_Symbol, 0, 2);
         iclose_136 = iClose(_Symbol, 0, 1);
         g_bid_700  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         g_ask_708  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         gi_760     = gi_776;
         gd_764     = ld_176;
         if(iclose_128 > iclose_136)
           {
            double rsi_buffer[];
            ArraySetAsSeries(rsi_buffer, true);
            if(CopyBuffer(rsi_handle, 0, 0, 2, rsi_buffer) == 2 && rsi_buffer[1] > 50.0)
              {
               gi_800 = OpenPendingOrder_16(0, gd_764, g_ask_708, ld_1284, g_bid_700, 0, 0, gs_744 + "-" + gi_760, g_magic_176_16, 0, clrHotPink);
               if(gi_800 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_716 = FindLastBuyPrice_16();
               gi_804 = true;
              }
           }
         else
           {
            double rsi_buffer[];
            ArraySetAsSeries(rsi_buffer, true);
            if(CopyBuffer(rsi_handle, 0, 0, 2, rsi_buffer) == 2 && rsi_buffer[1] < 50.0)
              {
               gi_800 = OpenPendingOrder_16(0, gd_764, g_ask_708, ld_1284, g_bid_700, 0, 0, gs_744 + "-" + gi_760, g_magic_176_16, 0, clrLime);
               if(gi_800 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_724 = FindLastSellPrice_16();
               gi_804 = true;
              }
           }
         if(gi_800 > 0)
            gi_756 = TimeCurrent() + 60.0 * (60.0 * gd_640);
         gi_788 = false;
        }
      g_datetime_824 = iTime(_Symbol, g_timeframe_624, 0);
     }
   gi_776         = CountTrades_16();
   g_price_692    = 0;
   double ld_1296 = 0;
   for(g_pos_772 = PositionsTotal() - 1; g_pos_772 >= 0; g_pos_772--)
     {
      if(!positionInfo.SelectByIndex(g_pos_772))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
           {
            g_price_692 += positionInfo.PriceOpen() * positionInfo.Volume();
            ld_1296 += positionInfo.Volume();
           }
        }
     }
   if(gi_776 > 0)
      g_price_692 = NormalizeDouble(g_price_692 / ld_1296, _Digits);
   if(gi_804)
     {
      for(g_pos_772 = PositionsTotal() - 1; g_pos_772 >= 0; g_pos_772--)
        {
         if(!positionInfo.SelectByIndex(g_pos_772))
            continue;
         if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
            continue;
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
              {
               g_price_660   = g_price_692 + ld_1236 * _Point;
               gd_unused_676 = g_price_660;
               gd_780        = g_price_692 - g_pips_628 * _Point;
               gi_740        = true;
              }
           }
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               g_price_660   = g_price_692 - ld_1236 * _Point;
               gd_unused_684 = g_price_660;
               gd_780        = g_price_692 + g_pips_628 * _Point;
               gi_740        = true;
              }
           }
        }
     }
   if(gi_804)
     {
      if(gi_740 == true)
        {
         int last_pos_index = -1;
         for(g_pos_772 = PositionsTotal() - 1; g_pos_772 >= 0; g_pos_772--)
           {
            if(!positionInfo.SelectByIndex(g_pos_772))
               continue;
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
               continue;
            if(last_pos_index == -1)
               last_pos_index = g_pos_772;
            break;
           }
         if(last_pos_index >= 0)
           {
            if(!positionInfo.SelectByIndex(last_pos_index))
              {
               gi_804 = false;
              }
            else
               if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
                 {
                  trade.PositionModify(positionInfo.Ticket(), positionInfo.StopLoss(), g_price_660);
                  gi_804 = false;
                 }
           }
        }
     }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_Hilo()
  {
   int count_0 = 0;
   for(int pos_4 = PositionsTotal() - 1; pos_4 >= 0; pos_4--)
     {
      if(!positionInfo.SelectByIndex(pos_4))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
         if(positionInfo.PositionType() == POSITION_TYPE_SELL || positionInfo.PositionType() == POSITION_TYPE_BUY)
            count_0++;
     }
   return (count_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_Hilo()
  {
   for(int pos_0 = PositionsTotal() - 1; pos_0 >= 0; pos_0--)
     {
      if(!positionInfo.SelectByIndex(pos_0))
         continue;
      if(positionInfo.Symbol() == _Symbol)
        {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
               trade.PositionClose(positionInfo.Ticket());
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
               trade.PositionClose(positionInfo.Ticket());
           }
         Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder_Hilo(int ai_0, double a_lots_4, double ad_unused_12, int a_slippage_20, double ad_unused_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52,
                          color a_color_56)
  {
   if(!cdDayLimit.evaluate())
     {
      return 0;
     }
   int ticket_60 = 0;
   int error_64  = 0;
   int count_68  = 0;
   int li_72     = 100;
   switch(ai_0)
     {
      case 0:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Buy(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), StopLong_Hilo(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_32), TakeLong_Hilo(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Sell(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), StopShort_Hilo(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_32), TakeShort_Hilo(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_Hilo(double ad_0, int ai_8)
  {
   if(useSl == false || ai_8 == 0)
      return 0;
   if(useSl)
      ai_8 = StopLoss;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_Hilo(double ad_0, int ai_8)
  {
   if(useSl == false || ai_8 == 0)
      return 0;
   if(useSl)
      ai_8 = StopLoss;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_Hilo(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_Hilo(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_Hilo()
  {
   double ld_ret_0 = 0;
   for(g_pos_344 = PositionsTotal() - 1; g_pos_344 >= 0; g_pos_344--)
     {
      if(!positionInfo.SelectByIndex(g_pos_344))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo)
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
            ld_ret_0 += positionInfo.Profit();
     }
   return (ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_Hilo(int ai_0, int ai_4, double a_price_8)
  {
   int    li_16;
   double order_stoploss_20;
   double price_28;
   if(ai_4 != 0)
     {
      for(int pos_36 = PositionsTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(positionInfo.SelectByIndex(pos_36))
           {
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
               continue;
            if(positionInfo.Symbol() == _Symbol || positionInfo.Magic() == MagicNumber_Hilo)
              {
               if(positionInfo.PositionType() == POSITION_TYPE_BUY)
                 {
                  li_16 = NormalizeDouble((SymbolInfoDouble(_Symbol, SYMBOL_BID) - a_price_8) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_BID) - ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
               if(positionInfo.PositionType() == POSITION_TYPE_SELL)
                 {
                  li_16 = NormalizeDouble((a_price_8 - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_Hilo()
  {
   if(CountTrades_Hilo() == 0)
      gd_380 = AccountInfoDouble(ACCOUNT_EQUITY);
   if(gd_380 < gd_388)
      gd_380 = gd_388;
   else
      gd_380 = AccountInfoDouble(ACCOUNT_EQUITY);
   gd_388 = AccountInfoDouble(ACCOUNT_EQUITY);
   return (gd_380);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_Hilo()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo && positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_Hilo()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber_Hilo)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo && positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_15()
  {
   int count_0 = 0;
   for(int pos_4 = PositionsTotal() - 1; pos_4 >= 0; pos_4--)
     {
      if(!positionInfo.SelectByIndex(pos_4))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
         if(positionInfo.PositionType() == POSITION_TYPE_SELL || positionInfo.PositionType() == POSITION_TYPE_BUY)
            count_0++;
     }
   return (count_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_15()
  {
   for(int pos_0 = PositionsTotal() - 1; pos_0 >= 0; pos_0--)
     {
      if(!positionInfo.SelectByIndex(pos_0))
         continue;
      if(positionInfo.Symbol() == _Symbol)
        {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
               trade.PositionClose(positionInfo.Ticket());
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
               trade.PositionClose(positionInfo.Ticket());
           }
         Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder_15(int ai_0, double a_lots_4, double ad_unused_12, int a_slippage_20, double ad_unused_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52,
                        color a_color_56)
  {
   if(!cdDayLimit.evaluate())
     {
      return 0;
     }
   int ticket_60 = 0;
   int error_64  = 0;
   int count_68  = 0;
   int li_72     = 100;
   switch(ai_0)
     {
      case 0:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Buy(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), StopLong_15(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_32), TakeLong_15(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Sell(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), StopShort_15(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_32), TakeShort_15(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_15(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_15(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_15(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_15(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_15()
  {
   double ld_ret_0 = 0;
   for(g_pos_556 = PositionsTotal() - 1; g_pos_556 >= 0; g_pos_556--)
     {
      if(!positionInfo.SelectByIndex(g_pos_556))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15)
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
            ld_ret_0 += positionInfo.Profit();
     }
   return (ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_15(int ai_0, int ai_4, double a_price_8)
  {
   int    li_16;
   double order_stoploss_20;
   double price_28;
   if(ai_4 != 0)
     {
      for(int pos_36 = PositionsTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(positionInfo.SelectByIndex(pos_36))
           {
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
               continue;
            if(positionInfo.Symbol() == _Symbol || positionInfo.Magic() == g_magic_176_15)
              {
               if(positionInfo.PositionType() == POSITION_TYPE_BUY)
                 {
                  li_16 = NormalizeDouble((SymbolInfoDouble(_Symbol, SYMBOL_BID) - a_price_8) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_BID) - ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
               if(positionInfo.PositionType() == POSITION_TYPE_SELL)
                 {
                  li_16 = NormalizeDouble((a_price_8 - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_15()
  {
   if(CountTrades_15() == 0)
      gd_592 = AccountInfoDouble(ACCOUNT_EQUITY);
   if(gd_592 < gd_600)
      gd_592 = gd_600;
   else
      gd_592 = AccountInfoDouble(ACCOUNT_EQUITY);
   gd_600 = AccountInfoDouble(ACCOUNT_EQUITY);
   return (gd_592);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_15()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15 && positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_15()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_15)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_15 && positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_16()
  {
   int count_0 = 0;
   for(int pos_4 = PositionsTotal() - 1; pos_4 >= 0; pos_4--)
     {
      if(!positionInfo.SelectByIndex(pos_4))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
         if(positionInfo.PositionType() == POSITION_TYPE_SELL || positionInfo.PositionType() == POSITION_TYPE_BUY)
            count_0++;
     }
   return (count_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_16()
  {
   for(int pos_0 = PositionsTotal() - 1; pos_0 >= 0; pos_0--)
     {
      if(!positionInfo.SelectByIndex(pos_0))
         continue;
      if(positionInfo.Symbol() == _Symbol)
        {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
           {
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
               trade.PositionClose(positionInfo.Ticket());
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
               trade.PositionClose(positionInfo.Ticket());
           }
         Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder_16(int ai_0, double a_lots_4, double ad_unused_12, int a_slippage_20, double ad_unused_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52,
                        color a_color_56)
  {
   if(!cdDayLimit.evaluate())
     {
      return 0;
     }
   int ticket_60 = 0;
   int error_64  = 0;
   int count_68  = 0;
   int li_72     = 100;
   switch(ai_0)
     {
      case 0:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Buy(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), StopLong_16(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_32), TakeLong_16(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < li_72; count_68++)
           {
            trade.SetExpertMagicNumber(a_magic_48);
            if(trade.Sell(a_lots_4, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), StopShort_16(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ai_32), TakeShort_16(SymbolInfoDouble(_Symbol, SYMBOL_BID), ai_36), a_comment_40))
              {
               ticket_60 = (int)trade.ResultOrder();
              }
            error_64  = GetLastError();
            if(error_64 == 0)
               break;
            if(!((error_64 == 4  || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_16(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_16(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_16(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 + ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_16(double ad_0, int ai_8)
  {
   if(ai_8 == 0)
      return 0;
   return (ad_0 - ai_8 * _Point);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_16()
  {
   double ld_ret_0 = 0;
   for(g_pos_772 = PositionsTotal() - 1; g_pos_772 >= 0; g_pos_772--)
     {
      if(!positionInfo.SelectByIndex(g_pos_772))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16)
         if(positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL)
            ld_ret_0 += positionInfo.Profit();
     }
   return (ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_16(int ai_0, int ai_4, double a_price_8)
  {
   int    li_16;
   double order_stoploss_20;
   double price_28;
   if(ai_4 != 0)
     {
      for(int pos_36 = PositionsTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(positionInfo.SelectByIndex(pos_36))
           {
            if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
               continue;
            if(positionInfo.Symbol() == _Symbol || positionInfo.Magic() == g_magic_176_16)
              {
               if(positionInfo.PositionType() == POSITION_TYPE_BUY)
                 {
                  li_16 = NormalizeDouble((SymbolInfoDouble(_Symbol, SYMBOL_BID) - a_price_8) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_BID) - ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
               if(positionInfo.PositionType() == POSITION_TYPE_SELL)
                 {
                  li_16 = NormalizeDouble((a_price_8 - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / _Point, 0);
                  if(li_16 < ai_0)
                     continue;
                  order_stoploss_20 = positionInfo.StopLoss();
                  price_28          = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + ai_4 * _Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     trade.PositionModify(positionInfo.Ticket(), price_28, positionInfo.TakeProfit());
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_16()
  {
   if(CountTrades_16() == 0)
      gd_808 = AccountInfoDouble(ACCOUNT_EQUITY);
   if(gd_808 < gd_816)
      gd_808 = gd_816;
   else
      gd_808 = AccountInfoDouble(ACCOUNT_EQUITY);
   gd_816 = AccountInfoDouble(ACCOUNT_EQUITY);
   return (gd_808);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_16()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16 && positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_16()
  {
   double order_open_price_0 = 0.0;
   int    ticket_8;
   double ld_unused_12 = 0;
   int    ticket_20    = 0;
   for(int pos_24 = PositionsTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(!positionInfo.SelectByIndex(pos_24))
         continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != g_magic_176_16)
         continue;
      if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16 && positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         ticket_8 = positionInfo.Ticket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = positionInfo.PriceOpen();
            ld_unused_12       = order_open_price_0;
            ticket_20          = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBuyOrderExist()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && positionInfo.Magic() == g_magic_176_16 && positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSellOrderExist()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber_Hilo && positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         return true;
        }
     }
   return false;
  }
double LotSize = Lots;
int Slippage = slip;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {
   if(!cdDayLimit.evaluate())
     {
      Print("OpenBuyOrder: Daily limit reached, not opening");
      return;
     }
   if(!IsBuyOrderExist())
     {
      Print("OpenBuyOrder: No Buy position found, attempting to open...");
      double buyPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double tp = buyPrice + TakeProfit * _Point;
      trade.SetExpertMagicNumber(g_magic_176_16);
      if(trade.Buy(LotSize, _Symbol, buyPrice, 0, tp, "First-Order Buy"))
        {
         Print("OpenBuyOrder: Successfully opened Buy position");
        }
      else
        {
         Print("OpenBuyOrder: Failed to open Buy position, error: ", trade.ResultRetcode());
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSellOrder()
  {
   if(!cdDayLimit.evaluate())
     {
      Print("OpenSellOrder: Daily limit reached, not opening");
      return;
     }
   if(!IsSellOrderExist())
     {
      Print("OpenSellOrder: No Sell position found, attempting to open...");
      double sellPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double tp = sellPrice - TakeProfit * _Point;
      trade.SetExpertMagicNumber(MagicNumber_Hilo);
      if(trade.Sell(LotSize, _Symbol, sellPrice, 0, tp, "First-Order Sell"))
        {
         Print("OpenSellOrder: Successfully opened Sell position");
        }
      else
        {
         Print("OpenSellOrder: Failed to open Sell position, error: ", trade.ResultRetcode());
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTPForOrders(int type, double takeProfit)
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && (int)positionInfo.PositionType() == type)
        {
         double currentTP = positionInfo.TakeProfit();
         if(MathAbs(currentTP - takeProfit) > _Point)
           {
            trade.PositionModify(positionInfo.Ticket(), positionInfo.StopLoss(), takeProfit);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetTakeProfit()
  {
   double totalLotsBuy     = 0.0;
   double totalLotsSell    = 0.0;
   double averagePriceBuy  = 0.0;
   double averagePriceSell = 0.0;
   int    countBuy         = 0;
   int    countSell        = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol)
        {
         if(positionInfo.PositionType() == POSITION_TYPE_BUY)
           {
            totalLotsBuy += positionInfo.Volume();
            averagePriceBuy += positionInfo.PriceOpen() * positionInfo.Volume();
            countBuy++;
           }
         else
            if(positionInfo.PositionType() == POSITION_TYPE_SELL)
              {
               totalLotsSell += positionInfo.Volume();
               averagePriceSell += positionInfo.PriceOpen() * positionInfo.Volume();
               countSell++;
              }
        }
     }
   if(countBuy >= 1)
     {
      averagePriceBuy /= totalLotsBuy;
      ModifyTPForOrders(POSITION_TYPE_BUY, averagePriceBuy + TakeProfit * _Point);
     }
   if(countSell >= 1)
     {
      averagePriceSell /= totalLotsSell;
      ModifyTPForOrders(POSITION_TYPE_SELL, averagePriceSell - TakeProfit * _Point);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Loadtext()
  {
   datetime    currentTime = TimeCurrent();
   MqlDateTime mqlDateTime;
   TimeToStruct(currentTime, mqlDateTime);
   int    day         = mqlDateTime.day;
   int    month       = mqlDateTime.mon;
   int    year        = mqlDateTime.year;
   int    dayOfWeek   = mqlDateTime.day_of_week;
   string dayNames[7] = {"SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};
   string today       = dayNames[dayOfWeek];
   string fullDate = "" + today + ", " + IntegerToString(day) + "-" + IntegerToString(month) + "-" + IntegerToString(year);
   ObjectSetString(0, "lblDay", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblDay", OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, "lblDay", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "lblDay", OBJPROP_COLOR, clrRed);
   SetText("lblDay", "" + fullDate, x_axis + 1250, y_axis + 1, clrYellow, 12);
   int    totalBuyOrders  = 0;
   double totalBuyLot     = 0.0;
   int    totalSellOrders = 0;
   double totalSellLot    = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         totalBuyOrders++;
         totalBuyLot += positionInfo.Volume();
        }
     }
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         totalSellOrders++;
         totalSellLot += positionInfo.Volume();
        }
     }
   ObjectSetString(0, "lblBuy", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblBuy", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblBuy", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblBuy", OBJPROP_COLOR, clrLimeGreen);
   SetText("lblBuy", "Buy Order: " + totalBuyOrders + " | Lot: " + NormalizeDouble(totalBuyLot, 2), x_axis + 1250, y_axis + 25, clrAqua, 12);
   ObjectSetString(0, "lblSel", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblSel", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblSel", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblSel", OBJPROP_COLOR, clrRed);
   SetText("lblSel", "Sell Order: " + totalSellOrders + " | Lot: " + NormalizeDouble(totalSellLot, 2), x_axis + 1250, y_axis + 50, clrRed, 12);
   double totalProfit = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i))
        {
         if((positionInfo.PositionType() == POSITION_TYPE_BUY || positionInfo.PositionType() == POSITION_TYPE_SELL) && positionInfo.Symbol() == _Symbol)
           {
            double profit = positionInfo.Profit();
            totalProfit += profit;
           }
        }
     }
   double total_Only_Profit = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol && positionInfo.Profit() > 0)
        {
         total_Only_Profit += positionInfo.Profit();
        }
     }
   ObjectSetString(0, "lblPro1", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblPro1", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblPro1", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblPro1", OBJPROP_COLOR, clrMagenta);
   SetText("lblPro1", "Profit: " + NormalizeDouble(totalProfit, 2), x_axis + 1250, y_axis + 70, clrMagenta, 12);
   ObjectSetString(0, "lblPro", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblPro", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblPro", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblPro", OBJPROP_COLOR, clrMagenta);
   SetText("lblPro", "Floating: " + NormalizeDouble(totalProfit, 2) + " | B:" + NormalizeDouble(totalBuyLot, 2) + " | S:" + NormalizeDouble(totalSellLot, 2), x_axis + 450, y_axis - 57, clrAqua, 20);
   ObjectSetString(0, "lblLine", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblLine", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblLine", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblLine", OBJPROP_COLOR, clrMagenta);
   SetText("lblLine", "____________________________________________", x_axis + 450, y_axis - 46, clrWhite, 15);
   ObjectSetString(0, "lblOnPro", OBJPROP_TEXT, "");
   ObjectSetString(0, "lblOnPro", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "lblOnPro", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "lblOnPro", OBJPROP_COLOR, clrMagenta);
   SetText("lblOnPro", "Only Profit: " + NormalizeDouble(total_Only_Profit, 2), x_axis + 450, y_axis - 24, clrAqua, 20);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Create_Button(string but_name, string label, int xsize, int ysize, int xdist, int ydist, int bcolor, int fcolor)
  {
   if(ObjectFind(0, but_name) < 0)
     {
      if(!ObjectCreate(0, but_name, OBJ_BUTTON, 0, 0, 0))
        {
         Print(__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
         return;
        }
      ObjectSetString(0, but_name, OBJPROP_TEXT, label);
      ObjectSetInteger(0, but_name, OBJPROP_XSIZE, xsize);
      ObjectSetInteger(0, but_name, OBJPROP_YSIZE, ysize);
      ObjectSetInteger(0, but_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, but_name, OBJPROP_XDISTANCE, xdist);
      ObjectSetInteger(0, but_name, OBJPROP_YDISTANCE, ydist);
      ObjectSetInteger(0, but_name, OBJPROP_BGCOLOR, bcolor);
      ObjectSetInteger(0, but_name, OBJPROP_COLOR, fcolor);
      ObjectSetInteger(0, but_name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, but_name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, but_name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string name, string text, int xPos, int yPos, color colour, int fontsize = 12)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
   ObjectSetInteger(0, name, OBJPROP_COLOR, colour);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetObjText(string name, string CharToStr, int xPos, int yPos, color colour, int fontsize = 12)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, colour);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, CharToStr);
   ObjectSetString(0, name, OBJPROP_FONT, "Wingdings");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_profit()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(positionInfo.SelectByIndex(i) && positionInfo.Symbol() == _Symbol)
        {
         trade.PositionClose(positionInfo.Ticket());
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_Only_profit()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i) &&
         positionInfo.Symbol() == _Symbol)
        {
         if((positionInfo.PositionType() == POSITION_TYPE_BUY && positionInfo.Profit() > 0) || (positionInfo.PositionType() == POSITION_TYPE_SELL && positionInfo.Profit() > 0))
           {
            trade.PositionClose(positionInfo.Ticket());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(sparam == button_close_basket_Prof)
     {
      ObjectSetString(0, button_close_basket_Prof, OBJPROP_TEXT, "Closing...");
      close_profit();
      ObjectSetInteger(0, button_close_basket_Prof, OBJPROP_STATE, 0);
      ObjectSetString(0, button_close_basket_Prof, OBJPROP_TEXT, "Close Order");
      return;
     }
   if(sparam == button_close_Profit)
     {
      ObjectSetString(0, button_close_Profit, OBJPROP_TEXT, "Closing...");
      close_Only_profit();
      ObjectSetInteger(0, button_close_Profit, OBJPROP_STATE, 0);
      ObjectSetString(0, button_close_Profit, OBJPROP_TEXT, "Close Profit");
      return;
     }
  }

void RemoveGrid() { ChartSetInteger(0, CHART_SHOW_GRID, false); }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Elise_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75311&p=160182#p160182
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
