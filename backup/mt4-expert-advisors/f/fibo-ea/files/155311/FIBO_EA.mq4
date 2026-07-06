// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74790

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

enum direction
  {
   off,  // OFF, no trading
   sell, // Sell Only
   buy   // Buy Only
  };
input direction Direcion = sell; // Trade Direction Type
input double lot00 = 0.01;       // Level 0 Lot (0.0 = disable)
input double lot23 = 0.02;       // Level 23.6% Lot (0.0 = disable)
input double lot38 = 0.03;       // Level 38.2% Lot (0.0 = disable)
input double lot50 = 0.04;       // Level 50.0% Lot (0.0 = disable)
input double lot61 = 0.05;       // Level 61.8% Lot (0.0 = disable)
input double lot78 = 0.06;       // Level 78.6% Lot (0.0 = disable)
input double lot86 = 0.07;       // Level 86.0% Lot (0.0 = disable)
input string sltp = "==========  SL / TP Settings  =========="; // ==========  SL / TP Settings  ==========
input double tp_buy = 0.0;       // Take Profit for Buy (0.0 = disable)
input double tp_sell = 0.0;      // Take Profit for Sell (0.0 = disable)
input double sl_buy = 0.0;       // Stop Loss for Buy (0.0 = disable)
input double sl_sell = 0.0;      // Stop Loss for Sell (0.0 = disable)
input bool close_all = true;     // Close All on Net Pips Profit
input int profit_target = 100;   // Close All Profit Target in Pips
input int MagicNumber = 3535;    // Magic Number
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   double l_00 = 0.0;
   double l_23 = 0.0;
   double l_38 = 0.0;
   double l_50 = 0.0;
   double l_61 = 0.0;
   double l_78 = 0.0;
   double l_86 = 0.0;
//
   double p1 = ObjectGetDouble(0, "FIBO", OBJPROP_PRICE1);
   double p2 = ObjectGetDouble(0, "FIBO", OBJPROP_PRICE2);
   double p11 = ObjectGetDouble(0, "FIBO_INACTIVE", OBJPROP_PRICE1);
   double p22 = ObjectGetDouble(0, "FIBO_INACTIVE", OBJPROP_PRICE2);
   if((p1 == 0.0 && p11 == 0.0) || (p2 == 0.0 && p22 == 0.0))
      closeAll(0);
   if(Direcion == sell || Direcion == buy)
     {
      if(p1 < p2)
        {
         l_00 = NormalizeDouble(p2, Digits);
         l_23 = NormalizeDouble(p2 - (p2 - p1) * 0.236, Digits);
         l_38 = NormalizeDouble(p2 - (p2 - p1) * 0.382, Digits);
         l_50 = NormalizeDouble(p2 - (p2 - p1) * 0.500, Digits);
         l_61 = NormalizeDouble(p2 - (p2 - p1) * 0.618, Digits);
         l_78 = NormalizeDouble(p2 - (p2 - p1) * 0.786, Digits);
         l_86 = NormalizeDouble(p2 - (p2 - p1) * 0.860, Digits);
        }
      else
        {
         l_00 = NormalizeDouble(p2, Digits);
         l_23 = NormalizeDouble(p2 + (p1 - p2) * 0.236, Digits);
         l_38 = NormalizeDouble(p2 + (p1 - p2) * 0.382, Digits);
         l_50 = NormalizeDouble(p2 + (p1 - p2) * 0.500, Digits);
         l_61 = NormalizeDouble(p2 + (p1 - p2) * 0.618, Digits);
         l_78 = NormalizeDouble(p2 + (p1 - p2) * 0.786, Digits);
         l_86 = NormalizeDouble(p2 + (p1 - p2) * 0.860, Digits);
        }
     }
//
   if(Direcion == sell)
     {
      if(lot00 > 0.0 && !checkPos(2, "lev00"))
         openPos(2, l_00, lot00, "lev00");
      if(lot23 > 0.0 && !checkPos(2, "lev23"))
         openPos(2, l_23, lot23, "lev23");
      if(lot38 > 0.0 && !checkPos(2, "lev38"))
         openPos(2, l_38, lot38, "lev38");
      if(lot50 > 0.0 && !checkPos(2, "lev50"))
         openPos(2, l_50, lot50, "lev50");
      if(lot61 > 0.0 && !checkPos(2, "lev61"))
         openPos(2, l_61, lot61, "lev61");
      if(lot78 > 0.0 && !checkPos(2, "lev78"))
         openPos(2, l_78, lot78, "lev78");
      if(lot86 > 0.0 && !checkPos(2, "lev86"))
         openPos(2, l_86, lot86, "lev86");
     }
//
   if(Direcion == buy)
     {
      if(lot00 > 0.0 && !checkPos(1, "lev00"))
         openPos(1, l_00, lot00, "lev00");
      if(lot23 > 0.0 && !checkPos(1, "lev23"))
         openPos(1, l_23, lot23, "lev23");
      if(lot38 > 0.0 && !checkPos(1, "lev38"))
         openPos(1, l_38, lot38, "lev38");
      if(lot50 > 0.0 && !checkPos(1, "lev50"))
         openPos(1, l_50, lot50, "lev50");
      if(lot61 > 0.0 && !checkPos(1, "lev61"))
         openPos(1, l_61, lot61, "lev61");
      if(lot78 > 0.0 && !checkPos(1, "lev78"))
         openPos(1, l_78, lot78, "lev78");
      if(lot86 > 0.0 && !checkPos(1, "lev86"))
         openPos(1, l_86, lot86, "lev86");
      //
     }
//
   ObjectSetString(0, "FIBO", OBJPROP_NAME, "FIBO_INACTIVE");
//
   double global_tp = PLOfPositions(0, "");
   if(global_tp > profit_target)
      closeAll(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PLOfPositions(int dir, string sym)
  {
   double countPip = 0.0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      string ordersym = OrderSymbol();
      string comment = OrderComment();
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
              {
               countPip += (MarketInfo(ordersym, MODE_BID) - OrderOpenPrice()) / pip(ordersym);
              }
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
              {
               countPip += (OrderOpenPrice() - MarketInfo(ordersym, MODE_ASK)) / pip(ordersym);
              }
        }
     }
   return countPip;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkPos(int dir, string comment)
  {
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      string orderComment = OrderComment();
      RefreshRates();
      ResetLastError();
      if(dir == 0 ||
         (dir == 1 && (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_BUY)) ||
         (dir == 2 && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELL)))
        {
         if(comment == orderComment)
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openPos(int dir, double level, double lot, string comment)
  {
   int ticket;
   string sym = Symbol();
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double final_lot = MathRound(lot / step) * step;
   if(dir == 1)
     {
      if(Ask > level)
         ticket = OrderSend(Symbol(), OP_BUYLIMIT, lot, level, 30, sl_buy, tp_buy, comment, MagicNumber, 0, 0);
      else
         ticket = OrderSend(Symbol(), OP_BUYSTOP, lot, level, 30, sl_buy, tp_buy, comment, MagicNumber, 0, 0);
     }
//
   if(dir == 2)
     {
      if(Bid < level)
         ticket = OrderSend(Symbol(), OP_SELLLIMIT, lot, level, 30, sl_sell, tp_sell, comment, MagicNumber, 0, 0);
      else
         ticket = OrderSend(Symbol(), OP_SELLSTOP, lot, level, 30, sl_sell, tp_sell, comment, MagicNumber, 0, 0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll(int dir = 0, string sym = "")
  {
   int succ;
   string EAName = "FIBO EA: ";
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == "") && OrderMagicNumber() == MagicNumber)
        {
         if(dir == 0 ||
            (dir == 1 && (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)) ||
            (dir == 2 && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)))
           {
            succ = OrderDelete(OrderTicket(), 0);
            if(succ < 0)
              {
               Alert(EAName + ": OrderClose on " + sym + " failed with error #", GetLastError());
              }
           }
         if(dir == 0 ||
            (dir == 1 && (OrderType() == OP_BUY)) ||
            (dir == 2 && (OrderType() == OP_SELL)))
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
double pip(string sy)
  {
   sy == "" ? sy = Symbol() :;
   double po = MarketInfo(sy, MODE_POINT);
   int di = (int)MarketInfo(sy, MODE_DIGITS);
   return (di % 2 == 1 ? po * 10 : po);
  }
//+------------------------------------------------------------------+
