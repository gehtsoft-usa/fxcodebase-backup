/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        TradeSurge_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=158841#p158841
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

#include <Trade/Trade.mqh>
CTrade trade;
input string t1   = "SETTINGS";
input double Lots = 0.01; // Now, micro-lots of 0.01 are allowed, and if 0.1 is set, the next lot in the series will be 0.16.
input double LotExponent = 1.55; // Lot multiplication in the series follows an exponential pattern for breakeven exit.
input int    lotdecimal      = 2;     // 2 - micro-lots of 0.01, 1 - mini lots of 0.1, 0 - standard lots of 1.0.
input double PipStep         = 30.0;  // The step of the knee was 30.
input double MaxLots         = 0.01;  // Maximum lot limit.
input bool   MM              = false; // MM - Money Management
input double TakeProfit      = 100.0; // Take Profit
input bool   UseEquityStop   = false; // Use risk as a percentage.
input double TotalEquityRisk = 20.0;  // Risk as a percentage of the deposit.
input bool   UseTrailingStop = true;  // Use trailing stop.
input double TrailStart      = 13.0;
input double TrailStop       = 3.0;
input double slip            = 5.0; // Slippage
input string t2 = "Advisor's operation on Friday – before and Monday – after.";
input int StartHour_Monday    = 0;  // Start hour for Monday.
input int EndHour_Monday      = 23; // End hour for Monday.
input int StartHour_Tuesday   = 0;  // Start hour for Tuesday.
input int EndHour_Tuesday     = 23; // End hour for Tuesday.
input int StartHour_Wednesday = 0;  // Start hour for Wednesday.
input int EndHour_Wednesday   = 23; // End hour for Wednesday.
input int StartHour_Thursday  = 0;  // Start hour for Thursday.
input int EndHour_Thursday    = 23; // End hour for Thursday.
input int StartHour_Friday    = 0;  // Start hour for Friday.
input int EndHour_Friday      = 23; // End hour for Friday.
input string t3 = "SETTINGS for TradeSurge EA ";
input int    MaxTrades_Hilo = 10;  // Maximum number of simultaneously open orders for Hilo
input int    MagicNumber_Hilo = 10278; // Magic number for Hilo
input string t4 = "TradeSurge EA ILAN 1.5";
input int    MaxTrades_15 = 10;
input int    g_magic_176_15 = 22324;
int          OpenNewTF_15 = 60;
input string t5 = "SETTINGS for TradeSurge EA ILAN 1.6";
input int    MaxTrades_16 = 10;
input int    g_magic_176_16 = 23794;
int          OpenNewTF_16 = 1;
ENUM_TIMEFRAMES g_timeframe_492 = PERIOD_M1;
ENUM_TIMEFRAMES g_timeframe_496 = PERIOD_M5;
ENUM_TIMEFRAMES g_timeframe_500 = PERIOD_M15;
ENUM_TIMEFRAMES g_timeframe_504 = PERIOD_M30;
ENUM_TIMEFRAMES g_timeframe_508 = PERIOD_H1;
ENUM_TIMEFRAMES g_timeframe_512 = PERIOD_H4;
ENUM_TIMEFRAMES g_timeframe_516 = PERIOD_D1;
bool g_corner_528 = true;
int  gi_532       = 0;
int  gi_536       = 10;
int  g_window_540 = 0;
bool gi_552      = true;
bool gi_556      = true;
bool gi_560      = false;
color g_color_564 = clrGray;
color g_color_568 = clrGray;
color g_color_572 = clrGray;
color g_color_576 = clrDarkOrange;
color g_color_580 = clrDarkOrange;
int  gi_584      = 65280;
int  gi_588      = 17919;
int  gi_592      = 65280;
int  gi_596      = 17919;
int gi_608 = 65280;
int gi_612 = 255;
int gi_616 = 42495;
int g_period_628        = 8;
int g_period_632        = 17;
int g_period_636        = 9;
ENUM_APPLIED_PRICE g_applied_price_640 = PRICE_CLOSE;
int    gi_652              = 65280;
int    gi_656              = 4678655;
int    gi_660              = 32768;
int    gi_664              = 255;
int    g_period_684        = 9;
ENUM_APPLIED_PRICE g_applied_price_688 = PRICE_CLOSE;
int    g_period_700        = 13;
ENUM_APPLIED_PRICE g_applied_price_704 = PRICE_CLOSE;
int    g_period_716        = 5;
int    g_period_720        = 3;
int    g_slowing_724       = 3;
ENUM_MA_METHOD g_ma_method_728     = MODE_EMA;
int    gi_740              = 65280;
int    gi_744              = 255;
int    gi_748              = 42495;
int    g_period_760        = 5;
int    g_period_764        = 9;
ENUM_MA_METHOD g_ma_method_768     = MODE_EMA;
ENUM_APPLIED_PRICE g_applied_price_772 = PRICE_CLOSE;
int    gi_784              = 65280;
int    gi_788              = 255;
double gd_808;
double g_acc_number_816;
double g_str2dbl_824;
double g_str_len_832;
double gd_848;
double gd_856;
double g_period_864;
double g_period_872;
double g_period_880;
double gd_888;
double gd_896;
double gd_904;
double gd_912;
double g_shift_920;
double gd_928;
double gd_936;
double gd_960;
double gd_968;
int    g_bool_976;
double gd_980;
bool   g_bool_988;
int    gi_992;
string txt, txt1;
string txt2 = "";
string txt3 = "";
color  col  = clrForestGreen;
string tmp_str      = "";
int    handle_Write = 0;
int    handle_read        = 0;
string tmp_str_read       = "";
double dbl_Write_deposite = 0;
input string t6 = "SETTINGS for Variable Earnings";
input double Variable_Earnings = 20;

double WorkingLots = 0.01;
double        Lots_Hilo;
double        LotExponent_Hilo;
int           lotdecimal_Hilo;
double        TakeProfit_Hilo;
bool          UseEquityStop_Hilo;
double        TotalEquityRisk_Hilo;
bool   UseTimeOut_Hilo        = false;
double MaxTradeOpenHours_Hilo = 48.0;
bool   UseTrailingStop_Hilo;
double Stoploss_Hilo = 40.0;
double TrailStart_Hilo;
double TrailStop_Hilo;
double     PipStep_Hilo;
double     slip_Hilo;
double PriceTarget_Hilo, StartEquity_Hilo, BuyTarget_Hilo, SellTarget_Hilo, Balans, Sredstva;
double AveragePrice_Hilo, SellLimit_Hilo, BuyLimit_Hilo;
double LastBuyPrice_Hilo, LastSellPrice_Hilo, Spread_Hilo;
bool   flag_Hilo;
string EAName_Hilo      = "TradeSurge EA";
datetime timeprev_Hilo    = 0;
datetime expiration_Hilo;
int    NumOfTrades_Hilo = 0;
double iLots_Hilo;
int    cnt_Hilo      = 0, total_Hilo;
double Stopper_Hilo  = 0.0;
bool   TradeNow_Hilo = false, LongTrade_Hilo = false, ShortTrade_Hilo = false;
ulong  ticket_Hilo;
bool   NewOrdersPlaced_Hilo = false;
double AccountEquityHighAmt_Hilo, PrevEquity_Hilo;
double        LotExponent_15;
double        Lots_15;
int           lotdecimal_15;
double        TakeProfit_15;
bool          UseEquityStop_15;
double        TotalEquityRisk_15;
int           gi_unused_88_15;
bool   UseTrailingStop_15;
double Stoploss_15 = 40.0;
double TrailStart_15;
double TrailStop_15;
bool   UseTimeOut_15        = false;
double MaxTradeOpenHours_15 = 48.0;
double     PipStep_15;
double     slip_15;
double   g_price_180_15;
double   gd_188_15;
double   gd_unused_196_15;
double   gd_unused_204_15;
double   g_price_212_15;
double   g_bid_220_15;
double   g_ask_228_15;
double   gd_236_15;
double   gd_244_15;
double   gd_260_15;
bool     gi_268_15;
string   gs_ilan_272_15 = "TradeSurge EA";
datetime gi_280_15      = 0;
datetime gi_284_15;
int      gi_288_15 = 0;
double   gd_292_15;
int      g_pos_300_15 = 0;
int      gi_304_15;
double   gd_308_15 = 0.0;
bool     gi_316_15 = false;
bool     gi_320_15 = false;
bool     gi_324_15 = false;
ulong    gi_328_15;
bool     gi_332_15 = false;
double   gd_336_15;
double   gd_344_15;
datetime time_15 = 1;
double        LotExponent_16;
double        Lots_16;
int           lotdecimal_16;
double        TakeProfit_16;
bool          UseEquityStop_16;
double        TotalEquityRisk_16;
bool   UseTrailingStop_16;
double Stoploss_16 = 40.0;
double TrailStart_16;
double TrailStop_16;
bool   UseTimeOut_16        = false;
double MaxTradeOpenHours_16 = 48.0;
double     PipStep_16;
double     slip_16;
double   g_price_180_16;
double   gd_188_16;
double   gd_unused_196_16;
double   gd_unused_204_16;
double   g_price_212_16;
double   g_bid_220_16;
double   g_ask_228_16;
double   gd_236_16;
double   gd_244_16;
double   gd_260_16;
bool     gi_268_16;
string   gs_ilan_272_16 = "TradeSurge EA";
datetime gi_280_16      = 0;
datetime gi_284_16;
int      gi_288_16 = 0;
double   gd_292_16;
int      g_pos_300_16 = 0;
int      gi_304_16;
double   gd_308_16 = 0.0;
bool     gi_316_16 = false;
bool     gi_320_16 = false;
bool     gi_324_16 = false;
ulong    gi_328_16;
bool     gi_332_16 = false;
double   gd_336_16;
double   gd_344_16;
datetime time_16 = 1;
int handle_MACD_492, handle_MACD_496, handle_MACD_500, handle_MACD_504, handle_MACD_508, handle_MACD_512, handle_MACD_516;
int handle_RSI_492, handle_RSI_496, handle_RSI_500, handle_RSI_504, handle_RSI_508, handle_RSI_512, handle_RSI_516;
int handle_CCI_492, handle_CCI_496, handle_CCI_500, handle_CCI_504, handle_CCI_508, handle_CCI_512, handle_CCI_516;
int handle_Stoch_492, handle_Stoch_496, handle_Stoch_500, handle_Stoch_504, handle_Stoch_508, handle_Stoch_512, handle_Stoch_516;
int handle_MA_492_1, handle_MA_492_2, handle_MA_496_1, handle_MA_496_2, handle_MA_500_1, handle_MA_500_2;
int handle_MA_504_1, handle_MA_504_2, handle_MA_508_1, handle_MA_508_2, handle_MA_512_1, handle_MA_512_2;
int handle_MA_516_1, handle_MA_516_2;
int handle_RSI_H1;
int handle_MA_M1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Spread_Hilo = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_260_15   = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   gd_260_16   = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   handle_MACD_492 = iMACD(_Symbol, g_timeframe_492, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_496 = iMACD(_Symbol, g_timeframe_496, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_500 = iMACD(_Symbol, g_timeframe_500, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_504 = iMACD(_Symbol, g_timeframe_504, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_508 = iMACD(_Symbol, g_timeframe_508, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_512 = iMACD(_Symbol, g_timeframe_512, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_MACD_516 = iMACD(_Symbol, g_timeframe_516, g_period_628, g_period_632, g_period_636, g_applied_price_640);
   handle_RSI_492 = iRSI(_Symbol, g_timeframe_492, g_period_684, g_applied_price_688);
   handle_RSI_496 = iRSI(_Symbol, g_timeframe_496, g_period_684, g_applied_price_688);
   handle_RSI_500 = iRSI(_Symbol, g_timeframe_500, g_period_684, g_applied_price_688);
   handle_RSI_504 = iRSI(_Symbol, g_timeframe_504, g_period_684, g_applied_price_688);
   handle_RSI_508 = iRSI(_Symbol, g_timeframe_508, g_period_684, g_applied_price_688);
   handle_RSI_512 = iRSI(_Symbol, g_timeframe_512, g_period_684, g_applied_price_688);
   handle_RSI_516 = iRSI(_Symbol, g_timeframe_516, g_period_684, g_applied_price_688);
   handle_RSI_H1 = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
   handle_CCI_492 = iCCI(_Symbol, g_timeframe_492, g_period_700, g_applied_price_704);
   handle_CCI_496 = iCCI(_Symbol, g_timeframe_496, g_period_700, g_applied_price_704);
   handle_CCI_500 = iCCI(_Symbol, g_timeframe_500, g_period_700, g_applied_price_704);
   handle_CCI_504 = iCCI(_Symbol, g_timeframe_504, g_period_700, g_applied_price_704);
   handle_CCI_508 = iCCI(_Symbol, g_timeframe_508, g_period_700, g_applied_price_704);
   handle_CCI_512 = iCCI(_Symbol, g_timeframe_512, g_period_700, g_applied_price_704);
   handle_CCI_516 = iCCI(_Symbol, g_timeframe_516, g_period_700, g_applied_price_704);
   handle_Stoch_492 = iStochastic(_Symbol, g_timeframe_492, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_496 = iStochastic(_Symbol, g_timeframe_496, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_500 = iStochastic(_Symbol, g_timeframe_500, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_504 = iStochastic(_Symbol, g_timeframe_504, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_508 = iStochastic(_Symbol, g_timeframe_508, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_512 = iStochastic(_Symbol, g_timeframe_512, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_Stoch_516 = iStochastic(_Symbol, g_timeframe_516, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, STO_LOWHIGH);
   handle_MA_492_1 = iMA(_Symbol, g_timeframe_492, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_492_2 = iMA(_Symbol, g_timeframe_492, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_496_1 = iMA(_Symbol, g_timeframe_496, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_496_2 = iMA(_Symbol, g_timeframe_496, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_500_1 = iMA(_Symbol, g_timeframe_500, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_500_2 = iMA(_Symbol, g_timeframe_500, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_504_1 = iMA(_Symbol, g_timeframe_504, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_504_2 = iMA(_Symbol, g_timeframe_504, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_508_1 = iMA(_Symbol, g_timeframe_508, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_508_2 = iMA(_Symbol, g_timeframe_508, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_512_1 = iMA(_Symbol, g_timeframe_512, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_512_2 = iMA(_Symbol, g_timeframe_512, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_516_1 = iMA(_Symbol, g_timeframe_516, g_period_760, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_516_2 = iMA(_Symbol, g_timeframe_516, g_period_764, 0, g_ma_method_768, g_applied_price_772);
   handle_MA_M1 = iMA(_Symbol, PERIOD_M1, 1, 0, MODE_EMA, PRICE_CLOSE);
   ObjectCreate(0, "Lable1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable1", OBJPROP_CORNER, 2);
   ObjectSetInteger(0, "Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSetInteger(0, "Lable1", OBJPROP_YDISTANCE, 21);
   txt1 = "TRADESURGE EA";
   ObjectSetString(0, "Lable1", OBJPROP_TEXT, txt1);
   ObjectSetInteger(0, "Lable1", OBJPROP_FONTSIZE, 16);
   ObjectSetString(0, "Lable1", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, "Lable1", OBJPROP_COLOR, clrAqua);
   ObjectCreate(0, "Lable", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable", OBJPROP_CORNER, 2);
   ObjectSetInteger(0, "Lable", OBJPROP_XDISTANCE, 3);
   ObjectSetInteger(0, "Lable", OBJPROP_YDISTANCE, 1);
   txt = "Caution: High-risk trading robot";
   ObjectSetString(0, "Lable", OBJPROP_TEXT, txt);
   ObjectSetInteger(0, "Lable", OBJPROP_FONTSIZE, 14);
   ObjectSetString(0, "Lable", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, "Lable", OBJPROP_COLOR, clrGreen);
   trade.SetDeviationInPoints((ulong)slip);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
   ObjectDelete(0, "SIG_DETAIL_1");
   ObjectDelete(0, "SIG_DETAIL_2");
   ObjectDelete(0, "SIG_DETAIL_3");
   ObjectDelete(0, "SIG_DETAIL_4");
   ObjectDelete(0, "SIG_DETAIL_5");
   ObjectDelete(0, "SIG_DETAIL_6");
   ObjectDelete(0, "SIG_DETAIL_7");
   ObjectDelete(0, "SIG_DETAIL_8");
   ObjectDelete(0, "Lable");
   ObjectDelete(0, "Lable1");
   ObjectDelete(0, "Lable2");
   ObjectDelete(0, "Lable3");
   ObjectDelete(0, "close_all");
   ObjectDelete(0, "AccountEquity");
   ObjectDelete(0, "dbl_Write_deposite");
   if(handle_MACD_492 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_492);
   if(handle_MACD_496 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_496);
   if(handle_MACD_500 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_500);
   if(handle_MACD_504 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_504);
   if(handle_MACD_508 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_508);
   if(handle_MACD_512 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_512);
   if(handle_MACD_516 != INVALID_HANDLE)
      IndicatorRelease(handle_MACD_516);
   if(handle_RSI_492 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_492);
   if(handle_RSI_496 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_496);
   if(handle_RSI_500 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_500);
   if(handle_RSI_504 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_504);
   if(handle_RSI_508 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_508);
   if(handle_RSI_512 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_512);
   if(handle_RSI_516 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_516);
   if(handle_RSI_H1 != INVALID_HANDLE)
      IndicatorRelease(handle_RSI_H1);
   if(handle_CCI_492 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_492);
   if(handle_CCI_496 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_496);
   if(handle_CCI_500 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_500);
   if(handle_CCI_504 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_504);
   if(handle_CCI_508 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_508);
   if(handle_CCI_512 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_512);
   if(handle_CCI_516 != INVALID_HANDLE)
      IndicatorRelease(handle_CCI_516);
   if(handle_Stoch_492 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_492);
   if(handle_Stoch_496 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_496);
   if(handle_Stoch_500 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_500);
   if(handle_Stoch_504 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_504);
   if(handle_Stoch_508 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_508);
   if(handle_Stoch_512 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_512);
   if(handle_Stoch_516 != INVALID_HANDLE)
      IndicatorRelease(handle_Stoch_516);
   if(handle_MA_492_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_492_1);
   if(handle_MA_492_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_492_2);
   if(handle_MA_496_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_496_1);
   if(handle_MA_496_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_496_2);
   if(handle_MA_500_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_500_1);
   if(handle_MA_500_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_500_2);
   if(handle_MA_504_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_504_1);
   if(handle_MA_504_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_504_2);
   if(handle_MA_508_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_508_1);
   if(handle_MA_508_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_508_2);
   if(handle_MA_512_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_512_1);
   if(handle_MA_512_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_512_2);
   if(handle_MA_516_1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_516_1);
   if(handle_MA_516_2 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_516_2);
   if(handle_MA_M1 != INVALID_HANDLE)
      IndicatorRelease(handle_MA_M1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   int currentHour = tm.hour;
   int dayOfWeek   = tm.day_of_week;
   if(dayOfWeek == 1 && (currentHour < StartHour_Monday || currentHour > EndHour_Monday))
      return false;
   if(dayOfWeek == 2 && (currentHour < StartHour_Tuesday || currentHour > EndHour_Tuesday))
      return false;
   if(dayOfWeek == 3 && (currentHour < StartHour_Wednesday || currentHour > EndHour_Wednesday))
      return false;
   if(dayOfWeek == 4 && (currentHour < StartHour_Thursday || currentHour > EndHour_Thursday))
      return false;
   if(dayOfWeek == 5 && (currentHour < StartHour_Friday || currentHour > EndHour_Friday))
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_Hilo()
  {
   int count_Hilo = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL || ptype == POSITION_TYPE_BUY)
            count_Hilo++;
        }
     }
   return (count_Hilo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_15()
  {
   int l_count_0_15 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL || ptype == POSITION_TYPE_BUY)
            l_count_0_15++;
        }
     }
   return (l_count_0_15);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades_16()
  {
   int l_count_0_16 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL || ptype == POSITION_TYPE_BUY)
            l_count_0_16++;
        }
     }
   return (l_count_0_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_Hilo()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
        {
         trade.PositionClose(ticket, (ulong)slip_Hilo);
         Sleep(1000);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_15()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
        {
         trade.PositionClose(ticket, (ulong)slip_15);
         Sleep(1000);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll_16()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
        {
         trade.PositionClose(ticket, (ulong)slip_16);
         Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenPendingOrder_Hilo(int pType_Hilo, double pLots_Hilo, double pPrice_Hilo, int pSlippage_Hilo, double pr_Hilo, int sl_Hilo, int tp_Hilo, string pComment_Hilo, int pMagic_Hilo,
                            int pDatetime_Hilo, color pColor_Hilo)
  {
   ticket_Hilo = 0;
   trade.SetExpertMagicNumber(pMagic_Hilo);
   if(pType_Hilo == 0)
     {
      if(trade.Buy(pLots_Hilo, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, pComment_Hilo))
        {
         ticket_Hilo = trade.ResultOrder();
        }
     }
   else
      if(pType_Hilo == 1)
        {
         if(trade.Sell(pLots_Hilo, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, pComment_Hilo))
           {
            ticket_Hilo = trade.ResultOrder();
           }
        }
   return (ticket_Hilo);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenPendingOrder_15(int ai_0_15, double a_lots_4_15, double a_price_12_15, int a_slippage_20_15, double ad_24_15, int ai_32_15, int ai_36_15, string a_comment_40_15, int a_magic_48_15,
                          int a_datetime_52_15, color a_color_56_15)
  {
   ulong l_ticket_60_15 = 0;
   trade.SetExpertMagicNumber(a_magic_48_15);
   if(ai_0_15 == 0)
     {
      if(trade.Buy(a_lots_4_15, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, a_comment_40_15))
        {
         l_ticket_60_15 = trade.ResultOrder();
        }
     }
   else
      if(ai_0_15 == 1)
        {
         if(trade.Sell(a_lots_4_15, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, a_comment_40_15))
           {
            l_ticket_60_15 = trade.ResultOrder();
           }
        }
   return (l_ticket_60_15);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenPendingOrder_16(int ai_0_16, double a_lots_4_16, double a_price_12_16, int a_slippage_20_16, double ad_24_16, int ai_32_16, int ai_36_16, string a_comment_40_16, int a_magic_48_16,
                          int a_datetime_52_16, color a_color_56_16)
  {
   ulong l_ticket_60_16 = 0;
   trade.SetExpertMagicNumber(a_magic_48_16);
   if(ai_0_16 == 0)
     {
      if(trade.Buy(a_lots_4_16, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, a_comment_40_16))
        {
         l_ticket_60_16 = trade.ResultOrder();
        }
     }
   else
      if(ai_0_16 == 1)
        {
         if(trade.Sell(a_lots_4_16, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, a_comment_40_16))
           {
            l_ticket_60_16 = trade.ResultOrder();
           }
        }
   return (l_ticket_60_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_Hilo()
  {
   double Profit_Hilo = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
        {
         Profit_Hilo += PositionGetDouble(POSITION_PROFIT);
        }
     }
   return (Profit_Hilo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_15()
  {
   double ld_ret_0_15 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
        {
         ld_ret_0_15 += PositionGetDouble(POSITION_PROFIT);
        }
     }
   return (ld_ret_0_15);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit_16()
  {
   double ld_ret_0_16 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
        {
         ld_ret_0_16 += PositionGetDouble(POSITION_PROFIT);
        }
     }
   return (ld_ret_0_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_Hilo()
  {
   if(CountTrades_Hilo() == 0)
      AccountEquityHighAmt_Hilo = AccountInfoDouble(ACCOUNT_EQUITY);
   if(AccountEquityHighAmt_Hilo < PrevEquity_Hilo)
      AccountEquityHighAmt_Hilo = PrevEquity_Hilo;
   else
      AccountEquityHighAmt_Hilo = AccountInfoDouble(ACCOUNT_EQUITY);
   PrevEquity_Hilo = AccountInfoDouble(ACCOUNT_EQUITY);
   return (AccountEquityHighAmt_Hilo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_15()
  {
   if(CountTrades_15() == 0)
      gd_336_15 = AccountInfoDouble(ACCOUNT_EQUITY);
   if(gd_336_15 < gd_344_15)
      gd_336_15 = gd_344_15;
   else
      gd_336_15 = AccountInfoDouble(ACCOUNT_EQUITY);
   gd_344_15 = AccountInfoDouble(ACCOUNT_EQUITY);
   return (gd_336_15);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh_16()
  {
   if(CountTrades_16() == 0)
      gd_336_16 = AccountInfoDouble(ACCOUNT_EQUITY);
   if(gd_336_16 < gd_344_16)
      gd_336_16 = gd_344_16;
   else
      gd_336_16 = AccountInfoDouble(ACCOUNT_EQUITY);
   gd_344_16 = AccountInfoDouble(ACCOUNT_EQUITY);
   return (gd_336_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_Hilo()
  {
   double oldorderopenprice_Hilo = 0;
   ulong oldticketnumber_Hilo = 0;
   ulong ticketnumber_Hilo = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY)
           {
            oldticketnumber_Hilo = ticket;
            if(oldticketnumber_Hilo > ticketnumber_Hilo)
              {
               oldorderopenprice_Hilo = PositionGetDouble(POSITION_PRICE_OPEN);
               ticketnumber_Hilo = oldticketnumber_Hilo;
              }
           }
        }
     }
   return (oldorderopenprice_Hilo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_Hilo()
  {
   double oldorderopenprice_Hilo = 0;
   ulong oldticketnumber_Hilo = 0;
   ulong ticketnumber_Hilo = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL)
           {
            oldticketnumber_Hilo = ticket;
            if(oldticketnumber_Hilo > ticketnumber_Hilo)
              {
               oldorderopenprice_Hilo = PositionGetDouble(POSITION_PRICE_OPEN);
               ticketnumber_Hilo = oldticketnumber_Hilo;
              }
           }
        }
     }
   return (oldorderopenprice_Hilo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_15()
  {
   double l_ord_open_price_8_15 = 0;
   ulong l_ticket_24_15 = 0;
   ulong l_ticket_20_15 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY)
           {
            l_ticket_24_15 = ticket;
            if(l_ticket_24_15 > l_ticket_20_15)
              {
               l_ord_open_price_8_15 = PositionGetDouble(POSITION_PRICE_OPEN);
               l_ticket_20_15 = l_ticket_24_15;
              }
           }
        }
     }
   return (l_ord_open_price_8_15);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_15()
  {
   double l_ord_open_price_8_15 = 0;
   ulong l_ticket_24_15 = 0;
   ulong l_ticket_20_15 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL)
           {
            l_ticket_24_15 = ticket;
            if(l_ticket_24_15 > l_ticket_20_15)
              {
               l_ord_open_price_8_15 = PositionGetDouble(POSITION_PRICE_OPEN);
               l_ticket_20_15 = l_ticket_24_15;
              }
           }
        }
     }
   return (l_ord_open_price_8_15);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastBuyPrice_16()
  {
   double l_ord_open_price_8_16 = 0;
   ulong l_ticket_24_16 = 0;
   ulong l_ticket_20_16 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY)
           {
            l_ticket_24_16 = ticket;
            if(l_ticket_24_16 > l_ticket_20_16)
              {
               l_ord_open_price_8_16 = PositionGetDouble(POSITION_PRICE_OPEN);
               l_ticket_20_16 = l_ticket_24_16;
              }
           }
        }
     }
   return (l_ord_open_price_8_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLastSellPrice_16()
  {
   double l_ord_open_price_8_16 = 0;
   ulong l_ticket_24_16 = 0;
   ulong l_ticket_20_16 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL)
           {
            l_ticket_24_16 = ticket;
            if(l_ticket_24_16 > l_ticket_20_16)
              {
               l_ord_open_price_8_16 = PositionGetDouble(POSITION_PRICE_OPEN);
               l_ticket_20_16 = l_ticket_24_16;
              }
           }
        }
     }
   return (l_ord_open_price_8_16);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_Hilo(int pType_Hilo, int stop_Hilo, double AvgPrice_Hilo)
  {
   int    profit_Hilo;
   double stoptrade_Hilo;
   double stopcal_Hilo;
   if(stop_Hilo != 0)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol || PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
           {
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if(ptype == POSITION_TYPE_BUY)
              {
               profit_Hilo = (int)NormalizeDouble((bid - AvgPrice_Hilo) / _Point, 0);
               if(profit_Hilo < pType_Hilo)
                  continue;
               stoptrade_Hilo = PositionGetDouble(POSITION_SL);
               stopcal_Hilo   = bid - stop_Hilo * _Point;
               if(stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo > stoptrade_Hilo))
                 {
                  trade.PositionModify(ticket, stopcal_Hilo, PositionGetDouble(POSITION_TP));
                 }
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               profit_Hilo = (int)NormalizeDouble((AvgPrice_Hilo - ask) / _Point, 0);
               if(profit_Hilo < pType_Hilo)
                  continue;
               stoptrade_Hilo = PositionGetDouble(POSITION_SL);
               stopcal_Hilo   = ask + stop_Hilo * _Point;
               if(stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo < stoptrade_Hilo))
                 {
                  trade.PositionModify(ticket, stopcal_Hilo, PositionGetDouble(POSITION_TP));
                 }
              }
           }
         Sleep(1000);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_15(int ai_0_15, int ai_4_15, double a_price_8_15)
  {
   int    l_ticket_16_15;
   double l_ord_stoploss_20_15;
   double l_price_28_15;
   if(ai_4_15 != 0)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol || PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
           {
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if(ptype == POSITION_TYPE_BUY)
              {
               l_ticket_16_15 = (int)NormalizeDouble((bid - a_price_8_15) / _Point, 0);
               if(l_ticket_16_15 < ai_0_15)
                  continue;
               l_ord_stoploss_20_15 = PositionGetDouble(POSITION_SL);
               l_price_28_15        = bid - ai_4_15 * _Point;
               if(l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 > l_ord_stoploss_20_15))
                 {
                  trade.PositionModify(ticket, l_price_28_15, PositionGetDouble(POSITION_TP));
                 }
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               l_ticket_16_15 = (int)NormalizeDouble((a_price_8_15 - ask) / _Point, 0);
               if(l_ticket_16_15 < ai_0_15)
                  continue;
               l_ord_stoploss_20_15 = PositionGetDouble(POSITION_SL);
               l_price_28_15        = ask + ai_4_15 * _Point;
               if(l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 < l_ord_stoploss_20_15))
                 {
                  trade.PositionModify(ticket, l_price_28_15, PositionGetDouble(POSITION_TP));
                 }
              }
           }
         Sleep(1000);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls_16(int ai_0_16, int ai_4_16, double a_price_8_16)
  {
   int    l_ticket_16_16;
   double l_ord_stoploss_20_16;
   double l_price_28_16;
   if(ai_4_16 != 0)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol || PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
           {
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if(ptype == POSITION_TYPE_BUY)
              {
               l_ticket_16_16 = (int)NormalizeDouble((bid - a_price_8_16) / _Point, 0);
               if(l_ticket_16_16 < ai_0_16)
                  continue;
               l_ord_stoploss_20_16 = PositionGetDouble(POSITION_SL);
               l_price_28_16        = bid - ai_4_16 * _Point;
               if(l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 > l_ord_stoploss_20_16))
                 {
                  trade.PositionModify(ticket, l_price_28_16, PositionGetDouble(POSITION_TP));
                 }
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               l_ticket_16_16 = (int)NormalizeDouble((a_price_8_16 - ask) / _Point, 0);
               if(l_ticket_16_16 < ai_0_16)
                  continue;
               l_ord_stoploss_20_16 = PositionGetDouble(POSITION_SL);
               l_price_28_16        = ask + ai_4_16 * _Point;
               if(l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 < l_ord_stoploss_20_16))
                 {
                  trade.PositionModify(ticket, l_price_28_16, PositionGetDouble(POSITION_TP));
                 }
              }
           }
         Sleep(1000);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Total_buy_pos()
  {
   int Total_buy_pos_count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY)
           {
            Total_buy_pos_count++;
           }
        }
     }
   return (Total_buy_pos_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Total_sell_pos()
  {
   int Total_sell_pos_count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL)
           {
            Total_sell_pos_count++;
           }
        }
     }
   return (Total_sell_pos_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Total_LIMIT_STOP()
  {
   int Total_LIMIT_STOP_count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         if(otype == ORDER_TYPE_BUY_LIMIT || otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_SELL_LIMIT || otype == ORDER_TYPE_SELL_STOP)
           {
            Total_LIMIT_STOP_count++;
           }
        }
     }
   return (Total_LIMIT_STOP_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Close_BUY()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY)
           {
            trade.PositionClose(ticket, 3);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Close_SELL()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_SELL)
           {
            trade.PositionClose(ticket, 3);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Delete_limit_stop()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         if(otype == ORDER_TYPE_BUY_LIMIT || otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_SELL_LIMIT || otype == ORDER_TYPE_SELL_STOP)
           {
            trade.OrderDelete(ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Obj_Label(string Name, string Value, color Color, int xdis, int ydis, int font_size, int corner)
  {
   ObjectCreate(0, Name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, Name, OBJPROP_XDISTANCE, xdis);
   ObjectSetInteger(0, Name, OBJPROP_YDISTANCE, ydis);
   ObjectSetInteger(0, Name, OBJPROP_CORNER, corner);
   ObjectSetString(0, Name, OBJPROP_TEXT, Value);
   ObjectSetInteger(0, Name, OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, Name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, Name, OBJPROP_COLOR, Color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   LotExponent_Hilo = LotExponent;
   lotdecimal_Hilo = lotdecimal;
   TakeProfit_Hilo = TakeProfit;
   UseEquityStop_Hilo = UseEquityStop;
   TotalEquityRisk_Hilo = TotalEquityRisk;
   UseTrailingStop_Hilo = UseTrailingStop;
   TrailStart_Hilo = TrailStart;
   TrailStop_Hilo = TrailStop;
   PipStep_Hilo = PipStep;
   slip_Hilo = slip;
   LotExponent_15 = LotExponent;
   lotdecimal_15 = lotdecimal;
   TakeProfit_15 = TakeProfit;
   UseEquityStop_15 = UseEquityStop;
   TotalEquityRisk_15 = TotalEquityRisk;
   UseTrailingStop_15 = UseTrailingStop;
   TrailStart_15 = TrailStart;
   TrailStop_15 = TrailStop;
   PipStep_15 = PipStep;
   slip_15 = slip;
   LotExponent_16 = LotExponent;
   lotdecimal_16 = lotdecimal;
   TakeProfit_16 = TakeProfit;
   UseEquityStop_16 = UseEquityStop;
   TotalEquityRisk_16 = TotalEquityRisk;
   UseTrailingStop_16 = UseTrailingStop;
   TrailStart_16 = TrailStart;
   TrailStop_16 = TrailStop;
   PipStep_16 = PipStep;
   slip_16 = slip;
   if(MM == true)
     {
      if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000)
        {
         Lots_Hilo = Lots;
         Lots_15 = Lots;
         Lots_16 = Lots;
        }
      else
        {
         Lots_Hilo = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
         Lots_15 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
         Lots_16 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
        }
     }
   else
     {
      Lots_Hilo = Lots;
      Lots_15 = Lots;
      Lots_16 = Lots;
     }
   if(dbl_Write_deposite == 0)
     {
      tmp_str = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
      handle_Write = FileOpen("Write_deposite.txt", FILE_READ | FILE_WRITE | FILE_TXT, ';');
      if(handle_Write != INVALID_HANDLE)
        {
         FileSeek(handle_Write, 0, SEEK_CUR);
         FileWrite(handle_Write, tmp_str);
         FileClose(handle_Write);
         handle_Write = 0;
        }
     }
   if(((AccountInfoDouble(ACCOUNT_EQUITY) >= NormalizeDouble((dbl_Write_deposite + Variable_Earnings), 2)) && (dbl_Write_deposite != 0)))
     {
      if(ObjectFind(0, "close_all") != 0)
        {
         Obj_Label("close_all", "close_all", clrWhite, 5, 5, 7, 0);
        }
      tmp_str = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
      handle_Write = FileOpen("Write_deposite.txt", FILE_READ | FILE_WRITE | FILE_TXT, ';');
      if(handle_Write != INVALID_HANDLE)
        {
         FileSeek(handle_Write, 0, SEEK_CUR);
         FileWrite(handle_Write, tmp_str);
         FileClose(handle_Write);
         handle_Write = 0;
        }
     }
   if((Total_buy_pos() == 0) && (Total_sell_pos() == 0) && (Total_LIMIT_STOP() == 0) && (ObjectFind(0, "close_all") == 0))
     {
      SendMail("account earnings reached, all trades closed", "account earnings reached, all trades closed");
      if(dbl_Write_deposite != 0)
        {
         tmp_str = "0";
         handle_Write = FileOpen("Write_deposite.txt", FILE_READ | FILE_WRITE | FILE_TXT, ';');
         if(handle_Write != INVALID_HANDLE)
           {
            FileSeek(handle_Write, 0, SEEK_CUR);
            FileWrite(handle_Write, tmp_str);
            FileClose(handle_Write);
            handle_Write = 0;
           }
        }
      ObjectDelete(0, "close_all");
     }
   if(ObjectFind(0, "close_all") == 0)
     {
      Close_BUY();
      Close_SELL();
      Delete_limit_stop();
      return;
     }
   handle_read = FileOpen("Write_deposite.txt", FILE_READ | FILE_TXT);
   if(handle_read != INVALID_HANDLE)
     {
      tmp_str_read = FileReadString(handle_read, 7);
      dbl_Write_deposite = StringToDouble(tmp_str_read);
      FileClose(handle_read);
     }
   WorkingLots = Lots;
   if(WorkingLots > MaxLots)
     {
      WorkingLots = MaxLots;
      Lots_Hilo = MaxLots;
      Lots_15 = MaxLots;
      Lots_16 = MaxLots;
     }
   else
     {
      Lots_Hilo = WorkingLots;
      Lots_15 = WorkingLots;
      Lots_16 = WorkingLots;
     }
   string comment_str = "\n" + "TradeSurge EA" + "\n" + "________________________________" + "\n" +
                        "Broker:         " + AccountInfoString(ACCOUNT_COMPANY) + "\n" +
                        "Brokers Time:  " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n" +
                        "________________________________" + "\n" +
                        "Name:             " + AccountInfoString(ACCOUNT_NAME) + "\n" +
                        "Account Number:   " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n" +
                        "Account Currency: " + AccountInfoString(ACCOUNT_CURRENCY) + "\n" +
                        "_______________________________" + "\n" +
                        "Open Orders Ilan_Hilo:   " + IntegerToString(CountTrades_Hilo()) + "\n" +
                        "Open Orders Ilan_1.5 :   " + IntegerToString(CountTrades_15()) + "\n" +
                        "Open Orders Ilan_1.6 :   " + IntegerToString(CountTrades_16()) + "\n" +
                        "ALL ORDERS:               " + IntegerToString(PositionsTotal()) + "\n" +
                        "_______________________________" + "\n" +
                        "Account BALANCE:     " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n" +
                        "Account EQUITY:      " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n" +
                        "TradeSurge EA";
   Comment(comment_str);
   Balans = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   Sredstva = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   if(Sredstva >= Balans / 6 * 5)
      col = clrDodgerBlue;
   if(Sredstva >= Balans / 6 * 4 && Sredstva < Balans / 6 * 5)
      col = clrDeepSkyBlue;
   if(Sredstva >= Balans / 6 * 3 && Sredstva < Balans / 6 * 4)
      col = clrGold;
   if(Sredstva >= Balans / 6 * 2 && Sredstva < Balans / 6 * 3)
      col = clrOrangeRed;
   if(Sredstva >= Balans / 6 && Sredstva < Balans / 6 * 2)
      col = clrCrimson;
   if(Sredstva < Balans / 5)
      col = clrRed;
   ObjectDelete(0, "Lable2");
   ObjectCreate(0, "Lable2", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable2", OBJPROP_CORNER, 3);
   ObjectSetInteger(0, "Lable2", OBJPROP_XDISTANCE, gi_536 + 0);
   ObjectSetInteger(0, "Lable2", OBJPROP_YDISTANCE, 31);
   txt2 = (DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   ObjectSetString(0, "Lable2", OBJPROP_TEXT, "Account BALANCE:  " + txt2 + "");
   ObjectSetInteger(0, "Lable2", OBJPROP_FONTSIZE, 16);
   ObjectSetString(0, "Lable2", OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, "Lable2", OBJPROP_COLOR, clrDodgerBlue);
   ObjectDelete(0, "Lable3");
   ObjectCreate(0, "Lable3", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Lable3", OBJPROP_CORNER, 3);
   ObjectSetInteger(0, "Lable3", OBJPROP_XDISTANCE, gi_536 + 0);
   ObjectSetInteger(0, "Lable3", OBJPROP_YDISTANCE, 11);
   txt3 = (DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
   ObjectSetString(0, "Lable3", OBJPROP_TEXT, "Account EQUITY:  " + txt3 + "");
   ObjectSetInteger(0, "Lable3", OBJPROP_FONTSIZE, 16);
   ObjectSetString(0, "Lable3", OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, "Lable3", OBJPROP_COLOR, col);
   if(gi_556 && gi_552)
     {
      double macd_m1[];
      double signal_m1[];
      double macd_m5[];
      double signal_m5[];
      double macd_m15[];
      double signal_m15[];
      double macd_m30[];
      double signal_m30[];
      double macd_h1[];
      double signal_h1[];
      double macd_h4[];
      double signal_h4[];
      double macd_d1[];
      double signal_d1[];
      CopyBuffer(handle_MACD_492, 0, 0, 2, macd_m1);
      ArraySetAsSeries(macd_m1, true);
      CopyBuffer(handle_MACD_492, 1, 0, 2, signal_m1);
      ArraySetAsSeries(signal_m1, true);
      CopyBuffer(handle_MACD_496, 0, 0, 2, macd_m5);
      ArraySetAsSeries(macd_m5, true);
      CopyBuffer(handle_MACD_496, 1, 0, 2, signal_m5);
      ArraySetAsSeries(signal_m5, true);
      CopyBuffer(handle_MACD_500, 0, 0, 2, macd_m15);
      ArraySetAsSeries(macd_m15, true);
      CopyBuffer(handle_MACD_500, 1, 0, 2, signal_m15);
      ArraySetAsSeries(signal_m15, true);
      CopyBuffer(handle_MACD_504, 0, 0, 2, macd_m30);
      ArraySetAsSeries(macd_m30, true);
      CopyBuffer(handle_MACD_504, 1, 0, 2, signal_m30);
      ArraySetAsSeries(signal_m30, true);
      CopyBuffer(handle_MACD_508, 0, 0, 2, macd_h1);
      ArraySetAsSeries(macd_h1, true);
      CopyBuffer(handle_MACD_508, 1, 0, 2, signal_h1);
      ArraySetAsSeries(signal_h1, true);
      CopyBuffer(handle_MACD_512, 0, 0, 2, macd_h4);
      ArraySetAsSeries(macd_h4, true);
      CopyBuffer(handle_MACD_512, 1, 0, 2, signal_h4);
      ArraySetAsSeries(signal_h4, true);
      CopyBuffer(handle_MACD_516, 0, 0, 2, macd_d1);
      ArraySetAsSeries(macd_d1, true);
      CopyBuffer(handle_MACD_516, 1, 0, 2, signal_d1);
      ArraySetAsSeries(signal_d1, true);
      string macd_text_m1 = "-";
      string macd_text_m5 = "-";
      string macd_text_m15 = "-";
      string macd_text_m30 = "-";
      string macd_text_h1 = "-";
      string macd_text_h4 = "-";
      string macd_text_d1 = "-";
      color macd_col_m1 = (color)gi_656;
      color macd_col_m5 = (color)gi_656;
      color macd_col_m15 = (color)gi_656;
      color macd_col_m30 = (color)gi_656;
      color macd_col_h1 = (color)gi_656;
      color macd_col_h4 = (color)gi_656;
      color macd_col_d1 = (color)gi_656;
      if(macd_m1[1] > signal_m1[1])
        {
         macd_text_m1 = "-";
         macd_col_m1 = (color)gi_660;
        }
      if(macd_m1[1] <= signal_m1[1])
        {
         macd_text_m1 = "-";
         macd_col_m1 = (color)gi_656;
        }
      if(macd_m1[1] > signal_m1[1] && macd_m1[1] > 0.0)
        {
         macd_text_m1 = "-";
         macd_col_m1 = (color)gi_652;
        }
      if(macd_m1[1] <= signal_m1[1] && macd_m1[1] < 0.0)
        {
         macd_text_m1 = "-";
         macd_col_m1 = (color)gi_664;
        }
      if(macd_m5[1] > signal_m5[1])
        {
         macd_text_m5 = "-";
         macd_col_m5 = (color)gi_660;
        }
      if(macd_m5[1] <= signal_m5[1])
        {
         macd_text_m5 = "-";
         macd_col_m5 = (color)gi_656;
        }
      if(macd_m5[1] > signal_m5[1] && macd_m5[1] > 0.0)
        {
         macd_text_m5 = "-";
         macd_col_m5 = (color)gi_652;
        }
      if(macd_m5[1] <= signal_m5[1] && macd_m5[1] < 0.0)
        {
         macd_text_m5 = "-";
         macd_col_m5 = (color)gi_664;
        }
      if(macd_m15[1] > signal_m15[1])
        {
         macd_text_m15 = "-";
         macd_col_m15 = (color)gi_660;
        }
      if(macd_m15[1] <= signal_m15[1])
        {
         macd_text_m15 = "-";
         macd_col_m15 = (color)gi_656;
        }
      if(macd_m15[1] > signal_m15[1] && macd_m15[1] > 0.0)
        {
         macd_text_m15 = "-";
         macd_col_m15 = (color)gi_652;
        }
      if(macd_m15[1] <= signal_m15[1] && macd_m15[1] < 0.0)
        {
         macd_text_m15 = "-";
         macd_col_m15 = (color)gi_664;
        }
      if(macd_m30[1] > signal_m30[1])
        {
         macd_text_m30 = "-";
         macd_col_m30 = (color)gi_660;
        }
      if(macd_m30[1] <= signal_m30[1])
        {
         macd_text_m30 = "-";
         macd_col_m30 = (color)gi_656;
        }
      if(macd_m30[1] > signal_m30[1] && macd_m30[1] > 0.0)
        {
         macd_text_m30 = "-";
         macd_col_m30 = (color)gi_652;
        }
      if(macd_m30[1] <= signal_m30[1] && macd_m30[1] < 0.0)
        {
         macd_text_m30 = "-";
         macd_col_m30 = (color)gi_664;
        }
      if(macd_h1[1] > signal_h1[1])
        {
         macd_text_h1 = "-";
         macd_col_h1 = (color)gi_660;
        }
      if(macd_h1[1] <= signal_h1[1])
        {
         macd_text_h1 = "-";
         macd_col_h1 = (color)gi_656;
        }
      if(macd_h1[1] > signal_h1[1] && macd_h1[1] > 0.0)
        {
         macd_text_h1 = "-";
         macd_col_h1 = (color)gi_652;
        }
      if(macd_h1[1] <= signal_h1[1] && macd_h1[1] < 0.0)
        {
         macd_text_h1 = "-";
         macd_col_h1 = (color)gi_664;
        }
      if(macd_h4[1] > signal_h4[1])
        {
         macd_text_h4 = "-";
         macd_col_h4 = (color)gi_660;
        }
      if(macd_h4[1] <= signal_h4[1])
        {
         macd_text_h4 = "-";
         macd_col_h4 = (color)gi_656;
        }
      if(macd_h4[1] > signal_h4[1] && macd_h4[1] > 0.0)
        {
         macd_text_h4 = "-";
         macd_col_h4 = (color)gi_652;
        }
      if(macd_h4[1] <= signal_h4[1] && macd_h4[1] < 0.0)
        {
         macd_text_h4 = "-";
         macd_col_h4 = (color)gi_664;
        }
      if(macd_d1[1] > signal_d1[1])
        {
         macd_text_d1 = "-";
         macd_col_d1 = (color)gi_660;
        }
      if(macd_d1[1] <= signal_d1[1])
        {
         macd_text_d1 = "-";
         macd_col_d1 = (color)gi_656;
        }
      if(macd_d1[1] > signal_d1[1] && macd_d1[1] > 0.0)
        {
         macd_text_d1 = "-";
         macd_col_d1 = (color)gi_652;
        }
      if(macd_d1[1] <= signal_d1[1] && macd_d1[1] < 0.0)
        {
         macd_text_d1 = "-";
         macd_col_d1 = (color)gi_664;
        }
      ObjectDelete(0, "SSignalMACD_TEXT");
      ObjectCreate(0, "SSignalMACD_TEXT", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACD_TEXT", OBJPROP_TEXT, "MACD");
      ObjectSetString(0, "SSignalMACD_TEXT", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_FONTSIZE, 6);
      ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_COLOR, g_color_568);
      ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
      ObjectSetInteger(0, "SSignalMACD_TEXT", OBJPROP_YDISTANCE, gi_532 + 35);
      ObjectDelete(0, "SSignalMACDM1");
      ObjectCreate(0, "SSignalMACDM1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDM1", OBJPROP_TEXT, macd_text_m1);
      ObjectSetString(0, "SSignalMACDM1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDM1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDM1", OBJPROP_COLOR, macd_col_m1);
      ObjectSetInteger(0, "SSignalMACDM1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDM1", OBJPROP_XDISTANCE, gi_536 + 130);
      ObjectSetInteger(0, "SSignalMACDM1", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDM5");
      ObjectCreate(0, "SSignalMACDM5", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDM5", OBJPROP_TEXT, macd_text_m5);
      ObjectSetString(0, "SSignalMACDM5", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDM5", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDM5", OBJPROP_COLOR, macd_col_m5);
      ObjectSetInteger(0, "SSignalMACDM5", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDM5", OBJPROP_XDISTANCE, gi_536 + 110);
      ObjectSetInteger(0, "SSignalMACDM5", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDM15");
      ObjectCreate(0, "SSignalMACDM15", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDM15", OBJPROP_TEXT, macd_text_m15);
      ObjectSetString(0, "SSignalMACDM15", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDM15", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDM15", OBJPROP_COLOR, macd_col_m15);
      ObjectSetInteger(0, "SSignalMACDM15", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDM15", OBJPROP_XDISTANCE, gi_536 + 90);
      ObjectSetInteger(0, "SSignalMACDM15", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDM30");
      ObjectCreate(0, "SSignalMACDM30", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDM30", OBJPROP_TEXT, macd_text_m30);
      ObjectSetString(0, "SSignalMACDM30", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDM30", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDM30", OBJPROP_COLOR, macd_col_m30);
      ObjectSetInteger(0, "SSignalMACDM30", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDM30", OBJPROP_XDISTANCE, gi_536 + 70);
      ObjectSetInteger(0, "SSignalMACDM30", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDH1");
      ObjectCreate(0, "SSignalMACDH1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDH1", OBJPROP_TEXT, macd_text_h1);
      ObjectSetString(0, "SSignalMACDH1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDH1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDH1", OBJPROP_COLOR, macd_col_h1);
      ObjectSetInteger(0, "SSignalMACDH1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDH1", OBJPROP_XDISTANCE, gi_536 + 50);
      ObjectSetInteger(0, "SSignalMACDH1", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDH4");
      ObjectCreate(0, "SSignalMACDH4", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDH4", OBJPROP_TEXT, macd_text_h4);
      ObjectSetString(0, "SSignalMACDH4", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDH4", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDH4", OBJPROP_COLOR, macd_col_h4);
      ObjectSetInteger(0, "SSignalMACDH4", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDH4", OBJPROP_XDISTANCE, gi_536 + 30);
      ObjectSetInteger(0, "SSignalMACDH4", OBJPROP_YDISTANCE, gi_532 + 2);
      ObjectDelete(0, "SSignalMACDD1");
      ObjectCreate(0, "SSignalMACDD1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalMACDD1", OBJPROP_TEXT, macd_text_d1);
      ObjectSetString(0, "SSignalMACDD1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalMACDD1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SSignalMACDD1", OBJPROP_COLOR, macd_col_d1);
      ObjectSetInteger(0, "SSignalMACDD1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalMACDD1", OBJPROP_XDISTANCE, gi_536 + 10);
      ObjectSetInteger(0, "SSignalMACDD1", OBJPROP_YDISTANCE, gi_532 + 2);
      double rsi_d1[];
      double rsi_h4[];
      double rsi_h1[];
      double rsi_m30[];
      double rsi_m15[];
      double rsi_m5[];
      double rsi_m1[];
      double cci_d1[];
      double cci_h4[];
      double cci_h1[];
      double cci_m30[];
      double cci_m15[];
      double cci_m5[];
      double cci_m1[];
      double stoch_d1[];
      double stoch_h4[];
      double stoch_h1[];
      double stoch_m30[];
      double stoch_m15[];
      double stoch_m5[];
      double stoch_m1[];
      CopyBuffer(handle_RSI_516, 0, 0, 2, rsi_d1);
      ArraySetAsSeries(rsi_d1, true);
      CopyBuffer(handle_RSI_512, 0, 0, 2, rsi_h4);
      ArraySetAsSeries(rsi_h4, true);
      CopyBuffer(handle_RSI_508, 0, 0, 2, rsi_h1);
      ArraySetAsSeries(rsi_h1, true);
      CopyBuffer(handle_RSI_504, 0, 0, 2, rsi_m30);
      ArraySetAsSeries(rsi_m30, true);
      CopyBuffer(handle_RSI_500, 0, 0, 2, rsi_m15);
      ArraySetAsSeries(rsi_m15, true);
      CopyBuffer(handle_RSI_496, 0, 0, 2, rsi_m5);
      ArraySetAsSeries(rsi_m5, true);
      CopyBuffer(handle_RSI_492, 0, 0, 2, rsi_m1);
      ArraySetAsSeries(rsi_m1, true);
      CopyBuffer(handle_CCI_516, 0, 0, 2, cci_d1);
      ArraySetAsSeries(cci_d1, true);
      CopyBuffer(handle_CCI_512, 0, 0, 2, cci_h4);
      ArraySetAsSeries(cci_h4, true);
      CopyBuffer(handle_CCI_508, 0, 0, 2, cci_h1);
      ArraySetAsSeries(cci_h1, true);
      CopyBuffer(handle_CCI_504, 0, 0, 2, cci_m30);
      ArraySetAsSeries(cci_m30, true);
      CopyBuffer(handle_CCI_500, 0, 0, 2, cci_m15);
      ArraySetAsSeries(cci_m15, true);
      CopyBuffer(handle_CCI_496, 0, 0, 2, cci_m5);
      ArraySetAsSeries(cci_m5, true);
      CopyBuffer(handle_CCI_492, 0, 0, 2, cci_m1);
      ArraySetAsSeries(cci_m1, true);
      CopyBuffer(handle_Stoch_516, 0, 0, 2, stoch_d1);
      ArraySetAsSeries(stoch_d1, true);
      CopyBuffer(handle_Stoch_512, 0, 0, 2, stoch_h4);
      ArraySetAsSeries(stoch_h4, true);
      CopyBuffer(handle_Stoch_508, 0, 0, 2, stoch_h1);
      ArraySetAsSeries(stoch_h1, true);
      CopyBuffer(handle_Stoch_504, 0, 0, 2, stoch_m30);
      ArraySetAsSeries(stoch_m30, true);
      CopyBuffer(handle_Stoch_500, 0, 0, 2, stoch_m15);
      ArraySetAsSeries(stoch_m15, true);
      CopyBuffer(handle_Stoch_496, 0, 0, 2, stoch_m5);
      ArraySetAsSeries(stoch_m5, true);
      CopyBuffer(handle_Stoch_492, 0, 0, 2, stoch_m1);
      ArraySetAsSeries(stoch_m1, true);
      string str_text_d1 = "-";
      string str_text_h4 = "-";
      string str_text_h1 = "-";
      string str_text_m30 = "-";
      string str_text_m15 = "-";
      string str_text_m5 = "-";
      string str_text_m1 = "-";
      color str_col_d1 = (color)gi_748;
      color str_col_h4 = (color)gi_748;
      color str_col_h1 = (color)gi_748;
      color str_col_m30 = (color)gi_748;
      color str_col_m15 = (color)gi_748;
      color str_col_m5 = (color)gi_748;
      color str_col_m1 = (color)gi_748;
      if(rsi_d1[0] > 50.0 && stoch_d1[0] > 40.0 && cci_d1[0] > 0.0)
        {
         str_text_d1 = "-";
         str_col_d1 = (color)gi_740;
        }
      if(rsi_h4[0] > 50.0 && stoch_h4[0] > 40.0 && cci_h4[0] > 0.0)
        {
         str_text_h4 = "-";
         str_col_h4 = (color)gi_740;
        }
      if(rsi_h1[0] > 50.0 && stoch_h1[0] > 40.0 && cci_h1[0] > 0.0)
        {
         str_text_h1 = "-";
         str_col_h1 = (color)gi_740;
        }
      if(rsi_m30[0] > 50.0 && stoch_m30[0] > 40.0 && cci_m30[0] > 0.0)
        {
         str_text_m30 = "-";
         str_col_m30 = (color)gi_740;
        }
      if(rsi_m15[0] > 50.0 && stoch_m15[0] > 40.0 && cci_m15[0] > 0.0)
        {
         str_text_m15 = "-";
         str_col_m15 = (color)gi_740;
        }
      if(rsi_m5[0] > 50.0 && stoch_m5[0] > 40.0 && cci_m5[0] > 0.0)
        {
         str_text_m5 = "-";
         str_col_m5 = (color)gi_740;
        }
      if(rsi_m1[0] > 50.0 && stoch_m1[0] > 40.0 && cci_m1[0] > 0.0)
        {
         str_text_m1 = "-";
         str_col_m1 = (color)gi_740;
        }
      if(rsi_d1[0] < 50.0 && stoch_d1[0] < 60.0 && cci_d1[0] < 0.0)
        {
         str_text_d1 = "-";
         str_col_d1 = (color)gi_744;
        }
      if(rsi_h4[0] < 50.0 && stoch_h4[0] < 60.0 && cci_h4[0] < 0.0)
        {
         str_text_h4 = "-";
         str_col_h4 = (color)gi_744;
        }
      if(rsi_h1[0] < 50.0 && stoch_h1[0] < 60.0 && cci_h1[0] < 0.0)
        {
         str_text_h1 = "-";
         str_col_h1 = (color)gi_744;
        }
      if(rsi_m30[0] < 50.0 && stoch_m30[0] < 60.0 && cci_m30[0] < 0.0)
        {
         str_text_m30 = "-";
         str_col_m30 = (color)gi_744;
        }
      if(rsi_m15[0] < 50.0 && stoch_m15[0] < 60.0 && cci_m15[0] < 0.0)
        {
         str_text_m15 = "-";
         str_col_m15 = (color)gi_744;
        }
      if(rsi_m5[0] < 50.0 && stoch_m5[0] < 60.0 && cci_m5[0] < 0.0)
        {
         str_text_m5 = "-";
         str_col_m5 = (color)gi_744;
        }
      if(rsi_m1[0] < 50.0 && stoch_m1[0] < 60.0 && cci_m1[0] < 0.0)
        {
         str_text_m1 = "-";
         str_col_m1 = (color)gi_744;
        }
      ObjectDelete(0, "SSignalSTR_TEXT");
      ObjectCreate(0, "SSignalSTR_TEXT", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SSignalSTR_TEXT", OBJPROP_TEXT, "STR");
      ObjectSetString(0, "SSignalSTR_TEXT", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_FONTSIZE, 6);
      ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_COLOR, g_color_568);
      ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
      ObjectSetInteger(0, "SSignalSTR_TEXT", OBJPROP_YDISTANCE, gi_532 + 43);
      ObjectDelete(0, "SignalSTRM1");
      ObjectCreate(0, "SignalSTRM1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRM1", OBJPROP_TEXT, str_text_m1);
      ObjectSetString(0, "SignalSTRM1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRM1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRM1", OBJPROP_COLOR, str_col_m1);
      ObjectSetInteger(0, "SignalSTRM1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRM1", OBJPROP_XDISTANCE, gi_536 + 130);
      ObjectSetInteger(0, "SignalSTRM1", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRM5");
      ObjectCreate(0, "SignalSTRM5", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRM5", OBJPROP_TEXT, str_text_m5);
      ObjectSetString(0, "SignalSTRM5", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRM5", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRM5", OBJPROP_COLOR, str_col_m5);
      ObjectSetInteger(0, "SignalSTRM5", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRM5", OBJPROP_XDISTANCE, gi_536 + 110);
      ObjectSetInteger(0, "SignalSTRM5", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRM15");
      ObjectCreate(0, "SignalSTRM15", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRM15", OBJPROP_TEXT, str_text_m15);
      ObjectSetString(0, "SignalSTRM15", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRM15", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRM15", OBJPROP_COLOR, str_col_m15);
      ObjectSetInteger(0, "SignalSTRM15", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRM15", OBJPROP_XDISTANCE, gi_536 + 90);
      ObjectSetInteger(0, "SignalSTRM15", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRM30");
      ObjectCreate(0, "SignalSTRM30", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRM30", OBJPROP_TEXT, str_text_m30);
      ObjectSetString(0, "SignalSTRM30", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRM30", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRM30", OBJPROP_COLOR, str_col_m30);
      ObjectSetInteger(0, "SignalSTRM30", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRM30", OBJPROP_XDISTANCE, gi_536 + 70);
      ObjectSetInteger(0, "SignalSTRM30", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRH1");
      ObjectCreate(0, "SignalSTRH1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRH1", OBJPROP_TEXT, str_text_h1);
      ObjectSetString(0, "SignalSTRH1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRH1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRH1", OBJPROP_COLOR, str_col_h1);
      ObjectSetInteger(0, "SignalSTRH1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRH1", OBJPROP_XDISTANCE, gi_536 + 50);
      ObjectSetInteger(0, "SignalSTRH1", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRH4");
      ObjectCreate(0, "SignalSTRH4", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRH4", OBJPROP_TEXT, str_text_h4);
      ObjectSetString(0, "SignalSTRH4", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRH4", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRH4", OBJPROP_COLOR, str_col_h4);
      ObjectSetInteger(0, "SignalSTRH4", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRH4", OBJPROP_XDISTANCE, gi_536 + 30);
      ObjectSetInteger(0, "SignalSTRH4", OBJPROP_YDISTANCE, gi_532 + 10);
      ObjectDelete(0, "SignalSTRD1");
      ObjectCreate(0, "SignalSTRD1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalSTRD1", OBJPROP_TEXT, str_text_d1);
      ObjectSetString(0, "SignalSTRD1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalSTRD1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalSTRD1", OBJPROP_COLOR, str_col_d1);
      ObjectSetInteger(0, "SignalSTRD1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalSTRD1", OBJPROP_XDISTANCE, gi_536 + 10);
      ObjectSetInteger(0, "SignalSTRD1", OBJPROP_YDISTANCE, gi_532 + 10);
      double ema_fast_m1[];
      double ema_slow_m1[];
      double ema_fast_m5[];
      double ema_slow_m5[];
      double ema_fast_m15[];
      double ema_slow_m15[];
      double ema_fast_m30[];
      double ema_slow_m30[];
      double ema_fast_h1[];
      double ema_slow_h1[];
      double ema_fast_h4[];
      double ema_slow_h4[];
      double ema_fast_d1[];
      double ema_slow_d1[];
      CopyBuffer(handle_MA_492_1, 0, 0, 2, ema_fast_m1);
      ArraySetAsSeries(ema_fast_m1, true);
      CopyBuffer(handle_MA_492_2, 0, 0, 2, ema_slow_m1);
      ArraySetAsSeries(ema_slow_m1, true);
      CopyBuffer(handle_MA_496_1, 0, 0, 2, ema_fast_m5);
      ArraySetAsSeries(ema_fast_m5, true);
      CopyBuffer(handle_MA_496_2, 0, 0, 2, ema_slow_m5);
      ArraySetAsSeries(ema_slow_m5, true);
      CopyBuffer(handle_MA_500_1, 0, 0, 2, ema_fast_m15);
      ArraySetAsSeries(ema_fast_m15, true);
      CopyBuffer(handle_MA_500_2, 0, 0, 2, ema_slow_m15);
      ArraySetAsSeries(ema_slow_m15, true);
      CopyBuffer(handle_MA_504_1, 0, 0, 2, ema_fast_m30);
      ArraySetAsSeries(ema_fast_m30, true);
      CopyBuffer(handle_MA_504_2, 0, 0, 2, ema_slow_m30);
      ArraySetAsSeries(ema_slow_m30, true);
      CopyBuffer(handle_MA_508_1, 0, 0, 2, ema_fast_h1);
      ArraySetAsSeries(ema_fast_h1, true);
      CopyBuffer(handle_MA_508_2, 0, 0, 2, ema_slow_h1);
      ArraySetAsSeries(ema_slow_h1, true);
      CopyBuffer(handle_MA_512_1, 0, 0, 2, ema_fast_h4);
      ArraySetAsSeries(ema_fast_h4, true);
      CopyBuffer(handle_MA_512_2, 0, 0, 2, ema_slow_h4);
      ArraySetAsSeries(ema_slow_h4, true);
      CopyBuffer(handle_MA_516_1, 0, 0, 2, ema_fast_d1);
      ArraySetAsSeries(ema_fast_d1, true);
      CopyBuffer(handle_MA_516_2, 0, 0, 2, ema_slow_d1);
      ArraySetAsSeries(ema_slow_d1, true);
      string ema_text_m1 = "-";
      string ema_text_m5 = "-";
      string ema_text_m15 = "-";
      string ema_text_m30 = "-";
      string ema_text_h1 = "-";
      string ema_text_h4 = "-";
      string ema_text_d1 = "-";
      color ema_col_m1 = (color)gi_788;
      color ema_col_m5 = (color)gi_788;
      color ema_col_m15 = (color)gi_788;
      color ema_col_m30 = (color)gi_788;
      color ema_col_h1 = (color)gi_788;
      color ema_col_h4 = (color)gi_788;
      color ema_col_d1 = (color)gi_788;
      if(ema_fast_m1[0] > ema_slow_m1[0])
        {
         ema_text_m1 = "-";
         ema_col_m1 = (color)gi_784;
        }
      else
        {
         ema_text_m1 = "-";
         ema_col_m1 = (color)gi_788;
        }
      if(ema_fast_m5[0] > ema_slow_m5[0])
        {
         ema_text_m5 = "-";
         ema_col_m5 = (color)gi_784;
        }
      else
        {
         ema_text_m5 = "-";
         ema_col_m5 = (color)gi_788;
        }
      if(ema_fast_m15[0] > ema_slow_m15[0])
        {
         ema_text_m15 = "-";
         ema_col_m15 = (color)gi_784;
        }
      else
        {
         ema_text_m15 = "-";
         ema_col_m15 = (color)gi_788;
        }
      if(ema_fast_m30[0] > ema_slow_m30[0])
        {
         ema_text_m30 = "-";
         ema_col_m30 = (color)gi_784;
        }
      else
        {
         ema_text_m30 = "-";
         ema_col_m30 = (color)gi_788;
        }
      if(ema_fast_h1[0] > ema_slow_h1[0])
        {
         ema_text_h1 = "-";
         ema_col_h1 = (color)gi_784;
        }
      else
        {
         ema_text_h1 = "-";
         ema_col_h1 = (color)gi_788;
        }
      if(ema_fast_h4[0] > ema_slow_h4[0])
        {
         ema_text_h4 = "-";
         ema_col_h4 = (color)gi_784;
        }
      else
        {
         ema_text_h4 = "-";
         ema_col_h4 = (color)gi_788;
        }
      if(ema_fast_d1[0] > ema_slow_d1[0])
        {
         ema_text_d1 = "-";
         ema_col_d1 = (color)gi_784;
        }
      else
        {
         ema_text_d1 = "-";
         ema_col_d1 = (color)gi_788;
        }
      ObjectDelete(0, "SignalEMA_TEXT");
      ObjectCreate(0, "SignalEMA_TEXT", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMA_TEXT", OBJPROP_TEXT, "EMA");
      ObjectSetString(0, "SignalEMA_TEXT", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_FONTSIZE, 6);
      ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_COLOR, g_color_568);
      ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
      ObjectSetInteger(0, "SignalEMA_TEXT", OBJPROP_YDISTANCE, gi_532 + 51);
      ObjectDelete(0, "SignalEMAM1");
      ObjectCreate(0, "SignalEMAM1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAM1", OBJPROP_TEXT, ema_text_m1);
      ObjectSetString(0, "SignalEMAM1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAM1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAM1", OBJPROP_COLOR, ema_col_m1);
      ObjectSetInteger(0, "SignalEMAM1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAM1", OBJPROP_XDISTANCE, gi_536 + 130);
      ObjectSetInteger(0, "SignalEMAM1", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAM5");
      ObjectCreate(0, "SignalEMAM5", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAM5", OBJPROP_TEXT, ema_text_m5);
      ObjectSetString(0, "SignalEMAM5", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAM5", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAM5", OBJPROP_COLOR, ema_col_m5);
      ObjectSetInteger(0, "SignalEMAM5", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAM5", OBJPROP_XDISTANCE, gi_536 + 110);
      ObjectSetInteger(0, "SignalEMAM5", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAM15");
      ObjectCreate(0, "SignalEMAM15", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAM15", OBJPROP_TEXT, ema_text_m15);
      ObjectSetString(0, "SignalEMAM15", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAM15", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAM15", OBJPROP_COLOR, ema_col_m15);
      ObjectSetInteger(0, "SignalEMAM15", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAM15", OBJPROP_XDISTANCE, gi_536 + 90);
      ObjectSetInteger(0, "SignalEMAM15", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAM30");
      ObjectCreate(0, "SignalEMAM30", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAM30", OBJPROP_TEXT, ema_text_m30);
      ObjectSetString(0, "SignalEMAM30", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAM30", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAM30", OBJPROP_COLOR, ema_col_m30);
      ObjectSetInteger(0, "SignalEMAM30", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAM30", OBJPROP_XDISTANCE, gi_536 + 70);
      ObjectSetInteger(0, "SignalEMAM30", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAH1");
      ObjectCreate(0, "SignalEMAH1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAH1", OBJPROP_TEXT, ema_text_h1);
      ObjectSetString(0, "SignalEMAH1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAH1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAH1", OBJPROP_COLOR, ema_col_h1);
      ObjectSetInteger(0, "SignalEMAH1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAH1", OBJPROP_XDISTANCE, gi_536 + 50);
      ObjectSetInteger(0, "SignalEMAH1", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAH4");
      ObjectCreate(0, "SignalEMAH4", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAH4", OBJPROP_TEXT, ema_text_h4);
      ObjectSetString(0, "SignalEMAH4", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAH4", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAH4", OBJPROP_COLOR, ema_col_h4);
      ObjectSetInteger(0, "SignalEMAH4", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAH4", OBJPROP_XDISTANCE, gi_536 + 30);
      ObjectSetInteger(0, "SignalEMAH4", OBJPROP_YDISTANCE, gi_532 + 18);
      ObjectDelete(0, "SignalEMAD1");
      ObjectCreate(0, "SignalEMAD1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "SignalEMAD1", OBJPROP_TEXT, ema_text_d1);
      ObjectSetString(0, "SignalEMAD1", OBJPROP_FONT, "Tahoma Narrow");
      ObjectSetInteger(0, "SignalEMAD1", OBJPROP_FONTSIZE, 45);
      ObjectSetInteger(0, "SignalEMAD1", OBJPROP_COLOR, ema_col_d1);
      ObjectSetInteger(0, "SignalEMAD1", OBJPROP_CORNER, g_corner_528);
      ObjectSetInteger(0, "SignalEMAD1", OBJPROP_XDISTANCE, gi_536 + 10);
      ObjectSetInteger(0, "SignalEMAD1", OBJPROP_YDISTANCE, gi_532 + 18);
     }
   if(!IsTradingAllowed())
     {
      Print("Trading is not allowed at this time.");
      return;
     }
     {
      if(UseTrailingStop_Hilo)
         TrailingAlls_Hilo(TrailStart_Hilo, TrailStop_Hilo, AveragePrice_Hilo);
      if(UseTimeOut_Hilo)
        {
         if(TimeCurrent() >= (datetime)expiration_Hilo)
           {
            CloseThisSymbolAll_Hilo();
            Print("Closed All due to TimeOut - Hilo");
           }
        }
      datetime current_time = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(timeprev_Hilo == current_time)
         return;
      timeprev_Hilo = current_time;
      double CurrentPairProfit_Hilo = CalculateProfit_Hilo();
      if(UseEquityStop_Hilo)
        {
         if(CurrentPairProfit_Hilo < 0.0 && MathAbs(CurrentPairProfit_Hilo) > TotalEquityRisk_Hilo / 100.0 * AccountEquityHigh_Hilo())
           {
            CloseThisSymbolAll_Hilo();
            Print("Closed All due to Stop Out - Hilo");
            NewOrdersPlaced_Hilo = false;
           }
        }
      total_Hilo = CountTrades_Hilo();
      if(total_Hilo == 0)
         flag_Hilo = false;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
           {
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(ptype == POSITION_TYPE_BUY)
              {
               LongTrade_Hilo = true;
               ShortTrade_Hilo = false;
               break;
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               LongTrade_Hilo = false;
               ShortTrade_Hilo = true;
               break;
              }
           }
        }
      if(total_Hilo > 0 && total_Hilo <= MaxTrades_Hilo)
        {
         LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
         LastSellPrice_Hilo = FindLastSellPrice_Hilo();
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(LongTrade_Hilo && LastBuyPrice_Hilo - ask >= PipStep_Hilo * _Point)
            TradeNow_Hilo = true;
         if(ShortTrade_Hilo && bid - LastSellPrice_Hilo >= PipStep_Hilo * _Point)
            TradeNow_Hilo = true;
        }
      if(total_Hilo < 1)
        {
         ShortTrade_Hilo = false;
         LongTrade_Hilo = false;
         TradeNow_Hilo = true;
         StartEquity_Hilo = AccountInfoDouble(ACCOUNT_EQUITY);
        }
      if(TradeNow_Hilo)
        {
         LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
         LastSellPrice_Hilo = FindLastSellPrice_Hilo();
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(ShortTrade_Hilo)
           {
            NumOfTrades_Hilo = total_Hilo;
            iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
            ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, bid, (int)slip_Hilo, ask, 0, 0, EAName_Hilo + "-" + IntegerToString(NumOfTrades_Hilo), MagicNumber_Hilo, 0, clrHotPink);
            if(ticket_Hilo < 1)
              {
               Print("Error: ", GetLastError());
               return;
              }
            LastSellPrice_Hilo = FindLastSellPrice_Hilo();
            TradeNow_Hilo = false;
            NewOrdersPlaced_Hilo = true;
           }
         else
           {
            if(LongTrade_Hilo)
              {
               NumOfTrades_Hilo = total_Hilo;
               iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
               ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, ask, (int)slip_Hilo, bid, 0, 0, EAName_Hilo + "-" + IntegerToString(NumOfTrades_Hilo), MagicNumber_Hilo, 0, clrLime);
               if(ticket_Hilo < 1)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
               TradeNow_Hilo = false;
               NewOrdersPlaced_Hilo = true;
              }
           }
        }
      if(TradeNow_Hilo && total_Hilo < 1)
        {
         double high_arr[];
         double low_arr[];
         ArraySetAsSeries(high_arr, true);
         ArraySetAsSeries(low_arr, true);
         CopyHigh(_Symbol, PERIOD_CURRENT, 0, 3, high_arr);
         CopyLow(_Symbol, PERIOD_CURRENT, 0, 3, low_arr);
         double PrevCl_Hilo = high_arr[1];
         double CurrCl_Hilo = low_arr[2];
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         SellLimit_Hilo = bid;
         BuyLimit_Hilo = ask;
         if(!ShortTrade_Hilo && !LongTrade_Hilo)
           {
            NumOfTrades_Hilo = total_Hilo;
            iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
            if(!IsTradingAllowed())
              {
               Print("Trading is not allowed at this time.");
               return;
              }
            double rsi_arr[];
            ArraySetAsSeries(rsi_arr, true);
            CopyBuffer(handle_RSI_H1, 0, 0, 3, rsi_arr);
            if(PrevCl_Hilo > CurrCl_Hilo)
              {
               if(rsi_arr[1] > 30.0)
                 {
                  ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, SellLimit_Hilo, (int)slip_Hilo, SellLimit_Hilo, 0, 0, EAName_Hilo + "-" + IntegerToString(NumOfTrades_Hilo), MagicNumber_Hilo, 0, clrHotPink);
                  if(ticket_Hilo < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
                  NewOrdersPlaced_Hilo = true;
                 }
              }
            else
              {
               if(rsi_arr[1] < 70.0)
                 {
                  ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, BuyLimit_Hilo, (int)slip_Hilo, BuyLimit_Hilo, 0, 0, EAName_Hilo + "-" + IntegerToString(NumOfTrades_Hilo), MagicNumber_Hilo, 0, clrLime);
                  if(ticket_Hilo < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  LastSellPrice_Hilo = FindLastSellPrice_Hilo();
                  NewOrdersPlaced_Hilo = true;
                 }
              }
            if(ticket_Hilo > 0)
               expiration_Hilo = (datetime)(TimeCurrent() + 60 * (60 * MaxTradeOpenHours_Hilo));
            TradeNow_Hilo = false;
           }
        }
      total_Hilo = CountTrades_Hilo();
      AveragePrice_Hilo = 0;
      double Count_Hilo = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
           {
            AveragePrice_Hilo += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
            Count_Hilo += PositionGetDouble(POSITION_VOLUME);
           }
        }
      if(total_Hilo > 0)
         AveragePrice_Hilo = NormalizeDouble(AveragePrice_Hilo / Count_Hilo, _Digits);
      if(NewOrdersPlaced_Hilo)
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
               continue;
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
              {
               ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(ptype == POSITION_TYPE_BUY)
                 {
                  PriceTarget_Hilo = AveragePrice_Hilo + TakeProfit_Hilo * _Point;
                  BuyTarget_Hilo = PriceTarget_Hilo;
                  Stopper_Hilo = AveragePrice_Hilo - Stoploss_Hilo * _Point;
                  flag_Hilo = true;
                 }
               if(ptype == POSITION_TYPE_SELL)
                 {
                  PriceTarget_Hilo = AveragePrice_Hilo - TakeProfit_Hilo * _Point;
                  SellTarget_Hilo = PriceTarget_Hilo;
                  Stopper_Hilo = AveragePrice_Hilo + Stoploss_Hilo * _Point;
                  flag_Hilo = true;
                 }
              }
           }
        }
      if(NewOrdersPlaced_Hilo)
        {
         if(flag_Hilo == true)
           {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket == 0)
                  continue;
               if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != MagicNumber_Hilo)
                  continue;
               if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber_Hilo)
                 {
                  while(!trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), PriceTarget_Hilo))
                    {
                     Sleep(1000);
                    }
                  NewOrdersPlaced_Hilo = false;
                 }
              }
           }
        }
     }
     {
      LotExponent_15 = LotExponent;
      lotdecimal_15 = lotdecimal;
      TakeProfit_15 = TakeProfit;
      UseEquityStop_15 = UseEquityStop;
      TotalEquityRisk_15 = TotalEquityRisk;
      UseTrailingStop_15 = UseTrailingStop;
      TrailStart_15 = TrailStart;
      TrailStop_15 = TrailStop;
      PipStep_15 = PipStep;
      slip_15 = slip;
      if(MM == true)
        {
         if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000)
           {
            Lots_15 = WorkingLots;
           }
         else
           {
            Lots_15 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
           }
        }
      else
        {
         Lots_15 = WorkingLots;
        }
      if(!IsTradingAllowed())
        {
         Print("Trading not allowed - Ilan 1.5");
         return;
        }
      if(UseTrailingStop_15)
         TrailingAlls_15(TrailStart_15, TrailStop_15, g_price_212_15);
      if(UseTimeOut_15)
        {
         if(TimeCurrent() >= (datetime)gi_284_15)
           {
            CloseThisSymbolAll_15();
            Print("Closed All due to TimeOut - Ilan 1.5");
           }
        }
      datetime current_time_15 = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(gi_280_15 != current_time_15)
        {
         gi_280_15 = current_time_15;
         double CurrentPairProfit_15 = CalculateProfit_15();
         if(UseEquityStop_15)
           {
            if(CurrentPairProfit_15 < 0.0 && MathAbs(CurrentPairProfit_15) > TotalEquityRisk_15 / 100.0 * AccountEquityHigh_15())
              {
               CloseThisSymbolAll_15();
               Print("Closed All due to Stop Out - Ilan 1.5");
               gi_332_15 = false;
              }
           }
         gi_304_15 = CountTrades_15();
         if(gi_304_15 == 0)
            gi_268_15 = false;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
               continue;
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(ptype == POSITION_TYPE_BUY)
              {
               gi_320_15 = true;
               gi_324_15 = false;
               break;
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               gi_320_15 = false;
               gi_324_15 = true;
               break;
              }
           }
         if(gi_304_15 > 0 && gi_304_15 <= MaxTrades_15)
           {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            gd_236_15 = FindLastBuyPrice_15();
            gd_244_15 = FindLastSellPrice_15();
            if(gi_320_15 && gd_236_15 - ask >= PipStep_15 * _Point)
               gi_316_15 = true;
            if(gi_324_15 && bid - gd_244_15 >= PipStep_15 * _Point)
               gi_316_15 = true;
           }
         if(gi_304_15 < 1)
           {
            gi_324_15 = false;
            gi_320_15 = false;
            gi_316_15 = true;
            gd_188_15 = AccountInfoDouble(ACCOUNT_EQUITY);
           }
         if(gi_316_15)
           {
            gd_236_15 = FindLastBuyPrice_15();
            gd_244_15 = FindLastSellPrice_15();
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(gi_324_15)
              {
               gi_288_15 = gi_304_15;
               gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
               gi_328_15 = OpenPendingOrder_15(1, gd_292_15, bid, (int)slip_15, ask, 0, 0, gs_ilan_272_15 + "-" + IntegerToString(gi_288_15), g_magic_176_15, 0, clrHotPink);
               if(gi_328_15 < 1)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_244_15 = FindLastSellPrice_15();
               gi_316_15 = false;
               gi_332_15 = true;
              }
            else
              {
               if(gi_320_15)
                 {
                  gi_288_15 = gi_304_15;
                  gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
                  gi_328_15 = OpenPendingOrder_15(0, gd_292_15, ask, (int)slip_15, bid, 0, 0, gs_ilan_272_15 + "-" + IntegerToString(gi_288_15), g_magic_176_15, 0, clrLime);
                  if(gi_328_15 < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  gd_236_15 = FindLastBuyPrice_15();
                  gi_316_15 = false;
                  gi_332_15 = true;
                 }
              }
           }
        }
      datetime time_check_15 = iTime(_Symbol, PERIOD_H1, 0);
      if(time_15 != time_check_15)
        {
         int totals_15 = PositionsTotal();
         int orders_15 = 0;
         for(int i = 0; i < totals_15; i++)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_15)
              {
               orders_15++;
              }
           }
         if(totals_15 == 0 || orders_15 < 1)
           {
            double close_arr[];
            if(CopyClose(_Symbol, PERIOD_CURRENT, 1, 2, close_arr) < 2)
               return;
            ArraySetAsSeries(close_arr, true);
            double l_iclose_8 = close_arr[1];
            double l_iclose_16 = close_arr[0];
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            g_bid_220_15 = bid;
            g_ask_228_15 = ask;
            gi_288_15 = gi_304_15;
            gd_292_15 = Lots_15;
            if(l_iclose_8 > l_iclose_16)
              {
               gi_328_15 = OpenPendingOrder_15(1, gd_292_15, g_bid_220_15, (int)slip_15, g_bid_220_15, 0, 0, gs_ilan_272_15 + "-" + IntegerToString(gi_288_15), g_magic_176_15, 0, clrHotPink);
               if(gi_328_15 < 1)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_236_15 = FindLastBuyPrice_15();
               gi_332_15 = true;
              }
            else
              {
               gi_328_15 = OpenPendingOrder_15(0, gd_292_15, g_ask_228_15, (int)slip_15, g_ask_228_15, 0, 0, gs_ilan_272_15 + "-" + IntegerToString(gi_288_15), g_magic_176_15, 0, clrLime);
               if(gi_328_15 < 1)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_244_15 = FindLastSellPrice_15();
               gi_332_15 = true;
              }
            if(gi_328_15 > 0)
               gi_284_15 = (long)(TimeCurrent() + 60 * (60 * MaxTradeOpenHours_15));
            gi_316_15 = false;
           }
         time_15 = time_check_15;
        }
      gi_304_15 = CountTrades_15();
      g_price_212_15 = 0;
      double Count_15 = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
            continue;
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY || ptype == POSITION_TYPE_SELL)
           {
            g_price_212_15 += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
            Count_15 += PositionGetDouble(POSITION_VOLUME);
           }
        }
      if(gi_304_15 > 0)
         g_price_212_15 = NormalizeDouble(g_price_212_15 / Count_15, _Digits);
      if(gi_332_15)
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
               continue;
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(ptype == POSITION_TYPE_BUY)
              {
               g_price_180_15 = g_price_212_15 + TakeProfit_15 * _Point;
               gd_unused_196_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 - Stoploss_15 * _Point;
               gi_268_15 = true;
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               g_price_180_15 = g_price_212_15 - TakeProfit_15 * _Point;
               gd_unused_204_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 + Stoploss_15 * _Point;
               gi_268_15 = true;
              }
           }
        }
      if(gi_332_15)
        {
         if(gi_268_15 == true)
           {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket == 0)
                  continue;
               if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_15)
                  continue;
               while(!trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), g_price_180_15))
                 {
                  Sleep(1000);
                 }
               gi_332_15 = false;
              }
           }
        }
     }
     {
      LotExponent_16 = LotExponent;
      lotdecimal_16 = lotdecimal;
      TakeProfit_16 = TakeProfit;
      UseEquityStop_16 = UseEquityStop;
      TotalEquityRisk_16 = TotalEquityRisk;
      UseTrailingStop_16 = UseTrailingStop;
      TrailStart_16 = TrailStart;
      TrailStop_16 = TrailStop;
      PipStep_16 = PipStep;
      slip_16 = slip;
      if(MM == true)
        {
         if(MathCeil(AccountInfoDouble(ACCOUNT_BALANCE)) < 200000)
           {
            Lots_16 = WorkingLots;
           }
         else
           {
            Lots_16 = 0.00001 * MathCeil(AccountInfoDouble(ACCOUNT_BALANCE));
           }
        }
      else
        {
         Lots_16 = WorkingLots;
        }
      if(!IsTradingAllowed())
        {
         Print("Trading not allowed - Ilan 1.6");
         return;
        }
      if(UseTrailingStop_16)
         TrailingAlls_16(TrailStart_16, TrailStop_16, g_price_212_16);
      if(UseTimeOut_16)
        {
         if(TimeCurrent() >= (datetime)gi_284_16)
           {
            CloseThisSymbolAll_16();
            Print("Closed All due to TimeOut - Ilan 1.6");
           }
        }
      datetime current_time_16 = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(gi_280_16 != current_time_16)
        {
         gi_280_16 = current_time_16;
         double CurrentPairProfit_16 = CalculateProfit_16();
         if(UseEquityStop_16)
           {
            if(CurrentPairProfit_16 < 0.0 && MathAbs(CurrentPairProfit_16) > TotalEquityRisk_16 / 100.0 * AccountEquityHigh_16())
              {
               CloseThisSymbolAll_16();
               Print("Closed All due to Stop Out - Ilan 1.6");
               gi_332_16 = false;
              }
           }
         gi_304_16 = CountTrades_16();
         if(gi_304_16 == 0)
            gi_268_16 = false;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
               continue;
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(ptype == POSITION_TYPE_BUY)
              {
               gi_320_16 = true;
               gi_324_16 = false;
               break;
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               gi_320_16 = false;
               gi_324_16 = true;
               break;
              }
           }
         if(gi_304_16 > 0 && gi_304_16 <= MaxTrades_16)
           {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            gd_236_16 = FindLastBuyPrice_16();
            gd_244_16 = FindLastSellPrice_16();
            if(gi_320_16 && gd_236_16 - ask >= PipStep_16 * _Point)
               gi_316_16 = true;
            if(gi_324_16 && bid - gd_244_16 >= PipStep_16 * _Point)
               gi_316_16 = true;
           }
         if(gi_304_16 < 1)
           {
            gi_324_16 = false;
            gi_320_16 = false;
            gd_188_16 = AccountInfoDouble(ACCOUNT_EQUITY);
           }
         if(gi_316_16)
           {
            gd_236_16 = FindLastBuyPrice_16();
            gd_244_16 = FindLastSellPrice_16();
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(gi_324_16)
              {
               gi_288_16 = gi_304_16;
               gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
               gi_328_16 = OpenPendingOrder_16(1, gd_292_16, bid, (int)slip_16, ask, 0, 0, gs_ilan_272_16 + "-" + IntegerToString(gi_288_16), g_magic_176_16, 0, clrHotPink);
               if(gi_328_16 < 1)
                 {
                  Print("Error: ", GetLastError());
                  return;
                 }
               gd_244_16 = FindLastSellPrice_16();
               gi_316_16 = false;
               gi_332_16 = true;
              }
            else
              {
               if(gi_320_16)
                 {
                  gi_288_16 = gi_304_16;
                  gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
                  gi_328_16 = OpenPendingOrder_16(0, gd_292_16, ask, (int)slip_16, bid, 0, 0, gs_ilan_272_16 + "-" + IntegerToString(gi_288_16), g_magic_176_16, 0, clrLime);
                  if(gi_328_16 < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  gd_236_16 = FindLastBuyPrice_16();
                  gi_316_16 = false;
                  gi_332_16 = true;
                 }
              }
           }
        }
      datetime time_check_16 = iTime(_Symbol, PERIOD_H1, 0);
      if(time_16 != time_check_16)
        {
         int totals_16 = PositionsTotal();
         int orders_16 = 0;
         for(int i = 0; i < totals_16; i++)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == g_magic_176_16)
              {
               orders_16++;
              }
           }
         if(totals_16 == 0 || orders_16 < 1)
           {
            double close_arr[];
            if(CopyClose(_Symbol, PERIOD_CURRENT, 1, 2, close_arr) < 2)
               return;
            ArraySetAsSeries(close_arr, true);
            double l_iclose_8_16 = close_arr[1];
            double l_iclose_16_16 = close_arr[0];
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            g_bid_220_16 = bid;
            g_ask_228_16 = ask;
            gi_288_16 = gi_304_16;
            gd_292_16 = Lots_16;
            double rsi_arr[];
            if(CopyBuffer(handle_RSI_H1, 0, 0, 2, rsi_arr) < 2)
               return;
            ArraySetAsSeries(rsi_arr, true);
            if(l_iclose_8_16 > l_iclose_16_16)
              {
               if(rsi_arr[1] > 30.0)
                 {
                  gi_328_16 = OpenPendingOrder_16(1, gd_292_16, g_bid_220_16, (int)slip_16, g_bid_220_16, 0, 0, gs_ilan_272_16 + "-" + IntegerToString(gi_288_16), g_magic_176_16, 0, clrHotPink);
                  if(gi_328_16 < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  gd_236_16 = FindLastBuyPrice_16();
                  gi_332_16 = true;
                 }
              }
            else
              {
               if(rsi_arr[1] < 70.0)
                 {
                  gi_328_16 = OpenPendingOrder_16(0, gd_292_16, g_ask_228_16, (int)slip_16, g_ask_228_16, 0, 0, gs_ilan_272_16 + "-" + IntegerToString(gi_288_16), g_magic_176_16, 0, clrLime);
                  if(gi_328_16 < 1)
                    {
                     Print("Error: ", GetLastError());
                     return;
                    }
                  gd_244_16 = FindLastSellPrice_16();
                  gi_332_16 = true;
                 }
              }
            if(gi_328_16 > 0)
               gi_284_16 = (long)(TimeCurrent() + 60 * (60 * MaxTradeOpenHours_16));
            gi_316_16 = false;
           }
         time_16 = time_check_16;
        }
      gi_304_16 = CountTrades_16();
      g_price_212_16 = 0;
      double Count_16 = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
            continue;
         ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(ptype == POSITION_TYPE_BUY || ptype == POSITION_TYPE_SELL)
           {
            g_price_212_16 += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
            Count_16 += PositionGetDouble(POSITION_VOLUME);
           }
        }
      if(gi_304_16 > 0)
         g_price_212_16 = NormalizeDouble(g_price_212_16 / Count_16, _Digits);
      if(gi_332_16)
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0)
               continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
               continue;
            ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(ptype == POSITION_TYPE_BUY)
              {
               g_price_180_16 = g_price_212_16 + TakeProfit_16 * _Point;
               gd_unused_196_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 - Stoploss_16 * _Point;
               gi_268_16 = true;
              }
            if(ptype == POSITION_TYPE_SELL)
              {
               g_price_180_16 = g_price_212_16 - TakeProfit_16 * _Point;
               gd_unused_204_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 + Stoploss_16 * _Point;
               gi_268_16 = true;
              }
           }
        }
      if(gi_332_16)
        {
         if(gi_268_16 == true)
           {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket == 0)
                  continue;
               if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != g_magic_176_16)
                  continue;
               while(!trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), g_price_180_16))
                 {
                  Sleep(1000);
                 }
               gi_332_16 = false;
              }
           }
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        TradeSurge_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=158841#p158841
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
