// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66881

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

#define     NL    "\n" 

extern int    ProfitTarget     = 25;             // closes all orders once profit hits this $ amount
extern int    StopLoss         = 25;             // closes all orders once loss hits this $ amount
extern bool   CloseAllNow      = false;          // closes all orders now
extern bool   CloseProfitableTradesOnly = false; // closes only profitable trades
extern double ProftableTradeAmount      = 1;     // Only trades above this amount close out
extern bool   ClosePendingOnly = false;          // closes pending orders only
extern bool   UseAlerts        = false;

//+-------------+
//| Custom init |
//|-------------+
int init()
{
   return 0;
}

//+----------------+
//| Custom DE-init |
//+----------------+
int deinit()
{
   return 0;
}

//+------------------------------------------------------------------------+
//| Closes everything
//+------------------------------------------------------------------------+
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
         if (UseAlerts) PlaySound("alert.wav");
      }
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
         if (UseAlerts) PlaySound("alert.wav");
      }
      Sleep(1000);
   }
}
   
//+------------------------------------------------------------------------+
//| cancels all orders that are in profit
//+------------------------------------------------------------------------+
void CloseAllinProfit()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType() == OP_BUY && OrderProfit()+OrderSwap()>ProftableTradeAmount)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
        if ( OrderType() == OP_SELL && OrderProfit()+OrderSwap()>ProftableTradeAmount)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
        if (UseAlerts) PlaySound("alert.wav");
 }
  return; 
}

//+------------------------------------------------------------------------+
//| cancels all pending orders 
//+------------------------------------------------------------------------+
void ClosePendingOrdersOnly()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType()== OP_BUYSTOP)   result = OrderDelete( OrderTicket() );
        if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
  }
  return; 
  }

//+-----------+
//| Main      |
//+-----------+
int start()
{
   int      OrdersBUY;
   int      OrdersSELL;
   double   BuyLots, SellLots, BuyProfit, SellProfit;

//+------------------------------------------------------------------+
//  Determine last order price                                       |
//-------------------------------------------------------------------+
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderType()==OP_BUY)  
      {
         OrdersBUY++;
         BuyLots += OrderLots();
         BuyProfit += OrderProfit() + OrderCommission() + OrderSwap();
      }
      if(OrderType()==OP_SELL) 
      {
         OrdersSELL++;
         SellLots += OrderLots();
         SellProfit += OrderProfit() + OrderCommission() + OrderSwap();
      }
   }               
   
   if(CloseAllNow) CloseAll();
   
   if(CloseProfitableTradesOnly) CloseAllinProfit();
    
   if (BuyProfit+SellProfit >= ProfitTarget || BuyProfit + SellProfit <= -StopLoss)
      CloseAll();

   if(ClosePendingOnly) ClosePendingOrdersOnly();
       
   
   Comment("                            Comments Last Update 12-12-2006 10:00pm", NL,
           "                            Buys    ", OrdersBUY, NL,
           "                            BuyLots        ", BuyLots, NL,
           "                            Sells    ", OrdersSELL, NL,
           "                            SellLots        ", SellLots, NL,
           "                            Balance ", AccountBalance(), NL,
           "                            Equity        ", AccountEquity(), NL,
           "                            Margin              ", AccountMargin(), NL,
           "                            MarginPercent        ", MathRound((AccountEquity()/AccountMargin())*100), NL,
           "                            Current Time is  ",TimeHour(CurTime()),":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()));
   return 0;
} // start()

 




