// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69021

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input ENUM_MA_METHOD method = MODE_SMA; // Smoothing method
input int period = 7; // Smoothing period

int init()
{
   return 0;
}

int deinit()
{
   return 0;
}

void CloseAll()
{
   int i;
   bool result = false;

   while(OrdersTotal()>0)
   {
      // Close open positions first to lock in profit/loss
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType() == OP_BUY)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 15, Red );
         if ( OrderType() == OP_SELL)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 15, Red );
      }
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
      }
   }
}
   
int start()
{
   double close0 = Close[0];
   double close1 = Close[1];
   double ma0 = iMA(_Symbol, _Period, period, 0, method, PRICE_CLOSE, 0);
   double ma1 = iMA(_Symbol, _Period, period, 0, method, PRICE_CLOSE, 1);
   if ((close0 < ma0 && close1 >= ma1) || (close0 > ma0 && close1 <= ma1))
      CloseAll();

   return 0;
}