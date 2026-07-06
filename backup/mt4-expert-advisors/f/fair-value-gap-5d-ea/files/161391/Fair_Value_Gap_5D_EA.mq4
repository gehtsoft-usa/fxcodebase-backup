//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76478
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
PayPal:      https://paypal.me/mariojemic
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
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict

input string grp_tf = "=== Timeframes ===";
input bool   UseM5  = true;   // Use M5
input bool   UseM15 = true;   // Use M15
input bool   UseH1  = true;   // Use H1
input bool   UseH4  = true;   // Use H4

input string grp_fvg = "=== FVG Settings ===";
input double InpThresholdPer = 0.0;  // Threshold %
input bool   InpAuto = false;         // Auto Threshold
input int    InpExtend = 20;          // Extend Bars

input string grp_trade = "=== Trade Settings ===";
input double InpLotSize = 0.01;      // Lot Size
input int    InpTP = 500;             // Take Profit (points)
input int    InpSL = 300;             // Stop Loss (points)
input int    InpMagic = 123456;       // Magic Number
input string InpComment = "FVG_EA";   // Trade Comment
input int    InpDelayBars = 0;        // Delay Bars (wait N bars before looking for entry)

input string grp_manage = "=== Trade Management ===";
input bool   InpTrailingStop = true;  // Trailing Stop
input int    InpTrailingStep = 50;     // Trailing Step (points)
input int    InpTrailingStart = 100;   // Trailing Start (points)
input bool   InpBreakEven = true;     // Break Even
input int    InpBreakEvenAt = 100;    // Break Even At (points)
input int    InpBreakEvenPlus = 20;   // Break Even Plus (points)
input bool   TradeAfterExit = false; // Trade after exit zone (true) or touch inside zone (false)

struct FVGZone {
   datetime time;
   double top;
   double bottom;
   bool isBull;
   bool mitigated;
   bool traded;
   int tf;
};

FVGZone fvgZones[];
int tfArray[];

datetime gStartTime;

int OnInit()
{
   ArrayResize(tfArray, 0);
   if(UseM5)  { ArrayResize(tfArray, ArraySize(tfArray)+1); tfArray[ArraySize(tfArray)-1] = PERIOD_M5; }
   if(UseM15) { ArrayResize(tfArray, ArraySize(tfArray)+1); tfArray[ArraySize(tfArray)-1] = PERIOD_M15; }
   if(UseH1)  { ArrayResize(tfArray, ArraySize(tfArray)+1); tfArray[ArraySize(tfArray)-1] = PERIOD_H1; }
   if(UseH4)  { ArrayResize(tfArray, ArraySize(tfArray)+1); tfArray[ArraySize(tfArray)-1] = PERIOD_H4; }
   
   if(ArraySize(tfArray) == 0) {
      Print("ERROR: No timeframe selected!");
      return(INIT_FAILED);
   }
   
   ArrayResize(fvgZones, 0);
   gStartTime = TimeCurrent();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick()
{
   CheckFVGZones();
   ManageTrades();
   CheckTradeOpportunity();
}

void CheckFVGZones()
{
   for(int tf_idx = 0; tf_idx < ArraySize(tfArray); tf_idx++) {
      int tf = tfArray[tf_idx];
      int bars = iBars(Symbol(), tf);
      if(bars < 3) continue;
      
      double threshold = InpAuto ? CalculateAutoThreshold(tf) : InpThresholdPer / 100.0;
      
      for(int i = 1; i < bars - 2; i++) {
         bool is_bull = false;
         bool is_bear = false;
         
         double low0 = iLow(Symbol(), tf, i);
         double high0 = iHigh(Symbol(), tf, i);
         double close1 = iClose(Symbol(), tf, i+1);
         double high2 = iHigh(Symbol(), tf, i+2);
         double low2 = iLow(Symbol(), tf, i+2);
         
         if(low0 > high2 && close1 > high2 && high2 > 0 && (low0 - high2)/high2 > threshold) {
            is_bull = true;
         }
         
         if(high0 < low2 && close1 < low2 && high0 > 0 && (low2 - high0)/high0 > threshold) {
            is_bear = true;
         }
         
         if(is_bull || is_bear) {
            datetime fvg_time = iTime(Symbol(), tf, i+2);
            if(fvg_time < gStartTime) 
               continue;
            double fvg_top = is_bull ? low0 : low2;
            double fvg_bottom = is_bull ? high2 : high0;
            
            bool exists = false;
            for(int z = 0; z < ArraySize(fvgZones); z++) {
               if(fvgZones[z].time == fvg_time && fvgZones[z].tf == tf) {
                  exists = true;
                  break;
               }
            }
            
            if(!exists) {
               int size = ArraySize(fvgZones);
               ArrayResize(fvgZones, size + 1);
               fvgZones[size].time = fvg_time;
               fvgZones[size].top = fvg_top;
               fvgZones[size].bottom = fvg_bottom;
               fvgZones[size].isBull = is_bull;
               fvgZones[size].mitigated = false;
               fvgZones[size].traded = false;
               fvgZones[size].tf = tf;
               Print("FVG detected: ", (is_bull?"BULL":"BEAR"), " TF:", GetTFString(tf), " Top:", fvg_top, " Bottom:", fvg_bottom);
            }
         }
      }
   }
   
   CheckMitigation();
   CleanMitigatedZones();
}

double CalculateAutoThreshold(int tf)
{
   int bars = iBars(Symbol(), tf);
   if(bars < 10) return InpThresholdPer / 100.0;
   
   double cum_volatility = 0;
   for(int i = 0; i < bars && i < 1000; i++) {
      double low_val = iLow(Symbol(), tf, i);
      if(low_val > 0)
         cum_volatility += (iHigh(Symbol(), tf, i) - low_val) / low_val;
   }
   return bars > 0 ? cum_volatility / bars : InpThresholdPer / 100.0;
}

bool InsideZone(double highP, double lowP, double top, double bottom)
{
   return (lowP <= top && highP >= bottom);
}

void CheckTradeOpportunity()
{
   if(ArraySize(fvgZones) == 0) return;
   
   double ask = Ask;
   double bid = Bid;
   datetime now = TimeCurrent();
   
   for(int z = 0; z < ArraySize(fvgZones); z++) {
      if(fvgZones[z].traded || fvgZones[z].mitigated) continue;
      
      int tf = fvgZones[z].tf;
      datetime zone_start = fvgZones[z].time;
      datetime zone_end = zone_start + InpExtend * GetPeriodSeconds(tf);
      
      if(now < zone_start || now > zone_end) continue;
      
      int bars = iBars(Symbol(), tf);
      int bars_since_fvg = 0;
      for(int b = 0; b < bars; b++) {
         datetime bar_time = iTime(Symbol(), tf, b);
         if(bar_time <= zone_start) {
            bars_since_fvg = b;
            break;
         }
      }
      
      if(bars_since_fvg < InpDelayBars) continue;
      
      bool trade_signal = false;
      int  order_type   = -1;
      
      double cur_high = iHigh(Symbol(), tf, 0);
      double cur_low  = iLow(Symbol(), tf, 0);
      double prev_high = iHigh(Symbol(), tf, 1);
      double prev_low  = iLow(Symbol(), tf, 1);
      double prev_close = iClose(Symbol(), tf, 1);
      
      if(!TradeAfterExit) {
         if(fvgZones[z].isBull) {
            bool price_in_zone = (Ask >= fvgZones[z].bottom && Ask <= fvgZones[z].top) || 
                                 (cur_low <= fvgZones[z].top && cur_high >= fvgZones[z].bottom);
            if(price_in_zone) {
               trade_signal = true;
               order_type = OP_BUY;
            }
         } else {
            bool price_in_zone = (Bid <= fvgZones[z].top && Bid >= fvgZones[z].bottom) || 
                                 (cur_low <= fvgZones[z].top && cur_high >= fvgZones[z].bottom);
            if(price_in_zone) {
               trade_signal = true;
               order_type = OP_SELL;
            }
         }
      } else {
         bool prev_inside = InsideZone(prev_high, prev_low, fvgZones[z].top, fvgZones[z].bottom);
         if(fvgZones[z].isBull) {
            if(prev_inside && (Ask > fvgZones[z].top || prev_close > fvgZones[z].top)) {
               trade_signal = true;
               order_type = OP_BUY;
            }
         } else {
            if(prev_inside && (Bid < fvgZones[z].bottom || prev_close < fvgZones[z].bottom)) {
               trade_signal = true;
               order_type = OP_SELL;
            }
         }
      }
      
      if(trade_signal) {
         if(!HasOpenTrade(order_type, tf)) {
            OpenTrade(order_type, tf);
            fvgZones[z].traded = true;
         }
      }
   }
}

void CheckMitigation()
{
   for(int z = 0; z < ArraySize(fvgZones); z++) {
      if(fvgZones[z].mitigated) continue;
      
      int tf = fvgZones[z].tf;
      double cur_low = iLow(Symbol(), tf, 0);
      double cur_high = iHigh(Symbol(), tf, 0);
      
      if(fvgZones[z].isBull) {
         if(cur_low < fvgZones[z].bottom) {
            fvgZones[z].mitigated = true;
            Print("FVG BULL mitigated TF:", GetTFString(tf));
         }
      } else {
         if(cur_high > fvgZones[z].top) {
            fvgZones[z].mitigated = true;
            Print("FVG BEAR mitigated TF:", GetTFString(tf));
         }
      }
   }
}

bool HasOpenTrade(int order_type, int tf)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == InpMagic && OrderType() == order_type) {
            string comment = OrderComment();
            if(StringFind(comment, GetTFString(tf)) >= 0) {
               return true;
            }
         }
      }
   }
   return false;
}

void OpenTrade(int order_type, int tf)
{
   double price = (order_type == OP_BUY) ? Ask : Bid;
   double sl = (order_type == OP_BUY) ? price - InpSL * Point : price + InpSL * Point;
   double tp = (order_type == OP_BUY) ? price + InpTP * Point : price - InpTP * Point;
   
   string comment = InpComment + "_" + GetTFString(tf);
   
   int ticket = OrderSend(Symbol(), order_type, InpLotSize, price, 3, sl, tp, comment, InpMagic, 0, 0);
   
   if(ticket > 0) {
      string type_str = (order_type == OP_BUY) ? "BUY" : "SELL";
      Print("Trade opened: ", type_str, " @ ", price, " TF:", GetTFString(tf));
   } else {
      Print("Trade open failed: ", GetLastError());
   }
}

string GetTFString(int tf)
{
   if(tf == PERIOD_M5)  return "M5";
   if(tf == PERIOD_M15) return "M15";
   if(tf == PERIOD_H1)  return "H1";
   if(tf == PERIOD_H4)  return "H4";
   return "TF" + IntegerToString(tf);
}

void CleanMitigatedZones()
{
   for(int z = ArraySize(fvgZones) - 1; z >= 0; z--) {
      datetime current_time = iTime(Symbol(), fvgZones[z].tf, 0);
      int seconds_per_bar = GetPeriodSeconds(fvgZones[z].tf);
      datetime zone_end = fvgZones[z].time + InpExtend * seconds_per_bar;
      
      if(current_time > zone_end || (fvgZones[z].mitigated && fvgZones[z].traded)) {
         int size = ArraySize(fvgZones);
         for(int i = z; i < size - 1; i++) {
            fvgZones[i] = fvgZones[i + 1];
         }
         ArrayResize(fvgZones, size - 1);
      }
   }
}

int GetPeriodSeconds(int tf)
{
   if(tf == PERIOD_M1)  return 60;
   if(tf == PERIOD_M5)  return 300;
   if(tf == PERIOD_M15) return 900;
   if(tf == PERIOD_M30) return 1800;
   if(tf == PERIOD_H1)  return 3600;
   if(tf == PERIOD_H4)  return 14400;
   if(tf == PERIOD_D1)  return 86400;
   if(tf == PERIOD_W1)  return 604800;
   if(tf == PERIOD_MN1) return 2592000;
   return 3600;
}

void ManageTrades()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != InpMagic) continue;
         
         if(InpTrailingStop) TrailingStop(OrderTicket());
         if(InpBreakEven) BreakEven(OrderTicket());
      }
   }
}

void TrailingStop(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return;
   
   double current_sl = OrderStopLoss();
   double point = Point;
   if(Digits == 3 || Digits == 5) point *= 10;
   
   if(OrderType() == OP_BUY) {
      double new_sl = Bid - InpTrailingStart * point;
      if(current_sl == 0 || Bid - current_sl >= InpTrailingStep * point) {
         if(new_sl > current_sl + InpTrailingStep * point) {
            bool result = OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, 0);
            if(!result) Print("TrailingStop BUY failed: ", GetLastError());
         }
      }
   } else if(OrderType() == OP_SELL) {
      double new_sl = Ask + InpTrailingStart * point;
      if(current_sl == 0 || current_sl - Ask >= InpTrailingStep * point) {
         if(new_sl < current_sl - InpTrailingStep * point || current_sl == 0) {
            bool result = OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, 0);
            if(!result) Print("TrailingStop SELL failed: ", GetLastError());
         }
      }
   }
}

void BreakEven(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return;
   
   double current_sl = OrderStopLoss();
   double point = Point;
   if(Digits == 3 || Digits == 5) point *= 10;
   
   if(OrderType() == OP_BUY) {
      double profit = Bid - OrderOpenPrice();
      if(profit >= InpBreakEvenAt * point && (current_sl < OrderOpenPrice() || current_sl == 0)) {
         double new_sl = OrderOpenPrice() + InpBreakEvenPlus * point;
         bool result = OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, clrBlue);
         if(!result) Print("BreakEven BUY failed: ", GetLastError());
      }
   } else if(OrderType() == OP_SELL) {
      double profit = OrderOpenPrice() - Ask;
      if(profit >= InpBreakEvenAt * point && (current_sl > OrderOpenPrice() || current_sl == 0)) {
         double new_sl = OrderOpenPrice() - InpBreakEvenPlus * point;
         bool result = OrderModify(ticket, OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, clrRed);
         if(!result) Print("BreakEven SELL failed: ", GetLastError());
      }
   }
}

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76478
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
PayPal:      https://paypal.me/mariojemic
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