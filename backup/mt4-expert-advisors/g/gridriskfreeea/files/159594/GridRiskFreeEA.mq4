//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76030

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

// Enum
enum ENUM_LOT_MODE {LOT_MULTIPLIER, LOT_ADDITION};

// Input parameters
input bool      GridEnabled = true;        // Grid On/Off
input bool      GridModeStop = true;       // Only open grid when first position is profitable
input double    FirstGridDistance = 50.0;  // First grid distance (pips)
input int       GridMaxCount = 5;          // Grid Max Count
input ENUM_LOT_MODE LotMode = LOT_MULTIPLIER; // Lot mode: Multiplier/Addition
input double    GridMaxLot = 5.0;          // Grid Max Lot
input double    GridMultiplier = 1.5;      // Grid Multiplier
input double    GridAdditionLot = 0.1;     // Grid Addition Lot
input double    GridDistance = 30.0;       // Grid Distance (pips)
input bool      CloseGrid = false;         // Close Grid by TP/SL
input double    GridTakeProfit = 100.0;    // Close grid TP (pips)
input double    GridStopLoss = 50.0;       // Close grid SL (pips)
input bool      UseTrailingStop = true;    // Use Trailing Stop
input double    TrailingStopPoints = 30.0; // Trailing Stop (pips)
input double    TrailingStep = 10.0;       // Trailing Step (pips)

// Global variables
double pointMultiplier; // Converts pips to points
input int masterMagic = 0;     // Magic number of master position (manual or other EA)
input int gridMagic = 12345;   // Magic number for grid trades opened by this EA

int OnInit()
{
   pointMultiplier = Point;
   if(Digits() == 3 || Digits() == 5) pointMultiplier *= 10;
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if(!GridEnabled) return;

   // Find master position (opened by trader or other EA)
   int masterTicket = FindMasterPosition();
   if(masterTicket < 0) return;

   // Check if master position is profitable (if required)
   if(GridModeStop && !IsPositionProfitable(masterTicket)) return;

   // Process grid
   ProcessGrid(masterTicket);

   // Apply trailing stop if enabled
   if(UseTrailingStop) ApplyTrailingStop();
}

int FindMasterPosition()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == masterMagic)
      {
         return OrderTicket();
      }
   }
   return -1;
}

bool IsPositionProfitable(int ticket)
{
   if(OrderSelect(ticket, SELECT_BY_TICKET))
      return OrderProfit() > 0;
   return false;
}

void ProcessGrid(int masterTicket)
{
   if(!OrderSelect(masterTicket, SELECT_BY_TICKET)) return;
   
   int direction = OrderType();
   double masterPrice = OrderOpenPrice();
   double masterLot = OrderLots();
   int gridCount = CountGridPositions();
   
   // Check grid limits
   if(gridCount >= GridMaxCount) return;
   
   // Calculate next grid price
   double gridPrice = CalculateNextGridPrice(direction, masterPrice, gridCount);
   
   // Check price condition
   if((direction == OP_BUY && Ask < gridPrice) ||
      (direction == OP_SELL && Bid > gridPrice))
      return;
   
   // Calculate grid lot size
   double gridLot = CalculateGridLot(masterLot, gridCount);
   if(gridLot > GridMaxLot) gridLot = GridMaxLot;
   
   // Open grid position
   int newTicket = OpenGridPosition(direction, gridLot);
   if(newTicket < 0) return;
   
   // Adjust previous position SL
   if(gridCount > 0) 
   {
      int prevTicket = FindLastGridPosition();
      AdjustPositionSL(prevTicket, gridPrice);
   }
   else
   {
      AdjustPositionSL(masterTicket, gridPrice);
   }
}

double CalculateNextGridPrice(int direction, double basePrice, int gridCount)
{
   double distance = (gridCount == 0) ? 
                     FirstGridDistance * pointMultiplier : 
                     GridDistance * pointMultiplier;
   
   if(direction == OP_BUY)
      return basePrice + distance;
   else
      return basePrice - distance;
}

double CalculateGridLot(double baseLot, int gridCount)
{
   if(gridCount == 0)
   {
      if(LotMode == LOT_MULTIPLIER)
         return baseLot * GridMultiplier;
      else
         return baseLot + GridAdditionLot;
   }
   else
   {
      double lastGridLot = GetLastGridLot();
      if(LotMode == LOT_MULTIPLIER)
         return lastGridLot * GridMultiplier;
      else
         return lastGridLot + GridAdditionLot;
   }
}

int OpenGridPosition(int direction, double lot)
{
   double price = (direction == OP_BUY) ? Ask : Bid;
   double sl = 0, tp = 0;
   
   if(CloseGrid)
   {
      if(direction == OP_BUY)
      {
         sl = price - GridStopLoss * pointMultiplier;
         tp = price + GridTakeProfit * pointMultiplier;
      }
      else
      {
         sl = price + GridStopLoss * pointMultiplier;
         tp = price - GridTakeProfit * pointMultiplier;
      }
   }
   
   int ticket = OrderSend(Symbol(), direction, lot, price, 3, sl, tp, "Grid", gridMagic, 0, clrNONE);
   return ticket;
}

void AdjustPositionSL(int ticket, double nextGridPrice)
{
   if(OrderSelect(ticket, SELECT_BY_TICKET))
   {
      double currentPrice = OrderOpenPrice();
      double newSl = (currentPrice + nextGridPrice) / 2.0;
      
      if(OrderType() == OP_BUY)
         newSl = MathMin(newSl, Bid - 10*Point);
      else
         newSl = MathMax(newSl, Ask + 10*Point);
      
      OrderModify(ticket, OrderOpenPrice(), newSl, OrderTakeProfit(), 0, clrNONE);
   }
}

void ApplyTrailingStop()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol())
      {
         double newSl = 0;
         double trail = TrailingStopPoints * pointMultiplier;
         double step = TrailingStep * pointMultiplier;
         
         if(OrderType() == OP_BUY)
         {
            if(Bid - OrderStopLoss() > step * pointMultiplier)
               newSl = Bid - trail;
         }
         else if(OrderType() == OP_SELL)
         {
            if(OrderStopLoss() - Ask > step * pointMultiplier)
               newSl = Ask + trail;
         }
         
         if(newSl > 0 && 
            MathAbs(OrderStopLoss() - newSl) > Point)
         {
            OrderModify(OrderTicket(), OrderOpenPrice(), newSl, 
                       OrderTakeProfit(), 0, clrNONE);
         }
      }
   }
}

int CountGridPositions()
{
   int count = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == gridMagic)
      {
         count++;
      }
   }
   return count;
}

int FindLastGridPosition()
{
   int lastTicket = -1;
   datetime lastTime = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == gridMagic &&
         OrderOpenTime() > lastTime)
      {
         lastTime = OrderOpenTime();
         lastTicket = OrderTicket();
      }
   }
   return lastTicket;
}

double GetLastGridLot()
{
   int ticket = FindLastGridPosition();
   if(OrderSelect(ticket, SELECT_BY_TICKET))
      return OrderLots();
   return 0;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76030

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 