//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76383&sid=c475aa855a2351a3dda86040d5325c4b
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
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

input int    BarsBack = 5;                              // Bars back to check for a swing
input double LotSize = 0.01;                            // Lot size
input int    StopLoss = 0;                              // Stop Loss (pips, 0 = off)
input int    TakeProfit = 0;                            // Take Profit (pips, 0 = off)
input int    MagicNumber = 675;                         // Magic Number
input bool   UseChartTF = true;                          // Use Chart Timeframe, true = current timeframe, example: M15
input bool   UseHigherTF = true;                         // Use Higher Timeframe, true = current timeframe + 1, example: M30
input bool   UseHighestTF = true;                       // Use Highest Timeframe, true = highest timeframe

struct SwingData
  {
   datetime          time;
   double            price;
   double            close;
   double            open;
   double            low;
   bool              detected;
  };

SwingData etfSwingHighs[5];
SwingData etfSwingLows[5];
SwingData btfSwingHighs[5];
SwingData btfSwingLows[5];
SwingData htfSwingHighs[5];
SwingData htfSwingLows[5];
int etfSHCount = 0;
int etfSLCount = 0;
int btfSHCount = 0;
int btfSLCount = 0;
int htfSHCount = 0;
int htfSLCount = 0;
int etf, btf, htf;
int btf_bb, htf_bb;

datetime lastETF_SH_Time = 0;
datetime lastETF_SL_Time = 0;
datetime lastBTF_SH_Time = 0;
datetime lastBTF_SL_Time = 0;
datetime lastHTF_SH_Time = 0;
datetime lastHTF_SL_Time = 0;

int OnInit()
  {
   etf = Period();
   switch(etf)
     {
      case PERIOD_M1:
         btf = PERIOD_M5;
         htf = PERIOD_M15;
         break;
      case PERIOD_M5:
         btf = PERIOD_M15;
         htf = PERIOD_H1;
         break;
      case PERIOD_M15:
         btf = PERIOD_H1;
         htf = PERIOD_H4;
         break;
      case PERIOD_H1:
         btf = PERIOD_H4;
         htf = PERIOD_D1;
         break;
      case PERIOD_H4:
         btf = PERIOD_D1;
         htf = PERIOD_W1;
         break;
      case PERIOD_D1:
         btf = PERIOD_W1;
         htf = PERIOD_MN1;
         break;
      case PERIOD_W1:
         btf = PERIOD_MN1;
         htf = PERIOD_MN1;
         break;
      default:
         btf = etf * 5;
         htf = etf * 15;
         break;
     }
   int btf_bb_mult, htf_bb_mult;
   switch(etf)
     {
      case PERIOD_M1:
         btf_bb_mult = 5;
         htf_bb_mult = 15;
         break;
      case PERIOD_M5:
         btf_bb_mult = 3;
         htf_bb_mult = 12;
         break;
      case PERIOD_M15:
         btf_bb_mult = 4;
         htf_bb_mult = 16;
         break;
      case PERIOD_H1:
         btf_bb_mult = 4;
         htf_bb_mult = 24;
         break;
      case PERIOD_H4:
         btf_bb_mult = 6;
         htf_bb_mult = 30;
         break;
      case PERIOD_D1:
         btf_bb_mult = 5;
         htf_bb_mult = 20;
         break;
      case PERIOD_W1:
         btf_bb_mult = 4;
         htf_bb_mult = 16;
         break;
      default:
         btf_bb_mult = 5;
         htf_bb_mult = 15;
         break;
     }
   btf_bb = BarsBack * btf_bb_mult;
   htf_bb = BarsBack * htf_bb_mult;
   InitSwingArrays();
   LoadLastSwingTimes();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
  }

void OnTick()
  {
   if(Bars < BarsBack * 2 + 1)
      return;
   
   InitSwingArrays();
   
   if(UseChartTF)
     {
      CheckSwingAtIndex(BarsBack, Period(), etfSwingHighs, etfSwingLows, etfSHCount, etfSLCount);
      CheckNewSwing("ETF", etfSwingHighs, etfSwingLows, etfSHCount, etfSLCount, 
                    lastETF_SH_Time, lastETF_SL_Time);
     }
   
   if(UseHigherTF)
     {
      CheckSwingAtIndex(btf_bb, btf, btfSwingHighs, btfSwingLows, btfSHCount, btfSLCount);
      CheckNewSwing("BTF", btfSwingHighs, btfSwingLows, btfSHCount, btfSLCount, 
                    lastBTF_SH_Time, lastBTF_SL_Time);
     }
   
   if(UseHighestTF)
     {
      CheckSwingAtIndex(htf_bb, htf, htfSwingHighs, htfSwingLows, htfSHCount, htfSLCount);
      CheckNewSwing("HTF", htfSwingHighs, htfSwingLows, htfSHCount, htfSLCount, 
                    lastHTF_SH_Time, lastHTF_SL_Time);
     }
  }

void InitSwingArrays()
  {
   for(int i = 0; i < 5; i++)
     {
      etfSwingHighs[i].detected = false;
      etfSwingLows[i].detected = false;
      btfSwingHighs[i].detected = false;
      btfSwingLows[i].detected = false;
      htfSwingHighs[i].detected = false;
      htfSwingLows[i].detected = false;
     }
   etfSHCount = 0;
   etfSLCount = 0;
   btfSHCount = 0;
   btfSLCount = 0;
   htfSHCount = 0;
   htfSLCount = 0;
  }

void CheckSwingAtIndex(int index, int timeframe, SwingData &swingHighs[], SwingData &swingLows[],
                       int &shCount, int &slCount)
  {
   int bars_count = iBars(Symbol(), timeframe);
   if(bars_count < index + index * 2)
      return;
   CollectHistoricalSwings(index, timeframe, true, swingHighs, shCount);
   CollectHistoricalSwings(index, timeframe, false, swingLows, slCount);
  }

void CollectHistoricalSwings(int lookback, int timeframe, bool isHigh, SwingData &swings[], int &count)
  {
   count = 0;
   int swingsFound = 0;
   int bars_count = iBars(Symbol(), timeframe);
   int max_bars = MathMin(bars_count - lookback * 2, 500);
   
   for(int bar = lookback; bar < max_bars && swingsFound < 5; bar++)
     {
      int start = (lookback * 2) - 1;
      double swing_point = isHigh ? iHigh(Symbol(), timeframe, bar) : iLow(Symbol(), timeframe, bar);
      bool isSwing = true;
      for(int i = 0; i <= start && isSwing; i++)
        {
         int checkBar = bar + i - lookback;
         if(checkBar < 0 || checkBar >= bars_count)
           {
            isSwing = false;
            break;
           }
         double checkValue = isHigh ? iHigh(Symbol(), timeframe, checkBar) : iLow(Symbol(), timeframe, checkBar);
         if(i < lookback)
           {
            if(isHigh)
              {
               if(checkValue > swing_point)
                  isSwing = false;
              }
            else
              {
               if(checkValue < swing_point)
                  isSwing = false;
              }
           }
         else
            if(i > lookback)
              {
               if(isHigh)
                 {
                  if(checkValue >= swing_point)
                     isSwing = false;
                 }
               else
                 {
                  if(checkValue <= swing_point)
                     isSwing = false;
                 }
              }
        }
      if(isSwing)
        {
         swings[swingsFound].time = iTime(Symbol(), timeframe, bar);
         swings[swingsFound].price = swing_point;
         swings[swingsFound].close = iClose(Symbol(), timeframe, bar);
         swings[swingsFound].open = iOpen(Symbol(), timeframe, bar);
         swings[swingsFound].low = iLow(Symbol(), timeframe, bar);
         swings[swingsFound].detected = true;
         swingsFound++;
        }
     }
   count = swingsFound;
  }

void CheckNewSwing(string tfName, SwingData &swingHighs[], SwingData &swingLows[],
                   int shCount, int slCount, datetime &lastSHTime, datetime &lastSLTime)
  {
   string varPrefix = "MTF_EA_" + tfName + "_";
   
   if(shCount > 0 && swingHighs[0].detected)
     {
      if(swingHighs[0].time != lastSHTime)
        {
         if(lastSHTime > 0)
           {
            PlaceSellOrder(tfName);
           }
         lastSHTime = swingHighs[0].time;
         GlobalVariableSet(varPrefix + "SH_" + Symbol(), lastSHTime);
        }
     }
   
   if(slCount > 0 && swingLows[0].detected)
     {
      if(swingLows[0].time != lastSLTime)
        {
         if(lastSLTime > 0)
           {
            PlaceBuyOrder(tfName);
           }
         lastSLTime = swingLows[0].time;
         GlobalVariableSet(varPrefix + "SL_" + Symbol(), lastSLTime);
        }
     }
  }

void PlaceBuyOrder(string tfName)
  {
   double price = Ask;
   double sl = 0, tp = 0;
   
   if(StopLoss > 0)
      sl = price - StopLoss * Point * 10;
   if(TakeProfit > 0)
      tp = price + TakeProfit * Point * 10;
   
   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, 
                          "MTF_Swing_" + tfName + "_Buy", MagicNumber, 0, clrBlue);
   
   if(ticket > 0)
      Print("Buy order placed: ", tfName, " Ticket: ", ticket);
   else
      Print("Buy order failed: ", tfName, " Error: ", GetLastError());
  }

void PlaceSellOrder(string tfName)
  {
   double price = Bid;
   double sl = 0, tp = 0;
   
   if(StopLoss > 0)
      sl = price + StopLoss * Point * 10;
   if(TakeProfit > 0)
      tp = price - TakeProfit * Point * 10;
   
   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, 
                          "MTF_Swing_" + tfName + "_Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
      Print("Sell order placed: ", tfName, " Ticket: ", ticket);
   else
      Print("Sell order failed: ", tfName, " Error: ", GetLastError());
  }

void LoadLastSwingTimes()
  {
   lastETF_SH_Time = (datetime)GlobalVariableGet("MTF_EA_ETF_SH_" + Symbol());
   lastETF_SL_Time = (datetime)GlobalVariableGet("MTF_EA_ETF_SL_" + Symbol());
   lastBTF_SH_Time = (datetime)GlobalVariableGet("MTF_EA_BTF_SH_" + Symbol());
   lastBTF_SL_Time = (datetime)GlobalVariableGet("MTF_EA_BTF_SL_" + Symbol());
   lastHTF_SH_Time = (datetime)GlobalVariableGet("MTF_EA_HTF_SH_" + Symbol());
   lastHTF_SL_Time = (datetime)GlobalVariableGet("MTF_EA_HTF_SL_" + Symbol());
  }

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76383&sid=c475aa855a2351a3dda86040d5325c4b
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