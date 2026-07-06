// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69785
// More information about this indicator can be found at:
// http://fxcodebase.com/


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property version   "1.00"
#property strict

input double lotSize = 0.05;

input int staticSL = 150;
input int staticTP = 200;

int maxPositions = 1;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double macdArray[];
   
   ArraySetAsSeries(macdArray, true);
   
   double MACD = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double StochasticDef = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN,0);
   
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   if(maxPositions > OrdersTotal() && StochasticDef < 20 && MACD > 0)
   {
      int ticket=OrderSend(Symbol(),OP_BUY, lotSize, Ask, 3, Ask - (staticSL * _Point), Ask + (staticTP * _Point), "Stoch/MACD EA Long", 00120902, 0, clrGreen);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
        }
      else
         Print("OrderSend placed successfully");
   }
   
   if(maxPositions > OrdersTotal() && StochasticDef > 80 && MACD < 0)
   {
      int ticket=OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, Bid + (staticSL * _Point), Bid - (staticTP * _Point), "Stoch/MACD EA Short", 00120902, 0, clrRed);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
        }
      else
         Print("OrderSend placed successfully");
   }
  }
//+------------------------------------------------------------------+

