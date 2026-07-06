//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76262s

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

input double   InitialLot      = 0.01;    // Initial lot size
input double   Multiplier      = 2.0;     // Lot multiplier
input int      ZoneDistance    = 10;      // Zone distance in pips
input int      MaxTransactions = 100;     // Maximum total transactions
input int      MagicNumber     = 123456;  // Magic number for orders
input string   Comment         = "Zone_Recovery"; // Order comment
input double   ProfitTarget    = 100.0;   // Close all orders when profit reaches this amount ($)
input double   LossLimit       = 100.0;   // Close all orders when loss reaches this amount ($)
input bool     EnableAutoClose = true;    // Enable automatic close on profit/loss
double lastBuyPrice = 0;
double lastSellPrice = 0;
double currentLot = 0;
int totalTransactions = 0;
bool isInitialized = false;
double pipValue = 0;
datetime lastProfitDisplay = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits == 5 || Digits == 3)
      pipValue = Point * 10;
   else
      pipValue = Point;
   currentLot = InitialLot;
   totalTransactions = CountExistingOrders();
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
   if(EnableAutoClose)
     {
      if(CheckAutoCloseConditions())
        {
         return;
        }
     }
   if(totalTransactions >= MaxTransactions)
     {
      return;
     }
   totalTransactions = CountExistingOrders();
   if(totalTransactions == 0 && !isInitialized)
     {
      OpenFirstBuy();
      return;
     }
   CheckZoneRecovery();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckAutoCloseConditions()
  {
   double totalProfit = CalculateTotalProfit();
   if(TimeCurrent() - lastProfitDisplay >= 30)
     {
      lastProfitDisplay = TimeCurrent();
     }
   if(totalProfit >= ProfitTarget)
     {
      CloseAllOrders();
      ResetEA();
      return true;
     }
   if(totalProfit <= -LossLimit)
     {
      CloseAllOrders();
      ResetEA();
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTotalProfit()
  {
   double totalProfit = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
           }
        }
     }
   return totalProfit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetEA()
  {
   lastBuyPrice = 0;
   lastSellPrice = 0;
   currentLot = InitialLot;
   totalTransactions = 0;
   isInitialized = false;
   Print("EA reset - Ready for new trading session");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenFirstBuy()
  {
   double price = Ask;
   int ticket = OrderSend(Symbol(), OP_BUY, currentLot, price, 3, 0, 0, Comment, MagicNumber, 0, clrBlue);
   if(ticket > 0)
     {
      lastBuyPrice = price;
      lastSellPrice = 0;
      totalTransactions++;
      isInitialized = true;
     }
   else
     {
      Print("Failed to open first BUY order. Error: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckZoneRecovery()
  {
   double currentPrice = (Bid + Ask) / 2;
   int lastOrderType = GetLastOrderType();
   if(lastOrderType == OP_BUY && lastBuyPrice > 0)
     {
      if(currentPrice <= lastBuyPrice - (ZoneDistance * pipValue))
        {
         OpenSellOrder();
        }
     }
   else
      if(lastOrderType == OP_SELL && lastSellPrice > 0)
        {
         if(currentPrice >= lastSellPrice + (ZoneDistance * pipValue))
           {
            OpenBuyOrder();
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSellOrder()
  {
   if(totalTransactions >= MaxTransactions)
      return;
   currentLot = currentLot * Multiplier;
   double price = Bid;
   int ticket = OrderSend(Symbol(), OP_SELL, currentLot, price, 3, 0, 0, Comment, MagicNumber, 0, clrRed);
   if(ticket > 0)
     {
      lastSellPrice = price;
      totalTransactions++;
     }
   else
     {
      Print("Failed to open SELL order. Error: ", GetLastError());
      currentLot = currentLot / Multiplier;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {
   if(totalTransactions >= MaxTransactions)
      return;
   currentLot = currentLot * Multiplier;
   double price = Ask;
   int ticket = OrderSend(Symbol(), OP_BUY, currentLot, price, 3, 0, 0, Comment, MagicNumber, 0, clrBlue);
   if(ticket > 0)
     {
      lastBuyPrice = price;
      totalTransactions++;
     }
   else
     {
      Print("Failed to open BUY order. Error: ", GetLastError());
      currentLot = currentLot / Multiplier;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountExistingOrders()
  {
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            count++;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLastOrderType()
  {
   int lastOrderType = -1;
   datetime lastTime = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if(OrderOpenTime() > lastTime)
              {
               lastTime = OrderOpenTime();
               lastOrderType = OrderType();
               if(OrderType() == OP_BUY)
                  lastBuyPrice = OrderOpenPrice();
               else
                  if(OrderType() == OP_SELL)
                     lastSellPrice = OrderOpenPrice();
              }
           }
        }
     }
   return lastOrderType;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            bool result = false;
            if(OrderType() == OP_BUY)
              {
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlue);
                 }
            if(!result)
              {
               Print("Failed to close order #", OrderTicket(), ". Error: ", GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76262s

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+