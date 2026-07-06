// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73363

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#include <trade\trade.mqh>
CTrade     trade;

enum Side {
  buy,
  sell
};

input string       T0           = "== Trade Setup ==";  // **********
input Side         side         = buy;                  // Side:
input double       userLots     = 0.10;                 // Lots:
input string       T01          = "- Take Profit -";    // **********
input int          TPMoney      = 100;                  // Money TP
input string       T02          = "- Stop Loss -";      // **********
input int          SLMoney      = 50;                   // Money SL
 
 
//////////////////////////////////////////////////////////////////////
 
int OnInit()
{
 
	return(INIT_SUCCEEDED);
}
 
void OnDeinit(const int reason) { }
 
 // NOTE: tick
void OnTick() { 


	// if haven't trades:
	if(PositionsTotal()==0)
		trade.PositionOpen(_Symbol, Type(), userLots, Price(), Sl(), Tp());
}
//////////////////////////////////////////////////////////////////////


double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }

double Price() 
{
	double price = side == buy ? Ask(): Bid();
	return price;
}

ENUM_ORDER_TYPE Type()
{
  ENUM_ORDER_TYPE type = side == buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  return type;
}

double Sl()
{
  double sl = side == buy ? Bid() - points(SLMoney, userLots) : Bid() + points(SLMoney, userLots);
  return sl;
}
double Tp()
{
	double tp = side == buy ? Ask() + points(TPMoney, userLots) : Ask() - points(TPMoney, userLots);
  return tp;
}

double points(double risk, double lots)
{

	double _tickValue    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);   
	double _points       = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

// NOTE: points calculation money based:
	double distance = (risk * _points) / (lots * _tickValue) ;

	int _digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
  distance    = NormalizeDouble(distance, _digits);

  return distance;
}