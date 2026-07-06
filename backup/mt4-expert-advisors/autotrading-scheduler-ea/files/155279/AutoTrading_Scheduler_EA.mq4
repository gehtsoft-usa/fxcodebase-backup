// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74851

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#import "user32.dll"
void keybd_event(int bVk, int bScan, int dwFlags, int dwExtraInfo);
#import
#define  REL  0x0002
#define  CTRL 0x11
#define  E    0x45
enum timeZone
  {
   local,  // Local time
   server  // Server time

  };
bool paramsOK = true;
input string Note1 = "MT4 doesn't able to enable/disable auto trading from EA.";
input string Note2 = "This EA only send a CTRL+E keystroke";
input string Note3 = "that's why the MT4 window must be the active window so";
input string Note4 = "this EA doesn't work if the MT4 window is in the background";
input string Note5 = "Accept this format: 02:14-02:19,10:15-10:30,17:40-17:41";
input string Note6 = "or leave empty to trade whole day";
input string Monday = "";
input string Tuesday = "";
input string Wednesday = "";
input string Thursday = "";
input string Friday = "";
input string Saturday = "";
input string Sunday = "";
input timeZone TimeZone = local;
input bool CloseAll = true;
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
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
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
      tradeOFF();
      if(CloseAll)
         closeAll();
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
void stroke()
  {
   keybd_event(CTRL, 0, 0,  0);
   keybd_event(E,   0, 0,  0);
   keybd_event(CTRL, 0, REL, 0);
   keybd_event(E,   0, REL, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeON()
  {
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 0)
      stroke();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeOFF()
  {
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 1)
      stroke();
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
void closeAll(int dir = 0, string sym = "")
  {
   int succ;
   string EAName = "AutoTrading Scheduler: ";
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
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 