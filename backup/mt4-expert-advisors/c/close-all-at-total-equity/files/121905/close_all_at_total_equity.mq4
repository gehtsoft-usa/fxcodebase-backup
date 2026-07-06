// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66881

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

extern double EL = 200000; // Equity Limit
extern double ES = 0; // Equity Stop

int OnInit()
{
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

bool stop = false;
void OnTick()
{
   if (stop)
      return;

   double Equity = AccountEquity();
   if (Equity >= EL)
   {
      closeAllTrades();
      removeAllOrders();
      stop = true;
   }
   else if (Equity <= ES)
   {
      closeAllTrades();
      removeAllOrders();
      stop = true;
   }
}

int closeAllTrades()
{
   int closedPositions = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderType() == OP_BUY)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), Bid, 5)) 
            {
               Print("LastError = ", GetLastError());
            }
            else
            {
               ++closedPositions;
            }
         }
         if (OrderType() == OP_SELL)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), Ask, 5)) 
            {
               Print("LastError = ", GetLastError());
            }
            else
            {
               ++closedPositions;
            }
         }
      }
   }
   return closedPositions;
}

void removeAllOrders()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)
         && OrderType() != OP_BUY
         && OrderType() != OP_SELL)
      {
         if (!OrderDelete(OrderTicket()))
         {
            Print("Failed to delete the order " + IntegerToString(OrderTicket()));
         }
      }
   }
}
