//+------------------------------------------------------------------+
//|                                                ReverseOrders.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property show_confirm

int MaxTry=10;

int start()
{
 bool res;
 int res2;
 double Lots;
 string Symb;
 int Magic;
 int k;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
   Lots=OrderLots();
   Symb=OrderSymbol();
   Magic=OrderMagicNumber();
   if(OrderType()==OP_BUY)
   {
    for (k=0;k<MaxTry;k++)
    {
     res=OrderClose(OrderTicket(),OrderLots(),Bid,5);
     if (res) break; else Sleep(5000);
    } 
    if (!res) 
    {
     Print("LastError = ",GetLastError());
    }
    else
    {
     for (k=0;k<MaxTry;k++)
     {
      res2=OrderSend(Symb, OP_SELL, Lots, Bid, 5, 0, 0, NULL, Magic);
      if (res2!=-1) break; else Sleep(5000);
     } 
    } 
   }
   if(OrderType()==OP_SELL)
   {
    for (k=0;k<MaxTry;k++)
    {
     res=OrderClose(OrderTicket(),OrderLots(),Ask,5);
     if (res) break; else Sleep(5000);
    } 
    if (!res) 
    {
     Print("LastError = ",GetLastError());
    }
    else
    {
     for (k=0;k<MaxTry;k++)
     {
      res2=OrderSend(Symb, OP_BUY, Lots, Ask, 5, 0, 0, NULL, Magic);
      if (res2!=-1) break; else Sleep(5000);
     } 
    } 
   }
  }
 } 
 return(0);
}

