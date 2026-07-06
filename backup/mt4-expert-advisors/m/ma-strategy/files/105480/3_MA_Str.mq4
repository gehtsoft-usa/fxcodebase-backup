//+------------------------------------------------------------------+
//|                                                     3_MA_Str.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  36457736

input int Fast_MA_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
input int Fast_MA_Length=10;
input int Fast_MA_Price=0;    // Applied price
                              // 0 - Close
                              // 1 - Open
                              // 2 - High
                              // 3 - Low
                              // 4 - Median
                              // 5 - Typical
                              // 6 - Weighted  
                      
input int Medium_MA_Method=0;  // 0 - SMA
                               // 1 - EMA
                               // 2 - SMMA
                               // 3 - LWMA
input int Medium_MA_Length=20;
input int Medium_MA_Price=0;    // Applied price
                                // 0 - Close
                                // 1 - Open
                                // 2 - High
                                // 3 - Low
                                // 4 - Median
                                // 5 - Typical
                                // 6 - Weighted  
                      
input int Slow_MA_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
input int Slow_MA_Length=30;
input int Slow_MA_Price=0;    // Applied price
                              // 0 - Close
                              // 1 - Open
                              // 2 - High
                              // 3 - Low
                              // 4 - Median
                              // 5 - Typical
                              // 6 - Weighted  
                      
input string Allowed_Side_Str="Allowed side: 0 - Both, 1 - Buy, 2 - Sell";
input int Allowed_Side=0;  // 0 - Both, 1 - Buy, 2 - Sell
input bool Allow_Trade=true;
input double Lots=0.1;
input bool Set_Stop=true;
input int Stop=50;
input bool Set_Limit=true;
input int Limit=100;
input bool Show_Alert=true;
input bool Play_Sound=false;
input string Sound_File="";
input bool Send_Email=false;

datetime LastBar;

int OnInit()
{
 LastBar=0;
 
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

void _Alert(string op)
{
 if (Show_Alert)
 {
  Alert(Symbol()+" :"+op);
 } 
 
 if (Play_Sound)
 {
  PlaySound(Sound_File);
 }
 
 if (Send_Email)
 {
  SendMail(Symbol()+" :", op);
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
 if (LastBar==Time[1])
 {
  return;
 }
 LastBar=Time[1];
 
 double FMA0, FMA1, MMA0, MMA1, SMA0, SMA1;
 FMA0=iMA(NULL, 0, Fast_MA_Length, 0, Fast_MA_Method, Fast_MA_Price, 1);
 FMA1=iMA(NULL, 0, Fast_MA_Length, 0, Fast_MA_Method, Fast_MA_Price, 2);
 MMA0=iMA(NULL, 0, Medium_MA_Length, 0, Medium_MA_Method, Medium_MA_Price, 1);
 MMA1=iMA(NULL, 0, Medium_MA_Length, 0, Medium_MA_Method, Medium_MA_Price, 2);
 SMA0=iMA(NULL, 0, Slow_MA_Length, 0, Slow_MA_Method, Slow_MA_Price, 1);
 SMA1=iMA(NULL, 0, Slow_MA_Length, 0, Slow_MA_Method, Slow_MA_Price, 2);
 
 int CO;
 int res;
 double SL, TP;
 
 if (FMA1<=MMA1 && FMA0>MMA0)
 {
  _Alert("Close Sell");
  CO=CalculateOrders();
  if (CO<0)
  {
   if (Allow_Trade)
   {
    CloseAll();
   }
  } 
 }

 if (FMA1>=MMA1 && FMA0<MMA0)
 {
  _Alert("Close Buy");
  CO=CalculateOrders();
  if (CO>0)
  {
   if (Allow_Trade)
   {
    CloseAll();
   }
  } 
 }

 if (FMA1<=SMA1 && FMA0>SMA0) 
 {
  _Alert("Buy");
  CO=CalculateOrders();
  if (CO<=0)
  {
   if (Allow_Trade)
   {
    CloseAll();
    if (Allowed_Side!=2)
    {
     if (Set_Stop)
     {
      SL=NormalizeDouble(Bid-Stop*Point, Digits);
     }
     else
     {
      SL=0.;
     } 
     if (Set_Limit)
     {
      TP=NormalizeDouble(Bid+Limit*Point, Digits);
     }
     else
     {
      TP=0.;
     }
     res=OrderSend(Symbol(), OP_BUY, Lots, Ask, 5, SL, TP, "", MAGICMA, 0, Blue); 
    } 
   } 
   
  }
 }
 
 if (FMA1>=SMA1 && FMA0<SMA0) 
 {
  _Alert("Sell");
  CO=CalculateOrders();
  if (CO>=0)
  {
   if (Allow_Trade)
   {
    CloseAll();
    if (Allowed_Side!=1)
    {
     if (Set_Stop)
     {
      SL=NormalizeDouble(Ask+Stop*Point, Digits);
     }
     else
     { 
      SL=0.;
     } 
     if (Set_Limit)
     {
      TP=NormalizeDouble(Ask-Limit*Point, Digits);
     }
     else
     {
      TP=0.;
     }
     res=OrderSend(Symbol(), OP_SELL, Lots, Bid, 5, SL, TP, "", MAGICMA, 0, Blue); 
    } 
   } 
   
  }
 }
 

}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

}
  