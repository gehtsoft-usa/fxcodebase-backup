// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72776

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// Includes
#include <trade\trade.mqh>
COrderInfo orderInfo;
CTrade     trade;

// Gobal Variables

// NOTE: inputs
// ------------------------------------------------------------------
input string T00          = "- Check Time -";   // Check Time:
input int    uCheckTime   = 30;                 // Seconds to check:
input string T01          = "- Take Profit -";  // Setup Take Profit
input bool   takeProfitOn = true;               // Take Profit On:
input int    userTPpips   = 0;                  // Pips TP
input string T02          = "- Stop Loss -";    // Setup Stop Loss
input bool   stopLossOn   = true;               // Stop Loss On:
input int    userSLpips   = 0;                  // Pips SL
// ------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   return (INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) {}

void OnTick() {}

void OnTimer(void) { doControl(); }

void OnTrade(void) {}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {}

//////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SL(string symbol, string direction, double price)
  {
   if(!stopLossOn)
      return 0;
   double result = 0;
   if(userSLpips == 0)
     {
      return 0;
     }
   double mPoints = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    digits  = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(direction == "buy")
     {
      // double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      result     = price - userSLpips * 10 * mPoints;
      return NormalizeDouble(result, digits);
     }
   if(direction == "sell")
     {
      // double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      result     = price + userSLpips * 10 * mPoints;
      return NormalizeDouble(result, digits);
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TP(string symbol, string direction, double price)
  {
   if(!takeProfitOn)
      return 0;
   double result = 0;
   if(userTPpips == 0)
     {
      return 0;
     }
   double mPoints = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    digits  = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(direction == "buy")
     {
      // double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      result     = price + userTPpips * 10 * mPoints;
      return NormalizeDouble(result, digits);
     }
   if(direction == "sell")
     {
      // double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      result     = price - userTPpips * 10 * mPoints;
      return NormalizeDouble(result, digits);
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doControl()
  {
   int checkTime = TimeCurrent() - uCheckTime;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong              tk   = PositionGetTicket(i);
      ENUM_POSITION_TYPE type = PositionGetInteger(POSITION_TYPE);
      string             side = "";
      if(type == POSITION_TYPE_BUY)
         side = "buy";
      if(type == POSITION_TYPE_SELL)
         side = "sell";
      if(side == "")
         continue;
      string symbol       = PositionGetSymbol(i);
      long   positionTime = PositionGetInteger(POSITION_TIME);
      double price        = PositionGetDouble(POSITION_PRICE_OPEN);
      double position_tp  = PositionGetDouble(POSITION_TP);
      double position_sl  = PositionGetDouble(POSITION_SL);
      if(positionTime <= checkTime && symbol == Symbol())
        {
         // SL Control
         if(PositionGetInteger(POSITION_MAGIC) == 0 && position_sl == 0)
           {
            position_sl = SL(symbol, side, price);
            trade.PositionModify(tk, position_sl, position_tp);
           }
         // TP Control
         if(PositionGetInteger(POSITION_MAGIC) == 0 && position_tp == 0)
           {
            position_tp = TP(symbol, side, price);
            trade.PositionModify(tk, position_sl, position_tp);
           }
        }
     }
  }

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+

