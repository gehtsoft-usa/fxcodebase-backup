//+------------------------------------------------------------------+
//|                                                 CloseAllSell.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property show_confirm

int start()
{
 bool res;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_SELL)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Ask,5);
   if (!res) Print("LastError = ",GetLastError());
  }
 } 
 return(0);
}

