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
#include <Trade/Trade.mqh>
CTrade trade;

// Enum
enum ENUM_LOT_MODE {LOT_MULTIPLIER, LOT_ADDITION};

// Input parameters
input bool      GridEnabled = true;            // Enable/Disable grid strategy
input bool      GridModeStop = true;           // Open grid only when master trade is in profit
input ENUM_LOT_MODE LotMode = LOT_MULTIPLIER;  // Lot mode: Multiplier/Addition
input double    FirstGridDistance = 50.0;      // Distance from master to first grid (in pips)
input int       GridMaxCount = 5;              // Maximum number of grid trades
input double    GridMaxLot = 5.0;              // Maximum lot size for grid trades
input double    GridMultiplier = 1.5;          // Lot multiplier factor
input double    GridAdditionLot = 0.1;         // Additional lot amount
input double    GridDistance = 30.0;           // Distance between subsequent grid trades (in pips)
input bool      CloseGrid = false;             // Close entire grid by TP/SL
input double    GridTakeProfit = 100.0;        // Take Profit for grid (in pips)
input double    GridStopLoss = 50.0;           // Stop Loss for grid (in pips)
input bool      UseTrailingStop = true;        // Enable trailing stop
input double    TrailingStopPoints = 30.0;     // Trailing stop distance (in pips)
input double    TrailingStep = 10.0;           // Trailing stop step (in pips)

// Global variables
double pointMultiplier;    // Converts pips to points
input ulong masterMagic = 0;     // Magic number of master position (manual or other EA)
input ulong gridMagic = 12345;   // Magic number for grid trades opened by this EA

int OnInit()
{
   pointMultiplier = Point();
   if(Digits() == 3 || Digits() == 5) pointMultiplier *= 10;
   trade.SetExpertMagicNumber(gridMagic);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if(!GridEnabled) return;

   // Find master position (opened by trader or other EA)
   ulong masterTicket = FindMasterPosition();
   if(masterTicket == 0) return;

   // Check position
   if(GridModeStop && !IsPositionProfitable(masterTicket)) return;

   // Process grid
   ProcessGrid(masterTicket);

   // TSL
   if(UseTrailingStop) ApplyTrailingStop();
}

ulong FindMasterPosition()
{
   ulong latestTicket = 0;
   datetime latestTime = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == masterMagic)
      {
         datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
         if(openTime > latestTime)
         {
            latestTime = openTime;
            latestTicket = PositionGetTicket(i);
         }
      }
   }
   return latestTicket;
}

bool IsPositionProfitable(ulong ticket)
{
   if(PositionSelectByTicket(ticket))
      return PositionGetDouble(POSITION_PROFIT) > 0;
   return false;
}

void ProcessGrid(ulong masterTicket)
{
   if(!PositionSelectByTicket(masterTicket)) return;
   
   long direction = PositionGetInteger(POSITION_TYPE);
   double masterPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double masterLot = PositionGetDouble(POSITION_VOLUME);
   int gridCount = CountGridPositions();
   
   // Check grid limits
   if(gridCount >= GridMaxCount) return;
   
   // Calculate next grid price
   double gridPrice = CalculateNextGridPrice(direction, masterPrice, gridCount);
   
   // Check price condition
   MqlTick lastTick;
   SymbolInfoTick(_Symbol, lastTick);
   
   if((direction == POSITION_TYPE_BUY && lastTick.ask < gridPrice) ||
      (direction == POSITION_TYPE_SELL && lastTick.bid > gridPrice))
      return;
   
   // Calculate grid lot size
   double gridLot = CalculateGridLot(masterLot, gridCount);
   if(gridLot > GridMaxLot) gridLot = GridMaxLot;
   
   ulong newTicket = OpenGridPosition(direction, gridLot);   // Open grid position
   if(newTicket == 0) return;
   
   // Adjust previous position SL
   if(gridCount > 0) 
   {
      ulong prevTicket = FindLastGridPosition();
      AdjustPositionSL(prevTicket, gridPrice);
   }
   else
   {
      AdjustPositionSL(masterTicket, gridPrice);
   }
}

double CalculateNextGridPrice(long direction, double basePrice, int gridCount)
{
   double distance = (gridCount == 0) ? 
                     FirstGridDistance * pointMultiplier : 
                     GridDistance * pointMultiplier;
   
   if(direction == POSITION_TYPE_BUY)
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

ulong OpenGridPosition(long direction, double lot)
{
   double price = (direction == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                                   : SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double sl = 0, tp = 0;
   if(CloseGrid)
   {
      if(direction == POSITION_TYPE_BUY)
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

   bool success;
   if(direction == POSITION_TYPE_BUY)
      success = trade.Buy(lot, _Symbol, price, sl, tp);
   else
      success = trade.Sell(lot, _Symbol, price, sl, tp);

   if(!success)
      return 0;

   return trade.ResultOrder();
}

void AdjustPositionSL(ulong ticket, double nextGridPrice)
{
   if(PositionSelectByTicket(ticket))
   {
      double currentPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double newSl = (currentPrice + nextGridPrice) / 2.0;
      
      trade.SetExpertMagicNumber(PositionGetInteger(POSITION_MAGIC));
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         newSl = MathMin(newSl, PositionGetDouble(POSITION_PRICE_CURRENT) - 10*Point());
      else
         newSl = MathMax(newSl, PositionGetDouble(POSITION_PRICE_CURRENT) + 10*Point());
      
      trade.PositionModify(ticket, newSl, PositionGetDouble(POSITION_TP));
   }
}

void ApplyTrailingStop()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i)) continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      long magic = PositionGetInteger(POSITION_MAGIC);
      long type  = PositionGetInteger(POSITION_TYPE);
      double price = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl    = PositionGetDouble(POSITION_SL);
      double trail = TrailingStopPoints * pointMultiplier;
      double step  = TrailingStep * pointMultiplier;

      double newSl = 0;
      bool modify = false;

      if(type == POSITION_TYPE_BUY)
      {
         double trigger = price - trail;
         if((sl == 0 && price - PositionGetDouble(POSITION_PRICE_OPEN) >= trail) ||
            (sl > 0 && price - sl >= step))
         {
            newSl = NormalizeDouble(trigger, _Digits);
            modify = (sl == 0 || MathAbs(newSl - sl) >= Point());
         }
      }
      else if(type == POSITION_TYPE_SELL)
      {
         double trigger = price + trail;
         if((sl == 0 && PositionGetDouble(POSITION_PRICE_OPEN) - price >= trail) ||
            (sl > 0 && sl - price >= step))
         {
            newSl = NormalizeDouble(trigger, _Digits);
            modify = (sl == 0 || MathAbs(newSl - sl) >= Point());
         }
      }

      if(modify && newSl > 0)
      {
         trade.SetExpertMagicNumber(magic);
         trade.PositionModify(PositionGetTicket(i), newSl, PositionGetDouble(POSITION_TP));
      }
   }
}

int CountGridPositions()
{
   int count = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == gridMagic)
      {
         count++;
      }
   }
   return count;
}

ulong FindLastGridPosition()
{
   ulong lastTicket = 0;
   datetime lastTime = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == gridMagic &&
         PositionGetInteger(POSITION_TIME) > lastTime)
      {
         lastTime = (datetime)PositionGetInteger(POSITION_TIME);
         lastTicket = ticket;
      }
   }
   return lastTicket;
}

double GetLastGridLot()
{
   ulong ticket = FindLastGridPosition();
   if(ticket > 0 && PositionSelectByTicket(ticket))
      return PositionGetDouble(POSITION_VOLUME);
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