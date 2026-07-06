//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76323
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

extern int forced_tf = 0;
extern bool use_narrow_bands = false;
extern bool kill_retouch = true;
extern color TopColor = DarkSlateGray;
extern color BotColor = DarkSlateGray;
extern color Price_mark = Black;
extern int Price_Width = 1;

string custom_indicator = "SupDemV2";

#define CUSTOM_INDICATOR_PARAMS forced_tf,use_narrow_bands,kill_retouch

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   double none = iCustom(Symbol(), PERIOD_CURRENT, custom_indicator, CUSTOM_INDICATOR_PARAMS, 0, 1);
   ChartRedraw();
   ChartSetSymbolPeriod(0, Symbol(), PERIOD_CURRENT);
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(ObjectGetInteger(0, name, OBJPROP_TYPE) == OBJ_RECTANGLE && StringFind(name, "II_SupDem5") != -1)
        {
         double top_price = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
         double bottom_price = ObjectGetDouble(0, name, OBJPROP_PRICE, 1);
         // Ensure top_price is always the higher value
         if(top_price < bottom_price)
           {
            double temp = top_price;
            top_price = bottom_price;
            bottom_price = temp;
           }
         double current_open = iOpen(Symbol(), 0, 0);
         double current_close = iClose(Symbol(), 0, 0);
         double prev_close = iClose(Symbol(), 0, 1);
         bool open_inside = (current_open > bottom_price && current_open < top_price);
         bool prev_close_inside = (prev_close > bottom_price && prev_close < top_price);
         // Buy condition: Close breaks above the rectangle
         if(current_close > top_price && (open_inside || prev_close_inside))
           {
            // Place Buy Order Logic Here
            // Example: OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Buy", 123, 0, Green);
           }
         // Sell condition: Close breaks below the rectangle
         if(current_close < bottom_price && (open_inside || prev_close_inside))
           {
            // Place Sell Order Logic Here
            // Example: OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Sell", 124, 0, Red);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76323
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//FOOTER:END
 