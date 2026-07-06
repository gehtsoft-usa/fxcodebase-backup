//+------------------------------------------------------------------+
//|                                                       OCO_EA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

extern bool OnlyCurrentSymbol=false;
extern bool UseSound=false;
extern string NameSoundFile="expert.wav";

int init()
{

 return(0);
}

int deinit()
{

 return(0);
}
  
bool ExistMarketOrder()
{
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
   if (!OnlyCurrentSymbol || OrderSymbol()==Symbol())
   {
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) return (true);
   } 
  }
 }
 return (false);
}
  
void DeletePendingOrders()
{
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
   if (!OnlyCurrentSymbol || OrderSymbol()==Symbol())
   {
    if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT) OrderDelete(OrderTicket());
   } 
  }
 }
 return;
}
  
int start()
{
 if (ExistMarketOrder())
 {
  DeletePendingOrders();
  if (UseSound) PlaySound(NameSoundFile);
 }
 return(0);
}

