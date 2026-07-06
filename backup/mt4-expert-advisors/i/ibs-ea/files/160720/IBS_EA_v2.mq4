//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=148262#p148262
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
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

datetime NewCandleTimeCurrent   ;
enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };
extern  string S1  =  "Indicator Setting";
extern int ibs_period   =  5;   // Per
int index_shift    = 1;  //  Candle Index Confirmation

extern double level_for_buy   =  50 ;  //  Level  For Buy
extern  double  level_for_sell  =  50 ; //  Level For Sell
double  Lots_mapping    =  0.1;   //   Lot
extern  int MAGIC_NUMBER  = 398376; // Magic  Number
extern   EnableDisable     take_profit_set  =   Disable  ;   //  Take Profit Set
extern   double   take_profit   = 10   ;  //  Take Profit
extern    EnableDisable   stop_loss_set   =   Disable ; // Stop Loss Set
extern  double    stop_loss   =  10   ;   //  Stop Loss

extern   EnableDisable  trailling_stop_loss     =    Disable; // Trailling Stop Loss
extern  double when_to_trail_l4      =   20 ;  //  When to trail
extern  double where_to_trail_l4   =   10 ;   //  Where to trail

extern  EnableDisable    useBreakEven   = Disable  ;  // Breakeven
extern   double  when_to_trail_l1   =    7      ;   //  When To Breakeven
extern  double    where_to_trail_l1  =     1;    //  Where to  Breakeven

extern  bool previous_trade  =    true;  //  Close Previous Trade
string upcommingSignal  = "NONE";
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification
extern bool   trade_execution    =  true   ;  //  Trade Execution
input string startTime1 = "09:00";      //Start time 1
input string finishTime1 = "17:30";     //Finish time 1
input string startTime2 = "18:00";      //Start time 2
input string finishTime2 = "22:00";     //Finish time 2
extern bool mandatoryClose = true;      //Mandatory Close during Time Filter
// extern    revese_
int OnInit()
  {
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(trailling_stop_loss   == Enable)
     {
      fx_trail();
     }
   if(useBreakEven    ==  Enable)
     {
      fx_trail_breakeven();
     }
   
   // Mandatory Close during Time Filter
   if(mandatoryClose == true && !checkTime())
     {
      fx_close_mode(true, "Time Filter Close");
     }
//---
// Please make an expert advisor from this indicator, it should be no repaiting indicator after candle close. / close of the trade - opposite candle close, and new trade to the opposite direction/ . Candle close should be with cross of certain level, for example 50 / candle close above
// level 50 - buy, candle close below level 50 - sell /. Please add Time Filter /Stop loss. Thank you.
   double   ibs_data   =   iCustom(Symbol(),  PERIOD_CURRENT, "ibs",  ibs_period, 0, index_shift) ;                 //  positive
   if(IsNewCandleCurrent()&& checkTime())
     {
      if(ibs_data  >  level_for_buy   && (upcommingSignal    == "NONE" ||  upcommingSignal   == "SELL") &&  Open[1] <   Close[1])
        {
         upcommingSignal   =   "BUY";
         if(alert_send_notification    ==  true)
           {
            string signal_type   = "bull";
            Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0, Symbol())) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0, Symbol())));
            SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0, Symbol())) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0,  Symbol())));
           }
         if(trade_execution    ==  true)
           {
            fx_take_trade_order(0);
           }
        }
      if(ibs_data   < level_for_sell  && (upcommingSignal    == "NONE"  || upcommingSignal    == "BUY")  &&    Open[1] >   Close[1])
        {
         upcommingSignal  =  "SELL";
         if(alert_send_notification   ==  true)
           {
            string signal_type   = "bear";
            Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1,  Symbol())) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1, Symbol())));
            SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1,  Symbol())) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1,  Symbol())));
           }
         if(trade_execution    ==  true)
           {
            fx_take_trade_order(1);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_order(int order_type)
  {
   if(previous_trade == true)
     {
      fx_close_mode(true, "");
     }
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);
   bool  response_order  =  OrderSend(Symbol(), order_type, Lots_mapping, order_type ==  0  ?  Ask :  Bid, 10,  stop_loss_set   ==   Enable    ? fx_stop_profit_calculation(order_type, Symbol())   :  0,  take_profit_set   == Enable   ?  fx_take_profit_calculation(order_type, Symbol())    :        0, "true", MAGIC_NUMBER, 0, clrNONE);
   if(!response_order)
     {
      Print(GetLastError(),   "GetLastError()========================");
     }
   else
     {
     }
   return 0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_calculation(int order_type,  string symbol_mapping)
  {
   if(order_type   == 0)
     {
      return   fx_asker(symbol_mapping)   +   fx_pips_evaluation(symbol_mapping) *  take_profit * Point;
     }
   else
      if(order_type   ==  1)
        {
         return  fx_bidder(symbol_mapping)   -  fx_pips_evaluation(symbol_mapping) *  take_profit * Point;
        }
   return 0  ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stop_profit_calculation(int order_type,  string symbol_mapping)
  {
   if(order_type   == 0)
     {
      return   fx_bidder(symbol_mapping)   -   fx_pips_evaluation(symbol_mapping) *  stop_loss * Point;
     }
   else
      if(order_type   ==  1)
        {
         return   fx_asker(symbol_mapping)   +  fx_pips_evaluation(symbol_mapping) *  stop_loss * Point;
        }
   return 0  ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    fx_asker(string symbol_mapping)
  {
   return  MarketInfo(symbol_mapping, MODE_ASK);
   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    fx_bidder(string symbol_mapping)
  {
   return  MarketInfo(symbol_mapping, MODE_BID);
   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation(string  symbol_mapping)
  {
   int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
   if(digits == 2)
     {
      return   100;
     }
   else
      if(digits ==  4  ||  digits == 5)
        {
         return 10;
        }
      else
        {
         return  1;
        }
   return 0;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_trail()
  {
   for(int fx   =    0 ;    fx < OrdersTotal()  ; fx++)
     {
      if(OrderSelect(fx,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()   ==  Symbol()   &&   OrderMagicNumber()  == MAGIC_NUMBER)
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double   local_strage  =   bid_price -  where_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage   || OrderStopLoss()  == 0.0)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
         if(OrderType()  ==  1 &&  OrderSymbol()   == Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(OrderSymbol());
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =  ask_price + where_to_trail_l4  * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  >  local_strage || OrderStopLoss()  == 0.0)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
        }
     }
   return   0 ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_trail_breakeven()
  {
   for(int b = OrdersTotal() - 1  ;  b >=  0   ;   b--)
     {
      if(OrderSelect(b,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol() &&  OrderMagicNumber()   == MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double   local_strage  =   OrderOpenPrice()  +  where_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss()   <   OrderOpenPrice()  && ask_price  > OrderOpenPrice())
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
         if(OrderType()  ==  1   &&   OrderSymbol()    == Symbol() && OrderMagicNumber()   == MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =   OrderOpenPrice()  - where_to_trail_l1   * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  > OrderOpenPrice() &&  bid_price  < OrderOpenPrice())
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
        }
     }
   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_order_modification(int ticket,  double  order_open_price,    double  local_storage_stop_loss,  double   order_take_profit,   int expiration, string additional,   int order_magic_number)
  {
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration, CLR_NONE);
   if(!res)
     {
      Alert("Error in OrderModify. Error code=", GetLastError());
     }
   return    0 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandleCurrent()
  {
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
      return true;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_close_mode(bool  type,  string addtional)
  {
   RefreshRates();
   Print(OrdersTotal());
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
        }
      bool res = false;
      int Slippage = 0;
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
      if(OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        }
      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }
   return 0  ;
  }
//+------------------------------------------------------------------+
bool checkTime()
  {
   datetime curTime = TimeCurrent();
   datetime s_time1 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + startTime1);
   datetime f_time1 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + finishTime1);
   datetime s_time2 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + startTime2);
   datetime f_time2 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + finishTime2);
   if((startTime1 == "00:00" || startTime1 == "0") && (finishTime1 == "00:00" || finishTime1 == "0") && (startTime2 == "00:00" || startTime2 == "0") && (finishTime2 == "00:00" || finishTime2 == "0"))
      return true;
   if(curTime >=  s_time1 && curTime < f_time1)
      return true;
   if(curTime >=  s_time2 && curTime < f_time2)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=148262#p148262
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