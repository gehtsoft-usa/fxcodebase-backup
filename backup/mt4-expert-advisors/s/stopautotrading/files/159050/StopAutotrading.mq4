// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75864

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#include <WinUser32.mqh>

#import "user32.dll"
int GetAncestor(int, int);
#define MT4_WMCMD_EXPERTS 33020
#import

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
input timeZone TimeZone      = local;
input double off_by_equity         = 0;      // Turn OFF AutoTrading by Equity Amount(0 = off):
double off_by_percent        = 0;      // Turn OFF AutoTrading by Equity Percent (0 = off):
double off_by_margin         = 0;      // Turn OFF AutoTrading by Margin (0 = off):
double off_by_margin_percent = 0;      // Turn OFF AutoTrading by Margin Percent (0 = off):

input bool CloseAll = true;                              // Close all positions before Turn off
input bool deletePendingOnCloseAll = true;               // Delete pendings when close all
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

   //............................
   
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
   int main = GetAncestor(WindowHandle(Symbol(), Period()), 2);
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeOFF()
  {
   int main = GetAncestor(WindowHandle(Symbol(), Period()), 2);
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
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
      if(StringGetChar(times[i], 0) == 48 || StringGetChar(times[i], 0) == 49 || StringGetChar(times[i], 0) == 50)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 1) >= 48 && StringGetChar(times[i], 1) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 2) == 58)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 3) >= 48 && StringGetChar(times[i], 3) <= 53)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 4) >= 48 && StringGetChar(times[i], 4) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 5) == 45)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 6) == 48 || StringGetChar(times[i], 6) == 49 || StringGetChar(times[i], 6) == 50)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 7) >= 48 && StringGetChar(times[i], 7) <= 57)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 8) == 58)
         paramsOK = true;
      else
         return false;
      if(StringGetChar(times[i], 9) >= 48 && StringGetChar(times[i], 9) <= 53)
         paramsOK = true;
      else
         if(StringGetChar(times[i], 10) >= 48 && StringGetChar(times[i], 10) <= 57)
            paramsOK = true;
         else
            return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
string EAName = "Account Protector: ";
void closeAll(int dir = 0, string sym = "")
  {
   int succ;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == ""))
        {
         if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
           {
            succ = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 1000, 0);
            if(succ < 0)
              {
               Alert(EAName + ": OrderClose on " + sym + " failed with error #", GetLastError());
              }
           }
        }
     }
   if(deletePendingOnCloseAll)
      closeAllPending(dir, sym);
  }
//+------------------------------------------------------------------+
void closeAllPending(int dir, string sym)
  {
   int succ;
   string commentPart = "";
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      RefreshRates();
      ResetLastError();
      if(dir == 0 ||
         (dir == 1 && (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)) ||
         (dir == 2 && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)))
        {
         succ = OrderDelete(OrderTicket(), 0);
         if(succ < 0)
           {
            Alert(EAName + ": OrderDelete on " + sym + " failed with error #", GetLastError());
           }
        }
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75864

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 