/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76300
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
// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict

input int      MA_Period = 20;                    // MA Period
input ENUM_MA_METHOD MA_Method = MODE_SMA;        // MA Method
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE;  // MA Applied Price
input double   Lot_Size = 0.01;                   // Lot Size
input string   Comment = "MA_MTF_EA";             // Comment
input int      Magic_Number = 12345;              // Magic Number
input bool     Close_On_Out_Trend = true;         // Close On Out Trend
input bool     Close_On_Opposite = true;          // Close On Opposite

input bool     Use_M1 = false;                    // Use M1
input bool     Use_M5 = true;                     // Use M5
input bool     Use_M15 = true;                    // Use M15
input bool     Use_M30 = true;                    // Use M30
input bool     Use_H1 = true;                     // Use H1
input bool     Use_H4 = true;                     // Use H4
input bool     Use_D1 = true;                     // Use D1
input bool     Use_W1 = false;                    // Use W1
input bool     Use_MN1 = false;                   // Use MN1

int timeframes[9] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
bool use_timeframes[9];
string tf_names[9] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};

int OnInit()
{
    use_timeframes[0] = Use_M1;
    use_timeframes[1] = Use_M5;
    use_timeframes[2] = Use_M15;
    use_timeframes[3] = Use_M30;
    use_timeframes[4] = Use_H1;
    use_timeframes[5] = Use_H4;
    use_timeframes[6] = Use_D1;
    use_timeframes[7] = Use_W1;
    use_timeframes[8] = Use_MN1;
    
    Print("MA Multi-Timeframe EA initialized successfully");
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    Print("MA Multi-Timeframe EA deinitialized");
}

void OnTick()
{
    static datetime last_bar_time = 0;
    if(Time[0] == last_bar_time)
        return;
    last_bar_time = Time[0];
    
    int bullish_count = 0;
    int bearish_count = 0;
    int active_timeframes = 0;
    
    for(int i = 0; i < 9; i++)
    {
        if(use_timeframes[i])
        {
            double ma_value = iMA(Symbol(), timeframes[i], MA_Period, 0, MA_Method, MA_Price, 0);
            double current_price = iClose(Symbol(), timeframes[i], 0);
            
            if(current_price > ma_value)
            {
                bullish_count++;
            }
            else if(current_price < ma_value)
            {
                bearish_count++;
            }
            
            active_timeframes++;
        }
    }
    
    bool all_bullish = (bullish_count == active_timeframes && active_timeframes > 0);
    bool all_bearish = (bearish_count == active_timeframes && active_timeframes > 0);
    
    if(Close_On_Out_Trend || Close_On_Opposite)
    {
        ClosePositions(all_bullish, all_bearish);
    }
    
    if(all_bullish && !HasBuyPosition())
    {
        OpenBuyOrder();
    }
    else if(all_bearish && !HasSellPosition())
    {
        OpenSellOrder();
    }
}

bool HasBuyPosition()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number && OrderType() == OP_BUY)
            {
                return true;
            }
        }
    }
    return false;
}

bool HasSellPosition()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number && OrderType() == OP_SELL)
            {
                return true;
            }
        }
    }
    return false;
}

void ClosePositions(bool all_bullish, bool all_bearish)
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
            {
                bool should_close = false;
                
                if(Close_On_Opposite)
                {
                    if(OrderType() == OP_BUY && all_bearish)
                        should_close = true;
                    else if(OrderType() == OP_SELL && all_bullish)
                        should_close = true;
                }
                
                if(Close_On_Out_Trend && !should_close)
                {
                    if(OrderType() == OP_BUY && !all_bullish)
                        should_close = true;
                    else if(OrderType() == OP_SELL && !all_bearish)
                        should_close = true;
                }
                
                if(should_close)
                {
                    if(OrderType() == OP_BUY)
                    {
                        if(OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed))
                        {
                            Print("Buy position closed: ", OrderTicket());
                        }
                    }
                    else if(OrderType() == OP_SELL)
                    {
                        if(OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed))
                        {
                            Print("Sell position closed: ", OrderTicket());
                        }
                    }
                }
            }
        }
    }
}

void OpenBuyOrder()
{
    double price = Ask;
    double sl = 0;
    double tp = 0;
    
    int ticket = OrderSend(Symbol(), OP_BUY, Lot_Size, price, 3, sl, tp, Comment, Magic_Number, 0, clrBlue);
    
    if(ticket > 0)
    {
        Print("Buy order opened: ", ticket, " at ", price);
    }
    else
    {
        Print("Error opening buy order: ", GetLastError());
    }
}

void OpenSellOrder()
{
    double price = Bid;
    double sl = 0;
    double tp = 0;
    
    int ticket = OrderSend(Symbol(), OP_SELL, Lot_Size, price, 3, sl, tp, Comment, Magic_Number, 0, clrRed);
    
    if(ticket > 0)
    {
        Print("Sell order opened: ", ticket, " at ", price);
    }
    else
    {
        Print("Error opening sell order: ", GetLastError());
    }
}

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76300
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
