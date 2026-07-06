// Id: 19045
//+------------------------------------------------------------------+
//|                                           TrendStop_Strategy.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  3645656

extern int Length=10;
extern int Type=0;   // 0 - Close, 1 - High/Low
extern double Lots=0.1;

int OnInit()
  {
       double temp = iCustom(NULL, 0, "TrendStop", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TrendStop' indicator");
       return INIT_FAILED;
   }
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }
  
void CloseAll()
{
 bool res;
 int OT=OrdersTotal();
 for (int i=OT-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  res=OrderClose(OrderTicket(), OrderLots(), Bid, 5);
   if(OrderType()==OP_SELL) res=OrderClose(OrderTicket(), OrderLots(), Ask, 5);
  }
 }
 
}  

int CalculateOrders()
{
 int Count=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY) Count++;
   if(OrderType()==OP_SELL) Count--;
  }
 }
 return (Count);  
}

void OnTick()
  {
   int res;
   int CO;
   
   double TS1, TS2;
   
   TS1=iCustom(NULL, 0, "TrendStop", Length, Type, false, false, "", false, 0, 2);
   TS2=iCustom(NULL, 0, "TrendStop", Length, Type, false, false, "", false, 0, 3);
   
   if (TS1>Close[1] && TS2<Close[2])
   {
    // Buy
    Print("TS1="+TS1+", Close1="+Close[1]);
    CO=CalculateOrders();
    if (CO<0)
    {
     CloseAll();
    } 
    res=OrderSend(Symbol(), OP_BUY, Lots, Ask, 5, 0, 0, "", MAGICMA, 0, Blue);
   }
   
   if (TS1<Close[1] && TS2>Close[2])
   {
    // Sell
    CO=CalculateOrders();
    if (CO>0)
    {
     CloseAll();
    } 
    res=OrderSend(Symbol(), OP_SELL, Lots, Bid, 5, 0, 0, "", MAGICMA, 0, Blue);
   }
   

  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   
  }
  