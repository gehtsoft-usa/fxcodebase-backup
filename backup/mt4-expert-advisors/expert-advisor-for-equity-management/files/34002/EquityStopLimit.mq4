//+------------------------------------------------------------------+
//|                                              EquityStopLimit.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

extern double TP_Equity=0;
extern double SL_Equity=0;

bool Enable_Expert;

int init()
{
 Enable_Expert=true;
 return(0);
}

int deinit()
{
 return(0);
}
  
void CloseAll()
{
 bool res;
 bool AllClosed=true;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_BUY)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Bid,5);
   if (!res) 
   {
    Print("LastError = ",GetLastError());
    AllClosed=false;
   } 
  }
  if(OrderType()==OP_SELL)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Ask,5);
   if (!res) 
   {
    Print("LastError = ",GetLastError());
    AllClosed=false;
   }  
  }
 } 
 if (AllClosed) Enable_Expert=false;
 return;
}  

int start()
{
 if (Enable_Expert)
 {
  if (TP_Equity>0)
  {
   if (AccountEquity()>=TP_Equity) CloseAll();
  }
  if (SL_Equity>0)
  {
   if (AccountEquity()<=SL_Equity) CloseAll();
  } 
 }
 return(0);
}

