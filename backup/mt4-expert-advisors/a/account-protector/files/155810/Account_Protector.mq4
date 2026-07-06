// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74983

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
#property version "1.0"
#property description "Expert Advisor"
#property strict

input string note           = "Remember to have the DLL's allowed";
input string tbytimer       = "== On/Off by Timer ==";   // ————————————————————————
input bool   useStart       = true;                      // Use Start time:
input string ustart_time    = "00:00";                   // Start Time:
input bool   useStop        = true;                      // Use Stop time:
input string ustop_time     = "23:59";                   // Stop Time:
input string tbyresuts      = "== On/Off by Results =="; // ————————————————————————
input double off_by_equity  = 0;                         // Disable by Equity Amount(0 = off):
input double off_by_percent = 0;                         // Disable by Percent (0 = off):

MqlDateTime start_tm;
MqlDateTime stop_tm;

#define Section_Autotrading
#ifdef Section_Autotrading

#include <WinUser32.mqh>

#import "user32.dll"
int GetAncestor(int, int);
#define MT4_WMCMD_EXPERTS 33020
#import

void ToggleAutotrading()
{
    int main = GetAncestor(WindowHandle(Symbol(), Period()), 2);
    if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
        return;
    }
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
        return;
    }
}
void AutotradingOff()
{
    int main = GetAncestor(WindowHandle(Symbol(), Period()), 2);
    if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
    }
}
void AutotradingOn()
{
    int main = GetAncestor(WindowHandle(Symbol(), Period()), 2);
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
    }
}

#endif

int OnInit()
{
    TimeToStruct(TimeLocal(), start_tm);
    int start_hh  = (int)StringSubstr(ustart_time, 0, 2);
    int start_mm  = (int)StringSubstr(ustart_time, 3, 2);
    start_tm.hour = start_hh;
    start_tm.min  = start_mm;
    start_tm.sec  = 00;

    TimeToStruct(TimeLocal(), stop_tm);
    int stop_hh  = (int)StringSubstr(ustop_time, 0, 2);
    int stop_mm  = (int)StringSubstr(ustop_time, 3, 2);
    stop_tm.hour = stop_hh;
    stop_tm.min  = stop_mm;
    stop_tm.sec  = 00;

    EventSetTimer(1);
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
void OnTick() {}
void OnTimer(void)
{
    if (useStart)
        if (TimeLocal() >= StructToTime(start_tm) && TimeLocal() - 1 < StructToTime(start_tm)) {
            AutotradingOn();
        }

    if (useStop)
        if (TimeLocal() >= StructToTime(stop_tm) && TimeLocal() - 1 < StructToTime(stop_tm)) {
            AutotradingOff();
        }

    if (off_by_percent > 0) {
        double cur_percent = (AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
        if (cur_percent >= off_by_percent) {
            AutotradingOff();
        }
    }
    if (off_by_percent < 0) {
        double cur_percent = (AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
        if (cur_percent <= off_by_percent) {
            AutotradingOff();
        }
    }
    if (off_by_equity > 0) {
        double cur_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        if (cur_equity >= off_by_equity) {
            AutotradingOff();
        }
    }
    if (off_by_equity < 0) {
        double cur_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        if (cur_equity <= off_by_equity) {
            AutotradingOff();
        }
    }
}

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