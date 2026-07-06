// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74981

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
#property strict
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

void OnStart(){
     ToggleAutotrading();
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