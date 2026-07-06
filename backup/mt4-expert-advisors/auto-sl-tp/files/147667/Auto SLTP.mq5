// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72776

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

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

double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }

double SL(string symbol, string direction, double price)
{
  if (!stopLossOn) return 0;
  double result = 0;
  if (userSLpips == 0) {
    return 0;
  }
	
	double mPoints = SymbolInfoDouble(symbol,SYMBOL_POINT);
  int    digits  = SymbolInfoInteger(symbol, SYMBOL_DIGITS);

        if (direction == "buy") {
          // double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
          result     = price - userSLpips * 10 * mPoints;
          return NormalizeDouble(result,digits);
  }

  if (direction == "sell") {
    // double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
    result     = price + userSLpips * 10 * mPoints;
    return NormalizeDouble(result,digits);
  }

  return -1;
}

double TP(string symbol, string direction, double price)
{
  if (!takeProfitOn) return 0;
  double result = 0;
  if (userTPpips == 0) { return 0; }
  
	double mPoints = SymbolInfoDouble(symbol,SYMBOL_POINT);
	int    digits  = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	
	if (direction == "buy") {
    // double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
    result     = price + userTPpips * 10 * mPoints;
    return NormalizeDouble(result, digits);
  }

  if (direction == "sell") {
    // double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
    result     = price - userTPpips * 10 * mPoints;
    return NormalizeDouble(result,digits);
  }

  return -1;
}

void doControl()
{
  int checkTime = TimeCurrent() - uCheckTime;

  for (int i = PositionsTotal()-1; i >= 0; i--) {
    ulong              tk   = PositionGetTicket(i);
    ENUM_POSITION_TYPE type = PositionGetInteger(POSITION_TYPE);
    string             side = "";
    if (type == POSITION_TYPE_BUY) side = "buy";
    if (type == POSITION_TYPE_SELL) side = "sell";
    if (side == "") continue;

    string symbol       = PositionGetSymbol(i);
    int    positionTime = PositionGetInteger(POSITION_TIME);
    double price        = PositionGetDouble(POSITION_PRICE_OPEN);
    double position_tp  = PositionGetDouble(POSITION_TP); 
    double position_sl  = PositionGetDouble(POSITION_SL);
		
    if (positionTime <= checkTime) {      
			
			// SL Control
      if (PositionGetInteger(POSITION_MAGIC) == 0 && position_sl == 0) {
        position_sl = SL(symbol, side, price);
        trade.PositionModify(tk, position_sl, position_tp);
      }

      // TP Control
      if (PositionGetInteger(POSITION_MAGIC) == 0 && position_tp == 0) {
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
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+