/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        AF_Global_Expert_Full_v4
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=152713#p152713
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

#property description "COMBINED AF-Scalper.Ltd, AF-FiboScalper And AF-TrendKiller"
#property description "Expert Type Scalping Day"
#property description "Minimum Deposit 1000$/2 Pair - EURUSD GBPUSD"
#property description "Recommended Pair EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY"
#property description "TF H1"
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
CTrade trade;
CPositionInfo posInfo;
COrderInfo ordInfo;
input group "=== GLOBAL SETTINGS ==="
input string LicenceTO = "Juan Guillermo Lara";
input string OnlineIndicatorAddress = "103.233.102.2"; //Online Indicator
input string IndicatorServer = "https://afs-id.com"; //Connecting to server
input bool UseOnlineIndicator = true;
input double Lots = 0.01;
input double LotExponent = 1.44;
input int lotdecimal = 2;
input double PercentToChangePipStep = 2.0; //DD Percent To double Pip Step
input double PipStep = 180.0;
input double MaxLots = 99.0;
input bool MM = false;
input double TakeProfit = 50.0;
input bool UseEquityStop = false;
input double TotalEquityRisk = 20.0;
input group "=== AF-FiboScalper SETTINGS ==="
input int MaxTrades_Hilo = 20;
input int MagicNumber_Hilo = 10278;
input group "=== AF-Scalper SETTINGS ==="
input int MaxTrades_15 = 20;
input int g_magic_176_15 = 22324;
input group "=== AF-TrendKiller SETTINGS ==="
input int MaxTrades_16 = 20;
input int g_magic_176_16 = 23794;
input bool UseNewsFilter = false;
input group "=== Filters Orders ==="
input bool filterSymbolsOn = true;
input string SymbolsList = "GBPUSD,EURUSD";
input bool filterMagicsOn = true;
input string MagicsList = "2022";
enum TSLMode
  {
   byPips,  // By Pips
   byMA     // By Moving Average
  };
input group "=== TrailingStop Setup ==="
input bool TslON = false; //TSL ON
input TSLMode userTslMode = byPips;
input int userTslInitialStep = 1; //TSL Initial Step
input int userTslStep = 1; //TSL Step
input int userTslDistance = 20; //TSL Distance
input group "=== Breakeven Setup ==="
input bool breakevenOn = false; //Breakeven On
input double userBkvPips = 10; //Breakeven Pips
input double userBkvStep = 3; //Breakeven Step
enum CloseAllMode
  {
   CloseByMoney,          // by Money
   CloseByAccountPercent  // by Account Percent
  };
input group "=== Close All Options ==="
input bool closeAllControlON = false; //Close All Control On
input CloseAllMode closeBy = CloseByMoney; //Close All Mode
input double closeAllMoney = 100; //Close by Money $
input double closeAllMoneyLoss = -100; //Close by Money Lossing $
input double accountPerWin = 1; //Account Percent Win
input double accountPerLos = -1; //Account Percent Loss
bool UseTrailingStop = false;
double TrailStart = 13.0;
double TrailStop = 3.0;
double slip = 5.0;
double ld_1276 = PipStep;
double ld_1196 = PipStep;
double ld_1112 = PipStep;
bool gi_184 = false;
double gd_188 = 48.0;
double g_pips_196 = 40.0;
double g_slippage_204;
double g_price_216;
double gd_224;
double gd_unused_232;
double gd_unused_240;
double gd_248;
double gd_256;
double g_price_264;
double g_bid_272;
double g_ask_280;
double gd_288;
double gd_296;
double gd_304;
bool gi_312;
string gs_316 = "Global*AF-FiboScalper/2019";
datetime gi_324 = 0;
datetime gi_328;
int gi_332 = 0;
double gd_336;
int g_pos_344 = 0;
int gi_348;
double gd_352 = 0.0;
bool gi_360 = false;
bool gi_364 = false;
bool gi_368 = false;
int gi_372;
bool gi_376 = false;
double gd_380;
double gd_388;
int g_timeframe_408 = PERIOD_H1;
double g_pips_412 = 40.0;
bool gi_420 = false;
double gd_424 = 48.0;
ulong g_slippage_432;
double g_price_444;
double gd_452;
double gd_unused_460;
double gd_unused_468;
double g_price_476;
double g_bid_484;
double g_ask_492;
double gd_500;
double gd_508;
double gd_516;
bool gi_524;
string gs_528 = "Global*AF-Scalper.Ltd/2019";
int gi_536 = 0;
int gi_540;
int gi_544 = 0;
double gd_548;
int g_pos_556 = 0;
int gi_560;
double gd_564 = 0.0;
bool gi_572 = false;
bool gi_576 = false;
bool gi_580 = false;
int gi_584;
bool gi_588 = false;
double gd_592;
double gd_600;
datetime g_datetime_608 = 0;
int g_timeframe_624 = PERIOD_M1;
double g_pips_628 = 40.0;
bool gi_636 = false;
double gd_640 = 48.0;
ulong g_slippage_648;
double g_price_660;
double gd_668;
double gd_unused_676;
double gd_unused_684;
double g_price_692;
double g_bid_700;
double g_ask_708;
double gd_716;
double gd_724;
double gd_732;
bool gi_740;
string gs_744 = "Global*AF-TrendKiller/2019";
int gi_752 = 0;
int gi_756;
int gi_760 = 0;
double gd_764;
int g_pos_772 = 0;
int gi_776;
double gd_780 = 0.0;
bool gi_788 = false;
bool gi_792 = false;
bool gi_796 = false;
int gi_800;
bool gi_804 = false;
bool cg = false;
double gd_808;
double gd_816;
datetime g_datetime_824 = 0;
ENUM_TIMEFRAMES g_timeframe_828 = PERIOD_M1;
ENUM_TIMEFRAMES g_timeframe_832 = PERIOD_M5;
ENUM_TIMEFRAMES g_timeframe_836 = PERIOD_M15;
ENUM_TIMEFRAMES g_timeframe_840 = PERIOD_M30;
ENUM_TIMEFRAMES g_timeframe_844 = PERIOD_H1;
ENUM_TIMEFRAMES g_timeframe_848 = PERIOD_H4;
ENUM_TIMEFRAMES g_timeframe_852 = PERIOD_D1;
bool g_corner_856 = true;
int gi_860 = 0;
int gi_864 = 10;
int g_window_868 = 0;
bool gi_872 = true;
bool gi_unused_876 = true;
bool gi_880 = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeframeLabel(ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_M1)
      return "M1";
   if(tf == PERIOD_M5)
      return "M5";
   if(tf == PERIOD_M15)
      return "M15";
   if(tf == PERIOD_M30)
      return "M30";
   if(tf == PERIOD_H1)
      return "H1";
   if(tf == PERIOD_H4)
      return "H4";
   if(tf == PERIOD_D1)
      return "D1";
   if(tf == PERIOD_W1)
      return "W1";
   if(tf == PERIOD_MN1)
      return "MN";
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PanelCorner()
  {
   return g_corner_856 ? CORNER_RIGHT_UPPER : CORNER_LEFT_UPPER;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateIndicatorPanel()
  {
   if(gi_860 < 0)
      return;
   const int corner = PanelCorner();
   const int windowId = g_window_868;
   static bool handleWarned = false;
   for(int i = 0; i < 7; i++)
     {
      if(macd_handle[i] <= 0 || rsi_handle[i] <= 0 || cci_handle[i] <= 0 || stoch_handle[i] <= 0 || ma_fast_handle[i] <= 0 || ma_slow_handle[i] <= 0)
        {
         if(!handleWarned)
            Print("UpdateIndicatorPanel: indicator handles not ready, skipping draw.");
         handleWarned = true;
         return;
        }
     }
   static bool firstDrawLogged = false;
   if(!firstDrawLogged)
     {
      Print("UpdateIndicatorPanel: drawing panel (handles ready)");
      firstDrawLogged = true;
     }
   string tfLabels[7];
   tfLabels[0] = TimeframeLabel(g_timeframe_828);
   tfLabels[1] = TimeframeLabel(g_timeframe_832);
   tfLabels[2] = TimeframeLabel(g_timeframe_836);
   tfLabels[3] = TimeframeLabel(g_timeframe_840);
   tfLabels[4] = TimeframeLabel(g_timeframe_844);
   tfLabels[5] = TimeframeLabel(g_timeframe_848);
   tfLabels[6] = TimeframeLabel(g_timeframe_852);
   int xOffsets[7] = {0, 0, 0, 0, 0, 0, 0};
   if(g_timeframe_828 == PERIOD_M15 || g_timeframe_828 == PERIOD_M30)
      xOffsets[0] = -2;
   if(g_timeframe_832 == PERIOD_M15 || g_timeframe_832 == PERIOD_M30)
      xOffsets[1] = -2;
   if(g_timeframe_836 == PERIOD_M15 || g_timeframe_836 == PERIOD_M30)
      xOffsets[2] = -2;
   if(g_timeframe_840 == PERIOD_M15 || g_timeframe_840 == PERIOD_M30)
      xOffsets[3] = -2;
   if(g_timeframe_844 == PERIOD_M15 || g_timeframe_844 == PERIOD_M30)
      xOffsets[4] = -2;
   if(g_timeframe_848 == PERIOD_M15 || g_timeframe_848 == PERIOD_M30)
      xOffsets[5] = -2;
   if(g_timeframe_852 == PERIOD_M15 || g_timeframe_852 == PERIOD_M30)
      xOffsets[6] = -2;
   string tfObjNames[7] = {"SIG_BARS_TF1", "SIG_BARS_TF2", "SIG_BARS_TF3", "SIG_BARS_TF4", "SIG_BARS_TF5", "SIG_BARS_TF6", "SIG_BARS_TF7"};
   int tfXBase[7] = {134, 114, 94, 74, 54, 34, 14};
   for(int i = 0; i < 7; i++)
     {
      ObjectDelete(0, tfObjNames[i]);
      ObjectCreate(0, tfObjNames[i], OBJ_LABEL, windowId, 0, 0);
      ObjectSetString(0, tfObjNames[i], OBJPROP_TEXT, tfLabels[i]);
      ObjectSetInteger(0, tfObjNames[i], OBJPROP_FONTSIZE, 7);
      ObjectSetString(0, tfObjNames[i], OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, tfObjNames[i], OBJPROP_COLOR, g_color_884);
      ObjectSetInteger(0, tfObjNames[i], OBJPROP_CORNER, corner);
      ObjectSetInteger(0, tfObjNames[i], OBJPROP_XDISTANCE, gi_864 + tfXBase[i] + xOffsets[i]);
      ObjectSetInteger(0, tfObjNames[i], OBJPROP_YDISTANCE, gi_860 + 25);
     }
   double macdMain[7], macdSignal[7];
   ArrayInitialize(macdMain, 0.0);
   ArrayInitialize(macdSignal, 0.0);
   for(int i = 0; i < 7; i++)
     {
      double mainBuf[1], sigBuf[1];
      if(CopyBuffer(macd_handle[i], 0, 0, 1, mainBuf) == 1)
         macdMain[i] = mainBuf[0];
      if(CopyBuffer(macd_handle[i], 1, 0, 1, sigBuf) == 1)
         macdSignal[i] = sigBuf[0];
     }
   string macdTexts[7];
   color macdColors[7];
   for(int i = 0; i < 7; i++)
     {
      macdTexts[i] = "-";
      if(macdMain[i] > macdSignal[i] && macdMain[i] > 0.0)
         macdColors[i] = g_color_948;
      else
         if(macdMain[i] <= macdSignal[i] && macdMain[i] < 0.0)
            macdColors[i] = g_color_960;
         else
            if(macdMain[i] > macdSignal[i])
               macdColors[i] = g_color_956;
            else
               macdColors[i] = g_color_952;
     }
   ObjectDelete(0, "SSignalMACD_TEXT");
   ObjectCreate(0, "SSignalMACD_TEXT", OBJ_LABEL, windowId, 0, 0);
   ObjectSetString(0, "SSignalMACD_TEXT", OBJPROP_TEXT, "MACD");
   ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_FONTSIZE, 6);
   ObjectSetString(0, "SSignalMACD_TEXT", OBJPROP_FONT, "Tahoma Narrow");
   ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_COLOR, g_color_888);
   ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_CORNER, corner);
   ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_XDISTANCE, gi_864 + 153);
   ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_YDISTANCE, gi_860 + 35);
   string macdObjNames[7] = {"SSignalMACDM1", "SSignalMACDM5", "SSignalMACDM15", "SSignalMACDM30", "SSignalMACDH1", "SSignalMACDH4", "SSignalMACDD1"};
   int macdXBase[7] = {130, 110, 90, 70, 50, 30, 10};
   for(int i = 0; i < 7; i++)
     {
      ObjectDelete(0, macdObjNames[i]);
      ObjectCreate(0, macdObjNames[i], OBJ_LABEL, windowId, 0, 0);
      ObjectSetString(0, macdObjNames[i], OBJPROP_TEXT, macdTexts[i]);
      ObjectSetInteger(0, macdObjNames[i], OBJPROP_FONTSIZE, 45);
      ObjectSetString(0, macdObjNames[i], OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, macdObjNames[i], OBJPROP_COLOR, macdColors[i]);
      ObjectSetInteger(0, macdObjNames[i], OBJPROP_CORNER, corner);
      ObjectSetInteger(0, macdObjNames[i], OBJPROP_XDISTANCE, gi_864 + macdXBase[i]);
      ObjectSetInteger(0, macdObjNames[i], OBJPROP_YDISTANCE, gi_860 + 2);
     }
   double rsiVals[7];
   double stochVals[7];
   double cciVals[7];
   ArrayInitialize(rsiVals, 0.0);
   ArrayInitialize(stochVals, 0.0);
   ArrayInitialize(cciVals, 0.0);
   for(int i = 0; i < 7; i++)
     {
      double rsiBuf[1], stochBuf[1], cciBuf[1];
      if(CopyBuffer(rsi_handle[i], 0, 0, 1, rsiBuf) == 1)
         rsiVals[i] = rsiBuf[0];
      if(CopyBuffer(stoch_handle[i], 0, 0, 1, stochBuf) == 1)
         stochVals[i] = stochBuf[0];
      if(CopyBuffer(cci_handle[i], 0, 0, 1, cciBuf) == 1)
         cciVals[i] = cciBuf[0];
     }
   string strTexts[7];
   color strColors[7];
   for(int i = 0; i < 7; i++)
     {
      strTexts[i] = "-";
      strColors[i] = g_color_1044;
      if(rsiVals[i] > 50.0 && stochVals[i] > 40.0 && cciVals[i] > 0.0)
         strColors[i] = g_color_1036;
      else
         if(rsiVals[i] < 50.0 && stochVals[i] < 60.0 && cciVals[i] < 0.0)
            strColors[i] = g_color_1040;
     }
   ObjectDelete(0, "SSignalSTR_TEXT");
   ObjectCreate(0, "SSignalSTR_TEXT", OBJ_LABEL, windowId, 0, 0);
   ObjectSetString(0, "SSignalSTR_TEXT", OBJPROP_TEXT, "STR");
   ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_FONTSIZE, 6);
   ObjectSetString(0, "SSignalSTR_TEXT", OBJPROP_FONT, "Tahoma Narrow");
   ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_COLOR, g_color_888);
   ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_CORNER, corner);
   ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_XDISTANCE, gi_864 + 153);
   ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_YDISTANCE, gi_860 + 43);
   string strObjNames[7] = {"SignalSTRM1", "SignalSTRM5", "SignalSTRM15", "SignalSTRM30", "SignalSTRH1", "SignalSTRH4", "SignalSTRD1"};
   int strXBase[7] = {130, 110, 90, 70, 50, 30, 10};
   for(int i = 0; i < 7; i++)
     {
      ObjectDelete(0, strObjNames[i]);
      ObjectCreate(0, strObjNames[i], OBJ_LABEL, windowId, 0, 0);
      ObjectSetString(0, strObjNames[i], OBJPROP_TEXT, strTexts[i]);
      ObjectSetInteger(0, strObjNames[i], OBJPROP_FONTSIZE, 45);
      ObjectSetString(0, strObjNames[i], OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, strObjNames[i], OBJPROP_COLOR, strColors[i]);
      ObjectSetInteger(0, strObjNames[i], OBJPROP_CORNER, corner);
      ObjectSetInteger(0, strObjNames[i], OBJPROP_XDISTANCE, gi_864 + strXBase[i]);
      ObjectSetInteger(0, strObjNames[i], OBJPROP_YDISTANCE, gi_860 + 10);
     }
   double maFast[7];
   double maSlow[7];
   ArrayInitialize(maFast, 0.0);
   ArrayInitialize(maSlow, 0.0);
   for(int i = 0; i < 7; i++)
     {
      double fastBuf[1], slowBuf[1];
      if(CopyBuffer(ma_fast_handle[i], 0, 0, 1, fastBuf) == 1)
         maFast[i] = fastBuf[0];
      if(CopyBuffer(ma_slow_handle[i], 0, 0, 1, slowBuf) == 1)
         maSlow[i] = slowBuf[0];
     }
   string emaTexts[7];
   color emaColors[7];
   for(int i = 0; i < 7; i++)
     {
      emaTexts[i] = "-";
      emaColors[i] = (maFast[i] > maSlow[i]) ? g_color_1080 : g_color_1084;
     }
   ObjectDelete(0, "SignalEMA_TEXT");
   ObjectCreate(0, "SignalEMA_TEXT", OBJ_LABEL, windowId, 0, 0);
   ObjectSetString(0, "SignalEMA_TEXT", OBJPROP_TEXT, "EMA");
   ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_FONTSIZE, 6);
   ObjectSetString(0, "SignalEMA_TEXT", OBJPROP_FONT, "Tahoma Narrow");
   ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_COLOR, g_color_888);
   ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_CORNER, corner);
   ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_XDISTANCE, gi_864 + 153);
   ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_YDISTANCE, gi_860 + 51);
   string emaObjNames[7] = {"SignalEMAM1", "SignalEMAM5", "SignalEMAM15", "SignalEMAM30", "SignalEMAH1", "SignalEMAH4", "SignalEMAD1"};
   int emaXBase[7] = {130, 110, 90, 70, 50, 30, 10};
   for(int i = 0; i < 7; i++)
     {
      ObjectDelete(0, emaObjNames[i]);
      ObjectCreate(0, emaObjNames[i], OBJ_LABEL, windowId, 0, 0);
      ObjectSetString(0, emaObjNames[i], OBJPROP_TEXT, emaTexts[i]);
      ObjectSetInteger(0, emaObjNames[i], OBJPROP_FONTSIZE, 45);
      ObjectSetString(0, emaObjNames[i], OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, emaObjNames[i], OBJPROP_COLOR, emaColors[i]);
      ObjectSetInteger(0, emaObjNames[i], OBJPROP_CORNER, corner);
      ObjectSetInteger(0, emaObjNames[i], OBJPROP_XDISTANCE, gi_864 + emaXBase[i]);
      ObjectSetInteger(0, emaObjNames[i], OBJPROP_YDISTANCE, gi_860 + 18);
     }
   ChartRedraw();
  }
color g_color_884 = clrGray;
color g_color_888 = clrGray;
color g_color_892 = clrGray;
color g_color_896 = clrDarkOrange;
int gi_unused_900 = 36095;
color g_color_904 = clrLime;
color g_color_908 = clrOrangeRed;
int gi_912 = 65280;
int gi_916 = 17919;
color g_color_920 = clrLime;
color g_color_924 = clrRed;
color g_color_928 = clrOrange;
int g_period_932 = 8;
int g_period_936 = 17;
int g_period_940 = 9;
ENUM_APPLIED_PRICE g_applied_price_944 = PRICE_CLOSE;
color g_color_948 = clrLime;
color g_color_952 = clrTomato;
color g_color_956 = clrGreen;
color g_color_960 = clrRed;
int g_period_980 = 9;
ENUM_APPLIED_PRICE g_applied_price_984 = PRICE_CLOSE;
int g_period_996 = 13;
ENUM_APPLIED_PRICE g_applied_price_1000 = PRICE_CLOSE;
int g_period_1012 = 5;
int g_period_1016 = 3;
int g_slowing_1020 = 3;
ENUM_MA_METHOD g_ma_method_1024 = MODE_EMA;
color g_color_1036 = clrLime;
color g_color_1040 = clrRed;
color g_color_1044 = clrOrange;
int g_period_1056 = 5;
int g_period_1060 = 9;
ENUM_MA_METHOD g_ma_method_1064 = MODE_EMA;
ENUM_APPLIED_PRICE g_applied_price_1068 = PRICE_CLOSE;
color g_color_1080 = clrLime;
color g_color_1084 = clrRed;
string gs_dummy_1088;
string g_text_1096;
string g_text_1104;
string g_dbl2str_1112 = "";
string g_dbl2str_1120 = "";
color g_color_1128 = clrForestGreen;
int magico = MagicNumber_Hilo;

int macd_handle[];
int rsi_handle[];
int cci_handle[];
int stoch_handle[];
int ma_fast_handle[];
int ma_slow_handle[];
int g_rsi_h1_handle;
#define OP_BUY 0
#define OP_SELL 1
#define MODE_ASCEND 0

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAdjustedPoint()
  {
   return _Point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AdjustStopLoss(double sl, int orderType, double currentPrice)
  {
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDistance = stopsLevel * _Point;
   if(minDistance == 0)
      return sl;
   if(orderType == OP_BUY)
     {
      double minSL = currentPrice - minDistance;
      if(sl > minSL)
         sl = minSL;
     }
   else
      if(orderType == OP_SELL)
        {
         double maxSL = currentPrice + minDistance;
         if(sl < maxSL)
            sl = maxSL;
        }
   return NormalizeDouble(sl, _Digits);
  }
interface iActions
  {

   bool doAction();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionCloseAll : public iActions
  {
   string            _symbol;
   int               _magic;
   ulong             _deviation;
public:

                     ActionCloseAll(int magic = 0, string symbol = "", ulong deviation = 100)
     {
      _magic = magic;
      _symbol = (symbol == "") ? _Symbol : symbol;
      _deviation = deviation;
     }

                    ~ActionCloseAll() {}

   bool              doAction()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(posInfo.SelectByIndex(i))
           {
            if(posInfo.Symbol() == _symbol)
              {
               if(!trade.PositionClose(posInfo.Ticket(), _deviation))
                 {
                  Print(__FUNCTION__, " can't close Position: ", posInfo.Ticket(), " error: ", GetLastError());
                 }
              }
           }
        }
      return true;
     }
  };
ActionCloseAll* actionClose;
interface IOrders
  {

   virtual void Add() = 0;

   virtual void Release() = 0;

   virtual bool AddOrder() = 0;

   virtual bool DeleteOrder() = 0;

   virtual bool Select() = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
private:
   ulong             _id;
   string            _symbol;
   double            _price;
   double            _sl;
   double            _tp;
   double            _lot;
   ENUM_POSITION_TYPE _type;
   int               _magic;
   string            _comment;
   string            _strategy;
   datetime          _expireTime;
   datetime          _signalTime;
   double            _profit;
   double            _tslNext;
   bool              _bkvWasDoIt;
   int               _countPartials;
public:
                     Order(ulong id, string symbol, double price, double sl, double tp, double lot,
         ENUM_POSITION_TYPE type, int magic, string comment, string strategy,
         datetime expireTime, datetime signalTime, double profit, bool bkvWasDoIt, int countPartials)
     {
      _id = id;
      _symbol = symbol;
      _price = price;
      _sl = sl;
      _tp = tp;
      _lot = lot;
      _type = type;
      _magic = magic;
      _comment = comment;
      _strategy = strategy;
      _expireTime = expireTime;
      _signalTime = signalTime;
      _profit = profit;
      _bkvWasDoIt = bkvWasDoIt;
      _countPartials = countPartials;
      _tslNext = 0;
     }

                     Order() { _id = 0; _tslNext = 0; _bkvWasDoIt = false; _countPartials = 0; }

                    ~Order() {}

   Order*            id(ulong id) { _id = id; return &this; }

   Order*            symbol(string symbol) { _symbol = symbol; return &this; }

   Order*            price(double price) { _price = price; return &this; }

   Order*            sl(double sl) { _sl = sl; return &this; }

   Order*            tp(double tp) { _tp = tp; return &this; }

   Order*            lot(double lot) { _lot = lot; return &this; }

   Order*            type(ENUM_POSITION_TYPE type) { _type = type; return &this; }

   Order*            magic(int magic) { _magic = magic; return &this; }

   Order*            comment(string comment) { _comment = comment; return &this; }

   Order*            expireTime(datetime expireTm) { _expireTime = expireTm; return &this; }

   Order*            signalTime(datetime signalTm) { _signalTime = signalTm; return &this; }

   Order*            profit(double profit) { _profit = profit; return &this; }

   Order*            strategy(string strategy) { _strategy = strategy; return &this; }

   Order*            tslNext(double tslNext) { _tslNext = tslNext; return &this; }

   Order*            breakevenWasDoIt(bool bkvWasDoIt) { _bkvWasDoIt = bkvWasDoIt; return &this; }

   Order*            countPartials(int count) { _countPartials = _countPartials + count; return &this; }

   ulong             id() { return _id; }

   string            symbol() { return _symbol; }

   double            price() { return _price; }

   double            sl() { return _sl; }

   double            tp() { return _tp; }

   double            lot() { return _lot; }

   ENUM_POSITION_TYPE type() { return _type; }

   int               magic() { return _magic; }

   string            comment() { return _comment; }

   string            strategy() { return _strategy; }

   datetime          expireTime() { return _expireTime; }

   datetime          signalTime() { return _signalTime; }

   double            tslNext() { return _tslNext; }

   bool              breakevenWasDoIt() { return _bkvWasDoIt; }

   int               countPartials() { return _countPartials; }

   double            profit()
     {
      if(PositionSelectByTicket(_id))
        {
         return PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
        }
      return -1;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FilterBySymbols
  {
   string            _symbols[];
public:

                     FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }

                    ~FilterBySymbols() {}

   void              getSymbols(string userSymbols)
     {
      string simbolos[];
      string sep = ",";
      ushort u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userSymbols, u_sep, simbolos);
      ArrayResize(_symbols, ArraySize(simbolos), 0);
      for(int i = 0; i < ArraySize(simbolos); i++)
        {
         _symbols[i] = simbolos[i];
        }
      printSymbols();
     }

   bool              control(const string symbolToControl)
     {
      if(ArraySize(_symbols) > 0)
        {
         for(int i = 0; i < ArraySize(_symbols); i++)
           {
            if(_symbols[i] == symbolToControl)
               return true;
           }
        }
      return false;
     }

   void              printSymbols()
     {
      for(int i = 0; i < ArraySize(_symbols); i++)
        {
         Print(_symbols[i]);
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FilterByMagics
  {
   int               _magics[];
public:

                     FilterByMagics(string userMagics) { getMagics(userMagics); }

                    ~FilterByMagics() {}

   void              getMagics(string userMagics)
     {
      string magicos[];
      string sep = ",";
      ushort u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userMagics, u_sep, magicos);
      ArrayResize(_magics, ArraySize(magicos), 0);
      for(int i = 0; i < ArraySize(magicos); i++)
        {
         _magics[i] = (int)StringToInteger(magicos[i]);
        }
      if(ArraySize(_magics) > 0)
        {
         ArraySort(_magics);
        }
      printMagics();
     }

   bool              control(const int magicToControl)
     {
      if(ArraySize(_magics) > 0)
        {
         int p = ArrayBsearch(_magics, magicToControl);
         if(p >= 0 && p < ArraySize(_magics) && _magics[p] == magicToControl)
           {
            return true;
           }
        }
      return false;
     }

   void              printMagics()
     {
      for(int i = 0; i < ArraySize(_magics); i++)
        {
         Print(_magics[i]);
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrdersList
  {
   Order*            orders[];
   bool              _filterByMagicOn;
   bool              _filterBySymbolsOn;
   FilterByMagics*   _magics;
   FilterBySymbols*  _symbols;
public:

                     OrdersList() {}

                     OrdersList(bool uFilterByMagicOn, string uMagics, bool uFilterBySymbolsOn, string uSymbols)
     {
      _filterByMagicOn = uFilterByMagicOn;
      _filterBySymbolsOn = uFilterBySymbolsOn;
      _magics = new FilterByMagics(uMagics);
      _symbols = new FilterBySymbols(uSymbols);
      Print("New OrderList Created");
     }

                    ~OrdersList()
     {
      delete _magics;
      delete _symbols;
      clearList();
     }

   void              setOrdersList(bool magicOn, string magics, bool symbolsOn, string symbols)
     {
      _filterByMagicOn = magicOn;
      _filterBySymbolsOn = symbolsOn;
      _magics = new FilterByMagics(magics);
      _symbols = new FilterBySymbols(symbols);
     }

   bool              AddOrder(Order* order)
     {
      int t = ArraySize(orders);
      if(ArrayResize(orders, t + 1) > 0)
        {
         orders[t] = order;
         return true;
        }
      return false;
     }

   void              GetMarketOrders()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(posInfo.SelectByIndex(i))
           {
            if(_filterByMagicOn)
               if(!_magics.control((int)posInfo.Magic()))
                  continue;
            if(_filterBySymbolsOn)
               if(!_symbols.control(posInfo.Symbol()))
                  continue;
            if(exist(posInfo.Ticket()))
               continue;
            Order* newOrder = new Order();
            newOrder
            .id(posInfo.Ticket())
            .symbol(posInfo.Symbol())
            .price(posInfo.PriceOpen())
            .sl(posInfo.StopLoss())
            .tp(posInfo.TakeProfit())
            .lot(posInfo.Volume())
            .type(posInfo.PositionType())
            .magic((int)posInfo.Magic())
            .comment(posInfo.Comment())
            .expireTime(0)
            .profit(posInfo.Profit())
            .breakevenWasDoIt(false)
            .countPartials(0);
            if(AddOrder(newOrder))
              {
               PrintOrder(i);
              }
           }
        }
     }

   bool              exist(ulong id)
     {
      for(int i = qnt() - 1; i >= 0; i--)
        {
         if(orders[i].id() == id)
            return true;
        }
      return false;
     }

   bool              deleteOrder(int index)
     {
      if(notOverFlow(index))
        {
         delete orders[index];
        }
      if(qnt() > index)
        {
         for(int i = index; i < qnt() - 1; i++)
           {
            orders[i] = orders[i + 1];
           }
         ArrayResize(orders, qnt() - 1);
         return true;
        }
      return false;
     }

   void              clearList()
     {
      for(int i = 0; i < qnt(); i++)
        {
         if(CheckPointer(orders[i]) != POINTER_INVALID)
           {
            deleteOrder(i);
           }
        }
     }

   Order*            last()
     {
      int lastIndex = ArraySize(orders) - 1;
      if(lastIndex == -1)
         return NULL;
      return GetPointer(orders[lastIndex]);
     }

   Order*            index(int in)
     {
      return GetPointer(orders[in]);
     }

   bool              notOverFlow(int index)
     {
      if(index > ArraySize(orders) - 1)
         return false;
      if(index < 0)
         return false;
      if(CheckPointer(orders[index]) == POINTER_INVALID)
         return false;
      return true;
     }

   int               qnt()
     {
      return ArraySize(orders);
     }

   bool              isClose(int index)
     {
      if(notOverFlow(index))
        {
         if(!PositionSelectByTicket(orders[index].id()))
            return true;
        }
      return false;
     }

   void              cleanCloseOrders()
     {
      if(qnt() == 0)
         return;
      for(int i = qnt() - 1; i >= 0; i--)
        {
         if(isClose(i))
           {
            deleteOrder(i);
           }
        }
     }

   void              PrintOrder(const int index)
     {
      if(!notOverFlow(index))
         return;
      if(CheckPointer(orders[index]) == POINTER_INVALID)
         return;
      Print("Order ", index, " id: ", orders[index].id());
      Print("Order ", index, " symbol: ", orders[index].symbol());
      Print("Order ", index, " type: ", orders[index].type());
      Print("Order ", index, " lot: ", orders[index].lot());
      Print("Order ", index, " price: ", orders[index].price());
     }

   void              PrintList()
     {
      for(int i = 0; i < qnt(); i++)
        {
         PrintOrder(i);
        }
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrdersList mainOrders(filterMagicsOn, (string)MagicNumber_Hilo, filterSymbolsOn, _Symbol);
class MoveSL : public iActions
  {
   Order*            _order;
   double            _newSL;
public:

                     MoveSL() {}

                    ~MoveSL() {}

   MoveSL*           order(Order* or)
     {
      _order = or;
      return &this;
     }

   MoveSL*           newSL(double newSL)
     {
      _newSL = newSL;
      return &this;
     }

   bool              controlPointer(Order* or)
     {
      if(CheckPointer( or) != POINTER_INVALID)
        {
         return true;
        }
      else
        {
         Print("Order Pointer Invalid");
         return false;
        }
     }

   bool              doAction()
     {
      if(!controlPointer(_order))
        {
         Print(__FUNCTION__, " Can't Move Stop Loss");
         return false;
        }
      if(PositionSelectByTicket(_order.id()))
        {
         double adjustedSL = AdjustStopLoss(_newSL, (int)_order.type(),
                                            (_order.type() == POSITION_TYPE_BUY ?
                                             SymbolInfoDouble(_order.symbol(), SYMBOL_BID) :
                                             SymbolInfoDouble(_order.symbol(), SYMBOL_ASK)));
         if(trade.PositionModify(_order.id(), adjustedSL, _order.tp()))
           {
            _order.sl(adjustedSL);
            _order.breakevenWasDoIt(true);
            Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", adjustedSL);
            return true;
           }
         else
           {
            Print(__FUNCTION__, " OrderModify Error: ", GetLastError());
           }
        }
      else
        {
         Print(__FUNCTION__, " Can't Select the position ", _order.id());
        }
      return false;
     }
  };
MoveSL* breackevenAction;
interface iTSL
  {

   void setInitialStep(Order* order);

   void setNextStep(Order* order);

   double newSL(Order* order);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TslByPips : public iTSL
  {
   int               _InitialStep;
   int               _TslStep;
   double            _Distance;
public:

                     TslByPips(int InitialStep, int TslStep, double Distance)
     {
      _InitialStep = InitialStep * 10;
      _TslStep = TslStep * 10;
      _Distance = Distance * 10;
     }

                    ~TslByPips() {}

   void              setInitialStep(Order* order)
     {
      double mPoint = _Point;
      double pointsToMove = _InitialStep * mPoint;
      if(order.type() == POSITION_TYPE_SELL)
        {
         pointsToMove *= -1;
        }
      order.tslNext(order.price() + pointsToMove);
      Print(__FUNCTION__, " TSL Order: ", order.id());
      Print(__FUNCTION__, " TSL Order Price: ", order.price());
      Print(__FUNCTION__, " TSL tslNext: ", order.tslNext());
     }

   void              setNextStep(Order* order)
     {
      double mPoint = _Point;
      double pointsToMove = _TslStep * mPoint;
      if(order.type() == POSITION_TYPE_SELL)
        {
         pointsToMove *= -1;
        }
      order.tslNext(order.tslNext() + pointsToMove);
      Print(__FUNCTION__, " TSL Order: ", order.id());
      Print(__FUNCTION__, " TSL tslNext: ", order.tslNext());
     }

   double            newSL(Order* order)
     {
      double mPoint = _Point;
      double pointsToMove = _Distance * mPoint;
      if(order.type() == POSITION_TYPE_SELL)
        {
         pointsToMove *= -1;
        }
      double newSl = order.tslNext() - pointsToMove;
      Print(__FUNCTION__, " TSL Order: ", order.id());
      Print(__FUNCTION__, " TSL New SL: ", newSl);
      return newSl;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TrailingStop
  {
   OrdersList*       _orders;
   iTSL*             _TslMode;
public:

                     TrailingStop(OrdersList* uOrders, TSLMode mode)
     {
      _orders = uOrders;
      switch(mode)
        {
         case byPips:
            _TslMode = new TslByPips(userTslInitialStep, userTslStep, userTslDistance);
            break;
        }
     }

                    ~TrailingStop()
     {
      delete _TslMode;
     }

   void              doTSL()
     {
      for(int i = 0; i < _orders.qnt(); i++)
        {
         if(CheckPointer(_orders.index(i)) == POINTER_INVALID)
           {
            Print(__FUNCTION__, " Pointer invalid i= ", i);
            continue;
           }
         if(_orders.index(i).tslNext() == 0)
           {
            _TslMode.setInitialStep(_orders.index(i));
           }
         if(MatchNextTsl(_orders.index(i)))
           {
            double newSl = _TslMode.newSL(_orders.index(i));
            moveSL(_orders.index(i).id(), newSl);
            _TslMode.setNextStep(_orders.index(i));
           }
        }
     }

   bool              MatchNextTsl(Order* order)
     {
      double ask = SymbolInfoDouble(order.symbol(), SYMBOL_ASK);
      double bid = SymbolInfoDouble(order.symbol(), SYMBOL_BID);
      if(order.type() == POSITION_TYPE_BUY)
        {
         if(bid >= order.tslNext())
            return true;
        }
      if(order.type() == POSITION_TYPE_SELL)
        {
         if(ask <= order.tslNext())
            return true;
        }
      return false;
     }

   void              moveSL(ulong tk, double newSl)
     {
      if(PositionSelectByTicket(tk))
        {
         double ask = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_ASK);
         double bid = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_BID);
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         double adjustedSL = AdjustStopLoss(newSl, (int)posType, (posType == POSITION_TYPE_BUY ? bid : ask));
         if(!trade.PositionModify(tk, adjustedSL, PositionGetDouble(POSITION_TP)))
           {
            Print(__FUNCTION__, " error when make TSL in TK: ", tk, " ", GetLastError());
           }
         else
           {
            Print(__FUNCTION__, " trailing stop in tk: ", tk);
           }
        }
     }
  };
TrailingStop* tsl;
interface iConditions
  {

   bool evaluate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BreackevenCondition : public iConditions
  {
   Order*            _order;
public:

   void              setOrder(Order* or)
     {
      _order = or;
     }

   bool              evaluate()
     {
      double mPoints = _Point;
      double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
      double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
      double dist = userBkvPips * mPoints * 10;
      if(_order.type() == POSITION_TYPE_BUY)
        {
         if(bid >= _order.price() + dist)
            return true;
        }
      if(_order.type() == POSITION_TYPE_SELL)
        {
         if(ask <= _order.price() - dist)
            return true;
        }
      return false;
     }
  };
BreackevenCondition* breackevenCondition;
class ConcurrentConditions
  {
protected:
   iConditions*      _conditions[];
public:

                     ConcurrentConditions(void) {}

                    ~ConcurrentConditions(void) { releaseConditions(); }

   void              releaseConditions()
     {
      for(int i = 0; i < ArraySize(_conditions); i++)
        {
         delete _conditions[i];
        }
      ArrayFree(_conditions);
     }

   void              AddCondition(iConditions* condition)
     {
      int t = ArraySize(_conditions);
      ArrayResize(_conditions, t + 1);
      _conditions[t] = condition;
     }

   bool              EvaluateConditions(void)
     {
      for(int i = 0; i < ArraySize(_conditions); i++)
        {
         if(!_conditions[i].evaluate())
            return false;
        }
      return true;
     }
  };
ConcurrentConditions conditionsToBreackeven;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double floatingEA()
  {
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber_Hilo)
           {
            profit += posInfo.Profit() + posInfo.Swap();
           }
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double floatingPercent()
  {
   return (floatingEA() / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangePipStep()
  {
   if(floatingEA() > 0)
      return;
   double t = floor(fabs(floatingPercent() / PercentToChangePipStep));
   if(t < 1)
     {
      ld_1276 = PipStep;
      ld_1196 = PipStep;
      ld_1112 = PipStep;
      return;
     }
   ld_1276 = t * 2 * PipStep;
   ld_1196 = t * 2 * PipStep;
   ld_1112 = t * 2 * PipStep;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DebugLog(string context, string action, double price, double volume, int count, double pipstep, string extra)
  {
   int h = FileOpen("af_debug_mt5.csv", FILE_WRITE | FILE_READ | FILE_CSV | FILE_SHARE_WRITE | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      Print("Log open error: ", GetLastError());
      return;
     }
   FileSeek(h, 0, SEEK_END);
   FileWrite(h,
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             _Symbol,
             context,
             action,
             DoubleToString(price, _Digits),
             DoubleToString(volume, 2),
             count,
             DoubleToString(pipstep, 6),
             extra);
   FileClose(h);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EnsureDebugLogFile()
  {
   string dataPath = TerminalInfoString(TERMINAL_DATA_PATH);
   bool tester = (MQLInfoInteger(MQL_TESTER) == 1);
   string targetFolder = tester ? (dataPath + "\\Tester\\Files\\") : (dataPath + "\\MQL5\\Files\\");
   int h = FileOpen("af_debug_mt5.csv", FILE_WRITE | FILE_READ | FILE_CSV | FILE_SHARE_WRITE | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      Print("Log open error (init): ", GetLastError(), " path=", targetFolder, "af_debug_mt5.csv");
      return;
     }
   if(FileSize(h) == 0)
     {
      FileWrite(h, "time", "symbol", "context", "action", "price", "volume", "count", "pipstep", "extra");
      Print("Log file created: ", targetFolder, "af_debug_mt5.csv");
     }
   FileClose(h);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAllControl()
  {
   switch(closeBy)
     {
      case CloseByMoney:
         if(floatingEA() >= closeAllMoney && closeAllMoney > 0)
            return true;
         if(floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss < 0)
            return true;
         break;
      case CloseByAccountPercent:
        {
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;
         if(floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin > 0)
            return true;
         if(floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos < 0)
            return true;
         break;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(string side = "")
  {
   actionClose = new ActionCloseAll();
   actionClose.doAction();
   delete actionClose;
   Print(__FUNCTION__, "-- Closing All --");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doBreackevenAction()
  {
   for(int i = mainOrders.qnt() - 1; i >= 0; i--)
     {
      if(!mainOrders.index(i).breakevenWasDoIt())
        {
         breackevenCondition.setOrder(mainOrders.index(i));
         if(conditionsToBreackeven.EvaluateConditions())
           {
            breackevenAction = new MoveSL();
            double buySl = mainOrders.index(i).price() + userBkvStep * 10 * _Point;
            double sellSl = mainOrders.index(i).price() - userBkvStep * 10 * _Point;
            double newSl = mainOrders.index(i).type() == POSITION_TYPE_BUY ? buySl : sellSl;
            breackevenAction.order(mainOrders.index(i)).newSL(newSl);
            breackevenAction.doAction();
            delete breackevenAction;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_15()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_15()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      ulong ticket = posInfo.Ticket();
      if(posInfo.PositionType() == POSITION_TYPE_BUY)
         trade.PositionClose(ticket, g_slippage_432);
      else
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
            trade.PositionClose(ticket, g_slippage_432);
      Sleep(1000);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder_15(int type, double lots, double price, int slippage, double unused, int stopLoss, int takeProfit, string comment, int magic, ulong datetimeExp, color clr)
  {
   int ticket = 0;
   int error = 0;
   int count = 0;
   int maxTries = 100;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   trade.SetDeviationInPoints((ulong)slippage);
   trade.SetExpertMagicNumber(magic);
   if(type == 0)
     {
      for(count = 0; count < maxTries; count++)
        {
         ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = StopLong_15(bid, stopLoss);
         double tp = TakeLong_15(ask, takeProfit);
         if(trade.Buy(lots, _Symbol, ask, sl, tp, comment))
           {
            ticket = (int)trade.ResultOrder();
            break;
           }
         error = GetLastError();
         if(error == 0)
            break;
         if(!(error == 4 || error == 10021 || error == 10018 || error == 10020))
            break;
         Sleep(5000);
        }
     }
   else
      if(type == 1)
        {
         for(count = 0; count < maxTries; count++)
           {
            ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double sl = StopShort_15(ask, stopLoss);
            double tp = TakeShort_15(bid, takeProfit);
            if(trade.Sell(lots, _Symbol, bid, sl, tp, comment))
              {
               ticket = (int)trade.ResultOrder();
               break;
              }
            error = GetLastError();
            if(error == 0)
               break;
            if(!(error == 4 || error == 10021 || error == 10018 || error == 10020))
               break;
            Sleep(5000);
           }
        }
   return ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_15(double price, int points)
  {
   if(points == 0)
      return 0;
   return price - points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_15(double price, int points)
  {
   if(points == 0)
      return 0;
   return price + points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_15(double price, int points)
  {
   if(points == 0)
      return 0;
   return price + points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_15(double price, int points)
  {
   if(points == 0)
      return 0;
   return price - points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_15()
  {
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
         profit += posInfo.Profit();
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_15(int start, int stop, double entryPrice)
  {
   if(stop == 0)
      return;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      ulong ticket = posInfo.Ticket();
      double sl = posInfo.StopLoss();
      double tp = posInfo.TakeProfit();
      if(posInfo.PositionType() == POSITION_TYPE_BUY)
        {
         int pips = (int)NormalizeDouble((bid - entryPrice) / Point(), 0);
         if(pips < start)
            continue;
         double newSL = bid - stop * Point();
         newSL = AdjustStopLoss(newSL, ORDER_TYPE_BUY, bid);
         if((sl == 0 || (sl != 0 && newSL > sl)) && MathAbs(newSL - sl) > Point())
           {
            if(!trade.PositionModify(ticket, newSL, tp))
               Print("TrailingAlls_15 BUY PositionModify Error: ", GetLastError());
           }
        }
      else
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            int pips = (int)NormalizeDouble((entryPrice - ask) / Point(), 0);
            if(pips < start)
               continue;
            double newSL = ask + stop * Point();
            newSL = AdjustStopLoss(newSL, ORDER_TYPE_SELL, ask);
            if((sl == 0 || (sl != 0 && newSL < sl)) && MathAbs(newSL - sl) > Point())
              {
               if(!trade.PositionModify(ticket, newSL, tp))
                  Print("TrailingAlls_15 SELL PositionModify Error: ", GetLastError());
              }
           }
      Sleep(1000);
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
   return gd_592;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_15()
  {
   double openPrice = 0;
   int lastTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      if(posInfo.PositionType() != POSITION_TYPE_BUY)
         continue;
      int ticket = (int)posInfo.Ticket();
      if(ticket > lastTicket)
        {
         openPrice = posInfo.PriceOpen();
         lastTicket = ticket;
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_15()
  {
   double openPrice = 0;
   int lastTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      if(posInfo.PositionType() != POSITION_TYPE_SELL)
         continue;
      int ticket = (int)posInfo.Ticket();
      if(ticket > lastTicket)
        {
         openPrice = posInfo.PriceOpen();
         lastTicket = ticket;
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_16()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_16()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      ulong ticket = posInfo.Ticket();
      if(posInfo.PositionType() == POSITION_TYPE_BUY)
         trade.PositionClose(ticket, g_slippage_648);
      else
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
            trade.PositionClose(ticket, g_slippage_648);
      Sleep(1000);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder_16(int type, double lots, double price, int slippage, double unused, int stopLoss, int takeProfit, string comment, int magic, ulong datetimeExp, color clr)
  {
   int ticket = 0;
   int error = 0;
   int count = 0;
   int maxTries = 100;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   trade.SetDeviationInPoints((ulong)slippage);
   trade.SetExpertMagicNumber(magic);
   if(type == 0)
     {
      for(count = 0; count < maxTries; count++)
        {
         ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = StopLong_16(bid, stopLoss);
         double tp = TakeLong_16(ask, takeProfit);
         if(trade.Buy(lots, _Symbol, ask, sl, tp, comment))
           {
            ticket = (int)trade.ResultOrder();
            break;
           }
         error = GetLastError();
         if(error == 0)
            break;
         if(!(error == 4 || error == 10021 || error == 10018 || error == 10020))
            break;
         Sleep(5000);
        }
     }
   else
      if(type == 1)
        {
         for(count = 0; count < maxTries; count++)
           {
            ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double sl = StopShort_16(ask, stopLoss);
            double tp = TakeShort_16(bid, takeProfit);
            if(trade.Sell(lots, _Symbol, bid, sl, tp, comment))
              {
               ticket = (int)trade.ResultOrder();
               break;
              }
            error = GetLastError();
            if(error == 0)
               break;
            if(!(error == 4 || error == 10021 || error == 10018 || error == 10020))
               break;
            Sleep(5000);
           }
        }
   return ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_16(double price, int points)
  {
   if(points == 0)
      return 0;
   return price - points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_16(double price, int points)
  {
   if(points == 0)
      return 0;
   return price + points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_16(double price, int points)
  {
   if(points == 0)
      return 0;
   return price + points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_16(double price, int points)
  {
   if(points == 0)
      return 0;
   return price - points * Point();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_16()
  {
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
         profit += posInfo.Profit();
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_16(int start, int stop, double entryPrice)
  {
   if(stop == 0)
      return;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      ulong ticket = posInfo.Ticket();
      double sl = posInfo.StopLoss();
      double tp = posInfo.TakeProfit();
      if(posInfo.PositionType() == POSITION_TYPE_BUY)
        {
         int pips = (int)NormalizeDouble((bid - entryPrice) / Point(), 0);
         if(pips < start)
            continue;
         double newSL = bid - stop * Point();
         newSL = AdjustStopLoss(newSL, ORDER_TYPE_BUY, bid);
         if((sl == 0 || (sl != 0 && newSL > sl)) && MathAbs(newSL - sl) > Point())
           {
            if(!trade.PositionModify(ticket, newSL, tp))
               Print("TrailingAlls_16 BUY PositionModify Error: ", GetLastError());
           }
        }
      else
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            int pips = (int)NormalizeDouble((entryPrice - ask) / Point(), 0);
            if(pips < start)
               continue;
            double newSL = ask + stop * Point();
            newSL = AdjustStopLoss(newSL, ORDER_TYPE_SELL, ask);
            if((sl == 0 || (sl != 0 && newSL < sl)) && MathAbs(newSL - sl) > Point())
              {
               if(!trade.PositionModify(ticket, newSL, tp))
                  Print("TrailingAlls_16 SELL PositionModify Error: ", GetLastError());
              }
           }
      Sleep(1000);
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
   return gd_808;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_16()
  {
   double openPrice = 0;
   int lastTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      if(posInfo.PositionType() != POSITION_TYPE_BUY)
         continue;
      int ticket = (int)posInfo.Ticket();
      if(ticket > lastTicket)
        {
         openPrice = posInfo.PriceOpen();
         lastTicket = ticket;
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_16()
  {
   double openPrice = 0;
   int lastTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      if(posInfo.PositionType() != POSITION_TYPE_SELL)
         continue;
      int ticket = (int)posInfo.Ticket();
      if(ticket > lastTicket)
        {
         openPrice = posInfo.PriceOpen();
         lastTicket = ticket;
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_Hilo()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         count++;
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_Hilo()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() == _Symbol && posInfo.Magic() == MagicNumber_Hilo)
           {
            trade.PositionClose(posInfo.Ticket());
            Sleep(1000);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong_Hilo(double price, double points)
  {
   if(points == 0)
      return 0;
   return price - points * _Point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort_Hilo(double price, double points)
  {
   if(points == 0)
      return 0;
   return price + points * _Point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong_Hilo(double price, double points)
  {
   if(points == 0)
      return 0;
   return price + points * _Point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort_Hilo(double price, double points)
  {
   if(points == 0)
      return 0;
   return price - points * _Point;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenPendingOrder_Hilo(int type, double lots, double price, double slippage,
                            double bid_ask, double sl_points, double tp_points,
                            string comment, int magic, datetime expiration, color clr)
  {
   ulong ticket = 0;
   int error = 0;
   int retries = 0;
   int max_retries = 100;
   trade.SetDeviationInPoints((ulong)slippage);
   trade.SetExpertMagicNumber(magic);
   for(retries = 0; retries < max_retries; retries++)
     {
      if(type == OP_BUY)
        {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = StopLong_Hilo(ask, sl_points);
         double tp = TakeLong_Hilo(ask, tp_points);
         if(trade.Buy(lots, _Symbol, ask, sl, tp, comment))
           {
            ticket = trade.ResultOrder();
            break;
           }
         error = GetLastError();
        }
      else
         if(type == OP_SELL)
           {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double sl = StopShort_Hilo(bid, sl_points);
            double tp = TakeShort_Hilo(bid, tp_points);
            if(trade.Sell(lots, _Symbol, bid, sl, tp, comment))
              {
               ticket = trade.ResultOrder();
               break;
              }
            error = GetLastError();
           }
      if(!(error == 4 || error == 137 || error == 146 || error == 136))
         break;
      Sleep(5000);
     }
   return ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_Hilo()
  {
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         profit += posInfo.Profit() + posInfo.Swap();
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_Hilo(double trailStart, double trailStop, double openPrice)
  {
   if(trailStop == 0)
      return;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            double points = NormalizeDouble((bid - openPrice) / _Point, 0);
            if(points < trailStart)
               continue;
            double currentSL = posInfo.StopLoss();
            double newSL = bid - trailStop * _Point;
            newSL = AdjustStopLoss(newSL, OP_BUY, bid);
            if((currentSL == 0.0 || (currentSL != 0.0 && newSL > currentSL)) &&
               MathAbs(newSL - currentSL) > _Point)
              {
               trade.PositionModify(posInfo.Ticket(), newSL, posInfo.TakeProfit());
              }
           }
         else
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               double points = NormalizeDouble((openPrice - ask) / _Point, 0);
               if(points < trailStart)
                  continue;
               double currentSL = posInfo.StopLoss();
               double newSL = ask + trailStop * _Point;
               newSL = AdjustStopLoss(newSL, OP_SELL, ask);
               if((currentSL == 0.0 || (currentSL != 0.0 && newSL < currentSL)) &&
                  MathAbs(newSL - currentSL) > _Point)
                 {
                  trade.PositionModify(posInfo.Ticket(), newSL, posInfo.TakeProfit());
                 }
              }
         Sleep(1000);
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
   return gd_380;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_Hilo()
  {
   double openPrice = 0;
   ulong maxTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            ulong ticket = posInfo.Ticket();
            if(ticket > maxTicket)
              {
               openPrice = posInfo.PriceOpen();
               maxTicket = ticket;
              }
           }
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_Hilo()
  {
   double openPrice = 0;
   ulong maxTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(posInfo.SelectByIndex(i))
        {
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            ulong ticket = posInfo.Ticket();
            if(ticket > maxTicket)
              {
               openPrice = posInfo.PriceOpen();
               maxTicket = ticket;
              }
           }
        }
     }
   return openPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(MQLInfoInteger(MQL_TESTER) == 1)
     {
      FileDelete("af_debug_mt5.csv");
     }
   Print("Terminal data path: ", TerminalInfoString(TERMINAL_DATA_PATH));
   EnsureDebugLogFile();
   tsl = new TrailingStop(GetPointer(mainOrders), byPips);
   conditionsToBreackeven.AddCondition(breackevenCondition = new BreackevenCondition());
   gd_304 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_516 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_732 = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   ArrayResize(macd_handle, 7);
   ArrayResize(rsi_handle, 7);
   ArrayResize(cci_handle, 7);
   ArrayResize(stoch_handle, 7);
   ArrayResize(ma_fast_handle, 7);
   ArrayResize(ma_slow_handle, 7);
   ENUM_TIMEFRAMES timeframes[] = {g_timeframe_828, g_timeframe_832, g_timeframe_836,
                                   g_timeframe_840, g_timeframe_844, g_timeframe_848, g_timeframe_852
                                  };
   for(int i = 0; i < 7; i++)
     {
      macd_handle[i] = iMACD(_Symbol, timeframes[i], g_period_932, g_period_936, g_period_940, g_applied_price_944);
      rsi_handle[i] = iRSI(_Symbol, timeframes[i], g_period_980, g_applied_price_984);
      cci_handle[i] = iCCI(_Symbol, timeframes[i], g_period_996, g_applied_price_1000);
      stoch_handle[i] = iStochastic(_Symbol, timeframes[i], g_period_1012, g_period_1016, g_slowing_1020, g_ma_method_1024, STO_LOWHIGH);
      ma_fast_handle[i] = iMA(_Symbol, timeframes[i], g_period_1056, 0, g_ma_method_1064, g_applied_price_1068);
      ma_slow_handle[i] = iMA(_Symbol, timeframes[i], g_period_1060, 0, g_ma_method_1064, g_applied_price_1068);
     }
   g_rsi_h1_handle = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
   ObjectCreate(0, "Lable1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable1", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSetInteger(0, "Lable1", OBJPROP_YDISTANCE, 21);
   ObjectSetString(0, "Lable1", OBJPROP_TEXT, "AFSID GROUP");
   ObjectSetString(0, "Lable1", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable1", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "Lable1", OBJPROP_COLOR, clrAqua);
   ObjectCreate(0, "Lable", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "Lable", OBJPROP_XDISTANCE, 3);
   ObjectSetInteger(0, "Lable", OBJPROP_YDISTANCE, 1);
   ObjectSetString(0, "Lable", OBJPROP_TEXT, "https://afs-id.com");
   ObjectSetString(0, "Lable", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable", OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, "Lable", OBJPROP_COLOR, clrDeepSkyBlue);
   UpdateIndicatorPanel();
   Print("AF_Global_Expert_Full_v4 initialized successfully");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete tsl;
   for(int i = 0; i < ArraySize(macd_handle); i++)
     {
      IndicatorRelease(macd_handle[i]);
      IndicatorRelease(rsi_handle[i]);
      IndicatorRelease(cci_handle[i]);
      IndicatorRelease(stoch_handle[i]);
      IndicatorRelease(ma_fast_handle[i]);
      IndicatorRelease(ma_slow_handle[i]);
     }
   IndicatorRelease(g_rsi_h1_handle);
   ObjectDelete(0, "cja");
   ObjectDelete(0, "Signalprice");
   ObjectDelete(0, "SIG_BARS_TF1");
   ObjectDelete(0, "SIG_BARS_TF2");
   ObjectDelete(0, "SIG_BARS_TF3");
   ObjectDelete(0, "SIG_BARS_TF4");
   ObjectDelete(0, "SIG_BARS_TF5");
   ObjectDelete(0, "SIG_BARS_TF6");
   ObjectDelete(0, "SIG_BARS_TF7");
   ObjectDelete(0, "SSignalMACD_TEXT");
   ObjectDelete(0, "SSignalMACDM1");
   ObjectDelete(0, "SSignalMACDM5");
   ObjectDelete(0, "SSignalMACDM15");
   ObjectDelete(0, "SSignalMACDM30");
   ObjectDelete(0, "SSignalMACDH1");
   ObjectDelete(0, "SSignalMACDH4");
   ObjectDelete(0, "SSignalMACDD1");
   ObjectDelete(0, "SSignalSTR_TEXT");
   ObjectDelete(0, "SignalSTRM1");
   ObjectDelete(0, "SignalSTRM5");
   ObjectDelete(0, "SignalSTRM15");
   ObjectDelete(0, "SignalSTRM30");
   ObjectDelete(0, "SignalSTRH1");
   ObjectDelete(0, "SignalSTRH4");
   ObjectDelete(0, "SignalSTRD1");
   ObjectDelete(0, "SignalEMA_TEXT");
   ObjectDelete(0, "SignalEMAM1");
   ObjectDelete(0, "SignalEMAM5");
   ObjectDelete(0, "SignalEMAM15");
   ObjectDelete(0, "SignalEMAM30");
   ObjectDelete(0, "SignalEMAH1");
   ObjectDelete(0, "SignalEMAH4");
   ObjectDelete(0, "SignalEMAD1");
   ObjectDelete(0, "Lable");
   ObjectDelete(0, "Lable1");
   ObjectDelete(0, "Lable2");
   ObjectDelete(0, "Lable3");
   Comment("https://afs-id.com");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   mainOrders.cleanCloseOrders();
   mainOrders.GetMarketOrders();
   if(breakevenOn)
      doBreackevenAction();
   if(TslON)
      tsl.doTSL();
   if(floatingEA() < 0)
     {
      ChangePipStep();
      Print("floating: $ ", floatingEA(), " percent: ", floatingPercent(), " %  Current PipStep:", ld_1276);
     }
   if(closeAllControlON)
     {
      if(CloseAllControl())
         CloseAll();
     }
   Comment("AFSID GROUP\n" +
           "https://afs-id.com\n" +
           "___________________________________________________\n" +
           "Broker: " + AccountInfoString(ACCOUNT_COMPANY) + "\n" +
           "Time: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n" +
           "___________________________________________________\n" +
           "Name: " + AccountInfoString(ACCOUNT_NAME) + "\n" +
           "Account Number: " + (string)AccountInfoInteger(ACCOUNT_LOGIN) + "\n" +
           "Account Currency: " + AccountInfoString(ACCOUNT_CURRENCY) + "\n" +
           "____________________________________________________\n" +
           "Open Orders FiboScalper: " + (string)CountTrades_Hilo() + "\n" +
           "ALL ORDERS: " + (string)PositionsTotal() + "\n" +
           "_____________________________________________________\n" +
           "Account BALANCE: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n" +
           "Account EQUITY: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n" +
           "AFSID GROUP");
   gd_248 = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   gd_256 = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   if(gd_256 >= 5.0 * (gd_248 / 6.0))
      g_color_1128 = clrDodgerBlue;
   else
      if(gd_256 >= 4.0 * (gd_248 / 6.0))
         g_color_1128 = clrDeepSkyBlue;
      else
         if(gd_256 >= 3.0 * (gd_248 / 6.0))
            g_color_1128 = clrGold;
         else
            if(gd_256 >= 2.0 * (gd_248 / 6.0))
               g_color_1128 = clrOrangeRed;
            else
               if(gd_256 >= gd_248 / 6.0)
                  g_color_1128 = clrCrimson;
               else
                  g_color_1128 = clrRed;
   ObjectDelete(0, "Lable2");
   ObjectCreate(0, "Lable2", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable2", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "Lable2", OBJPROP_XDISTANCE, 153);
   ObjectSetInteger(0, "Lable2", OBJPROP_YDISTANCE, 31);
   g_dbl2str_1112 = DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   ObjectSetString(0, "Lable2", OBJPROP_TEXT, "Account BALANCE:  " + g_dbl2str_1112);
   ObjectSetString(0, "Lable2", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable2", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "Lable2", OBJPROP_COLOR, clrDodgerBlue);
   ObjectDelete(0, "Lable3");
   ObjectCreate(0, "Lable3", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable3", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "Lable3", OBJPROP_XDISTANCE, 153);
   ObjectSetInteger(0, "Lable3", OBJPROP_YDISTANCE, 11);
   g_dbl2str_1120 = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   ObjectSetString(0, "Lable3", OBJPROP_TEXT, "Account EQUITY:  " + g_dbl2str_1120);
   ObjectSetString(0, "Lable3", OBJPROP_FONT, "Times New Roman");
   ObjectSetInteger(0, "Lable3", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "Lable3", OBJPROP_COLOR, g_color_1128);
   UpdateIndicatorPanel();
   double ld_1060 = LotExponent;
   int li_1068 = lotdecimal;
   double ld_1072 = TakeProfit;
   bool bool_1080 = UseEquityStop;
   double ld_1084 = TotalEquityRisk;
   ld_1112 = PipStep;
   double ld_144;
   if(MM == true)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_144 = Lots;
      else
         ld_144 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   else
      ld_144 = Lots;
   static datetime last_bar_time = 0;
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(gi_324 != current_bar)
     {
      gi_324 = current_bar;
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
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(posInfo.SelectByIndex(i))
           {
            if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
               continue;
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
              {
               gi_364 = true;
               gi_368 = false;
               break;
              }
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
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
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(gi_368 && bid - gd_296 >= ld_1112 * _Point)
           {
            gi_360 = true;
           }
         else
            if(gi_364 && gd_288 - ask >= ld_1112 * _Point)
              {
               gi_360 = true;
              }
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
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(gi_368)
           {
            gi_332 = gi_348;
            gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
            gi_372 = (int)OpenPendingOrder_Hilo(OP_SELL, gd_336, bid, slip, ask, 0, 0, gs_316 + "-" + (string)gi_332, MagicNumber_Hilo, 0, clrHotPink);
            if(gi_372 > 0)
              {
               gd_296 = FindLastSellPrice_Hilo();
               gi_376 = true;
               DebugLog("Hilo", "OPEN_SELL_GRID", bid, gd_336, gi_348, ld_1112, "ticket=" + (string)gi_372);
              }
            else
              {
               Print("Error Hilo SELL grid: ", GetLastError());
              }
            gi_360 = false;
           }
         else
            if(gi_364)
              {
               gi_332 = gi_348;
               gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
               gi_372 = (int)OpenPendingOrder_Hilo(OP_BUY, gd_336, ask, slip, bid, 0, 0, gs_316 + "-" + (string)gi_332, MagicNumber_Hilo, 0, clrLime);
               if(gi_372 > 0)
                 {
                  gd_288 = FindLastBuyPrice_Hilo();
                  gi_376 = true;
                  DebugLog("Hilo", "OPEN_BUY_GRID", ask, gd_336, gi_348, ld_1112, "ticket=" + (string)gi_372);
                 }
               else
                 {
                  Print("Error Hilo BUY grid: ", GetLastError());
                 }
               gi_360 = false;
              }
            else
               if(gi_348 < 1)
                 {
                  double high[], low[];
                  ArraySetAsSeries(high, true);
                  ArraySetAsSeries(low, true);
                  CopyHigh(_Symbol, PERIOD_CURRENT, 0, 3, high);
                  CopyLow(_Symbol, PERIOD_CURRENT, 0, 3, low);
                  double ihigh_112 = high[1];
                  double ilow_120 = low[2];
                  if(!gi_368 && !gi_364)
                    {
                     gi_332 = gi_348;
                     gd_336 = NormalizeDouble(ld_144 * MathPow(ld_1060, gi_332), li_1068);
                     double rsi_val[];
                     ArraySetAsSeries(rsi_val, true);
                     CopyBuffer(rsi_handle[4], 0, 0, 2, rsi_val);
                     if(ihigh_112 > ilow_120)
                       {
                        if(rsi_val[1] > 30.0)
                          {
                           gi_372 = (int)OpenPendingOrder_Hilo(OP_SELL, gd_336, bid, slip, bid, 0, 0, gs_316 + "-" + (string)gi_332, MagicNumber_Hilo, 0, clrHotPink);
                           if(gi_372 > 0)
                             {
                              gd_288 = FindLastBuyPrice_Hilo();
                              gi_376 = true;
                              DebugLog("Hilo", "OPEN_SELL_INIT", bid, gd_336, gi_348, ld_1112, "ticket=" + (string)gi_372);
                             }
                          }
                       }
                     else
                       {
                        if(rsi_val[1] < 70.0)
                          {
                           gi_372 = (int)OpenPendingOrder_Hilo(OP_BUY, gd_336, ask, slip, ask, 0, 0, gs_316 + "-" + (string)gi_332, MagicNumber_Hilo, 0, clrLime);
                           if(gi_372 > 0)
                             {
                              gd_296 = FindLastSellPrice_Hilo();
                              gi_376 = true;
                              DebugLog("Hilo", "OPEN_BUY_INIT", ask, gd_336, gi_348, ld_1112, "ticket=" + (string)gi_372);
                             }
                          }
                       }
                     if(gi_372 > 0)
                        gi_328 = TimeCurrent() + (datetime)(60.0 * 60.0 * gd_188);
                    }
                  gi_360 = false;
                 }
        }
     }
   gi_348 = CountTrades_Hilo();
   g_price_264 = 0;
   double ld_1136 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
         continue;
      g_price_264 += posInfo.PriceOpen() * posInfo.Volume();
      ld_1136 += posInfo.Volume();
     }
   if(gi_348 > 0)
      g_price_264 = NormalizeDouble(g_price_264 / ld_1136, _Digits);
   if(gi_376)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!posInfo.SelectByIndex(i))
            continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
            continue;
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            g_price_216 = g_price_264 + ld_1072 * _Point;
            gd_unused_232 = g_price_216;
            gd_352 = g_price_264 - g_pips_196 * _Point;
            gi_312 = true;
           }
         else
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               g_price_216 = g_price_264 - ld_1072 * _Point;
               gd_unused_240 = g_price_216;
               gd_352 = g_price_264 + g_pips_196 * _Point;
               gi_312 = true;
              }
        }
     }
   if(gi_376)
     {
      if(gi_312 == true)
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            if(!posInfo.SelectByIndex(i))
               continue;
            if(posInfo.Symbol() != _Symbol || posInfo.Magic() != MagicNumber_Hilo)
               continue;
            ulong ticket = posInfo.Ticket();
            double adjustedTP = g_price_216;
            double minStopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
            if(minStopLevel == 0)
               minStopLevel = 2 * _Point;
            double minAllowedTP = 0;
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
              {
               double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               minAllowedTP = bid + minStopLevel;
               if(adjustedTP < minAllowedTP)
                  adjustedTP = minAllowedTP;
              }
            else
               if(posInfo.PositionType() == POSITION_TYPE_SELL)
                 {
                  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                  minAllowedTP = ask - minStopLevel;
                  if(adjustedTP > minAllowedTP)
                     adjustedTP = minAllowedTP;
                 }
            adjustedTP = NormalizeDouble(adjustedTP, _Digits);
            if(!trade.PositionModify(ticket, posInfo.StopLoss(), adjustedTP))
               Print("OrderModify Error Hilo: ", GetLastError(), " for ticket ", ticket);
           }
         gi_376 = false;
        }
     }
   double ld_1144 = LotExponent;
   int li_1152 = lotdecimal;
   double ld_1156 = TakeProfit;
   bool bool_1164 = UseEquityStop;
   double ld_1168 = TotalEquityRisk;
   bool bool_1176 = UseTrailingStop;
   double ld_1180 = TrailStart;
   double ld_1188 = TrailStop;
   double ld_1196_local = ld_1196;
   double ld_1204 = slip;
   double ld_152 = Lots;
   if(MM)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_152 = Lots;
      else
         ld_152 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   if(bool_1176)
      TrailingAlls_15((int)ld_1180, (int)ld_1188, g_price_476);
   if(gi_420)
     {
      if(TimeCurrent() >= gi_540)
        {
         CloseThisSymbolAll_15();
         Print("Closed All _15 due to TimeOut");
        }
     }
   datetime time_15[];
   ArraySetAsSeries(time_15, true);
   if(CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, time_15) > 0)
     {
      if(gi_536 != (int)time_15[0])
        {
         gi_536 = (int)time_15[0];
         double ld_160 = CalculateProfit_15();
         if(bool_1164)
           {
            if(ld_160 < 0.0 && MathAbs(ld_160) > ld_1168 / 100.0 * AccountEquityHigh_15())
              {
               CloseThisSymbolAll_15();
               Print("Closed All _15 due to Stop Out");
               gi_588 = false;
              }
           }
         gi_560 = CountTrades_15();
         if(gi_560 == 0)
            gi_524 = false;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            if(!posInfo.SelectByIndex(i))
               continue;
            if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
               continue;
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
              {
               gi_576 = true;
               gi_580 = false;
               break;
              }
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               gi_576 = false;
               gi_580 = true;
               break;
              }
           }
         if(gi_560 > 0 && gi_560 <= MaxTrades_15)
           {
            double ask_15 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid_15 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            gd_500 = FindLastBuyPrice_15();
            gd_508 = FindLastSellPrice_15();
            if(gi_576 && gd_500 - ask_15 >= ld_1196_local * Point())
              {
               gi_572 = true;
              }
            else
               if(gi_580 && bid_15 - gd_508 >= ld_1196_local * Point())
                 {
                  gi_572 = true;
                 }
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
            double ask_15 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid_15 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double close_init_15[];
            ArraySetAsSeries(close_init_15, true);
            if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 3, close_init_15) < 3)
              {
               Print("Error _15 CopyClose initial: ", GetLastError());
               gi_572 = false;
              }
            double iclose_128 = close_init_15[2];
            double iclose_136 = close_init_15[1];
            if(gi_580)
              {
               gi_544 = gi_560;
               gd_548 = NormalizeDouble(ld_152 * MathPow(ld_1144, gi_544), li_1152);
               gi_584 = OpenPendingOrder_15(1, gd_548, bid_15, (int)ld_1204, ask_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrHotPink);
               if(gi_584 > 0)
                 {
                  gd_508 = FindLastSellPrice_15();
                  gi_588 = true;
                  DebugLog("AF15", "OPEN_SELL_GRID", bid_15, gd_548, gi_560, ld_1196_local, "ticket=" + (string)gi_584);
                 }
               else
                 {
                  Print("Error _15 SELL grid: ", GetLastError());
                 }
               gi_572 = false;
              }
            else
               if(gi_576)
                 {
                  gi_544 = gi_560;
                  gd_548 = NormalizeDouble(ld_152 * MathPow(ld_1144, gi_544), li_1152);
                  gi_584 = OpenPendingOrder_15(0, gd_548, ask_15, (int)ld_1204, bid_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrLime);
                  if(gi_584 > 0)
                    {
                     gd_500 = FindLastBuyPrice_15();
                     gi_588 = true;
                     DebugLog("AF15", "OPEN_BUY_GRID", ask_15, gd_548, gi_560, ld_1196_local, "ticket=" + (string)gi_584);
                    }
                  else
                    {
                     Print("Error _15 BUY grid: ", GetLastError());
                    }
                  gi_572 = false;
                 }
               else
                  if(gi_560 < 1 && !gi_576 && !gi_580)
                    {
                     gi_544 = gi_560;
                     gd_548 = NormalizeDouble(ld_152 * MathPow(ld_1144, gi_544), li_1152);
                     if(iclose_128 > iclose_136)
                       {
                        gi_584 = OpenPendingOrder_15(1, gd_548, bid_15, (int)ld_1204, bid_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrHotPink);
                        if(gi_584 > 0)
                          {
                           gd_500 = FindLastBuyPrice_15();
                           gi_588 = true;
                          }
                       }
                     else
                       {
                        gi_584 = OpenPendingOrder_15(0, gd_548, ask_15, (int)ld_1204, ask_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrLime);
                        if(gi_584 > 0)
                          {
                           gd_508 = FindLastSellPrice_15();
                           gi_588 = true;
                          }
                       }
                     gi_572 = false;
                    }
           }
        }
     }
   double close_15[];
   ArraySetAsSeries(close_15, true);
   datetime time_check_15[];
   ArraySetAsSeries(time_check_15, true);
   if(CopyTime(_Symbol, (ENUM_TIMEFRAMES)g_timeframe_408, 0, 1, time_check_15) > 0 &&
      CopyClose(_Symbol, PERIOD_CURRENT, 0, 3, close_15) >= 3)
     {
      if(g_datetime_608 != time_check_15[0])
        {
         int li_168 = PositionsTotal();
         int count_172 = 0;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            if(!posInfo.SelectByIndex(i))
               continue;
            if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
               continue;
            count_172++;
           }
         if(li_168 == 0 || count_172 < 1)
           {
            double iclose_128 = close_15[2];
            double iclose_136 = close_15[1];
            double ask_15 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid_15 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            gi_544 = gi_560;
            gd_548 = ld_152;
            if(iclose_128 > iclose_136)
              {
               gi_584 = OpenPendingOrder_15(1, gd_548, bid_15, (int)ld_1204, bid_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrHotPink);
               if(gi_584 > 0)
                 {
                  gd_500 = FindLastBuyPrice_15();
                  gi_588 = true;
                  DebugLog("AF15", "OPEN_SELL_INIT", bid_15, gd_548, gi_560, ld_1196_local, "ticket=" + (string)gi_584);
                 }
              }
            else
              {
               gi_584 = OpenPendingOrder_15(0, gd_548, ask_15, (int)ld_1204, ask_15, 0, 0, gs_528 + "-" + (string)gi_544, g_magic_176_15, 0, clrLime);
               if(gi_584 > 0)
                 {
                  gd_508 = FindLastSellPrice_15();
                  gi_588 = true;
                  DebugLog("AF15", "OPEN_BUY_INIT", ask_15, gd_548, gi_560, ld_1196_local, "ticket=" + (string)gi_584);
                 }
              }
            if(gi_584 > 0)
               gi_540 = (int)(TimeCurrent() + 60.0 * 60.0 * gd_424);
            gi_572 = false;
           }
         g_datetime_608 = time_check_15[0];
        }
     }
   gi_560 = CountTrades_15();
   g_price_476 = 0;
   double ld_1216 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
        {
         g_price_476 += posInfo.PriceOpen() * posInfo.Volume();
         ld_1216 += posInfo.Volume();
        }
     }
   if(gi_560 > 0)
      g_price_476 = NormalizeDouble(g_price_476 / ld_1216, _Digits);
   if(gi_588)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!posInfo.SelectByIndex(i))
            continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
            continue;
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            g_price_444 = g_price_476 + ld_1156 * Point();
            gd_564 = g_price_476 - g_pips_412 * Point();
            gi_524 = true;
           }
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            g_price_444 = g_price_476 - ld_1156 * Point();
            gd_564 = g_price_476 + g_pips_412 * Point();
            gi_524 = true;
           }
        }
     }
   if(gi_588 && gi_524)
     {
      double ask_15_tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid_15_tp = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!posInfo.SelectByIndex(i))
            continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_15)
            continue;
         ulong ticket = posInfo.Ticket();
         double adjustedTP_15 = g_price_444;
         double minStopLevel_15 = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * Point();
         if(minStopLevel_15 == 0)
            minStopLevel_15 = 2 * Point();
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            double minAllowedTP_15 = bid_15_tp + minStopLevel_15;
            if(adjustedTP_15 < minAllowedTP_15)
               adjustedTP_15 = minAllowedTP_15;
           }
         else
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               double minAllowedTP_15 = ask_15_tp - minStopLevel_15;
               if(adjustedTP_15 > minAllowedTP_15)
                  adjustedTP_15 = minAllowedTP_15;
              }
         adjustedTP_15 = NormalizeDouble(adjustedTP_15, _Digits);
         if(!trade.PositionModify(ticket, posInfo.StopLoss(), adjustedTP_15))
            Print("OrderModify Error _15: ", GetLastError(), " for ticket ", ticket);
        }
      gi_588 = false;
     }
   double ld_1224 = LotExponent;
   int li_1232 = lotdecimal;
   double ld_1236 = TakeProfit;
   bool bool_1244 = UseEquityStop;
   double ld_1248 = TotalEquityRisk;
   bool bool_1256 = UseTrailingStop;
   double ld_1260 = TrailStart;
   double ld_1268 = TrailStop;
   double ld_1276_local = ld_1276;
   double ld_1284 = slip;
   double ld_176 = Lots;
   if(MM)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000.0)
         ld_176 = Lots;
      else
         ld_176 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
     }
   if(bool_1256)
      TrailingAlls_16((int)ld_1260, (int)ld_1268, g_price_692);
   if(gi_636)
     {
      if(TimeCurrent() >= gi_756)
        {
         CloseThisSymbolAll_16();
         Print("Closed All _16 due to TimeOut");
        }
     }
   datetime time_16[];
   ArraySetAsSeries(time_16, true);
   if(CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, time_16) > 0)
     {
      if(gi_752 != (int)time_16[0])
        {
         gi_752 = (int)time_16[0];
         double ld_184 = CalculateProfit_16();
         if(bool_1244)
           {
            if(ld_184 < 0.0 && MathAbs(ld_184) > ld_1248 / 100.0 * AccountEquityHigh_16())
              {
               CloseThisSymbolAll_16();
               Print("Closed All _16 due to Stop Out");
               gi_804 = false;
              }
           }
         gi_776 = CountTrades_16();
         if(gi_776 == 0)
            gi_740 = false;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            if(!posInfo.SelectByIndex(i))
               continue;
            if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
               continue;
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
              {
               gi_792 = true;
               gi_796 = false;
               break;
              }
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               gi_792 = false;
               gi_796 = true;
               break;
              }
           }
         if(gi_776 > 0 && gi_776 <= MaxTrades_16)
           {
            double ask_16 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid_16 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            gd_716 = FindLastBuyPrice_16();
            gd_724 = FindLastSellPrice_16();
            if(gi_792 && gd_716 - ask_16 >= ld_1276_local * Point())
              {
               gi_788 = true;
              }
            else
               if(gi_796 && bid_16 - gd_724 >= ld_1276_local * Point())
                 {
                  gi_788 = true;
                 }
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
            double ask_16 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid_16 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(gi_796)
              {
               gi_760 = gi_776;
               gd_764 = NormalizeDouble(ld_176 * MathPow(ld_1224, gi_760), li_1232);
               gi_800 = OpenPendingOrder_16(1, gd_764, bid_16, (int)ld_1284, ask_16, 0, 0, gs_744 + "-" + (string)gi_760, g_magic_176_16, 0, clrHotPink);
               if(gi_800 > 0)
                 {
                  gd_724 = FindLastSellPrice_16();
                  gi_804 = true;
                  DebugLog("AF16", "OPEN_SELL_GRID", bid_16, gd_764, gi_776, ld_1276_local, "ticket=" + (string)gi_800);
                 }
               else
                 {
                  Print("Error _16 SELL grid: ", GetLastError());
                 }
               gi_788 = false;
              }
            else
               if(gi_792)
                 {
                  gi_760 = gi_776;
                  gd_764 = NormalizeDouble(ld_176 * MathPow(ld_1224, gi_760), li_1232);
                  gi_800 = OpenPendingOrder_16(0, gd_764, ask_16, (int)ld_1284, bid_16, 0, 0, gs_744 + "-" + (string)gi_760, g_magic_176_16, 0, clrLime);
                  if(gi_800 > 0)
                    {
                     gd_716 = FindLastBuyPrice_16();
                     gi_804 = true;
                     DebugLog("AF16", "OPEN_BUY_GRID", ask_16, gd_764, gi_776, ld_1276_local, "ticket=" + (string)gi_800);
                    }
                  else
                    {
                     Print("Error _16 BUY grid: ", GetLastError());
                    }
                  gi_788 = false;
                 }
           }
        }
     }
   double close_16[];
   ArraySetAsSeries(close_16, true);
   double rsi_16[];
   ArraySetAsSeries(rsi_16, true);
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 3, close_16) >= 3 &&
      CopyBuffer(g_rsi_h1_handle, 0, 0, 2, rsi_16) >= 2)
     {
      datetime time_check_16[];
      ArraySetAsSeries(time_check_16, true);
      if(CopyTime(_Symbol, (ENUM_TIMEFRAMES)g_timeframe_624, 0, 1, time_check_16) > 0)
        {
         if(g_datetime_824 != time_check_16[0])
           {
            int li_192 = PositionsTotal();
            int count_196 = 0;
            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               if(!posInfo.SelectByIndex(i))
                  continue;
               if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
                  continue;
               count_196++;
              }
            if(li_192 == 0 || count_196 < 1)
              {
               double iclose_128 = close_16[2];
               double iclose_136 = close_16[1];
               double ask_16 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double bid_16 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               gi_760 = gi_776;
               gd_764 = ld_176;
               if(iclose_128 > iclose_136)
                 {
                  if(rsi_16[1] > 30.0)
                    {
                     gi_800 = OpenPendingOrder_16(1, gd_764, bid_16, (int)ld_1284, bid_16, 0, 0, gs_744 + "-" + (string)gi_760, g_magic_176_16, 0, clrHotPink);
                     if(gi_800 < 0)
                       {
                        Print("Error _16 Initial SELL: ", GetLastError());
                        return;
                       }
                     gd_716 = FindLastBuyPrice_16();
                     gi_804 = true;
                     DebugLog("AF16", "OPEN_SELL_INIT", bid_16, gd_764, gi_776, ld_1276_local, "ticket=" + (string)gi_800);
                    }
                 }
               else
                 {
                  if(rsi_16[1] < 70.0)
                    {
                     gi_800 = OpenPendingOrder_16(0, gd_764, ask_16, (int)ld_1284, ask_16, 0, 0, gs_744 + "-" + (string)gi_760, g_magic_176_16, 0, clrLime);
                     if(gi_800 < 0)
                       {
                        Print("Error _16 Initial BUY: ", GetLastError());
                        return;
                       }
                     gd_724 = FindLastSellPrice_16();
                     gi_804 = true;
                     DebugLog("AF16", "OPEN_BUY_INIT", ask_16, gd_764, gi_776, ld_1276_local, "ticket=" + (string)gi_800);
                    }
                 }
               if(gi_800 > 0)
                  gi_756 = (int)(TimeCurrent() + 60.0 * 60.0 * gd_640);
               gi_788 = false;
              }
            g_datetime_824 = time_check_16[0];
           }
        }
     }
   gi_776 = CountTrades_16();
   g_price_692 = 0;
   double ld_1296 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!posInfo.SelectByIndex(i))
         continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
         continue;
      if(posInfo.PositionType() == POSITION_TYPE_BUY || posInfo.PositionType() == POSITION_TYPE_SELL)
        {
         g_price_692 += posInfo.PriceOpen() * posInfo.Volume();
         ld_1296 += posInfo.Volume();
        }
     }
   if(gi_776 > 0)
      g_price_692 = NormalizeDouble(g_price_692 / ld_1296, _Digits);
   if(gi_804)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!posInfo.SelectByIndex(i))
            continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
            continue;
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            g_price_660 = g_price_692 + ld_1236 * Point();
            gd_780 = g_price_692 - g_pips_628 * Point();
            gi_740 = true;
           }
         if(posInfo.PositionType() == POSITION_TYPE_SELL)
           {
            g_price_660 = g_price_692 - ld_1236 * Point();
            gd_780 = g_price_692 + g_pips_628 * Point();
            gi_740 = true;
           }
        }
     }
   if(gi_804 && gi_740)
     {
      double ask_16_tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid_16_tp = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(!posInfo.SelectByIndex(i))
            continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != g_magic_176_16)
            continue;
         ulong ticket = posInfo.Ticket();
         double adjustedTP_16 = g_price_660;
         double minStopLevel_16 = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * Point();
         if(minStopLevel_16 == 0)
            minStopLevel_16 = 2 * Point();
         if(posInfo.PositionType() == POSITION_TYPE_BUY)
           {
            double minAllowedTP_16 = bid_16_tp + minStopLevel_16;
            if(adjustedTP_16 < minAllowedTP_16)
               adjustedTP_16 = minAllowedTP_16;
           }
         else
            if(posInfo.PositionType() == POSITION_TYPE_SELL)
              {
               double minAllowedTP_16 = ask_16_tp - minStopLevel_16;
               if(adjustedTP_16 > minAllowedTP_16)
                  adjustedTP_16 = minAllowedTP_16;
              }
         adjustedTP_16 = NormalizeDouble(adjustedTP_16, _Digits);
         if(!trade.PositionModify(ticket, posInfo.StopLoss(), adjustedTP_16))
            Print("OrderModify Error _16: ", GetLastError(), " for ticket ", ticket);
        }
      gi_804 = false;
     }
   Comment("\n",
           "https://afs-id.com", "\n",
           "Server Time: ", TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS), "\n",
           "Broker: ", AccountInfoString(ACCOUNT_COMPANY), "\n",
           "Account: ", AccountInfoInteger(ACCOUNT_LOGIN), "\n",
           "Balance: ", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), "\n",
           "Equity: ", DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2), "\n",
           "Profit: ", DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2), "\n",
           "Free Margin: ", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2), "\n\n",
           "Open Orders FiboScalper: ", CountTrades_Hilo(), "\n",
           "Open Orders AF-Scalper: ", CountTrades_15(), "\n",
           "Open Orders AF-TrendKiller: ", CountTrades_16());
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        AF_Global_Expert_Full_v4
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=152713#p152713
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
