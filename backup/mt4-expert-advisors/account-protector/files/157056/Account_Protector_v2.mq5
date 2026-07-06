// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=156911#p156911

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MT_WMCMD_EXPERTS   32851
#define WM_COMMAND 0x0111
#define GA_ROOT    2
#include <WinAPI\winapi.mqh>

#include <Trade\Trade.mqh>
CTrade Trade;

bool paramsOK = true;

input string Note1 = "Remember to have the DLL's allowed";
input bool off_by_timer = true;                      // Turn OFF AutoTrading by Equity Amount(0 = off):
input string Note5 = "Accept this format: 02:14-02:19,10:15-10:30,17:40-17:41";
input string Note6 = "or leave empty to trade whole day";
input string Monday = "";
input string Tuesday = "";
input string Wednesday = "";
input string Thursday = "";
input string Friday = "";
input string Saturday = "";
input string Sunday = "";
enum timeZone
  {
   local,  // Local time
   server  // Server time

  };
input timeZone TimeZone = local;
input double off_by_equity  = 0;                         // Turn OFF AutoTrading by Equity Amount(0 = off):
input double off_by_percent = 0;                         // Turn OFF AutoTrading by Percent (0 = off):
input double off_by_margin = 0;                           // Turn OFF AutoTrading by Margin (0 = off):
input double off_by_margin_percent = 0;                   // Turn OFF AutoTrading by Margin Percent (0 = off):
input bool CloseAll = true;                              // Close all positions before Turn off
input bool deletePendingOnCloseAll = true;               // Delete pendings when close all

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input ENUM_ORDER_TYPE_FILLING OrderFill = 1; // Order filling mode (change if "Unsupported filling mode" error)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!checkInput(Monday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Monday");
      paramsOK = false;
     }
   if(!checkInput(Tuesday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Tuesday");
      paramsOK = false;
     }
   if(!checkInput(Wednesday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Wednesday");
      paramsOK = false;
     }
   if(!checkInput(Thursday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Thursday");
      paramsOK = false;
     }
   if(!checkInput(Friday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Friday");
      paramsOK = false;
     }
   if(!checkInput(Saturday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Saturday");
      paramsOK = false;
     }
   if(!checkInput(Sunday))
     {
      Alert("AutoTradind Scheduler: Wrong Input Parameters on Sunday");
      paramsOK = false;
     }
   EventSetTimer(1);
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayOfWeek()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowHandle(string symbol, int tf)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   long currChart, prevChart = ChartFirst();
   int i = 0, limit = 100;
   while(i < limit)
     {
      currChart = ChartNext(prevChart);
      if(currChart < 0)
         break;
      if(ChartSymbol(currChart) == symbol
         && ChartPeriod(currChart) == timeframe)
         return((int)currChart);
      prevChart = currChart;
      i++;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   if(!paramsOK)
      return;
   datetime curTime = 0;
   bool allow = false;
   if(TimeZone == local)
      curTime = TimeLocal();
   if(TimeZone == server)
      curTime = TimeCurrent();
   if(DayOfWeek() == 0)
      allow = checkTime(Sunday, curTime);
   if(DayOfWeek() == 1)
      allow = checkTime(Monday, curTime);
   if(DayOfWeek() == 2)
      allow = checkTime(Tuesday, curTime);
   if(DayOfWeek() == 3)
      allow = checkTime(Wednesday, curTime);
   if(DayOfWeek() == 4)
      allow = checkTime(Thursday, curTime);
   if(DayOfWeek() == 5)
      allow = checkTime(Friday, curTime);
   if(DayOfWeek() == 6)
      allow = checkTime(Saturday, curTime);
//
   if(allow)
     {
      tradeON();
     }
   else
     {
     if(CloseAll)
         closeAll();
      tradeOFF();
      
     }
//
   if(off_by_percent > 0)
     {
      double cur_percent = (AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
      if(cur_percent >= off_by_percent)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   if(off_by_percent < 0)
     {
      double cur_percent = (AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
      if(cur_percent <= off_by_percent)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   if(off_by_equity > 0)
     {
      double cur_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(cur_equity >= off_by_equity)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   if(off_by_equity < 0)
     {
      double cur_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(cur_equity <= off_by_equity)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }

   
   if(off_by_margin > 0)
     {
      double cur_margin = AccountInfoDouble(ACCOUNT_MARGIN);
      if(cur_margin >= off_by_margin)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   if(off_by_margin < 0)
     {
      double cur_margin = AccountInfoDouble(ACCOUNT_MARGIN);
      if(cur_margin <= off_by_margin)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   
   if(off_by_margin_percent > 0)     
   {
      double cur_margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      Print("line: ",__LINE__," cur_margin_level: ",cur_margin_level);      
      if(cur_margin_level >= off_by_margin_percent)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }
   if(off_by_margin_percent < 0)
     {
      double cur_margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      Print("line: ",__LINE__," cur_margin_level: ",cur_margin_level);      
      if(cur_margin_level <= off_by_margin_percent)
        {
         if(CloseAll)
            closeAll();
         tradeOFF();
        }
     }



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkTime(string inp, datetime curTime)
  {
   if(inp == "")
      return true;
   string times[], sfTime[];
   StringSplit(inp, 44, times);
   int count = ArraySize(times);
   for(int i = 0; i < count; i++)
     {
      StringSplit(times[i], 45, sfTime);
      datetime s_time = StringToTime(TimeToString(curTime, TIME_DATE) + " " + sfTime[0]);
      datetime f_time = StringToTime(TimeToString(curTime, TIME_DATE) + " " + sfTime[1]);
      if(curTime >=  s_time && curTime < f_time)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeON()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      HANDLE hChart = (HANDLE) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE);
      PostMessageW(GetAncestor(hChart, GA_ROOT), WM_COMMAND, MT_WMCMD_EXPERTS, 0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeOFF()
  {
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      HANDLE hChart = (HANDLE) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE);
      PostMessageW(GetAncestor(hChart, GA_ROOT), WM_COMMAND, MT_WMCMD_EXPERTS, 0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkInput(string inp)
  {
   if(inp == "")
      return true;
   string times[];
   StringSplit(inp, 44, times);
   int count = ArraySize(times);
   int length = StringLen(inp);
//
   for(int i = 0; i < count; i++)
     {
      if(StringLen(times[i]) > 11)
         return false;
      if(StringGetCharacter(times[i], 0) == 48 || StringGetCharacter(times[i], 0) == 49 || StringGetCharacter(times[i], 0) == 50)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 1) >= 48 && StringGetCharacter(times[i], 1) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 2) == 58)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 3) >= 48 && StringGetCharacter(times[i], 3) <= 53)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 4) >= 48 && StringGetCharacter(times[i], 4) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 5) == 45)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 6) == 48 || StringGetCharacter(times[i], 6) == 49 || StringGetCharacter(times[i], 6) == 50)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 7) >= 48 && StringGetCharacter(times[i], 7) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 8) == 58)
         paramsOK = true;
      else
         return false;
      if(StringGetCharacter(times[i], 9) >= 48 && StringGetCharacter(times[i], 9) <= 53)
         paramsOK = true;
      else
         if(StringGetCharacter(times[i], 10) >= 48 && StringGetCharacter(times[i], 10) <= 57)
            paramsOK = true;
         else
            return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
void closeAll(int dir = 0, string sym = "")
  {
   for(int pos = PositionsTotal(); pos >= 0; pos--)
     {
      ulong tk = PositionGetTicket(pos);
      Trade.PositionClose(tk, 10000);
     }
   if(deletePendingOnCloseAll)
      closeAllPending(dir, sym);
  }
//+------------------------------------------------------------------+
void closeAllPending(int dir = 0, string sym = "")
  {
   for(int pos = OrdersTotal(); pos >= 0; pos--)
     {
      ulong tk = OrderGetTicket(pos);
      Trade.OrderDelete(tk);
     }
  }
//+------------------------------------------------------------------+
